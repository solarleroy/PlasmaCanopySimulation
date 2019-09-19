public class Rad extends LXPattern {

    public String getAuthor() {
        return "Raadad Elsleiman";
    }

    public int positionCounter = 0; // determines which position in model to evaluate
    public int widthCounter = 10; // determines how far apart to place segment

    public int timer = 0; // keep track of time to allow slowing and speeding of program
    public int timerStep = 1; // interval to perform evaluation

    public boolean direction = true; // wheather segments are to be expanding or contracting over time


    public int r = 255; // "on" parts of each segment
    public int g = 233;
    public int b = 100;

    public int br = 0; // "off" parts of each segment 
    public int bg = 0;
    public int bb = 0;




    public CompoundParameter refreshV = new CompoundParameter("reset", 0, 1, 360);
    public CompoundParameter speed = new CompoundParameter("speed", 99, 1, 100);
    public CompoundParameter reversePoint = new CompoundParameter("actPoint", 10, 1, 360);
    public CompoundParameter lightWidth = new CompoundParameter("lightWidth", 5, 1, 20);


    public Rad(LX lx) {
        super(lx);
        addParameter(refreshV);
        addParameter(reversePoint);
        addParameter(speed);
        addParameter(lightWidth);
    }



    public void run(double deltaMs) {
        timer += deltaMs; // keep track of elapsed time;

        int reset = (int) this.refreshV.getValuef();
        timerStep = 100 - (int) this.speed.getValuef();

        if (reset > this.reversePoint.getValuef() && widthCounter > 20) { // when reset is triggered have the segments start shrinking, dont start shrinking if the segments are too small
            direction = false;
            widthCounter -= reset / 25; // increase the spead in which the segments shrink the bigger they are
        };

        if (widthCounter == 0) widthCounter = 1; // prevent division by 0 errors;


        for (LXPoint p: model.points) {
            positionCounter++;
            if (positionCounter % widthCounter > 1 && positionCounter % widthCounter < (int) this.lightWidth.getValuef()) { // light  the begenning x parts of each segment;
                setColor(p.index, LXColor.rgb(r, g, b));
            } else {
                setColor(p.index, LXColor.rgb(br, bg, bb)); // off every other part
            }
        }


        if ((timer / 10) > timerStep) { //make the situation change depending on elapsed time

            if (direction) {
                widthCounter++;
            } else {
                widthCounter--;
            };
            timer = 0;
        };
 

        positionCounter = 1; //reset counter after elapsed amount of time


        if (widthCounter > 50) positionCounter = 50; // set some boundaries for how big or small a segment gets, and make sure it reverses in direction when it gets too smalls
        if (widthCounter <= 1) direction = true;
        if (widthCounter > 400) widthCounter = 300;


        r = (int)(Math.random() * 255); //change set color on every timer step
        g = (int)(Math.random() * 255);
        b = (int)(Math.random() * 255);

      while(r+g+b / 3 < 255){ // make sure color is bright;
        r = (int)(Math.random() * 255); 
        g = (int)(Math.random() * 255);
        b = (int)(Math.random() * 255);    
      };
      

    }
    
};




public class RadLiq extends LXPattern {

    int[] bcl = {0,0,0};
   
    int counter = 0;
    int segPos = 1;
    int segSize = 20;
    int elapsed = 0;
    int nextRun = 0;
    int frameMs = 1000/ 25;
    
    //public CompoundParameter flasherOn = new CompoundParameter("flasher On", 1, 0, 360);
    public CompoundParameter liquidOn = new CompoundParameter("liquid On", 1, 0, 360);
 //   public CompoundParameter colorOn = new CompoundParameter("color On", 1, 0, 360);
    public CompoundParameter pusherOn = new CompoundParameter("pusherOn", 1, 0, 360);
    
    Animation liquid = new LiquidAnimation(segSize);
//    Animation colorChanger = new ColorChangerAnimation(segSize);
   
    public String getAuthor() {
        return "Raadad Elsleiman";
    }

    public RadLiq(LX lx) {
        super(lx);
        addParameter(liquidOn);
        addParameter(pusherOn);
        bcl = getNewColor();
    }

    public void next(){
         
      for (LXPoint p: model.points) {
        counter = ++counter % segSize;
        int cur = (counter+segPos) % segSize;
        
        int[] cl = null;
          if(cl == null && liquidOn.getValuef() > 0 ) cl = liquid.animate(bcl, cur);
  //        if(colorOn.getValuef() > 0 ) cl = colorChanger.animate(cl, cur);
          if(cl == null) cl = new int[]{0,0,0};
          
         
          
        setColor(p.index, LXColor.rgb(cl[0], cl[1], cl[2]));
      };
      
      liquid.update();
//      colorChanger.update();
     
     
     if(pusherOn.getValuef() > 10) {
        bcl = getNewColor(); 
     };
       //counter = counter segPos
      segPos = ++segPos % segSize;      

      
    };
    
    public void run(double deltaMs) {
      elapsed+=deltaMs;
      while(nextRun < elapsed){
        next();
        //print("madeIt");
        nextRun+=frameMs;
      };      
    }


    public int[] getNewColor() {
      int r = 0;
      int g = 0; 
      int b = 0;
      
      while(r+g+b / 3 < 255){ // make sure color is bright;
        r = (int)(Math.random() * 255); 
        g = (int)(Math.random() * 255);
        b = (int)(Math.random() * 255);    
      };
      
      int[] x = {r,g,b};
      return x;
    };

  
}

public abstract class Animation {
    int segSize;
    int apos = 0;

    public Animation(int segSize) {      
      this.segSize = segSize;
    };

    public abstract int[] animate( int[] bcl, int pos);
 
    public void update() {
      apos++;
      apos = apos % segSize;
    };   
 
};

//public class ColorChangerAnimation extends Animation {
//     public ColorChangerAnimation(int segSize) {
//       super(segSize);
//    };
    
//    public int target = 0;
//    public int source = 0;

//    public int[] animate( int[] bcl, int pos) {
        
//       int[] ncl = new int[]{bcl[0],bcl[1],bcl[2]};
       

//       if(apos == 0){ 
//         if(bcl[0] > bcl[1] && bcl[0] > bcl[2]) source = 0;
//         if(bcl[1] > bcl[2] && bcl[1] > bcl[0]) source = 1;
//         if(bcl[2] > bcl[1] && bcl[2] > bcl[0]) source = 2;

//         int sel = (int) Math.random() * 2;
//         while( sel == source) {
//           print(sel);
//           sel = (int) Math.random() * 3;
//         }
         
//       };
       
//        ncl[source] = apos * (bcl[source]-bcl[target] / segSize);
//        ncl[target] = apos * (bcl[target]-bcl[source] / segSize);
        
//      return ncl;
//    };
    
    
//};
    
public class LiquidAnimation extends Animation {
     public LiquidAnimation(int segSize) {
       super(segSize);
    };


    public int[] getMix(int[]cla, int[] clb){
      int r = cla[0] - (cla[0] - clb[0]) /2; 
      int g = cla[1] - (cla[1] - clb[1]) /2;
      int b = cla[2] - (cla[2] - clb[2]) /2; 
      
      int[] clx = {r,g,b};
      return clx;
    };
    
    public int[] animate( int[] bcl, int pos) {
      
      int r = bcl[0];
      int g = bcl[1];
      int b = bcl[2];
      
      int mid = segSize / 2 ;
      int rpos = segSize - pos;
  
      
      if(pos < mid) {
         r = (r/mid)*(pos); 
         g = (g/mid)*(pos); 
         b = (b/mid)*(pos);          
      } else {
       r = (r/mid)*(rpos); 
       g = (g/mid)*(rpos); 
       b = (b/mid)*(rpos);        
      }
      
      int[] x = {r,g,b};
      return x;
    };

};
   


    
//public class RadFlashAnimator extends LXEffect {
//    int counter = 0;
//    int segPos = 1;
//    int segSize = 20;
//    int elapsed = 0;
//    int nextRun = 0;
//    int frameMs = 1000/ 25;
//    int[] bcl = {0,0,0};
    
   
    
// class FlashAnimation extends Animation {

//    int[][] anim = {
//      {0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0},
//      {0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0},
//      {0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0},
//      {0,0,0,0,0,0,1,1,1,1,0,0,1,1,1,1,0,0,0,0,0,0},
//      {0,0,0,0,1,1,1,1,1,0,0,0,0,1,1,1,1,1,0,0,0,0},
//      {0,0,0,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,0,0,0},
//      {0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0},
//      {0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0},
//      {1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1},
//      {1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1},
//      {1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1},
//      {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
//      {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
//      {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
//    };
    
//    public FlashAnimation(int segSize) {
//      super(segSize);
//    };
    
//    public int[] animate(int[] bcl, int cur) {
//      int buffer = (segSize - anim.length) / 2;
//      int relPos = apos - buffer; 

//      if( relPos > 0 && relPos < anim.length && anim[relPos][cur] == 1 ) {
//        int[] x =  {255,255,255}; 
//        return x;
//      }
//      return null;
//    };

//    public void update() {
//      apos++;
//      if(apos >= anim.length){
//        apos = 0;
//      };
//    };
//};

//     Animation flasher = new FlashAnimation(segSize);

//    public CompoundParameter refreshV = new CompoundParameter("reset", 0, 1, 360);
//    public RadFlashAnimator(LX lx) {
//        super(lx);
//        addParameter(refreshV);
//    }

//    public void run(double deltaMs, double dx) {
//      elapsed+=deltaMs;
      
//      while(nextRun < elapsed){
//        counter = ++counter % segSize;
//        int cur = (counter+segPos) % segSize;
        
//        for (LXPoint p: model.points) {
//            bcl = flasher.animate(bcl, cur);
//            if( bcl!= null) {
//              setColor(p.index, LXColor.rgb(bcl[0], bcl[1], bcl[2]));
//            }
//        }
     
//        flasher.update();
//        nextRun+=frameMs;
//      };     
//    }
//}


public class RadFlash extends LXEffect {

    public CompoundParameter refreshV = new CompoundParameter("reset", 0, 1, 360);
    public CompoundParameter refreshTrigger = new CompoundParameter("resetTrigger", 200, 1, 360);
    public RadFlash(LX lx) {
        super(lx);
        addParameter(refreshV);
        addParameter(refreshTrigger);
    }

    public void run(double deltaMs, double dx) {

        int r = (int)(Math.random() * 255);
        int g = (int)(Math.random() * 255);
        int b = (int)(Math.random() * 255);

        for (LXPoint p: model.points) {
            if (this.refreshV.getValuef() > refreshTrigger.getValuef()) {
                setColor(p.index, LXColor.rgb(r, g, b));
            }
        }
    };
}
