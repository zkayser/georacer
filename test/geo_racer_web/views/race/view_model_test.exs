defmodule GeoRacerWeb.RaceView.ViewModelTest do
  use GeoRacer.DataCase
  alias GeoRacer.StringGenerator
  alias GeoRacer.Courses.Waypoint
  alias GeoRacer.Hazards.MeterBomb
  alias GeoRacer.Races.Race.{Supervisor, HotColdMeter}
  alias GeoRacerWeb.RaceView.ViewModel

  setup do
    {:ok, race} = GeoRacer.Factories.RaceFactory.insert()

    session = %{
      identifier: StringGenerator.random_string(),
      team_name: team_name(race),
      race: race
    }

    Supervisor.create_race(race)
    {:ok, race: race, session: session}
  end

  describe "from_session/1" do
    test "takes a session map and creates a new view model", %{race: race, session: session} do
      assert %ViewModel{race: ^race} = ViewModel.from_session(session)
    end

    test "calculates the number of waypoints reached by team", %{session: session} do
      view_model = ViewModel.from_session(session)
      assert view_model.waypoints_reached == 0
    end
  end

  describe "set_next_waypoint/1" do
    test "sets the next waypoint for the current team", %{race: race, session: session} do
      view_model = ViewModel.from_session(session)

      assert %Waypoint{id: id} = ViewModel.set_next_waypoint(view_model).next_waypoint
      assert id == List.first(race.team_tracker[team_name(race)])
    end

    test "sets the next waypoint to finished for the current team if there are no more waypoints left",
         %{race: race, session: session} do
      view_model = ViewModel.from_session(session)

      GeoRacer.Races.Race.drop_waypoint(race, team_name(race))
      GeoRacer.Races.Race.drop_waypoint(race, team_name(race))

      assert :finished = ViewModel.set_next_waypoint(view_model).next_waypoint
    end
  end

  describe "waypoint_reached/1" do
    test "sets the next waypoint to :at_waypoint", %{session: session} do
      view_model = ViewModel.from_session(session)

      assert :at_waypoint = ViewModel.waypoint_reached(view_model).next_waypoint
    end

    test "drops the current waypoint from the race state", %{session: session} do
      view_model =
        session
        |> ViewModel.from_session()
        |> ViewModel.set_next_waypoint()

      ViewModel.waypoint_reached(view_model)

      refute view_model.next_waypoint ==
               GeoRacer.Races.Race.next_waypoint(view_model.race, team_name(view_model.race))
    end

    test "updates the waypoints_reached attribute", %{session: session} do
      view_model =
        session
        |> ViewModel.from_session()
        |> ViewModel.set_next_waypoint()

      updated_view_model = ViewModel.waypoint_reached(view_model)

      assert updated_view_model.waypoints_reached == view_model.waypoints_reached + 1
    end

    test "sends a :refresh_race_state message", %{session: session} do
      view_model = ViewModel.from_session(session)

      ViewModel.waypoint_reached(view_model)

      assert_receive :refresh_race
    end
  end

  describe "maybe_update_position/2" do
    @position %{latitude: 39.10, longitude: -84.51}
    test "updates position if next_waypoint is nil (race has not yet started)", %{
      session: session
    } do
      view_model = ViewModel.from_session(session)

      assert @position == ViewModel.maybe_update_position(view_model, @position).position
    end

    test "updates position if next_waypoint is a Waypoint struct", %{session: session} do
      view_model =
        session
        |> ViewModel.from_session()
        |> ViewModel.set_next_waypoint()

      assert @position == ViewModel.maybe_update_position(view_model, @position).position
    end

    test "sends a reached waypoint message if position is within radius of next_waypoint", %{
      session: session
    } do
      view_model =
        session
        |> ViewModel.from_session()
        |> ViewModel.set_next_waypoint()

      waypoint = view_model.next_waypoint

      coordinates = Waypoint.to_coordinates(waypoint)

      ViewModel.maybe_update_position(view_model, coordinates)

      assert_receive :waypoint_reached
    end

    test "updates the hot cold meter based on the current position and the next waypoint", %{
      session: session
    } do
      view_model =
        session
        |> ViewModel.from_session()
        |> ViewModel.set_next_waypoint()

      ViewModel.maybe_update_position(view_model, @position)

      assert_receive {:set_hot_cold_level, hot_cold_level}
    end

    test "is a no-op when the team is at a waypoint", %{session: session} do
      view_model =
        session
        |> ViewModel.from_session()

      view_model = %ViewModel{view_model | next_waypoint: :at_waypoint}

      assert view_model.position ==
               ViewModel.maybe_update_position(view_model, @position).position
    end

    test "is a no-op when the team is finished finding all waypoints", %{session: session} do
      view_model = ViewModel.from_session(session)

      view_model = %ViewModel{view_model | next_waypoint: :finished}

      assert view_model.position ==
               ViewModel.maybe_update_position(view_model, @position).position
    end
  end

  describe "refresh_race/1" do
    test "refreshes the race by pulling the entire race from the DB", %{session: session} do
      view_model = ViewModel.from_session(session)

      # Change race, picking `status` as attribute to update for simplicity
      GeoRacer.Races.update_race(view_model.race, %{"status" => "completed"})

      refreshed = ViewModel.refresh_race(view_model)

      refute view_model.race.status == refreshed.race.status
    end
  end

  describe "update_race/2" do
    test "replaces the race property with the race passed in", %{session: session} do
      view_model = ViewModel.from_session(session)

      original = view_model.race
      updated = ViewModel.update_race(view_model, %GeoRacer.Races.Race.Impl{}).race

      refute original == updated
    end
  end

  describe "set_hot_cold_level/2" do
    test "updates the hot_cold_meter with the given level", %{session: session} do
      view_model = ViewModel.from_session(session)

      assert 3 = ViewModel.set_hot_cold_level(view_model, 3).hot_cold_level
    end
  end

  describe "set_hot_cold_meter/2" do
    test "updates the hot_cold_meter with the given HotColdMeter implementation", %{
      session: session
    } do
      view_model = ViewModel.from_session(session)

      assert MeterBomb == ViewModel.set_hot_cold_meter(view_model, MeterBomb).hot_cold_meter
      assert HotColdMeter == ViewModel.set_hot_cold_meter(view_model, HotColdMeter).hot_cold_meter
    end
  end

  describe "set_timer/2" do
    test "updates the timer with the given time", %{session: session} do
      view_model = ViewModel.from_session(session)

      assert "01:00" = ViewModel.set_timer(view_model, "01:00").timer
    end
  end

  defp team_name(race) do
    race.team_tracker
    |> Map.keys()
    |> List.first()
  end
end
