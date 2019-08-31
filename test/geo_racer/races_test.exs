defmodule GeoRacer.RacesTest do
  use GeoRacer.DataCase
  alias GeoRacer.Races

  setup do
    {:ok, course} = GeoRacer.Factories.CourseFactory.insert()

    {:ok, course: course}
  end

  describe "generate_code/0" do
    test "generates an 8-character code" do
      assert Races.generate_code() =~ ~r([\d\w]{8})
    end
  end

  describe "races" do
    alias GeoRacer.Races.Race.Impl, as: Race
    @team_name GeoRacer.StringGenerator.random_string()
    @remaining Enum.shuffle(1..5)
    @valid_attrs %{
      code: Races.generate_code(),
      team_tracker: %{@team_name => @remaining},
      status: "started"
    }
    @update_attrs %{
      team_tracker: %{@team_name => []}
    }
    @invalid_attrs %{code: ""}

    def race_fixture(attrs \\ %{}) do
      {:ok, race} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Races.create_race()

      race
    end

    test "get_race!/1 returns the race with given id", %{course: course} do
      race = race_fixture(%{course_id: course.id})
      assert Races.get_race!(race.id) == GeoRacer.Repo.preload(race, [:course])
    end

    test "create_race/1 with valid data creates a race", %{course: course} do
      assert {:ok, %Race{} = race} =
               Races.create_race(Map.put(@valid_attrs, :course_id, course.id))
    end

    test "create_race/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Races.create_race(@invalid_attrs)
    end

    test "create_race/1 returns error changeset if code is invalid", %{course: course} do
      attrs =
        @valid_attrs
        |> Map.put(:course_id, course.id)
        |> Map.put(:code, "Not Exactly 8 Characters Long")

      assert {:error, %Ecto.Changeset{}} = Races.create_race(attrs)
    end

    test "create_race/1 keeps a unique constraint on course_id + code", %{course: course} do
      attrs = Map.put(@valid_attrs, :course_id, course.id)
      assert {:ok, %Race{} = race} = Races.create_race(attrs)
      assert {:error, %Ecto.Changeset{} = changeset} = Races.create_race(attrs)
    end

    test "update_race/2 with valid data updates the race", %{course: course} do
      race = race_fixture(%{course_id: course.id})
      assert {:ok, %Race{} = race} = Races.update_race(race, @update_attrs)
      assert race.team_tracker[@team_name] == []
    end

    test "update_race/2 with invalid data returns error changeset", %{course: course} do
      race = race_fixture(%{course_id: course.id})
      assert {:error, %Ecto.Changeset{}} = Races.update_race(race, @invalid_attrs)
      assert GeoRacer.Repo.preload(race, [:course]) == Races.get_race!(race.id)
    end

    test "delete_race/1 deletes the race", %{course: course} do
      race = race_fixture(%{course_id: course.id})
      assert {:ok, %Race{}} = Races.delete_race(race)
      assert_raise Ecto.NoResultsError, fn -> Races.get_race!(race.id) end
    end

    test "change_race/1 returns a race changeset", %{course: course} do
      race = race_fixture(%{course_id: course.id})
      assert %Ecto.Changeset{} = Races.change_race(race)
    end

    test "by_course_and_race_code/2 returns a race based off course_id and race_code", %{
      course: course
    } do
      race =
        %{course_id: course.id} |> race_fixture() |> GeoRacer.Repo.preload(course: [:waypoints])

      assert %Race{} = actual = Races.by_course_id_and_code(course.id, race.code)
      assert race == actual
    end
  end
end
