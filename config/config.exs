# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :geo_racer,
  ecto_repos: [GeoRacer.Repo]

# Configures the endpoint
config :geo_racer, GeoRacerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: GeoRacerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GeoRacer.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "another_dummy_val_for_dev_env"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Config Postgis
config :geo_postgis,
  json_library: Jason

config :geo_racer, GeoRacer.Repo,
  types: GeoRacer.PostgresTypes,
  extensions: [{Geo.PostGIS.Extension, library: Geo}]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
