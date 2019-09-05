defmodule GeoRacer.Races.Race.Server do
  @moduledoc """
  GenServer callback module for `Race` processes.
  """
  use GenServer
  require Logger
  alias GeoRacer.Races.Race.{Time, Impl}

  def init(%Impl{} = race) do
    send(self(), :begin_clock)
    {:ok, race}
  end

  def handle_info(:begin_clock, state) do
    :timer.send_interval(1000, :tick)
    {:noreply, state}
  end

  def handle_info(:tick, %{time: seconds} = state) do
    new_time =
      seconds
      |> Time.update(state.id)

    {:noreply, %Impl{state | time: new_time}}
  end

  def handle_call({:next_waypoint, team_name}, _from, state) do
    {:reply, Impl.next_waypoint(state, team_name), state}
  end
end
