defmodule OpenRoad.Workers.Intersection do
  @moduledoc """
  The Intersection Module is responsible for an actual interscection.  It provides
  behavior for creating an intersection instance, adding roads to an intersection.

  The Intersection Module has two state attributes:

  * `nodes` these are collections of streets which form a logical 'edge' or 'path'
  through an intersection.  The lights for all the streets in a node should be
  green or red at the same time.  Consequently the lights for all other nodes
  should be red.
  * `traffic_engine` the traffic engine attribute stores a copy of the logic
  settings for intersection behavior.

  ## Node

  #### There is one function responsible for adding roads to an intersection.

  __add_road__ is responsible for adding roads to an intersection.

  `add_road/3` -- takes the intersection to be modified, the identifier of the road
  to be added and a full or partial identifier for the node to which the road
  should be added.

  `add_road/2` -- takes the intersection to be modified, and the identifier of the
  road to be added.  The new road will be added as the sole member of a new node.
  """

  def start_link(name, roads, warden) do
    Agent.start_link(__MODULE__, :initialize, [roads, warden], name: name)
  end

  def initialize(roads, warden) do
    [nodes: roads, warden: warden]
  end

  @doc """
  takes an intersection process identifier, a road process identifier, and
  optionally a full or partial node identifier.

  returns the new node map on success or {:error, :ambiguous_node, node_list} if
  the given node identifier is not unique in the existing set of nodes.
  """
  def add_road(intersection, road, node) do
    Agent.get_and_update(intersection, __MODULE__, :new_road, [road, node])
  end
  def add_road(intersection, road) do
    Agent.get_and_update(intersection, __MODULE__, :new_road, [road, []])
  end

  def new_road(current_state, road, []) do
    [nodes: nodes, warden: warden] = current_state

    {nodes ++ [road], [nodes: nodes ++ [road], warden: warden]}
  end
  def new_road(current_state, road, node) do
    [nodes: nodes, warden: warden] = current_state

    # TODO: Refactor this horrible mess.
    updated_nodes = Enum.map nodes, fn current_node ->
      has_given_node = Enum.any? current_node, fn street ->
        node == [street]
      end

      case has_given_node do
        true ->
          current_node ++ [road]
        _ ->
          current_node
      end
    end

    {result, [nodes: processed_nodes]} = insert_road?(nodes, updated_nodes)
    {result, [nodes: processed_nodes, warden: warden]}
  end

  def insert_road?(old, new) do
    updated_nodes = List.foldl old, [], fn(node, acc) ->
      case Enum.any? new, &(&1 == node) do
        false ->
          acc ++ [node]
        _ ->
          acc
      end
    end

    case Enum.count(updated_nodes) <= 1 do
      true ->
        {new, [nodes: updated_nodes]}
      false ->
        {[:error, :ambiguous_node, updated_nodes], [nodes: old]}
    end
  end
end
