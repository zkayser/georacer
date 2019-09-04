defmodule GeoRacerWeb.Live.Courses.ShowTest do
  use GeoRacerWeb.ConnCase
  alias GeoRacer.Races.StagingArea
  import Phoenix.LiveViewTest

  setup context do
    {:ok, course} = GeoRacer.Factories.CourseFactory.insert()
    code = GeoRacer.Races.generate_code()
    team_name = GeoRacer.StringGenerator.random_string()

    conn =
      context.conn
      |> put_req_cookie("geo_racer_team_name", Base.encode64("#{team_name}", padding: false))

    {:ok, _identifier} = StagingArea.Supervisor.create_staging_area("#{course.id}:#{code}")

    {:ok, course: course, code: code, team_name: team_name, conn: conn}
  end

  describe "Show" do
    test "mounts on /courses/:id with race_code query param", context do
      {:ok, view, _html} =
        live(context.conn, "/courses/#{context.course.id}?race_code=#{context.code}")

      assert view.module == GeoRacerWeb.Live.Courses.Show
    end

    test "renders team name in the list of teams", context do
      {:ok, view, _html} =
        live(context.conn, "/courses/#{context.course.id}?race_code=#{context.code}")

      assert render(view) =~ context.team_name
    end

    test "listens to updates when teams are added to the staging area", context do
      {:ok, view, _html} =
        live(context.conn, "/courses/#{context.course.id}?race_code=#{context.code}")

      new_team = GeoRacer.StringGenerator.random_string()

      refute render(view) =~ new_team

      StagingArea.put_team("#{context.course.id}:#{context.code}", new_team)

      Process.sleep(50)
      assert render(view) =~ new_team
    end

    test "listens to updates when team are removed from the staging area", context do
      {:ok, view, _html} =
        live(context.conn, "/courses/#{context.course.id}?race_code=#{context.code}")

      new_team = GeoRacer.StringGenerator.random_string()
      StagingArea.put_team("#{context.course.id}:#{context.code}", new_team)
      Process.sleep(50)
      assert render(view) =~ new_team
      StagingArea.drop_team("#{context.course.id}:#{context.code}", new_team)
      Process.sleep(50)
      refute render(view) =~ new_team
    end

    test "start_race click events redirects to race page", context do
      {:ok, view, _html} =
        live(context.conn, "/courses/#{context.course.id}?race_code=#{context.code}")

      assert_redirect(
        view,
        "/races/" <> id,
        fn ->
          render_click(view, "start_race")
        end
      )
    end

    test "force redirects other views to race page when one client starts a race", context do
      {:ok, view, _html} =
        live(context.conn, "/courses/#{context.course.id}?race_code=#{context.code}")

      new_team = GeoRacer.StringGenerator.random_string()
      StagingArea.put_team("#{context.course.id}:#{context.code}", new_team)
      Process.sleep(50)

      new_conn =
        context.conn
        |> put_req_cookie("geo_racer_web_team", Base.encode64(new_team, padding: false))

      {:ok, view_2, _html} =
        live(new_conn, "/courses/#{context.course.id}?race_code=#{context.code}")

      render_click(view, "start_race")
      assert_remove(view_2, _)
    end

    test "redirects to the race view for created races if current team is a participant",
         context do
      {:ok, race} = GeoRacer.Factories.RaceFactory.insert()
      team_name = race.team_tracker |> Map.keys() |> List.first()

      conn =
        context.conn
        |> put_req_cookie("geo_racer_team_name", Base.encode64(team_name, padding: false))

      conn = get(conn, "/courses/#{race.course.id}?race_code=#{race.code}")
      assert redirected_to(conn) =~ "/races/#{race.id}"
    end
  end
end
