import ddf.minim.*;

Minim minim;
AudioPlayer player;
PImage album;

boolean isPlaying = false;

void setup() {
  fullScreen();
  minim = new Minim(this);

  // Load audio and image
  player = minim.loadFile("assets/audio/USO.mp3");
  album = loadImage("assets/images/ME-JU.jpg");
  album.resize(400, 250);

  textAlign(CENTER, CENTER);
  textFont(createFont("Arial Black", 48));
}

void draw() {
  background(255);
  float centerX = width / 2;

  // Title
  fill(200);
  rect(centerX - 250, 50, 500, 80);
  fill(0, 0, 139);
  text("Yeat-The bell instrumental", centerX, 90);

  // Album Art
  image(album, centerX - 200, 150);

  // Buttons
  float btnY = 500;
  float btnSize = 80;
  float totalButtonWidth = btnSize * 4;
  float buttonX = centerX - totalButtonWidth / 2;

  // --- Fast Backward Button ---
  fill(180);
  rect(buttonX, btnY, btnSize, btnSize);
  fill(0);
  triangle(buttonX + 35, btnY + 20, buttonX + 35, btnY + 60, buttonX + 5, btnY + 40);
  triangle(buttonX + 55, btnY + 20, buttonX + 55, btnY + 60, buttonX + 25, btnY + 40);

  // --- Play/Pause Button ---
  buttonX += btnSize;
  fill(180);
  rect(buttonX, btnY, btnSize, btnSize);
  fill(0);
  if (isPlaying && player.isPlaying()) {
    rect(buttonX + 20, btnY + 20, 15, 40);
    rect(buttonX + 50, btnY + 20, 15, 40);
  } else {
    triangle(buttonX + 25, btnY + 20, buttonX + 25, btnY + 60, buttonX + 55, btnY + 40);
  }

  // --- Stop Button ---
  buttonX += btnSize;
  fill(180);
  rect(buttonX, btnY, btnSize, btnSize);
  fill(0);
  rect(buttonX + 20, btnY + 20, 40, 40);

  // --- Fast Forward Button ---
  buttonX += btnSize;
  fill(180);
  rect(buttonX, btnY, btnSize, btnSize);
  fill(0);
  triangle(buttonX + 25, btnY + 20, buttonX + 25, btnY + 60, buttonX + 55, btnY + 40);
  triangle(buttonX + 45, btnY + 20, buttonX + 45, btnY + 60, buttonX + 75, btnY + 40);

  // --- Progress Bar ---
  float barY = 620;
  float barWidth = 500;
  fill(220);
  rect(centerX - 250, barY, barWidth, 25);

  if (player.length() > 0) {
    float progress = map(player.position(), 0, player.length(), 0, barWidth);
    fill(0, 0, 139);
    rect(centerX - 250, barY, progress, 25);
  }

  // --- Time Display ---
  int currentMillis = player.position();
  int totalMillis = player.length();
  String currentTime = nf(currentMillis / 60000, 2) + ":" + nf((currentMillis / 1000) % 60, 2);
  String totalTime = nf(totalMillis / 60000, 2) + ":" + nf((totalMillis / 1000) % 60, 2);

  fill(0);
  textSize(20);
  text(currentTime + " / " + totalTime, centerX, barY + 35);

  // --- Quit Button ---
  fill(200);
  rect(width - 70, 20, 40, 40);
  fill(255, 0, 0);
  textSize(24);
  text("X", width - 50, 40);
}

void mousePressed() {
  float centerX = width / 2;
  float btnY = 500;
  float btnSize = 80;
  float totalButtonWidth = btnSize * 4;
  float buttonX = centerX - totalButtonWidth / 2;

  // --- Fast Backward ---
  if (mouseX > buttonX && mouseX < buttonX + btnSize && mouseY > btnY && mouseY < btnY + btnSize) {
    int newPos = player.position() - 5000;
    player.cue(max(newPos, 0));
  }

  // --- Play/Pause ---
  buttonX += btnSize;
  if (mouseX > buttonX && mouseX < buttonX + btnSize && mouseY > btnY && mouseY < btnY + btnSize) {
    if (isPlaying && player.isPlaying()) {
      player.pause();
      isPlaying = false;
    } else {
      if (player.position() >= player.length()) {
        player.rewind();
      }
      player.play();
      isPlaying = true;
    }
  }

  // --- Stop ---
  buttonX += btnSize;
  if (mouseX > buttonX && mouseX < buttonX + btnSize && mouseY > btnY && mouseY < btnY + btnSize) {
    player.pause();
    player.rewind();
    isPlaying = false;
  }

  // --- Fast Forward ---
  buttonX += btnSize;
  if (mouseX > buttonX && mouseX < buttonX + btnSize && mouseY > btnY && mouseY < btnY + btnSize) {
    int newPos = player.position() + 5000;
    player.cue(min(newPos, player.length()));
  }

  // --- Quit ---
  if (mouseX > width - 70 && mouseX < width - 30 && mouseY > 20 && mouseY < 60) {
    exit();
  }
}
