defmodule GeoRacer.StringGenerator do
  @moduledoc """
  Utilities for generating random strings for test values.
  """

  def random_string(base_string \\ "") do
    base_string <> Base.encode16(:crypto.strong_rand_bytes(8))
  end
end
