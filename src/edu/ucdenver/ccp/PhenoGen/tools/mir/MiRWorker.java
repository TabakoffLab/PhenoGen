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


public class MiRWorker extends Thread {
    private MiRTools parent;
    private DataSource pool;
    private GeneList geneList;
    private String geneListPath;
    private MiRWorker prevThread;
    private boolean done=false;
    private HttpSession session;
    private String fullPath;
    private String shortPath;
    private String rFunctDir;
    private String organism;
    private String table;
    private String predType;
    private int cutoff;
    private GeneListAnalysis gla;
    private int glaID;
    String [] validated=new String[3];
    String [] predicted=new String[8];
    String[] total=new String[3];
    String[] all=new String[14];
	/*String [][] disease=new String[3][3];
	disease[0][0]="mir2disease";
	disease[0][1]="mir2disease";
	disease[0][2]="mir2disease";
	disease[1][0]="pharmaco_mir";
	disease[1][1]="pharmaco_mir";
	disease[1][2]="pharmaco_mir";
	disease[2][0]="phenomir";
	disease[2][1]="phenomir";
	disease[2][2]="phenomir";*/
	

    
    public MiRWorker(GeneList gl,DataSource pool,MiRTools parent,HttpSession session,String path,String org,String table,String predType,int cutoff,int glaID){
        this.geneList=gl;
        this.pool=pool;
        this.parent=parent;
        this.session=session;
        this.rFunctDir = (String) session.getAttribute("rFunctionDir");
        this.fullPath=path.substring(0, path.lastIndexOf("/"));
        this.shortPath=fullPath.substring(fullPath.lastIndexOf("/")+1);
        this.organism=org;
        this.table=table;
        this.predType =predType;
        this.cutoff=cutoff;
        this.glaID=glaID;
        validated[0]="mirecords";
	validated[1]="mirtarbase";
	validated[2]="tarbase";
        predicted[0]="diana_microt";
	predicted[1]="elmmo";
	predicted[2]="microcosm";
	predicted[3]="miranda";
	predicted[4]="mirdb";
	predicted[5]="pictar";
	predicted[6]="pita";
	predicted[7]="targetscan";
        total[0]="validated.sum";
	total[1]="predicted.sum";
	total[2]="all.sum";
        int ind=0;
        for(int i=0;i<predicted.length;i++){
            all[ind]=predicted[i];
            ind++;
        }
        for(int i=0;i<validated.length;i++){
            all[ind]=validated[i];
            ind++;
        }
        for(int i=0;i<total.length;i++){
            all[ind]=total[i];
            ind++;
        }
    }
    
    /*public MiRWorker(String geneListPath,DataSource pool,MiRTools parent){
        this.geneListPath=geneListPath;
        this.pool=pool;
        this.parent=parent;
    }*/
    
    public void run() throws RuntimeException {
        done=false;
        User userLoggedIn= (User) session.getAttribute("userLoggedIn");
        try{
            if(userLoggedIn.getUser_name().equals("anon")){
                gla=(new GeneListAnalysis()).getAnonGeneListAnalysis(glaID,pool);
            }else{
                gla=(new GeneListAnalysis()).getGeneListAnalysis(glaID,pool);
            }
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
        GeneList tmpGL=new GeneList();
        String[] myGeneArray=null;
        HashMap<String,String> identifiers=new HashMap<String,String>();
        StringBuilder sb=new StringBuilder();
        try{
        myGeneArray = geneList.getGenesAsArray("Original",pool);
        }catch(SQLException e){}
        Identifier myIdentifier=new Identifier();
        String[] targets=new String[] {"Gene Symbol","Ensembl ID"};
        IDecoderClient myIDecoderClient=new IDecoderClient();
        HashMap<String,String> prevRunHM=new HashMap<String,String>();
        String prefix="tmp";
        R_session myR_session = new R_session();
        String rOrg="mmu";
        if(organism.equals("Rn")){
            rOrg="rno";
        }
        String[] functionArgs=new String[7];
        functionArgs[0] = "geneID= ''";
        functionArgs[1] = "organism = '" + rOrg + "'";
        functionArgs[2] = "outputDir = '" + fullPath +"/'";
        functionArgs[3] = "outputPrefix = '" + prefix +"'";
        functionArgs[4] = "tbl = '" + table +"'";
        functionArgs[5] = "cutoffType = '" + predType +"'";
        functionArgs[6] = "cutoff = " + cutoff;
        File dirs=new File(fullPath);
        if(!dirs.exists()&& dirs.mkdirs()){
        }
        try{
            Set iDecoderSet = myIDecoderClient.getIdentifiersByInputIDAndTarget(geneList.getGene_list_id(), 
							targets, pool);
            for (int i=0; i<myGeneArray.length; i++) {
                Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(myGeneArray[i], iDecoderSet); 			
                if (thisIdentifier != null) {
                    myIDecoderClient.setNum_iterations(2);
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
                        String search=geneSym;
                        if(geneSym.equals("")&&!ens.equals("")){
                            search=ens;
                        }
                        //Split search
                        String[] tmpList=search.split(",");
                        //search each name not previously searched
                        for(int j=0;j<tmpList.length;j++){
                            if(!prevRunHM.containsKey(tmpList[j])){
                                
                                //prep R call by updating to new geneID
                                functionArgs[0] = "geneID= '"+tmpList[j]+"'";
                                try{
                                    String[] errorMsg=myR_session.callR(this.rFunctDir, "multiMiR.getMiRTargetingGene", functionArgs, fullPath+"/", -99);
                                    if(errorMsg==null){
                                    }else{

                                    }
                                }catch(RException er){

                                }
                                //append to summary files
                                mergeFile(fullPath+"/"+prefix+".val.txt",fullPath+"/full.val.txt");
                                mergeFile(fullPath+"/"+prefix+".pred.txt",fullPath+"/full.pred.txt");
                                mergeSummaryFile(fullPath+"/"+prefix+".summary.txt",fullPath+"/full.summary.txt",all);
                                
                            }
                        }
                        //rename summary files
                        //update status
                    } else {
                    } 
                }                       
            }
            this.gla.updateStatus(pool,"Complete");
        }catch(SQLException er){
            try{
                this.gla.updateStatus(pool,"Error");
            }catch(SQLException e){
                
            }
        }
        done=true;
        parent.removeThread(this);
    }
    
    public void setPreviousThread(MiRWorker prevThread){
        this.prevThread=prevThread;
    }
    
    public boolean isDone(){
        return this.done;
    }

    private void mergeFile(String source, String dest){
        boolean newFile=true;
        File tmp=new File(dest);
        if(tmp.exists()){
            newFile=false;
        }
        try{
            BufferedWriter out=new BufferedWriter(new FileWriter(dest,true));
            BufferedReader in=new BufferedReader(new FileReader(source));
            int count=0;
            while(in.ready()){
                if(count>0){
                    out.write(in.readLine()+"\n");
                }else{
                   String header=in.readLine();
                   if(newFile){
                       out.write(header+"\n");
                   }
                }
                count++;
            }
            out.flush();
            out.close();
            in.close();
            File toDel=new File(source);
            toDel.delete();
        }catch(IOException e){
        }
    }
    private void mergeSummaryFile(String source, String dest,String[] list){
        boolean newFile=true;
        File tmp=new File(dest);
        if(tmp.exists()){
            newFile=false;
        }
        try{
            HashMap<String,String> columns=new HashMap<String,String>();
            BufferedWriter out=new BufferedWriter(new FileWriter(dest,true));
            BufferedReader in=new BufferedReader(new FileReader(source));
            int count=0;
            while(in.ready()){
                if(count>0){
                    String newline="";
                    String line=in.readLine();
                    String[] cols=line.split("\t");
                    newline=cols[0]+"\t"+cols[1]+"\t"+cols[2]+"\t"+cols[3]+"\t"+cols[4];
                    for(int i=0;i<list.length;i++){
                        if(columns.containsKey(list[i])){
                            int tmpind=Integer.parseInt(columns.get(list[i]));
                            newline=newline+"\t"+cols[tmpind];
                        }else{
                            newline=newline+"\t0";
                        }
                    }
                    out.write(newline+"\n");
                }else{
                    String header=in.readLine();
                    String[] cols=header.split("\t");
                    for(int i=5;i<cols.length;i++){
                        columns.put(cols[i],Integer.toString(i));
                    }
                    if(newFile){
                        out.write(cols[0]+"\t"+cols[1]+"\t"+cols[2]+"\t"+cols[3]+"\t"+cols[4]);
                        for(int i=0;i<list.length;i++){
                            out.write("\t"+list[i]);
                        }
                        out.write("\n");
                    }
                }
                count++;
            }
            out.flush();
            out.close();
            in.close();
            File toDel=new File(source);
            toDel.delete();
        }catch(IOException e){
        }
    }
}