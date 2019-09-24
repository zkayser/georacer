defmodule GeoRacer.Repo.Migrations.AddTimeToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :time, :integer, default: 0
    end
  end
end
