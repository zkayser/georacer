defmodule GeoRacer.Repo.Migrations.ModifyTimeFromIntegerToStringOnResults do
  use Ecto.Migration

  def change do
    alter table(:results) do
      modify :time, :string, default: "00:00"
    end
  end
end
