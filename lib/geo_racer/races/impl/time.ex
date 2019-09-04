defmodule GeoRacer.Races.Race.Time do
  @moduledoc """
  Exposes functions for calculating elapsed time
  during a race and broadcasting time updates to
  subscribers.
  """

  @minute 60
  @hour 60 * 60

  @doc """
  Broadcasts a "tick" event to subscribers on
  the `race_time:identifier` pubsub topic.
  """
  @spec update(non_neg_integer(), String.t()) :: non_neg_integer()
  def update(seconds, identifier) do
    update = seconds + 1

    Task.start(fn ->
      GeoRacerWeb.Endpoint.broadcast(
        "race_time:#{identifier}",
        "tick",
        %{"clock" => "#{render(update)}"}
      )
    end)

    update
  end

  @doc """
  Takes in number of seconds and returns a string
  in the format `HH:MM:SS`.
  """
  @spec render(non_neg_integer()) :: String.t()
  def render(seconds) do
    seconds
    |> convert_to_time()
    |> Enum.reduce(%{}, fn {unit, time}, acc ->
      if time < 10, do: Map.put(acc, unit, "0#{time}"), else: Map.put(acc, unit, "#{time}")
    end)
    |> time_map_to_string()
  end

  defp convert_to_time(seconds) do
    %{
      seconds: rem(seconds, @minute),
      minutes: if(seconds >= @minute, do: rem(div(seconds, @minute), @minute), else: 0),
      hours: if(seconds >= @hour, do: rem(div(seconds, @hour), @hour), else: 0)
    }
  end

  defp time_map_to_string(%{hours: hours} = time) when hours == "00" do
    "#{time[:minutes]}:#{time[:seconds]}"
  end

  defp time_map_to_string(time), do: "#{time[:hours]}:#{time[:minutes]}:#{time[:seconds]}"
end
