defmodule OpenRoad.Workers.Street do
  @moduledoc """
  The Street Module maintains the current state for a road leading into an intersection.
  It has a bit of a hybrid API, there are functions intended for the Intersection to which
  the street belongs, there are functions intended for reporting the distance of traffic
  and there are functions intended for metrics and monitoring.

  The Street Module has a fairly simple state:

  * `feeders` these are intersections that feed directly into this road (without any
  interviening intersections).
  * `intersection` this is the intersection that the street feeds into.
  * `traffic` this is a list representing the known traffic state on the road.
  Datapoints in this list are stored as a {depth, timestamp} tuple.

  ### Intersection

  There is currently one main function intended for intersection use.

  `get_traffic/1` -- This function returns the accumulated traffic information since the
  last time it was called.  Every cal to `get_traffic/1` resets the traffic data for that
  specific road.

  ### Traffic Sensors

  There is currently one main function for use by traffic sensors.

  `add_traffic/3` -- This function adds the specified number of vehicles to the road state
  at the specified depth.  The depth is used by the Intersection to approximate the priority
  for the road.  It is possible to indicate multiple vehicles in a single call, each will
  get a slightly different timestamp.

  ### Monitoring

  There is currently one function for use by the monitoring system.

  `intersection/1` -- This function returns the intersection that the road feeds into.
  This can be used to maintain a real time inventory of overall intersection health.
  """

  def start_link(intersection, road) do
    Agent.start_link(__MODULE__, :initialize, [intersection], name: road)
  end

  def initialize(intersection) do
    [feeders: HashSet.new, intersection: intersection, traffic: []]
  end

  @doc """
  takes a road process identifier and returns the name of the intersection that road
  belongs to.
  """
  def get_intersection(road) do
    Agent.get(road, __MODULE__, :intersection, [])
  end

  @doc """
  takes a road process identifier, a depth and a count.  adds `count` number of
  vehicles at `depth`.
  """
  def add_traffic(road, depth, 1) do
    Agent.cast(road, __MODULE__, :add_car, [depth])
  end
  def add_traffic(road, depth, count) do
    Agent.cast(road, __MODULE__, :add_car, [depth])

    add_traffic(road, depth, count - 1)
  end

  @doc """
  takes a road process identifier and returns all the current traffic data, this
  also resets the traffic data.
  """
  def get_traffic(road) do
    Agent.get_and_update(road, __MODULE__, :empty_seen, [])
  end

  def empty_seen(seen) do
    [feeders: feeders, intersection: intersection, traffic: traffic] = seen

    {traffic, [feeders: feeders, intersection: intersection, traffic: []]}
  end

  def intersection(state) do
    [feeders: _, intersection: parent, traffic: _] = state

    parent
  end

  def add_car(state, depth) do
    [feeders: feeders, intersection: intersection, traffic: traffic] = state

    traffic = case traffic |> seen_at_depth? depth do
      true ->
        traffic |> Enum.map fn level ->
                              case level do
                                {^depth, seen} ->
                                 {depth, seen ++ [:erlang.unique_integer([:monotonic])]}
                                 _ ->
                                   level
                               end
                             end
      false ->
        traffic ++ [{depth, [:erlang.unique_integer([:monotonic])]}]
    end

    [feeders: feeders, intersection: intersection, traffic: traffic]
  end

  defp seen_at_depth?(traffic, depth) do
    traffic |> Enum.any? fn level ->
                           case level do
                             {^depth, _} ->
                               true
                             _ ->
                               false
                           end
                         end
  end
end
