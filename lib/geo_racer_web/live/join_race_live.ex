defmodule GeoRacerWeb.JoinRaceLive do
  @moduledoc false
  use Phoenix.LiveView

  def mount(%{course_id: course_id, race_code: race_code, csrf_token: csrf_token}, socket) do
    socket =
      socket
      |> assign(:course_id, course_id)
      |> assign(:race_code, race_code)
      |> assign(:csrf_token, csrf_token)

    {:ok, socket}
  end

  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.JoinRaceView, "_form.html", assigns)
  end
end
