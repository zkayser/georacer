defmodule GeoRacerWeb.JoinRaceView do
  use GeoRacerWeb, :view

  def share_link(course_id, race_code) do
    GeoRacerWeb.Endpoint
    |> Routes.join_race_url(:show, %{course_id: course_id, race_code: race_code})
    |> maybe_replace_port()
  end

  defp maybe_replace_port(string) do
    if String.contains?(string, "localhost") do
      string
    else
      String.replace(string, ":4000", "")
    end
  end
end
