package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.ArrayList;
import java.util.Collections;
import edu.ucdenver.ccp.PhenoGen.data.Bio.Exon;
import edu.ucdenver.ccp.PhenoGen.data.Bio.Intron;
import edu.ucdenver.ccp.PhenoGen.data.Bio.TranscriptElement;
import edu.ucdenver.ccp.PhenoGen.data.Bio.SequenceVariant;
import java.util.HashMap;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to Downloads
 *  @author  Cheryl Hornbaker
 */

public class Transcript {
    ArrayList<Exon> exons=new ArrayList<Exon>();
    ArrayList<Intron> introns=new ArrayList<Intron>();
    ArrayList<TranscriptElement> fullTranscript=new ArrayList<TranscriptElement>();
    ArrayList<Annotation> fullAnnotation=new ArrayList<Annotation>();
    HashMap<String,ArrayList<Annotation>> annotBySource=new HashMap<String,ArrayList<Annotation>>();
    ArrayList<SequenceVariant> snps=new ArrayList<SequenceVariant>();
    String ID="";
    String strand="",category="";
    long start=0,stop=0,len=0;
    
    public Transcript(){
        
    }
    public Transcript(String ID){
        this(ID,"",0,0);
    }
    public Transcript(String ID,String strand){
        this(ID,strand,0,0);
    }
    public Transcript(String ID,long start,long stop){
        this(ID,"",start,stop);
    }
    public Transcript(String ID,String strand,long start,long stop){
        this.ID=ID;
        if(strand.equals("1")||strand.equals("+")||strand.equals("+1")){
            this.strand="+";
        }else if(strand.equals("-1")||strand.equals("-")){
            this.strand="-";
        }else{
            this.strand=".";
            //System.err.println("Unknown Strand Type:"+strand);
        }
        this.start=start;
        this.stop=stop;
        this.len=Math.abs(stop-start)+1;
    }
    
    public void setExon(ArrayList<Exon> exons){
        this.exons=exons;
        Collections.sort(this.exons);
        for(int i=0;i<this.exons.size();i++){
            ArrayList<SequenceVariant> tmp=this.exons.get(i).getVariants();
            for(int j=0;j<tmp.size();j++){
                snps.add(tmp.get(j));
            }
        }
    }
    
    public void setIntron(ArrayList<Intron> introns){
        this.introns=introns;
        if(introns!=null&&introns.size()>0){
            Collections.sort(this.introns);
        }
    }
    
    public void setAnnotation(ArrayList<Annotation> annot){
        this.fullAnnotation=annot;
        if(fullAnnotation!=null){
            for(int i=0;i<fullAnnotation.size();i++){
                String source=fullAnnotation.get(i).getSource();
                if(annotBySource.containsKey(source)){
                    ArrayList<Annotation> tmp=annotBySource.get(source);
                    tmp.add(fullAnnotation.get(i));
                }else{
                    ArrayList<Annotation> tmp=new ArrayList<Annotation>();
                    tmp.add(fullAnnotation.get(i));
                    annotBySource.put(source,tmp);
                }
            }
        }
    }
    
    public ArrayList<Annotation> getAnnotationBySource(String source){
        ArrayList<Annotation> ret;
        if(annotBySource.containsKey(source)){
            ret=annotBySource.get(source);            
        }else{
            ret=new ArrayList<Annotation>();
        }
        return ret;
    }
    
    public ArrayList<Annotation> getAnnotation(){
        return this.fullAnnotation;
    }
    
    public void fillFullTranscript(){
        this.fullTranscript=new ArrayList<TranscriptElement>();
        if(exons!=null){
            this.fullTranscript.addAll(exons);
            if(introns!=null){
                this.fullTranscript.addAll(introns);
            }
            Collections.sort(this.fullTranscript);
        }
    }
    
    public ArrayList<TranscriptElement> getFullTranscript(){
        return this.fullTranscript;
    }

    public String getID() {
        return ID;
    }
    
    public String getIDwToolTip(){
        String ret="";
        if(ID.startsWith("ENS")){
            ret=ID;
        }else{
            ArrayList<Annotation> annot=this.getAnnotationBySource("AKA");
            if(annot!=null && annot.size()==1){
                ret="<span title=\""+annot.get(0).getAKAToolTip()+"\">"+ID+"</span>";
            }else{
                ret=ID;
            }
        }
        return ret;
    }
    public String getMatchReason(){
        String ret="";
        if(ID.startsWith("ENS")){
            ret="";
        }else{
            ArrayList<Annotation> annot=this.getAnnotationBySource("AKA");
            if(annot!=null && annot.size()==1){
                ret=annot.get(0).getAKAToolTip();
            }else{
                ret="";
            }
        }
        return ret;
    }   

    public ArrayList<Exon> getExons() {
        return exons;
    }
    
    public ArrayList<Intron> getIntrons() {
        return introns;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }
    
    
    
    
    public int getExonLength(){
        return exons.size();
    }
    public int getIntronLength(){
        return introns.size();
    }
    /*public int getIntronLength(){
        return introns.size();
    }*/

    public int getConsecutiveExcluded(int i,boolean displayIntrons) {
        boolean stop=false;
        int numExcludedAfterI=1;
        ArrayList<TranscriptElement> elem=this.getIncludedTranscriptElements(displayIntrons);
        for(int j=i+1;j<elem.size()&&!stop;j++){
            TranscriptElement e=elem.get(j);
            if(e.getType().equals("exon")){
                if(e.isExclude()){
                    numExcludedAfterI++;
                }else{
                        stop=true;
                }
            }else{
                if(displayIntrons&&!e.isExclude()){
                    stop=true;
                }
            }
        }
        return numExcludedAfterI;
    }

    public String getStrand() {
        return this.strand;
    }

    /*public void setExcluded(ArrayList<ProbeSet> excludedProbes) {
        for(int i=0;i<exons.size();i++){
            exons.get(i).setProbesExcluded(excludedProbes);
            System.out.println("exon:"+i+":"+exons.get(i).isExclude()+":"+exons.get(i).getExclusionReason());
        }
    }*/
    
    public int getProbeSetCount(boolean includeIntrons){
        int ret=0;
        for(int i=0;i<this.fullTranscript.size();i++){
            ret=ret+fullTranscript.get(i).getIncludedProbeSetCount(includeIntrons);
        }
        return ret;
    }
    public int getIncludedElemLength(boolean includeIntrons){
        int ret=0;
        for(int i=0;i<fullTranscript.size();i++){
            TranscriptElement tmp=fullTranscript.get(i);
            if(tmp.getType().equals("exon")){//add all exons excluded or not
                    ret++;
            }else if(includeIntrons){//add introns only when displayed
                if(!tmp.isExclude()){//add only introns not excluded
                    ret++;
                }
            }
        }
        return ret;
    }
    //note this includes all exons regardless of exclusion because these will be drawn even if excluded.  Introns are not included
    public ArrayList<TranscriptElement> getIncludedTranscriptElements(boolean includeIntrons){
        ArrayList<TranscriptElement> ret=new ArrayList<TranscriptElement>();
        for(int i=0;i<fullTranscript.size();i++){
            TranscriptElement tmp=fullTranscript.get(i);
            if(tmp.getType().equals("exon")){//add all exons excluded or not
                    ret.add(tmp);
            }else if(includeIntrons){//add introns only when displayed
                if(!tmp.isExclude()){//add only introns not excluded
                    ret.add(tmp);
                }
            }
        }
        return ret;
    }

    public void setHeritDabg(HashMap heritDabg,HashMap fullPSList){
        for(int i=0;i<fullTranscript.size();i++){
            TranscriptElement te=fullTranscript.get(i);
            te.setHeritDabg(heritDabg,fullPSList,strand);
        }
        //System.err.println("New Size:"+fullPSList.size());
        
    }

    public long getStart() {
        return start;
    }

    public void setStart(long start) {
        this.start = start;
    }

    public long getStop() {
        return stop;
    }

    public void setStop(long stop) {
        this.stop = stop;
    }
    public ArrayList<SequenceVariant> getVariants(){
        return snps;
    }
}
