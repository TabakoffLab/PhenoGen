package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Set;


/* for logging messages */
import org.apache.log4j.Logger;
/**
 *
 * @author smahaffey
 */
public class ProbeSet implements Comparable {
    long start=-1,stop=-1,len=-1;
    String probeSetID="";
    String sequence="",strand="";
    boolean excluded=false;
    boolean filteredFromHeatMap=false;
    boolean filteredByAnnotation=false;
    boolean filteredByStrand=false;
    boolean filteredByHerit=false;
    boolean filteredByDabg=false;
    boolean oppositeStrand=false;
    String annotation="";
    
    HashMap heritDabg=new HashMap();
    boolean updateLoc=false;
  
    
    public ProbeSet(long start, long stop, String probeID,String seq, String strand,String type,String updatedLoc){
        this.start=start;
        this.stop=stop;
        this.probeSetID=probeID;
        this.sequence=seq;
        if(strand.equals("1")||strand.equals("+")||strand.equals("+1")){
            this.strand="+";
        }else if(strand.equals("-1")||strand.equals("-")){
            this.strand="-";
        }else{
            //System.err.println("Unknown Strand Type:"+strand);
        }
        this.annotation=type;
        len=Math.abs(start-stop);
        if(updatedLoc.equals("N")){
            this.updateLoc=false;
        }else if(updatedLoc.equals("Y")){
            this.updateLoc=true;
        }
    }
    public void clearFilters(){
        this.filteredByAnnotation=false;
        this.filteredByDabg=false;
        this.filteredByHerit=false;
        this.filteredByStrand=false;
    }
    
    public boolean isLocationUpdated(){
        return this.updateLoc;
    }
    
    public boolean isMasked(){
        return !this.updateLoc;
    }

    public long getLen() {
        return len;
    }

    public String getProbeSetID() {
        return probeSetID;
    }

    public long getStart() {
        return start;
    }

    public long getStop() {
        return stop;
    }

    public String getSequence() {
        return sequence;
    }

    public String getStrand() {
        return strand;
    }

    public boolean isExcluded() {
        return excluded;
    }

    public void setExcluded(boolean excluded) {
        if(!this.filteredFromHeatMap){
            this.excluded = excluded;
        }
    }

    public String getAnnotation() {
        return annotation;
    }
    
    public double getHerit(String tissue){
        double herit=-1;
        if(heritDabg.containsKey(tissue)){
            HashMap tmp=(HashMap) heritDabg.get(tissue);
            herit=Double.parseDouble(tmp.get("herit").toString());
        }
        return herit;
    }
    
    public double getDabg(String tissue){
        double dabg=-1;
        if(heritDabg.containsKey(tissue)){
            HashMap tmp=(HashMap) heritDabg.get(tissue);
            dabg=Double.parseDouble(tmp.get("dabg").toString());
        }
        return dabg;
    }
    
    public String[] getTissues(){
        Set tmp=heritDabg.keySet();
        Object[] tmpArr=tmp.toArray();
        String[] ret=new String[tmpArr.length];
        for(int i=0;i<ret.length;i++){
            ret[i]=tmpArr[i].toString();
        }
        return ret;
    }

    @Override
    public int compareTo(Object t) {
        ProbeSet p2=(ProbeSet)t;
        int ret=0;
        if(this.probeSetID.equals(p2.probeSetID)&&this.start==p2.start&&this.stop==p2.stop){
            ret=0;
        }else if(this.stop>this.start){//+ strand
            if(this.start>p2.start){
               ret=1; 
            }else if(this.start<p2.start){
               ret=-1;
            }else if(this.start==p2.start){
                if(this.stop>p2.stop){
                    ret=1;
                }else{
                    ret=-1;
                }
            }
        }else if(this.stop<this.start){//- strand
            if(this.start<p2.start){
               ret=1; 
            }else if(this.start>p2.start){
               ret=-1;
            }else if(this.start==p2.start){
                if(this.stop<p2.stop){
                    ret=1;
                }else{
                    ret=-1;
                }
            }
        }
        return ret;
    }
    public String toString(){
        String ret=this.probeSetID+" "+this.annotation+" "+this.strand;
        
        if(this.excluded){
            ret=ret+" (Not Displayed)";
        }
        return ret;
    }

    public boolean isFilteredByAnnotation() {
        return filteredByAnnotation;
    }

    public void setFilteredByAnnotation(boolean filteredByAnnotation) {
        this.filteredByAnnotation = filteredByAnnotation;
    }

    public boolean isFilteredByStrand() {
        return filteredByStrand;
    }

    public void setFilteredByStrand(boolean filteredByStrand) {
        this.filteredByStrand = filteredByStrand;
    }

    public boolean isFilteredFromHeatMap() {
        return filteredFromHeatMap;
    }

    public void setFilteredFromHeatMap(boolean filteredFromHeatMap) {
        if(filteredFromHeatMap){
            this.excluded=true;
            this.filteredFromHeatMap=true;
        }
    }

    public void setFilteredByHerit(boolean b) {
        this.filteredByHerit=b;
    }

    public void setFilteredByDabg(boolean b) {
       this.filteredByDabg=b;
    }
    
    public boolean isFilteredByDabg(){
        return this.filteredByDabg;
    }
    
    public boolean isFilteredByHerit(){
        return this.filteredByHerit;
    }
    public String getExclusionReason(){
        String reason="";
        if(this.filteredByStrand){
            reason="Wrong Strand";
        }else if(this.filteredFromHeatMap){
            reason="Masked";
        }else if(this.filteredByAnnotation){
            reason="Annotation";
        }else if(this.filteredByDabg){
            reason="DABG";
        }else if(this.filteredByHerit){
            reason="Heritability";
        }
        return reason;
    }

    void setOppositeStrand(boolean b) {
        this.oppositeStrand=b;
    }
    public boolean getOppositeStrand(){
        return this.oppositeStrand;
    }
    public void setHeritDabg(HashMap heritDabg){
        this.heritDabg=heritDabg;
    }
}