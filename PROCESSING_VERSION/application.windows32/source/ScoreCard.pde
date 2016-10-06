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
