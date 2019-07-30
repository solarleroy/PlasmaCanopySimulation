import java.util.List;
import java.util.HashSet;
import java.util.Arrays;
import java.lang.String;

public class PlasmaCanopy implements LXFixture{
    public List<Tube> tubes = new ArrayList<Tube>();
    // public TubeChandelier chandelier;

    public PlasmaCanopy(){
        JSONObject fixtureConfig = loadJSONObject(tcr.active_model+".json");
        JSONArray config = fixtureConfig.getJSONArray("fixturearray");

        for (int x=0; x<config.size(); ++x) {
            JSONObject tube_series = config.getJSONObject(x);
            float[] position = new float[3];
            float[] orient = new float[3];

            for (int j=0; j < 3; j++) {
                position[j] = METRE*tube_series.getJSONArray("origin").getFloat(j);
            }

            JSONArray tube_string = tube_series.getJSONArray("tubes");
            for(int i=0;i<tube_string.size();++i){
                LXTransform t = new LXTransform();
                t.translate(position[0],position[1],position[2]);
                JSONObject tube = tube_string.getJSONObject(i);
                int type = tube.getInt("type");
                for(int j=0;j<3;++j){
                    orient[j] = tube.getJSONArray("orient").getFloat(j);
                }
                // t.rotateX(orient[0]*PI/180);
                t.rotateY(orient[1]*PI/180);
                t.rotateZ(orient[2]*PI/180);
                tubes.add(new Tube(type,t));
                position[0] = t.x();
                position[1] = t.y();
                position[2] = t.z();
            }
        }
    }
    public List<LXPoint> getPoints(){
        ArrayList<LXPoint> out = new ArrayList<LXPoint>();
        for(Tube t : tubes){
            out.addAll(t.getPoints());
        }
        return out;
    }
}

public class Chandelier implements LXFixture {
    List<Tube> tubes = new ArrayList<Tube>();

    private final float a=1.1*METRE, b=0.6*METRE;
    private double theta, alpha;
    public Chandelier(float x,float y,float z,float yaw){
        alpha=Math.atan((Math.sqrt(2)/2)*(b/a));
        theta = PI/2 -alpha;
        LXTransform t = new LXTransform();
        t.translate(x,y,z);
        t.rotateY((yaw/360)*2*PI);

        t.push();
        t.push();
        tubes.add(new Tube(1,t));
        t.rotateY(120*PI/180);
        tubes.add(new Tube(1,t));
        t.rotateY(120*PI/180);
        tubes.add(new Tube(1,t));
        t.translate(2.5*CM,0,0);
        t.translate(5*CM,0,0);
        tubes.add(new Tube(1,t));
        t.rotateY(120*PI/180);
        tubes.add(new Tube(1,t));
        t.rotateY(120*PI/180);
        tubes.add(new Tube(1,t));
        t.translate(5*CM,0,0);
        tubes.add(new Tube(1,t));
        t.rotateY(120*PI/180);
        tubes.add(new Tube(1,t));
        t.rotateY(120*PI/180);
        tubes.add(new Tube(1,t));
        t.pop();

        t.rotateZ(-theta);
        tubes.add(new Tube(0,t));
        t.push();
        t.rotateZ(70*PI/180);
        t.translate(5*CM,0,0);
        t.rotateY(3*PI/4);
        tubes.add(new Tube(1,t));
        t.rotateY(90*PI/180);
        tubes.add(new Tube(1,t));
        t.rotateY(90*PI/180);
        tubes.add(new Tube(1,t));
        t.rotateY(90*PI/180);
        tubes.add(new Tube(1,t));
        t.pop();
        t.rotateZ(-(PI-2*theta));
        tubes.add(new Tube(0,t));
        t.rotateZ(-2*theta);
        tubes.add(new Tube(0,t));
        t.rotateZ(-(PI-2*theta));
        tubes.add(new Tube(0,t));
        t.pop();
        t.rotateY(PI/2);
        t.rotateZ(-theta);
        tubes.add(new Tube(0,t));
        t.rotateZ(-(PI-2*theta));
        tubes.add(new Tube(0,t));
        t.rotateZ(-2*theta);
        tubes.add(new Tube(0,t));
        t.rotateZ(-(PI-2*theta));
        tubes.add(new Tube(0,t));

    }
    public List<LXPoint> getPoints(){
        List<LXPoint> out = new ArrayList<LXPoint>();
        for(Tube t : tubes){
            out.addAll(t.getPoints());
        }
        return out;
    }
}

public class Tube implements LXFixture{
    List<TubeSegment> segments = new ArrayList<TubeSegment>();
    List<LXPoint> points = new ArrayList<LXPoint>();
    private float[][] end_points = new float[2][3];
    private final float DISTANCE = METRE/60;
    protected float offset = 5*CM;
    protected float length = offset*2+METRE;

    /*
    Constructor takes an LXTransform, uses it to construct points and leaves t modified to represent an in-line orientation to the constructed tube at the connector point on the outlet.
    */
    public Tube(int type, LXTransform t){

        int num=60;
        switch(type){
            case 0: num =60;break;
            case 1: num =30;length=offset*2+METRE/2;break;
            default:
        }

        end_points[0][0] = t.x();
        end_points[0][1] = t.y();
        end_points[0][2] = t.z();

        t.translate(2*offset,0,0);
        for(int i =0; i<num; ++i){
            segments.add(new TubeSegment(t));
            t.translate(DISTANCE,0,0);
        }
        t.translate(offset,0,0);

        end_points[1][0] = t.x();
        end_points[1][1] = t.y();
        end_points[1][2] = t.z();

        for(TubeSegment s : segments){
            points.add(s.point);
        }

    }
    public List<LXPoint> getPoints(){
        return points;
    }
    public float[][] getEnds(){
        return end_points;
    }
}

public class TubeSegment extends UI3dComponent{
    LXPoint point;
    UICylinder tube;
    LXMatrix m;
    private final float RADIUS = 2.5*CM;
    private final int DETAIL = 6;

    TubeSegment(LXTransform t){
        m = new LXMatrix(t.getMatrix());
        tube = new UICylinder(RADIUS, METRE/60, DETAIL);
        point = new LXPoint(t.x(),t.y(),t.z());
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

public class MetreTube extends Tube{
    public MetreTube(LXTransform t){
        super(0,t);
    }
}

public class HalfMetreTube extends Tube{
    public HalfMetreTube(LXTransform t){
        super(1,t);
    }
}
