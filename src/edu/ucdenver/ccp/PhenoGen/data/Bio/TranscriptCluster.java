package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.ArrayList;
import java.util.Collections;
import edu.ucdenver.ccp.PhenoGen.data.Bio.EQTL;
import java.util.HashMap;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for storing transcript cluster info and grouping EQTLs
 *  @author  Spencer Mahaffey
 */

public class TranscriptCluster {
    String transcriptClusterID="";
    String chr="";
    long start=0,end=0;
    String strand="";
    String level="";
    HashMap tissueEQTLs=new HashMap();
    HashMap tissueRegionEQTL=new HashMap();
    HashMap tissueLODScore=new HashMap();
    
    String geneID="",geneSymbol="",geneChr="",geneDescription="";
    long geneStart=0,geneEnd=0;
    double geneOverlap=0,tcOverlap=0,combOverlap=0;
    
    
    public TranscriptCluster(String tcID,String tcChr,String tcStrand,long tcStart,long tcStop,String tcLevel){
        this.transcriptClusterID=tcID;
        this.chr=tcChr;
        if(tcStrand.equals("1")||tcStrand.equals("+")||tcStrand.equals("+1")){
            this.strand="+";
        }else if(tcStrand.equals("-1")||tcStrand.equals("-")){
            this.strand="-";
        }else{
            this.strand=".";
        }
        this.start=tcStart;
        this.end=tcStop;
        this.level=tcLevel;
    }
    
    public void addEQTL(String tissue,double pval,String marker_name,String marker_chr,long marker_start,long marker_end,double lodScore){
        EQTL tmpQTL=new EQTL(marker_name,marker_chr,marker_start,marker_end,pval);
        if(tissueEQTLs.containsKey(tissue)){
            ArrayList<EQTL> tmpQTLs=(ArrayList<EQTL>) tissueEQTLs.get(tissue);
            tmpQTLs.add(tmpQTL);
            Collections.sort(tmpQTLs);
        }else{
            ArrayList<EQTL> qtls=new ArrayList<EQTL>();
            qtls.add(tmpQTL);
            Collections.sort(qtls);
            tissueEQTLs.put(tissue, qtls);
        }
        
        if(tissueLODScore.containsKey(tissue)){
            
        }else{
            tissueLODScore.put(tissue, lodScore);
        }
        
    }
    
    public void addGene(String ensemblID,String geneSymbol, String start,String end,String overlap,String overlapG,String desc){
        double tmpOvr=Double.parseDouble(overlap);
        double tmpOvrG=Double.parseDouble(overlapG);
        double ovr=tmpOvr;
        double ovrG=tmpOvrG;
        if(ovr>100.0){
            ovr=100.0;
        }
        if(ovrG>100.0){
            ovrG=100.0;
        }
        double comb=ovr+ovrG;
        if(comb>this.combOverlap){
            this.geneID=ensemblID;
            this.geneSymbol=geneSymbol;
            this.geneStart=Integer.parseInt(start);
            this.geneEnd=Integer.parseInt(end);
            geneOverlap=tmpOvrG;
            tcOverlap=tmpOvr;
            combOverlap=comb;
            this.geneDescription=desc;
        }
    }
    
    public void addRegionEQTL(String tissue,double pval,String marker_name,String marker_chr,long marker_start,long marker_end,double lodScore){
        EQTL tmpQTL=new EQTL(marker_name,marker_chr,marker_start,marker_end,pval);
        if(tissueRegionEQTL.containsKey(tissue)){
            ArrayList<EQTL> tmpQTLs=(ArrayList<EQTL>) tissueRegionEQTL.get(tissue);
            tmpQTLs.add(tmpQTL);
            Collections.sort(tmpQTLs);
        }else{
            ArrayList<EQTL> qtls=new ArrayList<EQTL>();
            qtls.add(tmpQTL);
            Collections.sort(qtls);
            tissueRegionEQTL.put(tissue, qtls);
        }
        
        if(tissueLODScore.containsKey(tissue)){
            
        }else{
            tissueLODScore.put(tissue, lodScore);
        }
        
    }

    public String getTranscriptClusterID() {
        return transcriptClusterID;
    }

    public void setTranscriptClusterID(String transcriptClusterID) {
        this.transcriptClusterID = transcriptClusterID;
    }

    public String getChromosome() {
        return chr;
    }

    public void setChromosome(String chr) {
        this.chr = chr;
    }

    public long getStart() {
        return start;
    }

    public void setStart(long start) {
        this.start = start;
    }

    public long getEnd() {
        return end;
    }

    public void setEnd(long end) {
        this.end = end;
    }

    public String getStrand() {
        return strand;
    }

    public void setStrand(String strand) {
        this.strand = strand;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getGeneID() {
        return geneID;
    }

    public void setGeneID(String geneID) {
        this.geneID = geneID;
    }

    public String getGeneSymbol() {
        return geneSymbol;
    }
    
    public String getGeneDescription() {
        return geneDescription;
    }

    public void setGeneSymbol(String geneSymbol) {
        this.geneSymbol = geneSymbol;
    }

    public String getGeneChr() {
        return geneChr;
    }

    public void setGeneChr(String geneChr) {
        this.geneChr = geneChr;
    }

    public long getGeneStart() {
        return geneStart;
    }

    public void setGeneStart(long geneStart) {
        this.geneStart = geneStart;
    }

    public long getGeneEnd() {
        return geneEnd;
    }

    public void setGeneEnd(long geneEnd) {
        this.geneEnd = geneEnd;
    }
    

    public HashMap getTissueEQTLs() {
        return tissueEQTLs;
    }
    
    public HashMap getTissueRegionEQTLs() {
        return tissueRegionEQTL;
    }

    public void setTissueEQTLs(HashMap tissueEQTLs) {
        this.tissueEQTLs = tissueEQTLs;
    }
    public ArrayList<EQTL> getTissueEQTL(String tissue){
        return (ArrayList<EQTL>) tissueEQTLs.get(tissue);
    }
    
    public ArrayList<EQTL> getTissueRegionEQTL(String tissue){
        return (ArrayList<EQTL>) tissueRegionEQTL.get(tissue);
    }
    
    public int getTissueChrCount(String tissue,String chr){
        int count=0;
        ArrayList<EQTL> tmp=(ArrayList<EQTL>) tissueEQTLs.get(tissue);
        for(int i=0;i<tmp.size();i++){
            EQTL tmpE=tmp.get(i);
            if(tmpE.getMarkerChr().equals(chr)){
                count++;
            }
        }
        return count;
    }
    
    public EQTL getMaxTissueEQTL(String tissue){
        EQTL ret=null;
        ArrayList<EQTL> tmp=(ArrayList<EQTL>) tissueEQTLs.get(tissue);
        if(tmp!=null&&tmp.size()>0){
            ret=tmp.get(0);
        }
        return ret;
    }
    
    public double getTissueLOD(String tissue){
        double ret=-1.0;
        Object tmp=this.tissueLODScore.get(tissue);
        if(tmp!=null){
            ret=Double.parseDouble(tmp.toString());
        }
        return ret;
    }
    
    public String[] getTissueList(){
        Object[] tmp=tissueEQTLs.keySet().toArray();
        String[] ret=new String[0];
        if(tmp.length>0){
            ret=new String[tmp.length];
            for(int i=0;i<tmp.length;i++){
                ret[i]=tmp[i].toString();
            }
        }
        return ret;
    }
}
