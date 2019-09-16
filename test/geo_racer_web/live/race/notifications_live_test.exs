defmodule GeoRacerWeb.Race.NotificationsLiveTest do
  use GeoRacerWeb.ConnCase
  import Phoenix.LiveViewTest

  setup context do
    {:ok, race} = GeoRacer.Factories.RaceFactory.insert()
    team = race.team_tracker |> Map.keys() |> Enum.at(0)

    conn =
      context.conn
      |> put_req_cookie("geo_racer_team_name", Base.encode64(team, padding: false))

    {:ok, conn: conn, race: race, team: team}
  end

  describe "mount" do
    test "successful mount renders attacking team name and hazard", %{
      conn: conn,
      race: race,
      team: team
    } do
      {:ok, view, html} = live(conn, "/races/#{race.id}/notifications/MeterBomb/#{team}")

      assert view.module == GeoRacerWeb.Race.NotificationsLive
      assert html =~ "Meter Bomb"
      assert html =~ "#{team}"
    end

    test "redirects back to race if the hazard is invalid", %{conn: conn, race: race, team: team} do
      expected_redirect = "/races/#{race.id}"

      {:error, %{redirect: %{to: ^expected_redirect}}} =
        live(conn, "/races/#{race.id}/notifications/NotARealHazard/#{team}")
    end
  end
end
