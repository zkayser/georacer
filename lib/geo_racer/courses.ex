defmodule GeoRacer.Courses do
  @moduledoc """
  The Courses context.
  """

  import Ecto.Query, warn: false
  alias GeoRacer.Repo

  alias GeoRacer.Courses.Course
  alias GeoRacer.Courses.Course.Queries

  @doc """
  Returns the list of public courses.

  ## Examples

      iex> list_courses()
      [%Race{}, ...]

  """
  def list_public_courses do
    Queries.public()
    |> Repo.all()
    |> Repo.preload([:waypoints])
  end

  @doc """
  Returns a list of courses owned by `user`.
  """
  @spec list_courses(String.t()) :: list(Course.t())
  def list_courses(user) do
    user
    |> Queries.by_user()
    |> Repo.all()
    |> Repo.preload([:waypoints])
  end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the Course does not exist.

  ## Examples

      iex> get_course!(123)
      %Race{}

      iex> get_course!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course!(id) do
    Course
    |> Repo.get!(id)
    |> Repo.preload([:waypoints])
  end

  @doc """
  Creates a course.

  ## Examples

      iex> create_course(%{field: value})
      {:ok, %Course{}}

      iex> create_course(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course(attrs \\ %{}) do
    %Course{}
    |> Repo.preload([:waypoints])
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course.

  ## Examples

      iex> update_course(course, %{field: new_value})
      {:ok, %Course{}}

      iex> update_course(course, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course(%Course{} = course, attrs) do
    course
    |> Repo.preload([:waypoints])
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Course.

  ## Examples

      iex> delete_course(course)
      {:ok, %Course{}}

      iex> delete_course(course)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course(%Course{} = course) do
    Repo.delete(course)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.

  ## Examples

      iex> change_course(course)
      %Ecto.Changeset{source: %Course{}}

  """
  def change_course(%Course{} = course) do
    Course.changeset(course, %{})
  end
end
