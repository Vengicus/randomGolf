class ScoreCard
{
  ArrayList<ScoreCardSection> scoreRows;
  ScoreCard()
  {
    scoreRows = new ArrayList<ScoreCardSection>();
  }
  
  void update(int lastHoleStrokeNum, int strokesEarned)
  {
    parTotal += numStrokesHole;
    scoreRows.add(new ScoreCardSection(lastHoleStrokeNum, strokesEarned, currentHole));
  }
  
  void display()
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
      
      /*
      String whatToSay;
      textSize(40);
      
      if(strokes == scoreRows.get(currentHole-2).holeStrokeLimit - 4 && scoreRows.get(currentHole-2).holeStrokeLimit - 4 > 0)
      {
         fill(#0C79D4);
         whatToSay = "ALBATROSS!!";
      }
      else if(strokes == scoreRows.get(currentHole-2).holeStrokeLimit - 3 && scoreRows.get(currentHole-2).holeStrokeLimit - 3 > 0)
      {
         fill(#FFFF0D);
         whatToSay = "EAGLE!";
      }
      else if(strokes == scoreRows.get(currentHole-2).holeStrokeLimit - 2)
      {
         fill(#FFE00D);
         whatToSay = "Birdie!";
      }
      else if(strokes == scoreRows.get(currentHole-2).holeStrokeLimit - 1)
      {
         fill(235);
         whatToSay = "Par!";
      }
      else if(strokes == scoreRows.get(currentHole-2).holeStrokeLimit)
      {
         fill(#F30000);
         whatToSay = "Bogey";
      }
      else if(strokes == scoreRows.get(currentHole-2).holeStrokeLimit + 1)
      {
         fill(#F30000);
         whatToSay = "Double Bogey";
      }
      else if(strokes == scoreRows.get(currentHole-2).holeStrokeLimit + 2)
      {
         fill(#F30000);
         whatToSay = "Triple Bogey";
      }
      else
      {
         fill(#F30000);
         whatToSay = "+" + (strokes - 3) + "";
      }
      println(scoreRows.get(currentHole-2).holeStrokeLimit);
      textAlign(CENTER);
      text(whatToSay + "", width/2,  (scoreRows.size() + 5) * 30);
      textAlign(LEFT);
      textSize(20);
      */
  }
  
  void clearScoreCard()
  {
      scoreRows.clear();
  }
}

class ScoreCardSection
{
  PVector position;
  color backgroundColorScores;
  color foregroundColorScores;
  int holeStrokeLimit;
  int holeStrokeEarned;
  
  int holeNumber;
  
  float sizeY;
  PShape backgroundRect;
  
  ScoreCardSection(int sLim, int sEarned, int holeNum)
  {
     sizeY = 25;
     backgroundColorScores = color(#3D994D);
     foregroundColorScores = color(235);
     
     holeStrokeLimit = sLim;
     holeStrokeEarned = sEarned;
     
     holeNumber = holeNum;
     
     position = new PVector(150, holeNumber * (sizeY + 5));
     
     backgroundRect = createShape(RECT, 0, 0, width - 300, sizeY);
     backgroundRect.setFill(backgroundColorScores);
  } 
  
  void display()
  {
      fill(foregroundColorScores);
      
      shape(backgroundRect, position.x, position.y + 10);
      textAlign(LEFT);
      text("Hole " + holeNumber + "                                                          Par: " + holeStrokeLimit + "                                                Your Strokes: " + holeStrokeEarned, position.x + 50, position.y + 30);
      
  }
}
