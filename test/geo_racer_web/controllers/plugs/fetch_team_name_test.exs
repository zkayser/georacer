defmodule GeoRacerWeb.Plugs.FetchTeamPlugTest do
  use GeoRacerWeb.ConnCase
  alias GeoRacerWeb.Plugs.FetchTeamName

  @team_name "My team"

  describe "TeamNamePlug" do
    test "assigns the team name from user session data", %{conn: conn} do
      conn = %{
        conn
        | req_cookies: %{"geo_racer_team_name" => Base.encode64(@team_name, padding: false)}
      }

      conn = FetchTeamName.call(conn, %{})

      assert conn.assigns[:team_name] == @team_name
    end

    test "assigns nothing if team name does not exist", %{conn: conn} do
      refute FetchTeamName.call(conn, %{}).assigns[:team_name]
    end
  end
end
