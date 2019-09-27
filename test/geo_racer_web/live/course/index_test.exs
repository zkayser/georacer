defmodule GeoRacerWeb.Live.Course.IndexTest do
  use GeoRacerWeb.ConnCase
  import Phoenix.LiveViewTest

  setup context do
    {:ok, course} = GeoRacer.Factories.CourseFactory.insert()

    {:ok, course: course, conn: context.conn}
  end

  describe "Courses.Live" do
    test "mounts when visiting the /courses path", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/courses")
      assert view.module == GeoRacerWeb.Live.Courses.Index
    end

    test "clicking on public tab highlights the public tab", %{conn: conn} do
      {:ok, view, html} = live(conn, "/courses")
      new_html = render_click(view, "select_private")
      refute html == new_html
    end
  end
end
