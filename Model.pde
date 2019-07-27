import java.util.List;
import java.util.Properties;
import java.io.InputStream;


public class Model extends LXModel {

    public Model() {
        super(tcr.getFixtures());
    }
}

/*
Class is just used as a means to aggregate appropriate fixtures and pass to model
*/
public class Telekinetik{

    public List<LXFixture> fixtures = new ArrayList();
    public static final String active_model = "pc_model";

    //When mapping tubes in the canopy, orientations are to be from a global reference; so use a smartphone gyro app
    public PlasmaCanopy pc;
    public Chandelier chandelier;
    public Tube[] tubes;

    public Telekinetik(){

        chandelier = new Chandelier(0,4.8*METRE,0,20);
        pc = new PlasmaCanopy();
        tubes = new Tube[pc.tubes.size()+chandelier.tubes.size()];

        int i=0;
        for(Tube t : pc.tubes){
            tubes[i] = t;
            ++i;
        }
        i=0;
        for(Tube t : chandelier.tubes){
            tubes[pc.tubes.size()+i] = t;
            ++i;
        }


        fixtures.add(pc);
        fixtures.add(chandelier);

        for(LXFixture f : tubes){
            fixtures.add(f);
        }
    }

    //Allows for accessing of List<LXFixture> fixtures through model.fixtures
    public LXFixture[] getFixtures(){
        return fixtures.toArray(new LXFixture[fixtures.size()]);
    }
}