defmodule GeoRacerWeb.RaceView do
  use GeoRacerWeb, :view

  def classes(level) do
    %{
      light_1: "light--1 light--#{light_temp(1, level)}",
      light_2: "light--2 light--#{light_temp(2, level)}",
      light_3: "light--3 light--#{light_temp(3, level)}",
      light_4: "light--4 light--#{light_temp(4, level)}",
      light_5: "light--5 light--#{light_temp(5, level)}",
      light_6: "light--6 light--#{light_temp(6, level)}",
      light_7: "light--7 light--#{light_temp(7, level)}",
      light_8: "light--8 light--#{light_temp(8, level)}"
    }
  end

  def gradient(level) do
    %{id: "grad#{level}", r: radius(level)}
  end

  def text(level) do
    %{
      transform: transform_for(level),
      meter_text: text_for(level)
    }
  end

  defp light_temp(1, level) when level <= 1, do: "cold"
  defp light_temp(1, _), do: "warm"
  defp light_temp(2, level) when level == 1 or level == 2, do: "cold"
  defp light_temp(2, _), do: "warm"
  defp light_temp(3, level) when level <= 3, do: "cold"
  defp light_temp(3, _), do: "warm"
  defp light_temp(4, level) when level <= 4, do: "cold"
  defp light_temp(4, _), do: "warm"
  defp light_temp(5, level) when level <= 5, do: "cold"
  defp light_temp(5, _), do: "warm"
  defp light_temp(6, level) when level <= 6, do: "cold"
  defp light_temp(6, _), do: "warm"
  defp light_temp(7, level) when level <= 7, do: "cold"
  defp light_temp(7, _), do: "warm"
  defp light_temp(8, level) when level <= 8, do: "cold"
  defp light_temp(8, _), do: "warm"

  defp radius(9), do: "1500"
  defp radius(level), do: "#{level + 1}00"

  defp transform_for(level) when level <= 3, do: "translate(190.727 269.551)"
  defp transform_for(level) when level <= 5, do: "translate(135.727 269.551)"
  defp transform_for(level) when level <= 7, do: "translate(188.727 269.551)"
  defp transform_for(8), do: "translate(207.727 269.551)"
  defp transform_for(9), do: "translate(169.727 269.551)"

  defp text_for(level) when level <= 3, do: "COLD"
  defp text_for(level) when level <= 5, do: "WARM_ISH"
  defp text_for(level) when level <= 7, do: "WARM"
  defp text_for(8), do: "HOT"
  defp text_for(9), do: "ON FIRE"
end
