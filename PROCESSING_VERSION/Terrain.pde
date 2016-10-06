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
  
  color fillColor = color(#2BBA22);
  
  
  int typeOfTerrain = 0;
  
  PlayerBall ball;  //Ball object that is referenced in both LevelGenerator and the Main Class
  
  
  Terrain(int edgeComplexity, float sizeOfTerrainXOffset, float sizeOfTerrainYOffset, color fillCol, int type)
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
  void display()
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
  void randomlyGenerateTerrain()
  {
     //Begin the shape
     terrainShape = createShape();
     terrainShape.beginShape();
     for(int x = 0; x < edgeNumber; x++)
     {
       radius = map(radius, 0, 1, 0, width);      //Remap the radius
       radius = noise(time) + random(0.08, 0.1);  //Randomize the radius on each vertex to draw for organic feeling
       
       //Randomize the scale to give some more variation in the perlin generated noise to offset the consistency in the perlin curve
       int randomXScale = int(random(xOffsetSize - 5, xOffsetSize + 5));
       int randomYScale = int(random(yOffsetSize - 5, yOffsetSize + 5));
       
       //Create the next vertex from the origin outwards
       //Angle based on edge complexity
       //Change positions based on the perlin random radius and a little variation using the random(X/Y)scale variables
       //Increment the time on the perlin noise
       drawingXPos = cos(radians((360 / edgeNumber) * x)) * radius * randomXScale; 
       drawingYPos = sin(radians((360 / edgeNumber) * x)) * radius * randomYScale;
       terrainShape.vertex(drawingXPos, drawingYPos);
       time += 0.05;
     }
     //After all vertices are built, close the shape
     terrainShape.endShape(CLOSE);
  }
  
  float getXOffset()
  {
     return xPosOffset;
  }
  
  void changeFillCol(color col)
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
  Fairway(int xPos, int yPos, float xSize, float ySize, float rotation, color fillCol)
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
     randomYPosFairway = (yPos * (ySize/ 1.05)) + random(0, 50);
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
  
  GreenWithHole(color fillCol)
  {
     super(50, 300, 300, fillCol, 1);
     randomXPosGreen = random(300, width - 300);
     randomYPosGreen = int(random(100, 150));
     
     //Place the hole within +/- 25 pixels in X and Y from the green's origin
     randomHoleLocX = random(randomXPosGreen - 25, randomXPosGreen + 25);
     randomHoleLocY = random(randomYPosGreen - 25, randomYPosGreen + 25);
     golfHole = new Hole(randomXPosGreen, randomYPosGreen);
     golfHolePublic = golfHole;
     
     xPosOffset = randomHoleLocX;
     yPosOffset = randomHoleLocY;
  } 
  
  //OVERRIDE PARENT DISPLAY FUNCTION
  void display()
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
  WaterHazard(float xPos, float yPos, float xSize, float ySize, color fillCol)
  {
     super(50, xSize, ySize, fillCol, 2);
     randomXPosWater = (xPos * xSize) + random(-100, 100);
     randomYPosWater = (yPos * ySize) + int(random(100, 150));
     
     xPosOffset = randomXPosWater;
     yPosOffset = randomYPosWater;
  } 
}


//Bunker inherits from Terrain
class Bunker extends Terrain
{
  float randomXPosSand;
  float randomYPosSand;
  Bunker(float xPos, float yPos, float xSize, float ySize, color fillCol)
  {
     super(50, xSize, ySize, fillCol, 3);
     randomXPosSand = (xPos * xSize) + random(-100, 100);
     randomYPosSand = (yPos * ySize) + int(random(100, 150));
     
     xPosOffset = randomXPosSand;
     yPosOffset = randomYPosSand;
  } 
}


//Tee inherits from Terrain
class Tee extends Terrain
{
  float randomXPosTee;
  float randomYPosTee;
  Tee(float xPos, float yPos, float xSize, float ySize, color fillCol)
  {
     super(50, xSize, ySize, fillCol, 1);
     randomXPosTee = (width/2) + random(-100, 100);
     randomYPosTee = (yPos * ySize) + int(random(100, 150));
     
     xPosOffset = randomXPosTee;
     yPosOffset = randomYPosTee;
     
     
     //INSTANTIATE THE BALL AT THE TEE'S ORIGIN
     ball = new PlayerBall(randomXPosTee, randomYPosTee);
     
  } 
  
  //OVERRIDE PARENT DISPLAY FUNCTION TO ALSO DISPLAY BALL
  void display()
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
