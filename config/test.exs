use Mix.Config

# Configure your database
config :geo_racer, GeoRacer.Repo,
  username: "postgres",
  password: "postgres",
  database: "geo_racer_test",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :geo_racer, GeoRacerWeb.Endpoint,
  http: [port: 4002],
  server: false

config :geo_racer, id_generator: &GeoRacer.FakeIdGenerator.id/0
config :geo_racer, geo_calc_module: GeoRacer.FakeCalc

# Print only warnings and errors during test
config :logger, level: :warn
