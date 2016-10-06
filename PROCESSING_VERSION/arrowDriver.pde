class arrowDriver
{
  PShape arrow;
  float xPos;
  float yPos;
  
  float xSize;
  float ySize;
  
  color fillCol;
  arrowDriver(float x, float y)
  {
     xPos = x;
     yPos = y;
     //fillCol = color(235);
     buildArrow();
     
     xSize = 12.5;
     ySize = 25;
  } 
  
  
  void buildArrow()
  {
     arrow = createShape();
     arrow.beginShape();
       arrow.vertex(0, 12.5);
       arrow.vertex(12.5,0);
       arrow.vertex(12.5,25);
     arrow.endShape(CLOSE);
     arrow.setFill(color(235));
     arrow.setStroke(false);
  }
  
  
  void display(float xOff, float yOff)
  {
      shape(arrow, xOff, yOff);
      
     // println(xPos + " |||| " + yPos);
  }
  
  void display()
  {
      shape(arrow, xPos, yPos);
  }
  
  void hovering(boolean hover)
  {
    if(hover)
    {
       arrow.setFill(color(#32FF5E));
    }
    else
    {
       arrow.setFill(color(235));
    } 
  }
}
