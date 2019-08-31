defmodule GeoRacerWeb.RaceLiveTest do
  use GeoRacerWeb.ConnCase
  alias GeoRacerWeb.{RaceLive, Endpoint}
  import Phoenix.LiveViewTest

  @position %{latitude: 39.10, longitude: 84.51}
  @topic "position_updates:"
  @id_generator Application.get_env(:geo_racer, :id_generator)

  setup context do
    {:ok, race} = GeoRacer.Factories.RaceFactory.insert()
    team = race.team_tracker |> Map.keys() |> Enum.at(0)

    conn =
      context.conn
      |> put_req_cookie("geo_racer_team_name", Base.encode64(team, padding: false))

    {:ok, conn: conn, race: race, team: team}
  end

  describe "RaceLive" do
    test "mounts when visiting the /races path", %{conn: conn, race: race} do
      {:ok, view, html} = live(conn, "/races/#{race.id}")
      assert view.module == RaceLive
      assert html =~ "<gr-map"
    end

    test "subscribes to the position_updates pubsub topic on mount", %{conn: conn, race: race} do
      {:ok, view, _html} = live(conn, "/races/#{race.id}")
      Endpoint.broadcast(@topic <> @id_generator.(), "update", @position)
      assert render(view) =~ "#{@position.latitude}"
      assert render(view) =~ "#{@position.longitude}"
    end

    test "subscribes to race_time:race_id pubsub topic on mount", %{
      conn: conn,
      race: race
    } do
      {:ok, _view, _html} = live(conn, "/races/#{race.id}")

      assert_receive %Phoenix.Socket.Broadcast{event: "tick", payload: %{"clock" => "00:01"}},
                     1000
    end
  end
end
