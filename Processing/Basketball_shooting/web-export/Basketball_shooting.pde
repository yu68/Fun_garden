import org.jbox2d.util.nonconvex.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.testbed.*;
import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.p5.*;
import org.jbox2d.dynamics.*;

/**
 * A Basketball shooting game made by SF_mallish
 */

// audio stuff

Maxim maxim;
AudioPlayer hitRimSound, hitBoardSound, hitWallSound, inSound;
Physics physics; // The physics handler: we'll see more of this later

Body ball;
Body board_1, board_2, rim_l_1, rim_r_1, rim_l_2, rim_r_2, in_1, in_2;

// the start point of the catapult 
Vec2 startPoint;
// a handler that will detect collisions
CollisionDetector detector; 

int ballSize = 30;
PImage hoops, ballImage, tip, shooter;

PFont myFont;

int score = 0;
int counter = 0;

boolean dragging = false;

boolean userHasTriggeredAudio = false;

void setup() {
  size(800,600);
  frameRate(60);
  
  tip = loadImage("background.jpg");
  hoops = loadImage("basketball_hoop.png");
  ballImage = loadImage("ball.png");
  shooter = loadImage("shoot.png");
  imageMode=(CENTER);
  
  physics = new Physics(this, width, height, 0, -8, width*2, height*2, width, height, 100);
  physics.setCustomRenderingMethod(this, "myCustomRenderer");
  physics.setDensity(10.0);
  
  // need set up objects for hoops
  // 1 is the above one and 2 is the below one
  physics.setDensity(0.0f);
  board_1 = physics.createRect(170, 65, 185, 165);
  board_2 = physics.createRect(179, 215, 185, 310);
  rim_l_1 = physics.createRect(186, 160, 190, 164);
  rim_r_1 = physics.createRect(240, 160, 244, 164);
  rim_l_2 = physics.createRect(186, 305, 190, 309);
  rim_r_2 = physics.createRect(240, 305, 244, 309);
  //in_1 = physics.createRect(190, 166, 240, 170);
  //in_2 = physics.createRect(190, 311, 240, 315);

  
  startPoint = new Vec2(650,height-250);
  
  startPoint = physics.screenToWorld(startPoint);
  // circle parameters are center x,y and radius
  physics.setDensity(1.0f);
  ball = physics.createCircle(650, height-250, ballSize/2);
  // sets up the collision callbacks
  detector = new CollisionDetector (physics, this);
  
  maxim = new Maxim(this);
  hitBoardSound = maxim.loadFile("hit_board.wav");
  hitRimSound = maxim.loadFile("hit_rim.wav");
  hitWallSound = maxim.loadFile("hit_wall.wav");
  inSound = maxim.loadFile("in_rim.wav");
  hitBoardSound.setLooping(false);
  hitBoardSound.volume(1.0);
  hitRimSound.setLooping(false);
  hitRimSound.volume(1.0);
  hitWallSound.setLooping(false);
  hitWallSound.volume(2.0);
  inSound.setLooping(false);
  inSound.volume(1.0);
  
}

void draw() {
  image(tip, 0, 0, width, height);
  image(hoops, 0, 0, width, height);
  
  fill(0);
  text("Score: " + score, 40, 20);
  text("Time: " + counter/60 + 's', 120, 20);
  
  if (counter > 3000) {
    background(255);
    myFont = createFont("Georgia", 32);
    textFont(myFont);
    text("GAME OVER\nSpacebar to start over\nFinal Score: " + score, width/2-100,height/2-100);
    noLoop();
  }
  counter++;
  
  //score the ball
  Vec2 screenBallPos = physics.worldToScreen(ball.getWorldCenter());
  Vec2 screenBallV = physics.worldToScreen(ball.getLinearVelocity());
  if (screenBallPos.x>190 && screenBallPos.x<240 && screenBallV.y>0) {
  if ((screenBallPos.y>=180-ballSize && screenBallPos.y<=180) || (screenBallPos.y<=320 && screenBallPos.y>=320-ballSize)) //score 
    {
      println ("Made the shoot! v_y: "+screenBallV.y);
      if (screenBallPos.y<250){
      score += 20; }
      else { score +=10; }
      inSound.cue(0);
      inSound.play();
      ball.setPosition(physics.screenToWorld(new Vec2(650, height-250)));

    }
  }
  
}
  
void mousePressed() {
  if(!userHasTriggeredAudio) {
    hitRimSound.play();
    hitBoardSound.play();
    hitWallSound.play();
    userHasTriggeredAudio = true;
  }
}
  

void mouseDragged() {
  dragging = true;
  ball.setPosition(physics.screenToWorld(new Vec2(mouseX, mouseY)));

}

void mouseReleased() {
  dragging = false;
  Vec2 impulse = new Vec2();
  impulse.set(startPoint);
  impulse = impulse.sub(ball.getWorldCenter());
  impulse = impulse.mul(0.8);
  ball.applyImpulse(impulse, ball.getWorldCenter());

}

// this function renders the physics scene.
// this can either be called automatically from the physics
// engine if we enable it as a custom renderer or 
// we can call it from draw
void myCustomRenderer(World world) {
  stroke(0);

  Vec2 screenStartPoint = physics.worldToScreen(startPoint);
  strokeWeight(8);
  image(shooter, screenStartPoint.x-30, screenStartPoint.y-20, 80, 250);

  // get the droids position and rotation from
  // the physics engine and then apply a translate 
  // and rotate to the image using those values
  // (then do the same for the crates)
  Vec2 screenBallPos = physics.worldToScreen(ball.getWorldCenter());
  float ballAngle = physics.getAngle(ball);
  pushMatrix();
  translate(screenBallPos.x, screenBallPos.y);
  rotate(-radians(ballAngle));
  image(ballImage, -ballSize/2, -ballSize/2, ballSize, ballSize);
  popMatrix();

  if (dragging)
  {
    strokeWeight(2);
    line(screenBallPos.x, screenBallPos.y, screenStartPoint.x, screenStartPoint.y);
  }
}


// This method gets called automatically when 
// there is a collision
void collision(Body b1, Body b2, float impulse)
{
  //if (b2 == in_1 || b1 == in_2 || b1 == in_1 || b1 == in_2)
  //{
   // Vec2 screenBallPos = physics.worldToScreen(ball.getWorldCenter());
    //println (screenBallPos.x,screenBallPos.y);
    //if (screenBallPos.y<=166 || (screenBallPos<=305 && screenBallPos>=305-ballSize)) //score top rim from top
    //{
      //score += 10;
      //inSound.cue(0);
      //inSound.play();
    //}
    //ball.setPosition(startPoint);
  //}
  if (b1 == board_1 || b1 == board_2 || b2 == board_1 || b2 == board_2) { // b1 or b2 are the broad
    // board sound
    println("hit board");
    hitBoardSound.cue(0);
    hitBoardSound.speed(impulse);
    hitBoardSound.play();
  }
  else if (b1 == rim_l_1 || b1 == rim_r_1 || b1 == rim_l_2 || b1 == rim_r_2 ||
  b2 == rim_l_1 || b2 == rim_r_1 || b2 == rim_l_2 || b2 == rim_r_2) {
    println("hit rim");
    hitRimSound.cue(0);
    hitRimSound.speed(impulse);
    hitRimSound.play();
  }
  else if (b1.getMass() == 0 || b2.getMass() == 0) {// b1 or b2 are walls

    hitWallSound.cue(0);
    hitWallSound.speed(impulse);
    hitWallSound.play();
    ball.setPosition(physics.screenToWorld(new Vec2(650, height-250)));
    loop();

  } 
  else {
   
  }
  //
}

void keyPressed()
{
  if(key == ' ')
 {
   loop();
   score = 0;
   counter = 0;
 }
}


  

