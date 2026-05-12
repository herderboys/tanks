// Namn: Alexander Herder, alhe5785

class TankGR04 extends SpriteGR04 {

  PVector acceleration;
  PVector velocity;
  PVector position;

  PVector startpos;
  String name;
  PImage img;
  color col;
  float diameter;
  int tankId;
  int hp = 3;
  long lastFiredTime = 0;

  float speed;
  float maxspeed;
  float heading; // direction tank moves towards
  float targetHeading;
  float turnRate = 0.05; // how fast tank rotates

  TeamGR04 team;

  int state;
  int previousState;
  boolean isInTransition;
  boolean isDead = false;

  //======================================
  TankGR04(String _name, int tankId, PVector _startpos, float _size, TeamGR04 team) {
    println("*** Tank.Tank()");
    this.name         = _name;
    this.diameter     = _size;
    this.tankId       = tankId;
    this.col          = team.col;

    this.startpos     = new PVector(_startpos.x, _startpos.y);
    this.position     = new PVector(this.startpos.x, this.startpos.y);
    this.velocity     = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);

    this.state        = 0; //0(still), 1(moving)
    this.speed        = 0;
    this.maxspeed     = 3;
    this.heading      = 0;
    this.targetHeading = 0;

    this.team = team;

    this.isInTransition = false;
  }

  // synchronized getters and setters to avoid desynchronization issues with this multithreaded program
  synchronized String getName() {
    return name;
  }

  synchronized TeamGR04 getTeam() {
    return team;
  }

  synchronized String getTeamName() {
    return Integer.toString(team.getTeamIndex());
  }

  synchronized int getID() {
    return tankId;
  }

  synchronized void setState(int newState) {
    state = newState;
  }

  synchronized int getState() {
    return state;
  }

  synchronized void setHeading(float h) {
    heading = h;
  }

  synchronized float getHeading() {
    return heading;
  }

  synchronized float getTargetHeading() {
    return targetHeading;
  }

  synchronized void setTargetHeading(float th) {
    targetHeading = th;
  }

  synchronized void setPosition(float x, float y) {
    position.set(x, y);
  }

  synchronized PVector getPosition() {
    return position.copy(); // return a copy to avoid external modification
  }

  //======================================
  void checkEnvironment() {
    // println("*** Tank.checkEnvironment()");

    borders();
  }

  // need to separate checking trees from tanks so as to not map a node
  // containing a tank as a permanently non-walkable node
  boolean isStaticObstacleAt(float checkX, float checkY) {
    float radius = this.diameter / 2;

    if (checkX < radius || checkX > width || checkY < radius || checkY > height) {
      return true;
    }

    for (TreeGR04 tree : allTrees) {
      if (tree != null) {
        float dist = dist(checkX, checkY, tree.position.x, tree.position.y);

        if (dist < tree.diameter / 2) {
          return true;
        }
      }
    }
    return false;
  }

  boolean isDynamicObstacleAt(float checkX, float checkY) {
    float radius = this.diameter / 2;

    for (TankGR04 tank : allTanks) {
      if (tank != null && !tank.equals(this)) {
        float dist = dist(checkX, checkY, tank.position.x, tank.position.y);

        if (dist < (tank.diameter / 2) + radius) {
          return true;
        }
      }
    }

    return false;
  }

  void resolveCollisionWithTree(TreeGR04 tree) {
    float treeRadius = tree.diameter / 2;
    float tankRadius = this.diameter / 2;
    float minSafeDistance = treeRadius + tankRadius;

    PVector pos = getPosition();

    float d = dist(pos.x, pos.y, tree.position.x, tree.position.y);

    // if actual distance is less than safe distance, they are colliding
    if (d < minSafeDistance && d > 0) {
      float overlap = minSafeDistance - d;

      // calculate vector pushing away from tree
      float dx = (pos.x - tree.position.x) / d;
      float dy = (pos.y - tree.position.y) / d;

      // update coordinates to resolve overlap by pushing tank exactly out of collision zone
      pos.x += dx * overlap;
      pos.y += dy * overlap;

      setPosition(pos.x, pos.y);
    }
  }

  void resolveCollisionWithTank(TankGR04 other) {
    float tankRadius = this.diameter / 2;
    float minSafeDistance = tankRadius + tankRadius;

    PVector pos = getPosition();
    PVector otherPos = other.getPosition();

    float d = dist(pos.x, pos.y, otherPos.x, otherPos.y);

    if (d < minSafeDistance && d > 0) {
      float overlap = minSafeDistance - d;

      float dx = (pos.x - otherPos.x) / d;
      float dy = (pos.y - otherPos.y) / d;

      if (hp > 0 && other.hp > 0) {
        // both tanks bounce back equally if both are alive
        pos.x += dx * (overlap / 2);
        pos.y += dy * (overlap / 2);
        setPosition(pos.x, pos.y);

        otherPos.x -= dx * (overlap / 2);
        otherPos.y -= dy * (overlap / 2);
        other.setPosition(otherPos.x, otherPos.y);
      }

      // if only this tank is alive, it absorbs the full bounce
      else if (hp > 0) {
        pos.x += dx * overlap;
        pos.y += dy * overlap;
        setPosition(pos.x, pos.y);
      }

      // same here as before but flipped
      else if (other.hp > 0) {
        otherPos.x -= dx * overlap;
        otherPos.y -= dy * overlap;
        other.setPosition(otherPos.x, otherPos.y);
      }
    }
  }

  void checkBoundaries(float maxWidth, float maxHeight) {
    float radius = this.diameter / 2;

    PVector pos = getPosition();

    if (pos.x - radius < 0) pos.x = radius;
    if (pos.x + radius > maxWidth) pos.x = maxWidth - radius;
    if (pos.y - radius < 0) pos.y = radius;
    if (pos.y + radius > maxHeight) pos.y = maxHeight - radius;

    setPosition(pos.x, pos.y);
  }


  void borders() {
    float r = diameter/2;
    if (position.x - r < 0) position.x = r;
    if (position.y - r < 0) position.y = r;
    if (position.x + r > width) position.x = width - r;
    if (position.y + r > height) position.y = height - r;
  }


  //======================================
  synchronized void moveForward() {
    //    println("*** Tank.moveForward()");

    if (this.speed < this.maxspeed) {
      this.speed += 1.0;
      this.velocity = PVector.fromAngle(heading);
      this.velocity.mult(speed);
    } else {
      this.speed = this.maxspeed;
    }
    this.velocity = PVector.fromAngle(heading);
    this.velocity.mult(speed);
  }

  synchronized void moveBackward() {
    //    println("*** Tank.moveBackward()");

    if (this.speed > -this.maxspeed) {
      this.speed -= 0.01;
    } else {
      this.speed = -this.maxspeed;
    }
    this.velocity = PVector.fromAngle(heading);
    this.velocity.mult(speed);
  }

  synchronized void stopMoving() {
    //    println("*** Tank.stopMoving()");

    this.speed = 0;
    this.velocity.x = 0;
    this.velocity.y = 0;
  }

  synchronized void turn(float angleOffset) {
    targetHeading = this.heading + angleOffset;
    previousState = state;
    state = 3;
    stopMoving();
  }


  // animated turn
  synchronized void smoothTurn() {
    float diff = targetHeading - heading;

    if (abs(diff) <= turnRate) {
      heading = targetHeading;
      state = previousState;
    } else {
      if (diff > 0) {
        heading += turnRate;
      } else {
        heading -= turnRate;
      }
    }
  }

  // method to turn towards a specific direction
  synchronized void turnTo(float absoluteAngle) {
    targetHeading = absoluteAngle;
    previousState = state;
    state = 3;
    stopMoving();
  }

  //======================================
  synchronized void action(String _action) {
    //    println("*** Tank.action()");

    switch (_action) {
    case "move":
      moveForward();
      break;
    case "reverse":
      moveBackward();
      break;
    case "stop":
      stopMoving();
      break;
    case "turning":
      smoothTurn();
      break;
    case "back to base":
      break;
    }
  }

  //======================================
  //Här är det tänkt att agenten har möjlighet till egna val.

  synchronized void update() {
    //    println("*** Tank.update()");

    if (hp <= 0) {
      if (isDead == false) {
        isDead = true;
        getTeam().activeTanks -= 1;
      }
      return; // dead tanks don't update
    }
    switch (state) {
    case 0:
      // still/idle
      action("stop");
      break;
    case 1:
      action("move");
      break;
    case 2:
      action("reverse");
      break;

    case 3:
      action("turning");
      break;

    case 4:
      action("back to base");
      moveForward();
      break;

    case 5:
      action("stop");
      break;

      // attack state
    case 6:
      action("stop");
      break;
    }

    if (hp == 1) {
      this.speed = 0;
      this.velocity.x = 0;
      this.velocity.y = 0;
    }

    this.position.add(velocity);
  }

  //======================================
  void drawTank(float x, float y) {

    if (hp == 2) fill(this.col, 150); // minor damage
    else if (hp == 1) fill(50, 50, 50); // major damage
    else if (hp <= 0) fill(0); // dead

    else {
      fill(this.col, 50);
    }

    // turns oulines on, keeping them after rendering walked on nodes
    stroke(0);

    ellipse(x, y, 50, 50);
    strokeWeight(1);
    line(x, y, x+25, y);

    //kanontornet
    ellipse(0, 0, 25, 25);
    strokeWeight(3);
    float cannon_length = this.diameter/2;
    line(0, 0, cannon_length, 0);
  }

  void display() {
    fill(this.col);
    strokeWeight(1);

    PVector pos = getPosition();
    float h = getHeading();

    pushMatrix();

    translate(pos.x, pos.y);
    rotate(h);

    imageMode(CENTER);
    drawTank(0, 0);
    imageMode(CORNER);

    rotate(-this.heading); // to not draw text wrong way

    strokeWeight(1);
    fill(230);
    rect(0+25, 0-25, 100, 40);
    fill(30);
    textSize(15);
    text(this.name +"\n( " + this.position.x + ", " + this.position.y + " )", 25+5, -5-5);

    popMatrix();
  }
}
