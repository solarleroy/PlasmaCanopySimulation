// Copyright 2019- Mark C. Slee <mcslee@gmail.com>
// Permission granted for use at Burning Seed 2019 - contact me otherwise!

@LXCategory("Form")
public class Oscillate extends LXPattern {
  
  private final static int MAX_DIVISIONS = 10;
  private float[] sinTable = new float[MAX_DIVISIONS];
  
  public final CompoundParameter size =
    new CompoundParameter("Size", 0.25f, 0, 1)
    .setDescription("Size of streaks");
    
  public final CompoundParameter sizeMod =
    new CompoundParameter("SizeMod", 0.1f, 0, 1)
    .setDescription("Modulation of size");
  
  public final CompoundParameter rate = (CompoundParameter)
    new CompoundParameter("Rate", 30000, 120000, 10000)
    .setExponent(.5)
    .setDescription("Rate of streak movement");
    
  public final CompoundParameter invert =
    new CompoundParameter("Inv", .15f, 0, 1)
    .setDescription("Invert colors");
    
  public final DiscreteParameter divisions =
    new DiscreteParameter("Div", 2, 2, MAX_DIVISIONS+1)
    .setDescription("Divisions");
    
  private final QuadraticEnvelope lfo = (QuadraticEnvelope) startModulator(
    new QuadraticEnvelope(0, 1, rate)
    .setEase(QuadraticEnvelope.Ease.BOTH)
    .setLooping(true)
  );
  
  public Oscillate(LX lx) {
    super(lx);
    addParameter("size", this.size);
    addParameter("rate", this.rate);
    addParameter("invert", this.invert);
    addParameter("divisions", this.divisions);
    addParameter("sizeMod", this.sizeMod);
  }
    
  public void run(double deltaMs) {
    float size = this.size.getValuef();
    float invert = this.invert.getValuef();
    float lfo = this.lfo.getValuef();
    for (int i = 0; i < this.sinTable.length; ++i) {
      this.sinTable[i] = .5 + .5 * sin(TWO_PI * ((lfo * (10+i)) % 1.f));
    }
    int ti = 0;
    int divisions = this.divisions.getValuei();
    for (Tube tube : tcr.tubes) {
      float lfo2 = this.sinTable[ti++ % divisions];
      float falloff = 100 / min(1, size + this.sizeMod.getValuef() * lfo2);
      float numPoints = tube.points.size();
      int i = 0;
      for (LXPoint p : tube.points) {
        float b = max(0, 100 - falloff * abs((i / numPoints) - lfo2));
        b = lerp(b, 100-b, invert);
        colors[p.index] = LXColor.gray(b);  
        ++i;
      }
    }
  }
}

@LXCategory("Form")
public class Meteorites extends LXPattern {
  
  private final static int MAX_METEORITES = 50; 
  
  public final CompoundParameter number =
    new CompoundParameter("Num", 40, 5, MAX_METEORITES)
    .setDescription("Number of meteorites");
    
  public final CompoundParameter rate = (CompoundParameter)
    new CompoundParameter("Rate", 3000, 5000, 250)
    .setExponent(.5)
    .setDescription("Rate of motion");
    
  public final CompoundParameter initSize =
    new CompoundParameter("Size", .7, 0, 1)
    .setDescription("Initial size");
    
  public final CompoundParameter endSize =
    new CompoundParameter("End", .5, 0, 1)
    .setDescription("Ending size");
  
  public Meteorites(LX lx) {
    super(lx);
    for (int i = 0; i < MAX_METEORITES; ++i) {
      addLayer(new Meteorite(lx, i));
    }
    addParameter("number", this.number);
    addParameter("rate", this.rate);
    addParameter("initSize", this.initSize);
    addParameter("endSize", this.endSize);
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
  
  }
  
  private class Meteorite extends LXLayer {
    
    private Tube tube;
    
    private final QuadraticEnvelope env =
      new QuadraticEnvelope(0, 1, 1000)
      .setEase(QuadraticEnvelope.Ease.OUT);
    
    private final int index;
    
    private Meteorite(LX lx, int index) {
      super(lx);
      this.index = index;
      addModulator(this.env);
      trigger();
    }
    
    private void trigger() {
      if (this.index < number.getValue()) { 
        this.tube = tcr.tubes[(int) random(tcr.tubes.length - .1)];
        this.env.setRange(random(0, .3), random(.7, 1)).setPeriod(rate.getValuef() * random(.5, 1)).trigger();
      }
    }
    
    public void run(double deltaMs) {
      if (!this.env.isRunning()) {
        trigger();
      }
      if (!this.env.isRunning()) {
        return;
      }
      int pi = 0;
      float bas = this.env.getBasisf();
      float size = (bas < .3) ?
        (bas / .3f * initSize.getValuef()) :       
        lerp(initSize.getValuef(), endSize.getValuef(), (bas - .3f) / .7f);
      float falloff = 100 / size;
      float numPoints = this.tube.points.size();
      float pos = this.env.getValuef();
      float bMax = (bas < .1f) ? (1000 * bas) : (100 - 111*(bas - .1f));
      for (LXPoint p : this.tube.points) {
        float b = bMax - falloff * abs((pi++ / numPoints) - pos);
        if (b > 0) {
          addColor(p.index, LXColor.gray(b));
        }
      }
    }
  }
  
}
