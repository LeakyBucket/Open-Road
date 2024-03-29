defmodule TestWarden do

end

defmodule HappyWarden do

end

defmodule SadWarden do

end

defmodule OpenRoad.Workers.IntersectionTest do
  use ExUnit.Case

  test "add_road/3 adds a road to the intersection" do
    OpenRoad.Workers.Intersection.start_link(:menaul_wyoming, [["menaul_southbound"]], TestWarden)

    assert [["menaul_southbound", "menaul_northbound"]] = OpenRoad.Workers.Intersection.add_road(:menaul_wyoming, "menaul_northbound", ["menaul_southbound"])
  end

  test "add_road/3 returns an error if intersection specification is ambiguous" do
    OpenRoad.Workers.Intersection.start_link(:menaul_wyoming, [["menaul_southbound", "spain"], ["menaul_southbound", "wyoming"]], TestWarden)

    assert [:error, :ambiguous_node, [["menaul_southbound", "spain"], ["menaul_southbound", "wyoming"]]] = OpenRoad.Workers.Intersection.add_road(:menaul_wyoming, "menaul_northbound", ["menaul_southbound"])
  end

  test "add_road/2 adds the road and builds an intersection entry" do
    OpenRoad.Workers.Intersection.start_link(:menaul_wyoming, [], TestWarden)

    assert ["menaul_southbound"] = OpenRoad.Workers.Intersection.add_road(:menaul_wyoming, "menaul_southbound")
  end

  test "add_road/3 doesn't change nodes that don't match target" do
    OpenRoad.Workers.Intersection.start_link(:menaul_wyoming, [["menaul_southbound"], ["wyoming_northbound", "wyoming_southbound"]], TestWarden)

    assert [["menaul_southbound", "menaul_northbound"], ["wyoming_northbound", "wyoming_southbound"]] = OpenRoad.Workers.Intersection.add_road(:menaul_wyoming, "menaul_northbound", ["menaul_southbound"])
  end
end
