defmodule GeoRacer.Races.Race.Server do
  @moduledoc """
  GenServer callback module for `Race` processes.
  """
  use GenServer
  require Logger
  alias GeoRacer.Hazards
  alias GeoRacer.Races.Race.{Time, Impl}

  def init(%Impl{} = race) do
    send(self(), :begin_clock)
    {:ok, race}
  end

  def handle_info(:begin_clock, %Impl{} = race) do
    :timer.send_interval(1000, :tick)
    {:noreply, %Impl{race | becomes_idle_at: race.time + Time.one_day()}}
  end

  def handle_info(:tick, %{time: seconds} = state) do
    new_time =
      seconds
      |> Time.update(state.id)

    if new_time > state.becomes_idle_at do
      send(self(), :close)
    end

    {:noreply, %Impl{state | time: new_time}}
  end

  def handle_info(:close, state) do
    {:stop, :normal, state}
  end

  def handle_info({:record_finished, team}, state) do
    case Impl.record_finished(state, team) do
      {:ok, updated} ->
        GeoRacer.Races.Race.broadcast_update(%{"update" => updated})
        {:noreply, updated}

      _ ->
        {:noreply, state}
    end
  end

  def handle_info({:check_for_race_completed, race}, state) do
    case Impl.is_race_completed?(race) do
      true -> {:stop, :normal, state}
      false -> {:noreply, state}
    end
  end

  def handle_call({:next_waypoint, team_name}, _from, state) do
    {:reply, Impl.next_waypoint(state, team_name), state}
  end

  def handle_call({:hot_cold_meter, team_name}, _from, state) do
    {:reply, Impl.hot_cold_meter(state, team_name), state}
  end

  def handle_cast({:drop_waypoint, team_name}, state) do
    {:ok, race} = Impl.drop_waypoint(state, team_name)
    send(self(), {:check_for_race_completed, race})
    {:noreply, %Impl{race | becomes_idle_at: race.time + Time.one_day()}}
  end

  def handle_cast({:put_hazard, attrs}, state) do
    {:ok, hazard} =
      attrs
      |> Map.merge(%{expiration: Hazards.calculate_expiration([for: attrs.name], state.time)})
      |> Hazards.create_hazard()

    new_state = GeoRacer.Races.get_race!(state.id)
    new_state = %Impl{new_state | time: state.time, becomes_idle_at: state.time + Time.one_day()}

    GeoRacer.Races.Race.broadcast_update(%{
      "update" => new_state,
      "hazard_deployed" => %{
        "name" => hazard.name,
        "on" => hazard.affected_team,
        "by" => hazard.attacking_team
      }
    })

    save_time(new_state)
    {:noreply, new_state}
  end

  def terminate(_reason, %Impl{} = race) do
    save_time(race)
    :ok
  end

  defp save_time(%Impl{} = race) do
    Task.start(fn ->
      GeoRacer.Races.update_race(GeoRacer.Races.get_race!(race.id), %{time: race.time})
    end)
  end
end
