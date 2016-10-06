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
  
  void buildHole()
  {
     hole = createShape(ELLIPSE, 0, 40, size, size / 1.5);
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
  
  void displayHole()
  {
     moveFlag();
     shape(holeGroup, xPos, yPos);
  }
  
  //Make the flag ITSELF be affected by the Perlin generated wind
  void moveFlag()
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
     flag.setFill(color(#FF352D));
     holeGroup.addChild(flag);
     time+=0.05;
  }
}
