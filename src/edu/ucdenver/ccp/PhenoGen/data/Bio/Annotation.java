package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.ArrayList;
import java.util.Collections;


/* for logging messages */
import org.apache.log4j.Logger;
/**
 *
 * @author smahaffey
 */
public class Annotation {
    String shortSource="";
    String value="";
    String type="transcript";
    String reason="";
    int id=0;
    
    public Annotation(String source, String value,String type,String reason){
        this(source,value,type);
        this.reason=reason;
    }
    public Annotation(int id,String source, String value,String type){
        this(source,value,type);
        this.id=id;
    }
    public Annotation(String source, String value,String type){
        this.shortSource=source;
        this.value=value;
        this.type=type;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getSource() {
        return shortSource;
    }

    public void setSource(String shortSource) {
        this.shortSource = shortSource;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
    
    public String getDisplayHTMLString(boolean withLinks){
        String ret=shortSource+":"+value;
        if(type.equals("transcript")){
            if(shortSource.equals("RepeatMaskMisc")||shortSource.equals("RepeatMaskRNA")){
                String[] values=value.split(":");
                ret="<span title=\"Repeat:"+values[0]+" Family:"+values[2]+"\">"+values[1]+"</span>";
            }else if(shortSource.equals("NonRatRefSeq")||shortSource.equals("RefSeq")){
                String[] values=value.split(":");
                if(withLinks){
                    ret="<a href=\"http://www.ncbi.nlm.nih.gov/gene/?term="+values[0]+"\" target=\"_blank\">"+values[0]+"</a>";
                }else{
                    ret=values[0];
                }
            }else if(shortSource.equals("Ensembl")){
                String[] values=value.split(":");
                if(withLinks){
                    ret="<a href=\"http://www.ensembl.org/Rattus_norvegicus/Gene/Summary?g="+values[0]+"\" target=\"_blank\">"+values[0]+"</a>";
                }else{
                    ret=values[0];
                }
            }
        }else if(type.equals("smnc")){
            if(shortSource.equals("Ensembl")){
                String[] values=value.split(":");
                if(withLinks){
                    ret="<a href=\"http://www.ensembl.org/Rattus_norvegicus/Gene/Summary?g="+values[0]+"\" target=\"_blank\">"+values[values.length-1]+"</a>";
                }else{
                    ret=values[values.length-1];
                }
            }else if(shortSource.equals("RepeatMaskMisc")||shortSource.equals("RepeatMaskRNA")){
                String[] values=value.split(":");
                ret="<span title=\"Repeat:"+values[0]+" Family:"+values[2]+"\">"+values[1]+"</span>";
            }else if(shortSource.equals("NonRatRefSeq")||shortSource.equals("RefSeq")){
                String[] values=value.split(":");
                if(withLinks){
                    ret="<a href=\"http://www.ncbi.nlm.nih.gov/gene/?term="+values[0]+"\" target=\"_blank\">"+values[0]+"</a>";
                }else{
                    ret=values[0];
                }
            }else if(shortSource.equals("mirDeep")){
                //String[] values=value.split(":");
                //if(withLinks){
                //    ret=values[1];
                //}else{
                //    ret=values[1];
                //}
                ret=value;
            }
        }
        return ret;
    }
    
    public String getLongDisplayHTMLString(boolean withLinks){
        String ret=shortSource+":"+value;
        if(type.equals("transcript")){
            if(shortSource.equals("RepeatMaskMisc")||shortSource.equals("RepeatMaskRNA")){
                String[] values=value.split(":");
                ret=values[1]+" Repeat:"+values[0]+" Family:"+values[2];
            }else if(shortSource.equals("NonRatRefSeq")||shortSource.equals("RefSeq")){
                String[] values=value.split(":");
                if(withLinks){
                    ret="<a href=\"http://www.ncbi.nlm.nih.gov/gene/?term="+values[0]+"\" target=\"_blank\">"+values[0]+"</a>";
                }else{
                    ret=values[0];
                }
            }else if(shortSource.equals("Ensembl")){
                String[] values=value.split(":");
                if(withLinks){
                    ret="<a href=\"http://www.ensembl.org/Rattus_norvegicus/Gene/Summary?g="+values[0]+"\" target=\"_blank\">"+values[0]+"</a>";
                }else{
                    ret=values[0];
                }
            }
        }else if(type.equals("smnc")){
            if(shortSource.equals("Ensembl")){
                String[] values=value.split(":");
                if(withLinks){
                    ret="<a href=\"http://www.ensembl.org/Rattus_norvegicus/Gene/Summary?g="+values[0]+"\" target=\"_blank\">"+values[values.length-1]+"</a>";
                }else{
                    ret=values[values.length-1];
                }
            }else if(shortSource.equals("RepeatMaskMisc")||shortSource.equals("RepeatMaskRNA")){
                String[] values=value.split(":");
                ret=values[1]+" Repeat:"+values[0]+" Family:"+values[2];
            }else if(shortSource.equals("NonRatRefSeq")||shortSource.equals("RefSeq")){
                String[] values=value.split(":");
                if(withLinks){
                    ret="<a href=\"http://www.ncbi.nlm.nih.gov/gene/?term="+values[0]+"\" target=\"_blank\">"+values[0]+"</a>";
                }else{
                    ret=values[0];
                }
            }else if(shortSource.equals("mirDeep")){
                /*String[] values=value.split(":");
                if(withLinks){
                    ret=values[1];
                }else{
                    ret=values[1];
                }*/
                ret=value;
            }
        }
        return ret;
    }
    
    public String getEnsemblLink(){
        String[] values=value.split(":");
        return "<a href=\"http://www.ensembl.org/Rattus_norvegicus/Gene/Summary?g="+values[0]+"\" target=\"_blank\" title=\"View Ensembl Gene Details\">"+values[0]+"</a>";
    }
    
    public String getEnsemblGeneID(){
        String ret=null;
        String[] values=value.split(":");
        if(this.shortSource.equals("Ensembl")||this.shortSource.equals("AKA")){
            ret=values[0];
        }
        return ret;
        
    }
    public String getEnsemblTranscriptID(){
        String ret=null;
        String[] values=value.split(":");
        if(this.shortSource.equals("Ensembl")){
            ret=values[1];
        }
        return ret;
    }
    public String getAKAToolTip(){
        String[] tmp=value.split(":");
        String toDisplay="";
        if(tmp!=null && tmp.length==3){
            if(!tmp[1].equals("")){
                toDisplay="Transcript Match: "+tmp[1]+" ";
            }
        }
        toDisplay=toDisplay+reason;
        return toDisplay;
    }
   
}
