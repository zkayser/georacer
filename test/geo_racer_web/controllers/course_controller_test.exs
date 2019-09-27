defmodule GeoRacerWeb.CourseControllerTest do
  use GeoRacerWeb.ConnCase
  import Phoenix.LiveViewTest
  alias GeoRacer.Factories.CourseFactory

  setup %{conn: conn} do
    {:ok, course} = CourseFactory.insert()

    {:ok, conn: conn, course: course}
  end

  test "GET /courses", %{conn: conn} do
    assert {:ok, _view, html} = live(conn, "/courses")
  end

  test "GET /courses/:id redirects with to /join-race with course_id and race_code params if no race_code query param exists",
       %{
         conn: conn
       } do
    conn = get(conn, "/courses/2")
    assert redirected_to(conn) =~ ~r(\/join-race\?course_id=\d+?&race_code=[\d\w]{8})
  end

  test "GET /courses/:id with race_code query param", %{conn: conn, course: course} do
    race_code = Base.encode16(:crypto.strong_rand_bytes(4))
    conn = get(conn, "/courses/#{course.id}?race_code=#{race_code}")
    assert html_response(conn, 200) =~ race_code
  end
end
