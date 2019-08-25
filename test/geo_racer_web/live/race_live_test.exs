defmodule GeoRacerWeb.PositionLiveTest do
  use GeoRacerWeb.ConnCase
  alias GeoRacerWeb.{RaceLive, Endpoint}
  import Phoenix.LiveViewTest

  @position %{latitude: 39.10, longitude: 84.51}
  @topic "position_updates:"
  @id_generator Application.get_env(:geo_racer, :id_generator)

  describe "RaceLive" do
    test "mounts when visiting the /race path", %{conn: conn} do
      {:ok, view, html} = live(conn, "/race")
      assert view.module == RaceLive
      assert html =~ "<gr-map"
    end

    test "subscribes to the position_updates pubsub topic on mount", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/race")
      Endpoint.broadcast(@topic <> @id_generator.(), "update", @position)
      assert render(view) =~ "#{@position.latitude}"
      assert render(view) =~ "#{@position.longitude}"
    end
  end
end
