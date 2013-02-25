package edu.ucdenver.ccp.PhenoGen.data.Bio;

import edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation;

import java.util.ArrayList;
import java.util.Collections;


/* for logging messages */
import org.apache.log4j.Logger;
/**
 *
 * @author smahaffey
 */
public class MirDeepAnnotation extends edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation {
    int total=0,mature=0,loop=0,star=0;
    String provID="",rfam="",matureSeq="",starSeq="",preCurSeq="",strand="",chr="";
    double score=0,prob=1;
    boolean sig=false;
    long start=0,stop=0;
    
    public MirDeepAnnotation(int id,String provID,String rfam,int mature,int star, int total,int loop,double score,double prob,String matureSeq,String starSeq,String preCurSeq,long start,long stop,String strand,String chr,boolean sig){
        super(id,"mirDeep",provID,"smnc");
        this.provID=provID;
        this.rfam=rfam;
        this.mature=mature;
        this.matureSeq=matureSeq;
        this.star=star;
        this.total=total;
        this.starSeq=starSeq;
        this.preCurSeq=preCurSeq;
        this.start=start;
        this.stop=stop;
        this.strand=strand;
        this.chr=chr;
        this.sig=sig;
        this.loop=loop;
        this.score=score;
        this.prob=prob;
    }
    
    public String getLongDisplayHTMLString(boolean withLinks){
        String ret="";
        ret="<table class=\"list_base\" style=\"text-align:left;\"><tbody>"
        + "<tr><TD>Provisional ID:"+provID+"</TD><TD>MirDeep Score:"+score+"</TD></TR>"
        + "<tr><TD>Significant Score: "+sig+"</TD><TD>PDF Detailed Output: <a href=\"web/GeneCentric/mirDeep/"+provID+".pdf\" target=\"_blank\">View</a></TD></TR>"
        + "<tr><TD colspan=\"2\">Precursor Location: chr"+chr+":"+start+"-"+stop+"</TD></TR>"
        + "<tr><TD colspan=\"2\"><H3>Sequences</H3></TD></TR>"
        + "<tr><TD>Mature Sequence: "+matureSeq.toUpperCase()+"</TD><TD>Star Sequence: "+starSeq.toUpperCase()+"</TD></TR>"
        + "<tr><TD colspan=\"2\">Precursor Sequence: "+preCurSeq.toUpperCase()+"</TD></TR>"
        + "<tr><TD colspan=\"2\"><H3>Read Counts</H3></TD></TR>"
        + "<tr><TD>Total Read Counts: "+total+"</TD><TD>Mature Read Counts: "+mature+"</TD></TR>"
        + "<tr><TD>Star Read Counts: "+star+"</TD><TD>Loop Read Counts: "+loop+"</TD></TR>";
        ret=ret+"</tbody></table>";
        return ret;
    }

    public int getTotalCount() {
        return total;
    }

    public void setTotalCount(int total) {
        this.total = total;
    }

    public int getMatureCount() {
        return mature;
    }

    public void setMatureCount(int mature) {
        this.mature = mature;
    }

    public int getLoopCount() {
        return loop;
    }

    public void setLoopCount(int loop) {
        this.loop = loop;
    }

    public int getStarCount() {
        return star;
    }

    public void setStarCount(int star) {
        this.star = star;
    }

    public String getProvisionalID() {
        return provID;
    }

    public void setProvisionalID(String provID) {
        this.provID = provID;
    }

    public String getRfam() {
        return rfam;
    }

    public void setRfam(String rfam) {
        this.rfam = rfam;
    }

    public String getMatureSequence() {
        return matureSeq;
    }

    public void setMatureSequence(String matureSeq) {
        this.matureSeq = matureSeq;
    }

    public String getStarSequence() {
        return starSeq;
    }

    public void setStarSequence(String starSeq) {
        this.starSeq = starSeq;
    }

    public String getPreCurSequence() {
        return preCurSeq;
    }

    public void setPreCurSequence(String preCurSeq) {
        this.preCurSeq = preCurSeq;
    }

    public String getStrand() {
        return strand;
    }

    public void setStrand(String strand) {
        this.strand = strand;
    }

    public String getChromosome() {
        return chr;
    }

    public void setChromosome(String chr) {
        this.chr = chr;
    }

    public double getScore() {
        return score;
    }

    public void setScore(double score) {
        this.score = score;
    }

    public double getProb() {
        return prob;
    }

    public void setProb(double prob) {
        this.prob = prob;
    }

    public boolean isSignificant() {
        return sig;
    }

    public void setSignificant(boolean sig) {
        this.sig = sig;
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

}
