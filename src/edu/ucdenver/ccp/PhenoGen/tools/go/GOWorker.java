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
import edu.ucdenver.ccp.PhenoGen.tools.go.GOTools;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;
import edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis;


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


import au.com.forward.threads.ThreadException;
import au.com.forward.threads.ThreadReturn;


public class GOWorker extends Thread {
    private GOTools parent;
    private DataSource pool;
    private GeneList geneList;
    private String geneListPath;
    private GOWorker prevThread;
    private boolean done=false;
    private HttpSession session;
    private String fullPath;
    private String shortPath;
    private String rFunctDir;
    private String organism;
    private String ensemblDBPropertiesFile;
    private String perlDir;
    private String perlEnvVar;
    private GeneListAnalysis gla;
    private int glaID;
    private Logger log;


    public GOWorker(GeneList gl,DataSource pool,GOTools parent,HttpSession session,String path,String org,int glaID){
        this.geneList=gl;
        this.pool=pool;
        this.parent=parent;
        this.session=session;
        this.rFunctDir = (String) session.getAttribute("rFunctionDir");
        this.fullPath=path.substring(0, path.lastIndexOf("/"));
        this.shortPath=fullPath.substring(fullPath.lastIndexOf("/")+1);
        this.organism=org;
        this.glaID=glaID;
        this.log = Logger.getRootLogger();
        this.perlDir = (String) session.getAttribute("perlDir") + "scripts/";
        this.perlEnvVar=(String)session.getAttribute("perlEnvVar");
        this.ensemblDBPropertiesFile = (String)session.getAttribute("ensDbPropertiesFile");
    }
    
    public void run() throws RuntimeException {
        done=false;
        
        try{
            gla=(new GeneListAnalysis()).getGeneListAnalysis(glaID,pool);
            gla.updatePath(pool,shortPath);
        }catch(SQLException e){
            
        }
        try{
            //
            // If this thread is interrupted, throw an Exception
            //
            ThreadReturn.ifInterruptedStop();

            if (prevThread != null && !prevThread.isDone()) {
                //log.debug("waiting on thread "+prevThread.getName());
                ThreadReturn.join(prevThread);
                //log.debug("just finished waiting on thread "+prevThread.getName());
            }

            //
            // If this thread is interrupted, throw an Exception
            //
            ThreadReturn.ifInterruptedStop();
        }catch(InterruptedException e){
            
        }
        //convert Genelist ID to Gene Symbol/Ensembl IDs fill 
        Connection conn=null;
        GeneList tmpGL=new GeneList();
        String[] myGeneArray=null;
        HashMap<String,String> identifiers=new HashMap<String,String>();
        StringBuilder sb=new StringBuilder();
        try{
            conn=pool.getConnection();
            myGeneArray = geneList.getGenesAsArray("Original",conn);
            conn.close();
        }catch(SQLException e){
            
        }finally{
            try{
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
            }catch(SQLException e){}
        }
        Identifier myIdentifier=new Identifier();
        String[] targets=new String[] {"Ensembl ID"};
        IDecoderClient myIDecoderClient=new IDecoderClient();
        HashMap<String,String> prevRunHM=new HashMap<String,String>();
        String prefix="tmp";
        String rOrg="mmu";
        if(organism.equals("Rn")){
            rOrg="rno";
        }
        String[] functionArgs=new String[7];

        File dirs=new File(fullPath);
        if(!dirs.exists()&& dirs.mkdirs()){
        }
        try{
            BufferedWriter fout=new BufferedWriter(new FileWriter(new File(fullPath+"/inputGeneList.txt")));
            Set iDecoderSet = myIDecoderClient.getIdentifiersByInputIDAndTarget(geneList.getGene_list_id(),targets, pool);
            for (int i=0; i<myGeneArray.length; i++) {
                Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(myGeneArray[i], iDecoderSet); 			
                if (thisIdentifier != null) {
                    myIDecoderClient.setNum_iterations(2);
                    Set ensID = myIDecoderClient.getIdentifiersForTargetForOneID(thisIdentifier.getTargetHashMap(), targets);
                    String ens="";
                    if (ensID.size() > 0) { 						
                        for (Iterator symbolItr = ensID.iterator(); symbolItr.hasNext();) { 
                            Identifier symbol = (Identifier) symbolItr.next();
                            if(symbol.getIdentifier().toString().startsWith("ENS")&&symbol.getIdentifier().toString().indexOf("G")>0){
                                fout.write(symbol.getIdentifier().toString()+"\n");
                            }
                        }   
                    }
                }                       
            }
            fout.flush();
            fout.close();
            
            //call perl to run script to output json with GO terms
            File ensPropertiesFile = new File(ensemblDBPropertiesFile);
            Properties myENSProperties = new Properties();
            myENSProperties.load(new FileInputStream(ensPropertiesFile));
            String ensHost=myENSProperties.getProperty("HOST");
            String ensPort=myENSProperties.getProperty("PORT");
            String ensUser=myENSProperties.getProperty("USER");
            String ensPassword=myENSProperties.getProperty("PASSWORD");
             String[] perlArgs = new String[9];
            perlArgs[0] = "perl";
            perlArgs[1] = perlDir + "GOFilesForGeneList.pl";
            perlArgs[2] = organism;
            perlArgs[3] = fullPath+"/";
            perlArgs[4] = "inputGeneList.txt";
            perlArgs[5] = "output.json";
            perlArgs[6] = ensHost;
            perlArgs[7] = ensUser;
            perlArgs[8] = ensPassword;
            
            String[] envVar=perlEnvVar.split(",");
            
            ExecHandler myExec_session = new ExecHandler(perlDir, perlArgs, envVar, fullPath);
            boolean exception=false;

            try {

                myExec_session.runExec();
                log.debug("after exec No Exception");
            } catch (ExecException e) {
                exception = true;
                log.error("In Exception of run GOFilesForGeneList.pl Exec_session", e);
                
                String errorList=myExec_session.getErrors();
                String apiVer="";
                
                if(errorList.contains("Ensembl API version =")){
                    int apiStart=errorList.indexOf("Ensembl API version =")+22;
                    apiVer=errorList.substring(apiStart,apiStart+3);
                }
                Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in Exec_session");        
                String errors=myExec_session.getErrors();
                myAdminEmail.setContent("There was an error while running "
                        + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" , "+perlArgs[5]+
                        ")\n\n"+errors);
                try {
                    if(errors!=null &&errors.length()>0){
                        myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                    }
                } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    try {
                        myAdminEmail.sendEmailToAdministrator("");
                    } catch (Exception mailException1) {
                        //throw new RuntimeException();
                    }
                }
            }
            
            this.gla.updateStatus(pool,"Complete");
        }catch(Exception er){
            try{
                this.gla.updateStatus(pool,"Error");
            }catch(SQLException e){
                
            }
        }
        done=true;
        parent.removeThread(this);
    }
    
    public void setPreviousThread(GOWorker prevThread){
        this.prevThread=prevThread;
    }
    
    public boolean isDone(){
        return this.done;
    }

    
}