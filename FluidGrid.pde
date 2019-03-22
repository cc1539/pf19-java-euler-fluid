
class FluidGrid {
  
  double[][][] fluid;
  public static final int VX = 0;  // x-velocity
  public static final int VY = 1;  // y-velocity
  public static final int RHO = 2; // pressure
  public static final int DYE0 = 3; // dye
  public static final int DYE1 = 4; // dye
  public static final int DYE2 = 5; // dye
  public static final int DYE3 = 6; // dye
  
  public static final int PROP_COUNT = 7;
  
  PImage canvas;
  
  FluidGrid(int w, int h) {
    fluid = new double[w][h][PROP_COUNT*2];
    canvas = createImage(w,h,RGB);
  }
  
  int getWidth() {
    return fluid.length;
  }
  
  int getHeight() {
    return fluid[0].length;
  }
  
  void reset() {
    for(int x=0;x<getWidth();x++) {
    for(int y=0;y<getHeight();y++) {
      for(int d=0;d<fluid[0][0].length;d++) {
        fluid[x][y][d] = 0;
      }
    }
    }
  }
  
  double getLaplacian(int x, int y, int d) {
    double laplacian = 0;
    for(int i=-1;i<=1;i++) {
    for(int j=-1;j<=1;j++) {
      int u = x+i; if(u<0 || u>=getWidth()) { continue; }
      int v = y+j; if(v<0 || v>=getHeight()) { continue; }
      double w = -1;
      if(i!=0 || j!=0) {
        if(i!=0 && j!=0) {
          w = 0.05;
        } else {
          w = 0.2;
        }
      }
      laplacian += w*fluid[u][v][d];
    }
    }
    return laplacian;
  }
  
  double getSpeed(int x, int y) {
    double vx = fluid[x][y][VX];
    double vy = fluid[x][y][VY];
    return Math.sqrt(vx*vx+vy*vy);
  }
  
  void updatePressure() {
    for(int x=0;x<getWidth();x++) {
    for(int y=0;y<getHeight();y++) {
      for(int i=-1;i<=1;i++) {
      for(int j=-1;j<=1;j++) {
        int u=x+i; if(u<0 || u>=getWidth()) { continue; }
        int v=y+j; if(v<0 || v>=getHeight()) { continue; }
        float w = 0;
        if(i!=0 || j!=0) {
          if(i!=0 && j!=0) {
            w = 0.05;
          } else {
            w = 0.2;
          }
        }
        if(w!=0) {
          fluid[x][y][RHO] += (i*fluid[u][v][VX]+j*fluid[u][v][VY])*w;
        }
      }
      }
    }
    }
  }
  
  void updateVelocity() {
    for(int x=0;x<getWidth();x++) {
    for(int y=0;y<getHeight();y++) {
      for(int i=-1;i<=1;i++) {
      for(int j=-1;j<=1;j++) {
        int u=x+i; if(u<0 || u>=getWidth()) { continue; }
        int v=y+j; if(v<0 || v>=getHeight()) { continue; }
        float w = 0;
        if(i!=0 || j!=0) {
          if(i!=0 && j!=0) {
            w = 0.05;
          } else {
            w = 0.2;
          }
        }
        if(w!=0) {
          fluid[x][y][VX] += fluid[u][v][RHO]*i*w;
          fluid[x][y][VY] += fluid[u][v][RHO]*j*w;
        }
      }
      }
    }
    }
  }
  
  double get(double x, double y, int d) {
    int bx = (int)Math.floor(x); double lx = x-bx; int px=bx+1;
    int by = (int)Math.floor(y); double ly = y-by; int py=by+1;
    boolean bxv = bx>=0 && bx<getWidth();
    boolean byv = by>=0 && by<getHeight();
    boolean pxv = px>=0 && px<getWidth();
    boolean pyv = py>=0 && py<getHeight();
    double v00 = bxv && byv ? fluid[bx][by][d] : 0;
    double v10 = pxv && byv ? fluid[px][by][d] : 0;
    double v01 = bxv && pyv ? fluid[bx][py][d] : 0;
    double v11 = pxv && pyv ? fluid[px][py][d] : 0;
    return
        (v00*(1-lx)+v10*lx)*(1-ly)+
        (v01*(1-lx)+v11*lx)*ly;
  }
  
  void advect(float dt) {
    for(int x=0;x<getWidth();x++) {
    for(int y=0;y<getHeight();y++) {
      fluid[x][y][DYE3] = Math.min(Math.max(fluid[x][y][DYE3],0),1);
      double gx = x-fluid[x][y][VX]*dt*(1-fluid[x][y][DYE3]*2);
      double gy = y-fluid[x][y][VY]*dt*(1-fluid[x][y][DYE3]*2);
      for(int i=0;i<PROP_COUNT;i++) {
        fluid[x][y][i+PROP_COUNT] = get(
            i==DYE3?(x-fluid[x][y][VX]*dt):gx,
            i==DYE3?(y-fluid[x][y][VY]*dt):gy,
            i);
      }
    }
    }
    for(int x=0;x<getWidth();x++) {
    for(int y=0;y<getHeight();y++) {
      for(int i=0;i<PROP_COUNT;i++) {
        fluid[x][y][i] = fluid[x][y][i+PROP_COUNT];
      }
    }
    }
  }
  
  void step(int t) {
    for(;t>=1;t--) {
      updatePressure();
      updateVelocity();
    }
  }
  
  void applyDyeForce() {
    for(int x=0;x<getWidth();x++) {
    for(int y=0;y<getHeight();y++) {
      /*
      double dx = getWidth()/2-x;
      double dy = getHeight()/2-y;
      if(dx!=0 || dy!=0) {
        double force = fluid[x][y][DYE]*1e-5*(Math.sqrt(dx*dx+dy*dy)+1);
        fluid[x][y][VX] += dx*force;
        fluid[x][y][VY] += dy*force;
      }
      */
      //fluid[x][y][VX] += (Math.random()-.5)*fluid[x][y][DYE]*10;
      //fluid[x][y][VY] += (Math.random()-.5)*fluid[x][y][DYE]*10;
      
      // fourth dye reverses stuff
      double rev = (1-2*fluid[x][y][DYE3]);
      
      // first dye rises
      fluid[x][y][VY] -= fluid[x][y][DYE0]*0.01*rev;
      
      // second dye causes turbulence
      double lap = getLaplacian(x,y,DYE1)*4;
      fluid[x][y][VX] -= (Math.random()-.5)*lap;
      fluid[x][y][VY] -= (Math.random()-.5)*lap;
      
      // third dye causes low pressure (gravity-like)
      fluid[x][y][RHO] -= fluid[x][y][DYE2]*rev;
      
    }
    }
  }
  
  void render(int isolate) {
    for(int x=0;x<getWidth();x++) {
    for(int y=0;y<getHeight();y++) {
      float rho = (float)fluid[x][y][RHO];
      float v = (float)getSpeed(x,y)*4;
      float dye_r = (float)fluid[x][y][DYE0];
      float dye_g = (float)fluid[x][y][DYE1];
      float dye_b = (float)fluid[x][y][DYE2];
      float dye_a = (float)fluid[x][y][DYE3];
      color pixel = color(0);
      if(isolate>=0) {
        pixel = color((float)fluid[x][y][isolate]);
      } else {
        float r = 0;
        float g = 0;
        float b = 0;
        if(rho>=0) {
          r = rho+dye_r;
          g = v+dye_g;
          b = dye_b;
        } else {
          r = dye_r;
          g = v+dye_g;
          b = -rho*10+dye_b;
        }
        float rev_border = (float)getLaplacian(x,y,DYE3);
        pixel = color(
            r*(1-dye_a)+g*dye_a+b*dye_a+rev_border*255,
            r*dye_a+g*(1-dye_a)+b*dye_a+rev_border*255,
            r*dye_a+g*dye_a+b*(1-dye_a)+rev_border*255);
      }
      canvas.pixels[x+y*getWidth()] = pixel;
    }
    }
    canvas.updatePixels();
  }
  
  void paint(int x, int y, float radius, float value, int d) {
    for(int i=(int)max(x-radius,0);i<=(int)min(x+radius,getWidth()-1);i++) {
    for(int j=(int)max(y-radius,0);j<=(int)min(y+radius,getHeight()-1);j++) {
      if(pow(i-x,2)+pow(j-y,2)<=radius) {
        fluid[i][j][d] += value;
      }
    }
    }
  }
  
  void paintVortex(int x, int y, float radius, float v) {
    for(int i=(int)max(x-radius,0);i<=(int)min(x+radius,getWidth()-1);i++) {
    for(int j=(int)max(y-radius,0);j<=(int)min(y+radius,getHeight()-1);j++) {
      if(pow(i-x,2)+pow(j-y,2)<=radius) {
        fluid[i][j][VX] += (j-y)*v;
        fluid[i][j][VY] -= (i-x)*v;
      }
    }
    }
  }
  
  PImage getImage() {
    return canvas;
  }
  
}
