package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.ArrayList;
import java.util.Collections;
import edu.ucdenver.ccp.PhenoGen.data.Bio.TranscriptElement;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 *
 * @author smahaffey
 */
public class Exon extends TranscriptElement{
    long codeStart=-1,codeStop=-1,codeLen=-1;
    String exonNum="";
    
    
    
    public Exon(long start, long stop){
        this(start,stop,null);
    }
    
    public Exon(long start, long stop, String ID){
        //System.out.println("ExonID:"+ID);
        this.ID=ID;
        this.start=start;
        this.stop=stop;
        len=Math.abs(start-stop);
        this.type="exon";
    }
    
    public String getExonNumber(){
        return exonNum;
    }
    
    public void setExonNumber(String num){
        this.exonNum=num;
    }
    

    public void setProteinCoding(long CodeStart, long CodeStop) {
        if(CodeStart==CodeStop){
            this.codeStart=0;
            this.codeStop=0;
            this.codeLen=0;
        }else{
            this.codeStart=CodeStart;
            this.codeStop=CodeStop;
            this.codeLen=Math.abs(codeStop-codeStart+1);
        }
    }
    
    public boolean isFullCoding(){
        boolean ret=true;
        if(this.codeStart<1||this.codeStart!=this.start){
            ret=false;
        }
        return ret;
    }
    public double getPercentNonCoding(){
        double perc=100;
        if(codeLen<len&&codeLen>0){
            perc=codeLen/len*100;
        }
        return perc;
    }

    
    
    

    //public void setProbesExcluded(ArrayList<ProbeSet> excludedProbes) {
                        //ArrayList<Probe> toRemove=new ArrayList<Probe>();
                        /*for(int i=0;i<this.probes.size();i++){
                            if(probes.get(i).getStrand().equals(strand)){
                                probes.get(i).setExcluded(false);
                            }else{
                                probes.get(i).setExcluded(true);
                            }
                        }*/
        /*for(int i=0;i<excludedProbes.size();i++){
            boolean found=false;
            for(int j=0;!found&&j<this.probeset.size();j++){
                if(probeset.get(j).equals(excludedProbes.get(i))){
                    probeset.get(j).setExcluded(true);
                    probeset.get(j).setFilteredFromHeatMap(true);
                    found=true;
                    //toRemove.add(probes.get(j));
                }
            }
        }*/
                        //for(int i=0;i<toRemove.size();i++){
                        //    probes.remove(toRemove.get(i));
                        //}
        /*if(this.isAllProbesExcluded()){
            this.exclude=true;
        }else{
            this.exclude=false;
        }
    }*/

    public long getProteinCodeStart() {
        return codeStart;
    }

    public long getProteinCodeStop() {
        return codeStop;
    }

    public long getProteinCodingLength() {
        return codeLen;
    }
    
    

    public String getToolTipText(){
            String tooltiptext="<html>Exon ID:"+this.getID()+"<BR>Exon length:"+this.getLen()+"bp ("+this.getStart()+":"+this.getStop()+")<BR>";
            if(this.getPercentNonCoding()<100){
                tooltiptext=tooltiptext+"Protein coding length:"+this.getProteinCodingLength()+"bp ("+this.getProteinCodeStart()+":"+this.getProteinCodeStop()+")<BR>";
            }
            tooltiptext=tooltiptext+"# Probes:"+this.probeset.size()+" (<B>"+this.getIncludedProbeSetCount(false)+" Displayed</b>)<BR>";
            if(this.exclude){
                tooltiptext=tooltiptext+"Exclusion Reason(s):<B>"+this.getExclusionReasons()+"</B><BR>";
            }
            tooltiptext=tooltiptext+"<i>Click on Transcript to view probe information</i></HTML>";
            return tooltiptext;
    }

   

    
    
    
}