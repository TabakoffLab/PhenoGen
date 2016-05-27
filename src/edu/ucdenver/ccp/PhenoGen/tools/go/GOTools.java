package edu.ucdenver.ccp.PhenoGen.tools.go;

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
import edu.ucdenver.ccp.PhenoGen.data.AnonUser;
import edu.ucdenver.ccp.PhenoGen.data.Bio.Gene;
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
import edu.ucdenver.ccp.PhenoGen.tools.go.GOWorker;

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





public class GOTools {
    private HttpSession session;
    private User user;
    private AnonUser anonU;
    private DataSource pool;
    private String rFunctDir;
    private String applicationRoot="";
    private String contextRoot="";
    private ArrayList<GOWorker> threads=new ArrayList<GOWorker>();
    private Logger log=null;
    
    public GOTools(){
        log = Logger.getRootLogger();
    }
    
    public void setup(DataSource pool,HttpSession session){
        this.session=session;
        this.rFunctDir = (String) session.getAttribute("rFunctionDir");
        this.applicationRoot = (String) session.getAttribute("applicationRoot");
        this.contextRoot = (String) session.getAttribute("contextRoot");
        this.pool=pool;
        user=(User)session.getAttribute("userLoggedIn");
    }
    
    public void setAnonUser(AnonUser au){
        this.anonU=au;
    }
    
    public boolean isGOResults(String path){
        boolean ret=false;
        File mirFile=new File(path);
        if(mirFile.exists()){
            ret=true;
        }
        return ret;
    }
    
    public String runGOGeneList(GeneList gl,String org,String genomeVer,String name,int glaID){
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
        String goFilePath=this.user.getUserGeneListsDir() +"/" + gl.getGene_list_name_no_spaces() +"/GO/"+datePart+"/";
        if(this.user.getUser_name().equals("anon")){
            goFilePath=this.user.getUserGeneListsDir() +"/" + anonU.getUUID()+"/"+gl.getGene_list_id()+"/GO/"+datePart+"/";
        }
        log.debug("runGOGeneList:\n"+goFilePath);
        //create DB entry
        
        
        
        GOWorker mw=new GOWorker(gl,this.pool,this,this.session,goFilePath,org,genomeVer,glaID);
        if(threads.size()>0){
                GOWorker prev=threads.get(threads.size()-1);
                if(prev.isAlive()){
                    mw.setPreviousThread(prev);
                    status="In Queue...Waiting";
                }
        }
        log.debug("start goWorker");
        mw.start();
        threads.add(mw);
        return status;
    }
    
    public synchronized void removeThread(GOWorker done){
        threads.remove(done);
    }
    
    /*public ArrayList<MiRResult> getGOGene(String org,String geneID){
        ArrayList<MiRResult> ret=new ArrayList<MiRResult>();
        return ret;
    }
    
    public ArrayList<MiRResult> getGenesForGO(String org,String goID){
        ArrayList<MiRResult> ret=new ArrayList<MiRResult>();
        return ret;
    }*/
    
    
}