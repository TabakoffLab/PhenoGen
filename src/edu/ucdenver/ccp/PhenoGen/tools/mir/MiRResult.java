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
import edu.ucdenver.ccp.PhenoGen.tools.mir.MiRDBResult;


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


public class MiRResult {
    String accession="";
    String id="";
    String targetSym="";
    String targetEntrez="";
    String targetEnsembl="";
    HashMap<String,String> sourceCount=new HashMap<String,String>();
    Logger log=null;
    HashMap<String,ArrayList<MiRDBResult>> dbResult=new HashMap<String,ArrayList<MiRDBResult>>();
    
    
    public MiRResult(){
        log = Logger.getRootLogger();
    }

    
    public MiRResult(String acc,String id,String targetSym,String entrez,String ensembl,HashMap<String,String> sourceCount){
        log = Logger.getRootLogger();
        this.accession=acc;
        this.id=id;
        this.targetSym=targetSym;
        this.targetEntrez=entrez;
        this.targetEnsembl=ensembl;
        this.sourceCount=sourceCount;
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

    public String getTargetSym() {
        return targetSym;
    }

    public void setTargetSym(String targetSym) {
        this.targetSym = targetSym;
    }

    public String getTargetEntrez() {
        return targetEntrez;
    }

    public void setTargetEntrez(String targetEntrez) {
        this.targetEntrez = targetEntrez;
    }

    public String getTargetEnsembl() {
        return targetEnsembl;
    }

    public void setTargetEnsembl(String targetEnsembl) {
        this.targetEnsembl = targetEnsembl;
    }

    public HashMap getSourceCount() {
        return sourceCount;
    }

    public void setSourceCount(HashMap<String,String> sourceCount) {
        this.sourceCount = sourceCount;
    }
    public String getCountForSource(String source){
        return sourceCount.get(source);
    }
    
    public void addDBResult(MiRDBResult res){
        String db=res.getDatabase();
        if(dbResult.containsKey(db)){
            ArrayList<MiRDBResult> tmp=dbResult.get(db);
            tmp.add(res);
        }else{
            ArrayList<MiRDBResult> tmp=new ArrayList<MiRDBResult>();
            tmp.add(res);
            dbResult.put(db, tmp);
        }
    }

    public HashMap<String, ArrayList<MiRDBResult>> getDbResult() {
        return dbResult;
    }
    
    
    public ArrayList<MiRResult> readGeneListResults(String path){
        log.debug("read Mir Results Gene List:"+path);
        ArrayList<MiRResult> ret=new ArrayList<MiRResult>();
        ret=MiRResult.readResults(path,"full");
        return ret;
    }
    
    public static  ArrayList<MiRResult> readResults(String path,String prefix){
        ArrayList<MiRResult> ret=new ArrayList<MiRResult>();
        HashMap<String,Integer> hm=new HashMap<String,Integer>();
        try{
                BufferedReader in=new BufferedReader(new FileReader(new File(path+prefix+".summary.txt")));
                int count=0;
                ArrayList<String> columnList=new ArrayList<String>();
                while(in.ready()){
                    String line=in.readLine();
                    if(count==0){
                        String[] col=line.split("\t");
                        for(int i=5;i<col.length;i++){
                            columnList.add(col[i]);
                        }
                    }else{
                        String[] col=line.split("\t");
                        String acc=col[0];
                        String id=col[1];
                        String targetSym=col[2];
                        String entrez=col[3];
                        String ensembl=col[4];
                        HashMap<String,String> sourceCount=new HashMap<String,String>();
                        for(int i=5;i<col.length;i++){
                            sourceCount.put(columnList.get(i-5) , col[i].trim());
                        }
                        
                        MiRResult res=new MiRResult(acc,id,targetSym,entrez,ensembl,sourceCount);
                        ret.add(res);
                        hm.put(acc+":"+targetSym+":"+entrez+":"+ensembl, count-1);
                    }
                    count++;
                }
                in.close();
                readValidated(ret,hm,path,prefix);
                readPredicted(ret,hm,path,prefix);
        }catch(IOException e){
            
        }
        
        
        return ret;
    }
    
     private static void readValidated(ArrayList<MiRResult> list,HashMap<String,Integer> hm,String path,String prefix){
         try{
                BufferedReader in=new BufferedReader(new FileReader(new File(path+prefix+".val.txt")));
                int count=0;
                while(in.ready()){
                    String line=in.readLine();
                    if(count==0){
                    }else{
                        String[] col=line.split("\t");
                        String db=col[0];
                        String acc=col[1];
                        String id=col[2];
                        String targetSym=col[3];
                        String entrez=col[4];
                        String ensembl=col[5];
                        String exp="";
                        if(col.length>=7){
                            exp=col[6];
                        }
                        String sup="";
                        if(col.length>=8){
                            sup=col[7];
                        }
                        String pmid="";
                        if(col.length>=9){
                            pmid=col[8];
                        }
                        String link="";
                        if(col.length>10){
                            link=col[9];
                        }
                        MiRDBResult res=new MiRDBResult(db,acc,id,exp,sup,pmid,link,entrez,ensembl,targetSym);
                        MiRResult mir=list.get(hm.get(acc+":"+targetSym+":"+entrez+":"+ensembl));
                        mir.addDBResult(res);
                    }
                    count++;
                }
                in.close();
                
        }catch(IOException e){}
     }
     
     private static void readPredicted(ArrayList<MiRResult> list, HashMap<String,Integer> hm,String path,String prefix){
         try{
                BufferedReader in=new BufferedReader(new FileReader(new File(path+prefix+".pred.txt")));
                int count=0;
                while(in.ready()){
                    String line=in.readLine();
                    if(count==0){
                    }else{
                        String[] col=line.split("\t");
                        String db=col[0];
                        String acc=col[1];
                        String id=col[2];
                        String targetSym=col[3];
                        String entrez=col[4];
                        String ensembl=col[5];
                        double score=Double.parseDouble(col[6]);
                        String link="";
                        if(col.length>7){
                            link=col[7];
                        }
                        MiRDBResult res=new MiRDBResult(db,acc,id,score,link,entrez,ensembl,targetSym);
                        MiRResult mir=list.get(hm.get(acc+":"+targetSym+":"+entrez+":"+ensembl));
                        mir.addDBResult(res);
                    }
                    count++;
                }
                in.close();
                
        }catch(IOException e){}
         
            
     }
    
}