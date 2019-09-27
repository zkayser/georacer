defmodule GeoRacerWeb.Plugs.UserUUIDTest do
  use GeoRacerWeb.ConnCase
  alias GeoRacerWeb.Plugs.UserUUID

  @user_uuid UUID.uuid4()

  describe "UserUUID" do
    test "generates a user_uuid if not present and places it in assigns", %{conn: conn} do
      conn = UserUUID.call(conn, %{})

      uuid = conn.assigns[:user_uuid]
      assert not is_nil(uuid) and is_binary(uuid)
    end

    test "retrieves user_uuid from req_cookies if present and places it in assigns", %{conn: conn} do
      conn = %{conn | req_cookies: %{"gr_user_uuid" => Base.encode64(@user_uuid, padding: false)}}

      assert UserUUID.call(conn, %{}).assigns[:user_uuid] == @user_uuid
    end
  end
end
