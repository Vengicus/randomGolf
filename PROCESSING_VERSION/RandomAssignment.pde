//NOTES
//FIX COLLISION DETECTION --> CURRENTLY THE HOLE'S COLLISION CIRCLE IS OFFSET ABOVE HOLE
//FIX VECTOR MOVEMENT FOR MORE PRECISE CALCULATIONS


/*
  Andrew Schoolnick
  Interactive Media Development
  2-12-15
  Randomly Generated Golf Game
  2321 Lines so far
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



color trackColorWater;





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



void setup()
{
  size(1280, 720, P2D);
  frameRate(30);
  background(235);
  
  colorMode(RGB, 255, 255, 255, 100);
  
  //Object assisnment//
  mainMenu = new Menu();
  exitMenu = new quitMenu();
  
  //BUILD THE LEVEL, I put this is setup since I only really want to generate one map per game FOR NOW
  numStrokesHole = int(random(3, 6));
  levelGenerator = new LevelGenerator(numStrokesHole);
  hud = new HUD();
  
  noStroke();
  
  //Reference the player ball object from level generator which will point to the player ball object in terrain and return it back to here//
  ballPlayer = levelGenerator.getPlayerBall();
  terrainListReference = levelGenerator.terrainListReturn();
  
  
  scoreCard = new ScoreCard();
  
}

void draw()
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
void showLevel()
{
    pushMatrix();
      translate(movementLeft, -playerBallYPos + (height/1.5));    //Align camera with ball position with a slight offset, but dont move xPos
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

void moveBall()
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


void buildNewHole()
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


void buildTheNewHole()
{
      numStrokesHole = int(random(3, 6));
      levelGenerator = new LevelGenerator(numStrokesHole);
      ballPlayer = levelGenerator.getPlayerBall();
      terrainListReference = levelGenerator.terrainListReturn();
}





void checkForCollision()
{
    for(Terrain t : terrainListReference)
    {
       
    }
}


void mouseClicked()
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


void keyPressed()
{
   if (key == ESC) 
   {
     key = 0; 
   }
}

void keyReleased()
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
  
  if(keyCode == LEFT || key == 'a' || key == 'A')
  {
    if(currentMode == "newGame" && typeOfClub > 0)
    {
       typeOfClub--;
    } 
  }
  else if(keyCode == RIGHT || key == 'd' || key == 'D')
  {
    if(currentMode == "newGame" && typeOfClub < 9)
    {
       typeOfClub++;
    } 
  }
}





void checkIfMousePressedGame()
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
