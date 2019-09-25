defmodule GeoRacerWeb.HazardsLiveTest do
  use GeoRacerWeb.ConnCase
  import Phoenix.LiveViewTest

  setup context do
    {:ok, race} = GeoRacer.Factories.RaceFactory.insert()

    [attacking_team, affected_team] = Map.keys(race.team_tracker)

    {:ok,
     conn: context.conn, race: race, attacking_team: attacking_team, affected_team: affected_team}
  end

  describe "handle_event -- use_hazard" do
    test "redirects to race when affected_team has been selected", %{conn: conn} = context do
      {:ok, view, _html} = live(conn, "/races/#{context.race.id}/hazards")

      render_click(view, "select_team", %{"selected" => context.affected_team})
      expected_path = "/races/#{context.race.id}"

      assert_redirect(view, ^expected_path, fn ->
        assert render_click(view, "use_hazard")
      end)
    end

    test "renders error message when no affected_team has been selected",
         %{conn: conn} = context do
      {:ok, view, _html} = live(conn, "/races/#{context.race.id}/hazards")

      assert render_click(view, "use_hazard") =~ "Select a team to attack"
    end
  end
end
