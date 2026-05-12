// Namn: Alexander Herder, alhe5785

class GridGR04 {
  final int GRID_LENGTH = 800;
  final int NODE_SIDE_LENGTH = 50;
  final int ROWS_COLS_AMOUNT = GRID_LENGTH / NODE_SIDE_LENGTH;
  int rows = ROWS_COLS_AMOUNT;
  int cols = ROWS_COLS_AMOUNT;
  NodeGR04[][] nodes = new NodeGR04[cols][rows];

  GridGR04() {
    for (int col = 0; col < nodes.length; col++) {
      for (int row = 0; row < nodes[col].length; row++) {
        NodeGR04 node = new NodeGR04(col, row);
        nodes[col][row] = node;

        int centerX = (NODE_SIDE_LENGTH * col) + (NODE_SIDE_LENGTH / 2);
        int centerY = (NODE_SIDE_LENGTH * row) + (NODE_SIDE_LENGTH / 2);

        node.setCenter(centerX, centerY);
      }
    }
  }

  synchronized NodeGR04 getNodeFromPixels(float physicalX, float physicalY) {
    int nodeCol = (int)physicalX / NODE_SIDE_LENGTH;
    int nodeRow = (int)physicalY / NODE_SIDE_LENGTH;

    if (nodeCol < 0) nodeCol = 0;
    if (nodeCol > cols - 1) nodeCol = cols - 1;
    if (nodeRow < 0) nodeRow = 0;
    if (nodeRow > rows - 1) nodeRow = rows - 1;

    return nodes[nodeCol][nodeRow];
  }

  synchronized ArrayList<NodeGR04> getNeighbors(NodeGR04 node) {
    ArrayList<NodeGR04> neighbors = new ArrayList<NodeGR04>();

    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        if (x == 0 && y == 0) continue; // skip tank's current position

        int checkX = node.gridX + x;
        int checkY = node.gridY + y;

        if (checkX >= 0 && checkX < cols && checkY >= 0 && checkY < rows) {
          neighbors.add(nodes[checkX][checkY]);
        }
      }
    }
    return neighbors;
  }

  void display() {
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        NodeGR04 n = nodes[i][j];

        if (n.isExplored && n.isWalkable) {
          // transparent green
          fill(0, 255, 0, 60);
          // no borders
          noStroke();
        
          // get top left corner of node
          int x = i * NODE_SIDE_LENGTH;
          int y = j * NODE_SIDE_LENGTH;

          rect(x, y, NODE_SIDE_LENGTH, NODE_SIDE_LENGTH);
        }
      }
    }
  }
}
