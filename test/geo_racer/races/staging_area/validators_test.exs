defmodule GeoRacer.Races.StagingArea.ValidatorsTest do
  use ExUnit.Case
  use GeoRacer.DataCase
  alias GeoRacer.Races.StagingArea.Validators

  describe "is_valid_identifier?/2" do
    test "returns true if the course id given exists and race code is non-nil" do
      {:ok, course} = GeoRacer.Factories.CourseFactory.insert()
      code = GeoRacer.Races.generate_code()

      assert Validators.is_valid_identifier?(course.id, code)
    end

    test "returns false if the course id given does not exist" do
      fake_course_id = "#{round(:rand.uniform() * 100_000)}"
      code = GeoRacer.Races.generate_code()

      refute Validators.is_valid_identifier?(fake_course_id, code)
    end

    test "returns false if the given code is nil" do
      {:ok, course} = GeoRacer.Factories.CourseFactory.insert()

      refute Validators.is_valid_identifier?(course.id, nil)
    end
  end

  @team_name "My awesome team"

  describe "run_validations/1" do
    test "returns :ok if all validation checks succeed" do
      {:ok, course} = GeoRacer.Factories.CourseFactory.insert()
      code = GeoRacer.Races.generate_code()

      assert :ok =
               Validators.run_validations(%{
                 course_id: course.id,
                 race_code: code,
                 expected_code: code,
                 team_name: @team_name
               })
    end

    test "returns an error tuple with message if race_code does not match expected_code" do
      {:ok, course} = GeoRacer.Factories.CourseFactory.insert()
      code_1 = GeoRacer.Races.generate_code()
      code_2 = GeoRacer.Races.generate_code()

      assert {:error, errors} =
               Validators.run_validations(%{
                 course_id: course.id,
                 race_code: code_1,
                 expected_code: code_2,
                 team_name: GeoRacer.StringGenerator.random_string()
               })

      assert [race_code: "The code you entered did not match the expected code."] == errors
    end

    test "returns an error tuple with message if team_name has already been taken" do
      {:ok, course} = GeoRacer.Factories.CourseFactory.insert()
      code = GeoRacer.Races.generate_code()

      {:ok, identifier} =
        GeoRacer.Races.StagingArea.Supervisor.create_staging_area("#{course.id}:#{code}")

      GeoRacer.Races.StagingArea.put_team(identifier, @team_name)

      assert {:error, errors} =
               Validators.run_validations(%{
                 course_id: course.id,
                 race_code: code,
                 expected_code: code,
                 team_name: @team_name
               })

      assert [team_name: "Team name #{@team_name} has already been taken."] == errors
    end

    test "returns an error tuple with message if no course exists with the given course_id" do
      course_id = "#{round(:rand.uniform() * 100_000)}"
      code = GeoRacer.Races.generate_code()

      assert {:error, errors} =
               Validators.run_validations(%{
                 course_id: course_id,
                 race_code: code,
                 expected_code: code,
                 team_name: GeoRacer.StringGenerator.random_string()
               })

      assert course_id: "The race you are trying to join does not exist."
    end
  end
end
