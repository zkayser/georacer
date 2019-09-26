defmodule GeoRacer.Races.Race.Impl do
  @moduledoc """
  Implements a struct encapsulating data for a race.
  """
  alias GeoRacer.Hazards
  alias GeoRacer.Hazards.MeterBomb
  alias GeoRacer.Races.Race.{HotColdMeter, Result}
  alias GeoRacer.Races.StagingArea.Impl, as: StagingArea
  alias GeoRacer.Courses.{Course, Waypoint}
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @one_day 60 * 60 * 24

  schema "races" do
    field :code, :string
    field :team_tracker, :map
    field :status, :string
    field :time, :integer, default: 0
    field :becomes_idle_at, :integer, virtual: true, default: @one_day

    has_many :hazards, GeoRacer.Hazards.Hazard,
      on_delete: :delete_all,
      on_replace: :delete,
      foreign_key: :race_id

    has_many :results, GeoRacer.Races.Race.Result,
      on_delete: :delete_all,
      on_replace: :delete,
      foreign_key: :race_id

    belongs_to :course, GeoRacer.Courses.Course, on_replace: :delete
    timestamps()
  end

  @typep team_name :: String.t()
  @typep waypoint_id :: pos_integer()

  @type status :: String.t()
  @type team_tracker :: %{optional(team_name) => list(waypoint_id)}

  @type t() :: %__MODULE__{
          code: String.t(),
          course: Course.t(),
          time: integer(),
          becomes_idle_at: integer(),
          hazards: map(),
          team_tracker: team_tracker,
          status: status
        }

  @valid_name_regex ~r/(?<course_id>\d+):(?<race_code>[\d+\w+]{8})/

  @doc """
  Takes a `GeoRacer.Races.StagingArea.Impl` struct and
  creates a new Race, or returns an error tuple if
  it cannot find an existing course based off the
  `StagingArea`'s identifier.
  """
  # @spec from_staging_area(StagingArea.t()) :: {:ok, t()} | {:error, :invalid}
  def from_staging_area(%StagingArea{} = staging_area) do
    with %{"course_id" => course_id, "race_code" => race_code} <-
           Regex.named_captures(@valid_name_regex, staging_area.identifier),
         %Course{} = course <- GeoRacer.Courses.get_course!(course_id) do
      race_attrs = %{
        code: race_code,
        team_tracker:
          Enum.reduce(staging_area.teams, %{}, fn team, acc ->
            Map.put(
              acc,
              team,
              course.waypoints |> Enum.map(fn waypoint -> waypoint.id end) |> Enum.shuffle()
            )
          end),
        status: "started",
        time: 0,
        course_id: course.id
      }

      GeoRacer.Races.StagingArea.stop("#{course_id}:#{race_code}")

      GeoRacer.Races.create_race(race_attrs)
    else
      _ -> {:error, :invalid}
    end
  end

  @doc """
  Creates a Query for finding Races based off course_id
  and code.
  """
  @spec course_and_code_query(pos_integer(), String.t()) :: Ecto.Query.t()
  def course_and_code_query(course_id, code) do
    from r in __MODULE__, where: r.course_id == ^course_id and r.code == ^code
  end

  @doc """
  Creates a changeset for a Race.
  """
  @spec changeset(t(), term()) :: Ecto.Changeset.t()
  def changeset(race, attrs) do
    race
    |> cast(attrs, [:code, :team_tracker, :status, :course_id, :time])
    |> validate_required([:code, :team_tracker, :course_id])
    |> validate_inclusion(:status, ["started", "not_started", "completed"])
    |> validate_length(:code, is: 8)
    |> unsafe_validate_unique([:course_id, :code], GeoRacer.Repo,
      message: "another race created from this course id has the same code"
    )
    |> unique_constraint(:code, name: :identifier_index)
  end

  @doc """
  Returns the next waypoint for `team`.
  """
  @spec next_waypoint(t(), String.t()) :: Waypoint.t() | :finished
  def next_waypoint(
        %__MODULE__{course: %Course{waypoints: waypoints}, team_tracker: team_tracker},
        team
      ) do
    case team_tracker[team] do
      [] ->
        send(self(), {:record_finished, team})
        :finished

      [id | _] ->
        hd(Enum.reject(waypoints, fn waypoint -> waypoint.id != id end))
    end
  end

  @doc """
  Records the time at which `team` finished.
  """
  @spec record_finished(t(), String.t()) ::
          {:ok, t()} | {:error, Ecto.Changeset.t()} | {:error, :invalid_team}
  def record_finished(%__MODULE__{} = race, team) do
    with false <- team in Enum.map(race.results, fn result -> result.team end),
         true <- team in Map.keys(race.team_tracker) do
      Result.create(team, race)
      GeoRacer.Races.update_race(GeoRacer.Races.get_race!(race.id), %{time: race.time})
    else
      _ -> {:error, :invalid_team}
    end
  end

  @doc """
  Returns true when the race is completed, meaning
  all teams have reached all of their waypoints.
  """
  @spec is_race_completed?(t()) :: boolean()
  def is_race_completed?(%__MODULE__{team_tracker: team_tracker} = race) do
    case Enum.all?(Map.values(team_tracker), fn remaining_waypoints ->
           Enum.empty?(remaining_waypoints)
         end) do
      true ->
        Task.start(fn -> GeoRacer.Races.update_race(race, %{status: "completed"}) end)
        true

      false ->
        false
    end
  end

  @doc """
  Drops a single waypoint from the list of
  `team`'s remaining waypoints.
  """
  @spec drop_waypoint(t(), String.t()) ::
          {:ok, t()} | {:error, Ecto.Changeset.t()} | {:error, :invalid_team}
  def drop_waypoint(%__MODULE__{team_tracker: team_tracker} = race, team_name) do
    case team_name in Map.keys(team_tracker) do
      false ->
        {:error, :invalid_team}

      true ->
        attrs = %{
          team_tracker: %{team_tracker | team_name => Enum.drop(team_tracker[team_name], 1)}
        }

        race
        |> GeoRacer.Races.update_race(attrs)
    end
  end

  @doc """
  Returns the HotColdMeter implementation for `team`
  based on whether the team is currently affected by
  a `MeterBomb` hazard.
  """
  @spec hot_cold_meter(t(), String.t()) :: HotColdMeter | MeterBomb
  def hot_cold_meter(%__MODULE__{time: seconds} = race, team) do
    race.hazards
    |> Enum.filter(fn %{affected_team: affected} -> affected == team end)
    |> Enum.filter(fn %{name: name, expiration: expiration} ->
      name == Hazards.name_for(MeterBomb) and expiration >= seconds
    end)
    |> case do
      [] -> HotColdMeter
      _ -> MeterBomb
    end
  end

  @doc """
  Shuffles the list of waypoints of the affected team
  """
  @spec shuffle_waypoints(t(), String.t()) :: t()
  def shuffle_waypoints(
        %__MODULE__{team_tracker: team_tracker} = race,
        affected_team
      ) do
    [current|remaining] = team_tracker[affected_team]
    new_team_tracker = %{
      team_tracker
      | affected_team =>
          Enum.shuffle(remaining) ++ [current]
    }

    GeoRacer.Races.update_race(race, %{team_tracker: new_team_tracker})
  end
end
