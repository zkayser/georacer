defmodule GeoRacer.Hazards.Hazard do
  @moduledoc """
  Ecto Schema and functions for working with
  Hazards.
  """
  alias GeoRacer.Races.Race.Impl, as: Race
  import Ecto.Changeset
  import Ecto.Query
  use Ecto.Schema

  schema "hazards" do
    field :name, :string
    field :affected_team, :string
    field :attacking_team, :string
    field :expiration, :integer
    belongs_to :race, Race, on_replace: :delete
  end

  @type t() :: %{
          name: String.t(),
          affected_team: String.t(),
          attacking_team: String.t(),
          expiration: non_neg_integer(),
          race: Race.t()
        }

  @callback explain() :: String.t()
  @callback description() :: String.t()
  @callback display_name() :: String.t()
  @callback image() :: String.t()

  @doc """
  Creates a changeset for a Hazard.
  """
  @spec changeset(t(), term()) :: Ecto.Changeset.t()
  def changeset(hazard, attrs) do
    hazard
    |> cast(attrs, [:name, :affected_team, :expiration, :attacking_team, :race_id])
    |> validate_required([:name, :affected_team, :attacking_team, :expiration, :race_id])
    |> validate_inclusion(:name, ["MeterBomb", "WaypointBomb", "MapBomb"])
  end

  @doc """
  Creates a query for retrieving hazards in effect for
  the targeted team in `race`
  """
  @spec by_targeted(non_neg_integer, String.t()) :: Ecto.Query.t()
  def by_targeted(race_id, targeted) do
    from h in __MODULE__,
      where: h.race_id == ^race_id and h.affected_team == ^targeted
  end
end
