import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;

// In this file you can define your own custom patterns

// Here is a fairly basic example pattern that renders a plane that can be moved
// across one of the axes.
@LXCategory("Form")
public static class PlanePattern extends LXPattern {
  
  public enum Axis {
    X, Y, Z
  };
  
  public final EnumParameter<Axis> axis =
    new EnumParameter<Axis>("Axis", Axis.X)
    .setDescription("Which axis the plane is drawn across");
  
  public final CompoundParameter pos = new CompoundParameter("Pos", 0, 1)
    .setDescription("Position of the center of the plane");
  
  public final CompoundParameter wth = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thickness of the plane");
  
  public PlanePattern(LX lx) {
    super(lx);
    addParameter("axis", this.axis);
    addParameter("pos", this.pos);
    addParameter("width", this.wth);
  }
  
  public void run(double deltaMs) {
    float pos = this.pos.getValuef();
    float falloff = 100 / this.wth.getValuef();
    float n = 0;
    for (LXPoint p : model.points) {
      switch (this.axis.getEnum()) {
      case X: n = p.xn; break;
      case Y: n = p.yn; break;
      case Z: n = p.zn; break;
      }
      colors[p.index] = LXColor.gray(max(0, 100 - falloff*abs(n - pos))); 
    }
  }
}

@LXCategory("Color")
public static class SimpleColour extends LXPattern {
  
  public SimpleColour(LX lx) {
    super(lx);
  }
  
  public void run(double deltaMs) {
    for (LXPoint p : model.points) {
      colors[p.index] = palette.getColor();
    }
  }
}

// Very simple pattern, just has one parameter and one LFO
@LXCategory("Form")
public class SimpleStripe extends LXPattern {
  
  public final CompoundParameter period = (CompoundParameter)
    new CompoundParameter("Period", 1000, 500, 10000)
    .setExponent(2)
    .setDescription("Period of oscillation of the stripe");
    
    public final CompoundParameter size = (CompoundParameter)
    new CompoundParameter("Size", 3*FEET, 1*FEET, 10*FEET)
    .setDescription("Size of the stripe");
  
  private final LXModulator xPos = startModulator(new SinLFO(model.xMin, model.xMax, period));

  
  public SimpleStripe(LX lx) {
    super(lx);
    
    // Parameters automatically appear in UI and are saved in project file
    addParameter("period", this.period);
    addParameter("size", this.size);
  }
  
  public void run(double deltaMs) {
    float xPos = this.xPos.getValuef();
    float falloff = 100 / this.size.getValuef();
    for (LXPoint p : model.points) {
      // Render each point based on its distance from a moving target position in the x axis 
      colors[p.index] = palette.getColor((double)max(0, 100 - falloff * abs(p.x - xPos)));
    }
  }
}

// This pattern makes use of the layer construct
@LXCategory("Form")
public class LayerDemo extends LXPattern {
  
  private final CompoundParameter numStars = (CompoundParameter)
    new CompoundParameter("Stars", 100, 0, 100)
    .setDescription("Number of star layers");
  
  public LayerDemo(LX lx) {
    super(lx);
    addParameter("numStars", this.numStars);
    
    // Layers are automatically rendered on every pass
    addLayer(new CircleLayer(lx));
    addLayer(new RodLayer(lx));
    for (int i = 0; i < 200; ++i) {
      addLayer(new StarLayer(lx));
    }
  }
  
  public void run(double deltaMs) {
    // Blank everything out first
    setColors(#000000);
    
    // The added layers are automatically called after our
    // run() method, no need to manually call them
  }
  
  private class CircleLayer extends LXLayer {
    
    private final SinLFO xPeriod = new SinLFO(3400, 7900, 11000); 
    
    // Note how one LFO can be a parameter to another LFO!
    private final SinLFO brightnessX = new SinLFO(model.xMin, model.xMax, xPeriod);
  
    private CircleLayer(LX lx) {
      super(lx);
      startModulator(this.xPeriod);
      startModulator(this.brightnessX);
    }
    
    public void run(double deltaMs) {
      float falloff = 100 / (4*FEET);
      float brightnessX = this.brightnessX.getValuef();
      for (LXPoint p : model.points) {
        float yWave = model.yRange/2 * sin(p.x / model.xRange * PI); 
        float distanceFromBrightness = dist(p.x, abs(p.y - model.cy), brightnessX, yWave);
        colors[p.index] = palette.getColor((double) max(0, 100 - falloff*distanceFromBrightness));
      }
    }
  }
  
  private class RodLayer extends LXLayer {
    
    private final SinLFO zPeriod = new SinLFO(2000, 5000, 9000);
    private final SinLFO zPos = new SinLFO(model.zMin, model.zMax, zPeriod);
    
    private RodLayer(LX lx) {
      super(lx);
      startModulator(this.zPeriod);
      startModulator(this.zPos);
    }
    
    public void run(double deltaMs) {
      float zPos = this.zPos.getValuef();
      for (LXPoint p : model.points) {
        double b = 100 - dist(p.x, p.y, model.cx, model.cy) - abs(p.z - zPos);
        if (b > 0) {
          addColor(p.index, palette.getColor( b));
        }
      }
    }
  }
  
  private class StarLayer extends LXLayer {
    
    private final TriangleLFO maxBright = new TriangleLFO(0, numStars, random(2000, 8000));
    private final SinLFO brightness = new SinLFO(-1, maxBright, random(3000, 9000)); 
    
    private int index = 0;
    
    private StarLayer(LX lx) { 
      super(lx);
      startModulator(this.maxBright);
      startModulator(this.brightness);
      pickStar();
    }
    
    private void pickStar() {
      index = (int) random(0, model.size-1);
    }
    
    public void run(double deltaMs) {
      double brightness = this.brightness.getValuef(); 
      if (brightness <= 0) {
        pickStar();
      } else {
        addColor(index, palette.getColor( 50, brightness));
      }
    }
  }
}
@LXCategory("Form")
public class Tumbler extends LXPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  private LXModulator azimuthRotation = startModulator(new SawLFO(0, 1, 15000).randomBasis());
  private LXModulator thetaRotation = startModulator(new SawLFO(0, 1, 13000).randomBasis());
  
  public Tumbler(LX lx) {
    super(lx);
  }
    
  public void run(double deltaMs) {
    float azimuthRotation = this.azimuthRotation.getValuef();
    float thetaRotation = this.thetaRotation.getValuef();
    for (LXPoint leaf : model.points) {
      float tri1 = trif(azimuthRotation + leaf.azimuth / PI);
      float tri2 = trif(thetaRotation + (PI + leaf.theta) / PI);
      float tri = max(tri1, tri2);
      setColor(leaf.index, LXColor.gray(100 * tri * tri));
    }
  }
  private float trif(double t){
    t =t -Math.floor(t);
    if(t<0.25){
      return (float) t*4;
    }else if(t<0.75){
      return (float)(1-4*(t-0.25));
    }else{
      return (float) (-1+4*(t-0.75));
    }

  }
}

@LXCategory("Form")
public class Scanner extends LXPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }
  
  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", .5, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Speed that the plane moves at");
    
  public final CompoundParameter sharp = (CompoundParameter)
    new CompoundParameter("Sharp", 0, -50, 150)
    .setDescription("Sharpness of the falling plane")
    .setExponent(2);
    
  public final CompoundParameter xSlope = (CompoundParameter)
    new CompoundParameter("XSlope", 0, -1, 1)
    .setDescription("Slope on the X-axis");
    
  public final CompoundParameter zSlope = (CompoundParameter)
    new CompoundParameter("ZSlope", 0, -1, 1)
    .setDescription("Slope on the Z-axis");
  
  private float basis = 0;
  
  public Scanner(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("sharp", this.sharp);
    addParameter("xSlope", this.xSlope);
    addParameter("zSlope", this.zSlope);
  }
  
  public void run(double deltaMs) {
    float speed = this.speed.getValuef();
    speed = speed * speed * ((speed < 0) ? -1 : 1);
    float sharp = this.sharp.getValuef();
    float xSlope = this.xSlope.getValuef();
    float zSlope = this.zSlope.getValuef();
    this.basis = (float) (this.basis - .001 * speed * deltaMs) % 1.;
    for (LXPoint leaf : model.points) {
      setColor(leaf.index, LXColor.gray(max(0, 50 - sharp + (50 + sharp) * LXUtils.trif(leaf.yn + this.basis + (leaf.xn-.5) * xSlope + (leaf.zn-.5) * zSlope))))  ;
    }
  }
}