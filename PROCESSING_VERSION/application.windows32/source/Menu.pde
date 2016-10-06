//MAIN MENU//

class Menu
{
  
   PShape mainMenu;
   PShape buttonsMenu;
   PShape previewWindow;
   
   
   ArrayList<MenuButtons> menuButtons;    //List of buttons on menu screen
   
   float menuButtonsOffsetX = 50;
   float menuButtonsOffsetY = height/2 - 80;
   
   
   PShape changeMap;                      //The rectangle for the arrows
   ArrayList<PShape> mapChangeArrow;      //The arrows
   
   
   ArrayList<PImage> imagesForMenu;          //Background Images
   ArrayList<PImage> previewImagesForMenu;   //Preview Images
   
   //Map Selected
   int currentMapSelected = 0;
   String currentLevelName = "Watering Plains";
   
   
   Menu()
   {
     //Build the Menu features
     buildButtonMenu();
     buildMapChanger();
     
     buildBackground();
     buildPreview();
   } 
   
   void display()
   {
     //Display the menu features
     displayBackground();
     displayButtonMenu();
     displayMapChanger();
     displayPreviewImage();
   }
   
   //Display preview image based on map selection
   void displayPreviewImage()
   {
      
      image(previewImagesForMenu.get(currentMapSelected), 845, 140, 395, 250);
   }
   
   //Change background image based on map selection
   void buildBackground()
   {
     imagesForMenu = new ArrayList<PImage>();
     for(int x = 0; x < 4; x++)
     {
        imagesForMenu.add(loadImage("images/golf" + x + ".jpg")); 
     }
   }
   //Change preview image based on map selection
   void buildPreview()
   {
     previewImagesForMenu = new ArrayList<PImage>();
     for(int x = 0; x < 4; x++)
     {
        previewImagesForMenu.add(loadImage("images/golfPreview" + x + ".jpg")); 
     }
   }
   
   //Display background image based on map selection and rename the map in the map selection
   void displayBackground()
   {
       switch(currentMapSelected)
       {
          case 0:
            background(imagesForMenu.get(0));
            currentLevelName = "Watering Plains";
            break;
          case 1:
            background(imagesForMenu.get(1));
            currentLevelName = "Sandy Peaks";
            break;
          case 2:
            background(imagesForMenu.get(2));
            currentLevelName = "Grassy Knoll";
            break;
          case 3: 
            background(imagesForMenu.get(3));
            currentLevelName = "Chilly Shores";
            break;
          default:
            background(235);
            break;
       }
       
   }
   
   //Build the arrows and make them work
   void buildMapChanger()
   {
     changeMap = createShape(RECT, 0, 0, width/3.25, 100);
     changeMap.setFill(color(#29B521));
     changeMap.setStroke(false);
     mapChangeArrow = new ArrayList<PShape>();
     for(int x = 0; x < 2; x++)
     {
       mapChangeArrow.add(createShape());
       mapChangeArrow.get(x).beginShape();
         mapChangeArrow.get(x).vertex(0, 25);
         mapChangeArrow.get(x).vertex(25,0);
         mapChangeArrow.get(x).vertex(25,50);
       mapChangeArrow.get(x).endShape(CLOSE);
       mapChangeArrow.get(x).setFill(#1C7A17);
       mapChangeArrow.get(x).setStroke(false);
     }
   }
   
   
   //Display the arrows and map changer
   void displayMapChanger()
   {
      shape(changeMap, width - (width/2.95), 440);
      for(int x = 0; x < mapChangeArrow.size(); x++)
      {
         //Left Arrow
         if(x == 0)
         {
           shape(mapChangeArrow.get(x), width - (width/2.95) + 25, 465);
         }
         //Right Arrow
         else
         {
           pushMatrix();
           translate(width - (width/2.95) + 370, 515);
           rotate(radians(180));
           shape(mapChangeArrow.get(x), 0, 0);  
           popMatrix();
         }
      }
      textAlign(CENTER);
      textSize(36);
      fill(235);
      text(currentLevelName, width - (width/3.25) + 155, 500);
   }
   
   //Build the buttons on the menu
   void buildButtonMenu()
   {
     
     menuButtons = new ArrayList<MenuButtons>();
     buttonsMenu = createShape(RECT, 0, -140, width/2, 400);
     buttonsMenu.setFill(color(#29B521));
     
     for(int y = 0; y < 4; y++)
     {
         menuButtons.add(new MenuButtons(menuButtonsOffsetX + 20, (y * 60) + menuButtonsOffsetY + 10, width/2.15, 50, y));
         
     }
   }
   
   
   //Display the buttons on the menu
   void displayButtonMenu()
   {
     pushMatrix();
     translate(menuButtonsOffsetX, menuButtonsOffsetY);
      buttonsMenu.setStroke(false);
      shape(buttonsMenu);
     popMatrix();
     fill(235);
     textAlign(CENTER);
     textSize(36);
     text("Processing Golf", menuButtonsOffsetX + ((width/2)/2), menuButtonsOffsetY - 35);
     for(int y = 0; y < 4; y++)
     {
       menuButtons.get(y).display();
         
     }
     
     
     
   }
   
   //Check for interaction
   void checkIfMouseMoved()
   {
     //Check which button is hovered if any and add a hovering effect, and if clicked do something
      for(MenuButtons b : menuButtons)
      {
        if(mouseX >= b.xPos && mouseX <= b.xPos + b.widthOfButton && mouseY >= b.yPos && mouseY <= b.yPos + b.heightOfButton)
        {
           b.hover(true);
           //println("Hovering");
           if(mousePressed)
           {
               switch(b.menuOptionNum)
               {
                  case 0:
                     currentMode = "newGame";
                     previousMode = "newGame";
                     
                     levelGenerator.chooseColorPalette();
                     loadGame = false;
                     break;
                  case 1:
                     currentMode = "newGame";
                     previousMode = "newGame";
                     
                     levelGenerator.chooseColorPalette();
                     loadGame = true;
                     break;
                  case 2:
                     //currentMode = "options";
                     break;
                  case 3:
                     previousMode = "Menu";
                     currentMode = "exitGame";
                     break;
                  default:
                     break; 
               }
           }
        } 
        else
        {
           b.hover(false); 
        }
      }
      //If hovering on left arrow
      if(mouseX >= width - (width/2.95) + 25 && mouseX <= width - (width/2.95) + 50 && mouseY >= 465 && mouseY <= 515)
      {
        mapChangeArrow.get(0).setFill(#32FF5E);
        
      }
      else
      {
        mapChangeArrow.get(0).setFill(#1C7A17);
      }
      
      //If hovering on right arrow
      if(mouseX >= width - (width/2.95) + 345 && mouseX <= width - (width/2.95) + (width/3.25) - 25 && mouseY >= 465 && mouseY <= 515)
      {
         mapChangeArrow.get(1).setFill(#32FF5E);
        
      }
      else
      {
          mapChangeArrow.get(1).setFill(#1C7A17);
      }
   }
   
   
   
   void checkIfMouseClicked()
   {
     //Left Button, change map
     if(mouseX >= width - (width/2.95) + 25 && mouseX <= width - (width/2.95) + 50 && mouseY >= 465 && mouseY <= 515)
      {
         currentMapSelected--;
         if(currentMapSelected < 0)
         {
            currentMapSelected = 3; 
         }
      } 
     //Right Button, change map
      else if(mouseX >= width - (width/2.95) + 345 && mouseX <= width - (width/2.95) + (width/3.25) - 25 && mouseY >= 465 && mouseY <= 515)
      {
         currentMapSelected++;
         if(currentMapSelected > 3)
         {
            currentMapSelected = 0; 
         }
      }
      mapToBeGenerated = currentMapSelected;
     
   }
}
