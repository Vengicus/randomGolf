//Buttons on the Main Menu

class MenuButtons
{
  float xPos;
  float yPos;
  float widthOfButton;
  float heightOfButton;
  
  PShape button;
  
  color notHovering;
  color hovering;
  
  String nameOfButton;
  
  int menuOptionNum;
  
  
   MenuButtons(float x, float y, float w, float h, int titleIncrement)
  {
     xPos = x;
     yPos = y;
     widthOfButton = w;
     heightOfButton = h;
     
     notHovering = color(#28AD20);
     hovering = color(#32FF5E);
     
     menuOptionNum = titleIncrement;
     
     button = createShape(RECT, xPos, yPos, widthOfButton, heightOfButton);
     button.setFill(notHovering);
     button.setStroke(false);
     
     //Change name displayed on the button
     if(titleIncrement == 0)
     {
       nameOfButton = "New Game";
     }
     else if(titleIncrement == 1)
     {
       nameOfButton = "Continue Game";
     }
     else if(titleIncrement == 2)
     {
        nameOfButton = "Options";
     }
     else if(titleIncrement == 3)
     {
       nameOfButton = "Exit Game";
     }
     else
     {
         nameOfButton = "Error O.B.";
     }
  } 
  
  //Display the button
  void display()
  {
     shape(button);
     textAlign(LEFT);
     fill(235);
     textSize(26);
     text(nameOfButton, xPos + 20, yPos + 35);
     textAlign(CENTER);
     textSize(36);
  }
  
  
  //Add hover color effect
  void hover(boolean hovering)
  {
    if(hovering)
    {
        button.setFill(color(#2EED58));
    }
    else
    {
        button.setFill(notHovering);
    }
  }
  
  
  
}
