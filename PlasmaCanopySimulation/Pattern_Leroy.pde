@LXCategory(LXCategory.TEXTURE)
public class BitCrush extends LXEffect {

    public CompoundParameter h_bits =
        new CompoundParameter("hue Bits", 360,1,360)
        .setDescription("Granularity of hue");
    public CompoundParameter s_bits =
        new CompoundParameter("sat Bits", 100,1,100)
        .setDescription("Granularity of hue");
    public CompoundParameter b_bits =
        new CompoundParameter("bright Bits", 100,1,100)
        .setDescription("Granularity of hue");

    public BitCrush(LX lx) {
        super(lx);
        addParameter("h bits", this.h_bits);
        addParameter("s bits", this.s_bits);
        addParameter("b bits", this.b_bits);
    }

    protected int crushBits(int index){
        double h_buckets = Math.ceil(this.h_bits.getValuef());
        double s_buckets = Math.ceil(this.s_bits.getValuef());
        double b_buckets = Math.ceil(this.b_bits.getValuef());

        double h_ratio = (1/360.0)*h_buckets;
        double s_ratio = (1/100.0)*s_buckets;
        double b_ratio = (1/100.0)*b_buckets;

        int h_in = (int)LXColor.h(this.colors[index]);
        int s_in = (int)LXColor.s(this.colors[index]);
        int b_in = (int)LXColor.b(this.colors[index]);

        double h_out = Math.round(h_ratio*h_in)/h_ratio;
        double s_out = Math.round(s_ratio*s_in)/s_ratio;
        double b_out = Math.round(b_ratio*b_in)/b_ratio;

        return LXColor.hsb(
            (int)h_out,
            (int)s_out,
            (int)b_out
        );
    }

    @Override
    protected void run(double deltaMs, double enabledAmount) {
        for (int i = 0; i < this.colors.length; ++i) {
            this.colors[i] = crushBits(i);
        }
    }
}

@LXCategory(LXCategory.TEXTURE)
public class BitCrushColour extends BitCrush {

    public CompoundParameter colourbits =
        new CompoundParameter("Bits", 256,2,256)
        .setDescription("Granularity of colour");

    public BitCrushColour(LX lx) {
        super(lx);
        addParameter("Bits", this.colourbits);
        removeParameter(this.h_bits);
        removeParameter(this.s_bits);
        removeParameter(this.b_bits);
    }

    @Override
    protected int crushBits(int index){
        double buckets = Math.ceil(this.colourbits.getValuef());
        double ratio = (1/256.0)*buckets;

        int red_in = (int)LXColor.red(this.colors[index]);
        int blue_in = (int)LXColor.blue(this.colors[index]);
        int green_in = (int)LXColor.green(this.colors[index]);

        double red_out = Math.round(ratio*red_in)/ratio;
        double blue_out = Math.round(ratio*blue_in)/ratio;
        double green_out = Math.round(ratio*green_in)/ratio;

        return LXColor.rgb(
            (int)red_out,
            (int)green_out,
            (int)blue_out
        );
    }
}