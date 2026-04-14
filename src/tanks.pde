// Namn: Alexander Herder, alhe5785

final int CANVAS_HEIGHT = 800;
final int CANVAS_WIDTH = 800;

int selectedAlgorithm = 0;

boolean left, right, up, down;
boolean mouse_pressed;

PImage tree_img;
PVector tree1_pos, tree2_pos, tree3_pos;

Tree[] allTrees   = new Tree[3];
Tank[] allTanks   = new Tank[6];

Tank tank0;
Tank tank1;
Tank tank2;
Tank tank3;
Tank tank4;
Tank tank5;

Team team0;
Team team1;

Agent agent0;

int tank_size;

boolean gameOver;
boolean pause;

//======================================
void setup()
{
  size(800, 800);

  up             = false;
  down           = false;
  mouse_pressed  = false;
  gameOver       = false;
  pause          = true;

  // Trad
  tree_img = loadImage("tree01_v2.png");
  tree1_pos = new PVector(230, 600);
  tree2_pos = new PVector(280, 230);
  tree3_pos = new PVector(530, 520);

  allTrees[0] = new Tree(tree_img, (int)tree1_pos.x, (int)tree1_pos.y);
  allTrees[1] = new Tree(tree_img, (int)tree2_pos.x, (int)tree2_pos.y);
  allTrees[2] = new Tree(tree_img, (int)tree3_pos.x, (int)tree3_pos.y);

  tank_size = 50;

  team0 = new Team(0);
  team1 = new Team(1);

  //tank0_startpos = new PVector(50, 50);
  tank0 = new Tank("tank0", team0.tank0_startpos, tank_size, team0);
  tank1 = new Tank("tank1", team0.tank1_startpos, tank_size, team0);
  tank2 = new Tank("tank2", team0.tank2_startpos, tank_size, team0);

  Tank tank3 = new Tank("tank3", team1.tank0_startpos, tank_size, team1);
  tank4 = new Tank("tank4", team1.tank1_startpos, tank_size, team1);
  tank5 = new Tank("tank5", team1.tank2_startpos, tank_size, team1);

  allTanks[0] = tank0;                         // Symbol samma som index!
  allTanks[1] = tank1;
  allTanks[2] = tank2;
  allTanks[3] = tank3;
  allTanks[4] = tank4;
  allTanks[5] = tank5;

  agent0 = new Agent(tank0);
  agent0.start();
}

void draw()
{
  background(200);
  // checkForInput(); // Kontrollera inmatning.

  if (!gameOver && !pause) {

    // UPDATE LOGIC
    updateTanksLogic();

    // CHECK FOR COLLISIONS
    checkForCollisions();
  }

  // UPDATE DISPLAY
  displayHomeBase();
  displayTrees();
  displayTanks();

  displayGUI();
}

//======================================
void checkForInput() {

  if (up) {
    if (!pause && !gameOver) {
      tank0.state=1; // moveForward
    }
  } else
    if (down) {
      if (!pause && !gameOver) {
        tank0.state=2; // moveBackward
      }
    }

  if (right) {
  } else
    if (left) {
    }

  if (!up && !down) {
    tank0.state=0;
  }
}

//======================================
void updateTanksLogic() {
  for (Tank tank : allTanks) {
    tank.update();
  }
}

void checkForCollisions() {
  //println("*** checkForCollisions()");
  for (Tank tank : allTanks) {
    if (tank == null) continue;

    for (Tree tree : allTrees) {
      if (tree != null) {
        tank.resolveCollisionWithTree(tree);
      }
    }

    for (Tank otherTank : allTanks) {
      if (otherTank != null && tank != otherTank) {
        tank.resolveCollisionWithTank(otherTank);
      }
    }

    tank.checkBoundaries(CANVAS_WIDTH, CANVAS_HEIGHT);
  }

}

void displayHomeBase() {
  if (team0 != null && team1 != null) {
    team0.displayHomeBase();
    team1.displayHomeBase();
  }
}

// Följande bör ligga i klassen Tree
void displayTrees() {
  imageMode(CENTER);
  image(tree_img, tree1_pos.x, tree1_pos.y);
  image(tree_img, tree2_pos.x, tree2_pos.y);
  image(tree_img, tree3_pos.x, tree3_pos.y);
  imageMode(CORNER);
}

void displayTanks() {
  for (Tank tank : allTanks) {
    tank.display();
  }
}

void displayGUI() {
  if (pause) {
    textSize(36);
    fill(30);
    text("Game paused!\nPress \'1\' to use A* for pathfinding\nPress \'2\' to use Greedy Best-First Search \nfor pathfinding", width/1.7-350, height/2.5);
  }

  if (gameOver) {
    textSize(36);
    fill(30);
    text("Game Over!", width/2-100, height/2);
  }
}

//======================================
void keyPressed() {
//  System.out.println("keyPressed!");

  if (key == CODED) {
    switch(keyCode) {
    case LEFT:
      left = true;
      break;
    case RIGHT:
      right = true;
      break;
    case UP:
      up = true;
      break;
    case DOWN:
      down = true;
      break;
    }
  }
}

void keyReleased() {
  // System.out.println("keyReleased!");
  if (key == CODED) {
    switch(keyCode) {
    case LEFT:
      left = false;
      break;
    case RIGHT:
      right = false;
      break;
    case UP:
      up = false;
      //tank0.stopMoving();
      break;
    case DOWN:
      down = false;
      //tank0.stopMoving();
      break;
    }
  }

  if (key == '1') {
    selectedAlgorithm = 1;
    agent0.setAlgorithm(1);
    println("Now using A* for pathfinding home.");
    if (pause == true) {
      pause = !pause; 
    }
  } else if (key == '2') {
    selectedAlgorithm = 2;
    agent0.setAlgorithm(2);
    println("Now using Greedy Best-First Search for pathfinding home.");
    if (pause == true) {
      pause = !pause;
    }
  } else if (key == 'p') {
      pause = !pause;
  }
}

// Mousebuttons
void mousePressed() {
  //println("---------------------------------------------------------");
//  println("*** mousePressed() - Musknappen har tryckts ned.");

  mouse_pressed = true;
}
