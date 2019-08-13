defmodule GeoRacer.Repo do
  use Ecto.Repo,
    otp_app: :geo_racer,
    adapter: Ecto.Adapters.Postgres
end
