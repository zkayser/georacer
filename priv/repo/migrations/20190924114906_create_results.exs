defmodule GeoRacer.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :team, :string, null: false
      add :time, :integer, null: false
      add :race_id, references(:races)
    end
  end
end
