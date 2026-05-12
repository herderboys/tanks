// Namn: Alexander Herder, alhe5785

class TeamGR04 {

  int teamIndex;
  color col;
  int defenderId = -1; // who is currently defending?
  int currentStrategy = 1; // 1 = Utility Based Autonomous Allocation (default),
                           // 2 = Hardcoded Role Allocation
  float closestDefenderDistance = 100000; // score to determine who is defending
  PVector knownEnemyPos = null; // where did we last see an enemy?
  int activeTanks;
  
  float baseX;
  float baseY;
  float baseW;
  float baseH;

  PVector tank0_startpos;
  PVector tank1_startpos;
  PVector tank2_startpos;

  boolean shareIntel = true;
  
  // 0 = red (friendly)
  // 1 = blue (enemy)
  TeamGR04(int teamIndex) {
    this.teamIndex = teamIndex;


      if (teamIndex == 0) {
        col  = color(204, 50, 50);             // base team 0 (red)
        
        baseX = 0;
        baseY = 0;
        baseW = 150;
        baseH = 350;

        tank0_startpos  = new PVector(50, 50);
        tank1_startpos  = new PVector(50, 150);
        tank2_startpos  = new PVector(50, 250);

      } else {
        col  = color(0, 150, 200);             // base team 1 (blue)

        baseX = width - 151;
        baseY = height - 351;
        baseW = 150;
        baseH = 350;

        tank0_startpos  = new PVector(width-50, height-250);
        tank1_startpos  = new PVector(width-50, height-150);
        tank2_startpos  = new PVector(width-50, height-50);
      }
  }

  void setStrategy(int strat) {
    currentStrategy = strat;
  }

  int getTeamIndex() {
    return teamIndex;
  }


  void displayHomeBase() {
    strokeWeight(1);
    fill(this.col, 15);
    rect(baseX, baseY, baseW, baseH);
  }

  void display() {
    displayHomeBase();
  }
}
