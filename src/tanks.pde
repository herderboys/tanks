// Namn: Alexander Herder, alhe5785

import java.util.concurrent.CopyOnWriteArrayList;

final int CANVAS_HEIGHT = 800;
final int CANVAS_WIDTH = 800;

int selectedAlgorithm = 1;
int startTime;

boolean left, right, up, down;
boolean mouse_pressed;

PImage tree_img;
PVector tree1_pos, tree2_pos, tree3_pos;

TreeGR04[] allTrees   = new TreeGR04[3];
TankGR04[] allTanks   = new TankGR04[6];
List<ProjectileGR04> projectiles = new CopyOnWriteArrayList<ProjectileGR04>();

TankGR04 tank0;
TankGR04 tank1;
TankGR04 tank2;
TankGR04 tank3;
TankGR04 tank4;
TankGR04 tank5;

TeamGR04 team0;
TeamGR04 team1;

// friendly tanks
AgentGR04 agent0;
AgentGR04 agent1;
AgentGR04 agent2;

// enemy tanks
AgentGR04 agent3;
AgentGR04 agent4;
AgentGR04 agent5;

int tank_size;

int totalTimeLimit = 180000; // 3 minutes in ms
int pauseStartTime;
int totalPausedTime = 0;

boolean gameOver;
boolean pause;
String winningTeam;

//======================================
void setup()
{
  size(800, 800);

  up             = false;
  down           = false;
  mouse_pressed  = false;
  gameOver       = false;
  pause          = true;

  startTime = millis();
  pauseStartTime = millis();

  // Trad
  tree_img = loadImage("tree01_v2.png");
  tree1_pos = new PVector(230, 600);
  tree2_pos = new PVector(280, 230);
  tree3_pos = new PVector(530, 520);

  allTrees[0] = new TreeGR04(tree_img, (int)tree1_pos.x, (int)tree1_pos.y);
  allTrees[1] = new TreeGR04(tree_img, (int)tree2_pos.x, (int)tree2_pos.y);
  allTrees[2] = new TreeGR04(tree_img, (int)tree3_pos.x, (int)tree3_pos.y);

  tank_size = 50;

  team0 = new TeamGR04(0);
  team1 = new TeamGR04(1);

  //tank0_startpos = new PVector(50, 50);
  tank0 = new TankGR04("tank0", 0, team0.tank0_startpos, tank_size, team0);
  tank1 = new TankGR04("tank1", 1, team0.tank1_startpos, tank_size, team0);
  tank2 = new TankGR04("tank2", 2, team0.tank2_startpos, tank_size, team0);

  tank3 = new TankGR04("tank3", 0, team1.tank0_startpos, tank_size, team1);
  tank4 = new TankGR04("tank4", 1, team1.tank1_startpos, tank_size, team1);
  tank5 = new TankGR04("tank5", 2, team1.tank2_startpos, tank_size, team1);

  allTanks[0] = tank0;                         // Symbol samma som index!
  allTanks[1] = tank1;
  allTanks[2] = tank2;
  allTanks[3] = tank3;
  allTanks[4] = tank4;
  allTanks[5] = tank5;

  // friendly tanks
  agent0 = new AgentGR04(tank0);
  agent0.start();
  agent1 = new AgentGR04(tank1);
  agent1.start();
  agent2 = new AgentGR04(tank2);
  agent2.start();

  // enemy tanks
  agent3 = new AgentGR04(tank3);
  agent3.start();
  agent4 = new AgentGR04(tank4);
  agent4.start();
  agent5 = new AgentGR04(tank5);
  agent5.start();
}

void draw()
{
  background(200);
  // checkForInput(); // Kontrollera inmatning.

  if (!gameOver && !pause) {
    if (millis() - startTime - totalPausedTime >= totalTimeLimit) {
      gameOver = true;
      println("Time limit reached, game over.");
    }

    // team wipe check
    boolean team0Alive = false;
    boolean team1Alive = false;

    // check team 0 tanks
    for (int i = 0; i < 3; i++) {
      if (allTanks[i].hp > 0) team0Alive = true;
    }

    // check team 1 tanks
    for (int i = 3; i < 6; i++) {
      if (allTanks[i].hp > 0) team1Alive = true;
    }

    if (!team0Alive || !team1Alive) {
      gameOver = true;
      pauseStartTime = millis();
      if (!team0Alive && !team1Alive) println("Draw, both teams wiped out.");
      else if (!team0Alive) {
        println("Blue team wins.");
        winningTeam = "Blue team";
      } else {
        println("Red team wins.");
        winningTeam = "Red team";
      }
    }

    // UPDATE LOGIC
    updateTanksLogic();

    // CHECK FOR COLLISIONS
    checkForCollisions();
  }
  /*
  if (agent0 != null) {
   agent0.displayGrid();
   }
   
   if (agent1 != null) {
   agent1.displayGrid();
   }
   
   if (agent2 != null) {
   agent2.displayGrid();
   }
   
   */

  // UPDATE DISPLAY
  displayHomeBase();
  displayTrees();
  displayTanks();

  if (!gameOver && !pause) {
    updateProjectiles();
  }

  displayGUI();
}

void updateProjectiles() {
  for (int i = projectiles.size() - 1; i >= 0; i--) {
    ProjectileGR04 p = projectiles.get(i);
    p.update();
    p.display();

    for (TreeGR04 t : allTrees) {
      if (dist(p.position.x, p.position.y, t.position.x, t.position.y) < (t.diameter / 2)) p.isActive = false;
    }

    for (TankGR04 tank : allTanks) {
      if (tank.hp > 0 &&  tank.team.teamIndex != p.ownerTeam.teamIndex && dist(p.position.x, p.position.y, tank.position.x, tank.position.y) < (tank.diameter / 2)) {
        tank.hp -= 1;
        p.isActive = false;
      }
    }
    if (!p.isActive) {
      projectiles.remove(p);
    }
  }
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
  for (TankGR04 tank : allTanks) {
    tank.update();
  }
}

void checkForCollisions() {
  //println("*** checkForCollisions()");
  for (TankGR04 tank : allTanks) {
    if (tank == null) continue;

    for (TreeGR04 tree : allTrees) {
      if (tree != null) {
        tank.resolveCollisionWithTree(tree);
      }
    }

    for (TankGR04 otherTank : allTanks) {
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
  for (TankGR04 tank : allTanks) {
    tank.display();
  }
}

void displayGUI() {
  pushStyle();
  int elapsed;

  // if paused, timer shouldn't tick
  if (pause) {
    elapsed = (pauseStartTime - startTime) - totalPausedTime;
  } else {
    elapsed = (millis() - startTime) - totalPausedTime;
  }

  int remaining = totalTimeLimit - elapsed;
  if (remaining < 0) remaining = 0; // don't show negative numbers

  // convert ms to seconds and minutes
  int seconds = (remaining / 1000) % 60;
  int minutes = (remaining / (1000 * 60)) % 60;

  // format to show 2:05 instead of 2:5
  String timerText = nf(minutes, 2) + ":" + nf(seconds, 2);



  textAlign(CENTER);
  textSize(24);
  fill(0);
  text(timerText, width / 2, 30);
  popStyle();

  if (pause && !gameOver) {
    textSize(28);
    fill(30);
    text("Game paused!\nPress \'1\' to use Cooperative Agents (Shared Intel) for red team\nPress \'2\' to use Independent Agents (Local Intel) for red team\n\nBlue team always uses Cooperative Agents.", width/2 - 350, height/2.5);
  }

  if (gameOver) {
    pause = true;
    textSize(36);
    fill(30);

    text("Game Over!\n" + winningTeam + " wins!\nGame took " + (pauseStartTime - startTime) + " ms.", width/2-175, height/2);
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
    team0.shareIntel = true;
    println("Team 0 now sharing intel.");
    if (pause == true) {
      pause = false;
      totalPausedTime += (millis() - pauseStartTime);
    }
  } else if (key == '2') {
    team0.shareIntel = false;
    println("Team 0 no longer sharing intel.");
    if (pause == true) {
      pause = false;
      totalPausedTime += (millis() - pauseStartTime);
    }
  }

  /*
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
   }
   */
  else if (key == 'p') {
    if (pause == true) {
      pause = false;
      totalPausedTime += (millis() - pauseStartTime);
    } else {
      pause = true;
      pauseStartTime = millis();
    }
  }
}

// Mousebuttons
void mousePressed() {
  //println("---------------------------------------------------------");
  //  println("*** mousePressed() - Musknappen har tryckts ned.");

  mouse_pressed = true;
}
