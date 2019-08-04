 //this code is written for use during Burning Seed 2019, running from the 25th September to 2nd of October 2019 in Melbourne, Australia.
 //Use of the code for another event or purpose may be granted upon discussion with the author about type and purpose of the project. 
 

//todo : address color in more interesting grayscale pattern than white/black
//fix recursion to draw arbitrary n of balls
//link balls parameters to sound triggers
//affect direction of balls in more interesting way than straight line direction
 
 public class A10 extends LXPattern { 

    public String getAuthor() {
     return "Alessandro Cesana,  https://github.com/alecesana , cesaless@gmail.com ";
   }

 

     //------------- Parameters affecting grayscale pattern (currently not in use)
    public final CompoundParameter A= (CompoundParameter)
     new CompoundParameter("A",1, 1, 50) 
     .setDescription(" A");
    
        public final CompoundParameter B = (CompoundParameter)
     new CompoundParameter("B",2, 1, 70) 
     .setDescription(" B");
    
        public final CompoundParameter C = (CompoundParameter)
     new CompoundParameter("C",1, 1, 200) 
     .setDescription(" C");
    
     public final CompoundParameter D = (CompoundParameter)
     new CompoundParameter("D",1, -10, 10) 
     .setDescription("D");
    
     //----------------------------------------
    
        public final CompoundParameter s1R= (CompoundParameter)
     new CompoundParameter("s1R",1, 0, 4) 
     .setDescription(" Sphere1 radius");
    
        public final CompoundParameter s1p = (CompoundParameter)
     new CompoundParameter("s1p",1, 1, 20) 
     .setDescription(" sphere1 oscillation period(everything else oscillates with it when Olink set to true) ");
    
        public final CompoundParameter s1t = (CompoundParameter)
     new CompoundParameter("s1 thickness",1, 0.1, 4) 
     .setDescription(" sphere1 thickness");
    
     //----------------------------------------
     public final CompoundParameter s2R = (CompoundParameter)
     new CompoundParameter("s2R",2, 0.01, 4) 
     .setDescription("Sphere2 radius");
    
        public final CompoundParameter s2p = (CompoundParameter)
     new CompoundParameter("s2p",1, 1, 5) 
     .setDescription(" Sphere2 radius");
    
     public final CompoundParameter s2t = (CompoundParameter)
     new CompoundParameter("s2 thickness",0.29, 0.01, 6) 
     .setDescription(" Sphere2 radius");
    
     //----------------------------------------
    

     ///------------------------------------------------------------

    
     public final BooleanParameter OLink = (BooleanParameter)
     new BooleanParameter("OLink", true)
     .setDescription("not in use atm");
    
     public final BooleanParameter floorSwitch = (BooleanParameter)
     new BooleanParameter("floorswitch", false)
     .setDescription("not in use atm");
    
     int nBalls = 10;
     float[] cP = new float[nBalls * 3];  
     float[] cS = new float[nBalls * 3]; 


     public A10(LX lx) {
     super(lx);

     addParameter("A", this.A);
     addParameter("B", this.B);
     addParameter("C", this.C);
     addParameter("D", this.D);
    
     addParameter("OLink", this.OLink);
     addParameter("floorswitch", this.floorSwitch);
    
   
     addParameter("s1R", this.s1R);
     addParameter("s1P", this.s1p);
     addParameter("s1t", this.s1t);
    
        
     addParameter("s2R", this.s2R);
     addParameter("s2p", this.s2p);
     addParameter("s2t", this.s2t);
    

    
        // print("--------------");
        // print(cP.length);
        // print("--------------");

        //initializing things
        for(int i = 0 ;i< cP.length; i+=3){
                cP[0+i] = random(model.xMin,model.xMax);
                cP[1+i] = random(model.yMin, model.yMax);
                cP[2+i] = random(model.zMin, model.zMax);

                cS[0+i] = random(-1,1);
                cS[1+i] = random(-1,1);
                cS[2+i] = random(-1,1);
        }
   }
  //s1p,r1p to be addressed for each ball?
   public void run(double deltaMs) {

     float a = (this.A.getValuef());
     float b = (this.B.getValuef());
     float c = (this.C.getValuef());
     float d = (this.D.getValuef());
     boolean olink= (this.OLink.getValueb());
     boolean floorswitch= (this.floorSwitch.getValueb());

     //----------------------------------
     float r1 = (this.s1R.getValuef());
     float s1P = (this.s1p.getValuef());      
     float s1t = (this.s1t.getValuef());
    
     float s2P,s3P,s4P,s5P, s62;
          s2P = (this.s1p.getValuef());      

     float r2 = (this.s2R.getValuef());
     float s2t = (this.s2t.getValuef());
      

        //balls moving logic
        for(int i = 0; i< cP.length ;i+=3){

                //--------------- 
                if (cP[0+i] >= model.xMax){
                        cP[0+i]  = model.xMax;
                        cS[0+i] *= -1;
                }	
                if (cP[0+i] <= model.xMin){
                        cP[0+i]  = model.xMin;
                        cS[0+i] *= -1;
                }
                //--------------- 
                if (cP[1+i] >= model.yMax){
                        cP[1+i]  = model.yMax;
                        cS[1+i] *= -1;
                }	
                if (cP[1+i] <= model.yMin){
                        cP[1+i]  = model.yMin;
                        cS[1+i] *= -1;
                }

                //---------------- 
                if (cP[2+i] >= model.zMax){
                        cP[2+i]  = model.zMax;
                        cS[2+i] *= -1;
                }	
                if (cP[2+i] <= model.zMin){
                        cP[2+i]  = model.zMin;
                        cS[2+i] *= -1;
                }

                cP[0+i] += cS[0+i];
                cP[1+i] += cS[1+i];
                cP[2+i] += cS[2+i];

                //debugging
                // println("----------------------");
                // println("ball n"+ i/3 );
                // println(cP[0+i]);
                // println(cP[1+i]);
                // println(cP[2+i]);
                // println("----------------------");

                
        }


        for  (LXPoint p : model.getPoints()) {   
                //recursion to address all balls using for cycle doesn't work
                //for(int i =0 ;i< cP.length; i+=3){
                        int i =0;
                        if( 
                                (       
                                        (sqrt ( pow(abs( p.x  - cP[0+i]), 2) + 
                                                pow(abs( p.y  - cP[1+i]), 2) + 
                                                pow(abs( p.z  - cP[2+i]), 2))>= (s1P * r1) ) &&
                                        (sqrt ( pow(abs( p.x  - cP[0+i]), 2) + 
                                                pow(abs( p.y  - cP[1+i]), 2) + 
                                                pow(abs( p.z  - cP[2+i]), 2))<=(s1P *(r1+s1t)))        
                
                                )
                                
                                || (       
                                        (sqrt ( pow(abs( p.x  - cP[3+i]), 2) + 
                                                pow(abs( p.y  - cP[4+i]), 2) + 
                                                pow(abs( p.z  - cP[5+i]), 2))>= (s1P * r1) ) &&
                                        (sqrt ( pow(abs( p.x  - cP[3+i]), 2) + 
                                                pow(abs( p.y  - cP[4+i]), 2) + 
                                                pow(abs( p.z  - cP[5+i]), 2))<=(s1P *(r1+s1t)))        
                
                                )
                                || (       
                                        (sqrt ( pow(abs( p.x  - cP[6+i]), 2) + 
                                                pow(abs( p.y  - cP[7+i]), 2) + 
                                                pow(abs( p.z  - cP[8+i]), 2))>= (s2P * r2) ) &&
                                        (sqrt ( pow(abs( p.x  - cP[6+i]), 2) + 
                                                pow(abs( p.y  - cP[7+i]), 2) + 
                                                pow(abs( p.z  - cP[8+i]), 2))<=(s2P *(r2+s2t)))        
                
                                )
                        )

                        //todo : address color in more interesting grayscale pattern than white/black
                        {
                        setColor(p.index, #FFFFFF);
                        }
                        else {setColor(p.index,#000000);}
        // }
        }

 } //run thread closing bracket



 }
 
  
