public class UISpiderTruss extends UI3dComponent{
    private final float RAD = 5*METRE;
    private final float THETA = (float)Math.PI/3;
    private final float SPACING = 5*METRE*(float)Math.sqrt(2);
    private final float TRUSS_RADIUS = 10*CM;
    private final float HORIZONTAL_TRUSS_LENGTH = (float)Math.sqrt(2)*TRUSS_RADIUS;

    UITrussRing ring;
    UITrussRing[] legs = new UITrussRing[6];

    public UISpiderTruss(){
        ring = new UITrussRing();

        for( int i=0;i<6;++i ) {
            legs[i] = new UITrussRing(5*METRE, 0.25);
        }
    }

    @Override
    protected void onDraw(UI ui, PGraphics pg){
        // move 0,0 to top
        pg.pushMatrix();

        pg.translate(0,1.5*METRE-HORIZONTAL_TRUSS_LENGTH, 0);
        ring.onDraw(ui, pg);

        pg.popMatrix();

        for( int i=0;i<6;++i ) {
            float yaw = i*THETA-PI/12+PI/24;
            float x = (RAD/2+HORIZONTAL_TRUSS_LENGTH) * (float)Math.cos(Math.PI/4-yaw);
            float z = (RAD/2+HORIZONTAL_TRUSS_LENGTH) * (float)Math.sin(Math.PI/4-yaw);

            pg.pushMatrix();
            pg.translate(x, -3.5*METRE, z);
            pg.rotateX(0);
            pg.rotateY(yaw + PI/4);
            pg.rotateZ(PI/2);
            pg.translate(0,0,-5*METRE+UITrussRing.BOX_TRUSS_WIDTH);
            this.legs[i].onDraw(ui,pg);
            pg.popMatrix();
        }
    }
}

public class UITubeSegment extends UI3dComponent{
    LXPoint point;
    UICylinder tube;
    LXMatrix m;
    private final float RADIUS = 2.5*CM;
    private final int DETAIL = 6;

    UITubeSegment(LXTransform t, LXPoint p){
        m = new LXMatrix(t.getMatrix());
        tube = new UICylinder(RADIUS, METRE/60, DETAIL);
        point = p;
    }
    public void onDraw(UI ui, PGraphics pg){
        pg.pushMatrix();
        pg.applyMatrix(m.m11,m.m12,m.m13,m.m14,m.m21,m.m22,m.m23,m.m24,m.m31,m.m32,m.m33,m.m34,m.m41,m.m42,m.m43,m.m44);
        pg.rotateZ(PI/2);
        tube.updateColour(lx.getColors()[point.index]);
        tube.onDraw(ui,pg);
        pg.popMatrix();
    }
}

public static abstract class UITrussLeg extends UI3dComponent{
    protected final float MAIN_TUBE_DIAMETER = 3.5*CM;
    protected final float SUPPORT_TUBE_DIAMETER = 1.5*CM;
    protected final float TRUSS_HEIGHT = 1.95*METRE;
    protected static final float TRUSS_RADIUS = 10*CM;
    protected static final float HORIZONTAL_LENGTH = (float)Math.sqrt(2)*TRUSS_RADIUS;
    protected final float ANGLED_LENGTH =(float)Math.sqrt(2)*HORIZONTAL_LENGTH;
    protected float[] v;

}

public static class UITrussRing extends UI3dComponent{
    
    public static final float BOX_TRUSS_WIDTH = 20 * CM;

    private UIGenericTrussRing[] rings = new UIGenericTrussRing[4];

    public UITrussRing(float radius, float portion){
        this.rings[0] = new UIGenericTrussRing(0,0,0,radius,portion);
        this.rings[1] = new UIGenericTrussRing(0,BOX_TRUSS_WIDTH,0,radius, portion);
        this.rings[2] = new UIGenericTrussRing(0,0,0,radius - BOX_TRUSS_WIDTH,portion);
        this.rings[3] = new UIGenericTrussRing(0,BOX_TRUSS_WIDTH,0,radius - BOX_TRUSS_WIDTH, portion);
    }

    public UITrussRing(){
        this.rings[0] = new UIGenericTrussRing(0,0,0,1.5*METRE);
        this.rings[1] = new UIGenericTrussRing(0,BOX_TRUSS_WIDTH,0,1.5*METRE);
        this.rings[2] = new UIGenericTrussRing(0,0,0,1.5*METRE - BOX_TRUSS_WIDTH);
        this.rings[3] = new UIGenericTrussRing(0,BOX_TRUSS_WIDTH,0,1.5*METRE - BOX_TRUSS_WIDTH);
    }

    protected void onDraw(UI ui, PGraphics pg) {
        pg.pushMatrix();
        this.rings[0].onDraw(ui,pg);
        this.rings[1].onDraw(ui,pg);
        this.rings[2].onDraw(ui,pg);
        this.rings[3].onDraw(ui,pg);
        pg.popMatrix();
    }
}

public static class UIGenericTrussRing extends UITrussLeg{
    protected final int DETAIL = 50;
    protected final float ARC = ((float)Math.PI*2);
    protected float radius;
    protected float arc_length;
    protected float length;
    protected float portion = 1;

    public UIGenericTrussRing(float x,float y,float z,float radius, float portion){
        this(x,y,z,radius);
        this.portion = portion;
    }
    
    public UIGenericTrussRing(float x,float y,float z,float radius){
        this.v = new float[]{x,y,z,0,0,0};
        this.radius = radius;
        this.arc_length = radius * (float)Math.tan(ARC/DETAIL);
        this.length = PI * 2 * radius;
    }
    
    public UIGenericTrussRing(float x,float y,float z,float x_rot, float y_rot, float z_rot, float radius, float portion){
        this.v = new float[]{x,y,z, x_rot, y_rot, z_rot};
        this.radius = radius;
        this.arc_length = radius * (float)Math.tan(ARC/DETAIL);
        this.length = PI * 2 * radius;
        this.portion = portion;
    }
    @Override
    protected void onDraw(UI ui, PGraphics pg){
        //Structural elements
        pg.pushMatrix();
        pg.translate(v[0],v[1]-HORIZONTAL_LENGTH/2,v[2]);
        pg.rotateX(v[3]);
        pg.rotateY(v[4]);
        pg.rotateZ(v[5]);
        for(int i =0;i<DETAIL*portion;++i){
            pg.pushMatrix();
            pg.rotateY(i*ARC/DETAIL);
            pg.translate(radius,0,0);
            pg.rotateY((PI - 2*PI/DETAIL)/2);
            pg.rotateZ(PI/2);
            new UICylinder( MAIN_TUBE_DIAMETER/2, length / DETAIL,DETAIL).onDraw(ui,pg);
            pg.popMatrix();
        }
        pg.popMatrix();
    }
}


public static class UICylinder extends UI3dComponent {
    
    private final PVector[] base;
    private final PVector[] top;
    private final int detail;
    public final float len;
    private int colour = #555555;
    
    public UICylinder(float radius, float len, int detail) {
        this(radius, radius, 0, len, detail);
    }
    
    public UICylinder(float baseRadius, float topRadius, float len, int detail) {
        this(baseRadius, topRadius, 0, len, detail);
    }
    
    public UICylinder(float baseRadius, float topRadius, float yMin, float yMax, int detail) {
        this.base = new PVector[detail];
        this.top = new PVector[detail];
        this.detail = detail;
        this.len = yMax - yMin;
        for (int i = 0; i < detail; ++i) {
            float angle = i * TWO_PI / detail;
            this.base[i] = new PVector(baseRadius * cos(angle), yMin, baseRadius * sin(angle));
            this.top[i] = new PVector(topRadius * cos(angle), yMax, topRadius * sin(angle));
        }
    }

    protected void beginDraw(UI ui, PGraphics pg) {
        float level = 255;
        pg.pointLight(level, level, level, -10*FEET, 30*FEET, -30*FEET);
        pg.pointLight(level, level, level, 30*FEET, 20*FEET, -20*FEET);
        pg.pointLight(level, level, level, 0, 0, 30*FEET);
    }
        
    public void onDraw(UI ui, PGraphics pg) {
        pg.beginShape(TRIANGLE_STRIP);
        for (int i = 0; i <= this.detail; ++i) {
            int ii = i % this.detail;
            pg.vertex(this.base[ii].x, this.base[ii].y, this.base[ii].z);
            pg.vertex(this.top[ii].x, this.top[ii].y, this.top[ii].z);
            pg.stroke(colour);
        }
        pg.fill(colour);
        pg.endShape(CLOSE);

    }
    public void updateColour(int colour){
        this.colour = colour;
    }
}