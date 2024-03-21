import controlP5.*;
import queasycam.*;
import java.util.*;
QueasyCam qcam;
PMatrix3D baseMat;

ControlP5 cp5;
ParticleSystem ps;
PImage bg, grass, water, volcano, smokeImg, lavaImg;
PFont boldFont;
boolean eruption = false;
ArrayList<Collision> coliderList = new ArrayList<Collision>();
float radius;

PVector gravity, gravitySmoke;

int lifespanSliderLava = 600;
int lifespanSliderSmoke = 1000;
float initialLavaVelocity = 1;
float initialLavaVelocityY = 1;
float initialSmokeVelocity = 1;
int particleMultiplierLava = 5;
int particleMultiplierSmoke = 5;
boolean gravityToggle = true;
float gravityIntensity = 1;
boolean randomColour = false;
boolean spheresRendering = true;

final int sz = 1025; // 2^n+1
final float roughness = 0.3;
Random r;
ArrayList<CloudParticle> cloudParticles;
float[][] pixmap;

// Setup the scene, camera and particle system, load images
void setup() {
  size(1000, 800, P3D);
  bg = loadImage("sky.jpg");
  grass = loadImage("ground.png");
  volcano = loadImage("rocks.png");
  smokeImg = loadImage("smokeT.png");
  lavaImg = loadImage("lavaT.png");
  textAlign(LEFT, TOP);
  boldFont = createFont("Bitstream Charter Bold", 18);

  frameRate(60);
  ps = new ParticleSystem();

  // Create coliders
  pyramidColider(6, 120, 100, "volcano", 0.4);
  radius = 10;
  cubeColider(80, 10, "grass", 0.05);
  cubeColider(300, 5, "water", 0.05);

  // Setup gravity for particle systems
  gravity = new PVector(0, -0.05, 0);
  gravitySmoke = new PVector(0, 0.004, 0);

  cp5 = new ControlP5(this);

  // Add sliders and buttons for interaction
  cp5.addSlider("initialLavaVelocityY").setPosition(5, 620).setSize(300, 25).setRange(0, 10).setValue(1).setLabel("Lava Initial Velocity Eruption Upwards");
  cp5.addSlider("lifespanSliderLava").setPosition(5, 645).setSize(300, 25).setRange(0, 3000).setValue(600).setLabel("Lava Lifespan");
  cp5.addSlider("particleMultiplierLava").setPosition(5, 670).setSize(300, 25).setRange(0, 20).setValue(5).setLabel("Lava Particle Multiplier");
  cp5.addSlider("initialLavaVelocity").setPosition(5, 695).setSize(300, 25).setRange(0, 10).setValue(1).setLabel("Lava Initial Velocity Radius");
  cp5.addSlider("lifespanSliderSmoke").setPosition(5, 720).setSize(300, 25).setRange(0, 3000).setValue(1000).setLabel("Smoke Lifespan");
  cp5.addSlider("particleMultiplierSmoke").setPosition(5, 745).setSize(300, 25).setRange(0, 20).setValue(5).setLabel("Smoke Particle Multiplier");
  cp5.addSlider("initialSmokeVelocity").setPosition(5, 770).setSize(300, 25).setRange(0, 10).setValue(1).setLabel("Smoke Initial Velocity Radius");
  cp5.addToggle("gravityToggle").setPosition(900, 700).setSize(50, 25).setValue(gravityToggle).setLabel("Gravity");
  cp5.addSlider("gravityIntensity").setPosition(600, 750).setSize(300, 25).setRange(-1, 5).setValue(1).setLabel("Gravity Intensity");
  cp5.setAutoDraw(false);

  // Create freelook camera
  qcam = new QueasyCam(this);
  qcam.speed = 4;
  qcam.sensitivity = 0.3;
  qcam.controllable = false;
  baseMat = getMatrix(baseMat);
  camera(width/2, height/2-150, (height/2) / tan(PI/6) - 40, width/2, height/2-50, 300, 0, 1, 0);
  
  // Create Setup for Clouds
  r = new Random();
  noStroke();
  loadPixels();
  cloudParticles = new ArrayList<CloudParticle>();
  plasma();
}

void draw() {
  int start_time = millis();
  textureMode(IMAGE);
  noStroke();
  background(bg);

  // Render other objects
  noStroke();
  pyramid(6, 120, 100);
  cube(300, 10, grass);

  for (int i=0; i<coliderList.size(); i++) coliderList.get(i).render();

  // Render particle systems + determine if eruption of volcano or not
  float x = width/2 + (radius * sqrt(random(0, 1))) * cos(random(0, 1) * 2 * PI);
  float z = 300 + (radius * sqrt(random(0, 1))) * sin(random(0, 1) * 2 * PI);
  if(eruption == false){
    ps.addParticleSmoke(new PVector(x, -height/2+50, z));
    ps.runSmoke();
    ps.runLava(coliderList);
  } else {
    ps.addParticleLava(new PVector(x, -height/2+52, z));
    ps.runSmoke();
    ps.runLava(coliderList);
  }

  // Load interface of the program
  g.pushMatrix();
  g.hint(DISABLE_DEPTH_TEST);
  g.resetMatrix();
  g.applyMatrix(baseMat);
  cp5.draw();
  fill(0, 0, 0);
  textFont(boldFont);
  text("Frame Rate: " + (int)frameRate, width*0.01f, height*0.01f);
  text("Nr. of smoke and steam particles: " + ps.smokeParticles.size(), width*0.01f, height*0.03f);
  text("Nr. of lava particles: " + ps.lavaParticles.size(), width*0.01f, height*0.05f);
  text("Press spacebar for volcano to erupt", width*0.70f, height*0.01f);
  text("Click left mouse button to add clouds", width*0.69f, height*0.04f);
  g.hint(ENABLE_DEPTH_TEST);
  g.popMatrix();
  println(millis() - start_time);
  
  // Draw Clouds
  for (int i = 0; i < cloudParticles.size(); ++i){
    CloudParticle p = cloudParticles.get(i);
    p.drawparticle(); p.reproduce(); cloudParticles.remove(i);
  }
}

void keyPressed(){
  if (key == ' '){eruption = !eruption;}
  plasma();
}

void mousePressed(){
  cloudParticles.add(new CloudParticle(mouseX, mouseY, 50, color(255, 0, 255), 10));
}

void pyramidColider(int sides, float d, float h, String material, float reflection){
  PVector[] basePts = new PVector[sides];
  for (int i = 0; i < sides; ++i){
    float ang = TWO_PI * i / sides;
    basePts[i] = new PVector(cos(ang) * d/2, h/2, sin(ang) * d/2);
  }

  for (int i = 0; i < sides; ++i ){
    int i2 = (i+1) % sides;
    Collision pyramidSide1 = new Collision(new PVector(basePts[i].x + width/2, -basePts[i].y-height/2, basePts[i].z+300), new PVector(basePts[i].x*0.3 + width/2, h/2-height/2, basePts[i].z*0.3+300), new PVector(basePts[i2].x*0.3 + width/2, h/2-height/2, basePts[i2].z*0.3+300), material, reflection);
    Collision pyramidSide2 = new Collision(new PVector(basePts[i].x + width/2, -basePts[i].y-height/2, basePts[i].z+300), new PVector(basePts[i2].x + width/2, -basePts[i2].y-height/2, basePts[i2].z+300), new PVector(basePts[i2].x*0.3 + width/2, h/2-height/2, basePts[i2].z*0.3+300), material, reflection);
    Collision pyramidSideTop = new Collision(new PVector(basePts[i].x*0.3 + width/2, h/2-height/2, basePts[i].z*0.3+300), new PVector(width/2, h/2-height/2, 300), new PVector(basePts[i2].x*0.3 + width/2, h/2-height/2, basePts[i2].z*0.3+300), material, 1);
    coliderList.add(pyramidSide1);
    coliderList.add(pyramidSide2);
    coliderList.add(pyramidSideTop);
  }
}

void pyramid(int sides, float d, float h){
  PVector[] basePts = new PVector[sides];
  for (int i = 0; i < sides; ++i ) {
    float ang = TWO_PI * i / sides;
    basePts[i] = new PVector(cos(ang) * d/2, h/2, sin(ang) * d/2);
  }
  pushMatrix();
  translate(width/2, height/2, 300);
  beginShape(QUAD);
  fill(247, 104, 6);
  texture(volcano);
  for(int i = 0; i < sides; ++i){
    int i2 = (i+1) % sides;
    vertex(basePts[i].x, basePts[i].y, basePts[i].z, 0, volcano.pixelHeight);
    vertex(basePts[i2].x, basePts[i2].y, basePts[i2].z, 0, 0);
    vertex(basePts[i2].x*0.3, -h/2, basePts[i2].z*0.3, volcano.pixelWidth, 0);
    vertex(basePts[i].x*0.3, -h/2, basePts[i].z*0.3, 0, 0);
  }
  endShape();
  beginShape();
  fill(247, 104, 6);
  for(int i = 0; i < sides; ++i ){
    vertex(basePts[i].x*-0.3, -h/2, basePts[i].z*-0.3);
  }
  endShape(CLOSE); popMatrix();
}

void cubeColider(int s, int h, String material, float reflection){
  Collision triangle1 = new Collision(new PVector(-s+width/2, h-height/2-60, -s+300), new PVector(s+width/2, h-height/2-60, -s+300), new PVector(s+width/2, h-height/2-60, s+300), material, reflection);
  Collision triangle2 = new Collision(new PVector(-s+width/2, h-height/2-60, -s+300), new PVector(s+width/2, h-height/2-60, s+300), new PVector(-s+width/2, h-height/2-60, s+300), material, reflection);
  coliderList.add(triangle1);
  coliderList.add(triangle2);
}

void cube(int s, int h, PImage img){
  pushMatrix();
  translate(width/2, height/2+60, 300);
  beginShape(QUAD);
  texture(img);
  // +Z "front" face
  vertex(-s, -h, s, 0, 0);
  vertex( s, -h, s, img.pixelWidth, 0);
  vertex( s, h, s, img.pixelWidth, img.pixelHeight);
  vertex(-s, h, s, 0, img.pixelHeight);
  // back
  vertex( s, -h, -s, 0, 0);
  vertex(-s, -h, -s, img.pixelWidth, 0);
  vertex(-s, h, -s, img.pixelWidth, img.pixelHeight);
  vertex( s, h, -s, 0, img.pixelHeight);
  // bottom
  vertex(-s, h, s, 0, 0);
  vertex( s, h, s, img.pixelWidth, 0);
  vertex( s, h, -s, img.pixelWidth, img.pixelHeight);
  vertex(-s, h, -s, 0, img.pixelHeight);
  // top
  vertex(-s, -h, -s, 0, 0);
  vertex( s, -h, -s, img.pixelWidth, 0);
  vertex( s, -h, s, img.pixelWidth, img.pixelHeight);
  vertex(-s, -h, s, 0, img.pixelHeight);
  // right
  vertex( s, -h, s, 0, 0);
  vertex( s, -h, -s, img.pixelWidth, 0);
  vertex( s, h, -s, img.pixelWidth, img.pixelHeight);
  vertex( s, h, s, 0, img.pixelHeight);
  // left
  vertex(-s, -h, -s, 0, 0);
  vertex(-s, -h, s, img.pixelWidth, 0);
  vertex(-s, h, s, img.pixelWidth, img.pixelHeight);
  vertex(-s, h, -s, 0, img.pixelHeight); 
  endShape();
  popMatrix();
}

//  Cloud Functions and Rendering
void plasma(){
  pixmap = new float[sz][sz];
    float c1, c2, c3, c4;
    c1 = random(1.0);
    c2 = random(1.0);
    c3 = random(1.0);
    c4 = random(1.0);    
    sqr(0, 0, sz, sz, c1, c2, c3, c4, 1.0);
    for (int i = 0; i < sz; ++i) {
      for (int j = 0; j < sz; j++) {
        set(i,j, color(210, pixmap[i][j], 100));
      }
    }
}

void sqr(int x, int y, int w, int h, float c1, float c2, float c3, float c4, float std){
  float p1, p2, p3, p4, mid;
  if (w <= 1 && h <= 1) {
    float p = (c1+c2+c3+c4)/4;
    for (int i = x; i < x + w; ++i) {
      for (int j = y; j < y + h; ++j) {
        pixmap[x][y]=p*255;
      }
    }
    return;  
  }
  mid = (c1 + c2 + c3 + c4) / 4 + (float)r.nextGaussian()*std * roughness;
  p1 = (c1 + c2) / 2;
  p2 = (c2 + c3) / 2;
  p3 = (c3 + c4) / 2;
  p4 = (c4 + c1) / 2;
  p1 = max(0.0, min(p1, 1.0));
  p2 = max(0.0, min(p2, 1.0));
  p3 = max(0.0, min(p3, 1.0));
  p4 = max(0.0, min(p4, 1.0));
  sqr(x,y,w/2,h/2, c1,p1,mid,p4,std/2);
  sqr(x+w/2,y,w-w/2,h/2, p1,c2,p2,mid,std/2);
  sqr(x+w/2,y+h/2,w-w/2,h-h/2,mid,p2,c3,p3,std/2);
  sqr(x,y+h/2,w/2,h-h/2, p4,mid,p3,c4,std/2);
}
