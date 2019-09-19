
import java.util.ArrayList;  
import java.util.Random;
import java.util.ListIterator;

@LXCategory("Color")
public class NoiseGenerator extends LXPattern {

    public final CompoundParameter noiseDetail =
        new CompoundParameter("Detail", 4, 0, 10).setDescription("Noise Detail");
    public final CompoundParameter noiseFallOff =
        new CompoundParameter("FallOff", 0.5, 1).setDescription("Noise FallOff");
    public final CompoundParameter noiseScale =
        new CompoundParameter("Softness", 30, 255).setDescription("Noise Scale");
    private final CompoundParameter seedParam = 
        new CompoundParameter("Seed", 1, 100000).setDescription("Generate a seed");
    public final CompoundParameter motionParam =
        new CompoundParameter("Movement", 0.01, 3).setDescription("Movement");

    float movement = 0.01;
    public final SinLFO rateLfo = new SinLFO(2, 20, 100);

    public NoiseGenerator(LX lx) { 
      super(lx);
        noiseSeed(1);
        this.noiseDetail.setUnits(LXParameter.Units.INTEGER);
        this.seedParam.setUnits(LXParameter.Units.INTEGER);
        addParameter(this.noiseDetail);
        addParameter(this.noiseFallOff);
        addParameter(this.noiseScale);
        addParameter(this.seedParam);
        addParameter(this.motionParam);
        startModulator(this.rateLfo);
    }

    public void run(double deltaMs) {
        noiseDetail((int) this.noiseDetail.getValue(), this.noiseFallOff.getValuef());
        noiseSeed((int) this.seedParam.getValue());
        
        float scale =  this.movement * this.motionParam.getValuef();

        for (LXPoint p : model.points) {

            double brightness = noise(p.x * scale, p.y * scale, p.z * scale) * this.noiseScale.getValue();
            // setColor(p.index, LXColor.gray(brightness));

            int red = (int) Math.round(p.x * brightness);
            int green = (int) Math.round(p.y * brightness);
            int blue = (int) Math.round(p.z * brightness);
            setColor(p.index, LXColor.rgb(red, green, blue));
        }

        movement += rateLfo.getValuef() / 10000;
    }
}

@LXCategory("Color")
public class Starlight extends LXPattern {

        public final CompoundParameter starsParam =
        new CompoundParameter("Stars", 200, 1000).setDescription("Stars");
    public final CompoundParameter lifeParam =
        new CompoundParameter("Life", 0.05, 3).setDescription("Life");

    public String getAuthor() {
        return "Alex Witting";
    }

    private final LXModulator xPos = startModulator(new SinLFO(model.xMin, model.xMax, 1000));

    private ArrayList<Star> stars;

    Random rand = new Random();

    public Starlight(LX lx) {
        super(lx);
        this.starsParam.setUnits(LXParameter.Units.INTEGER);
        addParameter(this.starsParam);
        addParameter(this.lifeParam);

        setupStars();
    }

    private void setupStars() {
        int numStars = (int) this.starsParam.getValue();
        stars = new ArrayList();
        for (int i = 0; i < numStars; ++i) {
            createStar();
        }
    }

    private void createStar() {
        int randomIndex = (int) rand.nextInt(model.points.length - 1) + 1;
        Star star = new Star(randomIndex, random(0, 100));
        setColor(randomIndex, LXColor.gray(star.brightness));
        stars.add(star);
    }

    private void updateStars(int numStars) {
        float life = this.lifeParam.getValuef();
        int createNew = numStars;
        ArrayList<Star> deadStars = new ArrayList();
        for (Star star : this.stars) {
            float brightness = star.getBrightness(life);
            setColor(star.index, LXColor.gray(max(brightness, 0)));
            if(star.brightness <= 0) {
                deadStars.add(star);
                createNew++;
            }
        }

        stars.removeAll(deadStars);
    
        for (int i = 0; i < createNew; ++i) {
              createStar();
        }
    }

    public void run(double deltaMs) {
        int numStars = (int) this.starsParam.getValue();
        int currentStars = this.stars.size();
        
        int count = 0;
        if (currentStars != numStars) {
            if(numStars > currentStars) {
                count = numStars - currentStars;
            } else if (numStars < currentStars) {
                int remove = currentStars - numStars;
                for (int i = 0; i < remove; ++i) {
                    setColor(stars.get(0).index, LXColor.gray(0));
                    stars.remove(0);
                }
            }
        }
        
        updateStars(count);
    }
}

public class Star {
    float brightness;
    int index;

    public Star(int index, float brightness) {
        this.index = index;
        this.brightness = brightness;
    }

    public float getBrightness(float life) {
        this.brightness -= life;
        return this.brightness;
    }
}
