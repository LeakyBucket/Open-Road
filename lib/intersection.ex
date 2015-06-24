defmodule OpenRoad.Intersection do
  def start_link(name, roads) do
    Agent.start_link(__MODULE__, :initialize, [roads], name: name)
  end

  def initialize(roads) do
    [nodes: roads]
  end

  def add_road(intersection, road, node) do
    Agent.get_and_update(intersection, __MODULE__, :new_road, [road, node])
  end
  def add_road(intersection, road) do
    Agent.get_and_update(intersection, __MODULE__, :new_road, [road, []])
  end

  def new_road(current_state, road, []) do
    [nodes: nodes] = current_state

    {nodes ++ [road], [nodes: nodes ++ [road]]}
  end
  def new_road(current_state, road, node) do
    [nodes: nodes] = current_state

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

    insert_road? nodes, updated_nodes
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
