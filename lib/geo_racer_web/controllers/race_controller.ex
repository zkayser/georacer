defmodule GeoRacerWeb.RaceController do
  use GeoRacerWeb, :controller
  alias GeoRacer.Races
  alias GeoRacerWeb.Plugs.FetchTeamName
  alias Phoenix.LiveView

  @id_generator Application.get_env(:geo_racer, :id_generator) || (&UUID.uuid4/0)

  plug FetchTeamName when action in [:show]

  def show(conn, %{"id" => id}) do
    race = Races.get_race!(id)

    LiveView.Controller.live_render(
      conn,
      GeoRacerWeb.RaceLive,
      session: %{
        identifier: @id_generator.(),
        team_name: conn.assigns[:team_name],
        race: race
      }
    )
  end

  def show(conn, %{"course_id" => id, "race_code" => race_code}) do
    case Races.by_course_id_and_code(id, race_code) do
      nil ->
        conn |> put_status(:not_found) |> put_view(GeoRacerWeb.ErrorView) |> render("404.html")

      race ->
        redirect(conn, to: Routes.race_path(conn, :show, race))
    end
  end

  def notifications(
        conn,
        %{
          "race_id" => race_id,
          "hazard" => hazard,
          "attacking_team" => attacking_team
        }
      ) do
    LiveView.Controller.live_render(
      conn,
      GeoRacerWeb.Race.NotificationsLive,
      session: %{
        race_id: race_id,
        hazard: hazard,
        attacking_team: attacking_team
      }
    )
  end
end
