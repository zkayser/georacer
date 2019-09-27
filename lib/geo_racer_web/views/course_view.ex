defmodule GeoRacerWeb.CourseView do
  use GeoRacerWeb, :view
  alias GeoRacer.Courses.Course

  @km 1000
  @kilometers "km"
  @meters "m"

  def boundary(%Course{} = course) do
    case Course.boundary_for(course) do
      distance when distance > 1000 ->
        %{distance: Float.round(distance / @km, 2), units: @kilometers}

      distance ->
        %{distance: Float.round(distance, 2), units: @meters}
    end
  end

  def tab_classes(selected_tab, tab) do
    case selected_tab == tab do
      true -> %{container_class: "section--color-3", text_class: "color--1"}
      false -> %{container_class: "", text_class: ""}
    end
  end
end
