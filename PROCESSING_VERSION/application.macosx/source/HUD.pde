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
     yardsToHole = int(playerBallYPos / 10);
     arrows = new ArrayList<arrowDriver>();
     buildArrows();
     
     flakes = new Snow[100];
     for(int x = 0; x < flakes.length; x++)
     {
       flakes[x] = new Snow(random(0,width), random(0,height), random(1,5), random(3,6));
     }
  } 
  
  
  void buildArrows()
  {
    arrows.add(new arrowDriver(42.5, 647));
    arrows.add(new arrowDriver(140, 650));
  }
  
  
  void display()
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
      timeDisplayOB += 0.1;
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
  
  void displaySnow()
  {
     for(int x = 0; x < flakes.length; x++)
     {
       flakes[x].display();
     }
  }
  void displayStrokes()
  {
    textAlign(RIGHT);
    textSize(30);
    fill(235);
    text("[Hole " + currentHole + "] Par " + numStrokesHole, width - 60, 35);
    if(strokes > numStrokesHole)
    {
      if(strokes <= numStrokesHole + 1)
      {
        fill(#B5A726);
      }
      else if(strokes <= numStrokesHole + 2)
      {
        fill(#DB4F26);
      }
      else if(strokes > numStrokesHole + 2)
      {
        fill(#DB2D26);
      }
    }
    else
    {
       fill(235); 
    }
    textSize(20);
    text("Stroke " + strokes, width - 62.5, 65);
  }
  
  
  void displayPower()
  {
     textAlign(RIGHT);
     textSize(30);
     fill(235);
     text("Power", width - 62.5, height - 50);
     if(ballPower < 25)
     {
       fill(#5BA726);
     }
     else if(ballPower < 50)
     {
       fill(#B5A726);
     }
     else if(ballPower < 75)
     {
       fill(#DB4F26);
     }
     else
     {
         fill(#DB2D26);
     }
     
     rect(width - 62.5, height - 40, -ballPower * 2, 25);
     fill(235);
     textSize(20);
     text(int(ballPower) + "", width - 62.5, height - 20);
     
  }
  
  
  void displayYards()
  {
     textAlign(LEFT);
     yardsToHole = int(playerBallYPos / 10);
     fill(235);
     textSize(30);
     text("Yards Left", 50, 35); 
     textSize(20);
     text(yardsToHole + " yds", 50, 65); 
  }
  
  
  void displayClub()
  {
      fill(235);
      textSize(30);
      textAlign(LEFT);
      text("Club", 62.5, height - 50);
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
           translate(152.5, 672);
           rotate(radians(180));
           arrows.get(x).display(0, 0);
           popMatrix();
         }
      }
  }
  
  void checkIfClickedArrow()
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
  
  void checkIfMouseMoved()
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
