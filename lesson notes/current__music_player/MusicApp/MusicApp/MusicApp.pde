/*
===============================================================================
Music Player App - Processing (Java) Version
-------------------------------------------------------------------------------
This program is a simple music player that allows you to:
- Play, pause, stop, rewind, and fast-forward songs.
- Adjust the volume and mute/unmute the music.
- Shuffle and repeat songs.
- View and select songs from a playlist popup (like a real music app).
- See the current song's album image and title.
- See song progress and time labels.

Features:
- Press the playlist button (three lines) to show a popup with all song titles.
- Click any song in the popup to play it and close the popup.
- Button layout is custom: "Previous" and "Volume Up" are swapped, and "Playlist" and "Next" are swapped.

All code lines are commented for grade 10 understanding.
===============================================================================
*/

import ddf.minim.*;                    // Imports the Minim library for audio functions
import ddf.minim.analysis.*;           // Imports audio analysis classes (not used here, but part of Minim)
import ddf.minim.effects.*;            // Imports audio effects classes (not used here)
import ddf.minim.signals.*;            // Imports signal generator classes (not used here)
import ddf.minim.spi.*;                // Imports service provider interface (not used here)
import ddf.minim.ugens.*;              // Imports unit generators for audio (not used here)

Minim minim;                           // Object to manage audio
AudioPlayer song;                      // Object to play audio files
PImage albumImg;                       // Stores the album cover image
PFont mvBoliFont;                      // Stores the font for titles

boolean isPlaying = false;             // True if music is playing, false otherwise
boolean isShuffle = false;             // True if shuffle is on
boolean isRepeat = false;              // True if repeat is on
boolean isMuted = false;               // True if muted

String[] titles = {                    // Array of song titles
  "Yeat-GeT BuSy",
  "Yeat- system",
  "GOD'S COUNTRY"
};

String[] audioPaths = {                // Array of song file paths
  "assets/audio/Get Busy [Official Music Video].mp3",
  "assets/audio/[Official Clean] Travis Scott - GOD'S COUNTRY.mp3",
  "assets/audio/System.mp3"
};

String[] imagePaths = {                // Array of album image file paths
  "assets/images/images.jpg",
  "assets/images/download.jpg",
  "assets/images/JC.jpg"
};

color[] titleColors = {                // Array of colors for song titles
  color(0, 0, 255),                    // Blue for first song
  color(255, 165, 0),                  // Orange for second song
  color(0, 200, 0)                     // Green for third song
};

int currentSongIndex = 0;              // Keeps track of which song is playing

// GUI layout variables
float appWidth, appHeight;             // App window size
float titleHeight = 60.0;              // Height of the title bar
float topMargin = 20.0;                // Space at the top of the window
float albumX, albumWidth, albumY, albumHeight; // Album image position and size
float buttonWidth, buttonHeight, buttonY;      // Button size and position
float barY, barHeight;                 // Progress bar position and size
float quitSize, quitX, quitY;          // Quit button size and position

// Volume control
float volume = 0.7;                    // Volume level (0 to 1)

// Button indices (updated for new layout)
// SWAPPED: "Previous" and "Volume Up" button positions
final int BTN_VOL_DOWN = 1;            // Volume Down button index
final int BTN_VOL_UP   = 2;            // Volume Up button index (was 3, now 2)
final int BTN_PREV     = 3;            // Previous button index (was 2, now 3)
final int BTN_REWIND   = 4;            // Rewind button index
final int BTN_PLAY     = 5;            // Play/Pause button index
final int BTN_STOP     = 6;            // Stop button index
final int BTN_FFWD     = 7;            // Fast Forward button index
final int BTN_NEXT     = 8;            // Next button index
final int BTN_PLAYLIST = 9;            // Playlist button index
final int BTN_SHUFFLE  = 10;           // Shuffle button index
final int BTN_REPEAT   = 11;           // Repeat button index

boolean isSeeking = false;             // True if user is moving the progress bar

boolean showPlaylist = false;          // True if playlist popup is shown

void setup() {
  fullScreen();                        // Makes the app use the full screen
  appWidth = (float) displayWidth;     // Sets app width to the screen width
  appHeight = (float) displayHeight;   // Sets app height to the screen height

  mvBoliFont = loadFont("Kyrie's font.vlw"); // Loads the font for text
  minim = new Minim(this);             // Initializes Minim (audio library)

  albumX = appWidth * 0.25f;           // Horizontal position for album image
  albumWidth = appWidth * 0.5f;        // Width for album image
  albumY = topMargin + titleHeight + 20.0f; // Vertical position for album image
  albumHeight = appHeight / 3.0f;      // Height for album image

  buttonWidth = appWidth / 12.0f;      // Width of each control button
  buttonHeight = buttonWidth;          // Height of each button (square)
  buttonY = albumY + albumHeight + 20.0f; // Y position for buttons

  barY = buttonY + buttonHeight + 20.0f; // Y position for progress bar
  barHeight = 40.0f;                   // Height of progress bar

  quitSize = 40.0f;                    // Size for the quit button (square)
  quitX = appWidth - quitSize;         // X position for quit button (flush right, no margin)
  quitY = 0;                           // Y position for quit button (flush top, no margin)

  loadCurrentSong();                   // Loads the first song and image
}

void draw() {
  background(255);                     // Sets window background to white
  drawTitleBar();                      // Draws the song title bar
  drawAlbumImage();                    // Shows the album image
  drawButtons();                       // Shows the control buttons
  drawProgressBar();                   // Shows the progress bar
  drawTimeLabels();                    // Shows current time and total time
  drawVolumeLabel();                   // Shows volume information
  drawQuitButton();                    // Draws the quit/close button

  if (showPlaylist) {                  // If playlist popup should be shown
    drawPlaylistPopup();               // Draw the popup for playlist selection
  }

  // If song finished, go to next or repeat as needed
  if (song != null && !song.isPlaying() && isPlaying) {
    if (isRepeat) {                    // If repeat mode is on
      song.rewind();                   // Restart the same song
      song.play();                     // Play the song again
    } else {                           // If not repeating
      autoNextSong();                  // Play the next song
    }
  }
}

// Draws the rectangle and title at the top of the app
void drawTitleBar() {
  fill(220);                           // Light gray background
  stroke(0);                           // Black border
  strokeWeight(2);                     // Border thickness
  rect(albumX, topMargin, albumWidth, titleHeight); // Draw rectangle

  fill(titleColors[currentSongIndex]); // Different color for each song
  textFont(mvBoliFont);                // Use custom font
  textAlign(CENTER, CENTER);           // Centered text
  text(titles[currentSongIndex], appWidth / 2.0f, topMargin + titleHeight / 2.0f); // Show song title
}

// Draws the album image, or a placeholder if missing
void drawAlbumImage() {
  if (albumImg != null) {              // If the image loaded correctly
    image(albumImg, albumX, albumY, albumWidth, albumHeight); // Show the image
  } else {                             // If the image is missing
    fill(200);                         // Gray background
    rect(albumX, albumY, albumWidth, albumHeight); // Draw rectangle
    fill(0);                           // Black text
    textAlign(CENTER, CENTER);         // Centered text
    textSize(32);                      // Big text
    text("Image not found", albumX + albumWidth / 2.0f, albumY + albumHeight / 2.0f); // Message
  }
}

// Draws the row of control buttons at the bottom
void drawButtons() {
  stroke(0);                           // Black border for buttons
  strokeWeight(1);                     // Thin border

  // Draw button backgrounds
  for (int i = 0; i < 12; i++) {       // 12 buttons in total
    float buttonX = buttonWidth * i;   // X position of current button
    if (mouseX > buttonX && mouseX < buttonX + buttonWidth &&
        mouseY > buttonY && mouseY < buttonY + buttonHeight) {
      fill(150);                       // Darker when mouse is over
    } else {
      fill(180);                       // Normal button color
    }
    rect(buttonX, buttonY, buttonWidth, buttonHeight, 8); // Draw button
  }

  fill(0);                             // Black for icons
  // Draw each button's icon based on its function
  for (int i = 0; i < 12; i++) {
    float buttonX = buttonWidth * i;
    float centerX = buttonX + buttonWidth / 2.0f;
    float centerY = buttonY + buttonHeight / 2.0f;
    float size = buttonWidth / 3.0f;
    float gap = 5.0f;

    if (i == 0) {                      // Mute button: speaker icon
      stroke(0);
      strokeWeight(3);
      noFill();
      float spkW = size * 0.5f;
      float spkH = size * 0.7f;
      beginShape();
      vertex(centerX - spkW * 0.5, centerY - spkH * 0.5);
      vertex(centerX - spkW * 0.5, centerY + spkH * 0.5);
      vertex(centerX + spkW * 0.3, centerY + spkH * 0.5);
      vertex(centerX + spkW * 0.3, centerY - spkH * 0.5);
      endShape(CLOSE);

      if (isMuted) {                   // If muted, show red X
        stroke(255, 0, 0);
        strokeWeight(4);
        line(centerX + spkW * 0.4, centerY - spkH * 0.5, centerX + spkW * 0.9, centerY + spkH * 0.5);
        line(centerX + spkW * 0.9, centerY - spkH * 0.5, centerX + spkW * 0.4, centerY + spkH * 0.5);
        stroke(0);
      } else {                        // If not muted, show sound waves
        noFill();
        strokeWeight(3);
        arc(centerX + spkW * 0.7, centerY, size * 0.4f, size * 0.4f, -PI/4, PI/4);
        arc(centerX + spkW * 1.0, centerY, size * 0.7f, size * 0.7f, -PI/4, PI/4);
      }
      strokeWeight(1);
      fill(0);
    }

    if (i == BTN_VOL_DOWN) {           // Volume Down: minus sign
      float lineW = size * 0.8f;
      float lineH = size * 0.15f;
      rect(centerX - lineW/2, centerY - lineH/2, lineW, lineH, 3);
    }
    if (i == BTN_VOL_UP) {             // Volume Up: plus sign (SWAPPED position)
      float lineW = size * 0.8f;
      float lineH = size * 0.15f;
      rect(centerX - lineW/2, centerY - lineH/2, lineW, lineH, 3);
      rect(centerX - lineH/2, centerY - lineW/2, lineH, lineW, 3);
    }
    if (i == BTN_PREV) {               // Previous song button (SWAPPED position)
      rect(centerX - size / 2.0f, centerY - size / 2.0f, size / 5.0f, size);
      triangle(centerX - size / 2.0f + size / 5.0f, centerY,
               centerX + size / 2.0f, centerY - size / 2.0f,
               centerX + size / 2.0f, centerY + size / 2.0f);
    }
    if (i == BTN_REWIND) {             // Rewind button
      triangle(centerX + size + gap, centerY - size / 2.0f, centerX + size + gap, centerY + size / 2.0f, centerX + gap, centerY);
      triangle(centerX, centerY - size / 2.0f, centerX, centerY + size / 2.0f, centerX - size, centerY);
    }
    if (i == BTN_PLAY) {               // Play/Pause button
      if (isPlaying) {                 // If music is playing, show pause icon
        float barWidth = size / 4.0f;
        rect(centerX - barWidth - 2.0f, centerY - size / 2.0f, barWidth, size);
        rect(centerX + 2.0f, centerY - size / 2.0f, barWidth, size);
      } else {                         // If not playing, show play icon
        triangle(centerX - size / 2.0f, centerY - size / 2.0f, centerX - size / 2.0f, centerY + size / 2.0f, centerX + size / 2.0f, centerY);
      }
    }
    if (i == BTN_STOP) {               // Stop button: square
      rect(centerX - size / 2.0f, centerY - size / 2.0f, size, size);
    }
    if (i == BTN_FFWD) {               // Fast Forward button
      triangle(centerX - size - gap, centerY - size / 2.0f, centerX - size - gap, centerY + size / 2.0f, centerX - gap, centerY);
      triangle(centerX, centerY - size / 2.0f, centerX, centerY + size / 2.0f, centerX + size, centerY);
    }
    if (i == BTN_NEXT) {               // Next song button (SWAPPED position)
      triangle(centerX - size, centerY - size / 2.0f, centerX - size, centerY + size / 2.0f, centerX, centerY);
      rect(centerX, centerY - size / 2.0f, size / 3.0f, size);
    }
    if (i == BTN_PLAYLIST) {           // Playlist button (SWAPPED position)
      float lineHeight = size / 5.0f;
      for (int l = -1; l <= 1; l++) {
        rect(centerX - size/2, centerY + l*lineHeight, size, lineHeight/2, 2);
      }
    }
    if (i == BTN_SHUFFLE) {            // Shuffle button: arrows crossing
      stroke(0, isShuffle ? 180 : 80, 0);
      strokeWeight(3);
      noFill();
      beginShape();
      vertex(centerX - size/2, centerY + size/2);
      vertex(centerX + size/2, centerY - size/2);
      endShape();
      beginShape();
      vertex(centerX - size/2, centerY - size/2);
      vertex(centerX + size/2, centerY + size/2);
      endShape();
      triangle(centerX + size/2-5, centerY - size/2-3, centerX + size/2+5, centerY - size/2, centerX + size/2-5, centerY - size/2+3);
      triangle(centerX + size/2-5, centerY + size/2-3, centerX + size/2+5, centerY + size/2, centerX + size/2-5, centerY + size/2+3);
      stroke(0);
      fill(0);
    }
    if (i == BTN_REPEAT) {             // Repeat button: circular arrow
      stroke(0, 0, isRepeat ? 180 : 80);
      strokeWeight(3);
      noFill();
      arc(centerX, centerY, size, size, PI/3, TWO_PI-PI/3);
      float a = PI/3;
      float r = size/2;
      float ax = centerX + cos(a)*r;
      float ay = centerY + sin(a)*r;
      triangle(ax, ay, ax-8, ay-5, ax-8, ay+5);
      stroke(0);
      fill(0);
    }
  }
}

// Draws the song progress bar
void drawProgressBar() {
  stroke(0);                           // Black border
  strokeWeight(2);                     // Thickness
  fill(155);                           // Gray background
  rect(0, barY, appWidth, barHeight);  // Draws the progress bar

  if (song != null && song.length() > 0) { // If a song is loaded
    float progress = map(song.position(), 0, song.length(), 0, appWidth); // Progress bar width
    fill(0);                           // Black fill for progress
    noStroke();
    rect(0, barY, progress, barHeight); // Draws filled part
  }
}

// Draws time labels below the progress bar
void drawTimeLabels() {
  float smallW = appWidth * 0.1f;      // Width for time boxes
  float smallH = 20.0f;                // Height for time boxes
  float smallY = barY + barHeight + 10.0f; // Y position for time
  float rightX = appWidth - smallW - 10.0f; // X for total time
  float leftX = rightX - smallW;       // X for current time

  fill(200);                           // Gray background
  stroke(0);                           // Black border
  rect(leftX, smallY, smallW, smallH); // Current time box
  rect(rightX, smallY, smallW, smallH);// Total time box

  fill(0);                             // Black text
  textAlign(CENTER, CENTER);           // Centered text
  textSize(24);                        // Big text

  int currentMillis = song != null ? song.position() : 0; // Current position in ms
  int currentSeconds = currentMillis / 1000;              // Seconds
  int currentMinutes = currentSeconds / 60;               // Minutes
  currentSeconds %= 60;                                   // Seconds remainder

  int totalMillis = song != null ? song.length() : 0;     // Song length in ms
  int totalSeconds = totalMillis / 1000;                  // Seconds
  int totalMinutes = totalSeconds / 60;                   // Minutes
  totalSeconds %= 60;                                     // Seconds remainder

  String currentTime = nf(currentMinutes, 1) + ":" + nf(currentSeconds, 2); // Format curr time
  String totalTime = nf(totalMinutes, 1) + ":" + nf(totalSeconds, 2);       // Format total time

  text(currentTime, leftX + smallW / 2.0f, smallY + smallH / 2.0f);         // Draw curr time
  text(totalTime, rightX + smallW / 2.0f, smallY + smallH / 2.0f);          // Draw total time
}

// Draws the volume level label above the buttons
void drawVolumeLabel() {
  String volText = "Volume: " + int(volume * 100) + "%"; // Shows volume as percentage
  fill(50);                             // Dark gray text
  textSize(24);                         // Big text
  textAlign(RIGHT, TOP);                // Right-aligned, top
  text(volText, appWidth - 20, buttonY - 30); // Draw volume label
}

// Draws the quit (close) button in upper right
void drawQuitButton() {
  boolean hover = (mouseX > quitX && mouseX < quitX + quitSize && mouseY > quitY && mouseY < quitY + quitSize); // Check mouse hover
  stroke(0);                           // Black border
  strokeWeight(2);                     // Thickness
  if (hover) fill(255, 220, 220);      // Light red if hovered
  else noFill();                       // Transparent if not hovered
  rect(quitX, quitY, quitSize, quitSize, 5); // Draws rectangle

  pushMatrix();                        // Save drawing state
  translate(quitX + quitSize / 2.0f, quitY + quitSize / 2.0f); // Move to center of button
  rotate(radians(45));                 // Rotate lines for "X"
  stroke(255, 0, 0);                   // Red lines
  strokeWeight(3);                     // Thicker lines
  line(-10, 0, 10, 0);                 // First line
  line(0, -10, 0, 10);                 // Second line
  popMatrix();                         // Restore drawing state
}

// Draws the playlist popup above the playlist button
void drawPlaylistPopup() {
  float popupWidth = 400;              // Width of the popup
  float popupHeight = 60 + 50 * titles.length; // Height depends on number of songs
  float popupX = appWidth / 2 - popupWidth / 2; // X position (centered)
  float popupY = buttonY - popupHeight - 20;    // Y position (above buttons)

  fill(245);                           // Very light gray background
  stroke(0);                           // Black border
  rect(popupX, popupY, popupWidth, popupHeight, 12); // Draw popup

  fill(0);                             // Black text
  textAlign(CENTER, CENTER);           // Centered text
  textSize(28);                        // Big title
  text("Select a song:", popupX + popupWidth / 2, popupY + 30); // Title above song list

  for (int i = 0; i < titles.length; i++) { // For each song title
    float y = popupY + 60 + i * 50;   // Y position for each song
    if (mouseX > popupX && mouseX < popupX + popupWidth &&
        mouseY > y - 20 && mouseY < y + 20) {
      fill(220, 240, 255);            // Highlight if mouse is over
      rect(popupX + 10, y - 20, popupWidth - 20, 40, 6); // Draw highlight box
      fill(0);                        // Black text
    }
    textSize(24);                     // Slightly smaller text
    text(titles[i], popupX + popupWidth / 2, y); // Draw song title
  }
}

// Handles mouse button clicks
void mousePressed() {
  // If clicking the progress bar, seek to new position
  if (mouseY > barY && mouseY < barY + barHeight) {
    float clickRatio = constrain(mouseX / appWidth, 0, 1); // How far along the bar
    if (song != null) {
      int newPos = int(song.length() * clickRatio); // New position in ms
      song.cue(newPos);                    // Move to new position
    }
    return;                                // Don't process other clicks
  }

  // If playlist popup is open, check if a song is clicked
  if (showPlaylist) {
    float popupWidth = 400;
    float popupHeight = 60 + 50 * titles.length;
    float popupX = appWidth / 2 - popupWidth / 2;
    float popupY = buttonY - popupHeight - 20;
    for (int i = 0; i < titles.length; i++) {
      float y = popupY + 60 + i * 50;
      if (mouseX > popupX && mouseX < popupX + popupWidth &&
          mouseY > y - 20 && mouseY < y + 20) {
        currentSongIndex = i;         // Set current song to chosen index
        loadCurrentSong();            // Load and play the chosen song
        showPlaylist = false;         // Hide the popup
        return;                       // Don't process other clicks
      }
    }
  }

  // Check each control button
  for (int i = 0; i < 12; i++) {
    float buttonX = buttonWidth * i;
    if (mouseX > buttonX && mouseX < buttonX + buttonWidth &&
        mouseY > buttonY && mouseY < buttonY + buttonHeight) {
      switch(i) {
        case 0:                        // Mute/unmute
          isMuted = !isMuted;          // Toggle mute
          if (song != null) song.setGain(isMuted ? -80 : map(volume, 0, 1, -80, 0)); // Set volume
          break;
        case BTN_VOL_DOWN:             // Volume down
          setVolume(volume - 0.05f);   // Decrease volume
          break;
        case BTN_VOL_UP:               // Volume up (SWAPPED position)
          setVolume(volume + 0.05f);   // Increase volume
          break;
        case BTN_PREV:                 // Previous song (SWAPPED position)
          prevSong();                  // Go to previous song
          break;
        case BTN_REWIND:               // Rewind
          rewindFive();                // Go back 5 seconds
          break;
        case BTN_PLAY:                 // Play/pause
          togglePlayPause();           // Play or pause song
          break;
        case BTN_STOP:                 // Stop
          stopSong();                  // Stop music
          break;
        case BTN_FFWD:                 // Fast forward
          forwardFive();               // Skip ahead 5 seconds
          break;
        case BTN_NEXT:                 // Next song (SWAPPED position)
          nextSong();                  // Go to next song
          break;
        case BTN_PLAYLIST:             // Playlist (SWAPPED position)
          showPlaylist = !showPlaylist; // Show/hide playlist popup
          break;
        case BTN_SHUFFLE:              // Shuffle
          isShuffle = !isShuffle;      // Toggle shuffle mode
          break;
        case BTN_REPEAT:               // Repeat
          isRepeat = !isRepeat;        // Toggle repeat mode
          break;
      }
    }
  }

  // If quit button is clicked, close the app
  if (mouseX > quitX && mouseX < quitX + quitSize &&
      mouseY > quitY && mouseY < quitY + quitSize) {
    exit();                            // Exits the program
  }
}

// Handles key presses for keyboard shortcuts
void keyPressed() {
  if (key == ' ' || key == 'k') togglePlayPause(); // Spacebar or 'k' toggles play/pause
  else if (keyCode == RIGHT) nextSong();           // Right arrow for next song
  else if (keyCode == LEFT) prevSong();            // Left arrow for previous song
  else if (keyCode == UP) setVolume(volume + 0.05f);      // Up arrow for volume up
  else if (keyCode == DOWN) setVolume(volume - 0.05f);    // Down arrow for volume down
}

// Sets the music volume (0 to 1)
void setVolume(float v) {
  volume = constrain(v, 0, 1);         // Keep within bounds
  if (song != null && !isMuted) song.setGain(map(volume, 0, 1, -80, 0)); // Set volume
}

// Loads the song and image for the current index
void loadCurrentSong() {
  if (song != null) {                  // If a song is already loaded
    song.close();                      // Close it
  }
  song = minim.loadFile(audioPaths[currentSongIndex]); // Load new song
  albumImg = loadImage(imagePaths[currentSongIndex]);  // Load new image
  isPlaying = false;                   // Not playing yet
  setVolume(volume);                   // Set volume
  if (song != null) song.setGain(isMuted ? -80 : map(volume, 0, 1, -80, 0)); // Set gain
}

// Play or pause the current song
void togglePlayPause() {
  if (song == null) return;            // If no song, do nothing
  if (isPlaying) {                     // If already playing
    song.pause();                      // Pause the song
    isPlaying = false;                 // Update state
  } else {                             // If not playing
    song.play();                       // Play the song
    isPlaying = true;                  // Update state
  }
}

// Stop the current song and reset position
void stopSong() {
  if (song == null) return;            // If no song, do nothing
  song.pause();                        // Pause the song
  song.rewind();                       // Go back to start
  isPlaying = false;                   // Update state
}

// Go to the next song (shuffle if enabled)
void nextSong() {
  if (isShuffle) {                     // If shuffle mode
    int prevIdx = currentSongIndex;    // Remember current song
    while (titles.length > 1) {        // Loop until a new song is chosen
      currentSongIndex = int(random(titles.length)); // Pick random song
      if (currentSongIndex != prevIdx) break; // Make sure it's not the same
    }
  } else {                             // If not shuffle
    currentSongIndex++;                // Go to next song
    if (currentSongIndex >= titles.length) currentSongIndex = 0; // Wrap around
  }
  loadCurrentSong();                   // Load and play the song
}

// Go to the previous song (shuffle if enabled)
void prevSong() {
  if (isShuffle) {                     // If shuffle mode
    int prevIdx = currentSongIndex;    // Remember current song
    while (titles.length > 1) {        // Loop until a new song is chosen
      currentSongIndex = int(random(titles.length)); // Pick random song
      if (currentSongIndex != prevIdx) break; // Make sure it's not the same
    }
  } else {                             // If not shuffle
    currentSongIndex--;                // Go to previous song
    if (currentSongIndex < 0) currentSongIndex = titles.length - 1; // Wrap around
  }
  loadCurrentSong();                   // Load and play the song
}

// Rewind 5 seconds
void rewindFive() {
  if (song == null) return;            // If no song, do nothing
  int newPos = max(0, song.position() - 5000); // 5000 ms = 5 seconds
  song.cue(newPos);                    // Set new position
}

// Fast forward 5 seconds
void forwardFive() {
  if (song == null) return;            // If no song, do nothing
  int newPos = min(song.length(), song.position() + 5000); // 5000 ms = 5 seconds
  song.cue(newPos);                    // Set new position
}

// Auto-play next song when current finishes
void autoNextSong() {
  if (isShuffle) {                     // If shuffle mode
    int prevIdx = currentSongIndex;    // Remember current song
    while (titles.length > 1) {        // Loop until a new song is chosen
      currentSongIndex = int(random(titles.length)); // Pick random song
      if (currentSongIndex != prevIdx) break; // Make sure it's not the same
    }
  } else {                             // If not shuffle
    currentSongIndex++;                // Go to next song
    if (currentSongIndex >= titles.length) currentSongIndex = 0; // Wrap around
  }
  loadCurrentSong();                   // Load new song
  song.play();                         // Start playing it
  isPlaying = true;                    // Update state
}

// Stops and closes everything when app quits
void stop() {
  if (song != null) {                  // If a song is loaded
    song.close();                      // Close it
  }
  minim.stop();                        // Stop Minim audio
  super.stop();                        // Finish up
}
