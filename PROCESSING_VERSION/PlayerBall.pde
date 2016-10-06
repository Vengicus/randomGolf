//The player's golf ball

class PlayerBall
{
  //The INITIAL positions
  float xPosInitial;
  float yPosInitial;
  
  
  color ballColor;
  
  //The position of the ball
  float xPos;
  float yPos;
  
  //The ball shape
  PShape ball;
  
  //Scaling for ball z movement animation
  //int scale = 0; //0 = No scale, 1 = Scale Up, 2 = Scale Down
  float scaleFactor = 0.00001;
  
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
  
  
  void display()
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
  
  
  boolean checkForCollisionHole(PVector positionOfHole, float radiusOfHole)
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
       //strokes++;
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
