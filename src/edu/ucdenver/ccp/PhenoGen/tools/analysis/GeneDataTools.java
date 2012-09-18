package edu.ucdenver.ccp.PhenoGen.tools.analysis;

import edu.ucdenver.ccp.PhenoGen.driver.RException;
import edu.ucdenver.ccp.PhenoGen.driver.R_session;
import edu.ucdenver.ccp.PhenoGen.data.AsyncUpdateDataset;
import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.driver.PerlHandler;
import edu.ucdenver.ccp.PhenoGen.driver.PerlException;
import edu.ucdenver.ccp.PhenoGen.driver.ExecHandler;
import edu.ucdenver.ccp.PhenoGen.driver.ExecException;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.PhenoGen.tools.analysis.Statistic;
import edu.ucdenver.ccp.PhenoGen.tools.analysis.AsyncGeneDataExpr;
import edu.ucdenver.ccp.PhenoGen.tools.analysis.AsyncGeneDataTools;

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
import java.util.Properties;



public class GeneDataTools {
    private ArrayList<Thread> threadList=new ArrayList<Thread>();
    private String[] rErrorMsg = null;
    private R_session myR_session = new R_session();
    //private PerlHandler myPerl_session=null;
    private ExecHandler myExec_session = null;
    private HttpSession session = null;
    private User userLoggedIn = null;
    //private Dataset[] publicDatasets = null;
    //private Dataset selectedDataset = null;
    //private Dataset.DatasetVersion selectedDatasetVersion = null;
    private Connection dbConn = null;
    private Logger log = null;
    private String perlDir = "", fullPath = "";
    private String rFunctDir = "";
    private String userFilesRoot = "";
    private String urlPrefix = "";
    private int validTime=7*24*60*60*1000;
    private String perlEnvVar="";
    private String ucscDir="";
    private String ucscGeneDir="";
    private String bedDir="";
    private String geneSymbol="";
    private String ucscURL="";
    private String ucscURLfilter="";
    private String deMeanURL="";
    private String deFoldDiffURL="";
    private String chrom="";
    private String dbPropertiesFile="";
    private String ensemblDBPropertiesFile="";
    private int minCoord=0;
    private int maxCoord=0;
    FileHandler myFH=new FileHandler();
    private int usageID=-1;
    private int maxThreadRunning=1;
    
    private String getNextID="select TRANS_DETAIL_USAGE_SEQ.nextVal from dual";
    private String insertUsage="insert into TRANS_DETAIL_USAGE (TRANS_DETAIL_ID,INPUT_ID,IDECODER_RESULT,RUN_DATE,ORGANISM) values (?,?,?,?,?)";
    String updateSQL="update TRANS_DETAIL_USAGE set TIME_TO_RETURN=? , RESULT=? where TRANS_DETAIL_ID=?";
    
    

    public GeneDataTools() {
        log = Logger.getRootLogger();

    }
    
    public int[] getOrganismSpecificIdentifiers(String organism,Connection dbConn){
        
            int[] ret=new int[2];
            String organismLong="Mouse";
            if(organism.equals("Rn")){
                organismLong="Rat";
            }
            String atQuery="select Array_type_id from array_types "+
                        "where array_name like 'Affymetrix GeneChip "+organismLong+" Exon 1.0 ST Array'";
            String rnaIDQuery="select rna_dataset_id from RNA_DATASET "+
                        "where organism = '"+organism+"' and visible=1";
            PreparedStatement ps=null;
            try {
                ps = dbConn.prepareStatement(atQuery);
                ResultSet rs = ps.executeQuery();
                while(rs.next()){
                    ret[0]=rs.getInt(1);
                }
                ps.close();
            } catch (SQLException ex) {
                log.error("SQL Exception retreiving Array_Type_ID from array_types for Organism="+organism ,ex);
                try {
                    ps.close();
                } catch (Exception ex1) {
                   
                }
            }
            try {
                ps = dbConn.prepareStatement(rnaIDQuery);
                ResultSet rs = ps.executeQuery();
                while(rs.next()){
                    ret[1]=rs.getInt(1);
                }
                ps.close();
            } catch (SQLException ex) {
                log.error("SQL Exception retreiving RNA_dataset_ID from RNA_DATASET for Organism="+organism ,ex);
            try {
                ps.close();
            } catch (Exception ex1) {
                
            }
            }
            return ret;
        
    }

    /**
     * Calls the Perl script WriteXML_RNA.pl and R script ExonCorrelation.R.
     * @param ensemblID       the ensemblIDs as a comma separated list
     * @param panel 
     * @param organism        the organism         
     * 
     */
    public void getGeneCentricData(String inputID,String ensemblIDList,
            String panel,
            String organism,int RNADatasetID,int arrayTypeID) {
        
        //Setup a String in the format YYYYMMDDHHMM to append to the folder
        Date start = new Date();
        GregorianCalendar gc = new GregorianCalendar();
        gc.setTime(start);
        String rOutputPath = "";
        String outputDir="";
        String result="";
        try{
            PreparedStatement ps=dbConn.prepareStatement(getNextID, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
            ResultSet rs=ps.executeQuery();
            if (rs.next()){
                usageID=rs.getInt(1);
            }
            ps.close();
        }catch(SQLException e){
            log.error("Error getting Transcription Detail Usage ID.next()",e);
        }
        try{
            PreparedStatement ps=dbConn.prepareStatement(insertUsage, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
            ps.setInt(1, usageID);
            ps.setString(2,inputID);
            ps.setString(3, ensemblIDList);
            ps.setTimestamp(4, new Timestamp(start.getTime()));
            ps.setString(5, organism);
            ps.execute();
            ps.close();
        }catch(SQLException e){
            log.error("Error saving Transcription Detail Usage",e);
        }
        
        //EnsemblIDList can be a comma separated list break up the list
        String[] ensemblList = ensemblIDList.split(",");
        String ensemblID1 = ensemblList[0];
        boolean error=false;
        if(ensemblID1!=null){
            //Define output directory
            outputDir = fullPath + "tmpData/geneData/" + ensemblID1 + "/";
            session.setAttribute("geneCentricPath", outputDir);
            log.debug("checking for path:"+outputDir);
            String folderName = ensemblID1;
            //String publicPath = H5File.substring(H5File.indexOf("/Datasets/") + 10);
            //publicPath = publicPath.substring(0, publicPath.indexOf("/Affy.NormVer.h5"));
            
            try {
                File geneDir=new File(outputDir);
                if(geneDir.exists()){
                    Date lastMod=new Date(geneDir.lastModified());
                    Date prev2Months=new Date(start.getTime()-(60*24*60*60*1000));
                    if(lastMod.before(prev2Months)){
                        if(myFH.deleteAllFilesPlusDirectory(geneDir)){
                             generateFiles(outputDir,organism,rOutputPath,ensemblIDList,folderName,ensemblID1,RNADatasetID,arrayTypeID);
                             result="old files, regenerated all files";
                        }else{
                            error=true;
                        }
                    }else{
                        //do nothing just need to set session var
                        String errors;
                        errors = loadErrorMessage(outputDir);
                        if(errors.equals("")){
                            getUCSCUrls(outputDir,ensemblID1);
                            result="cache hit files not generated";
                        }else{
                            error=true;
                            this.setError(errors);
                        }
                    }
                }else{
                    generateFiles(outputDir,organism,rOutputPath,ensemblIDList,folderName,ensemblID1,RNADatasetID,arrayTypeID);
                    result="NewGene generated successfully";
                }
                
            } catch (Exception e) {
                error=true;
                
                log.error("In Exception getting Gene Centric Results", e);
                Email myAdminEmail = new Email();
                String fullerrmsg=e.getMessage();
                    StackTraceElement[] tmpEx=e.getStackTrace();
                    for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                    }
                myAdminEmail.setSubject("Exception thrown getting Gene Centric Results");
                myAdminEmail.setContent("There was an error while getting gene centric results.\n"+fullerrmsg);
                try {
                    myAdminEmail.sendEmailToAdministrator();
                } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    throw new RuntimeException();
                }
            }
        }else{
            error=true;
            setError("No Ensembl IDs");
        }
        if(error){
            result=(String)session.getAttribute("genURL");
        }
        this.setReturnSessionVar(error,outputDir,ensemblID1);
        
        try{
            PreparedStatement ps=dbConn.prepareStatement(updateSQL, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
            Date end=new Date();
            long returnTimeMS=end.getTime()-start.getTime();
            ps.setLong(1, returnTimeMS);
            ps.setString(2, result);
            ps.setInt(3, usageID);
            ps.executeUpdate();
            ps.close();
        }catch(SQLException e){
            log.error("Error saving Transcription Detail Usage",e);
        }
    }

    public boolean generateFiles(String outputDir,String organism,String rOutputPath, String ensemblIDList,String folderName,String ensemblID1,int RNADatasetID,int arrayTypeID) {
        log.debug("generate files");
        AsyncGeneDataTools prevThread=null;
        boolean completedSuccessfully = false;
        log.debug("outputDir:"+outputDir);
        File outDirF = new File(outputDir);
        //Mkdir if some are missing    
        if (!outDirF.exists()) {
            log.debug("make output dir");
            outDirF.mkdirs();
        }
        
        boolean createdXML=this.createImagesXMLFiles(outputDir,organism,ensemblIDList,arrayTypeID,ensemblID1,RNADatasetID);
        
        if(!createdXML){ 
            
        }else{       
            boolean ucscComplete=getUCSCUrls(outputDir,ensemblID1);
            if(!ucscComplete){
                   completedSuccessfully=false;
            }
            prevThread=callAsyncGeneDataTools(outputDir,chrom, minCoord, maxCoord,arrayTypeID,RNADatasetID);
            boolean createdExpressionfile=callPanelExpr(outputDir,chrom,minCoord,maxCoord,arrayTypeID,RNADatasetID,prevThread);
            if(!createdExpressionfile){
                   completedSuccessfully=false;
            }
        }
        return completedSuccessfully;
    }
    
     	public boolean createCircosFiles(String perlScriptDirectory, String perlEnvironmentVariables, String[] perlScriptArguments,String filePrefixWithPath){
   		// 
   	    boolean completedSuccessfully=false;
   	    String circosErrorMessage;
   		log.debug(" in GeneDataTools.createCircosFiles ");
   		// perlScriptArguments is an array of strings
   		// perlScriptArguments[0] is "perl" or maybe includes the path??
   		// perlScriptArguments[1] is the filename including directory of the perl script
   		// perlScriptArguments[2] ... are argument inputs to the perl script
   		for (int i=0; i<perlScriptArguments.length; i++){
   			log.debug(i + "::" + perlScriptArguments[i]);
   		}
   
        //set environment variables so you can access oracle. Environment variables are pulled from perlEnvironmentVariables which is a comma separated list
        String[] envVar=perlEnvironmentVariables.split(",");
    
        for (int i = 0; i < envVar.length; i++) {
            log.debug(i + " EnvVar::" + envVar[i]);
        }
        
       
        //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
        myExec_session = new ExecHandler(perlScriptDirectory, perlScriptArguments, envVar, filePrefixWithPath);

        try {

            myExec_session.runExec();

        } catch (ExecException e) {
            log.error("In Exception of createCircosFiles Exec_session", e);
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in Exec_session");
            circosErrorMessage = "There was an error while running ";
            circosErrorMessage = circosErrorMessage + " " + perlScriptArguments[1] + " (";
            for(int i=2; i<perlScriptArguments.length; i++){
            	circosErrorMessage = circosErrorMessage + " " + perlScriptArguments[i];
            }
            circosErrorMessage = circosErrorMessage + ")\n\n"+myExec_session.getErrors();
            myAdminEmail.setContent(circosErrorMessage);
            try {
                myAdminEmail.sendEmailToAdministrator();
            } catch (Exception mailException) {
                log.error("error sending message", mailException);
                throw new RuntimeException();
            }
        }
        
        if(myExec_session.getExitValue()!=0){
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in Exec_session");
            circosErrorMessage = "There was an error while running ";
            circosErrorMessage = circosErrorMessage + " " + perlScriptArguments[1] + " (";
            for(int i=2; i<perlScriptArguments.length; i++){
            	circosErrorMessage = circosErrorMessage + " " + perlScriptArguments[i];
            }
            circosErrorMessage = circosErrorMessage + ")\n\n"+myExec_session.getErrors();
            myAdminEmail.setContent(circosErrorMessage);
            try {
                myAdminEmail.sendEmailToAdministrator();
            } catch (Exception mailException) {
                log.error("error sending message", mailException);
                throw new RuntimeException();
            }
        }else{
            completedSuccessfully=true;
        }
        
   		return completedSuccessfully;
   	} 
    
    public boolean createImagesXMLFiles(String outputDir,String organism,String ensemblIDList,int arrayTypeID,String ensemblID1,int rnaDatasetID){
        boolean completedSuccessfully=false;
        try{
            int publicUserID=new User().getUser_id("public",dbConn);

            Properties myProperties = new Properties();
            File myPropertiesFile = new File(dbPropertiesFile);
            myProperties.load(new FileInputStream(myPropertiesFile));

            String dsn="dbi:"+myProperties.getProperty("PLATFORM") +":"+myProperties.getProperty("DATABASE");
            String dbUser=myProperties.getProperty("USER");
            String dbPassword=myProperties.getProperty("PASSWORD");

            File ensPropertiesFile = new File(ensemblDBPropertiesFile);
            Properties myENSProperties = new Properties();
            myENSProperties.load(new FileInputStream(ensPropertiesFile));
            String ensHost=myENSProperties.getProperty("HOST");
            String ensPort=myENSProperties.getProperty("PORT");
            String ensUser=myENSProperties.getProperty("USER");
            String ensPassword=myENSProperties.getProperty("PASSWORD");
            //construct perl Args
            String[] perlArgs = new String[19];
            perlArgs[0] = "perl";
            perlArgs[1] = perlDir + "writeXML_RNA.pl";
            perlArgs[2] = ucscDir+ucscGeneDir;
            perlArgs[3] = outputDir;
            perlArgs[4] = outputDir + "Gene.xml";

            if (organism.equals("Rn")) {
                perlArgs[5] = "Rat";
            } else if (organism.equals("Mm")) {
                perlArgs[5] = "Mouse";
            }
            perlArgs[6] = "Core";
            perlArgs[7] = ensemblIDList;
            perlArgs[8] = bedDir;
            perlArgs[9] = Integer.toString(arrayTypeID);
            perlArgs[10] = Integer.toString(rnaDatasetID);
            perlArgs[11] = Integer.toString(publicUserID);
            perlArgs[12] = dsn;
            perlArgs[13] = dbUser;
            perlArgs[14] = dbPassword;
            perlArgs[15] = ensHost;
            perlArgs[16] = ensPort;
            perlArgs[17] = ensUser;
            perlArgs[18] = ensPassword;


            //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
            String[] envVar=perlEnvVar.split(",");

            for (int i = 0; i < envVar.length; i++) {
                log.debug(i + " EnvVar::" + envVar[i]);
            }


            //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
            myExec_session = new ExecHandler(perlDir, perlArgs, envVar, fullPath + "tmpData/geneData/"+ensemblID1+"/");

            try {

                myExec_session.runExec();

            } catch (ExecException e) {
                log.error("In Exception of run writeXML_RNA.pl Exec_session", e);
                setError("Running Perl Script to get Gene and Transcript details/images.");
                Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in Exec_session");
                myAdminEmail.setContent("There was an error while running "
                        + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" , "+perlArgs[5]+" , "+perlArgs[6]+","+perlArgs[7]+","+perlArgs[8]+","+perlArgs[9]+","+perlArgs[10]+","+perlArgs[11]+
                        ")\n\n"+myExec_session.getErrors());
                try {
                    myAdminEmail.sendEmailToAdministrator();
                } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    throw new RuntimeException();
                }
            }

            if(myExec_session.getExitValue()!=0){
                Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in Exec_session");
                myAdminEmail.setContent("There was an error while running "
                        + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" , "+perlArgs[5]+" , "+perlArgs[6]+
                        ")\n\n"+myExec_session.getErrors());
                try {
                    myAdminEmail.sendEmailToAdministrator();
                } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    throw new RuntimeException();
                }
            }else{
                completedSuccessfully=true;
            }
        }catch(Exception e){
            log.error("Error getting DB properties or Public User ID.",e);
            String fullerrmsg=e.getMessage();
                    StackTraceElement[] tmpEx=e.getStackTrace();
                    for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                    }
            Email myAdminEmail = new Email();
                myAdminEmail.setSubject("Exception thrown in GeneDataTools.java");
                myAdminEmail.setContent("There was an error setting up to run writeXML_RNA.pl\n\nFull Stacktrace:\n"+fullerrmsg);
                try {
                    myAdminEmail.sendEmailToAdministrator();
                } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    throw new RuntimeException();
                }
        }
        return completedSuccessfully;
    }
    
    public AsyncGeneDataTools callAsyncGeneDataTools(String outputDir,String chr, int min, int max,int arrayTypeID,int rnaDS_ID){
        AsyncGeneDataTools agdt;         
        agdt = new AsyncGeneDataTools(session,outputDir,chr, min, max,arrayTypeID,rnaDS_ID,usageID);
        log.debug("Getting ready to start");
        agdt.start();
        log.debug("Started AsyncGeneDataTools");
        return agdt;
    }
    
    
    
    public boolean callPanelExpr(String outputDir,String chr, int min, int max,int arrayTypeID,int rnaDS_ID,AsyncGeneDataTools prevThread){
        boolean error=false;
        //create File with Probeset Tissue herit and DABG
        String datasetQuery="select rd.dataset_id, rd.tissue "+
                            "from rnadataset_dataset rd "+
                            "where rd.rna_dataset_id = "+rnaDS_ID+" "+
                            "order by rd.tissue";
        
        Date start=new Date();
        try{
            PreparedStatement ps = dbConn.prepareStatement(datasetQuery);
            ResultSet rs = ps.executeQuery();
            try{
                
                log.debug("Getting ready to start");
                File indivf=new File(outputDir+"Panel_Expr_indiv_tmp.txt");
                File groupf=new File(outputDir+"Panel_Expr_group_tmp.txt");
                BufferedWriter outGroup=new BufferedWriter(new FileWriter(groupf));
                BufferedWriter outIndiv=new BufferedWriter(new FileWriter(indivf));
                ArrayList<AsyncGeneDataExpr> localList=new ArrayList<AsyncGeneDataExpr>();
                SyncAndClose sac=new SyncAndClose(start,localList,dbConn,outGroup,outIndiv,usageID,outputDir);
                while(rs.next()){
                    AsyncGeneDataExpr agde=new AsyncGeneDataExpr(session,outputDir+"tmp_psList.txt",outputDir,prevThread,threadList,maxThreadRunning,outGroup,outIndiv,sac);
                    String dataset_id=Integer.toString(rs.getInt("DATASET_ID"));
                    int iDSID=rs.getInt("DATASET_ID");
                    String tissue=rs.getString("TISSUE");
                    String tissueNoSpaces=tissue.replaceAll(" ", "_");
                    edu.ucdenver.ccp.PhenoGen.data.Dataset sDataSet=new edu.ucdenver.ccp.PhenoGen.data.Dataset();
                    edu.ucdenver.ccp.PhenoGen.data.Dataset curDS=sDataSet.getDataset(iDSID,dbConn);
                    String DSPath=userFilesRoot+"public/Datasets/"+curDS.getNameNoSpaces()+"_Master/Affy.NormVer.h5";
                    String sampleFile=userFilesRoot+"public/Datasets/"+curDS.getNameNoSpaces()+"_Master/v3_samples.txt";
                    String groupFile=userFilesRoot+"public/Datasets/"+curDS.getNameNoSpaces()+"_Master/v3_groups.txt";
                    String outGroupFile="group_"+tissueNoSpaces+"_exprVal.txt";
                    String outIndivFile="indiv_"+tissueNoSpaces+"_exprVal.txt";
                    agde.add(DSPath,sampleFile,groupFile,outGroupFile,outIndivFile,tissue,curDS.getPlatform());
                    threadList.add(agde);
                    localList.add(agde);
                    agde.start();     
                }
                ps.close();
                
                log.debug("Started AsyncGeneDataExpr");
            }catch(IOException ioe){
                
            }
            
        }catch(SQLException e){
            error=true;
            log.error("Error getting dataset id",e);
            setError("SQL Error occurred while setting up Panel Expression");
        }
        return error;
    }
    
    
    
    private boolean getUCSCUrls(String outputDir,String ensemblID1){
        boolean error=false;
        String[] urls;
        try{
                urls=myFH.getFileContents(new File(outputDir + ensemblID1+".url"));
                this.geneSymbol=urls[0];
                session.setAttribute("geneSymbol", this.geneSymbol);
                this.ucscURL=urls[1];
                this.ucscURLfilter=urls[2];
                int start=urls[1].indexOf("position=")+9;
                int end=urls[1].indexOf("&",start);
                String position=urls[1].substring(start,end);
                String[] split=position.split(":");
                String chromosome=split[0].substring(3);
                String[] split2=split[1].split("-");
                this.minCoord=Integer.parseInt(split2[0]);
                this.maxCoord=Integer.parseInt(split2[1]);
                this.chrom=chromosome;
        }catch(IOException e){
                log.error("Error reading url file "+outputDir + ensemblID1,e);
                setError("Reading URL File");
                error=true;
        }
        return error;
    }
    
    private String loadErrorMessage(String outputDir){
        String ret="";
        try{
                File err=new File(outputDir +"errMsg.txt");
                if(err.exists()){
                    String[] tmp=myFH.getFileContents(new File(outputDir +"errMsg.txt"));
                    if(tmp!=null){
                        if(tmp.length>=1){
                            ret=tmp[0];
                        }
                        for(int i=1;i<tmp.length;i++){
                            ret=ret+"\n"+tmp;
                        }
                    }
                }
        }catch(IOException e){
                log.error("Error reading errMsg.txt file "+outputDir ,e);
                setError("Reading errMsg File");
        }
        return ret;
    }
    
    private void setError(String errorMessage){
        String tmp=(String)session.getAttribute("genURL");
        if(tmp==null||tmp.equals("")||!tmp.startsWith("ERROR:")){
            session.setAttribute("genURL","ERROR: "+errorMessage);
        }
    }
    
    private void setReturnSessionVar(boolean error,String outputDir,String ensemblID1){
        if(!error){
            session.setAttribute("genURL",urlPrefix + "tmpData/geneData/" + ensemblID1 + "/");
            session.setAttribute("ucscURL", this.ucscURL);
            session.setAttribute("ucscURLFiltered", this.ucscURLfilter);
        }else{
            String tmp=(String)session.getAttribute("genURL");
            if(tmp.equals("")||!tmp.startsWith("ERROR:")){
                session.setAttribute("genURL","ERROR:Unknown Error");
            }
            session.setAttribute("ucscURL", "");
            session.setAttribute("ucscURLFiltered", "");
            try{
                new FileHandler().writeFile((String)session.getAttribute("genURL"),outputDir+"errMsg.txt");
            }catch(IOException e){
                log.error("Error writing errMsg.txt",e);
            }
        }
    }
    public HttpSession getSession() {
        return session;
    }

    public String formatDate(GregorianCalendar gc) {
        String ret;
        String year = Integer.toString(gc.get(GregorianCalendar.YEAR));
        String month = Integer.toString(gc.get(GregorianCalendar.MONTH) + 1);
        if (month.length() == 1) {
            month = "0" + month;
        }
        String day = Integer.toString(gc.get(GregorianCalendar.DAY_OF_MONTH));
        if (day.length() == 1) {
            day = "0" + day;
        }
        String hour = Integer.toString(gc.get(GregorianCalendar.HOUR_OF_DAY));
        if (hour.length() == 1) {
            hour = "0" + hour;
        }
        String minute = Integer.toString(gc.get(GregorianCalendar.MINUTE));
        if (minute.length() == 1) {
            minute = "0" + minute;
        }
        ret = year + month + day + hour + minute;
        return ret;
    }
    
    public void setSession(HttpSession inSession) {
        log.debug("in GeneDataTools.setSession");
        this.session = inSession;
        
        log.debug("start");
        this.dbConn = (Connection) session.getAttribute("dbConn");
        log.debug("db");
        this.perlDir = (String) session.getAttribute("perlDir") + "scripts/";
        log.debug("perl"+perlDir);
        String contextRoot = (String) session.getAttribute("contextRoot");
        log.debug("context"+contextRoot);
        String appRoot = (String) session.getAttribute("applicationRoot");
        log.debug("app"+appRoot);
        this.fullPath = appRoot + contextRoot;
        log.debug("fullpath");
        this.rFunctDir = (String) session.getAttribute("rFunctionDir");
        log.debug("rFunction");
        this.userFilesRoot = (String) session.getAttribute("userFilesRoot");
        log.debug("userFilesRoot");
        this.urlPrefix=(String)session.getAttribute("mainURL");
        if(urlPrefix.endsWith(".jsp")){
            urlPrefix=urlPrefix.substring(0,urlPrefix.lastIndexOf("/")+1);
        }
        log.debug("mainURL");
        this.perlEnvVar=(String)session.getAttribute("perlEnvVar");
        log.debug("PerlEnv");
        this.ucscDir=(String)session.getAttribute("ucscDir");
        this.ucscGeneDir=(String)session.getAttribute("ucscGeneDir");
        log.debug("ucsc");
        this.bedDir=(String) session.getAttribute("bedDir");
        log.debug("bedDir");
        
        this.dbPropertiesFile = (String)session.getAttribute("dbPropertiesFile");
        this.ensemblDBPropertiesFile = (String)session.getAttribute("ensDbPropertiesFile");
        
    }
}
