package edu.ucdenver.ccp.PhenoGen.data.Bio;




/* for logging messages */
import org.apache.log4j.Logger;
/**
 *
 * @author smahaffey
 */
public class SequenceVariant {
    int id=0,start=0,stop=0;
    String refSeq="",strainSeq="",type="",strain="";

    public SequenceVariant(int id, int start,int stop, String refSeq,String strainSeq,String type,String strain) {
        this.id=id;
        this.start=start;
        this.stop=stop;
        this.refSeq=refSeq;
        this.strainSeq=strainSeq;
        this.type=type;
        this.strain=strain;
        
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getStart() {
        return start;
    }

    public void setStart(int start) {
        this.start = start;
    }

    public int getStop() {
        return stop;
    }

    public void setStop(int stop) {
        this.stop = stop;
    }

    public String getRefSeq() {
        return refSeq;
    }

    public void setRefSeq(String refSeq) {
        this.refSeq = refSeq;
    }

    public String getStrainSeq() {
        return strainSeq;
    }

    public void setStrainSeq(String strainSeq) {
        this.strainSeq = strainSeq;
    }

    public String getType() {
        return type;
    }
    
    public String getShortType() {
        String ret="Indel";
        if(type.equals("SNP")){
            ret="SNP";
        }
        return ret;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getStrain() {
        return strain;
    }

    public void setStrain(String strain) {
        this.strain = strain;
    }
    
    public String toString(){
        return "ID:"+this.id+" Start:"+start+" Stop:"+stop+"refSeq:"+refSeq+" StrainSeq:"+strainSeq;
    }
    
}
