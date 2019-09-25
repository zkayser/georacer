defmodule GeoRacer.Races.Race.Result do
  @moduledoc """
  Ecto Schema module for storing race results.
  """
  alias GeoRacer.Races.Race.Time
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          team: String.t(),
          time: integer(),
          race_id: pos_integer()
        }

  schema "results" do
    field :team, :string
    field :time, :string

    belongs_to :race, GeoRacer.Races.Race.Impl, on_replace: :delete
  end

  @doc """
  Creates a result and associates it with the
  passed in race.
  """
  @spec create(String.t(), GeoRacer.Races.Race.Impl.t()) ::
          {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create(team, race) do
    %__MODULE__{}
    |> cast(%{team: team, time: Time.render(race.time), race_id: race.id}, [
      :team,
      :time,
      :race_id
    ])
    |> validate_required([:team, :time, :race_id])
    |> unique_constraint(:team, name: "results_race_id_team_index")
    |> GeoRacer.Repo.insert()
  end
end
