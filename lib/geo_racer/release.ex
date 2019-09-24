defmodule GeoRacer.Release do
  @moduledoc """
  Exposes functions for migrating and rolling back
  the database. The migrate/0 function gets called on
  application startup to ensure that all migrations have
  been run. The rollback function can be used from a
  shell session to rollback the database if necessary.
  """
  @app :geo_racer
  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo \\ PokerEx.Repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
