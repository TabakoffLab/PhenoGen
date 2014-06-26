package edu.ucdenver.ccp.PhenoGen.tools.mir;

/*
*   Spencer Mahaffey
*   March 2014
*
*   Provide functions to run multiMiR and link results to Genes and eQTLs
*   also to create interactive circos plots for results.
*
*/

import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.PhenoGen.tools.mir.MiRResult;
import edu.ucdenver.ccp.PhenoGen.tools.databases.LinkGenerator;


import java.util.GregorianCalendar;
import java.util.Date;

import javax.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.SQLException;

import org.apache.log4j.Logger;

import edu.ucdenver.ccp.PhenoGen.web.mail.*;
import java.io.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;
import java.util.Set;
import javax.sql.DataSource;
import java.lang.Thread;
import org.apache.log4j.Logger;


public class MiRResultSummary {
    String accession="";
    String id="";
    ArrayList<String> validatedList=new ArrayList<String>();
    ArrayList<String> predictedList=new ArrayList<String>();
    ArrayList<MiRResult> results=new ArrayList<MiRResult>();
    HashMap<String,MiRResult> includedGenes = new HashMap<String,MiRResult>();
    
    public MiRResultSummary(){
        
    }
    public MiRResultSummary(String acc,String id){
       this.accession=acc;
       this.id=id;
    }

    public void addResult(MiRResult res){
        int valCount=Integer.parseInt(res.getCountForSource("validated.sum"));
        int predCount=Integer.parseInt(res.getCountForSource("predicted.sum"));
        if(valCount>0){
            if(!includedGenes.containsKey(res.getTargetSym()+":"+res.getTargetEntrez()+":"+res.getTargetEnsembl())){
                validatedList.add(res.getTargetSym()+":"+res.getTargetEntrez()+":"+res.getTargetEnsembl());
                includedGenes.put(res.getTargetSym()+":"+res.getTargetEntrez()+":"+res.getTargetEnsembl(),res);
            }
        }else if(predCount>0){
            if(!includedGenes.containsKey(res.getTargetSym()+":"+res.getTargetEntrez()+":"+res.getTargetEnsembl())){
                predictedList.add(res.getTargetSym()+":"+res.getTargetEntrez()+":"+res.getTargetEnsembl());
                includedGenes.put(res.getTargetSym()+":"+res.getTargetEntrez()+":"+res.getTargetEnsembl(),res);
            }
        }
    }

    public String getAccession() {
        return accession;
    }

    public void setAccession(String accession) {
        this.accession = accession;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public ArrayList<String> getValidatedList() {
        return validatedList;
    }

    public void setValidatedList(ArrayList<String> validatedList) {
        this.validatedList = validatedList;
    }

    public ArrayList<String> getPredictedList() {
        return predictedList;
    }

    public void setPredictedList(ArrayList<String> predictedList) {
        this.predictedList = predictedList;
    }
    
    public int getValidCount(){
        return this.validatedList.size();
    }
    
    public int getPredictedCount(){
        return this.predictedList.size();
    }
    
    public int getTotalCount(){
        return this.validatedList.size()+this.predictedList.size();
    }
    
    public String getValidListHTML(){
        String ret="Validated Gene Targets:<BR>";
        for(int i=0;i<validatedList.size();i++){
            String[] list=validatedList.get(i).split(":");
            String text=list[0]+" - ";
            if(list[0].equals("")){
                text=list[2]+" - ";
            }
            ret=ret+"<BR>"+text+"<a href=http://www.ncbi.nlm.nih.gov/gene/?term="+list[1]+" target=_blank>NCBI</a> - <a href="+LinkGenerator.getEnsemblLinkEnsemblID(list[2],"mus_musculus")+" target=_blank>Ensembl</a>";
        }
        return ret;
    }
    
    public String getPredictedListHTML(){
        String ret="Predicted Genes Targets:<BR>";
        for(int i=0;i<predictedList.size();i++){
            String[] list=predictedList.get(i).split(":");
            String text=list[0]+" - ";
            if(list[0].equals("")){
                text=list[2]+" - ";
            }
            ret=ret+"<BR>"+text+"<a href=http://www.ncbi.nlm.nih.gov/gene/?term="+list[1]+" target=_blank>NCBI</a> - <a href="+LinkGenerator.getEnsemblLinkEnsemblID(list[2],"mus_musculus")+" target=_blank>Ensembl</a>";
        }
        return ret;
    }
    
    public String getTotalListHTML(){
        String ret="";
        boolean valid=false;
        if(this.validatedList.size()>0){
            ret=this.getValidListHTML();
            valid=true;
        }
        if(this.predictedList.size()>0){
            if(valid){
                ret=ret+"<BR><BR>";
            }
            ret=ret+this.getPredictedListHTML();
        }
        return ret;
    }
    
   public ArrayList<MiRResultSummary> createSummaryList(ArrayList<MiRResult> results){
      HashMap<String,MiRResultSummary> hm=new HashMap<String,MiRResultSummary>();
      for(int i=0;i<results.size();i++){
          MiRResult cur=results.get(i);
          if(hm.containsKey(cur.getAccession())){
              MiRResultSummary sum=hm.get(cur.getAccession());
              sum.addResult(cur);
          }else{
              MiRResultSummary sum=new MiRResultSummary(cur.getAccession(),cur.getId());
              sum.addResult(cur);
              hm.put(cur.getAccession(),sum);
          }
      }
      ArrayList<MiRResultSummary> ret=new ArrayList<MiRResultSummary>();
       Iterator keyItr=hm.keySet().iterator();
       while(keyItr.hasNext()){
           Object next=keyItr.next();
           ret.add(hm.get(next));
       }
       return ret;
   }
    
}