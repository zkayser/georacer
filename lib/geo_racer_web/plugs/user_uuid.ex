defmodule GeoRacerWeb.Plugs.UserUUID do
  @moduledoc """
  Assigns a unique user_uuid to requests, placing the
  uuid value in a response cookie and assigning the
  value to the `Plug.Conn :assigns`.
  """
  import Plug.Conn

  # 5 years
  @max_age 60 * 60 * 24 * 365 * 5

  def init(options), do: options

  def call(%{req_cookies: %{"gr_user_uuid" => uuid}} = conn, _opts) do
    {:ok, decoded_uuid} = Base.decode64(uuid, padding: false)

    conn
    |> assign(:user_uuid, decoded_uuid)
  end

  def call(conn, _opts) do
    user_uuid = UUID.uuid4()

    conn
    |> put_resp_cookie("gr_user_uuid", Base.encode64(user_uuid, padding: false), max_age: @max_age)
    |> assign(:user_uuid, user_uuid)
  end
end
