//The Quit Menu

class quitMenu
{
  boolean quit = false;
  boolean highLightYes = false;
  boolean highLightNo = false;
   quitMenu()
  {
     
  } 
  void display()
  {
      fill(0,0,0,100);
      rect(0, 0, width, height);
      fill(#29B521);
      rectMode(CENTER);
      rect(width/2, height/2, 425, 175);
      fill(235);
      textAlign(CENTER);
      textSize(26);
      text("Are you sure you want to quit?", width/2, height/2 - 25);
      rectMode(CORNER);
      if(highLightYes)
      {
         fill(50); 
      }
      else
      {
         fill(235); 
      }
      text("Yes", width/2 - 50, height/2 + 50);
      if(highLightNo)
      {
         fill(50); 
      }
      else
      {
         fill(235); 
      }
      text("No", width/2 + 50, height/2 + 50);
      if(mouseX >= width/2 - 75 && mouseX <= width/2 - 25 && mouseY >= height/2 + 25 && mouseY <= height/2 + 50)
       {
          highLightYes = true;
          
         
       } 
       else
       {
          highLightYes = false;
       }
      if(mouseX >= width/2 + 30 && mouseX <= width/2 + 80 && mouseY >= height/2 + 25 && mouseY <= height/2 + 50)
      {
         highLightNo = true; 
         
      }
      else
      {
         highLightNo = false; 
      }
  }
}
