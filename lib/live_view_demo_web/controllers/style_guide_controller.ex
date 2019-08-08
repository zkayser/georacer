defmodule LiveViewDemoWeb.StyleGuideController do
  use LiveViewDemoWeb, :controller

  def show(conn, _params) do
    render(conn, "show.html", %{})
  end
end
