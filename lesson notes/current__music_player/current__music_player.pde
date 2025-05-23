import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

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
  minim = new Minim(this);
  loadSong(currentSong);
 
  textAlign(CENTER, CENTER);
  textFont(createFont("MV Boli", 60));
  fill(0, 0, 139);
}
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
  background(255);
  float centerX = width / 2;
 
  noFill();
  stroke(0);
  strokeWeight(5);
  rect(50, 50, width - 100, height - 100);
 
  fill(200);
  rect(centerX - 300, 50, 600, 100);
  fill(0, 0, 139);
  text(titles[currentSong], centerX, 100);
 
  image(album, centerX - 250, 180);
 
  drawButtons(centerX);
  drawProgressBar(centerX);
  drawQuitButton();
}

void drawButtons(float centerX) {
  float btnY = 550;
  float btnSize = 100;
  float totalButtonWidth = btnSize * 8;
  float buttonX = centerX - totalButtonWidth / 2;
 
  for (int i = 0; i < 8; i++) {
    fill(180);
    rect(buttonX, btnY, btnSize, btnSize);
    fill(0);
    drawButtonIcon(i, buttonX, btnY);
    buttonX += btnSize;
  }
}

void drawButtonIcon(int index, float x, float y) {
  switch (index) {
    case 0: // Fast Backward
      triangle(x + 40, y + 25, x + 40, y + 75, x + 10, y + 50);
      triangle(x + 60, y + 25, x + 60, y + 75, x + 30, y + 50);
      break;
    case 1: // Play/Pause
      if (isPlaying) {
        rect(x + 25, y + 30, 20, 50);
        rect(x + 55, y + 30, 20, 50);
      } else {
        triangle(x + 35, y + 30, x + 35, y + 70, x + 65, y + 50);
      }
      break;
    case 2: // Stop
      rect(x + 25, y + 30, 50, 50);
      break;
    case 3: // Fast Forward
      triangle(x + 35, y + 25, x + 35, y + 75, x + 65, y + 50);
      triangle(x + 55, y + 25, x + 55, y + 75, x + 85, y + 50);
      break;
    case 4: // Next
      triangle(x + 35, y + 25, x + 35, y + 75, x + 65, y + 50);
      rect(x + 70, y + 25, 10, 50);
      break;
    case 5: // Previous
      triangle(x + 65, y + 25, x + 65, y + 75, x + 35, y + 50);
      rect(x + 25, y + 25, 10, 50);
      break;
    case 6: // Mute/Unmute
      if (isMuted) {
        line(x + 30, y + 30, x + 70, y + 70);
        line(x + 70, y + 30, x + 30, y + 70);
      } else {
        triangle(x + 40, y + 35, x + 40, y + 65, x + 60, y + 50);
        rect(x + 60, y + 40, 10, 20);
      }
      break;
    case 7: // Loop mode icon
      if (loopInfinite) {
        noFill();
        stroke(0);
        strokeWeight(3);
        // Draw an infinity symbol as 2 connected loops
        beginShape();
        vertex(x + 30, y + 50);
        bezierVertex(x + 30, y + 30, x + 50, y + 30, x + 50, y + 50);
        bezierVertex(x + 50, y + 70, x + 70, y + 70, x + 70, y + 50);
        bezierVertex(x + 70, y + 30, x + 50, y + 30, x + 50, y + 50);
        bezierVertex(x + 50, y + 70, x + 30, y + 70, x + 30, y + 50);
        endShape();
      } else {
        noFill();
        stroke(0);
        strokeWeight(3);
        ellipse(x + 50, y + 50, 40, 40);
        fill(0);
        textSize(30);
        text("1", x + 50, y + 55);
      }
      break;
  }
}

void drawProgressBar(float centerX) {
  float barY = 700;
  float barWidth = 100 * 15;
  fill(220);
  rect(centerX - barWidth / 2, barY, barWidth, 30);
 
  if (player.isPlaying()) {
    float progress = map(player.position(), 0, player.length(), 0, barWidth);
    fill(0, 0, 139);
    rect(centerX - barWidth / 2, barY, progress, 30);
  }
 
  int currentMillis = player.position();
  int totalMillis = player.length();
  String currentTime = nf(currentMillis / 60000, 2) + ":" + nf((currentMillis / 1000) % 60, 2);
  String totalTime = nf(totalMillis / 60000, 2) + ":" + nf((totalMillis / 1000) % 60, 2);
 
  fill(0);
  textSize(24);
  text(currentTime + " / " + totalTime, centerX, barY + 40);
}

void drawQuitButton() {
  fill(200);
  rect(width - 90, 30, 50, 50);
  fill(255, 0, 0);
  textSize(30);
  text("X", width - 60, 55);
}

void mousePressed() {
  float centerX = width / 2;
  float btnY = 550;
  float btnSize = 100;
  float totalButtonWidth = btnSize * 8;
  float buttonX = centerX - totalButtonWidth / 2;
 
  for (int i = 0; i < 8; i++) {
    if (mouseX > buttonX && mouseX < buttonX + btnSize && mouseY > btnY && mouseY < btnY + btnSize) {
      handleButtonPress(i);
    }
    buttonX += btnSize;
  }
 
  if (mouseX > width - 90 && mouseX < width - 40 && mouseY > 30 && mouseY < 80) {
    exit();
  }
}

void keyPressed() {
  //
  //
}
