defmodule GeoRacerWeb.CourseController do
  use GeoRacerWeb, :controller
  alias GeoRacer.Courses
  alias GeoRacerWeb.Live.Courses.{New, Show}
  alias Phoenix.LiveView

  @id_generator Application.get_env(:geo_racer, :id_generator)

  def index(conn, _params) do
    render(conn, "index.html", courses: Courses.list_courses())
  end

  def new(conn, _) do
    LiveView.Controller.live_render(conn, New, session: %{identifier: @id_generator.()})
  end

  def show(conn, %{"id" => id} = params) do
    case params["race_code"] do
      nil ->
        redirect(conn,
          to:
            Routes.course_path(conn, :show, id,
              race_code: Base.encode16(:crypto.strong_rand_bytes(4))
            )
        )

      code ->
        LiveView.Controller.live_render(conn, Show,
          session: %{course: Courses.get_course!(id), code: code}
        )
    end
  end
end
