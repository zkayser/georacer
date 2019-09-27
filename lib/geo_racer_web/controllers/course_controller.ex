defmodule GeoRacerWeb.CourseController do
  use GeoRacerWeb, :controller
  alias GeoRacer.Courses
  alias GeoRacer.Races
  alias GeoRacerWeb.Live.Courses.{Index, New, Show}
  alias GeoRacerWeb.Plugs.{FetchTeamName, UserUUID}
  alias Phoenix.LiveView

  @id_generator Application.get_env(:geo_racer, :id_generator) || (&UUID.uuid4/0)
  @terms_and_conditions_session_key "geo_racer_accepted_terms_and_conditions"

  plug FetchTeamName when action in [:show]
  plug UserUUID

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, Index,
      session: %{
        identifier: @id_generator.(),
        courses: Courses.list_courses(conn.assigns[:user_uuid]),
        public_courses: GeoRacer.Courses.list_public_courses()
      }
    )
  end

  def new(conn, params) do
    render_view = fn conn, has_accepted_terms_and_conditions? ->
      LiveView.Controller.live_render(conn, New,
        session: %{
          identifier: @id_generator.(),
          has_accepted_terms_and_conditions?: has_accepted_terms_and_conditions?,
          user_uuid: conn.assigns[:user_uuid]
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
        # --> Redirect to race if a Race exists for course_id and race_code
        LiveView.Controller.live_render(conn, Show,
          session: %{
            course: Courses.get_course!(id),
            code: code,
            current_team: conn.assigns[:team_name]
          }
        )
    end
  end

  defp fetch_has_accepted_terms_and_conditions(conn) do
    case get_session(conn, @terms_and_conditions_session_key) do
      "yes" -> true
      _ -> false
    end
  end
end
