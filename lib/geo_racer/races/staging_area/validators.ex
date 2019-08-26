defmodule GeoRacer.Races.StagingArea.Validators do
  @moduledoc """
  Provides utilities for validating data that is
  used for creating `StagingArea`s.
  """
  alias GeoRacer.Races.StagingArea

  @type data :: %{
          course_id: String.t() | pos_integer,
          race_code: String.t(),
          expected_code: String.t(),
          team_name: String.t()
        }

  @doc """
  Returns true if there is a `Course` associated
  with the given `id` AND the code is non-nil
  """
  @spec is_valid_identifier?(String.t(), String.t()) :: boolean()
  def is_valid_identifier?(nil, _code), do: false
  def is_valid_identifier?(_course_id, nil), do: false

  def is_valid_identifier?(course_id, _code) do
    case GeoRacer.Repo.get(GeoRacer.Courses.Course, course_id) do
      %GeoRacer.Courses.Course{} -> true
      _ -> false
    end
  end

  @doc """
  Runs validations on the passed in data and returns
  an error tuple with a Keyword list of error messages
  if any of the validations fails. Returns :ok otherwise.
  """
  @spec run_validations(data()) :: :ok | {:error, Keyword.t(String.t())}
  def run_validations(data) do
    [:validate_identifier, :validate_unique_team_name, :validate_code_matches]
    |> Enum.reduce(:ok, fn validation, acc ->
      run(validation, data, acc)
    end)
  end

  defp run(:validate_identifier, data, acc) do
    case is_valid_identifier?(data.course_id, data.race_code) do
      true -> update_acc(acc, :ok)
      false -> update_acc(acc, {:course_id, "The race you are trying to join does not exist."})
    end
  end

  defp run(:validate_unique_team_name, data, acc) do
    case StagingArea.team_name_taken?("#{data.course_id}:#{data.expected_code}", data.team_name) do
      false -> update_acc(acc, :ok)
      true -> update_acc(acc, {:team_name, "Team name #{data.team_name} has already been taken."})
    end
  end

  defp run(:validate_code_matches, data, acc) do
    case String.downcase(data.race_code) == String.downcase(data.expected_code) do
      true ->
        update_acc(acc, :ok)

      false ->
        update_acc(acc, {:race_code, "The code you entered did not match the expected code."})
    end
  end

  defp update_acc(:ok, :ok), do: :ok

  defp update_acc(:ok, {key, val}) do
    {:error, Keyword.put([], key, val)}
  end

  defp update_acc({:error, errors}, :ok), do: {:error, errors}

  defp update_acc({:error, errors}, {key, val}) do
    {:error, Keyword.put(errors, key, val)}
  end
end
