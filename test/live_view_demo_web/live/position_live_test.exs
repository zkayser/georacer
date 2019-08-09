defmodule LiveViewDemoWeb.PositionLiveTest do
  use LiveViewDemoWeb.ConnCase
  alias LiveViewDemoWeb.{PositionLive, Endpoint}
  import Phoenix.LiveViewTest

  @position %{latitude: "39.10", longitude: "84.51"}
  @topic "position_updates"

  describe "PositionLive" do
    test "mounts when visiting the /position path", %{conn: conn} do
      {:ok, view, html} = live(conn, "/position")
      assert view.module == PositionLive
      assert html =~ "<h2>"
    end

    test "subscribes to the position_updates pubsub topic on mount", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/position")
      Endpoint.broadcast(@topic, "update", @position)
      assert render(view) =~ @position.latitude
      assert render(view) =~ @position.longitude
    end
  end
end
