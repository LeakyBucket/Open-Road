# OpenRoad

## Supervisor Structure

* grid
  * intersection
    * roads

The main/top level process supervises all of the intersections in the network.  It provides mechanisms for adding new intersections as well as a way to load a configuration and recover the network state in the case of grid failure.

The intersection level process supervises it's member road processes.  It also manages the addition of roads to an intersection.

The road level process is the bottom level process.  It currently has no supervisory level responsibilities.
