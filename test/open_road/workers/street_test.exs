defmodule OpenRoad.Workers.StreetTest do
  use ExUnit.Case

  test "start_link/2 starts the agent" do
    assert {:ok, _} = OpenRoad.Workers.Street.start_link("bob", :menaul_wyoming)
  end

  test "get_intersection/1 returns the intersection this street belongs to" do
    {:ok, _} = OpenRoad.Workers.Street.start_link("bob", :menaul_wyoming)

    assert "bob" = OpenRoad.Workers.Street.get_intersection(:menaul_wyoming)
  end

  test "get_traffic/1 resets the traffic seen by the road" do
    OpenRoad.Workers.Street.start_link("bob", :menaul_wyoming)
    OpenRoad.Workers.Street.add_traffic(:menaul_wyoming, 1, 1)

    OpenRoad.Workers.Street.get_traffic(:menaul_wyoming)

    assert [] = OpenRoad.Workers.Street.get_traffic(:menaul_wyoming)
  end

  test "add_traffic/3 adds one car to the specified depth" do
    OpenRoad.Workers.Street.start_link("bob", :menaul_wyoming)

    OpenRoad.Workers.Street.add_traffic(:menaul_wyoming, 3, 1)

    assert [{3, _}] = OpenRoad.Workers.Street.get_traffic(:menaul_wyoming)
  end

  test "add_traffic/3 adds more than one car to the specified depth" do
    OpenRoad.Workers.Street.start_link("bob", :menaul_wyoming)

    OpenRoad.Workers.Street.add_traffic(:menaul_wyoming, 3, 3)

    [{3, cars}] = OpenRoad.Workers.Street.get_traffic(:menaul_wyoming)

    assert 3 = cars |> Enum.count
  end
end
