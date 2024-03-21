class CloudParticle{
  float x, y, opacity, w;
  color col;
  boolean alive;
  
  CloudParticle(float _x, float _y, float _w, color c, float o){
    x = _x; y = _y; w = _w; col = c; opacity = o; alive = true;
  }
  
  public void reproduce(){
    if(w > 1)    {
      for(int i = 0; i < 2; i++){
        float newX = x + random(-w, w);
        float newY = y + random(-w/2, w/4);
        float r = random(10);
        float newW = w - r;
        if(newW < 1) newW = 1;
        cloudParticles.add(new CloudParticle(newX, newY, newW, col, opacity));
        alive = false;
      }
    }
  }
  
  public void drawparticle(){
    fill(col, opacity);
    ellipse(x, y, w, w);
  }
}
