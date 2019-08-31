defmodule GeoRacerWeb.Live.Course.NewTest do
  use GeoRacerWeb.ConnCase
  alias GeoRacerWeb.Endpoint
  import Phoenix.LiveViewTest

  @position %{latitude: 39.10, longitude: -84.51}
  @topic "position_updates:"
  @id_generator Application.get_env(:geo_racer, :id_generator)

  describe "Courses.New" do
    test "mounts when visiting the /courses/new path", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/courses/new")
      assert view.module == GeoRacerWeb.Live.Courses.New
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

      new_position = %{latitude: 40.10, longitude: 85.51}
      update_position(new_position)

      assert render_click(view, "set_waypoint") =~
               "#{new_position.latitude}/#{new_position.longitude}"

      refute render_click(view, "delete_waypoint", "1") =~
               "#{@position.latitude}/#{@position.longitude}"
    end
  end

  test "create_course creates a course and redirects to /courses/:id", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/courses/new")
    update_position()
    render_click(view, "set_waypoint")

    new_position = %{latitude: 40.10, longitude: -85.51}
    update_position(new_position)

    render_click(view, "set_waypoint")
    race_name = "My amazing race #{:rand.uniform() * 100_000}"

    render_change(view, "update_race_name", %{
      "race_name" => race_name
    })

    assert_redirect(
      view,
      "/courses/" <> id,
      fn ->
        render_click(view, "create_course")
      end
    )
  end

  test "renders the terms and conditions overlay on first visit", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/courses/new")
    assert html =~ "data-qa=\"terms_and_conditions\""
  end

  test "redirects to same path when terms and conditions are accepted", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/courses/new")

    assert_redirect(
      view,
      "/courses/new?accepted_terms_and_conditions=yes",
      fn ->
        render_click(view, "accept_terms")
      end
    )
  end

  # Default Opts are required to setup a plug session config
  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false
  ]
  @session_opts Plug.Session.init(@default_opts)
  @terms_and_conditions_key "geo_racer_accepted_terms_and_conditions"
  test "does not render terms and conditions for users who have already accepted", %{conn: conn} do
    conn =
      conn.secret_key_base
      |> put_in(System.get_env("SECRET_KEY_BASE"))
      |> Plug.Session.call(@session_opts)
      |> fetch_session(@terms_and_conditions_key)
      |> put_session(@terms_and_conditions_key, "yes")

    {:ok, _view, html} = live(conn, "/courses/new")

    refute html =~ "data-qa=\"terms_and_conditions\""
  end

  defp update_position(position \\ @position) do
    Endpoint.broadcast(@topic <> @id_generator.(), "update", position)
  end
end
