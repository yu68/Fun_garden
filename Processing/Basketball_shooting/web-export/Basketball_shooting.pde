import org.jbox2d.util.nonconvex.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.testbed.*;
import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.p5.*;
import org.jbox2d.dynamics.*;
import java.awt.*;
import controlP5.*;

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
PImage hoops, ballImage, tip, shooter, scoreboard, hand, bronze, silver, gold,start_s, final_HOF, final_fail, rule;
// tip: the background with ROCKET logo
// hoops: the two basket rims and boards
// hand: the purple hand arrow
// bronze, silver, gold: three kinds of medals
// start_s: start animation.
// final_HOF: final result image when you reach higher than bronze
// final_fail: final result image when you failed
// rule: rule for achievement.

PFont myFont,myFont2;

int score = 0;
int counter = 0; // control game time

// point:20/10. duration for "+20/+10" effect
int time, point; //time: record real-time game time; point: record current score for "+20/+10"
int duration = 0;  // control "+20/+10" effect and "made shoot!!" animation 

int duration1, duration2;  // control "hit rim"/"hit board" animation time
int start_duration = 60; // control start animation time

// allow input of total time
int total_time=50; // record total game time from user input
boolean timeStart=false; // time only started when input total time and press ENTER
int highlight_instruction=0; // shining effect for instruction on the top.

boolean dragging = false;

boolean userHasTriggeredAudio = false;

void setup() {
  size(800,600);
  frameRate(60);
  
  tip = loadImage("background.jpg");
  hoops = loadImage("basketball_hoop.png");
  ballImage = loadImage("ball.png");
  shooter = loadImage("shoot.png");
  scoreboard = loadImage("scoreBoard.png");
  hand = loadImage("hand.png");
  bronze = loadImage("Bronze_medal.png");
  silver = loadImage("Silver_medal.png");
  gold = loadImage("gold_medal.png");
  start_s = loadImage("start.jpg");
  final_HOF = loadImage("Final.png");
  final_fail = loadImage("Final_fail.png");
  rule = loadImage("rule.png");
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

  //font
  myFont = createFont("Georgia", 45);
  myFont2 = loadFont("SegoeScript-Bold-48.vlw");
  
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
  image(scoreboard, 0, 0, width, height);
  fill(0);
  textFont(myFont2,45);
  fill(140, 163, 199);
  text(score, 570, 100);
  time = int(counter/60);
  text(time, 680, 100);
  
  //allow input of total time
  fill(250,250,250);
  stroke(250,250,250);
  if (!timeStart && highlight_instruction>20){
    rect(295,20,180,48);
    image(hand,400,100,20,35);
    if (highlight_instruction>40) {
    highlight_instruction=0;}
  }  
  if (!timeStart) {
    textFont(myFont2,14);
    fill(255, 0, 0);
    text("Please use UP/DOWN keys \nto change game time and \npress ENTER to START.",300,30);
    image(rule,250,330,250,250);
    highlight_instruction++;
  }
  textFont(myFont2,20);
  fill(0, 0, 0);
  text("Total_time:____s",300,90);
  fill(140,163,199);
  text(total_time,405,90);
  
  if (counter > 60*total_time) {
    background(255);
    if (int(score/total_time*60)>=100) {
    image(final_HOF,50,20,600,600);    
    } else {
      image(final_fail,50,20,600,600);
    }
    textFont(myFont,20);
    fill(10, 10, 10);
    text("Press 'SPACEBAR' \nto start over", 600,300);
    fill(122,104,56);
    textFont(myFont,25);
    text("Final score: "+ score + "\nPerformance: "+int(score/total_time*60)+"/min", 200,550);
    //image(gold,263,150,174,200);
    textFont(myFont,30);
    //text("GOLD",380,500);
    if (int(score/total_time*60)>=250) {
      image(gold,263,170,174,200);
      text("GOLD",360,515);
    } else if (int(score/total_time*60)>=170) {
      image(silver,263,170,174,200);
      text("SILVER",360,515);
    } else if (int(score/total_time*60)>=100) {
      image(bronze,263,170,174,200);
      text("BRONZE",360,515);
    }
    noLoop();
  }
  

  if (timeStart) {
  
  if (start_duration>0) {
    //tint(255, start_duration*3+60);
    image(start_s,width/2-200*(1-0.003*start_duration)/2,150-80*(1-0.003*start_duration)/2,200*(1-0.003*start_duration),80*(1-0.003*start_duration));
    start_duration--;
  }
  counter++;
  
  //score the ball
  Vec2 screenBallPos = physics.worldToScreen(ball.getWorldCenter());
  Vec2 screenBallV = physics.worldToScreen(ball.getLinearVelocity());
  if (screenBallPos.x>190 && screenBallPos.x<240 && screenBallV.y>0) {
  if ((screenBallPos.y>=180-ballSize && screenBallPos.y<=180) || (screenBallPos.y<=320 && screenBallPos.y>=320-ballSize)) //score 
    {
      if (screenBallPos.y<250){
      score += 20;
      point = 20; }
      else { score +=10; text("+10",130,160); point = 10; }
      inSound.cue(0);
      inSound.play();
      ball.setPosition(physics.screenToWorld(new Vec2(650, height-250)));
      duration = 120;
    }
  }
  // "+20/+10" effect
  if (duration>0) {
    
    textFont(myFont2,35);
    fill(228,60,23,2*duration);
    text("+" + point, 30, 440-point*14+0.25*duration); 
    textFont(myFont2,20);
    fill(228,60,23,2*duration);
    text("Made Shoot!!", 30, 40+0.4*duration);

    duration--;
  }
  if (duration1>0) {
    
    textFont(myFont2,15);
    fill(50,50,50,2*duration1);
    text("Hit Board", 30, 40+0.4*duration1); 
    duration1--;
  }
  if (duration2>0) {
    
    textFont(myFont2,15);
    fill(50,50,50,2*duration2);
    text("Hit Rim", 30, 40+0.4*duration2); 
    duration2--;
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
    duration1=120;
    hitBoardSound.cue(0);
    hitBoardSound.speed(impulse);
    hitBoardSound.play();
  }
  else if (b1 == rim_l_1 || b1 == rim_r_1 || b1 == rim_l_2 || b1 == rim_r_2 ||
  b2 == rim_l_1 || b2 == rim_r_1 || b2 == rim_l_2 || b2 == rim_r_2) {
    duration2=120;
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
  if(key == ' ' && counter>0)
 {
   loop();
   score = 0;
   counter = 0;
   timeStart=false;
   total_time=50;

 }
 else if(key == '\n')
 {
   timeStart = true; // start the game
 }
 if (keyCode==UP) {
      total_time +=10;
  }
  if (keyCode==DOWN) {
      total_time -=10;
  }

}


  

