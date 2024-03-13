class ParticleSystem {
  ArrayList<LavaParticle> lavaParticles;
  ArrayList<SmokeParticle> smokeParticles;
  ArrayList<CloudParticle> cloudParticles; 
  ArrayList<PVector> deadLavaParticles;
  PVector origin;
  float counterLava = 0.0;
  float timerLava = 5.0;
  float counterSmoke = 0.0;
  float timerSmoke = 5.0;
  float counterCloud = 0.0; // Counter for cloud particle addition
  float timerCloud = 5.0; // Timer for cloud particle addition
  float particleMultiplierCloud = 5.0; 
  int howManyLava, howManySmoke, howManyCloud;

  ParticleSystem() {
    lavaParticles = new ArrayList<LavaParticle>();
    smokeParticles = new ArrayList<SmokeParticle>();
    cloudParticles = new ArrayList<CloudParticle>(); 
    deadLavaParticles = new ArrayList<PVector>();
  }

  // LAVA PARTICLES
  void addParticleLava(PVector position) {
    howManyLava = (int) 10 * particleMultiplierLava; // Random nr of particles to add per run
    if (counterLava >= timerLava) {
      counterLava = 0;
      for (int i=0; i<howManyLava; i++) {
        lavaParticles.add(new LavaParticle(position));
      }
    } else {
      counterLava += 1; // Count time between particle spawn
    }
  }

  void runLava(ArrayList<Collision> coliderList) {
    for (int i = 0; i<lavaParticles.size(); i++) {
      LavaParticle p = lavaParticles.get(i);
      if (p.vapour == true) {
        smokeParticles.add(new SmokeParticle(p.position));
        int temp = smokeParticles.size()-1;
        smokeParticles.get(temp).lifespan = smokeParticles.get(temp).lifespan/4;
        smokeParticles.get(temp).colourSmoke = new PVector(238, 238, 238);
        lavaParticles.remove(i);
      }
      if (p.isDead()) {
        lavaParticles.remove(i);
      }
      // Stop at a certain terminal velocity
      if (gravityToggle == true) {
        if (p.vel.y > -5) {
          PVector force = new PVector();
          p.applyForce(PVector.mult(gravity, gravityIntensity, force));
        }
      }
      p.run(coliderList);
    }
  }

  // SMOKE PARTICLES
  void addParticleSmoke(PVector position) {
    howManySmoke = (int) 2 * particleMultiplierSmoke; // Random nr of particles to add per run
    if (counterSmoke >= timerSmoke) {
      counterSmoke = 0;
      for (int i=0; i<howManySmoke; i++) {
        smokeParticles.add(new SmokeParticle(position));
      }
    } else {
      counterSmoke += 1; // Count time between particle spawn
    }
  }

  void runSmoke() {
    for (int i = 0; i<smokeParticles.size(); i++) {
      SmokeParticle p = smokeParticles.get(i);
      if (p.isDead()) {
        smokeParticles.remove(i);
      }
      // Stop at a certain terminal velocity
      if (gravityToggle == true) {
        if (p.vel.y < 0.5) {
          PVector force = new PVector();
          p.applyForce(PVector.mult(gravitySmoke, gravityIntensity, force));
        }
      }
      p.run();
    }
  }
  
  // CLOUD PARTICLES
  void addParticleCloud(PVector position) {
    howManyCloud = (int) (2 * particleMultiplierCloud); // Adjust particle count for clouds
    if (counterCloud >= timerCloud) {
      counterCloud = 0;
      // Adjust the y-coordinate to spawn the clouds higher in the sky
      float y = position.y + 100; // Change this value as needed
      for (int i=0; i<howManyCloud; i++) {
        cloudParticles.add(new CloudParticle(new PVector(position.x, y, position.z)));
      }
    } else {
      counterCloud += 1; // Count time between cloud particle spawns
    }
  }
  
  void addParticleCloudAtMousePosition() {
    PVector position = new PVector(mouseX, mouseY, 0); // Get mouse position
    cloudParticles.add(new CloudParticle(position)); // Add cloud particle at mouse position
    runCloud();
  }

  void runCloud() {
    for (int i = 0; i<cloudParticles.size(); i++) {
      CloudParticle p = cloudParticles.get(i);
      if (p.isDead()) {
        cloudParticles.remove(i);
      }
      p.run();
    }
  }
  
}
