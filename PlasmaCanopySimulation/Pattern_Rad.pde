@LXCategory("Color")
public class Rad extends LXPattern {
  
  public String getAuthor() {
    return "Raadad Elsleiman";
  }
  
  public int positionCounter = 0;  // determines which position in model to evaluate
  public int widthCounter = 10;  // determines how far apart to place segment
  
  public int timer = 0; // keep track of time to allow slowing and speeding of program
  public int timerStep = 1; // interval to perform evaluation
  
  public boolean direction = true; // wheather segments are to be expanding or contracting over time
 
 
  public  int r = 255;  // "on" parts of each segment
  public  int g = 233; 
  public  int b = 100;
  
  public  int br = 0;  // "off" parts of each segment 
  public  int bg = 0;
  public  int bb = 0;
  
  
  

  public CompoundParameter refreshV = new CompoundParameter("reset", 0,1,360);
  public CompoundParameter speed = new CompoundParameter("speed", 99,1,100);
  public CompoundParameter reversePoint = new CompoundParameter("actPoint", 10,1,360);
  public CompoundParameter lightWidth = new CompoundParameter("lightWidth", 5,1,20);
  
 
  public Rad(LX lx) {
    super(lx);
    addParameter(refreshV);
    addParameter(reversePoint);
    addParameter(speed);
    addParameter(lightWidth);
  }
  
  
    
  public void run(double deltaMs) {
    timer+=deltaMs; // keep track of elapsed time;
    
    int reset = (int) this.refreshV.getValuef(); 
    timerStep = 100 - (int) this.speed.getValuef();  
    
    if(reset > this.reversePoint.getValuef() && widthCounter > 20) {  // when reset is triggered have the segments start shrinking, dont start shrinking if the segments are too small
       direction = false;
       widthCounter-= reset/25; // increase the spead in which the segments shrink the bigger they are
    };
    
    if(widthCounter == 0) widthCounter = 1; // prevent division by 0 errors;
 
 
    for (LXPoint p : model.points) {
       positionCounter++;
       if(positionCounter % widthCounter > 1 && positionCounter % widthCounter < (int) this.lightWidth.getValuef()  ) { // light  the begenning x parts of each segment;
         setColor(p.index, LXColor.rgb(r,g,b));
       } else {
         setColor(p.index, LXColor.rgb(br,bg,bb));   // off every other part
       }
    }
    
   
    if((timer / 10) > timerStep){  //make the situation change depending on elapsed time
      
     if(direction) {
       widthCounter++;
      } else {
       widthCounter--;
      };
      timer = 0;
    };
    
    
    positionCounter = 1; //reset counter after elapsed amount of time
    
  
    if (widthCounter > 50) positionCounter = 50;   // set some boundaries for how big or small a segment gets, and make sure it reverses in direction when it gets too smalls
    if (widthCounter <= 1 ) direction = true;    
    if(widthCounter > 400) widthCounter = 300;
   
   
    r = (int)(Math.random()*255);  //change set color on every timer step
    g = (int)(Math.random()*255);
    b = (int)(Math.random()*255);
    

  }
  
  
} 

public class RadFlash extends LXEffect {
    
  public CompoundParameter refreshV = new CompoundParameter("reset", 0,1,360);
  public CompoundParameter refreshTrigger = new CompoundParameter("resetTrigger", 200,1,360);
  public RadFlash(LX lx) {
    super(lx);
    addParameter(refreshV);
    addParameter(refreshTrigger);
  }
  
  public void run(double deltaMs, double dx) {
     
        int r = (int)(Math.random()*255);
        int g = (int)(Math.random()*255);
        int b = (int)(Math.random()*255);
     
    
        for (LXPoint p : model.points) {
         if(this.refreshV.getValuef() > refreshTrigger.getValuef()) {
             setColor(p.index, LXColor.rgb(r,g,b));           
         }
    }
  };
}
