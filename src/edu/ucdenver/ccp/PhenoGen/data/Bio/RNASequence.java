package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.HashMap;

/* for logging messages */
import org.apache.log4j.Logger;
/**
 *
 * @author smahaffey
 */
public class RNASequence{
    int readCount=0,id=0;
    int uniqueAlignment=0;
    String sequence="";
    int offsetFromReference=0;
    HashMap strainMatch=new HashMap();
    
    public RNASequence(int id,String seq,int readCount,int unique,int offset,HashMap match){
        this(id,seq,readCount,unique,offset);
        this.strainMatch=match;
    }
    public RNASequence(int id,String seq,int readCount,int unique,int offset){
        this.id=id;
        this.sequence=seq;
        this.offsetFromReference=offset;
        this.readCount=readCount;
        this.uniqueAlignment=unique;
    }

    public int getReadCount() {
        return readCount;
    }

    public void setReadCount(int readCount) {
        this.readCount = readCount;
    }

    public int getUniqueAlignment() {
        return uniqueAlignment;
    }

    public void setUniqueAlignment(int uniqueAlignment) {
        this.uniqueAlignment = uniqueAlignment;
    }

    public HashMap getStrainMatch() {
        return strainMatch;
    }

    public void setStrainMatch(HashMap strainMatch) {
        this.strainMatch = strainMatch;
    }
    
    public boolean getStrainMatch(String strain){
        String result=this.strainMatch.get(strain).toString();
        boolean ret=false;
        if(result.equals("1")){
            ret=true;
        }
        return ret;
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
