defmodule GeoRacerWeb.JoinRaceController do
  alias GeoRacer.Races.StagingArea
  use GeoRacerWeb, :controller

  def create(conn, %{"staging_area" => %{"team_name" => ""} = params}) do
    conn
    |> put_flash(:team_name, "Team name must not be blank")
    |> redirect(
      to:
        Routes.join_race_path(conn, :show, %{
          "race_code" => params["race_code"],
          "course_id" => params["course_id"]
        })
    )
  end

  def create(conn, %{
        "staging_area" => %{
          "race_code" => race_code,
          "course_id" => course_id,
          "expected_code" => expected_code,
          "team_name" => team_name
        }
      }) do
    case StagingArea.Validators.run_validations(%{
           course_id: course_id,
           race_code: race_code,
           expected_code: expected_code,
           team_name: team_name
         }) do
      :ok ->
        StagingArea.Supervisor.create_staging_area("#{course_id}:#{expected_code}")

        conn
        |> put_resp_cookie("geo_racer_team_name", Base.encode64(team_name))
        |> redirect(to: Routes.course_path(conn, :show, course_id, %{race_code: expected_code}))

      {:error, errors} ->
        errors
        |> Enum.reduce(conn, fn {error_key, value}, conn ->
          put_flash(conn, error_key, value)
        end)
        |> redirect(
          to:
            Routes.join_race_path(conn, :show, %{
              "race_code" => race_code,
              "course_id" => course_id
            })
        )
    end
  end

  def create(conn, _) do
    conn
    |> put_status(:bad_request)
    |> redirect(to: "/")
  end

  def show(conn, %{"race_code" => race_code, "course_id" => course_id}) do
    case StagingArea.Validators.is_valid_identifier?(course_id, race_code) do
      true ->
        render(conn, "show.html", %{race_code: race_code, course_id: course_id})

      false ->
        conn
        |> put_flash(
          :error,
          "Looks like you're trying to join a race that doesn't exist. Try joining or creating another race."
        )
        |> redirect(to: Routes.course_path(conn, :index))
    end
  end

  def show(conn, _), do: redirect(conn, to: Routes.course_path(conn, :index))
end
