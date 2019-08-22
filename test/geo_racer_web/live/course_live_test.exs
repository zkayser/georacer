defmodule GeoRacerWeb.CourseLiveTest do
  use GeoRacerWeb.ConnCase
  alias GeoRacerWeb.{CourseLive, Endpoint}
  import Phoenix.LiveViewTest

  @position %{latitude: "39.10", longitude: "84.51"}
  @topic "position_updates"

  describe "CourseLive" do
    test "mounts when visiting the /courses/new path", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/courses/new")
      assert view.module == CourseLive
    end

    test "set_waypoint event adds the user's current location to the set waypoints", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/courses/new")
      update_position()

      assert render_click(view, "set_waypoint") =~ "#{@position.latitude}/#{@position.longitude}"
    end

    test "delete_waypoint removes the waypoint from the view", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/courses/new")
      update_position()
      render_click(view, "set_waypoint")

      new_position = %{latitude: "40.10", longitude: "85.51"}
      update_position(new_position)

      assert render_click(view, "set_waypoint") =~
               "#{new_position.latitude}/#{new_position.longitude}"

      refute render_click(view, "delete_waypoint", "1") =~
               "#{@position.latitude}/#{@position.longitude}"
    end
  end

  defp update_position(position \\ @position) do
    Endpoint.broadcast(@topic, "update", position)
  end
end
