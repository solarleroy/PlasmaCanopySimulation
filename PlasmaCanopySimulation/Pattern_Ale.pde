 /*this code is written for use during Burning Seed 2019, running from the 25th September to 2nd of October 2019 in Melbourne, Australia.
 may it become a more complex pattern!

 current situation: three spheres, floating in a 3d box (xmin-xmax. ymin-yman, zmin-zmax are its dimensions) and bouncing constrained inside it.

todo : -inject variable speed into pattern maintaining box constraint
       -generalise to obtain an arbitrary n of spheres/particles
 add interaction between balls

 /to use the pattern in a pretty way: overlay it to a colored pattern, link radius/parameter1/thicknes (one of or all of them) to fft triggers
 enjoy Seed!

 Ale*/
 
 public class floatingBalls extends LXPattern { 

    public String getAuthor() {
     return "Alessandro Cesana,  https://github.com/alecesana , cesaless@gmail.com ";
   }

 

     //------------- Parameters affecting grayscale pattern (currently not in use)
    public final CompoundParameter FalloffA= (CompoundParameter)
     new CompoundParameter("FalloffA",1, 1, 50) 
     .setDescription("Falloff A");
    
        public final CompoundParameter FalloffB = (CompoundParameter)
     new CompoundParameter("FalloffB",2, 1, 11) 
     .setDescription(" Falloff B");
    
        public final CompoundParameter speed = (CompoundParameter)
     new CompoundParameter("speed",0.1, 0.001, 1) 
     .setDescription(" C");
    
    // public final CompoundParameter D = (CompoundParameter)
    // new CompoundParameter("D",1, -10, 10) 
    // .setDescription("D");
    
     //----------------------------------------
    
        public final CompoundParameter radius= (CompoundParameter)
     new CompoundParameter("radius",1, 0, 4) 
     .setDescription(" Sphere radius");
    
        public final CompoundParameter parameter1 = (CompoundParameter)
     new CompoundParameter("parameter1",1, 1, 20) 
     .setDescription(" sphere oscillation period");
    
        public final CompoundParameter thickness = (CompoundParameter)
     new CompoundParameter("thickness",1, 0.1, 14) 
     .setDescription(" sphere thickness");

    
     //----------------------------------------
    

     ///------------------------------------------------------------

    
   
     int nBalls = 10;
     float[] ballPosition = new float[nBalls * 3];  
     float[] ballSpeed = new float[nBalls * 3]; 


     public floatingBalls(LX lx) {
     super(lx);

     addParameter("FalloffA", this.FalloffA); 
     addParameter("FalloffB", this.FalloffB);
     addParameter("speed", this.speed);
     //addParameter("D", this.D);
 
    
   
     addParameter("radius", this.radius);
     addParameter("parameter1", this.parameter1);
     addParameter("thickness", this.thickness);
    
   
    

    
        // print("--------------");
        // print(ballPosition.length);
        // print("--------------");

        //initializing things
        for(int i = 0 ;i< ballPosition.length; i+=3){
                ballPosition[0+i] = random(model.xMin,model.xMax);
                ballPosition[1+i] = random(model.yMin, model.yMax);
                ballPosition[2+i] = random(model.zMin, model.zMax);

                ballSpeed[0+i] = random(-1,1);
                ballSpeed[1+i] = random(-1,1);
                ballSpeed[2+i] = random(-1,1);
        }
   }
  //s1p,r1p to be addressed for each ball?
   public void run(double deltaMs) {

     float falloffA = (this.FalloffA.getValuef());
     float falloffB = (this.FalloffB.getValuef());
     float speed = (this.speed.getValuef());

        //ballSpeed parametrize
        //----------------------------------
     float radius = (this.radius.getValuef());
     float parameter1 = (this.parameter1.getValuef());      
     float thickness = (this.thickness.getValuef());
    
         

     float radius2 = radius/3;
     float parameter2 = parameter1/3;   
     float thickness2 = thickness/3; 

     float radius3 = radius/2;
     float parameter3 = parameter1/2;   
     float thickness3 = thickness/2;   

      

        //balls moving logic
        for(int i = 0; i< ballPosition.length ;i+=3){
                //ballSpeed[0+i] = speed;    

              //ballSpeed[0+i] = speed;    
              //ballSpeed[1+i] = speed;
              //ballSpeed[2+i] = speed;
                //--------------- 
                if (ballPosition[0+i] >= model.xMax){
                        ballPosition[0+i]  = model.xMax;
                        ballSpeed[0+i] *= -1;


                }	
                if (ballPosition[0+i] <= model.xMin){
                        ballPosition[0+i]  = model.xMin;
                        ballSpeed[0+i] *= -1;
                }
                //--------------- 
                if (ballPosition[1+i] >= model.yMax){
                        ballPosition[1+i]  = model.yMax;
                        ballSpeed[1+i] *= -1;
                }	
                if (ballPosition[1+i] <= model.yMin){
                        ballPosition[1+i]  = model.yMin;
                        ballSpeed[1+i] *= -1;
                }

                //---------------- 
                if (ballPosition[2+i] >= model.zMax){
                        ballPosition[2+i]  = model.zMax;
                        ballSpeed[2+i] *= -1;
                }	
                if (ballPosition[2+i] <= model.zMin){
                        ballPosition[2+i]  = model.zMin;
                        ballSpeed[2+i] *= -1;
                }

                ballPosition[0+i] += ballSpeed[0+i];
                ballPosition[1+i] += ballSpeed[1+i];
                ballPosition[2+i] += ballSpeed[2+i];

                //debugging
                // println("----------------------");
                // println("ball n"+ i/3 );
                // println(ballPosition[0+i]);
                // println(ballPosition[1+i]);
                // println(ballPosition[2+i]);
                // println("----------------------");

                
        }

         float falloff = 100.0 / falloffA;
         float pos = falloffB;

                            float n = 0;
        for  (LXPoint p : model.getPoints()) {   
                //recursion to address all balls using for cycle doesn't work
                //for(int i =0 ;i< ballPosition.length; i+=3){
                        int i =0;
                        if( 
                                (       
                                        (sqrt ( pow(abs( p.x  - ballPosition[0+i]), 2) + 
                                                pow(abs( p.y  - ballPosition[1+i]), 2) + 
                                                pow(abs( p.z  - ballPosition[2+i]), 2))>= (parameter1 * radius) ) &&
                                        (sqrt ( pow(abs( p.x  - ballPosition[0+i]), 2) + 
                                                pow(abs( p.y  - ballPosition[1+i]), 2) + 
                                                pow(abs( p.z  - ballPosition[2+i]), 2))<=(parameter1 *(radius+thickness)))        
                
                                )
                                
                                || (       
                                        (sqrt ( pow(abs( p.x  - ballPosition[3+i]), 2) + 
                                                pow(abs( p.y  - ballPosition[4+i]), 2) + 
                                                pow(abs( p.z  - ballPosition[5+i]), 2))>= (parameter2 * radius2) ) &&
                                        (sqrt ( pow(abs( p.x  - ballPosition[3+i]), 2) + 
                                                pow(abs( p.y  - ballPosition[4+i]), 2) + 
                                                pow(abs( p.z  - ballPosition[5+i]), 2))<=(parameter2 *(radius2+thickness2)))        
                
                                )
                                || (       
                                        (sqrt ( pow(abs( p.x  - ballPosition[6+i]), 2) + 
                                                pow(abs( p.y  - ballPosition[7+i]), 2) + 
                                                pow(abs( p.z  - ballPosition[8+i]), 2))>= (parameter3 * radius3) ) &&
                                        (sqrt ( pow(abs( p.x  - ballPosition[6+i]), 2) + 
                                                pow(abs( p.y  - ballPosition[7+i]), 2) + 
                                                pow(abs( p.z  - ballPosition[8+i]), 2))<=(parameter3 *(radius3+thickness3)))        
                
                                )
                        )

                        //todo : address color in more interesting grayscale pattern than white/black
                        
                           

                        colors[p.index] = LXColor.gray(max(0, 100 - falloff*abs(n - pos))); 
                  
                        else {setColor(p.index,#000000);}
        // }
        }

 } //run thread closing bracket



 }
