class Node implements Comparable<Node> {
  int gridX;
  int gridY;
  int centerX;
  int centerY; // center coordinates
  boolean isHomeBase;
  volatile boolean isWalkable;
  volatile boolean isExplored;

  float gCost = Float.MAX_VALUE;
  float hCost;
  Node parent;

  Node(int gridX, int gridY) {
    this.gridX = gridX;
    this.gridY = gridY;
    isWalkable = true;
  }

  void setCenter(int x, int y) {
    centerX = x;
    centerY = y;
  }

  float fCost() {
    return gCost + hCost;
  }

  @Override
  public int compareTo(Node other) {
    int compare = Float.compare(this.fCost(), other.fCost());
        // if f costs are tied, prioritize the node closer to the target (lower h cost)
        if (compare == 0) {
            compare = Float.compare(this.hCost, other.hCost);
        }
        return compare;
  }
}
