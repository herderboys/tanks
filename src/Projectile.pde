class ProjectileGR04 {
    PVector position;
    PVector velocity;
    TeamGR04 ownerTeam;
    boolean isActive = true;

    ProjectileGR04(PVector startPos, float heading, TeamGR04 team) {
        this.position = startPos.copy();
        // 10 pixels per 1/60 seconds (FPS = 60)
        this.velocity = PVector.fromAngle(heading).mult(10);
        this.ownerTeam = team;
    }

    void update() {
        position.add(velocity);
        // deactivate if projectile is out of bounds
        if (position.x < 0 || position.x > width || position.y < 0 || position.y > height) {
            isActive = false;
        }
    }

    void display() {
        fill(255, 255, 0); // yellow projectiles
        noStroke();
        ellipse(position.x, position.y, 8, 8);
    }
}