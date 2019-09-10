defmodule GeoRacer.Factories.HazardFactory do
  @moduledoc """
  Exposes an insert function to create new Races
  for use in testing.
  """

  alias GeoRacer.Hazards

  @hazards ["MeterBomb", "WaypointBomb", "MapBomb"]

  def insert(race, attrs \\ %{}) do
    %{
      name: Enum.random(@hazards),
      affected_team: List.first(Map.keys(race.team_tracker)),
      attacking_team: Enum.at(Map.keys(race.team_tracker), 1),
      expiration: 60,
      race_id: race.id
    }
    |> Map.merge(attrs)
    |> Hazards.create_hazard()
  end
end
