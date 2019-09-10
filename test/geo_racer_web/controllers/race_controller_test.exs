defmodule GeoRacerWeb.RaceControllerTest do
  use GeoRacerWeb.ConnCase

  setup %{conn: conn} do
    {:ok, race} = GeoRacer.Factories.RaceFactory.insert()

    {:ok, conn: conn, race: race}
  end

  test "GET /races/:course_id/:race_code redirects to /races/:id if race exists", %{
    conn: conn,
    race: race
  } do
    conn = get(conn, "races/#{race.course.id}/#{race.code}")
    assert redirected_to(conn) =~ "/races/#{race.id}"
  end

  test "GET /races/:course_id/:race_code returns a 404 if associated race does not exist", %{
    conn: conn
  } do
    conn = get(conn, "races/2/#{GeoRacer.Races.generate_code()}")
    assert response(conn, 404)
  end

  test "GET /races/:id", %{conn: conn, race: race} do
    conn =
      conn
      |> put_req_cookie(
        "geo_racer_team_name",
        Base.encode64(Enum.at(Map.keys(race.team_tracker), 0), padding: false)
      )
      |> get("/races/#{race.id}")

    assert html_response(conn, 200)
  end

  test "GET /races/:id redirects if no team can be derived from cookies or session", %{
    conn: conn,
    race: race
  } do
    conn = get(conn, "/races/#{race.id}")
    assert redirected_to(conn) =~ "/courses"
  end

  test "GET /races/:id redirects if the team name from session is not participating in the race",
       %{conn: conn, race: race} do
    conn =
      conn
      |> put_req_cookie("geo_racer_team_name", Base.encode64("some random team", padding: false))
      |> get("/races/#{race.id}")

    assert redirected_to(conn) =~ "/courses"
  end

  test "GET /races/:id/notifications/:hazard/:attacking_team", %{conn: conn, race: race} do
    conn = get(conn, "/races/#{race.id}/notifications/MeterBomb/the%20attackers")

    assert html_response(conn, 200) =~ "Meter Bomb"
  end
end
