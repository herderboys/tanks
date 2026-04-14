// Namn: Alexander Herder, alhe5785

import java.util.*;

class Agent extends Thread {
  private Tank tank;
  private Grid grid;
  private Team team;

  private int selectedAlgorithm;

  // horizontal/vertical moves cost 1
  final float ORTHOGONAL_COST = 1.0f;

  // diagonal moves form a right triangle,
  // so the cost is the hypotenuse (sqrt of 2)
  final float DIAGONAL_COST = (float)Math.sqrt(2);

  private long reportStartTime = 0;
  private boolean isReporting = false;

  List<Node> currentPath = new ArrayList<Node>();

  Agent(Tank tank) {
    this.tank = tank;
    this.team = tank.getTeam();
    this.grid = new Grid();
    this.selectedAlgorithm = 0;
  }

  void run() {
    System.out.println("Agent thread started for " + tank.getName());

    tank.setState(1);

    // where did we see the enemy?
    Node enemyMemory = null;

    while (true) {
      try {

        PVector pos = tank.getPosition();
        Node nodeTankIsStandingOn = grid.getNodeFromPixels(pos.x, pos.y);
        boolean atOwnBase = (pos.x > team.baseX && pos.x < team.baseX+team.baseW &&
          pos.y > team.baseY && pos.y < team.baseY+team.baseH);

        if (!nodeTankIsStandingOn.isExplored) {
          nodeTankIsStandingOn.isExplored = true;
        }

        // sensor phase
        if (tank.getState() == 1 || tank.getState() == 3 || tank.getState() == 4) {

          // projecting sensor coordinates ahead of tank by treating its heading as an angle
          // and the lookAhead distance as the hypotenuse. Multiplying lookAhead by cosine
          // gives you the X-axis, and sine gives the Y-axis
          float lookAhead = 50.0f;
          float sensorX = pos.x + (float)Math.cos(tank.getHeading()) * lookAhead;
          float sensorY = pos.y + (float)Math.sin(tank.getHeading()) * lookAhead;

          Node sensedNode = grid.getNodeFromPixels(sensorX, sensorY);

          boolean hitStatic = tank.isStaticObstacleAt(sensorX, sensorY);
          boolean hitDynamic = tank.isDynamicObstacleAt(sensorX, sensorY);

          // patrolling state
          if (tank.getState() == 1) {
            // calculating enemy base boundaries
            float enemyBaseX = (team.teamIndex == 0) ? CANVAS_WIDTH - 151 : 0;
            float enemyBaseY = (team.teamIndex == 0) ? CANVAS_HEIGHT - 351: 0;
            float enemyBaseW = 150;
            float enemyBaseH = 350;

            boolean insideEnemyBase = (pos.x > enemyBaseX && pos.x < enemyBaseX + enemyBaseW &&
              pos.y > enemyBaseY && pos.y < enemyBaseY + enemyBaseH);

            if (hitDynamic && insideEnemyBase) {
              println("Enemy spotted inside base! Calculating path home.");

              enemyMemory = sensedNode;

              Node startNode = grid.getNodeFromPixels(pos.x, pos.y);
              float targetX = team.baseX + (team.baseW / 2);
              float targetY = team.baseY + (team.baseH / 2);
              Node targetNode = grid.getNodeFromPixels(targetX, targetY);

              calculatePath(startNode, targetNode);

              tank.setState(4);
            } else if (hitStatic) {
              if (sensedNode.isWalkable) {
                // marking nodes containing a tree (static object) as unwalkable
                // removes it from the search graph, preventing the heuristic
                // algorithms from finding paths through it
                sensedNode.isWalkable = false;
                System.out.println("Mapped an unwalkable Node at coordinates [" + sensedNode.gridX + "][" + sensedNode.gridY + "]");
              }
              tank.turn(random((float)Math.PI / 2, (float)Math.PI));
            } else {
              // if we have no current path, find nearest unexplored node
              if (currentPath.isEmpty()) {
                Node target = findNearestUnexplored();
                if (target != null) {
                  Node start = grid.getNodeFromPixels(pos.x, pos.y);
                  boolean pathFound = calculatePath(start, target);

                  if (pathFound) {
                    println("Path to base found! Following it.");
                  } else {
                    println("No path to base! Staying in patrol mode.");
                    tank.turn(random(PI/2, PI));
                  }
                } else {
                  tank.turn(random((float)Math.PI / 4, (float)Math.PI / 2));
                }
              }
            }
          }

          // going back to base
          else if (tank.getState() == 4) {
            println("Entering state 4.");
            if (atOwnBase) {
              println("Already at own base. Entering state 5.");
              tank.setState(5);
              continue;
            }


            if (hitStatic) {
              if (sensedNode.isWalkable) {
                sensedNode.isWalkable = false;
              }

              // try to turn away from obstacle before recalculating
              tank.turn(random(PI, PI / 2));
              while (tank.getState() == 3) {
                try {
                  sleep(10);
                }
                catch (InterruptedException e) {
                  e.printStackTrace();
                }
              }

              println("Path blocked. Recalculating...");
              tank.turn(random(PI / 4, PI / 2));
              tank.setState(4);
              Node startNode = grid.getNodeFromPixels(pos.x, pos.y);
              float targetX = team.baseX + (team.baseW / 2);
              float targetY = team.baseY + (team.baseH / 2);
              Node targetNode = grid.getNodeFromPixels(targetX, targetY);

              boolean success = calculatePath(startNode, targetNode);

              if (!success) {
                println("Can't find path to base, resuming patrol.");
                tank.setState(1);
                currentPath.clear();
              }
            } else {

              if (!currentPath.isEmpty()) {

                Node currentNode = currentPath.get(0);

                float distanceToNode = dist(pos.x, pos.y, currentNode.centerX, currentNode.centerY);

                // ignore nodes that are very close, go to next node
                if (distanceToNode < 20) {
                  currentPath.remove(0);
                }

                if (!currentPath.isEmpty()) {

                  float deltaX = currentNode.centerX - pos.x;
                  float deltaY = currentNode.centerY - pos.y;

                  // atan2 gives us exact angle to the target node by tanking the
                  // Y and X differences
                  float desiredHeading = (float)Math.atan2(deltaY, deltaX);
                  float currentHeading = tank.getHeading();

                  // calculate the shortest angular distance.
                  // this is done to prevent the tank spinning 270 degrees instead of
                  // 90 degrees, when possible
                  float angleDiff = desiredHeading - currentHeading;
                  angleDiff = (float)atan2(sin(angleDiff), cos(angleDiff));

                  // need this, otherwise tank will "unwind" several turns before actually traversing
                  float unwoundTargetHeading = currentHeading + angleDiff;

                  // only halt and turn if angle is off by more than tank turn rate
                  if (abs(angleDiff) > tank.turnRate) {
                    tank.turnTo(unwoundTargetHeading);
                  } else {
                    // else it's aligned
                    tank.setHeading(desiredHeading);
                  }
                }
              } else if (currentPath.isEmpty()) {
                // finished path, check if at base
                println("Path empty. At own base: " + atOwnBase);
                if (atOwnBase) {
                  println("Entering state 5.");
                  tank.setState(5);
                } else {
                  // path ended but not at base, resume patrol
                  println("Not at base. Resuming state 1.");
                  tank.setState(1);
                }
              }
            }
          }
        }

        if (tank.getState() == 5) {
          if (!isReporting) {
            tank.action("stop");
            println("Arrived at base. Reporting enemy... (3 seconds)");

            isReporting = true;
            reportStartTime = System.currentTimeMillis();
          }

          if (System.currentTimeMillis() - reportStartTime >= 3000) {
            if (enemyMemory != null) {
              enemyMemory.isWalkable = false;
              println("Memory updated. Resuming patrol.");
              isReporting = false;
              enemyMemory = null;
            }
            // turn around so we don't drive into wall
            tank.turn((float)Math.PI);

            // pause brain while rotating
            while (tank.getState() == 3) {
              Thread.sleep(10);
            }

            tank.setState(1);
          }
        }
        // avoiding 100% cpu
        Thread.sleep(1);
      }
      catch (Exception e) {
        System.err.println("Agent thread crashed: " + e.getMessage());
      }
    }
  }

  // A* and GBFS (depending on which algirithm is chosen)
  boolean calculatePath(Node startNode, Node targetNode) {
    resetNodeCosts();

    Queue<Node> openSet = new PriorityQueue<Node>();
    HashSet<Node> closedSet = new HashSet<Node>();

    startNode.gCost = 0;
    startNode.hCost = getDistance(startNode, targetNode);

    openSet.add(startNode);

    while (!openSet.isEmpty()) {

      // find node with lowest f cost
      Node currentNode = openSet.poll();
      if (!closedSet.add(currentNode)) {
        continue;
      }

      if (currentNode == targetNode) {
        retracePath(startNode, targetNode);
        return true;
      }

      for (Node neighbor : grid.getNeighbors(currentNode)) {
        if (!neighbor.isWalkable || closedSet.contains(neighbor)) {
          continue;
        }

        /*
          A* evaluates notes using f(n) = g(n) + h(n), where it priotitizes
          nodes with a lower f(n) value. g(n) is the cost of the taken path so far,
          h(n) is the estimated path to the goal. This way, it goes in the right
          direction because of the heuristic, and it remembers the path taken + how
          much it cost to get there. It can also back out of dead ends because of it
          tracking gCost.
        */
        if (selectedAlgorithm == 0 || selectedAlgorithm == 1) {
          // println("Using A* to find path home.");
          float newMovementCostToNeighbor = currentNode.gCost + getDistance(currentNode, neighbor);

          if (newMovementCostToNeighbor < neighbor.gCost || !openSet.contains(neighbor)) {

            if (openSet.contains(neighbor)) {
              // removing node before modifying its values
              // to ensure the queue re-sorts priority based on
              // new fCost. This is because PriorityQueue doesn't
              // automatically re-sort when values change
              openSet.remove(neighbor);
            }
            neighbor.gCost = newMovementCostToNeighbor;
            neighbor.hCost = getDistance(neighbor, targetNode);
            neighbor.parent = currentNode;

            openSet.add(neighbor);
          }
        /*
          Greedy Best-First Search (GBFS) evanluates nodes using
          ONLY the heuristic f(n) = h(n). gCost is set equal to 0 here,
          since it is never used. Therefore the algorithm has no memory
          of the path taken so far, making it vulnerable/prone to getting
          trapped against large "physical" obstacles.
        */
        } else if (selectedAlgorithm == 2) {
          // println("Using GBFS to find path home.");
          if (!openSet.contains(neighbor)) {
            neighbor.gCost = 0; // nullify distance from start
            neighbor.hCost = getDistance(neighbor, targetNode);
            neighbor.parent = currentNode;
            openSet.add(neighbor);
          }
        }
      }
    }
    currentPath.clear();
    return false;
  }

  void retracePath(Node startNode, Node endNode) {
    List<Node> path = new ArrayList<Node>();
    Node currentNode = endNode;

    // trace backwards from target to start
    while (currentNode != startNode && currentNode != null) {
      path.add(currentNode);
      currentNode = currentNode.parent;
    }
    // reverse path so it goes from start to target
    List<Node> reversedPath = new ArrayList<Node>();
    for (int i = path.size() - 1; i >= 0; i--) {
      reversedPath.add(path.get(i));
    }
    this.currentPath = reversedPath;
  }

  Node findNearestUnexplored() {
    Node best = null;
    float bestDist = Float.MAX_VALUE;
    PVector pos = tank.getPosition();

    for (int i = 0; i < grid.cols; i++) {
      for (int j = 0; j < grid.rows; j++) {
        Node n = grid.nodes[i][j];
        if (!n.isExplored && n.isWalkable) {
          float d = dist(pos.x, pos.y, n.centerX, n.centerY);
          if (d < bestDist) {
            bestDist = d;
            best = n;
          }
        }
      }
    }
    return best;
  }

  void resetNodeCosts() {
    for (int i = 0; i < grid.cols; i++) {
      for (int j = 0; j < grid.rows; j++) {
        Node n = grid.nodes[i][j];
        n.gCost = Float.MAX_VALUE;
        n.hCost = 0;
        n.parent = null;
      }
    }
  }


  float getDistance(Node nodeA, Node nodeB) {
    float distX = Math.abs(nodeA.gridX - nodeB.gridX);
    float distY = Math.abs(nodeA.gridY - nodeB.gridY);

    if (distX > distY) {
      return DIAGONAL_COST * distY + ORTHOGONAL_COST * (distX - distY);
    }
    return DIAGONAL_COST * distX + ORTHOGONAL_COST * (distY - distX);
  }

  void setAlgorithm(int a) {
    selectedAlgorithm = a;
  }
}
