package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.ArrayList;
import java.util.Collections;


/* for logging messages */
import org.apache.log4j.Logger;
/**
 *
 * @author smahaffey
 */
public class EQTL implements Comparable{
    String probeSetID="";
    String marker_name="";
    String marker_chr="";
    double marker_locationMB=0.0;
    String tissue="";
    double lodScore=0,pVal=0,fdr=0,lower=0,upper=0;
    String type="probeset";
    long marker_start=0,marker_end=0;
    
    public EQTL(String probeSetID,String marker_name,String marker_chr,double marker_locationMB,String tissue,double lod,double pVal,double fdr,double lower,double upper){
        this.probeSetID=probeSetID;
        this.marker_name=marker_name;
        this.marker_chr=marker_chr;
        this.marker_locationMB=marker_locationMB;
        this.tissue=tissue;
        this.lodScore=lod;
        this.pVal=pVal;
        this.fdr=fdr;
        this.lower=lower;
        this.upper=upper;
    }
    
    public EQTL(String marker_name,String marker_chr,long marker_start,long marker_end,double pVal){

        this.marker_name=marker_name;
        this.marker_chr=marker_chr;
        this.pVal=pVal;
        this.marker_start=marker_start;
        this.marker_end=marker_end;
        
    }

    public String getProbeSetID() {
        return probeSetID;
    }

    public void setProbeSetID(String probeSetID) {
        this.probeSetID = probeSetID;
    }

    public String getMarkerName() {
        return marker_name;
    }

    public void setMarkerName(String marker_name) {
        this.marker_name = marker_name;
    }

    public String getMarkerChr() {
        return marker_chr;
    }

    public void setMarkerChr(String marker_chr) {
        this.marker_chr = marker_chr;
    }

    public double getMarkerLocationMB() {
        return marker_locationMB;
    }

    public void setMarkerLocationMB(double marker_locationMB) {
        this.marker_locationMB = marker_locationMB;
    }

    public String getTissue() {
        return tissue;
    }

    public void setTissue(String tissue) {
        this.tissue = tissue;
    }

    public double getLODScore() {
        return lodScore;
    }

    public void setLODScore(double lodScore) {
        this.lodScore = lodScore;
    }

    public double getPVal() {
        return pVal;
    }

    public double getNegLogPVal() {
        return Math.log10(pVal)*-1;
    }
    
    public void setPVal(double pVal) {
        this.pVal = pVal;
    }

    public double getFDR() {
        return fdr;
    }

    public void setFDR(double fdr) {
        this.fdr = fdr;
    }

    public long getMarker_start() {
        return marker_start;
    }

    public long getMarker_end() {
        return marker_end;
    }
    
    
    public int compareTo(Object t) {
        EQTL e2=(EQTL)t;
        if(this.pVal<e2.pVal){
            return -1;
        }else if(this.pVal>e2.pVal){
            return 1;
        }
        if(this.lodScore>0 || e2.lodScore>0){
            if(this.lodScore>e2.lodScore){
                return -1;
            }else if(this.lodScore<e2.lodScore){
                return 1;
            }
        }
        return 0;
    }
    
}
