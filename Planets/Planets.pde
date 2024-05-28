float G = 5f;

Planet[] planets;
Actor[] actors;
PVector screen = new PVector(1640, 480);
int nplanets = 23;
  int nactors = 23;

PGraphics[] layers = new PGraphics[3];

void setup() {
  size(1640, 480); 
  
  for (int i = 0; i < layers.length; i++) {
    layers[i] = createGraphics(width, height);
  }  

  int minrad = 7, maxrad = 70;
  int maxvel = 4;
  int amass = 5;

  PVector[] apos = new PVector[nactors];
  PVector[] ppos = new PVector[nplanets];
  for (int i = 0; i < nplanets; i++) {
    ppos[i] = new PVector(0, 0);
  }
  
  
  
  
  
  
  
  distribute(screen, nplanets, ppos);
  planets = new Planet[nplanets];
  for (int i = 0; i < nplanets; i++) {
    int size = int(random(minrad, maxrad));
    planets[i] = new Planet(ppos[i], size, size);
  }

  for (int i = 0; i < nactors; i++) {
    apos[i] = new PVector(0, 0);
  }
  distribute(screen, nactors, apos);
  actors = new Actor[nactors];
  for (int i = 0; i < nactors; i++) {
    actors[i] = new Actor(apos[i], amass, new PVector(random(-maxvel, maxvel), random(-maxvel, maxvel)));
  }
}

void draw() {
  
 for (int i = 0; i < layers.length; i++) {
    layers[i].beginDraw();
  }
  
  layers[0].background(102);
  
  if (mousePressed == true) {
    if(mouseButton == LEFT)
      layers[2].clear();
    
    if(mouseButton == RIGHT){
      layers[1].clear();
      PVector[] pos = new PVector[nplanets];
      for(int i = 0;i < nplanets; i++){
        pos[i] = planets[i].pos;
      }
      distribute(screen, nplanets, pos);
      for(int i = 0;i < nplanets; i++){
        planets[i].pos = pos[i];
      }
    }
  } 

  for (int i =0; i < planets.length; i++) {
    planets[i].display();
    planets[i].updateActors(actors);
  }

  for (int i =0; i < actors.length; i++) {

    actors[i].applyMotion();
    actors[i].resolveCollisions();


    actors[i].display();
  }
  
  for (int i = 0; i < layers.length; i++) {
    layers[i].endDraw();
    image(layers[i],0,0);
  }
}




class Planet {
  float mass;
  PVector pos;
  float radius;
  float maxradius = 2000;

  Planet(PVector p, float m, float r) {
    mass = m;
    radius = r;
    pos = p;
  }

  public void updateActors(Actor[] actors) {

    PVector towardsMe;
    float r, f;
    for (int i = 0; i < actors.length; i++) {

      towardsMe = PVector.sub(pos, actors[i].pos);
      r = towardsMe.mag();

      if ( r > maxradius || r - radius <= 0)
        continue;

      towardsMe.normalize();


      actors[i].addForce(towardsMe.mult((G * mass * actors[i].mass) / (r * r)));
    }
  }

  public void display() {
    layers[1].fill(0);
    layers[1].circle(pos.x, pos.y, radius * 2);
  }
}

class Actor {
  public PVector pos;
  float mass;
  PVector fNet, vel;

  PVector norm = new PVector(0, 0);

  public Actor(PVector p, float m, PVector v) {
    pos = p;
    mass = m;
    fNet = new PVector(0, 0);
    vel = v;
  }

  public void addForce(PVector f) {
    fNet.add(f);
  }

  public void applyMotion() {

    //println(fNet);

    fNet.mult(1 / mass);  //Acceleration -> F = ma
    vel.add(fNet);
    pos.add(vel);

    fNet = new PVector(0, 0);
  }

  //Happens after applyMotion() is called
  public void resolveCollisions()
  {
    float epsilon = 1f;
    float damping = 1f;
    float d;
    PVector n;
    PVector newPos;
    PVector velDelta;
    for (int i =0; i < planets.length; i++) {
      n = PVector.sub(pos, planets[i].pos);
      d = n.mag();

      if (d <= planets[i].radius) {


        norm = PVector.mult(n, 1 / d);

        velDelta = PVector.mult(n, damping * (-2 / (d*d)) * PVector.dot(n, vel));


        vel = PVector.add(vel, velDelta);
        n.normalize();
        pos = PVector.add(planets[i].pos, PVector.mult(n, (planets[i].radius + epsilon)));
      }
    }

    resolveWallCollisions();


    //println(pos);
  }

  private void resolveWallCollisions()
  {
    if (pos.x < 0)
    {
      pos.x = 1;
      if (vel.x < 0)
        vel.x = -vel.x;
    }
    if (pos.x > screen.x)
    {
      pos.x = screen.x - 1;
      if (vel.x > 0)
        vel.x = -vel.x;
    }
    if (pos.y < 0)
    {
      pos.y = 1;
      if (vel.y < 0)
        vel.y = -vel.y;
    }
    if (pos.y > screen.y)
    {
      pos.y = screen.y - 1;
      if (vel.y > 0)
        vel.y = -vel.y;
    }
  }



  public void display() {
    layers[2].noStroke();
        //layers[2].fill(millis() / 7 % 255);

    layers[2].fill(millis() / 32 % 255, millis() / 7 % 255, millis() / 14 % 255);
    layers[2].circle(pos.x, pos.y, 2.5);
    //int scaleFactor = 10;
    //strokeWeight(1);
    //println(norm);
    //stroke(255);
    //line(pos.x, pos.y, pos.x + norm.x * scaleFactor, pos.y + norm.y * scaleFactor);
    //noStroke();
  }
}
