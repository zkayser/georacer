defmodule GeoRacerWeb.CourseController do
  use GeoRacerWeb, :controller
  alias GeoRacer.Courses
  alias GeoRacer.Races
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
            Routes.join_race_path(conn, :show, %{course_id: id, race_code: Races.generate_code()})
        )

      code ->
        LiveView.Controller.live_render(conn, Show,
          session: %{
            course: Courses.get_course!(id),
            code: code,
            current_team: get_team_name(conn)
          }
        )
    end
  end

  defp get_team_name(%{req_cookies: %{"geo_racer_team_name" => team_name}}) do
    case Base.decode64(team_name, padding: false) do
      {:ok, name} -> name
      :error -> ""
    end
  end

  defp get_team_name(_), do: ""
end
