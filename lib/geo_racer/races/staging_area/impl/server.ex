defmodule GeoRacer.Races.StagingArea.Server do
  @moduledoc """
  GenServer callback module for `StagingArea` processes.
  """
  alias GeoRacer.Races.StagingArea.Impl, as: StagingArea
  use GenServer

  # One day in milliseconds
  @one_day 86_400_000
  def init(identifier) do
    Process.send_after(self(), :close, @one_day)
    {:ok, StagingArea.from_identifier(identifier)}
  end

  def handle_cast({:put_team, team_name}, state) do
    new_state = StagingArea.put_team(state, team_name)
    GeoRacerWeb.Endpoint.broadcast!("staging_area:#{state.identifier}", "update", new_state)
    {:noreply, new_state}
  end

  def handle_cast({:drop_team, team_name}, %StagingArea{teams: teams} = state) do
    case team_name in teams do
      true ->
        new_state = StagingArea.drop_team(state, team_name)
        GeoRacerWeb.Endpoint.broadcast!("staging_area:#{state.identifier}", "update", new_state)
        {:noreply, new_state}

      _ ->
        {:noreply, state}
    end
  end

  def handle_call({:team_name_taken?, team_name}, _from, %StagingArea{teams: teams} = state) do
    {:reply, team_name in teams, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:close, state) do
    {:stop, :normal, state}
  end
end
