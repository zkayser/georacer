defmodule GeoRacer.Courses.Course.Queries do
  @moduledoc """
  Provides Ecto queries for querying
  Courses.
  """
  alias GeoRacer.Courses.Course
  import Ecto.Query

  @doc """
  Creates an Ecto Query for public courses
  """
  @spec public :: Ecto.Query.t()
  def public do
    from c in Course, where: c.is_public == true
  end

  @doc """
  Creates a query for Courses created by `user`
  """
  @spec by_user(String.t()) :: Ecto.Query.t()
  def by_user(user) do
    from c in Course, where: c.user_uuid == ^user
  end
end
