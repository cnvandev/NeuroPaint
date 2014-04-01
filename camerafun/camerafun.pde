import processing.video.*;

Capture cam; //declared, not yet initialized

void setup(){
  size(600,300);
  
 String[] cameras = Capture.list();
  
  if (cameras.length == 0){
    println("There are no cameras available for capture.");
    exit();
  }else{
    println("Available cameras:");
    for (int i = 0; i<cameras.length; i++){
      println(cameras[i]);
    }
  }
  
 
  cam = new Capture(this, 320, 240, 30); //(Parent, width, height and framerate
  cam.start();
  //println(Capture.list());
  //320 240 30 <-- resolution
}

void draw(){
  if(cam.available()==true){
    cam.read(); //read in the current frame, whatever is entering through the camera
  }
  image(cam, 0, 0); //draw the frame at 0,0
}
