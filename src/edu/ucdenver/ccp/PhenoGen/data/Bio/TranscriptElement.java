package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.ArrayList;
import java.util.Collections;

import edu.ucdenver.ccp.PhenoGen.data.Bio.TranscriptElement;
import edu.ucdenver.ccp.PhenoGen.data.Bio.ProbeSet;
import edu.ucdenver.ccp.PhenoGen.data.Bio.SequenceVariant;
import java.util.HashMap;


/**
 *
 * @author smahaffey
 */
abstract public class TranscriptElement implements Comparable {
    String ID="",exclusionReason="";
    boolean exclude=false;
    ArrayList<ProbeSet> probeset=new ArrayList<ProbeSet>();
    ArrayList<SequenceVariant> variant=new ArrayList<SequenceVariant>();
    long start=-1,stop=-1,len=-1;
    int number=-1;
    String type="";
    HashMap heritCount=new HashMap();
    HashMap dabgCount=new HashMap();
    
    
    static int WRONG_STRAND=1;
    static int MISSING_HEATMAP=5;
    static int HERIT_CUTOFF=2;
    static int DABG_CUTOFF=3;
    static int ANNOTATION_CUTOFF=4;
    
    int exclusionCode=-1;
    
    public String getID() {
        return ID;
    }

    public void setID(String ID) {
        this.ID = ID;
    }

    public boolean isExclude() {
        return exclude;
    }

    public void setExclude(boolean exclude) {
        this.exclude = exclude;
    }

    public String getExclusionReason() {
        this.findExclusionReason();
        assignExcludeReasonFromCode();
        return exclusionReason;
    }
    
    public String getExclusionReasons() {
        return this.findExclusionReasons();
    }
    
    public String getType(){
        return type;
    }
    public long getLen() {
        return len;
    }

    public long getStart() {
        return start;
    }

    public long getStop() {
        return stop;
    }
    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    public ArrayList<ProbeSet> getProbeSet() {
        return probeset;
    }
    
    public void setProbeSets(ArrayList<ProbeSet> probeset) {
        this.probeset=probeset;
        Collections.sort(probeset);
        if(probeset.size()==0){
            exclude=true;
        }
        
    }
    public void setVariants(ArrayList<SequenceVariant> vars){
        this.variant=vars;
    }
    public ArrayList<SequenceVariant> getVariants(){
        return this.variant;
    }
    
    public int getIncludedProbeSetCount(boolean includeIntrons){
        int countIncluded=0;
        if(this.type.equals("exon")||(this.type.equals("intron")&&includeIntrons)){
            for(int i=0;i<this.probeset.size();i++){
                if(!this.probeset.get(i).isExcluded()){
                    countIncluded++;
                }
            }
        }
        return countIncluded;
    }
    
    
    
    public String findExclusionReasons(){
        String reasons="";
        if(this.exclude){
            if(probeset.size()==0){
                reasons="No Probesets";
            }
            for(int i=0;i<this.probeset.size();i++){
                    ProbeSet tmp=this.probeset.get(i);
                    if(tmp.isFilteredByHerit()){
                        reasons=this.addToString("Heritability", reasons);
                    }
                    if(tmp.isFilteredByDabg()){
                        reasons=this.addToString("DABG", reasons);
                    }
                    if(tmp.isFilteredByAnnotation()){
                        reasons=this.addToString("Annotation", reasons);
                    }
                    if(tmp.isFilteredFromHeatMap()){
                        reasons=this.addToString("Masked", reasons);
                    }
            }
        }
        return reasons;
    }
    
    private String addToString(String toAdd,String addTo){
        String ret="";
        if(addTo.contains(toAdd)){
            ret=addTo;
        }else{
            if(addTo.equals("")){
                ret=toAdd;
            }else{
                ret=addTo+", "+toAdd;
            }
        }
        return ret;
    }
    
    public void clearExclusionReason(){
        this.exclusionCode=-1;
    }
    
    public boolean isAllProbesExcluded(){
        boolean allExcluded=true;
        for(int i=0;i<this.probeset.size()&&allExcluded;i++){
            if(!this.probeset.get(i).isExcluded()){
                allExcluded=false;
            }
        }
        return allExcluded;
    }
    
    private void assignExcludeReasonFromCode() {
        if(this.exclusionCode==Exon.MISSING_HEATMAP){
            this.exclusionReason="Masked";
        }else if(this.exclusionCode==Exon.WRONG_STRAND){
            this.exclusionReason="Strand";
        }else if(this.exclusionCode==Exon.HERIT_CUTOFF){
            this.exclusionReason="Herit";
        }else if(this.exclusionCode==Exon.ANNOTATION_CUTOFF){
            this.exclusionReason="Annotation";
        }else if(this.exclusionCode==Exon.DABG_CUTOFF){
            this.exclusionReason="DABG";
        }else{
            this.exclusionReason="";
        }
    }

    
    
    public void findExclusionReason(){
        if(this.exclude){
            for(int i=0;i<this.probeset.size();i++){
                    ProbeSet tmp=this.probeset.get(i);
                    if(tmp.isFilteredByHerit()&&this.exclusionCode<Exon.HERIT_CUTOFF){
                        this.exclusionCode=Exon.HERIT_CUTOFF;
                    }else if(tmp.isFilteredByDabg()&&this.exclusionCode<Exon.DABG_CUTOFF){
                        this.exclusionCode=Exon.DABG_CUTOFF;
                    }else if(tmp.isFilteredByAnnotation()&&this.exclusionCode<Exon.ANNOTATION_CUTOFF){
                        this.exclusionCode=Exon.ANNOTATION_CUTOFF;
                    }
            }
        }else{
            this.exclusionCode=-1;
        }
    }
    
    
    
    @Override
    public int compareTo(Object t) {
        TranscriptElement ex2=(TranscriptElement)t;
        int ret=-1;
        if(this.start>ex2.start){
           ret=1; 
        }else if(this.start<ex2.start){
           ret=-1;
        }else if(this.start==ex2.start){
            if(this.stop>ex2.stop){
                ret=1;
            }else{
                ret=-1;
            }
        }
        if(this.ID.equals(ex2.ID) &&  this.start==ex2.start && this.stop==ex2.stop){
            ret=0;
        }
        return ret;
    }
    
    public void setHeritDabg(HashMap heritDabg, HashMap fullPSList,String transcriptStrand){
        //System.err.println("TE probeset size:"+probeset.size());
        for(int i=0;i<probeset.size();i++){
            ProbeSet ps=probeset.get(i);
            if(ps!=null){
                //System.err.println("ps:"+ps.getProbeSetID()+":");
                if(ps.isLocationUpdated() && !fullPSList.containsKey(ps.getProbeSetID()) && ps.getStrand().equals(transcriptStrand)){
                    fullPSList.put(ps.getProbeSetID(), 1);
                }
                if(heritDabg.containsKey(ps.getProbeSetID())){
                    ps.setHeritDabg((HashMap)heritDabg.get(ps.getProbeSetID()));
                }
            }
        }
    }
}