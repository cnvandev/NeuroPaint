import blobscanner.*;
import processing.video.*;

PImageOperations  PImOps;
Capture frame;
PBGS  pBackground;
FingerDetector fd  ;
Detector bs, bstips;

final int TIPS_MASS = 45;
final int HAND_MASS = 600;

final int CAMERA_WIDTH = 320;
final int CAMERA_HEIGHT = 180;

int iThreshold = 190;
boolean iSetNext = true;

PFont f;
PImage tips = createImage(CAMERA_WIDTH, CAMERA_HEIGHT, RGB); 
PImage imgDiff = createImage(CAMERA_WIDTH, CAMERA_HEIGHT, RGB); 
PImage  FG = createImage(CAMERA_WIDTH, CAMERA_HEIGHT, RGB);
PImage  imgDiffColor = createImage(CAMERA_WIDTH, CAMERA_HEIGHT, RGB);

void setup() {
  size(CAMERA_WIDTH, CAMERA_HEIGHT);
  f = createFont("", 20);
  textFont(f, 20);
  
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i<cameras.length; i++){
      println(cameras[i]);
    }
  }
  
  frame = new Capture(this, CAMERA_WIDTH, CAMERA_HEIGHT, 30);
  frame.start();
  PImOps = new PImageOperations();
  pBackground = new PBGS(FG);
  fd = new FingerDetector(CAMERA_WIDTH, CAMERA_HEIGHT);
  bs = new Detector(this, 0, 0, CAMERA_WIDTH, CAMERA_HEIGHT, 255);
  bstips = new Detector(this, 0, 0, CAMERA_WIDTH, CAMERA_HEIGHT, 255);
  
  ellipseMode(CENTER);
  fill(204, 102, 0);
}
 
void draw(){
  if (frame.available()) {
    frame.read();
    
    //   BACKGROUND SUBTRACTION  //
    frame.loadPixels();
    FG.loadPixels();
    
    arrayCopy(frame.pixels, FG.pixels);       //put this into a PImage
   
    FG.updatePixels();
    
    if (iSetNext) {
      pBackground.Set(FG);                    // Set the background image
      iSetNext=false;
    }
    pBackground.Update(FG);                   // Update the background model
    imgDiff.loadPixels();
    pBackground.PutDifference();              // Put the difference in imgDiff
    imgDiff.updatePixels();
    
    //  FINGER DETECTION   //
    imgDiff.loadPixels();
    fd.setImage(imgDiff);                     // Set hand detection image with BGS image
    imgDiff.updatePixels();
    
    bs.imageFindBlobs(imgDiff);               // Compute blobs in BGS image
    bs.loadBlobsFeatures();
    bs.weightBlobs(false);
 
    calculateDiff();
    
    image(frame, 0, 0);
    findTips();
  }
}
 

// force update of the background model when a key is clicked. 
void keyPressed() {
  iSetNext=true;
}

/*
  This function analyzes the BGS image, then
  based on its data and on the original camera's  
  image data, creates a BGS color image.
  If you need more speed you can eliminate this
  function, and display the original frame instead.
 */
void calculateDiff() {
  int []fg_pix = FG.pixels;               //set a reference to the foreground image
 
  imgDiff.loadPixels();
  imgDiffColor.loadPixels();
  for(int y = 0; y < imgDiff.height; y++){
    for(int x = 0; x < imgDiff.width; x++){
      if(brightness(imgDiff.get(x, y))==0) imgDiffColor.pixels[x+y*imgDiff.width]= 0xff000000;
      else  imgDiffColor.pixels[x+y*imgDiff.width]=fg_pix[x+y*FG.width];
    }
  }
  imgDiffColor.updatePixels();
}

void doSomethingWithTip(float centerX, float centerY, float tipWidth, float tipHeight) {
  ellipse(centerX, centerY, tipWidth, tipHeight);
} 
 
 /*
   Here many important things happen.  
   The tips image is first initialized to black.
   Then, the hand's blob is searched in the BGS image.
   Once it has been found, the blob pixels are scanned for
   possibly finger's tips regions. 
   After that a finger tips image is created based upon
   the search's result data. The image is then scanned for blobs.  
 */
void findTips() {
  tips.loadPixels();
  
  for (int i = 0; i < CAMERA_WIDTH*CAMERA_HEIGHT; i++)
    tips.pixels[i] = 0xff000000;// Set to black the tips image pixels
  
  //For each pixels in the BGS image (imgDiff)....
  for (int y =  0; y < CAMERA_HEIGHT; y++) {
    for (int x =  0; x < CAMERA_WIDTH; x++) {
      if (bs.isBlob(x, y) && bs.getBlobWeightLabel(bs.getLabel(x, y))>= HAND_MASS) {      // if is hand  
        if(fd.goodPixel(x, y))                              //if it's a finger's tip pixel set to white
          tips.pixels[x+y*tips.width] = 0xff << 16 & 0xff0000 | 0xff << 8 & 0xff00 | 0xff & 0xff;
      } 
    }
  }
   
  tips.updatePixels();
   
  //now the tips image is created (top right) let's compute the blobs in it   
  bstips.imageFindBlobs(tips);
  bstips.loadBlobsFeatures();
  bstips.weightBlobs(false); 
  
  fill(255);
  for (int i = 0; i < bstips.getBlobsNumber(); i++) {
    if (bstips.getBlobWeight(i) >= TIPS_MASS) 
       doSomethingWithTip(bstips.getBoxCentX(i), bstips.getBoxCentY(i), bstips.getBlobWidth(i), bstips.getBlobHeight(i));
  } 
}
