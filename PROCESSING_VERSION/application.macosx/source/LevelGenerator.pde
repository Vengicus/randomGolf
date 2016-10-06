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
  
  
  color holeGreenCol;
  color fairwayCol;
  color bunkerCol;
  color waterCol;
  color roughCol;
  
  
  
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
 
  
  void chooseColorPalette()
  {
    switch(mapToBeGenerated)
    {
       //WATERING PLAINS
       case 0:
          holeGreenCol = color(#30D127);
          fairwayCol = color(#2BBA22);
          bunkerCol = color(#E8C188);
          waterCol = color(#3366E8);
          roughCol = color(#208C1A);
          break;
       //SANDY PEAKS
       case 1:
          holeGreenCol = color(#7DBA3A);
          fairwayCol = color(#B7BA3A);
          bunkerCol = color(#E8C188);
          waterCol = color(#1E5BCF);
          roughCol = color(#878A2B);
          break;
       //GRASSY KNOLL
       case 2:
          holeGreenCol = color(#56C114);
          fairwayCol = color(#5FD822);
          bunkerCol = color(#E8C188);
          waterCol = color(#3366E8);
          roughCol = color(#22B147);
          break;
       //CHILLY SHORES
       case 3:
          holeGreenCol = color(#37E080);
          fairwayCol = color(#63E080);
          bunkerCol = color(#C1BA90);
          waterCol = color(#5382E0);
          roughCol = color(#A0D7E0);
          break;
       default:
          holeGreenCol = color(#30D127);
          fairwayCol = color(#2BBA22);
          bunkerCol = color(#E8C188);
          waterCol = color(#3366E8);
          roughCol = color(#208C1A);
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
  void buildTerrain()
  {
     
     
     //Build the Green
     
     terrainList.add(new GreenWithHole(holeGreenCol));
     
     //Build Fairway
     for(int y = 1; y < numberOfFairwayPatches + 1; y++)
     {
         int xPosition = int(terrainList.get(y-1).getXOffset());
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
  void displayTerrain()
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
  void calculateProbabilities()
  {
     if(numberOfStrokes == 3)
     {
         probabilityOfWaterHazards = 0.2;
         probabilityOfBunkers = 0.5;
         probabilityOfFoliage = 1.0;
         numberOfFairwayPatches = 3;
         numberOfPropsY = 10;
     }
     else if(numberOfStrokes == 4)
     {
         probabilityOfWaterHazards = 0.2;
         probabilityOfBunkers = 0.3;
         probabilityOfFoliage = 1.0;
         numberOfFairwayPatches = 5;
         numberOfPropsY = 15;
     }
     else if(numberOfStrokes == 5)
     {
         probabilityOfWaterHazards = 0.25;
         probabilityOfBunkers = 0.5;
         probabilityOfFoliage = 1.0;
         numberOfFairwayPatches = 8;
         numberOfPropsY = 20;
     }
  }
  
  //RETURNS BACK TO THE MAIN CLASS
  PlayerBall getPlayerBall()
  {
     return ball; 
  }
  
  
}
