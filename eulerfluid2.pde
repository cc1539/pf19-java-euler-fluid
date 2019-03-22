
FluidGrid fg;
int dye_level = 0;

Ball ball;
int rez = 2;

void setup() {
  
  size(480,480);
  noSmooth();
  
  fg = new FluidGrid(width/rez,height/rez);
  
  ball = new Ball();
  ball.radius = 40;
  ball.paint = FluidGrid.DYE0;
}

void keyPressed() {
  switch(key) {
    case 'c':
      fg.reset();
    break;
    default:
      try {
        dye_level = Integer.parseInt(key+"");
      } catch(Exception e) {}
    break;
  }
}

void draw() {
  if(mousePressed) {
    int x = (int)((float)mouseX/width*fg.getWidth());
    int y = (int)((float)mouseY/height*fg.getHeight());
    float vx = (mouseX-pmouseX)*5;
    float vy = (mouseY-pmouseY)*5;
    if(mouseButton==LEFT) {
      fg.paint(x,y,40,vx,FluidGrid.VX);
      fg.paint(x,y,40,vy,FluidGrid.VY);
    } else if(mouseButton==RIGHT) {
      fg.paint(x,y,100,30,FluidGrid.DYE0+dye_level);
      //fg.paint(x,y,20,0,0,100);
    } else {
      fg.paintVortex(x,y,200,2);
    }
  }
  
  if(keyPressed && key=='b') {
    ball.x = mouseX;
    ball.y = mouseY;
    ball.vx = mouseX-pmouseX;
    ball.vy = mouseY-pmouseY;
  }
  
  ball.enforceBorder(0,0,width,height);
  ball.vy += 0.1;
  ball.move();
  fg.paint(
      (int)(ball.x/rez),
      (int)(ball.y/rez),
      ball.radius,
      10,
      ball.paint);
  
  for(int i=0;i<1;i++) {
    fg.applyDyeForce();
    fg.step(8);
    fg.advect(1e-2);
  }
  fg.render(-1);
  image(fg.getImage(),0,0,width,height);
}
