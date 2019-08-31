defmodule GeoRacer.Races do
  @moduledoc """
  Exposes functions for manipulating and working with Races.
  """
  import Ecto.Query, warn: false
  alias GeoRacer.Repo

  alias GeoRacer.Races.Race.Impl, as: Race
  alias GeoRacer.Races.StagingArea.Impl, as: StagingArea

  @doc """
  Generates a random 8-character code for joining races
  """
  @spec generate_code() :: String.t()
  def generate_code, do: Base.encode16(:crypto.strong_rand_bytes(4))

  @doc """
  Gets a single race.

  Raises `Ecto.NoResultsError` if the Race does not exist.

  ## Examples

      iex> get_race!(123)
      %Race{}

      iex> get_race!(456)
      ** (Ecto.NoResultsError)

  """
  def get_race!(id) do
    Race
    |> Repo.get!(id)
    |> Repo.preload(course: [:waypoints])
  end

  @doc """
  Gets a single Race based off course_id and code.

  ## Examples

      iex> by_course_id_and_code(1, "ABCD1234")
      %Race{}

      iex> by_course_id_and_code(1235153, "ABCDEWEQ")
      nil
  """
  def by_course_id_and_code(course_id, code) do
    course_id
    |> Race.course_and_code_query(code)
    |> Repo.one()
    |> Repo.preload(course: [:waypoints])
  end

  @doc """
  Creates a race.

  ## Examples

      iex> create_race(%{field: value})
      {:ok, %Race{}}

      iex> create_race(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_race(attrs \\ %{}) do
    %Race{}
    |> Race.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, %Race{} = race} -> {:ok, Repo.preload(race, course: [:waypoints])}
      error -> error
    end
  end

  @doc """
  Creates a Race from a StagingArea instance.

  ## Examples

    iex> create_from_staging_area(%StagingArea{field: value})
    {:ok, %Race{}}

    iex> create_from_staging_area(%StagingArea{field: bad_value})
    {:error, %Ecto.Changeset{}}

  """
  def create_from_staging_area(%StagingArea{} = staging_area) do
    staging_area
    |> Race.from_staging_area()
  end

  @doc """
  Updates a race.

  ## Examples

      iex> update_race(race, %{field: new_value})
      {:ok, %Race{}}

      iex> update_race(race, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_race(%Race{} = race, attrs) do
    race
    |> Race.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Race.

  ## Examples

      iex> delete_race(race)
      {:ok, %Race{}}

      iex> delete_race(race)
      {:error, %Ecto.Changeset{}}

  """
  def delete_race(%Race{} = race) do
    Repo.delete(race)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking race changes.

  ## Examples

      iex> change_race(race)
      %Ecto.Changeset{source: %Race{}}

  """
  def change_race(%Race{} = race) do
    Race.changeset(race, %{})
  end
end
