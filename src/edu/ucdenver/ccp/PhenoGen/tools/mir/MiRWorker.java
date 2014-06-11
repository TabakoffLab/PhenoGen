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
import edu.ucdenver.ccp.PhenoGen.tools.mir.MiRTools;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;


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


public class MiRWorker extends Thread {
    private MiRTools parent;
    private DataSource pool;
    private int geneListID;
    private String geneListPath;
    private MiRWorker prevThread;
    private boolean done=false;
    private HttpSession session;
    private String fullPath;
    
    public MiRWorker(int geneListID,DataSource pool,MiRTools parent,HttpSession session,String path){
        this.geneListID=geneListID;
        this.pool=pool;
        this.parent=parent;
        this.session=session;
        this.fullPath=path.substring(0, path.lastIndexOf("/"));
    }
    
    /*public MiRWorker(String geneListPath,DataSource pool,MiRTools parent){
        this.geneListPath=geneListPath;
        this.pool=pool;
        this.parent=parent;
    }*/
    
    public void run() throws RuntimeException {
        done=false;
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
        GeneList gl=null;
        GeneList tmpGL=new GeneList();
        String[] myGeneArray=null;
        HashMap<String,String> identifiers=new HashMap<String,String>();
        StringBuilder sb=new StringBuilder();
        try{
            conn=pool.getConnection();
            gl=tmpGL.getGeneList(geneListID,conn);
            myGeneArray = gl.getGenesAsArray("Original",conn);
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
        String[] targets=new String[] {"Gene Symbol","Ensembl ID"};
        IDecoderClient myIDecoderClient=new IDecoderClient();
        /*try{
            Set iDecoderSet = myIDecoderClient.getIdentifiersByInputIDAndTarget(gl.getGene_list_id(), 
							targets, pool);
            for (int i=0; i<myGeneArray.length; i++) {
                Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(myGeneArray[i], iDecoderSet); 			
                if (thisIdentifier != null) {
                    myIDecoderClient.setNum_iterations(3);
                    Set geneSymbols = myIDecoderClient.getIdentifiersForTargetForOneID(thisIdentifier.getTargetHashMap(), targets);
                    String geneSym="";
                    String ens="";
                    if (geneSymbols.size() > 0) { 						
                        for (Iterator symbolItr = geneSymbols.iterator(); symbolItr.hasNext();) { 
                            Identifier symbol = (Identifier) symbolItr.next();
                            if(symbol.getIdentifier().toString().startsWith("ENS")&&symbol.getIdentifier().toString().indexOf("G")>0){
                                ens=ens+symbol.getIdentifier()+",";
                            }else if(!symbol.getIdentifier().toString().startsWith("ENS")){
                                geneSym=geneSym+symbol.getIdentifier()+",";
                            }
                        }
                        if(!geneSym.equals("")){
                            sb.append(geneSym);
                            identifiers.put(myGeneArray[i],geneSym);
                        }else if(!ens.equals("")){
                            sb.append(ens);
                            identifiers.put(myGeneArray[i],ens);
                        }
                    } else {
                    } 
                }                       
            }
            //output a list of gene symbol/ensembl id
            FileHandler FH=new FileHandler();
            try{
                File dir=new File(fullPath);
                if(!dir.exists()){
                    dir.mkdirs();
                }
                sb.deleteCharAt(sb.length()-1);
                FH.writeFile(sb.toString(),fullPath+"/tmpInputList.txt");
            }catch(IOException e){

            }
            /*rFunction = "mir.getTargets";
            //call multimir
            functionArgs = new String[9];
            functionArgs[0] = "InputFile = " + inputFile;
            functionArgs[1] = "ClusterType = '" + cluster_method + "'";
            rErrorMsg = myR_session.callR(this.getRFunctionDir(), rFunction, functionArgs, analysisPath, -99);
            if (warningFile.exists()) {

            } */
            //output multimir results to file
        /*}catch(SQLException er){
            
        }*/
        done=true;
        parent.removeThread(this);
    }
    
    public void setPreviousThread(MiRWorker prevThread){
        this.prevThread=prevThread;
    }
    
    public boolean isDone(){
        return this.done;
    }
    
}