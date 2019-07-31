@LXCategory(LXCategory.TEXTURE)
public class BitCrush extends LXEffect {

  public final CompoundParameter bits =
    new CompoundParameter("Bits", 100,1,100)
    .setDescription("Granularity of brightness");

  public BitCrush(LX lx) {
    super(lx);
    addParameter("bits", this.bits);
  }

  private int crushBits(int index){
    double buckets = Math.ceil(this.bits.getValuef());
    double ratio = (1/100.0)*buckets;
    int b_in = (int)LXColor.b(this.colors[index]);
    double b_out = Math.round(ratio*b_in)/ratio;

    return LXColor.hsb(
      LXColor.h(this.colors[index]),
      LXColor.s(this.colors[index]),
      b_out);
  }

  @Override
  protected void run(double deltaMs, double enabledAmount) {
      for (int i = 0; i < this.colors.length; ++i) {
         this.colors[i] = crushBits(i);
      }
  }
}