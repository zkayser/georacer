defmodule GeoRacerWeb.CourseController do
  use GeoRacerWeb, :controller
  alias GeoRacer.Courses
  alias GeoRacer.Races
  alias GeoRacerWeb.Live.Courses.{New, Show}
  alias Phoenix.LiveView

  @id_generator Application.get_env(:geo_racer, :id_generator)
  @terms_and_conditions_session_key "geo_racer_accepted_terms_and_conditions"

  def index(conn, _params) do
    render(conn, "index.html", courses: Courses.list_courses())
  end

  def new(conn, params) do
    render_view = fn conn, has_accepted_terms_and_conditions? ->
      LiveView.Controller.live_render(conn, New,
        session: %{
          identifier: @id_generator.(),
          has_accepted_terms_and_conditions?: has_accepted_terms_and_conditions?
        }
      )
    end

    case params["accepted_terms_and_conditions"] do
      "yes" ->
        conn = put_session(conn, @terms_and_conditions_session_key, "yes")
        render_view.(conn, true)

      _ ->
        render_view.(conn, fetch_has_accepted_terms_and_conditions(conn))
    end
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

  defp fetch_has_accepted_terms_and_conditions(conn) do
    case get_session(conn, @terms_and_conditions_session_key) do
      "yes" -> true
      _ -> false
    end
  end
end
