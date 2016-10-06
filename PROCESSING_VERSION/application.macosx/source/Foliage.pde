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
  
  void buildBasicShape()
  {
     leaves = createShape();
     leaves.beginShape();
       leaves.vertex(15, 0);
       leaves.vertex(0, 30);
       leaves.vertex(30, 30);
     leaves.endShape(CLOSE);
     leaves.setFill(color(#135410));
     
     stumps = createShape(RECT, 10, 15, 10, 20);
     stumps.setFill(color(#82781B));
     
     treeShapeGroup = createShape(GROUP);
     treeShapeGroup.addChild(stumps);
     treeShapeGroup.addChild(leaves);
     
     treeShapeGroup.setStroke(false);
     
     
     
     
  }
  
  void buildFoliage()
  {
     xOffsetSize = random(50, 150);
     yOffsetSize = random(50, 150);
     xPosOffset = random(-100, 100) + xPosCenter;
     yPosOffset = random(-100, 100) + yPosCenter;
     for(int x = 0; x < numberOfTrees; x++)
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
       drawingXPos = cos(radians((360 / numberOfTrees) * x)) * radius * randomXScale; 
       drawingYPos = sin(radians((360 / numberOfTrees) * x)) * radius * randomYScale;
       //terrainShape.vertex(drawingXPos, drawingYPos);
       println(drawingXPos + " |||| " + drawingYPos);
       foliageGroup.add(treeShapeGroup);
       foliageLocations.add(new PVector(drawingXPos, drawingYPos));
       
       time += 0.05;
     }
  }
  
  void displayFoliage()
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
