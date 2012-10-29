package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.ArrayList;
import java.util.Collections;


/* for logging messages */
import org.apache.log4j.Logger;
/**
 *
 * @author smahaffey
 */
public class Intron extends TranscriptElement {

    
    public Intron(long start,long stop,String id){
        this.start=start;
        this.stop=stop;
        len=Math.abs(stop-start);
        this.ID=id;
        this.type="intron";
    }

    
    
    public String getToolTipText(){
            String tooltiptext="<html>Intron:"+this.getID()+"<BR>Length:"+this.getLen()+"bp ("+this.getStart()+","+this.getStop()+")<BR>";
            tooltiptext=tooltiptext+"# Probes:"+this.probeset.size()+" ("+this.getIncludedProbeSetCount(true)+" Displayed)<BR>";
            tooltiptext=tooltiptext+"</HTML>";
            return tooltiptext;
    }
    
}
