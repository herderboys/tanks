class Team {

  int teamIndex;
  color col;
  
  float baseX;
  float baseY;
  float baseW;
  float baseH;

  PVector tank0_startpos;
  PVector tank1_startpos;
  PVector tank2_startpos;
  
  // 0 = red (friendly)
  // 1 = blue (enemy)
  Team(int teamIndex) {
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


  void displayHomeBase() {
    strokeWeight(1);
    fill(this.col, 15);
    rect(baseX, baseY, baseW, baseH);
  }

  void display() {
    displayHomeBase();
  }
}
