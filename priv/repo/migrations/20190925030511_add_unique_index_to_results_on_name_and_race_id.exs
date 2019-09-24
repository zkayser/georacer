defmodule GeoRacer.Repo.Migrations.AddUniqueIndexToResultsOnNameAndRaceId do
  use Ecto.Migration

  def change do
    create index(:results, [:race_id, :team], name: "results_race_id_team_index", unique: true)
  end
end
