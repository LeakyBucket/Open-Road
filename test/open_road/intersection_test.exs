defmodule OpenRoad.IntersectionTest do
  use ExUnit.Case

  test "add_road/3 adds a road to the intersection" do
    OpenRoad.Intersection.start_link(:menaul_wyoming, [["menaul_southbound"]])

    assert [["menaul_southbound", "menaul_northbound"]] = OpenRoad.Intersection.add_road(:menaul_wyoming, "menaul_northbound", ["menaul_southbound"])
  end

  test "add_road/3 returns an error if intersection specification is ambiguous" do
    OpenRoad.Intersection.start_link(:menaul_wyoming, [["menaul_southbound", "spain"], ["menaul_southbound", "wyoming"]])

    assert [:error, :ambiguous_node, [["menaul_southbound", "spain"], ["menaul_southbound", "wyoming"]]] = OpenRoad.Intersection.add_road(:menaul_wyoming, "menaul_northbound", ["menaul_southbound"])
  end

  test "add_road/2 adds the road and builds an intersection entry" do
    OpenRoad.Intersection.start_link(:menaul_wyoming, [])

    assert ["menaul_southbound"] = OpenRoad.Intersection.add_road(:menaul_wyoming, "menaul_southbound")
  end

  test "add_road/3 doesn't change nodes that don't match target" do
    OpenRoad.Intersection.start_link(:menaul_wyoming, [["menaul_southbound"], ["wyoming_northbound", "wyoming_southbound"]])

    assert [["menaul_southbound", "menaul_northbound"], ["wyoming_northbound", "wyoming_southbound"]] = OpenRoad.Intersection.add_road(:menaul_wyoming, "menaul_northbound", ["menaul_southbound"])
  end
end
