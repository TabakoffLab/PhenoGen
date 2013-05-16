package edu.ucdenver.ccp.util;

import java.io.IOException;

import javax.mail.MessagingException;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.util.HDF5.PhenoGen_HDF5_File;
/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;
import au.com.forward.threads.ThreadInterruptedException;
import au.com.forward.threads.ThreadException;

import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.DateTimeFormatter;
/* for logging messages */
import java.io.*;
import java.sql.*;

import org.apache.log4j.Logger;

import ncsa.hdf.object.*;     // the common object package
import ncsa.hdf.object.h5.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;

import javax.servlet.http.HttpSession;


public class Async_HDF5_FileHandler implements Runnable{

    private Logger log = null;
    private Thread waitThread = null;
    private String source = "";
    private String outputDir = "";
    private String h5file="";
    private String arrayType = "";
    private int[] grouping;
    private int groupingID;
    private ArrayList<ArrayList<Integer>> sampleGroups;
    private String[] groupNumbers;
    private String function;
    private String version;
    private String method;
    private String curDate;
    private String curTime;
    private String phenoDataPath=null;
    private edu.ucdenver.ccp.PhenoGen.data.Dataset pds;
    private int userID;
    private Connection conn;
    private String sampleArrayFile="",groupArrayFile="";
    private FileHandler myFileHandler = new FileHandler();
    private HttpSession session;
    private int numProbes=-1;

    public Async_HDF5_FileHandler(edu.ucdenver.ccp.PhenoGen.data.Dataset pds,String version,String outputDir,String H5File, String function, Thread waitThread,HttpSession session) {
        this.pds=pds;
        this.version=version;
        log = Logger.getRootLogger();
        this.waitThread = waitThread;
        this.outputDir = outputDir;
        this.h5file=H5File;
        this.function=function;
        this.session=session;
        //NEEDED ON COMPBIO AND PHENOGEN UNCOMMENT
        //String applicationPath=((String)session.getAttribute("applicationRoot"))+((String)session.getAttribute("contextRoot"))+"/WEB-INF/lib/linux";
        //log.debug("LIB path:"+applicationPath);
        //java.lang.System.setProperty("ncsa.hdf.hdf5lib.H5.hdf5lib",applicationPath);
        
    }
     
    public void setCreateVersionParameters(ArrayList<ArrayList<Integer>> sampleGroups,String[] groupNumbers, int[] grouping,int groupingID, String arrayType, String source, String method){
        this.source = source;
        this.arrayType = arrayType;
        this.grouping=grouping;
        this.groupingID=groupingID;
        this.sampleGroups=sampleGroups;
        this.groupNumbers=groupNumbers;
        this.method=method;
        String tmppart=outputDir.substring(outputDir.indexOf("/Datasets/")+10,outputDir.indexOf("_Master"));
        this.groupArrayFile=outputDir+tmppart+".arrayFiles.txt";
        this.sampleArrayFile=outputDir+version+"_samples.txt";
        System.out.println("Group:Sample:"+this.groupArrayFile+":"+this.sampleArrayFile);
    }
    
    public void setFillHDFFilterParameters(int userID,Connection conn,String phenoDataPath){
        this.userID=userID;
        this.conn=conn;
        this.phenoDataPath=phenoDataPath;
    }
    
    public void setDeleteFilterStats(String curDate,String curTime,Connection conn){
        this.curDate=curDate;
        this.curTime=curTime;
        this.conn=conn;
    }
    
    public int getNumberOfProbes(){
        return numProbes;
    }

    public void run() throws RuntimeException {
        Thread thisThread = Thread.currentThread();
        log.debug("Starting run method of Async_HDF5_FileHandler. , thisThread = " + thisThread.getName());
        String[] rErrorMsg = null;       
        try {
            //
            // If this thread is interrupted, throw an Exception
            //
            ThreadReturn.ifInterruptedStop();

            // 
            // If waitThread threw an exception, then ThreadReturn will
            // detect it and throw the same exception 
            // Otherwise, the join will happen, and will continue to the 
            // next statement.
            //
            if (waitThread != null) {
                //while (waitThread.isAlive()) {
                log.debug("in Async_HDF5_FileHandler waiting on thread " + waitThread.getName());
                ThreadReturn.join(waitThread);
                log.debug("just finished waiting on thread " + waitThread.getName());
            } else {
                log.debug("waitThread is null");
            }
            log.debug("after waiting on thread");
            log.debug("Function="+function);
            if(function.equals("createNormVersfromAPTFiles")){
                this.createVersionFromAPTFiles();
            }else if(function.equals("fillHDF5Filter")){
                this.fillFilterData();
            }else if(function.equals("fillFilterProbes")){
                this.fillFilterProbes();
            }else if(function.equals("deleteFilterStats")){
                this.deleteFilterStats();
            }else if(function.equals("deleteVersion")){
                this.deleteVersion();
            }else{
                log.debug("UNSUPPORTED HDF5 FILE FUNCTION:"+function);
            }
            
            //
            // If this thread is interrupted, throw an Exception
            //
            ThreadReturn.ifInterruptedStop();

        } catch (Throwable t) {
            //log.error("In exception of Async_HDF5_FileHandler for thread " + thisThread.getName(), t);
            
            if (t instanceof ThreadException) {
                //log.error("throwable exception is a ThreadException. cause = " + t.getCause().getMessage(),t);
                //
                // This saves the Throwable object so an Exception can be detected
                // by the calling program
                //
                ThreadReturn.save(t);
            } else if (t instanceof ThreadInterruptedException) {
                //log.error("throwable exception is a ThreadInterruptedException",t);
                //ThreadReturn.save(t);
                ThreadReturn.save(new Throwable("ThreadInterruptedException in Async_HDF5_FileHandler", t));
            } else {
                //log.error("exception caused in Async_HDF5_FileHandler",t);
                ThreadReturn.save(t);
                //ThreadReturn.save(new Throwable("Error in R process while running " + functionName + "\n" + rError, t));
            }

            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in Async_HDF5_FileHandler.");
            myAdminEmail.setContent("Cause = " + (t.getCause() != null ? t.getCause().getMessage() : t.getMessage())
                    + "\n Message = " + t.getMessage()
                    + "\n Thread name is " + thisThread.getName());
            try {
                //log.debug("sending message to notify administrator of problem");
                myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
            } catch (MessagingException e) {
                //log.error("error sending message to administrator",e);
                throw new RuntimeException();
                //ThreadReturn.save(new Throwable("Error sending message to administrator", e));
            }

        }
        //log.debug("done with Async_HDF5_FileHandler run method for this thread: " + thisThread.getName());

    }
    
    private void createVersionFromAPTFiles(){
        HashMap hm=readGroupsFile();
        //create file
        PhenoGen_HDF5_File file = null;
        try {
            //open file
            file = new PhenoGen_HDF5_File(outputDir + h5file);
            
            //check version
            if (file.versionExists(version)) {//problem?
                //need to figure out what to do
            } else {
                file.createVersion(version);
                log.debug("Version created");
                file.writeGrouping(grouping);
                //file.writeGroups(sampleGroups, groupNumbers, groupingID);
                //setup columns to skip
                ArrayList<Integer> skipCol = new ArrayList<Integer>();
                ArrayList<String> sampleNames=new ArrayList<String>();
                
                //read AVG DATA
                log.debug("Reading Avg Data");
                int[] sizes = readAvgData(file, version, skipCol,hm,sampleNames);
                log.debug("SampleName Size:"+sampleNames.size());
                writeSampleNames(sampleNames);
                log.debug("Done Reading AVG/nStarting DABG");
                int probeSize = sizes[0];
                int sampleSize = sizes[1];
 
                //read DABG DATA
                readDABG(file, version, skipCol, grouping, probeSize, sampleSize);
                log.debug("Done Reading DABG");
            }
            //close file
            file.close();
        } catch (Exception e) {
            try {
                file.close();
            } catch (Exception er) {
            }
            log.error("Error creating HDF5 file", e);
        }
    }
    
    private void fillFilterProbes() {
        log.debug("in fillFilterProbes");
        User tmpU = new User();
        User userLoggedIn = (User) session.getAttribute("userLoggedIn");
        String userFilesRoot = (String) session.getAttribute("userFilesRoot");
        curDate = (String) session.getAttribute("verFilterDate");
        curTime = (String) session.getAttribute("verFilterTime");
        log.debug("Creating Filtered Data at /" + version + "/" + curDate + "/" + curTime);
        int v = Integer.parseInt(version.substring(1));
        String h5path="";
        PhenoGen_HDF5_File file = null;
        boolean error=false;
        //if (pds.getCreator().equals("public")&&phenoDataPath==null) {//need to create a copy in user directory
        if (pds.getCreator().equals("public")) {
            String publicH5Path = userFilesRoot + "public/Datasets/" + pds.getNameNoSpaces() + "_Master/Affy.NormVer.h5";
            String userCurDir = userFilesRoot + userLoggedIn.getUser_name() + "/Datasets/" + pds.getNameNoSpaces() + "/";
            String userH5Path = userCurDir + "Affy.NormVer.h5";
            
            //FileHandler myFileHandler = new FileHandler();
            myFileHandler.createDir(userCurDir);
            log.debug("in Public Filter Fill\n" + publicH5Path + "\n" + userH5Path + "\n");
            try {
                Date start=new Date();
                h5path=userH5Path;
                file = new PhenoGen_HDF5_File(userH5Path);
                //copy DABG, Samples, etc.
                if (!file.versionExists(version)) {
                    PhenoGen_HDF5_File publich5 = new PhenoGen_HDF5_File(publicH5Path);
                    if (publich5.isOpen() && publich5.versionExists(version)) {
                        publich5.openVersion(version);
                        publich5.copyVerTo(version, file);
                    }
                    publich5.close();
                    String groupPath=userFilesRoot + "public/Datasets/" + pds.getNameNoSpaces() + "_Master/"+version+"_groups.txt";
                    String sampPath=userFilesRoot + "public/Datasets/" + pds.getNameNoSpaces() + "_Master/"+version+"_samples.txt";
                    String destGroupPath=userCurDir+version+"_groups.txt";
                    String destSampPath=userCurDir+version+"_samples.txt";
                    File in=new File(groupPath);
                    File out=new File(destGroupPath);
                    myFileHandler.copyFile(in,out);
                    in=new File(sampPath);
                    out=new File(destSampPath);
                    myFileHandler.copyFile(in,out);
                            
                }
                file.clearMemory(version);
                Date end=new Date();
                long ms=(end.getTime()-start.getTime())/1000;
                log.debug("public dataset copy timing: "+ms+" sec");
            } catch (Exception e) {
                error=true;
                try {
                    file.close();
                } catch (Exception er) {
                    log.error("Error creating Public dataset HDF5 File", er);
                }
                log.error("Error creating Public dataset HDF5 File", e);
            }

        } else {
            //if(phenoDataPath==null){
            try {
                h5path=outputDir+h5file;
                file = new PhenoGen_HDF5_File(outputDir + h5file);
            }catch (Exception e) {
                error=true;
                try {
                    file.close();
                } catch (Exception er) {
                    log.error("Error creating dataset HDF5 File", er);
                }
                log.error("Error creating dataset HDF5 File", e);
            }
            /*}else{
                try {
                    h5path=phenoDataPath+h5file;
                    file = new PhenoGen_HDF5_File(phenoDataPath+h5file);
                }catch (Exception e) {
                    error=true;
                    try {
                        file.close();
                    } catch (Exception er) {
                        log.error("Error creating dataset HDF5 File", er);
                    }
                    log.error("Error creating dataset HDF5 File", e);
                }
            }*/
        }
        if(!error){
            try {
                //check version
                if (file.isOpen() && file.versionExists(version)) {
                    Date start=new Date();
                    file.openVersion(version);
                    file.deleteFilterStatProbesets(version,curDate,curTime);
                    file.close();
                    file=new PhenoGen_HDF5_File(h5path);
                    file.openVersion(version);
                    System.out.println("Open version");
                    //get included probesets from DB
                    String query = "Select probeset_id from exon_user_filter_temp where dataset_id=? and dataset_version=? and user_id=? and cumulative_filter=1 order by probeset_id";
                    PreparedStatement ps = conn.prepareStatement(query);
                    ps.setInt(1, pds.getDataset_id());
                    ps.setInt(2, v);
                    //User userLoggedIn=(User)session.getAttribute("userLoggedIn");
                    ps.setInt(3, userLoggedIn.getUser_id());
                    ResultSet rs = ps.executeQuery();
                    ArrayList<Integer> list = new ArrayList<Integer>();
                    while (rs.next()) {
                        list.add(rs.getInt("probeset_id"));
                    }
                    //convert to probeset list to long[]
                    long[] probelist = new long[list.size()];
                    for (int i = 0; i < list.size(); i++) {
                        probelist[i] = list.get(i).longValue();
                    }
                    System.out.println("Write probeset list to file.  legnth="+probelist.length);
                    //write Filter
                    this.numProbes = probelist.length;
                    file.writeFilteredProbeList(probelist, curDate, curTime);

                    Date end=new Date();
                    long ms=(end.getTime()-start.getTime())/1000;
                    log.debug("dataset filter timing: "+ms+" sec");
                    log.debug("Done Creating Filtered Data");
                } else {
                    log.debug("ERROR:Not Opened ver=" + version);
                }
                //close file
                file.close();
            } catch (Exception e) {
                e.printStackTrace(System.out);
                try {
                    file.close();
                } catch (Exception er) {
                }
                log.error("Error creating HDF5 file", e);
            }
            
        }else{
            try{
                file.close();
            }catch(Exception e){
                log.error("Error closing HDF5 file after an error.",e);
            }
            log.debug("Error opening or copying HDF5 file to create probesets.");
        }
    }
    
    private void fillFilterData() {
        log.debug("in fillHDF5Filter");
        User tmpU = new User();
        User userLoggedIn = (User) session.getAttribute("userLoggedIn");
        String userFilesRoot = (String) session.getAttribute("userFilesRoot");
        curDate = (String) session.getAttribute("verFilterDate");
        curTime = (String) session.getAttribute("verFilterTime");
        log.debug("Creating Filtered Data at /" + version + "/" + curDate + "/" + curTime);
        int v = Integer.parseInt(version.substring(1));
        PhenoGen_HDF5_File file = null;
        boolean error=false;
        //if (pds.getCreator().equals("public")&&phenoDataPath==null) {//need to create a copy in user directory
        if (pds.getCreator().equals("public")) {
            String publicH5Path = userFilesRoot + "public/Datasets/" + pds.getNameNoSpaces() + "_Master/Affy.NormVer.h5";
            String userCurDir = userFilesRoot + userLoggedIn.getUser_name() + "/Datasets/" + pds.getNameNoSpaces() + "/";
            String userH5Path = userCurDir + "Affy.NormVer.h5";
            try {
                file = new PhenoGen_HDF5_File(userH5Path);
            } catch (Exception e) {
                error=true;
                try {
                    file.close();
                } catch (Exception er) {
                    log.error("Error creating Public dataset HDF5 File", er);
                }
                log.error("Error creating Public dataset HDF5 File", e);
            }

        } else {
            //if(phenoDataPath==null){
                try {
                    file = new PhenoGen_HDF5_File(outputDir + h5file);
                }catch (Exception e) {
                    error=true;
                    try {
                        file.close();
                    } catch (Exception er) {
                        log.error("Error creating dataset HDF5 File", er);
                    }
                    log.error("Error creating dataset HDF5 File", e);
                }
            /*}else{
                try {
                    file = new PhenoGen_HDF5_File(phenoDataPath+h5file);
                }catch (Exception e) {
                    error=true;
                    try {
                        file.close();
                    } catch (Exception er) {
                        log.error("Error creating dataset HDF5 File", er);
                    }
                    log.error("Error creating dataset HDF5 File", e);
                }
            }*/
        }
        if(!error){
            boolean success=false;
            try {
                //check version
                if (file.isOpen() && file.versionExists(version)) {
                    Date start=new Date();
                    file.openVersion(version);
                    file.deleteFilterData(version,curDate,curTime);
                    System.out.println("Open version");
                    long[] probelist=new long[0];
                    if(file.filterProbesetExists(version,curDate,curTime)){
                        probelist = file.readFilteredProbeset(curDate,curTime);
                    }else{
                        probelist=file.readMainProbeset(version);
                        file.writeFilteredProbeList(probelist,curDate,curTime);
                    }
                    //write Filter Data
                    file.writeFilteredData(probelist, curDate, curTime);
                    Date end=new Date();
                    long ms=(end.getTime()-start.getTime())/1000;
                    log.debug("dataset filter timing: "+ms+" sec");
                    log.debug("Done Creating Filtered Data");
                } else {
                    log.debug("ERROR:Not Opened ver=" + version);
                }
                //close file
                file.close();
                success=true;
            } catch (Exception e) {
                e.printStackTrace(System.out);
                try {
                    file.close();
                } catch (Exception er) {
                }
                log.error("Error creating HDF5 file", e);
            }
            if(success){
                String resetQ = "{call filter.reset(" + pds.getDataset_id() + "," + v + "," + userID + ",?)}";
                try {
                    CallableStatement cs = conn.prepareCall(resetQ);
                    cs.setInt(1, 3);
                    cs.executeUpdate();
                    cs.close();
                    conn.commit();
                } catch (SQLException e) {
                    log.error("Error removing temporary filter", e);
                }
            }
        }
    }
    
    private void deleteFilterStats(){
        log.debug("in deleteFilterStats");
        File test=new File(outputDir + h5file);
        if(test.exists()){
            PhenoGen_HDF5_File file = null;
            try {
                //open file
                file = new PhenoGen_HDF5_File(outputDir + h5file);
                //check version
                if (file.isOpen()&&file.versionExists(version)) {
                    file.openVersion(version);
                    System.out.println("Open version");
                    file.deleteFilterStat(version,curDate,curTime);
                    log.debug("Done Creating Filtered Data");
                }else{
                    log.debug("ERROR:Not Opened ver="+version);
                }
                //close file
                file.close();
            } catch (Exception e) {
                try {
                    file.close();
                } catch (Exception er) {
                }
                log.error("Error creating HDF5 file", e);
            }
        }
    }
    
    private void deleteVersion(){
        log.debug("in deleteVersion");
        File testh5=new File(outputDir + h5file);
        log.debug("test file created:"+outputDir+h5file);
        try{
            if(testh5.exists()){
                log.debug("test file exists");
                PhenoGen_HDF5_File file = null;
                try {
                    //open file
                    file = new PhenoGen_HDF5_File(outputDir + h5file);
                    //check version
                    if (file.isOpen()&&file.versionExists(version)) {
                        log.debug("File is Open. Version exists.");
                        file.deleteVersion(version);
                        log.debug("Deleted Version:"+version);
                    }else{
                        log.debug("ERROR:Does Not exist ver="+version);
                    }
                    //close file
                    file.close();
                    log.debug("Version Deleted");
                } catch (Exception er) {
                    try {
                        file.close();
                    } catch (Exception e) {
                        e.printStackTrace(System.err);
                    }
                    log.error("Error creating HDF5 file", er);
                    er.printStackTrace(System.err);
                }
            }else{
                log.debug("H5File doesn't exist");
            }
        }catch(Exception e){
            e.printStackTrace(System.err);
        }
    }
    
    private HashMap readGroupsFile(){
        HashMap ret=new HashMap();
        try{
            System.out.println("read:"+this.groupArrayFile);
            File f=new File(this.groupArrayFile);
            DataInputStream in=new DataInputStream(new FileInputStream(f));
            byte[] tmp=new byte[1024];
            int read = in.read(tmp);
            StringBuilder sb=new StringBuilder();
            while (read == 1024) {
                sb.append(new String(tmp, 0, read));
                read = in.read(tmp);
            }
            if(read>0){
                sb.append(new String(tmp, 0, read));
            }
            System.out.println("file contents:"+sb.toString());
            String[] lines=sb.toString().split("\n");
            System.out.println("lines:"+lines.length);
            for(int i=1;i<lines.length;i++){
                String[] col=lines[i].split("\t");
                if(col.length>1){
                    String filepart=col[0].substring(col[0].lastIndexOf("/")+1);
                    ret.put(filepart, col[1]);
                    System.out.println("put:("+filepart+","+col[1]);
                }
                
            }
        }catch(IOException er){
            log.error("Error reading Array file list file:"+this.sampleArrayFile+"\n",er);
        }
        return ret;
    }
    
    private void writeSampleNames(ArrayList<String> sampleNames) {
        log.debug("writeSampleNames()=");
        String SampleData="";
        for(int i=0;i<sampleNames.size();i++){
            SampleData=SampleData+"\n"+sampleNames.get(i);
        }
        log.debug(SampleData);
        try {
            myFileHandler.writeFile(SampleData, this.sampleArrayFile);
        } catch (Exception e) {
            log.debug("error creating groupsFile in doNormalization");
        }
    }

    private boolean isExcluded(int ind, ArrayList<Integer> skip) {
        boolean isEx = false;
        for (int i = 0; i < skip.size() && !isEx; i++) {
            if (ind == skip.get(i).intValue()) {
                isEx = true;
            }
        }
        return isEx;
    }

    private boolean readFromFile(ArrayList<String> list, StringBuffer sb, DataInputStream in, String ignore) {
        boolean eof = false;
        byte[] tmp = new byte[1024];
        sb.ensureCapacity(1024*64);
        try {
            int read = in.read(tmp);
            int count = 1;
            while (read == 1024 && count < 64) {
                sb.append(new String(tmp, 0, read));
                read = in.read(tmp);
                count++;
            }
            sb.append(new String(tmp, 0, read));
            if (read < 1024) {
                eof = true;
            }
        } catch (IOException ex) {
            
        }

        if (sb.length() > 0) {
            int indEOL = sb.indexOf("\n");
            while (indEOL > -1) {
                String line = sb.substring(0, indEOL);
                if (line.startsWith(ignore)) {
                } else {
                    list.add(line);
                }
                sb.delete(0, indEOL + 1);
                indEOL = sb.indexOf("\n");
            }

            if (eof) {
                String line = sb.toString();
                list.add(line);
            }

        }

        return eof;
    }
    
    private int[] readAvgData(PhenoGen_HDF5_File h5File,String ver,ArrayList<Integer> skipCol,HashMap hm,ArrayList<String> sampleNames) {
        int[] ret=new int[2];
        int v=Integer.parseInt(version.substring(1));
        ret[0]=0;
        ret[1]=0;
        //ArrayList<Double[]> data = new ArrayList<Double[]>();
        ArrayList<String> lines = new ArrayList<String>();
        
        
        boolean first = true;
        try {
            String file=outputDir+ver;
            String tmpOracleDir=outputDir+"oracle/";
            myFileHandler.createDir(tmpOracleDir);
            char endChar='a';
            String oracleFileSufix=".a";
            //String dabgFilePrefix="dabgdata_"+pds.getDataset_id()+"_"+v+oracleFileSufix;
            String avgFilePrefix=tmpOracleDir+"normdata_"+pds.getDataset_id()+"_"+v+oracleFileSufix;
            if(method.equals("rma-sketch")){
                file=file+"/rma-sketch.summary.txt";
            }else{
                file=file+"/plier-gcbg-sketch.summary.txt";
            }
            File singleFile=new File(file);
            ArrayList<File> fileList=new ArrayList<File>();
            if(singleFile.exists()){
                System.out.println("Single File");
                fileList.add(singleFile);
            }else{
                file=outputDir+ver;
                System.out.println("Multiple Files");
                int count=0;
                boolean lastFile=false;
                while(!lastFile){
                    String curfstr="";
                    if(method.equals("rma-sketch")){
                        curfstr=file+"/rma-sketch.summary."+count+".txt";
                    }else{
                        curfstr=file+"/plier-gcbg-sketch.summary."+count+".txt";
                    }
                    System.out.println("TEST:"+curfstr);
                    File testFile=new File(curfstr);
                    if(testFile.exists()){
                        System.out.println("Exists");
                        fileList.add(testFile);
                        count++;
                    }else{
                        lastFile=true;
                    }
                }
                
            }
            int finalProbeSize=0;
            int finalSampleSize=0;
            int probeSize=0;
            int sampleSize=0;
            int currentRow=0;
            int writeAfter=50000;
            long[] probeset = new long[writeAfter];
            double[][] data = new double[writeAfter][sampleSize];
            int clearMem=0;
            int clearMemAt=8;
            while (!fileList.isEmpty()) {
                
                boolean EOF = false;
                File curFile=fileList.get(0);
                fileList.remove(0);
                System.out.println("Process:"+curFile.getAbsolutePath());
                DataInputStream in = new DataInputStream(new FileInputStream(curFile));
                DataOutputStream out= new DataOutputStream(new FileOutputStream(avgFilePrefix+endChar));
                endChar++;
                StringBuffer sb = new StringBuffer();
                boolean firstFile=true;
                while (!EOF) {
                    EOF = readFromFile(lines, sb, in, "#");
                    while (!lines.isEmpty()) {
                        String line = lines.get(0);
                        lines.remove(0);
                        String[] col = line.split("\t");
                        //System.out.println(line+"\n col:"+col.length);
                        if (!first&&!firstFile) {
                            if (col.length > sampleSize) {
                                out.writeBytes(line+"\n");
                                probeset[currentRow]=Integer.parseInt(col[0]);
                                int curCol = 0;
                                for (int i = 1; i < col.length; i++) {
                                    if (!isExcluded(i, skipCol)) {
                                        data[currentRow][curCol] = Double.parseDouble(col[i]);
                                        curCol++;
                                    }
                                }
                                currentRow++;
                            }
                        } else if(firstFile&&!first){
                            firstFile=false;
                        }else {
                            //count samples and remove any
                            ArrayList<String> samples = new ArrayList<String>();
                            String header="probeset_id\n";
                            //ArrayList<String> allsamples = new ArrayList<String>();
                            for (int i = 1; i < col.length; i++) {
                                if (grouping[i - 1] == 0) {
                                    skipCol.add(i);
                                } else {
                                    String filepart=col[i].substring(col[i].lastIndexOf("/")+1);
                                    //System.out.println("filepart:"+filepart+"::");
                                    String sampName=(String)hm.get(filepart);
                                    //System.out.println("sampName:"+sampName+"::");
                                    samples.add(sampName);
                                    sampleNames.add(sampName);
                                    header=header+filepart+"\n";
                                }
                                //allsamples.add(col[i]);
                            }
                            sampleSize = samples.size();
                            data=new double[writeAfter][sampleSize];
                            finalSampleSize=samples.size();
                            /*
                             * if (newFile) { String[] sallsamples = (String[])
                             * allsamples.toArray(new String[0]);
                             * h5File.writeSampleList("All", sallsamples); }
                             */
                            String[] tmp = (String[]) samples.toArray(new String[0]);
                            
                            h5File.writeSampleList(tmp);
                            first = false;
                            firstFile=false;
                            myFileHandler.writeFile(header,tmpOracleDir+"normheader_"+pds.getDataset_id()+"_"+v+".txt");
                        }
                        if(currentRow==writeAfter){
                            int prevProbeSize=finalProbeSize;
                            probeSize = currentRow;
                            finalProbeSize=finalProbeSize+probeSize;
                            System.out.println("probe size:" + probeSize+"\nFinal Probe size:"+finalProbeSize);
                            h5File.writeProbeListPart(probeset, prevProbeSize, probeSize,h5File.DATASET_MAIN_PROBESET);
                            h5File.writeAvgDataPart(data,prevProbeSize,probeSize,h5File.DATASET_MAIN_DATA);
                            currentRow=0;
                            probeset = new long[writeAfter];
                            data = new double[writeAfter][sampleSize];
                            if(clearMemAt==clearMem){
                                h5File.clearMemory(ver);
                                clearMem=0;
                            }
                            clearMem++;
                        }
                    }
                }
                in.close();
                out.close();
            }
            int prevProbeSize = finalProbeSize;
            probeSize = currentRow;
            finalProbeSize = finalProbeSize + probeSize;
            System.out.println("probe size:" + probeSize + "\nFinal Probe size:" + finalProbeSize);
            h5File.writeProbeListPart(probeset, prevProbeSize, probeSize,h5File.DATASET_MAIN_PROBESET);
            h5File.writeAvgDataPart(data, prevProbeSize, probeSize,h5File.DATASET_MAIN_DATA);
            currentRow = 0;
            probeset = new long[writeAfter];
            data = new double[writeAfter][sampleSize];
            //h5File.writeDefaultFilter(finalProbeSize);
            System.gc();
            
            ret[0]=finalProbeSize;
            ret[1]=finalSampleSize;
        } catch (Exception e) {
            //e.printStackTrace(System.err);
            log.error("Error reading normalized data summary file:",e);
        }
        return ret;
    }
    
    private void readDABG(PhenoGen_HDF5_File h5File,String ver,ArrayList<Integer> skipCol,int[] grouping,int probeSize,int sampleSize){
        //read dabg     
            int v=Integer.parseInt(version.substring(1));
            ArrayList<String> lines = new ArrayList<String>();
            boolean first = true;
            try{
                
                String file=outputDir+ver+"/dabg.summary.txt";
                String tmpOracleDir=outputDir+"oracle/";
                String oracleFileSufix=".a";
                char endChar='a';
                String dabgFilePrefix=tmpOracleDir+"dabgdata_"+pds.getDataset_id()+"_"+v+oracleFileSufix;
                File singleFile=new File(file);
                ArrayList<File> fileList=new ArrayList<File>();
                if(singleFile.exists()){
                    fileList.add(singleFile);
                }else{
                    int count=0;
                    boolean lastFile=false;
                    while(!lastFile){
                        String curfstr = "";
                     
                        curfstr = outputDir+ver+"/dabg.summary."+count+".txt";
                        File testFile = new File(curfstr);
                        if (testFile.exists()) {
                            fileList.add(testFile);
                            count++;
                        } else {
                            lastFile = true;
                        }
                    }

                }
                int currentRow=0;
                int writeAfter=50000;
                int totalRow=0;
                double[][] data = new double[writeAfter][sampleSize];
                double[] percDABG=new double[writeAfter];
                int clearMem=0;
                int clearMemAt=8;
                while (!fileList.isEmpty()) {
                    boolean EOF = false;
                    File curFile = fileList.get(0);
                    fileList.remove(0);
                    DataInputStream in = new DataInputStream(new FileInputStream(curFile));
                    DataOutputStream out= new DataOutputStream(new FileOutputStream(dabgFilePrefix+endChar));
                    endChar++;
                    StringBuffer sb = new StringBuffer();
                    boolean firstFile=true;
                    while (!EOF) {
                        EOF = readFromFile(lines, sb, in, "#");
                        while (!lines.isEmpty()) {
                            String line = lines.get(0);
                            lines.remove(0);
                            String[] col = line.split("\t");
                            if (firstFile) {
                                first = false;
                                firstFile=false;
                                //count samples and remove any
                                String header="probeset_id\n";
                                for (int i = 1; i < col.length; i++) {
                                    if (grouping[i - 1] == 0) {
                                    } else {
                                        String filepart=col[i].substring(col[i].lastIndexOf("/")+1);
                                        header=header+filepart+"\n";
                                    }
                                }
                                myFileHandler.writeFile(header,tmpOracleDir+"dabgheader_"+pds.getDataset_id()+"_"+v+".txt");
                            }else if(first){
                                firstFile=false;
                            }else {
                                if (col.length > sampleSize) {
                                    out.writeBytes(line+"\n");
                                    double present = 0;
                                    int curCol=0;
                                    for (int i = 1; i < col.length; i++) {
                                        if (!isExcluded(i, skipCol)) {
                                            data[currentRow][curCol] = Double.parseDouble(col[i]);
                                            
                                            if (data[currentRow][curCol] < 0.0001) {
                                                present = present + 1.0;
                                            }
                                            curCol++;
                                        }
                                    }
                                    percDABG[currentRow] = present / sampleSize * 100.0;
                                    currentRow++;
                                }
                            }
                            if(currentRow==writeAfter){
                                //System.out.println("writing DABG TOTAL:"+totalRow);
                                h5File.writeDABGPvalPart(data,totalRow,currentRow);
                                h5File.writeDABGPercPart(percDABG,totalRow,currentRow);
                                totalRow=totalRow+currentRow;
                                data = new double[writeAfter][sampleSize];
                                percDABG=new double[writeAfter];
                                currentRow=0;
                                if(clearMemAt==clearMem){
                                    h5File.clearMemory(ver);
                                    clearMem=0;
                                }
                                clearMem++;
                            }
                        }
                        
                    }
                    in.close();
                    out.close();
                }
                h5File.writeDABGPvalPart(data,totalRow,currentRow);
                h5File.writeDABGPercPart(percDABG,totalRow,currentRow);
        } catch (Exception e) {
            log.error("Error reading DABG file:",e);
            //e.printStackTrace(System.err);
        }
    }
    
    
}
