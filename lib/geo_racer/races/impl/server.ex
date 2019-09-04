defmodule GeoRacer.Races.Race.Server do
  @moduledoc """
  GenServer callback module for `Race` processes.
  """
  use GenServer
  require Logger
  alias GeoRacer.Races.Race.Time

  def init(identifier) do
    send(self(), :begin_clock)
    {:ok, %{time: 0, identifier: identifier}}
  end

  def handle_info(:begin_clock, state) do
    :timer.send_interval(1000, :tick)
    {:noreply, state}
  end

  def handle_info(:tick, %{time: seconds} = state) do
    new_time =
      seconds
      |> Time.update(state[:identifier])

    {:noreply, %{state | time: new_time}}
  end
end
