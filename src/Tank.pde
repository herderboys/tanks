class Tank extends TankSprite {

  PVector acceleration;
  PVector velocity;
  PVector position;

  PVector startpos;
  String name;
  PImage img;
  color col;
  float diameter;

  float speed;
  float maxspeed;
  float heading; // direction tank moves towards
  float targetHeading;
  float turnRate = 0.05; // how fast tank rotates

  Team team;

  int state;
  int previousState;
  boolean isInTransition;

  //======================================
  Tank(String _name, PVector _startpos, float _size, Team team) {
    println("*** Tank.Tank()");
    this.name         = _name;
    this.diameter     = _size;
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

  synchronized Team getTeam() {
    return team;
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

    for (Tree tree : allTrees) {
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

    for (Tank tank : allTanks) {
      if (tank != null && !tank.equals(this)) {
        float dist = dist(checkX, checkY, tank.position.x, tank.position.y);

        if (dist < (tank.diameter / 2) + radius) {
          return true;
        }
      }
    }

    return false;
  }

  void resolveCollisionWithTree(Tree tree) {
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

      // update coordinates to resolve overlap
      pos.x += dx * overlap;
      pos.y += dy * overlap;

      setPosition(pos.x, pos.y);
    }
  }

  void resolveCollisionWithTank(Tank other) {
    float tankRadius = this.diameter / 2;
    float minSafeDistance = tankRadius + tankRadius;

    PVector pos = getPosition();
    PVector otherPos = other.getPosition();

    float d = dist(pos.x, pos.y, otherPos.x, otherPos.y);

    if (d < minSafeDistance && d > 0) {
      // divide overlap by 2 so both tanks get pushed away by the same amount
      float overlap = (minSafeDistance - d) / 2;

      float dx = (pos.x - otherPos.x) / d;
      float dy = (pos.y - otherPos.y) / d;

      pos.x += dx * overlap;
      pos.y += dy * overlap;
      setPosition(pos.x, pos.y);

      otherPos.x -= dx * overlap;
      otherPos.y -= dy * overlap;
      other.setPosition(otherPos.x, otherPos.y);
    }
  }
  
  void checkBoundaries(float maxWidth, float maxHeight) {
    float radius = this.diameter / 2;

    PVector pos = getPosition();

    if (pos.x - radius < 0) pos.x = radius;
    if (pos.x + radius > maxWidth) pos.x = maxWidth - radius;
    if (pos.y - radius < 0) pos.y = radius;
    if (pos.y + radius > maxHeight) pos.y = maxHeight - radius;
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
    }

    this.position.add(velocity);
  }

  //======================================
  void drawTank(float x, float y) {
    fill(this.col, 50);

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
