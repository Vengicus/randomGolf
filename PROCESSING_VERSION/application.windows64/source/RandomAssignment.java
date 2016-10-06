import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class RandomAssignment extends PApplet {

//NOTES
//FIX COLLISION DETECTION --> CURRENTLY THE HOLE'S COLLISION CIRCLE IS OFFSET ABOVE HOLE
//FIX VECTOR MOVEMENT FOR MORE PRECISE CALCULATIONS


/*
  Andrew Schoolnick
  Interactive Media Development
  2-12-15
  Randomly Generated Golf Game
*/


//Game Mode for swapping screens//
String currentMode = "Menu";


//Object initialization//
Menu mainMenu;
quitMenu exitMenu;
LevelGenerator levelGenerator;
HUD hud;
PlayerBall ballPlayer;



ScoreCard scoreCard;



//Havent used this variable YET, it will be used to generate variation between the 4 maps you can select on home screen//
int mapToBeGenerated = 0;


//References the xPos and yPos of the golf ball
float playerBallYPos;
float playerBallXPos;

PVector playerBallPreviousPos;


//Variables to restrict ball hitting//
boolean wait = true;
boolean ballHit = false;


float movementLeft = 0;



/*float cloudXOff = 0;
float cloudYOff = 0;
*/


//Vectors for Ball Movement//

PVector position;    //Stores X & Y values
PVector velocity;
PVector mousePos;
PVector dir;
//PVector direction;
PVector accel;



int ballHitFSM = 0; //0 = Not hit, 1 = In Air, 2 = Stopped



float amountToMove;    //Randomly generated movement value
float amountMoved = 0; //How far the ball has moved relative to amountToMove


int typeOfClub = 9;
  /*
  0 = Putter
  1 = SW
  2 = 9 Iron
  3 = 8 Iron
  4 = 7 Iron
  5 = 6 Iron
  6 = 5 Hybrid
  7 = 4 Hybrid
  8 = 3 Wood
  9 = Driver
  */

float mean = 180;

float ballPower = 0;
float powerIncrement = 1;

ArrayList<Terrain> terrainListReference;

int strokes = 0;
int numStrokesHole = 3;

String previousMode = "Menu";


boolean displayOBText = false;



int trackColorWater;





boolean ballInHole = false;
Hole golfHolePublic;



int strokeTotal = 0;
int parTotal = 0;


int currentHole = 1;
int holeLimit = 18;




boolean displayScoreCard = false;

boolean gameReset = false;
boolean loadGame = false;


int ballsScaling = 0;



public void setup()
{
  size(1280, 720, P2D);
  frameRate(30);
  background(235);
  
  colorMode(RGB, 255, 255, 255, 100);
  
  //Object assisnment//
  mainMenu = new Menu();
  exitMenu = new quitMenu();
  
  //BUILD THE LEVEL, I put this is setup since I only really want to generate one map per game FOR NOW
  numStrokesHole = PApplet.parseInt(random(3, 6));
  levelGenerator = new LevelGenerator(numStrokesHole);
  hud = new HUD();
  
  noStroke();
  
  //Reference the player ball object from level generator which will point to the player ball object in terrain and return it back to here//
  ballPlayer = levelGenerator.getPlayerBall();
  terrainListReference = levelGenerator.terrainListReturn();
  
  
  scoreCard = new ScoreCard();
  
}

public void draw()
{
  if(currentMode == "Menu")
  {
    mainMenu.display();
    mainMenu.checkIfMouseMoved(); //Check mousePos on menu
    gameReset = false;
  }
  
  else if(currentMode == "newGame")
  {
    if(gameReset == false && loadGame == false)
    {
      currentHole = 1;
      strokes = 0;
      strokeTotal = 0;
      parTotal = 0;
      scoreCard.clearScoreCard();
      buildTheNewHole();
      gameReset = true;
    }
    hud.checkIfMouseMoved();
    showLevel();
    moveBall();
    //showClouds();
    //println(ballPlayer.xPos);
  }
  
  else if(currentMode == "loadGame")
  {
    hud.checkIfMouseMoved();
    showLevel();
    moveBall();
    //showClouds();
    
    //println(ballPlayer.xPos);
  }
  
  else if(currentMode == "options")
  {
    
  }
  
  else if(currentMode == "exitGame")
  {
     if(previousMode == "Menu")
     {
      mainMenu.display();
     }
     else if(previousMode == "newGame")
     {
       showLevel();
     }
     exitMenu.display();
  }
  
  else if(currentMode == "Score")
  {
    
  }
  
  else if(currentMode == "Pause")
  {
    
  }
  
}

//Will be implemented later for wind direction
/*
void showClouds()
{
    
}
*/


//DISPLAY THE LEVEL
public void showLevel()
{
    pushMatrix();
      translate(movementLeft, -playerBallYPos + (height/1.5f));    //Align camera with ball position with a slight offset, but dont move xPos
      //println(playerBallYPos);
      levelGenerator.displayTerrain();
    popMatrix();
    
    if(displayScoreCard == false)
    {
       hud.display(); 
    }
    else
    {
      //fill(100, 100, 100, 100);
      //rect(0,0,width,height);
      scoreCard.display();
      //noFill();
    }
    
}

public void moveBall()
{
    //Do Nothing
    if(ballHitFSM == 0)
    {
      if(displayOBText)
      {  
          if(hud.displayOB() == false)
          {
              
          }
          
          else
          {
             displayOBText = false; 
          }
          
      }
    }
    //Determine Power
    else if(ballHitFSM == 1)
    {
       ballPower+= powerIncrement;
       if(ballPower > 100)
       {
           powerIncrement *= -1;
       }
       else if(ballPower < 0)
       {
           powerIncrement *= -1;
       }
    }
    //Animate Ball
    else if(ballHitFSM == 2)
    {
      
      if(amountMoved < amountToMove && ballInHole == false)
      {
        
        //Update vectors to be used when ball is hit
        
        velocity = PVector.mult(accel, 10);
        
        position.normalize();
        position.add(velocity);
        
        //position.mult(10);
        ballPlayer.xPos += position.x;
        ballPlayer.yPos += position.y;
        
        
        if(typeOfClub > 0)
        {
          //Scale Ball Up
          //Left side of Parabola, moving upwards
          if(amountMoved < amountToMove / 2)
          {
             ballsScaling = 1;
          }
        
          //Scale Ball Down
          //Right side of Parabola, moving downwards
          else if(amountMoved < amountToMove)
          {
             ballsScaling = 2;
          }
        }
        
      }
      else if(ballPlayer.xPos < 0 || ballPlayer.xPos > width)
      {
         position = playerBallPreviousPos;
         ballPlayer.xPos = position.x;
         ballPlayer.yPos = position.y;
         strokes+=2;
         ballsScaling = 0;
         displayOBText = true;
         ballHitFSM = 3;
      }
      else
      {
          //checkForCollision();
          //ballPlayer.scale = 3;
          boolean checkForCollideHole = ballPlayer.checkForCollisionHole(new PVector(golfHolePublic.xPos, golfHolePublic.yPos), golfHolePublic.size);
          if(checkForCollideHole)
          {
              ballInHole = true;
              buildNewHole();
          }
          
          
          
          ballHitFSM = 3;
      }
      amountMoved+=1;
     // println(amountMoved);
     // println(amountToMove);
    }
    //Return to Do Nothing
    else if(ballHitFSM == 3)
    {
        ballPower = 0;
        ballHitFSM = 0;
        strokes++;
        if(strokes > 9)
        {
            buildNewHole();
            
        }
    }
}


public void buildNewHole()
{
    strokeTotal += strokes;
    println(strokeTotal + " total strokes");
    
    ballInHole = false;
    
    displayScoreCard = true;
    //Display Score, wait for user to hit enter, THEN make next hole
    scoreCard.update(numStrokesHole, strokes);
    
    
    strokes = 0;
    typeOfClub = 9;
    currentHole++;
    
    //buildTheNewHole();
    
    
    
}


public void buildTheNewHole()
{
      numStrokesHole = PApplet.parseInt(random(3, 6));
      levelGenerator = new LevelGenerator(numStrokesHole);
      ballPlayer = levelGenerator.getPlayerBall();
      terrainListReference = levelGenerator.terrainListReturn();
}





public void checkForCollision()
{
    for(Terrain t : terrainListReference)
    {
       
    }
}


public void mouseClicked()
{
  //If on menu screen
  if(currentMode == "Menu")
  {
    mainMenu.display();
    mainMenu.checkIfMouseClicked();    //If mouse clicks on the menu screen
  }
  
  //If on game screen
  else if(currentMode == "newGame")
  {
    //wait keeps the ball from being hit when switching between menu and the game, ballHitFSM of zero means not hit
    hud.checkIfClickedArrow();
    checkIfMousePressedGame();
    
  }
  else if(currentMode == "exitGame")
  {
     if(mouseX >= width/2 - 75 && mouseX <= width/2 - 25 && mouseY >= height/2 + 25 && mouseY <= height/2 + 50)
       {
            if(previousMode == "Menu")
            {
              exit();
            }
            else if(previousMode == "newGame")
            {
               currentMode = "Menu"; 
            }
            
       }
    else if(mouseX >= width/2 + 30 && mouseX <= width/2 + 80 && mouseY >= height/2 + 25 && mouseY <= height/2 + 50)
      {
            if(previousMode == "newGame")
            {
              currentMode = "newGame";
            }
            else if(previousMode == "Menu")
            {
              currentMode = "Menu";
            }
            
      }
         
  }  
}


public void keyPressed()
{
   if (key == ESC) 
   {
     key = 0; 
   }
}

public void keyReleased()
{
  if(keyCode == ESC)
  {
    if(currentMode == "newGame")
    {
       
       wait = true;
       previousMode = "newGame";
       currentMode = "exitGame";
    }
    else if(currentMode == "Menu")
    {
       wait = true;
       previousMode = "Menu";
       currentMode = "exitGame";
    }
  }
  if(keyCode == ENTER)
  {
    if(currentMode == "newGame" && displayScoreCard == true)
    {
       displayScoreCard = false;
       if(currentHole < holeLimit + 1)
       {
          buildTheNewHole();
       }
       else 
       {
          currentHole = 1;
          strokes = 0;
          strokeTotal = 0;
          parTotal = 0;
          scoreCard.clearScoreCard();
          currentMode = "Menu";
       }
    } 
  }
}





public void checkIfMousePressedGame()
{
    if(currentMode == "newGame" && displayScoreCard == false)
    {
    if(wait == false && ballHitFSM == 0)
    {
      ballHitFSM = 1;
    }
    else if(wait == false && ballHitFSM == 1)
    {
      
      //Decide how far the ball should move when hit
      
      float num = randomGaussian();
      float sd = 5;
      
      
      for(int x = 0; x < 10; x++)
      {
        if(typeOfClub == x)
        {
           //mean = ((x+1) * random(15, 25));
           mean = ((ballPower / 4) * (x+1));
           println(mean);
           sd = random(1, 2);
        } 
        else if(typeOfClub == 0)
        {
           mean = ((ballPower / 4) * (0+1));
           println(mean);
           sd = 1;
        }
      }
      
      
      
      
      
      
      
      amountToMove = (sd * num) + mean;
      
      
      
      
      
      
      //Reset amountMoved since the ball is going to move again
      amountMoved = 0;
      
     
      
      //Set current position, reset velocity, set mousePosition when clicked, get direction, set direction to acceleration//
      
      position = new PVector(playerBallXPos, (playerBallYPos / height) + 415);
      velocity = new PVector(0,0);
      mousePos = new PVector(mouseX, mouseY - 50);
      
      //println("mouseY: " + mousePos.y + " Pos: " + position.y);
      dir = PVector.sub(mousePos, position);
      dir.normalize();
      accel = dir.get();
      
      playerBallPreviousPos = new PVector(playerBallXPos, playerBallYPos);
      
      ballHitFSM = 2;    //Hit the dang thing
      
      //ballPlayer.prevXpos = ballPlayer.xPos;
      //ballPlayer.prevYpos = ballPlayer.yPos;
    }
    else
    {
       wait = false; 
    }
    }
}
class Foliage
{
  ArrayList<PShape> foliageGroup;
  ArrayList<PVector> foliageLocations;
  
  PShape treeShapeGroup;
  PShape leaves;
  PShape stumps;
  
  float xPosCenter;
  float yPosCenter;
  float radius;
  
  float drawingXPos;
  float drawingYPos;
  
  float xOffsetSize, yOffsetSize;
  
  float time = 0;
  
  int numberOfTrees;
  
  float xPosOffset;
  float yPosOffset;
  Foliage(float x, float y, float rad, int treeNum)
  {
     xPosCenter = x;
     yPosCenter = y;
     radius = rad;
     numberOfTrees = treeNum;
     foliageGroup = new ArrayList<PShape>();
     foliageLocations = new ArrayList<PVector>();
     
     buildBasicShape();
     buildFoliage();
     
     time = random(0,15);
  } 
  
  public void buildBasicShape()
  {
     leaves = createShape();
     leaves.beginShape();
       leaves.vertex(15, 0);
       leaves.vertex(0, 30);
       leaves.vertex(30, 30);
     leaves.endShape(CLOSE);
     leaves.setFill(color(0xff135410));
     
     stumps = createShape(RECT, 10, 15, 10, 20);
     stumps.setFill(color(0xff82781B));
     
     treeShapeGroup = createShape(GROUP);
     treeShapeGroup.addChild(stumps);
     treeShapeGroup.addChild(leaves);
     
     treeShapeGroup.setStroke(false);
     
     
     
     
  }
  
  public void buildFoliage()
  {
     xOffsetSize = random(50, 150);
     yOffsetSize = random(50, 150);
     xPosOffset = random(-100, 100) + xPosCenter;
     yPosOffset = random(-100, 100) + yPosCenter;
     for(int x = 0; x < numberOfTrees; x++)
     {
       radius = map(radius, 0, 1, 0, width);      //Remap the radius
       radius = noise(time) + random(0.08f, 0.1f);  //Randomize the radius on each vertex to draw for organic feeling
       
       //Randomize the scale to give some more variation in the perlin generated noise to offset the consistency in the perlin curve
       int randomXScale = PApplet.parseInt(random(xOffsetSize - 5, xOffsetSize + 5));
       int randomYScale = PApplet.parseInt(random(yOffsetSize - 5, yOffsetSize + 5));
       
       //Create the next vertex from the origin outwards
       //Angle based on edge complexity
       //Change positions based on the perlin random radius and a little variation using the random(X/Y)scale variables
       //Increment the time on the perlin noise
       drawingXPos = cos(radians((360 / numberOfTrees) * x)) * radius * randomXScale; 
       drawingYPos = sin(radians((360 / numberOfTrees) * x)) * radius * randomYScale;
       //terrainShape.vertex(drawingXPos, drawingYPos);
       println(drawingXPos + " |||| " + drawingYPos);
       foliageGroup.add(treeShapeGroup);
       foliageLocations.add(new PVector(drawingXPos, drawingYPos));
       
       time += 0.05f;
     }
  }
  
  public void displayFoliage()
  {
    pushMatrix();
      translate(xPosOffset, yPosOffset);
      for(int x = 0; x < foliageGroup.size(); x++)
      {
         shape(foliageGroup.get(x), foliageLocations.get(x).x, foliageLocations.get(x).y);
      }
    popMatrix();
  }
}
//This class will get more complex as I build the game later after the project is due//
class HUD
{
  int yardsToHole;
  int power;
  int windSpeed;
  
  String [] clubName = {"Putter", "Sand Wedge", "9 Iron", "8 Iron", "7 Iron", "6 Iron", "5 Iron", "4 Iron", "3 Iron", "Driver"};
  
  
  ArrayList<arrowDriver> arrows;
  
  Snow[]flakes;
  
  float timeDisplayOB = 0;
  
  HUD()
  {
     yardsToHole = PApplet.parseInt(playerBallYPos / 10);
     arrows = new ArrayList<arrowDriver>();
     buildArrows();
     
     flakes = new Snow[100];
     for(int x = 0; x < flakes.length; x++)
     {
       flakes[x] = new Snow(random(0,width), random(0,height), random(1,5), random(3,6));
     }
  } 
  
  
  public void buildArrows()
  {
    arrows.add(new arrowDriver(42.5f, 647));
    arrows.add(new arrowDriver(140, 650));
  }
  
  
  public void display()
  {
     displayYards(); 
     displayClub();
     displayPower();
     displayStrokes();
     
     if(ballsScaling == 0 || ballsScaling == 3)
     {
       stroke(235);
       line(playerBallXPos, (playerBallYPos / height) + 475, mouseX, mouseY);
       noStroke();
     }
     
     if(mapToBeGenerated == 3)
     {
       displaySnow();
     }
     
  }
  
  public boolean displayOB()
  {
      timeDisplayOB += 0.1f;
      if(timeDisplayOB < 5)
      {
         fill(235);
         textAlign(CENTER);
         textSize(30);
         text("Out of Bounds", width/2, height/2);
         return false;
      }
      else if(timeDisplayOB >= 5)
      {
          timeDisplayOB = 0;
          return true;
      }
      else
      {
          return false;
      }
      
  }
  
  public void displaySnow()
  {
     for(int x = 0; x < flakes.length; x++)
     {
       flakes[x].display();
     }
  }
  public void displayStrokes()
  {
    textAlign(RIGHT);
    textSize(30);
    fill(235);
    text("[Hole " + currentHole + "] Par " + numStrokesHole, width - 60, 35);
    if(strokes > numStrokesHole)
    {
      if(strokes <= numStrokesHole + 1)
      {
        fill(0xffB5A726);
      }
      else if(strokes <= numStrokesHole + 2)
      {
        fill(0xffDB4F26);
      }
      else if(strokes > numStrokesHole + 2)
      {
        fill(0xffDB2D26);
      }
    }
    else
    {
       fill(235); 
    }
    textSize(20);
    text("Stroke " + strokes, width - 62.5f, 65);
  }
  
  
  public void displayPower()
  {
     textAlign(RIGHT);
     textSize(30);
     fill(235);
     text("Power", width - 62.5f, height - 50);
     if(ballPower < 25)
     {
       fill(0xff5BA726);
     }
     else if(ballPower < 50)
     {
       fill(0xffB5A726);
     }
     else if(ballPower < 75)
     {
       fill(0xffDB4F26);
     }
     else
     {
         fill(0xffDB2D26);
     }
     
     rect(width - 62.5f, height - 40, -ballPower * 2, 25);
     fill(235);
     textSize(20);
     text(PApplet.parseInt(ballPower) + "", width - 62.5f, height - 20);
     
  }
  
  
  public void displayYards()
  {
     textAlign(LEFT);
     yardsToHole = PApplet.parseInt(playerBallYPos / 10);
     fill(235);
     textSize(30);
     text("Yards Left", 50, 35); 
     textSize(20);
     text(yardsToHole + " yds", 50, 65); 
  }
  
  
  public void displayClub()
  {
      fill(235);
      textSize(30);
      textAlign(LEFT);
      text("Club", 62.5f, height - 50);
      textSize(20);
      textAlign(CENTER);
      text(clubName[typeOfClub] + "", 95, height - 20);
      
      for(int x = 0; x < arrows.size(); x++)
      {
         //Left Arrow
         if(x == 0)
         {
           arrows.get(x).display();
         }
         //Right Arrow
         else
         {
           
           pushMatrix();
           translate(152.5f, 672);
           rotate(radians(180));
           arrows.get(x).display(0, 0);
           popMatrix();
         }
      }
  }
  
  public void checkIfClickedArrow()
  {
     for(int x = 0; x < arrows.size(); x++)
     {
        if(mouseX >= arrows.get(x).xPos && mouseX <= arrows.get(x).xPos + arrows.get(x).xSize && mouseY >= arrows.get(x).yPos && mouseY <= arrows.get(x).yPos + arrows.get(x).ySize)
        {
          wait = true;
            if(x == 0)
            {
                typeOfClub--;
                if(typeOfClub < 0)
                {
                   typeOfClub = 0; 
                }
            }
            else if(x == 1)
            {
                typeOfClub++;
                if(typeOfClub > clubName.length - 1)
                {
                   typeOfClub = clubName.length - 1; 
                }
            }
        }
     } 
     
  }
  
  public void checkIfMouseMoved()
  {
     for(int x = 0; x < arrows.size(); x++)
     {
        if(mouseX >= arrows.get(x).xPos && mouseX <= arrows.get(x).xPos + arrows.get(x).xSize && mouseY >= arrows.get(x).yPos && mouseY <= arrows.get(x).yPos + arrows.get(x).ySize)
        {
          arrows.get(x).hovering(true);
        }
        else
        {
          arrows.get(x).hovering(false);
        }
     }
  }
  
}
//Class for building the hole on the green//

class Hole
{
  float xPos;
  float yPos;
  float size;
  
  //PShapes for the flag object//
  PShape hole;
  PShape flag;
  PShape flagPole;
  PShape holeGroup;
  
  //flagWind will end up scaling the flag to give illusion of wind movement on the flag itself (SEPARATELY)
  float flagWind;
  float time = 0;
  
  Hole(float x, float y)
  {
     size = 20;
     xPos = x;
     yPos = y;
     buildHole();
     
  } 
  
  public void buildHole()
  {
     hole = createShape(ELLIPSE, 0, 40, size, size / 1.5f);
     hole.setFill(color(50));
     /*
     flag = createShape();
     flag.beginShape();
       flag.vertex(size/2,0);
       flag.vertex(size + 2, 10);
       flag.vertex(size/2, 20);
     flag.endShape(CLOSE);
     flag.setFill(color(#FF352D));
     */
     flagPole = createShape(RECT, size/2 - 2, -1, 3, 46);
     flagPole.setFill(color(200));
     holeGroup = createShape(GROUP);
     holeGroup.addChild(hole);
     //holeGroup.addChild(flag);
     holeGroup.addChild(flagPole);
     holeGroup.setStroke(false);
  }
  
  public void displayHole()
  {
     moveFlag();
     shape(holeGroup, xPos, yPos);
  }
  
  //Make the flag ITSELF be affected by the Perlin generated wind
  public void moveFlag()
  {
     flagWind = map(flagWind, 0, 1, 0, width);
     flagWind = noise(time);
     holeGroup.removeChild(2);
     flag = createShape();
     flag.beginShape();
       flag.vertex(size/2,0);
       flag.vertex((size + flagWind) * random(-flagWind / 2, -flagWind/3), 10);    //Scale in x direction to simulate wind on FLAG itself
       flag.vertex(size/2, 20);
     flag.endShape(CLOSE);
     flag.setFill(color(0xffFF352D));
     holeGroup.addChild(flag);
     time+=0.05f;
  }
}
//BUILD THE LEVEL FOR THE GAME//

class LevelGenerator
{
  //Terrain terrainTest;
  int numberOfStrokes;      //How many strokes is this hole being generated
  int numberOfPropsY;       //Number of props or terrains will be impacted by number of strokes
  
  //Probabilities to generate hazards or props//
  float probabilityOfWaterHazards;
  float probabilityOfBunkers;
  float probabilityOfFoliage;    //Trees not yet implemented
  
  //Number of fairway objects is also impacted by numberOfStrokes
  int numberOfFairwayPatches;
  
  //ArrayList to store all props or terrains
  ArrayList<Terrain> terrainList;
  ArrayList<Foliage> foliageList;
  
  //ball object that will point to the ball object in the Terrain class being used by the GreenWithHole subclass
  PlayerBall ball;
  
  
  int holeGreenCol;
  int fairwayCol;
  int bunkerCol;
  int waterCol;
  int roughCol;
  
  
  
  LevelGenerator(int numStrokes)
  {
     //terrainTest = new Terrain(50, 300, 150, 200, 200, color(#2BBA22));
     numberOfStrokes = numStrokes;
     
     
     terrainList = new ArrayList<Terrain>();
     foliageList = new ArrayList<Foliage>();
     
     chooseColorPalette();
     calculateProbabilities();
     buildTerrain();
     
     
  
     
  } 
  
  public ArrayList<Terrain> terrainListReturn()
  {
     return  terrainList;
  }
 
  
  public void chooseColorPalette()
  {
    switch(mapToBeGenerated)
    {
       //WATERING PLAINS
       case 0:
          holeGreenCol = color(0xff30D127);
          fairwayCol = color(0xff2BBA22);
          bunkerCol = color(0xffE8C188);
          waterCol = color(0xff3366E8);
          roughCol = color(0xff208C1A);
          break;
       //SANDY PEAKS
       case 1:
          holeGreenCol = color(0xff7DBA3A);
          fairwayCol = color(0xffB7BA3A);
          bunkerCol = color(0xffE8C188);
          waterCol = color(0xff1E5BCF);
          roughCol = color(0xff878A2B);
          break;
       //GRASSY KNOLL
       case 2:
          holeGreenCol = color(0xff56C114);
          fairwayCol = color(0xff5FD822);
          bunkerCol = color(0xffE8C188);
          waterCol = color(0xff3366E8);
          roughCol = color(0xff22B147);
          break;
       //CHILLY SHORES
       case 3:
          holeGreenCol = color(0xff37E080);
          fairwayCol = color(0xff63E080);
          bunkerCol = color(0xffC1BA90);
          waterCol = color(0xff5382E0);
          roughCol = color(0xffA0D7E0);
          break;
       default:
          holeGreenCol = color(0xff30D127);
          fairwayCol = color(0xff2BBA22);
          bunkerCol = color(0xffE8C188);
          waterCol = color(0xff3366E8);
          roughCol = color(0xff208C1A);
          break;
    } 
    
    trackColorWater = waterCol;
    
    
    for(Terrain t : terrainList)
    {
        switch(t.typeOfTerrain)
        {
           case 0:
             t.changeFillCol(fairwayCol);
             break;
           case 1:
             t.changeFillCol(holeGreenCol);
             break;
           case 2:
             t.changeFillCol(waterCol);
             break;
           case 3:
             t.changeFillCol(bunkerCol);
             break;
              
        }
    }
  }
 
  //BUILD ALL THE TERRAINS TO BE USED
  public void buildTerrain()
  {
     
     
     //Build the Green
     
     terrainList.add(new GreenWithHole(holeGreenCol));
     
     //Build Fairway
     for(int y = 1; y < numberOfFairwayPatches + 1; y++)
     {
         int xPosition = PApplet.parseInt(terrainList.get(y-1).getXOffset());
         terrainList.add(new Fairway(xPosition, y, random(200, 300), random(300, 600), random(0,10), fairwayCol));
         
     }
     
     //Build the various hazards THEN the Tee at the end
     for(int y = 1; y < numberOfPropsY + 1; y++)    //Number of Props ends up being the length of the course basically
     {
       for(int x = 0; x < 3; x++)
       {
         //This tries to limit the number of props near the Tee
         if(y < numberOfPropsY - 6)
         {
           //Randomly generate a probability variable to be compared to
           float probability = random(0,1);
           //println(probability);
           
           //Generate a water hazard?
           if(probability < probabilityOfWaterHazards)
           {
             terrainList.add(new WaterHazard(x, y, random(200, 800), random(200, 800), waterCol));
             x = 3;
           }
           
           //Generate a bunker?
           else if(probability < probabilityOfBunkers)
           {
             terrainList.add(new Bunker(x, y, random(100, 200), random(100, 200), bunkerCol));
             x = 3;
           }
           
           //Generate a group of trees?
           //TREES HAVE NOT YET BEEN IMPLEMENTED YET
           else if(probability < probabilityOfFoliage)
           {
               //foliageList.add(new Foliage(x * random(1, 3), y * 3, random(100, 200), int(random(10,30))));
               
           }
           
           //Otherwise ignore
           else
           {
               
           }
         }
       }
       
       
       //Build the Tee
       if(y == numberOfPropsY)
       {
         terrainList.add(new Tee(random(100, width - 100), y, random(100, 200), random(100, 200), holeGreenCol));
         ball = terrainList.get(terrainList.size() - 1).ball;
       }
     }
     
  }
  
  //Display the map after everthing has been pre-built
  public void displayTerrain()
  {
      background(roughCol);
      
      for(int x = 1; x < terrainList.size() - 1; x++)
      {
         terrainList.get(x).display(); 
      }
      /*
      for(Foliage f : foliageList)
      {
        f.displayFoliage();
      }
      */
      terrainList.get(0).display(); 
      terrainList.get(terrainList.size() - 1).display();
      
      
  }
  
  
  //Calculate the possibility of generating certain land features based on the number of strokes
  public void calculateProbabilities()
  {
     if(numberOfStrokes == 3)
     {
         probabilityOfWaterHazards = 0.2f;
         probabilityOfBunkers = 0.5f;
         probabilityOfFoliage = 1.0f;
         numberOfFairwayPatches = 3;
         numberOfPropsY = 10;
     }
     else if(numberOfStrokes == 4)
     {
         probabilityOfWaterHazards = 0.2f;
         probabilityOfBunkers = 0.3f;
         probabilityOfFoliage = 1.0f;
         numberOfFairwayPatches = 5;
         numberOfPropsY = 15;
     }
     else if(numberOfStrokes == 5)
     {
         probabilityOfWaterHazards = 0.25f;
         probabilityOfBunkers = 0.5f;
         probabilityOfFoliage = 1.0f;
         numberOfFairwayPatches = 8;
         numberOfPropsY = 20;
     }
  }
  
  //RETURNS BACK TO THE MAIN CLASS
  public PlayerBall getPlayerBall()
  {
     return ball; 
  }
  
  
}
//MAIN MENU//

class Menu
{
  
   PShape mainMenu;
   PShape buttonsMenu;
   PShape previewWindow;
   
   
   ArrayList<MenuButtons> menuButtons;    //List of buttons on menu screen
   
   float menuButtonsOffsetX = 50;
   float menuButtonsOffsetY = height/2 - 80;
   
   
   PShape changeMap;                      //The rectangle for the arrows
   ArrayList<PShape> mapChangeArrow;      //The arrows
   
   
   ArrayList<PImage> imagesForMenu;          //Background Images
   ArrayList<PImage> previewImagesForMenu;   //Preview Images
   
   //Map Selected
   int currentMapSelected = 0;
   String currentLevelName = "Watering Plains";
   
   
   Menu()
   {
     //Build the Menu features
     buildButtonMenu();
     buildMapChanger();
     
     buildBackground();
     buildPreview();
   } 
   
   public void display()
   {
     //Display the menu features
     displayBackground();
     displayButtonMenu();
     displayMapChanger();
     displayPreviewImage();
   }
   
   //Display preview image based on map selection
   public void displayPreviewImage()
   {
      
      image(previewImagesForMenu.get(currentMapSelected), 845, 140, 395, 250);
   }
   
   //Change background image based on map selection
   public void buildBackground()
   {
     imagesForMenu = new ArrayList<PImage>();
     for(int x = 0; x < 4; x++)
     {
        imagesForMenu.add(loadImage("images/golf" + x + ".jpg")); 
     }
   }
   //Change preview image based on map selection
   public void buildPreview()
   {
     previewImagesForMenu = new ArrayList<PImage>();
     for(int x = 0; x < 4; x++)
     {
        previewImagesForMenu.add(loadImage("images/golfPreview" + x + ".jpg")); 
     }
   }
   
   //Display background image based on map selection and rename the map in the map selection
   public void displayBackground()
   {
       switch(currentMapSelected)
       {
          case 0:
            background(imagesForMenu.get(0));
            currentLevelName = "Watering Plains";
            break;
          case 1:
            background(imagesForMenu.get(1));
            currentLevelName = "Sandy Peaks";
            break;
          case 2:
            background(imagesForMenu.get(2));
            currentLevelName = "Grassy Knoll";
            break;
          case 3: 
            background(imagesForMenu.get(3));
            currentLevelName = "Chilly Shores";
            break;
          default:
            background(235);
            break;
       }
       
   }
   
   //Build the arrows and make them work
   public void buildMapChanger()
   {
     changeMap = createShape(RECT, 0, 0, width/3.25f, 100);
     changeMap.setFill(color(0xff29B521));
     changeMap.setStroke(false);
     mapChangeArrow = new ArrayList<PShape>();
     for(int x = 0; x < 2; x++)
     {
       mapChangeArrow.add(createShape());
       mapChangeArrow.get(x).beginShape();
         mapChangeArrow.get(x).vertex(0, 25);
         mapChangeArrow.get(x).vertex(25,0);
         mapChangeArrow.get(x).vertex(25,50);
       mapChangeArrow.get(x).endShape(CLOSE);
       mapChangeArrow.get(x).setFill(0xff1C7A17);
       mapChangeArrow.get(x).setStroke(false);
     }
   }
   
   
   //Display the arrows and map changer
   public void displayMapChanger()
   {
      shape(changeMap, width - (width/2.95f), 440);
      for(int x = 0; x < mapChangeArrow.size(); x++)
      {
         //Left Arrow
         if(x == 0)
         {
           shape(mapChangeArrow.get(x), width - (width/2.95f) + 25, 465);
         }
         //Right Arrow
         else
         {
           pushMatrix();
           translate(width - (width/2.95f) + 370, 515);
           rotate(radians(180));
           shape(mapChangeArrow.get(x), 0, 0);  
           popMatrix();
         }
      }
      textAlign(CENTER);
      textSize(36);
      fill(235);
      text(currentLevelName, width - (width/3.25f) + 155, 500);
   }
   
   //Build the buttons on the menu
   public void buildButtonMenu()
   {
     
     menuButtons = new ArrayList<MenuButtons>();
     buttonsMenu = createShape(RECT, 0, -140, width/2, 400);
     buttonsMenu.setFill(color(0xff29B521));
     
     for(int y = 0; y < 4; y++)
     {
         menuButtons.add(new MenuButtons(menuButtonsOffsetX + 20, (y * 60) + menuButtonsOffsetY + 10, width/2.15f, 50, y));
         
     }
   }
   
   
   //Display the buttons on the menu
   public void displayButtonMenu()
   {
     pushMatrix();
     translate(menuButtonsOffsetX, menuButtonsOffsetY);
      buttonsMenu.setStroke(false);
      shape(buttonsMenu);
     popMatrix();
     fill(235);
     textAlign(CENTER);
     textSize(36);
     text("Processing Golf", menuButtonsOffsetX + ((width/2)/2), menuButtonsOffsetY - 35);
     for(int y = 0; y < 4; y++)
     {
       menuButtons.get(y).display();
         
     }
     
     
     
   }
   
   //Check for interaction
   public void checkIfMouseMoved()
   {
     //Check which button is hovered if any and add a hovering effect, and if clicked do something
      for(MenuButtons b : menuButtons)
      {
        if(mouseX >= b.xPos && mouseX <= b.xPos + b.widthOfButton && mouseY >= b.yPos && mouseY <= b.yPos + b.heightOfButton)
        {
           b.hover(true);
           //println("Hovering");
           if(mousePressed)
           {
               switch(b.menuOptionNum)
               {
                  case 0:
                     currentMode = "newGame";
                     previousMode = "newGame";
                     
                     levelGenerator.chooseColorPalette();
                     loadGame = false;
                     break;
                  case 1:
                     currentMode = "newGame";
                     previousMode = "newGame";
                     
                     levelGenerator.chooseColorPalette();
                     loadGame = true;
                     break;
                  case 2:
                     //currentMode = "options";
                     break;
                  case 3:
                     previousMode = "Menu";
                     currentMode = "exitGame";
                     break;
                  default:
                     break; 
               }
           }
        } 
        else
        {
           b.hover(false); 
        }
      }
      //If hovering on left arrow
      if(mouseX >= width - (width/2.95f) + 25 && mouseX <= width - (width/2.95f) + 50 && mouseY >= 465 && mouseY <= 515)
      {
        mapChangeArrow.get(0).setFill(0xff32FF5E);
        
      }
      else
      {
        mapChangeArrow.get(0).setFill(0xff1C7A17);
      }
      
      //If hovering on right arrow
      if(mouseX >= width - (width/2.95f) + 345 && mouseX <= width - (width/2.95f) + (width/3.25f) - 25 && mouseY >= 465 && mouseY <= 515)
      {
         mapChangeArrow.get(1).setFill(0xff32FF5E);
        
      }
      else
      {
          mapChangeArrow.get(1).setFill(0xff1C7A17);
      }
   }
   
   
   
   public void checkIfMouseClicked()
   {
     //Left Button, change map
     if(mouseX >= width - (width/2.95f) + 25 && mouseX <= width - (width/2.95f) + 50 && mouseY >= 465 && mouseY <= 515)
      {
         currentMapSelected--;
         if(currentMapSelected < 0)
         {
            currentMapSelected = 3; 
         }
      } 
     //Right Button, change map
      else if(mouseX >= width - (width/2.95f) + 345 && mouseX <= width - (width/2.95f) + (width/3.25f) - 25 && mouseY >= 465 && mouseY <= 515)
      {
         currentMapSelected++;
         if(currentMapSelected > 3)
         {
            currentMapSelected = 0; 
         }
      }
      mapToBeGenerated = currentMapSelected;
     
   }
}
//Buttons on the Main Menu

class MenuButtons
{
  float xPos;
  float yPos;
  float widthOfButton;
  float heightOfButton;
  
  PShape button;
  
  int notHovering;
  int hovering;
  
  String nameOfButton;
  
  int menuOptionNum;
  
  
   MenuButtons(float x, float y, float w, float h, int titleIncrement)
  {
     xPos = x;
     yPos = y;
     widthOfButton = w;
     heightOfButton = h;
     
     notHovering = color(0xff28AD20);
     hovering = color(0xff32FF5E);
     
     menuOptionNum = titleIncrement;
     
     button = createShape(RECT, xPos, yPos, widthOfButton, heightOfButton);
     button.setFill(notHovering);
     button.setStroke(false);
     
     //Change name displayed on the button
     if(titleIncrement == 0)
     {
       nameOfButton = "New Game";
     }
     else if(titleIncrement == 1)
     {
       nameOfButton = "Continue Game";
     }
     else if(titleIncrement == 2)
     {
        nameOfButton = "Options";
     }
     else if(titleIncrement == 3)
     {
       nameOfButton = "Exit Game";
     }
     else
     {
         nameOfButton = "Error O.B.";
     }
  } 
  
  //Display the button
  public void display()
  {
     shape(button);
     textAlign(LEFT);
     fill(235);
     textSize(26);
     text(nameOfButton, xPos + 20, yPos + 35);
     textAlign(CENTER);
     textSize(36);
  }
  
  
  //Add hover color effect
  public void hover(boolean hovering)
  {
    if(hovering)
    {
        button.setFill(color(0xff2EED58));
    }
    else
    {
        button.setFill(notHovering);
    }
  }
  
  
  
}
//The player's golf ball

class PlayerBall
{
  //The INITIAL positions
  float xPosInitial;
  float yPosInitial;
  
  
  int ballColor;
  
  //The position of the ball
  float xPos;
  float yPos;
  
  //The ball shape
  PShape ball;
  
  //Scaling for ball z movement animation
  //int scale = 0; //0 = No scale, 1 = Scale Up, 2 = Scale Down
  float scaleFactor = 0.00001f;
  
  float prevXPos;
  float prevYPos;
  
  float ballSize = 10;
  
  
  
  PlayerBall(float x, float y)
  {
     xPosInitial = x;
     yPosInitial = y;
     ballColor = color(255);
     ball = createShape(ELLIPSE, -5, -5, ballSize, ballSize);
     ball.setFill(ballColor);
     ball.setStroke(false);
     xPos = xPosInitial;
     yPos = yPosInitial;
  } 
  
  
  public void display()
  {
    //No scaling
    if(ballsScaling == 0 || ballsScaling == 3 && displayScoreCard == false)
    {
        shape(ball, xPos, yPos);
        
    }
    //Scale the ball UP for Upwards movement
    else if(ballsScaling == 1)
    {
        pushMatrix();
           translate(xPos, yPos);
           scale(scaleFactor);
           shape(ball, 0, 0); 
        popMatrix(); 
        
        
        scaleFactor++;
    }
    //Scale the ball DOWN for Downwards movement
    else if(ballsScaling == 2)
    {
        pushMatrix();
           translate(xPos, yPos);
           scale(-scaleFactor);
           shape(ball, 0, 0); 
        popMatrix(); 
        scaleFactor--;
        
        if(scaleFactor < 0)
        {
           ballsScaling = 3; 
        }
        
    }
    
    
     
     //Feed the main class the position values
     playerBallYPos = yPos;
     playerBallXPos = xPos;
  }
  
  
  public boolean checkForCollisionHole(PVector positionOfHole, float radiusOfHole)
  {
    if(ballsScaling == 3)
    {
     //println("Collision");
     float distanceX = positionOfHole.x  - xPos;
     float distanceY = (positionOfHole.y  - yPos) + 40;
      
     float distance = sqrt((distanceX * distanceX) + (distanceY * distanceY));
     
     if(((radiusOfHole) + (ballSize + 10)) > distance)
     {
       println("Collision");
       strokes++;
       return true;
     }
     else
     {
      
       return false;
     }
     
    }
    else
    {
       
       return false; 
    }
  }
  
  
  

}
class ScoreCard
{
  ArrayList<ScoreCardSection> scoreRows;
  ScoreCard()
  {
    scoreRows = new ArrayList<ScoreCardSection>();
  }
  
  public void update(int lastHoleStrokeNum, int strokesEarned)
  {
    parTotal += numStrokesHole;
    scoreRows.add(new ScoreCardSection(lastHoleStrokeNum, strokesEarned, currentHole));
  }
  
  public void display()
  {
      fill(235);
      textAlign(CENTER);
      text("Score Card", width/2, 20);
      for(ScoreCardSection s : scoreRows)
      {
         s.display(); 
      }
      text("Total Strokes                                               Par: " + parTotal + "                                     Your Total Strokes: " + strokeTotal, 200, (scoreRows.size() + 2) * 30);
      if(currentHole <= holeLimit)
      {
        text("Press Enter to Continue to Next Hole", 200, (scoreRows.size() + 3) * 30);
      }
      else if(currentHole == holeLimit + 1)
      {
        text("Press Enter to Return to Main Menu", 200, (scoreRows.size() + 3) * 30);
      }
  }
  
  public void clearScoreCard()
  {
      scoreRows.clear();
  }
}

class ScoreCardSection
{
  PVector position;
  int backgroundColorScores;
  int foregroundColorScores;
  int holeStrokeLimit;
  int holeStrokeEarned;
  
  int holeNumber;
  
  float sizeY;
  PShape backgroundRect;
  
  ScoreCardSection(int sLim, int sEarned, int holeNum)
  {
     sizeY = 25;
     backgroundColorScores = color(0xff3D994D);
     foregroundColorScores = color(235);
     
     holeStrokeLimit = sLim;
     holeStrokeEarned = sEarned;
     
     holeNumber = holeNum;
     
     position = new PVector(150, holeNumber * (sizeY + 5));
     
     backgroundRect = createShape(RECT, 0, 0, width - 300, sizeY);
     backgroundRect.setFill(backgroundColorScores);
  } 
  
  public void display()
  {
      fill(foregroundColorScores);
      
      shape(backgroundRect, position.x, position.y + 10);
      textAlign(LEFT);
      text("Hole " + holeNumber + "                                                          Par: " + holeStrokeLimit + "                                                Your Strokes: " + holeStrokeEarned, position.x + 50, position.y + 30);
      
  }
}
class Snow
{
  float xPos;      //X Location
  float yPos;      //Y Location
  float size;      //Size
  float speed;     //Speed
  float col;       //Brightness of flakes
  int yDir;        //Y Direction
  Snow(float x, float y, float scale, float s)
  {
    xPos = x;
    yPos = y;
    size = scale;
    speed = s;
    yDir = 1;
    col = 255;
  }
  
  public void move()
  {
    yPos += yDir*speed;
    if(yPos > height)    //IF FLAKE GOES OFF THE SCREEN BRING IT BACK UP TO THE TOP OF THE SCREEN TO CREATE A LOOPING BACKGROUND EFFECT
    {
       yPos = 0; 
    }
  }
  
  public void shimmer()
  {
    col += random(-5,5);        //ADD A SHIMMERING EFFECT TO THE FLAKE BY RANDOMIZING THE BRIGHTNESS
    
    if(col > 100)      //MAKE SURE THE SNOW CAPS AT 100
    {
       col = 100; 
    }
    else if(col < 75)    //MAKE SURE THE SNOW CAPS AT 75
    {
       col = 75; 
    }
  }
  
  public void display()
  {
     move();
     shimmer();
     noStroke();
     colorMode(HSB, 360, 100, 100);
     fill(0,0,col);
     ellipse(xPos, yPos, size, size);
     colorMode(RGB, 255, 255, 255);
  }
  
  
}
//Parent
class Terrain
{
  PShape terrainShape;    //The shape of the object
  
  float drawingXPos = 0;  //The X position to draw the next vertex
  float drawingYPos = 0;  //Y position
  
  
  float xPosOffset = 50;
  float yPosOffset = 50;
  
  
  float time = 0;      //For the perlin noise generation
  
  float randomRotation;  //Add some variation in rotation to give more randomness
  
  float radius = 30;    //The radius to draw at
  
  
  int edgeNumber;                  //Edge Complexity of the terrain
  float xOffsetSize, yOffsetSize;
  
  int fillColor = color(0xff2BBA22);
  
  
  int typeOfTerrain = 0;
  
  PlayerBall ball;  //Ball object that is referenced in both LevelGenerator and the Main Class
  
  
  Terrain(int edgeComplexity, float sizeOfTerrainXOffset, float sizeOfTerrainYOffset, int fillCol, int type)
  {
     edgeNumber = edgeComplexity;
     xOffsetSize = sizeOfTerrainXOffset;
     yOffsetSize = sizeOfTerrainYOffset;
     fillColor = fillCol;
     typeOfTerrain = type;
     
     //Randomize the initial time to give randomness on the perlin noise curve
     time = random(0, 15);
     
     //Add some random rotation
     randomRotation = random(-30,30);
     
     //Now generate that shiz!
     randomlyGenerateTerrain();
     
  } 
  
  //Display the terrain
  public void display()
  {
    pushMatrix();
      translate(xPosOffset, yPosOffset);
      rotate(radians(randomRotation));
      terrainShape.setFill(fillColor);
      terrainShape.setStroke(false);
      shape(terrainShape);
    popMatrix();
  }
  
  
  //Generate the terrain
  public void randomlyGenerateTerrain()
  {
     //Begin the shape
     terrainShape = createShape();
     terrainShape.beginShape();
     for(int x = 0; x < edgeNumber; x++)
     {
       radius = map(radius, 0, 1, 0, width);      //Remap the radius
       radius = noise(time) + random(0.08f, 0.1f);  //Randomize the radius on each vertex to draw for organic feeling
       
       //Randomize the scale to give some more variation in the perlin generated noise to offset the consistency in the perlin curve
       int randomXScale = PApplet.parseInt(random(xOffsetSize - 5, xOffsetSize + 5));
       int randomYScale = PApplet.parseInt(random(yOffsetSize - 5, yOffsetSize + 5));
       
       //Create the next vertex from the origin outwards
       //Angle based on edge complexity
       //Change positions based on the perlin random radius and a little variation using the random(X/Y)scale variables
       //Increment the time on the perlin noise
       drawingXPos = cos(radians((360 / edgeNumber) * x)) * radius * randomXScale; 
       drawingYPos = sin(radians((360 / edgeNumber) * x)) * radius * randomYScale;
       terrainShape.vertex(drawingXPos, drawingYPos);
       time += 0.05f;
     }
     //After all vertices are built, close the shape
     terrainShape.endShape(CLOSE);
  }
  
  public float getXOffset()
  {
     return xPosOffset;
  }
  
  public void changeFillCol(int col)
  {
      fillColor = col;
  }
  
  
}




//Fairway inherits the Terrain class
class Fairway extends Terrain
{
  float randomXPosFairway;
  float randomYPosFairway;
  float rotate;
  Fairway(int xPos, int yPos, float xSize, float ySize, float rotation, int fillCol)
  {
     super(50, xSize, ySize, fillCol, 0); //Send info back to parent class constructor
     //println(xPos);
     
     //Very brute force way of keeping fairways close together and connected from the green
     if(xPos == 1)
     {
       randomXPosFairway = xPos + random(-100, 100);
     }
     else
     {
         randomXPosFairway = xPos + random(-50, 50);
     }
     randomYPosFairway = (yPos * (ySize/ 1.05f)) + random(0, 50);
     xPosOffset = randomXPosFairway;
     yPosOffset = randomYPosFairway;
     rotate = rotation;
  } 
  
  
  
}



//Golf Green inherits Terrain
class GreenWithHole extends Terrain
{
  //Random position for the green itself
  float randomXPosGreen;
  float randomYPosGreen;
  
  //The Golf Hole to be built on the green
  Hole golfHole;
  
  //Random locations within the green to place the hole
  float randomHoleLocX;
  float randomHoleLocY;
  
  GreenWithHole(int fillCol)
  {
     super(50, 300, 300, fillCol, 1);
     randomXPosGreen = random(300, width - 300);
     randomYPosGreen = PApplet.parseInt(random(100, 150));
     
     //Place the hole within +/- 25 pixels in X and Y from the green's origin
     randomHoleLocX = random(randomXPosGreen - 25, randomXPosGreen + 25);
     randomHoleLocY = random(randomYPosGreen - 25, randomYPosGreen + 25);
     golfHole = new Hole(randomXPosGreen, randomYPosGreen);
     golfHolePublic = golfHole;
     
     xPosOffset = randomHoleLocX;
     yPosOffset = randomHoleLocY;
  } 
  
  //OVERRIDE PARENT DISPLAY FUNCTION
  public void display()
  {
      terrainShape.setFill(fillColor);
      terrainShape.setStroke(false);
      shape(terrainShape, randomHoleLocX, randomHoleLocY);
      
      golfHole.displayHole();
  }
}



//WaterHazard inherits from Terrain
class WaterHazard extends Terrain
{
  float randomXPosWater;
  float randomYPosWater;
  WaterHazard(float xPos, float yPos, float xSize, float ySize, int fillCol)
  {
     super(50, xSize, ySize, fillCol, 2);
     randomXPosWater = (xPos * xSize) + random(-100, 100);
     randomYPosWater = (yPos * ySize) + PApplet.parseInt(random(100, 150));
     
     xPosOffset = randomXPosWater;
     yPosOffset = randomYPosWater;
  } 
}


//Bunker inherits from Terrain
class Bunker extends Terrain
{
  float randomXPosSand;
  float randomYPosSand;
  Bunker(float xPos, float yPos, float xSize, float ySize, int fillCol)
  {
     super(50, xSize, ySize, fillCol, 3);
     randomXPosSand = (xPos * xSize) + random(-100, 100);
     randomYPosSand = (yPos * ySize) + PApplet.parseInt(random(100, 150));
     
     xPosOffset = randomXPosSand;
     yPosOffset = randomYPosSand;
  } 
}


//Tee inherits from Terrain
class Tee extends Terrain
{
  float randomXPosTee;
  float randomYPosTee;
  Tee(float xPos, float yPos, float xSize, float ySize, int fillCol)
  {
     super(50, xSize, ySize, fillCol, 1);
     randomXPosTee = (width/2) + random(-100, 100);
     randomYPosTee = (yPos * ySize) + PApplet.parseInt(random(100, 150));
     
     xPosOffset = randomXPosTee;
     yPosOffset = randomYPosTee;
     
     
     //INSTANTIATE THE BALL AT THE TEE'S ORIGIN
     ball = new PlayerBall(randomXPosTee, randomYPosTee);
     
  } 
  
  //OVERRIDE PARENT DISPLAY FUNCTION TO ALSO DISPLAY BALL
  public void display()
  { 
     pushMatrix();
      translate(randomXPosTee, randomYPosTee);
      rotate(radians(randomRotation));
      terrainShape.setFill(fillColor);
      terrainShape.setStroke(false);
      shape(terrainShape);
     popMatrix();
     ball.display(); 
  }
}
class arrowDriver
{
  PShape arrow;
  float xPos;
  float yPos;
  
  float xSize;
  float ySize;
  
  int fillCol;
  arrowDriver(float x, float y)
  {
     xPos = x;
     yPos = y;
     //fillCol = color(235);
     buildArrow();
     
     xSize = 12.5f;
     ySize = 25;
  } 
  
  
  public void buildArrow()
  {
     arrow = createShape();
     arrow.beginShape();
       arrow.vertex(0, 12.5f);
       arrow.vertex(12.5f,0);
       arrow.vertex(12.5f,25);
     arrow.endShape(CLOSE);
     arrow.setFill(color(235));
     arrow.setStroke(false);
  }
  
  
  public void display(float xOff, float yOff)
  {
      shape(arrow, xOff, yOff);
      
     // println(xPos + " |||| " + yPos);
  }
  
  public void display()
  {
      shape(arrow, xPos, yPos);
  }
  
  public void hovering(boolean hover)
  {
    if(hover)
    {
       arrow.setFill(color(0xff32FF5E));
    }
    else
    {
       arrow.setFill(color(235));
    } 
  }
}
//The Quit Menu

class quitMenu
{
  boolean quit = false;
  boolean highLightYes = false;
  boolean highLightNo = false;
   quitMenu()
  {
     
  } 
  public void display()
  {
      fill(0,0,0,100);
      rect(0, 0, width, height);
      fill(0xff29B521);
      rectMode(CENTER);
      rect(width/2, height/2, 425, 175);
      fill(235);
      textAlign(CENTER);
      textSize(26);
      text("Are you sure you want to quit?", width/2, height/2 - 25);
      rectMode(CORNER);
      if(highLightYes)
      {
         fill(50); 
      }
      else
      {
         fill(235); 
      }
      text("Yes", width/2 - 50, height/2 + 50);
      if(highLightNo)
      {
         fill(50); 
      }
      else
      {
         fill(235); 
      }
      text("No", width/2 + 50, height/2 + 50);
      if(mouseX >= width/2 - 75 && mouseX <= width/2 - 25 && mouseY >= height/2 + 25 && mouseY <= height/2 + 50)
       {
          highLightYes = true;
          
         
       } 
       else
       {
          highLightYes = false;
       }
      if(mouseX >= width/2 + 30 && mouseX <= width/2 + 80 && mouseY >= height/2 + 25 && mouseY <= height/2 + 50)
      {
         highLightNo = true; 
         
      }
      else
      {
         highLightNo = false; 
      }
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "RandomAssignment" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
