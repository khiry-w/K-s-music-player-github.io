import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioPlayer player;
PImage album;

boolean isPlaying = false;
boolean isMuted = false;
float savedVolume = 0.0;
boolean loopInfinite = false;

String[] songs = {
  "data/Get Busy [Official Music Video].mp3",
  "data/Travis Scott & Kid Cudi - The Scotts Instrumental (Best Version).mp3",
  "data/.mp3"
};

String[] albums = {
  "data/black-myth-wukong-wallpaper-engine-1.jpg",
  "data/black-myth-wukong-wallpaper-engine-1.jpg",
  "data/black-myth-wukong-wallpaper-engine-1.jpg",
};

String[] titles = {
  "Yeat- Get busy",
  "",
  ""
};

int currentSong = 0;

void setup() {
  size(800, 600); // OpenJDK-compatible size
  minim = new Minim(this);
  loadSong(currentSong); // Auto-play first track
  textAlign(CENTER, CENTER);
  textSize(24);
}

void draw() {
  background(255);
  float centerX = width / 2;

  // Title Bar
  fill(200);
  rect(centerX - 300, 50, 600, 50);
  fill(0);
  text(titles[currentSong], centerX, 75);

  // Album Art
  if (album != null) {
    image(album, centerX - 150, 120, 300, 200);
  } else {
    fill(0);
    text("No Album Art", centerX, 200);
  }

  // Draw interactive elements
  drawButtons(centerX);
  drawProgressBar(centerX);
  drawQuitButton();
}

void drawButtons(float centerX) {
  float y = 350;
  float size = 80;
  float totalWidth = size * 5;
  float x = centerX - totalWidth / 2;

   String[] labels = {"PREV", "PLAY/PAUSE", "NEXT", "STOP", "QUIT"};

  for (int i = 0; i < 5; i++) {
    fill(180);
    rect(x, y, size, size);
    fill(0);
    textSize(32);
    text(labels[i], x + size / 2, y + size / 2 + 10);
    x += size + 10;
  }
}

void drawProgressBar(float centerX) {
  float y = 500;
  float barWidth = width - 200;
  fill(220);
  rect(centerX - barWidth / 2, y, barWidth, 20);

  if (player != null && player.isPlaying()) {
    float progress = map(player.position(), 0, player.length(), 0, barWidth);
    fill(0, 0, 139);
    rect(centerX - barWidth / 2, y, progress, 20);
  }

  if (player != null) {
    int pos = player.position();
    int len = player.length();
    String time = nf(pos / 60000, 2) + ":" + nf((pos / 1000) % 60, 2);
    String total = nf(len / 60000, 2) + ":" + nf((len / 1000) % 60, 2);

    fill(0);
    textSize(20);
    text(time + " / " + total, centerX, y + 40);
  }
}

void drawQuitButton() {
  float x = width - 70;
  float y = 30;
  fill(200);
  rect(x, y, 40, 40);
  fill(255, 0, 0);
  textSize(20);
  text("QUIT", x + 20, y + 25);
}

void mousePressed() {
  float centerX = width / 2;
  float y = 350;
  float size = 80;
  float totalWidth = size * 5;
  float x = centerX - totalWidth / 2;

  for (int i = 0; i < 5; i++) {
    if (mouseX > x && mouseX < x + size && mouseY > y && mouseY < y + size) {
      handleButtonPress(i);
    }
    x += size + 10;
  }

  if (mouseX > width - 70 && mouseX < width - 30 && mouseY > 30 && mouseY < 70) {
    exit();
  }
}

void handleButtonPress(int i) {
  if (player == null) return;

  switch (i) {
    case 0: // Previous Track
      currentSong = (currentSong - 1 + songs.length) % songs.length;
      loadSong(currentSong);
      break;
    case 1: // Play/Pause
      if (isPlaying) {
        player.pause();
        isPlaying = false;
      } else {
        player.play();
        isPlaying = true;
      }
      break;
    case 2: // Next Track
      currentSong = (currentSong + 1) % songs.length;
      loadSong(currentSong);
      break;
    case 3: // Mute/Unmute
      isMuted = !isMuted;
      player.setGain(isMuted ? -80 : savedVolume);
      break;
    case 4: // Quit
      exit();
      break;
  }
}

void loadSong(int i) {
  if (player != null) {
    player.close();
  }
 
  player = minim.loadFile(songs[i]);
  album = loadImage(albums[i]);
 
  if (album != null) {
    album.resize(300, 200);
  }

  if (player != null) {
    player.play();
    isPlaying = true;
    if (isMuted) player.setGain(-80);
  } else {
    println("Error loading song: " + songs[i]);
  }
}
