defmodule GeoRacerWeb.HazardView do
  use GeoRacerWeb, :view

  def is_selected?(team, selected) do
    case team == selected do
      true -> "--selected"
      false -> ""
    end
  end
end
