defmodule GeoRacerWeb.RaceView.ViewModel do
  @moduledoc """
  Exposes a struct encapsulating data used for
  driving Race screen views. It also has a number
  of operations for updating the struct based on
  position of the current team, progress through
  the race, and events triggered through game play
  that require the Race view to display different
  information.
  """
  alias GeoRacer.Courses.{Course, Waypoint}
  alias GeoRacer.Races.Race
  alias Race.HotColdMeter

  defstruct position: nil,
            identifier: nil,
            team_name: "",
            race: nil,
            next_waypoint: nil,
            number_waypoints: 0,
            hot_cold_level: 0,
            has_reached_waypoint?: false,
            bounding_box: nil,
            timer: "00:00"

  @typep coordinates :: %{latitude: Float.t(), longitude: Float.t()}
  @type session :: %{identifier: String.t(), team_name: String.t(), race: Race.Impl.t()}
  @type t :: %__MODULE__{
          position: coordinates,
          identifier: String.t(),
          team_name: String.t(),
          race: GeoRacer.Races.Race.Impl.t(),
          next_waypoint: Waypoint.t() | :at_waypoint | :finished | nil,
          number_waypoints: non_neg_integer(),
          hot_cold_level: non_neg_integer(),
          bounding_box: %{southwest: coordinates, northeast: coordinates},
          timer: String.t()
        }

  @doc """
  Takes session passed along from the RaceController containing
  an identifier for geo location update channels, a team name, and
  a race struct. Bootstraps a ViewModel struct with the minimal amount
  of data needed to display the Race view.
  """
  @spec from_session(session) :: t()
  def from_session(%{identifier: identifier, team_name: team_name, race: race}) do
    %__MODULE__{
      identifier: identifier,
      team_name: team_name,
      race: race,
      number_waypoints: length(race.course.waypoints),
      bounding_box: Course.bounding_box(race.course)
    }
  end

  @doc """
  Updates the next waypoint for the current team to pursue.
  If there are no more waypoints remaining, the Race.next_waypoint/2
  function returns a :finished atom.
  """
  @spec set_next_waypoint(t()) :: t()
  def set_next_waypoint(%__MODULE__{} = view_model) do
    %__MODULE__{
      view_model
      | next_waypoint: Race.next_waypoint(view_model.race, view_model.team_name)
    }
  end

  @doc """
  Refreshes the race state by pulling the latest
  data out of the database.
  """
  @spec refresh_race(t()) :: t()
  def refresh_race(%__MODULE__{race: race} = view_model) do
    %__MODULE__{view_model | race: GeoRacer.Races.get_race!(race.id)}
  end

  @doc """
  Sets the next waypoint attribute to the atom,
  `:at_waypoint`. This represents a special state
  in that we can forego updating the position attributes
  and running checks to determine if the current team has
  reached a waypoint or updating the HotColdMeter.
  """
  @spec waypoint_reached(t()) :: t()
  def waypoint_reached(%__MODULE__{} = view_model) do
    Race.drop_waypoint(view_model.race, view_model.team_name)
    send(self(), :refresh_race)
    %__MODULE__{view_model | next_waypoint: :at_waypoint}
  end

  @doc """
  Sets the hot cold meter to the specified
  level.
  """
  @spec set_hot_cold_level(t(), non_neg_integer) :: t()
  def set_hot_cold_level(%__MODULE__{} = view_model, hot_cold_level) do
    %__MODULE__{view_model | hot_cold_level: hot_cold_level}
  end

  @doc """
  Sets the timer to the specified time.
  """
  @spec set_timer(t(), String.t()) :: t()
  def set_timer(%__MODULE__{} = view_model, time) do
    %__MODULE__{view_model | timer: time}
  end

  @doc """
  Updates the ViewModel's position attribute when it is important
  for the view to have the latest position coordinates. Position
  updating is not done when the current team has either reached a waypoint
  or has finished finding all of their waypoints.
  When the current team is actively searching for a waypoint, the position
  coordinates are constantly updated, and asynchronous processing is triggered
  to determine whether or not the current position is within a certain radius
  of the waypoint AND to update the hot cold meter.
  """
  @spec maybe_update_position(t(), coordinates) :: t()
  def maybe_update_position(%__MODULE__{next_waypoint: nil} = view_model, position) do
    %__MODULE__{view_model | position: position}
  end

  def maybe_update_position(%__MODULE__{next_waypoint: status} = view_model, _)
      when status in [:at_waypoint, :finished],
      do: view_model

  def maybe_update_position(
        %__MODULE__{next_waypoint: %Waypoint{} = waypoint, race: race} = view_model,
        position
      ) do
    detect_if_waypoint_reached(view_model, position)
    update_hot_cold_meter(waypoint, position, race.course)
    %__MODULE__{view_model | position: position}
  end

  defp detect_if_waypoint_reached(%__MODULE__{next_waypoint: %Waypoint{} = waypoint}, position) do
    view_pid = self()

    Task.start(fn ->
      if Waypoint.within_radius?(waypoint, position) do
        send(view_pid, :waypoint_reached)
      end
    end)
  end

  defp update_hot_cold_meter(waypoint, position, course) do
    view_pid = self()

    Task.start(fn ->
      send(
        view_pid,
        {:set_hot_cold_level,
         HotColdMeter.level(
           waypoint,
           position,
           Course.boundary_for(course)
         )}
      )
    end)
  end
end
