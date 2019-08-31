defmodule GeoRacerWeb.Plugs.FetchTeamName do
  @moduledoc """
  Fetches a user's team name from request cookies
  and stores them in the connection's `assigns`.
  """
  import Plug.Conn

  def init(options), do: options

  def call(%{req_cookies: %{"geo_racer_team_name" => team_name}} = conn, _opts) do
    {:ok, decoded_team_name} = Base.decode64(team_name, padding: false)

    conn
    |> assign(:team_name, decoded_team_name)
  end

  def call(conn, _opts) do
    conn
  end
end
