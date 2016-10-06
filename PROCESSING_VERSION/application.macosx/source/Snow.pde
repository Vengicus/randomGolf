class Snow
{
  float xPos;      //X Location
  float yPos;      //Y Location
  float size;      //Size
  float speed;     //Speed
  float col;       //Brightness of flakes
  int yDir;        //Y Direction
  Snow(float x, float y, float scale, float s)
  {
    xPos = x;
    yPos = y;
    size = scale;
    speed = s;
    yDir = 1;
    col = 255;
  }
  
  void move()
  {
    yPos += yDir*speed;
    if(yPos > height)    //IF FLAKE GOES OFF THE SCREEN BRING IT BACK UP TO THE TOP OF THE SCREEN TO CREATE A LOOPING BACKGROUND EFFECT
    {
       yPos = 0; 
    }
  }
  
  void shimmer()
  {
    col += random(-5,5);        //ADD A SHIMMERING EFFECT TO THE FLAKE BY RANDOMIZING THE BRIGHTNESS
    
    if(col > 100)      //MAKE SURE THE SNOW CAPS AT 100
    {
       col = 100; 
    }
    else if(col < 75)    //MAKE SURE THE SNOW CAPS AT 75
    {
       col = 75; 
    }
  }
  
  void display()
  {
     move();
     shimmer();
     noStroke();
     colorMode(HSB, 360, 100, 100);
     fill(0,0,col);
     ellipse(xPos, yPos, size, size);
     colorMode(RGB, 255, 255, 255);
  }
  
  
}
