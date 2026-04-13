class Grid {
  final int GRID_LENGTH = 800;
  final int NODE_SIDE_LENGTH = 50;
  final int ROWS_COLS_AMOUNT = GRID_LENGTH / NODE_SIDE_LENGTH;
  int rows = ROWS_COLS_AMOUNT;
  int cols = ROWS_COLS_AMOUNT;
  Node[][] nodes = new Node[cols][rows];

  Grid() {
    for (int col = 0; col < nodes.length; col++) {
      for (int row = 0; row < nodes[col].length; row++) {
        Node node = new Node(col, row);
        nodes[col][row] = node;

        int centerX = (NODE_SIDE_LENGTH * col) + (NODE_SIDE_LENGTH / 2);
        int centerY = (NODE_SIDE_LENGTH * row) + (NODE_SIDE_LENGTH / 2);

        node.setCenter(centerX, centerY);
      }
    }
  }

  synchronized Node getNodeFromPixels(float physicalX, float physicalY) {
    int nodeCol = (int)physicalX / NODE_SIDE_LENGTH;
    int nodeRow = (int)physicalY / NODE_SIDE_LENGTH;

    if (nodeCol < 0) nodeCol = 0;
    if (nodeCol > cols - 1) nodeCol = cols - 1;
    if (nodeRow < 0) nodeRow = 0;
    if (nodeRow > rows - 1) nodeRow = rows - 1;

    return nodes[nodeCol][nodeRow];
  }

  synchronized ArrayList<Node> getNeighbors(Node node) {
    ArrayList<Node> neighbors = new ArrayList<Node>();

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
}
