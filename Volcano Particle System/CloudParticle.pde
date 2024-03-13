// CloudParticle.java
class CloudParticle {
  PVector position, vel, acc, colorCloud;
  float initialCloudVelocity = 0.5;
  int lifespanSliderCloud = 2000;
  float lifespan, sphereSize;

  CloudParticle(PVector position_) {
    // Setup particle velocity, position, and lifespan
    float vx = randomGaussian() * 0.1 * initialCloudVelocity;
    float vy = randomGaussian() * 0.05 * initialCloudVelocity;
    float vz = randomGaussian() * 0.1 * initialCloudVelocity;
    acc = new PVector(0, 0, 0);
    vel = new PVector(vx, vy, vz);
    position = position_.copy();
    // Set color to white
    colorCloud = new PVector(255, 255, 255);
    lifespan = lifespanSliderCloud;
    sphereSize = random(3, 6); 
  }

  void applyForce(PVector inputForce) {
    acc.add(inputForce);
  }

  void run() {
    update();
    render();
  }

  void update() {
    vel.add(acc);
    position.add(vel);
    lifespan -= random(0.5, 2); // Adjust lifespan decrement for clouds
    acc.mult(0);
  }

  void render() {
    // Rendering for clouds
    pushMatrix();
    translate(position.x, -position.y, position.z);
    noStroke();
    fill(colorCloud.x, colorCloud.y, colorCloud.z, lifespan);
    sphereDetail(4);
    sphere(sphereSize);
    popMatrix();
  }

  boolean isDead() {
    return (lifespan < 0.0);
  }
}
