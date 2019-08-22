defmodule GeoRacerWeb.CourseControllerTest do
  use GeoRacerWeb.ConnCase

  test "GET /courses", %{conn: conn} do
    conn = get(conn, "/courses")
    assert html_response(conn, 200)
  end
end
