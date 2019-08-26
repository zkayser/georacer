defmodule GeoRacer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      GeoRacer.Repo,
      # Start the endpoint when the application starts
      GeoRacerWeb.Endpoint
      # Starts a worker by calling: GeoRacer.Worker.start_link(arg)
      # {GeoRacer.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    :ets.new(:boundary_cache, [:set, :public, :named_table])
    opts = [strategy: :one_for_one, name: GeoRacer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GeoRacerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
