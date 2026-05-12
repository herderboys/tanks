// Namn: Alexander Herder, alhe5785

class NodeGR04 implements Comparable<NodeGR04> {
  int gridX;
  int gridY;
  int centerX;
  int centerY; // center coordinates
  boolean isHomeBase;
  volatile boolean isWalkable;
  volatile boolean isExplored;

  // g(n), the exact cost of the path from starting node to this node
  float gCost = Float.MAX_VALUE;
  
  // f(n), the (heuristic) estimated cost from this node to the target node
  float hCost;
  NodeGR04 parent;

  NodeGR04(int gridX, int gridY) {
    this.gridX = gridX;
    this.gridY = gridY;
    isWalkable = true;
    isHomeBase = false;
  }

  void setCenter(int x, int y) {
    centerX = x;
    centerY = y;
  }

  // g(n) + f(n), the total estimated cost of the path through this node
  float fCost() {
    return gCost + hCost;
  }

  @Override
  public int compareTo(NodeGR04 other) {
    int compare = Float.compare(this.fCost(), other.fCost());
        // if f costs are tied, prioritize the node closer to the target (lower h cost)
        if (compare == 0) {
            compare = Float.compare(this.hCost, other.hCost);
        }
        return compare;
  }
}
