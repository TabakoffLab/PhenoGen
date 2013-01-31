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
    
    public Annotation(String source, String value,String type){
        this.shortSource=source;
        this.value=value;
        this.type=type;
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
        }else if(type.equals("snmc")){
            
        }
        return ret;
    }
    
    
}
