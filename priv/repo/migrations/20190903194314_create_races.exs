defmodule GeoRacer.Repo.Migrations.CreateRaces do
  use Ecto.Migration

  def change do
    create table(:races) do
      add :code, :string, null: false
      add :status, :string, default: "not_started"
      add :team_tracker, :map, default: %{}
      add :course_id, references(:courses)

      timestamps()
    end

    unique_index(:races, [:course_id, :code], name: :identifier_index)
  end
end
