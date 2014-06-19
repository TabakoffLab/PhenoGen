package edu.ucdenver.ccp.PhenoGen.tools.mir;

/*
*   Spencer Mahaffey
*   March 2014
*
*   Provide functions to run multiMiR and link results to Genes and eQTLs
*   also to create interactive circos plots for results.
*
*/



import edu.ucdenver.ccp.PhenoGen.driver.RException;
import edu.ucdenver.ccp.PhenoGen.driver.R_session;
import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.data.Bio.Gene;
import edu.ucdenver.ccp.PhenoGen.data.Bio.BQTL;
import edu.ucdenver.ccp.PhenoGen.data.Bio.EQTL;
import edu.ucdenver.ccp.PhenoGen.data.Bio.Transcript;
import edu.ucdenver.ccp.PhenoGen.data.Bio.TranscriptCluster;
import edu.ucdenver.ccp.PhenoGen.data.Bio.SmallNonCodingRNA;
import edu.ucdenver.ccp.PhenoGen.data.Bio.SequenceVariant;
import edu.ucdenver.ccp.PhenoGen.driver.PerlHandler;
import edu.ucdenver.ccp.PhenoGen.driver.PerlException;
import edu.ucdenver.ccp.PhenoGen.driver.ExecHandler;
import edu.ucdenver.ccp.PhenoGen.driver.ExecException;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.PhenoGen.tools.analysis.Statistic;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;
import edu.ucdenver.ccp.PhenoGen.tools.mir.MiRWorker;
import edu.ucdenver.ccp.PhenoGen.tools.mir.MiRResult;



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





public class MiRTools {
    private HttpSession session;
    private User user;
    private DataSource pool;
    private String rFunctDir;
    private String applicationRoot="";
    private String contextRoot="";
    private ArrayList<MiRWorker> threads=new ArrayList<MiRWorker>();
    private HashMap<String,String> singleGeneCache=new HashMap<String,String>();
    private HashMap<String,String> mirGeneCache=new HashMap<String,String>();
    
    
    public MiRTools(){
    }
    
    public void setup(DataSource pool,HttpSession session){
        this.session=session;
        this.rFunctDir = (String) session.getAttribute("rFunctionDir");
        this.applicationRoot = (String) session.getAttribute("applicationRoot");
        this.contextRoot = (String) session.getAttribute("contextRoot");
        this.pool=pool;
        user=(User)session.getAttribute("userLoggedIn");
    }
    
    public boolean isMirResults(String path){
        boolean ret=false;
        File mirFile=new File(path);
        if(mirFile.exists()){
            ret=true;
        }
        return ret;
    }
    
    public String runMultiMiRGeneList(GeneList gl,String org,String table,String predType,int cutoff,String name){
        String status="Running..."+name;
        Date start = new Date();
        GregorianCalendar gc = new GregorianCalendar();
        gc.setTime(start);
        String datePart=Integer.toString(gc.get(gc.MONTH)+1)+
                Integer.toString(gc.get(gc.DAY_OF_MONTH))+
                Integer.toString(gc.get(gc.YEAR))+"_"+
                Integer.toString(gc.get(gc.HOUR_OF_DAY))+
                Integer.toString(gc.get(gc.MINUTE))+
                Integer.toString(gc.get(gc.SECOND));
        String mirFilePath=this.user.getUserGeneListsDir() +"/" + gl.getGene_list_name_no_spaces() +"/multiMir/"+datePart+"/";
        //create DB entry
        
        
        
        MiRWorker mw=new MiRWorker(gl,this.pool,this,this.session,mirFilePath,org,table,predType,cutoff);
        if(threads.size()>0){
                MiRWorker prev=threads.get(threads.size()-1);
                if(prev.isAlive()){
                    mw.setPreviousThread(prev);
                    status="In Queue...Waiting";
                }
        }
        mw.start();
        threads.add(mw);
        return status;
    }
    
    public synchronized void removeThread(MiRWorker done){
        threads.remove(done);
    }
    
    public ArrayList<MiRResult> getMirTargetingGene(String org,String geneID,String table,String predType,int cutoff){
        ArrayList<MiRResult> ret=new ArrayList<MiRResult>();
        Date start = new Date();
        GregorianCalendar gc = new GregorianCalendar();
        gc.setTime(start);
        String datePart=Integer.toString(gc.get(gc.MONTH)+1)+
                Integer.toString(gc.get(gc.DAY_OF_MONTH))+
                Integer.toString(gc.get(gc.YEAR))+"_"+
                Integer.toString(gc.get(gc.HOUR_OF_DAY))+
                Integer.toString(gc.get(gc.MINUTE))+
                Integer.toString(gc.get(gc.SECOND));
        String outputPath=applicationRoot + contextRoot+"tmpData/mirData/"+datePart+"_" +geneID+"/";
        String prefix=table+"."+predType+cutoff;
        boolean run=true;
        //check users cache for the session
        if(singleGeneCache.containsKey(geneID)){
            String testPath=singleGeneCache.get(geneID);
            File testFile=new File(testPath+prefix+".summary.txt");
            if(testFile.exists()){//setup to load from cache file instead of run
                run=false;
                outputPath=testPath;
            }
        }
        if(run){//don't run if cache hit
            R_session myR_session = new R_session();
            String rOrg="mmu";
            if(org.equals("Rn")){
                rOrg="rno";
            }
            String[] functionArgs=new String[7];
            functionArgs[0] = "geneID= '" + geneID + "'";
            functionArgs[1] = "organism = '" + rOrg + "'";
            functionArgs[2] = "outputDir = '" + outputPath +"'";
            functionArgs[3] = "outputPrefix = '" + prefix +"'";
            functionArgs[4] = "tbl = '" + table +"'";
            functionArgs[5] = "cutoffType = '" + predType +"'";
            functionArgs[6] = "cutoff = " + cutoff;
            File dirs=new File(outputPath);
            if(!dirs.exists()&& dirs.mkdirs()){
                try{
                String[] errorMsg=myR_session.callR(this.rFunctDir, "multiMiR.getMiRTargetingGene", functionArgs, outputPath, -99);
                if(errorMsg==null){
                    ret=MiRResult.readResults(outputPath,prefix);
                    singleGeneCache.put(geneID,outputPath);
                }else{

                }
                }catch(RException er){

                }
            }
        }else{//reaad from cache
            ret=MiRResult.readResults(outputPath,prefix);
        }
        
        return ret;
    }
    
    public ArrayList<MiRResult> getGenesTargetedByMir(String org,String mirID,String table,String predType,int cutoff){
        ArrayList<MiRResult> ret=new ArrayList<MiRResult>();
        Date start = new Date();
        GregorianCalendar gc = new GregorianCalendar();
        gc.setTime(start);
        String datePart=Integer.toString(gc.get(gc.MONTH)+1)+
                Integer.toString(gc.get(gc.DAY_OF_MONTH))+
                Integer.toString(gc.get(gc.YEAR))+"_"+
                Integer.toString(gc.get(gc.HOUR_OF_DAY))+
                Integer.toString(gc.get(gc.MINUTE))+
                Integer.toString(gc.get(gc.SECOND));
        String outputPath=applicationRoot + contextRoot+"tmpData/mirData/"+datePart+"_" +mirID+"/";
        String prefix=table+"."+predType+cutoff;
        boolean run=true;
        //check users cache for the session
        if(mirGeneCache.containsKey(mirID)){
            String testPath=mirGeneCache.get(mirID);
            File testFile=new File(testPath+prefix+".summary.txt");
            if(testFile.exists()){//setup to load from cache file instead of run
                run=false;
                outputPath=testPath;
            }
        }
        if(run){//don't run if cache hit
            R_session myR_session = new R_session();
            String rOrg="mmu";
            if(org.equals("Rn")){
                rOrg="rno";
            }
            String[] functionArgs=new String[7];
            functionArgs[0] = "mirID= '" + mirID + "'";
            functionArgs[1] = "organism = '" + rOrg + "'";
            functionArgs[2] = "outputDir = '" + outputPath +"'";
            functionArgs[3] = "outputPrefix = '" + prefix +"'";
            functionArgs[4] = "tbl = '" + table +"'";
            functionArgs[5] = "cutoffType = '" + predType +"'";
            functionArgs[6] = "cutoff = " + cutoff;
            File dirs=new File(outputPath);
            if(!dirs.exists()&& dirs.mkdirs()){
                try{
                String[] errorMsg=myR_session.callR(this.rFunctDir, "multiMiR.getGenesTargetedByMir", functionArgs, outputPath, -99);
                if(errorMsg==null){
                    ret=MiRResult.readResults(outputPath,prefix);
                    mirGeneCache.put(mirID,outputPath);
                }else{

                }
                }catch(RException er){

                }
            }
        }else{//reaad from cache
            ret=MiRResult.readResults(outputPath,prefix);
        }
        
        return ret;
    }
    
    
}