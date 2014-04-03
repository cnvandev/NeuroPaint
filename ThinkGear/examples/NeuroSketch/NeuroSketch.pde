/*
The NeuroSky MindWave device did not ship with any proper Java bindings.
 Jorge C. S. Cardoso has release a processing library for the MindSet device
 but that communicates over the serial port. NeuroSky has since release a connector
 application that talks JSON over a normal socket. 
 
 Using the same API as the previous library this talks directly to the ThinkGear
 connector.
 
 Info on this library
 http://crea.tion.to/processing/thinkgear-java-socket
 
 Info on ThinkGear 
 http://developer.neurosky.com/
 
 Info on Cardoso's API
 http://jorgecardoso.eu/processing/MindSetProcessing/
 
 Have fun and get some peace of mind!
 
 xx
 Andreas Borg
 Jun, 2011
 borg@elevated.to
 */



import neurosky.*;
import org.json.*;
import processing.pdf.*;

ThinkGearSocket neuroSocket;
int attention=10;
int meditation=10;
PFont font;


int w,h;
int halfw,halfh;
//int s,m,hr;
String name; 



void setup() {
  size(600,600);
  ThinkGearSocket neuroSocket = new ThinkGearSocket(this);
  try {
    neuroSocket.start();
  } 
  catch (Exception e) { //was "ConnectException" before
    //println("Is ThinkGear running??");
  }
  smooth();
  //noFill();
  font = createFont("Verdana",12);
  textFont(font);
  
  //For the Sketch App
  
  size(640, 360);
  frameRate(50);
  background(102);
  w = 20;
  h = 20;
  halfw = w/2; 
  halfh = w/2; 
  //beginRecord(PDF, "everything.pdf");
  
  //s = second();
  //String second=String.valueOf(s); 
  int m = minute();
  String minute=String.valueOf(m); 
  int hr = hour(); 
  String hour=String.valueOf(hr); 
  
  String name = hour+minute+".pdf";
  
  beginRecord(PDF, name);
  
  
  
}

void draw() {
  //background(0,0,0,50);
  fill(0, 0,0, 255);
  noStroke();
  rect(0,0,120,80); // this was the box for attention and meditation


  fill(0, 0,0, 10);
  noStroke();
  //rect(0,0,width,height);
  fill(0, 116, 168);
  stroke(0, 116, 168);
  text("Attention: "+attention, 10, 30);
  noFill();
  //ellipse(width/2,height/2,attention*3,attention*3);


  fill(209, 24, 117, 100);
  noFill();
  text("Meditation: "+meditation, 10, 50);
  //stroke(209, 24, 117, 100);
  //noFill();
  //ellipse(width/2,height/2,meditation*3,meditation*3);

stroke(255);
  if (mousePressed == true) {
    //line(mouseX, mouseY, pmouseX, pmouseY);
    //shape(star, mouseX-halfw, mouseY-halfh, w, h);
    variableEllipseThink(mouseX, mouseY, pmouseX, pmouseY, attention, meditation);
    //variableStroke(mouseX, mouseY,pmouseX, pmouseY);
  }


}

void poorSignalEvent(int sig) {
  println("SignalEvent "+sig);
}

public void attentionEvent(int attentionLevel) {
  println("Attention Level: " + attentionLevel);
  attention = attentionLevel;
}


void meditationEvent(int meditationLevel) {
  println("Meditation Level: " + meditationLevel);
  meditation = meditationLevel;
}

void blinkEvent(int blinkStrength) {

  println("blinkStrength: " + blinkStrength);
}

public void eegEvent(int delta, int theta, int low_alpha, int high_alpha, int low_beta, int high_beta, int low_gamma, int mid_gamma) {
  println("delta Level: " + delta);
  println("theta Level: " + theta);
  println("low_alpha Level: " + low_alpha);
  println("high_alpha Level: " + high_alpha);
  println("low_beta Level: " + low_beta);
  println("high_beta Level: " + high_beta);
  println("low_gamma Level: " + low_gamma);
  println("mid_gamma Level: " + mid_gamma);
}

void rawEvent(int[] raw) {
  //println("rawEvent Level: " + raw);
}	

void stop() {
  neuroSocket.stop();
  super.stop();
}


//Brush Code 
void variableEllipse(int x, int y, int px, int py) {
  float speed = abs(x-px) + abs(y-py);
  stroke(speed);
  ellipse(x, y, speed, speed);
}

void variableEllipseThink(int x, int y, int px, int py, int attention, int meditation) {
  
  //Stroke based on speed
  float speed = abs(x-px) + abs(y-py);
  stroke(speed);  //this is the gray level for the stroke
  
  float thickness = 100-attention;
  colorMode(HSB, 360, 100, 100); //360 100 100
  fill((round(meditation*2.5)),100,(100-meditation)/2+50); //210 100 48
                          //242 59 48  calm blue
  
  ellipse(x, y, thickness, thickness);
}

void variableStroke(int x, int y, int px, int py){
  float speed = abs(x-px) + abs (y-py); 
  strokeWeight(speed); 
  line(px,py,x,y);
}

//Saving a PDF
void keyPressed() {
  if (key == 'q') {
    endRecord();
    exit();
  }
}

