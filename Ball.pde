
class Ball {
  
  float x;
  float y;
  float vx;
  float vy;
  float radius;
  int paint;
  
  void enforceBorder(float x0, float y0, float x1, float y1) {
    float damp = 0.99;
    if(x!=(x=min(max(x,x0+radius),x1-radius))) { vx*=-damp; }
    if(y!=(y=min(max(y,y0+radius),y1-radius))) { vy*=-damp; }
  }
  
  void move() {
    x += vx;
    y += vy;
  }
  
}
