defmodule GeoRacer.Hazards do
  @moduledoc """
  Exposes functions for manipulating and working with Hazards.
  """
  import Ecto.Query, warn: false
  alias GeoRacer.Repo
  alias GeoRacer.Hazards.{Hazard, MeterBomb}

  @typedoc """
  Any of the available Hazards in the game.
  """
  @type hazard :: MeterBomb

  @doc """
  Returns a list of the available hazards in the game.
  """
  @spec all() :: list(hazard)
  def all, do: [MeterBomb]

  @doc """
  Creates a Hazard.

  ## Examples

      iex> create_hazard(%{field: value})
      {:ok, %Hazard{}}

      iex> create_hazard(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hazard(attrs \\ %{}) do
    %Hazard{}
    |> Hazard.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a Hazard.

  ## Examples

      iex> delete_hazard(hazard)
      {:ok, %Hazard{}}

      iex> delete_hazard(hazard)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hazard(%Hazard{} = hazard) do
    Repo.delete(hazard)
  end

  @doc """
  Returns a list of Hazards in effect for
  `targeted` team in the Race represented by
  `race_id`.

  ## Examples

      iex> by_targeted(race_id, targeted)
      [%Hazard{}]

      iex> by_targeted(race_id, targeted)
      []
  """
  @spec by_targeted(non_neg_integer, String.t()) :: list(Hazard.t())
  def by_targeted(race_id, targeted) do
    race_id
    |> Hazard.by_targeted(targeted)
    |> Repo.all()
  end

  @doc """
  Returns a string representing `hazard`.
  """
  @spec name_for(hazard) :: String.t()
  def name_for(MeterBomb), do: "MeterBomb"

  @doc """
  Returns the hazard matching `string`.
  If the `string` passed in does not match
  an available hazard, returns `{:error, :invalid_hazard}`
  """
  @spec from_string(String.t()) :: {:ok, hazard} | {:error, :invalid_hazard}
  def from_string("MeterBomb"), do: {:ok, MeterBomb}
  def from_string("Meter Bomb"), do: {:ok, MeterBomb}
  def from_string(_), do: {:error, :invalid_hazard}

  @doc """
  Calculates the expiration value by adding `seconds`
  number of seconds to the `time` value passed in.
  """
  @spec calculate_expiration(Keyword.t(), non_neg_integer) :: non_neg_integer
  def calculate_expiration([for: "MeterBomb"], time), do: time + 60
  def calculate_expiration(_, _), do: 0

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hazard changes.

  ## Examples

      iex> change_hazard(hazard)
      %Ecto.Changeset{source: %Hazard{}}

  """
  def change_hazard(%Hazard{} = hazard) do
    Hazard.changeset(hazard, %{})
  end
end
