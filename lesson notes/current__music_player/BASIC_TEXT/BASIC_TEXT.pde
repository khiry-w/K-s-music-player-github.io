// Text: Static
//
String title = "Gimme 3. HEYYYYYAAA!";
//
//Display
//fullScreen();
size(700, 500);
int appWidth = width; //displayWidth
int appHeight = height; //displayHeight
int shorterSide = ( appWidth >= appHeight ) ? appHeight : appWidth ; //Landscape, Portrait, & Square
//
/*Fonts from OS
 println("Start of Console");
 String[] fontList = PFont.list(); //To list all fonts available on system
 printArray(fontList); //For listing all possible fonts to choose, then createFont
 */
float fontSize = shorterSide; //changed int to float for strongly formatted language
PFont titleFont = createFont("Harrington", fontSize);
//Tools / Create Font / Find Font / Do Not Press "OK", known bug
//
//Population
float titleX, titleY, titleWidth, titleHeight;
titleX = appWidth*1/4;
titleY = appHeight*1/4;
titleWidth = appWidth*1/2;
titleHeight = appHeight*1/10;
//
//DIVs
rect(titleX, titleY, titleWidth, titleHeight);
//
//Font Size Algorithm
float harringtonAspectRatio = 1.04;
fontSize = titleHeight * harringtonAspectRatio; //Extra Valye "Cuts the Mullet OFF"
textFont(titleFont, fontSize); //see variable note
println( textWidth(title), titleWidth );
while ( textWidth(title) > titleWidth  ) {
  fontSize = fontSize * 0.99;
  textFont(titleFont, fontSize); //see variable note
  println( "Step:", textWidth(title), titleWidth );
}
//
color purpleInk = #2C08FF;
fill(purpleInk); //Ink, hexidecimal copied from Color Selector
textAlign (CENTER, CENTER); //Align X&Y, see Processing.org / Reference
//Values: [LEFT | CENTER | RIGHT] & [TOP | CENTER | BOTTOM | BASELINE]
textFont(titleFont, fontSize); //see variable note
//textFont() has option to combine font declaration with textSize()
//Drawing Text
text(title, titleX, titleY, titleWidth, titleHeight);
color whiteInk = #FFFFFF;
fill(whiteInk); //reset
//leX,titleY,titleWidth,titleHeight); 
