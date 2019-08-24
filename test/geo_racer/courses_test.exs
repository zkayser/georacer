defmodule GeoRacer.CoursesTest do
  use GeoRacer.DataCase

  alias GeoRacer.Courses

  describe "courses" do
    alias GeoRacer.Courses.Course

    @valid_attrs %{
      name: "some name",
      waypoints: [
        %{
          latitude: Float.round(39 + :rand.uniform(), 6),
          longitude: Float.round(-84 - :rand.uniform(), 6)
        },
        %{
          latitude: Float.round(39 + :rand.uniform(), 6),
          longitude: Float.round(-84 - :rand.uniform(), 6)
        }
      ],
      center: %Geo.Point{
        coordinates:
          {Float.round(-84 - :rand.uniform(), 6), Float.round(39 + :rand.uniform(), 6)},
        srid: 4326
      }
    }
    @update_attrs %{
      name: "some updated name",
      waypoints: [
        %{
          latitude: Float.round(39 + :rand.uniform(), 6),
          longitude: Float.round(-84 - :rand.uniform(), 6)
        },
        %{
          latitude: Float.round(39 + :rand.uniform(), 6),
          longitude: Float.round(-84 - :rand.uniform(), 6)
        }
      ],
      center: %Geo.Point{
        coordinates:
          {Float.round(-84 - :rand.uniform(), 6), Float.round(39 + :rand.uniform(), 6)},
        srid: 4326
      }
    }
    @invalid_attrs %{name: nil, center: nil}

    def course_fixture(attrs \\ %{}) do
      {:ok, course} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Courses.create_course()

      course
    end

    test "list_courses/0 returns all Courses" do
      course = course_fixture()
      assert Courses.list_courses() == [course]
    end

    test "get_course!/1 returns the course with given id" do
      course = course_fixture()
      assert Courses.get_course!(course.id) == course
    end

    test "create_course/1 with valid data creates a course" do
      assert {:ok, %Course{} = course} = Courses.create_course(@valid_attrs)
      assert course.name == "some name"
    end

    test "create_course/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Courses.create_course(@invalid_attrs)
    end

    test "create_course/1 requires at least one waypoint for the course" do
      attributes = %{@valid_attrs | waypoints: []}
      assert {:error, %Ecto.Changeset{}} = Courses.create_course(attributes)
    end

    test "update_course/2 with valid data updates the course" do
      course = course_fixture()
      assert {:ok, %Course{} = course} = Courses.update_course(course, @update_attrs)
      assert course.name == "some updated name"
    end

    test "update_course/2 with invalid data returns error changeset" do
      course = course_fixture()
      assert {:error, %Ecto.Changeset{}} = Courses.update_course(course, @invalid_attrs)
      assert course == Courses.get_course!(course.id)
    end

    test "delete_course/1 deletes the course" do
      course = course_fixture()
      assert {:ok, %Course{}} = Courses.delete_course(course)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_course!(course.id) end
    end

    test "change_course/1 returns a course changeset" do
      course = course_fixture()
      assert %Ecto.Changeset{} = Courses.change_course(course)
    end
  end
end
