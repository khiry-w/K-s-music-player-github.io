//Dynamic not static
//
//Library - Minim
//
//Global Variables
//
float X, Y, Width, Height;
float exitX, exitY, exitWidth, exitHeight;

void setup() {
  //
  fullScreen();
 
  //
  int appWidth = displayWidth;
  int appHeight = displayHeight;
 
  //
  float rectWidth = appWidth * 0.40;  //
  float rectHeight = appHeight * 0.40;  //
  float rectX = appWidth * 0.30;  //
  float rectY = appHeight * 0.25;  //
 
  //
  float squareSize = 100;  //
  int numSquares = 12;  //
  float totalSquaresWidth = numSquares * squareSize;  //
  float squareY = rectY + rectHeight + 20;  //
 
  //
  rect(rectX, rectY, rectWidth, rectHeight);
 //
  float startX = rectX + (rectWidth - totalSquaresWidth) / 2;
 
  //
  for (int i = 0; i < numSquares; i++) {
    //
    float squareX = startX + (i * squareSize);
   
    //
    rect(squareX, squareY, squareSize, squareSize);
  }
 
  //
  float buttonSize = 90;

  //
  float buttonX = appWidth - buttonSize;  //
  float buttonY = 0;  //

  //
  rect(buttonX, buttonY, buttonSize, buttonSize);
}

void draw() {
  //
  //
}

void mousePressed() {
  //
  //
}

void keyPressed() {
  //
  //
}
