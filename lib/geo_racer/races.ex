defmodule GeoRacer.Races do
  @moduledoc """
  Exposes functions for manipulating and working with Races.
  """

  @doc """
  Generates a random 8-character code for joining races
  """
  @spec generate_code() :: String.t()
  def generate_code, do: Base.encode16(:crypto.strong_rand_bytes(4))
end
