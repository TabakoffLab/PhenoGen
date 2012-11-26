package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.ArrayList;
import java.util.Collections;


/* for logging messages */
import org.apache.log4j.Logger;
/**
 *
 * @author smahaffey
 */
public class BQTL {
    String id="",mgiID="",rgdID="",symbol="",name="",trait="",subTrait="",traitMethod="",phenotype="",diseases="",mapMethod="";
    ArrayList<String> relatedQTL=new ArrayList<String>();
    ArrayList<String> relatedQTLreason=new ArrayList<String>();
    ArrayList<String> candidateGene=new ArrayList<String>();
    ArrayList<String> rgdRef=new ArrayList<String>();
    ArrayList<String> pubmedRef=new ArrayList<String>();
    double lod=0.0,pValue=0.0;
    String chromosome="";
    long start=0,stop=0;
    public BQTL(String id,String mgiID,String rgdID,String symbol,String name,String trait,String subTrait,String traitMethod,String phenotype,String diseases,String rgdRef,String pubmedRef,String mapMethod,String relQTLs,String candidGene,double lod,double pvalue,long start,long stop, String chr){
        this.id=id;
        this.mgiID=mgiID;
        this.rgdID=rgdID;
        this.symbol=symbol;
        this.name=name;
        this.trait=trait;
        this.subTrait=subTrait;
        this.traitMethod=traitMethod;
        this.phenotype=phenotype;
        this.diseases=diseases;
        if(rgdRef!=null){
            String[] tmpRef=rgdRef.split(";");
            for(int i=0;i<tmpRef.length;i++){
                this.rgdRef.add(tmpRef[i]);
            }
        }
        if(pubmedRef!=null){
            String[] tmpPRef=pubmedRef.split(";");
            for(int i=0;i<tmpPRef.length;i++){
                this.pubmedRef.add(tmpPRef[i]);
            }
        }
        this.mapMethod=mapMethod;
        if(relQTLs!=null){
            String[] tmpRel=relQTLs.split(";");
            for(int i=0;i<tmpRel.length;i++){
                String reason="";
                String tmpSymbol="";
                if(tmpRel[i].indexOf("(")>0){
                    tmpSymbol=tmpRel[i].substring(0,tmpRel[i].indexOf("(")-1);
                    reason=tmpRel[i].substring(tmpRel[i].indexOf("(")+1,tmpRel[i].indexOf(")"));
                }else{
                    tmpSymbol=tmpRel[i];
                }
                if(!tmpSymbol.equals("")){
                    relatedQTL.add(tmpSymbol);
                    relatedQTLreason.add(reason);
                }
            }
        }
        if(candidGene!=null){
            String[] tmpCanGene=candidGene.split(";");
            for(int i=0;i<tmpCanGene.length;i++){
                candidateGene.add(tmpCanGene[i]);
            }
        }
        this.lod=lod;
        this.pValue=pvalue;
        this.start=start;
        this.stop=stop;
        this.chromosome=chr;
    }

    public String getID() {
        return id;
    }

    public String getMGIID() {
        return mgiID;
    }

    public String getRGDID() {
        return rgdID;
    }

    public String getSymbol() {
        return symbol;
    }

    public String getName() {
        return name;
    }

    public String getTrait() {
        return trait;
    }

    public String getSubTrait() {
        return subTrait;
    }

    public String getTraitMethod() {
        return traitMethod;
    }

    public String getPhenotype() {
        return phenotype;
    }

    public String getDiseases() {
        return diseases;
    }

    public String getMapMethod() {
        return mapMethod;
    }

    public ArrayList<String> getRelatedQTL() {
        return relatedQTL;
    }
    
    public ArrayList<String> getRelatedQTLReason() {
        return relatedQTLreason;
    }

    public ArrayList<String> getCandidateGene() {
        return candidateGene;
    }

    public ArrayList<String> getRGDRef() {
        return rgdRef;
    }

    public ArrayList<String> getPubmedRef() {
        return pubmedRef;
    }

    public double getLOD() {
        return lod;
    }

    public double getPValue() {
        return pValue;
    }

    public String getChromosome() {
        return chromosome;
    }

    public long getStart() {
        return start;
    }

    public long getStop() {
        return stop;
    }
    

    
    
    
    
}
