defmodule GeoRacerWeb.JoinRaceControllerTest do
  use GeoRacerWeb.ConnCase

  test "GET /join-race with no params redirects", %{conn: conn} do
    conn = get(conn, "/join-race")
    assert redirected_to(conn) =~ "/courses"
  end

  test "GET /join-race with race_code but non-existent course id", %{conn: conn} do
    conn = get(conn, "/join-race?race_code=1234&course_id=239182301982340129")
    assert redirected_to(conn) =~ "/courses"
  end

  test "GET /join-race with race_code and valid course id", %{conn: conn} do
    {:ok, course} = GeoRacer.Factories.CourseFactory.insert()

    conn = get(conn, "/join-race?race_code=1234&course_id=#{course.id}")
    assert html_response(conn, 200)
  end

  test "POST /staging-area with invalid course id", %{conn: conn} do
    conn =
      post(conn, "/staging-area", %{
        "staging_area" => %{
          "race_code" => "1234",
          "course_id" => "2313123412",
          "expected_code" => "1234",
          "team_name" => "My team"
        }
      })

    assert redirected_to(conn) =~ "/join-race?"
  end

  test "POST /staging-area success path", %{conn: conn} do
    {:ok, course} = GeoRacer.Factories.CourseFactory.insert()
    code = GeoRacer.Races.generate_code()

    conn =
      post(conn, "/staging-area", %{
        "staging_area" => %{
          "race_code" => code,
          "expected_code" => code,
          "course_id" => "#{course.id}",
          "team_name" => "My team"
        }
      })

    assert GeoRacer.Races.StagingArea.Supervisor.started?("#{course.id}:#{code}")
    assert conn.resp_cookies["geo_racer_team_name"][:value] == Base.encode64("My team")
    assert redirected_to(conn) =~ "/courses/#{course.id}"
  end

  test "POST /staging-area with team name that has been taken", %{conn: conn} do
    {:ok, course} = GeoRacer.Factories.CourseFactory.insert()
    code = GeoRacer.Races.generate_code()

    {:ok, identifier} =
      GeoRacer.Races.StagingArea.Supervisor.create_staging_area("#{course.id}:#{code}")

    GeoRacer.Races.StagingArea.put_team(identifier, "My team")

    conn =
      post(conn, "/staging-area", %{
        "staging_area" => %{
          "race_code" => code,
          "course_id" => "#{course.id}",
          "expected_code" => code,
          "team_name" => "My team"
        }
      })

    assert redirected_to(conn) =~ "join-race?"
  end

  test "POST /staging-area with invalid parameters", %{conn: conn} do
    conn = post(conn, "/staging-area", %{})
    assert response(conn, :bad_request)
  end

  test "POST /staging-area when given race code does not match expected", %{conn: conn} do
    conn =
      post(conn, "/staging-area", %{
        "staging_area" => %{
          "race_code" => "1234",
          "expected_code" => "5134",
          "course_id" => "2",
          "team_name" => "My team"
        }
      })

    assert redirected_to(conn) =~ "/join-race"
  end

  test "POST /staging-area when team name is empty", %{conn: conn} do
    conn =
      post(conn, "/staging-area", %{
        "staging_area" => %{
          "team_name" => ""
        }
      })

    assert redirected_to(conn) =~ "/join-race"
  end
end
