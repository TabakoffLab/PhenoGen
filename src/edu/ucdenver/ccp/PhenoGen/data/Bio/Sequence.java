package edu.ucdenver.ccp.PhenoGen.data.Bio;




/* for logging messages */
import org.apache.log4j.Logger;
/**
 *
 * @author smahaffey
 */
public class Sequence {
    int id=0;
    String sequence="";
    int offsetFromReference=0;

    public Sequence(int id, String sequence,int offset) {
        this.id=id;
        this.sequence=sequence;
        this.offsetFromReference=offset;
    }
    
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getSequence() {
        return sequence;
    }

    public void setSequence(String sequence) {
        this.sequence = sequence;
    }

    public int getOffsetFromReference() {
        return offsetFromReference;
    }

    public void setOffsetFromReference(int offsetFromReference) {
        this.offsetFromReference = offsetFromReference;
    }
    
    
    
    
}
