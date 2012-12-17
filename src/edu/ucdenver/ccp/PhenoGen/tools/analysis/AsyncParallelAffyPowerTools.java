package edu.ucdenver.ccp.PhenoGen.tools.analysis;

import  edu.ucdenver.ccp.PhenoGen.tools.analysis.AsyncParallelAffyPowerToolsWorker;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.mail.MessagingException;
import javax.mail.SendFailedException;

import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.Dataset.DatasetVersion;
import edu.ucdenver.ccp.PhenoGen.data.User;

import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.driver.RException;


/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;
import au.com.forward.threads.ThreadInterruptedException;
import au.com.forward.threads.ThreadException;
import java.io.*;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncParallelAffyPowerTools implements Runnable {

	private Logger log = null;
	private Dataset.DatasetVersion newDatasetVersion = null;
	private Dataset selectedDataset = null;
	private HttpSession session = null;
	private String analysis_level = "";
	private String annotation_level = "";
	private String normalize_method = "";
	private String probeMask = "";
	private User userLoggedIn = null;
	private	Debugger myDebugger = new Debugger();
        private int numThreads=10;
        private String summaryFile="";

	public AsyncParallelAffyPowerTools(Dataset.DatasetVersion newDatasetVersion,
				Dataset selectedDataset,
	 			HttpSession session,
				String analysis_level,
				String annotation_level,
				String normalize_method,
				String probeMask,
                                String summaryFile
                    ) {

                log = Logger.getRootLogger();

		this.newDatasetVersion = newDatasetVersion;
		this.selectedDataset = selectedDataset;
		this.session = session;
		this.analysis_level = analysis_level;
		this.annotation_level = annotation_level;
		this.normalize_method = normalize_method;
		this.probeMask = probeMask;
		this.userLoggedIn = (User) session.getAttribute("userLoggedIn");
                this.summaryFile=summaryFile;
        }

	/** This constructor is used when running this for QC.  
	 *  Analysis_level, annotation_level, and normalize_method are all hard-coded for this call.
	 */
	public AsyncParallelAffyPowerTools(Dataset selectedDataset,
	 			HttpSession session) {

                log = Logger.getRootLogger();

		this.selectedDataset = selectedDataset;
		this.newDatasetVersion = selectedDataset.new DatasetVersion();
		this.newDatasetVersion.setVersion_path(selectedDataset.getPath());
		this.session = session;
		this.analysis_level = "transcript";
		this.annotation_level = "core";
		this.normalize_method = "rma-sketch";
		this.userLoggedIn = (User) session.getAttribute("userLoggedIn");
        }

	public void run() throws RuntimeException {

		Thread thisThread = Thread.currentThread();
	        log.debug("Starting run method of AsyncAffyPowerTools. thisThread = " +thisThread.getName());
		String fileName = "";
		try {
                        //
                        // If this thread is interrupted, throw an Exception
                        //
                        ThreadReturn.ifInterruptedStop();

			fileName = newDatasetVersion.getVersion_path() + "AffyPowerTools";

                	String aptDir = (String) session.getAttribute("aptDir");
                	log.debug("aptDir = "+aptDir + ", fileName = " + fileName);
			boolean mouse = (selectedDataset.getOrganism().equals("Mm") ? true : false);
			String mousePrefix = "Mo";
			String ratPrefix = "Ra";
			String filePrefix = (mouse ? mousePrefix : ratPrefix) + "Ex-1_0-st-v1.r2.";
			String version = (mouse ? "mm8." : "rn4."); 
			String masked = (probeMask.equals("T") ? "MASKED." : ""); 

                	String probeSetFile = aptDir + filePrefix + masked + "pgf";
                	String clfFile = aptDir + filePrefix + "clf";
                	String gcBackgroundFile = aptDir + filePrefix + "antigenomic.bgp";
			String transcriptsFile = aptDir + filePrefix + "dt1." + version + annotation_level + "." + masked + "mps";
			String probesetsFile = aptDir + filePrefix + "dt1." + version + annotation_level + "." + masked + "ps";
                	String qcProbesetsFile = aptDir + filePrefix + "qcc";
                	String analysisPathway = "dabg";
                	String outputDir = newDatasetVersion.getVersion_path();
                	String celFileListing = selectedDataset.getPath() + selectedDataset.getFileListingName();
                	log.debug("outputDir = "+outputDir + ", celFileListing = "+celFileListing);

                	// Create parameter value records?

                	String function = aptDir + "apt-probeset-summarize";
                	List<String>functionArgsList = new ArrayList<String>(Arrays.asList(
                                	function,
                                	"-p", probeSetFile,
                                	"-c", clfFile,
                                	"-a", normalize_method,
                                	"-b", gcBackgroundFile,
                                	"--qc-probesets", qcProbesetsFile,
                                	"-a", analysisPathway,
                                	"-o", outputDir,
                                	"--cel-files", celFileListing
			));
                        String tmpOutputDir=outputDir+"tmpps/";
                        File tmpOutput=new File(tmpOutputDir);
                        tmpOutput.mkdirs();
                        String[] joblist=null;
			if (analysis_level.equals("probeset")) {
				functionArgsList.add("-s");
				functionArgsList.add(probesetsFile);
                                joblist=splitFile(probesetsFile,numThreads,tmpOutputDir);
			} else {
				functionArgsList.add("-m");
				functionArgsList.add(transcriptsFile);
                                joblist=splitFile(transcriptsFile,numThreads,tmpOutputDir);
			}
			
                	

	
			String[] envVariables = new String[] { 
				"PATH=$PATH:" + aptDir
			};
			log.debug("envVariables = "); new Debugger().print(envVariables);
                        Thread[] threadList=new Thread[numThreads];
                        
                        for(int i=0;i<numThreads;i++){
                            String[] functionArgs = (String []) functionArgsList.toArray(new String[functionArgsList.size()]);
                            functionArgs[14]=outputDir+"apt"+i+"/";
                            functionArgs[18]=joblist[i];
                            String tmpFile=outputDir+"AffyPowerTools"+i;
                            log.debug("functionArgs["+i+"] = "); myDebugger.print(functionArgs);
                            threadList[i]=new Thread(new AsyncParallelAffyPowerToolsWorker(aptDir,functionArgs,envVariables,tmpFile));
                            threadList[i].start();
                            int randSleep=(int)Math.random()*20000+5000;
                            thisThread.sleep(randSleep);
                        }
                        boolean done=false;
                        while(!done){
                            done=true;
                            for(int i=0;i<threadList.length&&done;i++){
                                if(threadList[i].isAlive()){
                                    done=false;
                                }
                            }
                            thisThread.sleep(15000);
                        }
                        //move summary files up to next directory
                        for(int i=0;i<numThreads;i++){
                            String dabgr=outputDir+"apt"+i+"/dabg.report.txt";
                            String dabgs=outputDir+"apt"+i+"/dabg.summary.txt";
                            String destdabgr=outputDir+"dabg.report."+i+".txt";
                            String destdabgs=outputDir+"dabg.summary."+i+".txt";
                            File dabgrf=new File(dabgr);
                            File destdabgrf=new File(destdabgr);
                            dabgrf.renameTo(destdabgrf);
                            File dabgsf=new File(dabgs);
                            File destdabgsf=new File(destdabgs);
                            dabgsf.renameTo(destdabgsf);
                            String sr=outputDir+"apt"+i+"/"+summaryFile+".report.txt";
                            String ss=outputDir+"apt"+i+"/"+summaryFile+".summary.txt";
                            String destsr=outputDir+summaryFile+".report."+i+".txt";
                            String destss=outputDir+summaryFile+".summary."+i+".txt";
                            File srf=new File(sr);
                            File destsrf=new File(destsr);
                            srf.renameTo(destsrf);
                            File ssf=new File(ss);
                            File destssf=new File(destss);
                            ssf.renameTo(destssf);
                        }
                        
                        //
                        // If this thread is interrupted, throw an Exception
                        //
                        ThreadReturn.ifInterruptedStop();

		} catch (Throwable t) { 
			log.error("in exception of AsyncAffyPowerTools", t);

                        if (t instanceof ThreadException) {
                                log.error("throwable exception is a ThreadException. cause = "+t.getCause().getMessage());
                                //
                                // This saves the Throwable object so an Exception can be detected
                                // by the calling program
                                //
                                ThreadReturn.save(t);
                        } else if (t instanceof ThreadInterruptedException) {
                                log.error("throwable exception is a ThreadInterruptedException");
                                ThreadReturn.save(new Throwable("ThreadInterruptedException in AsyncAffyPowerTools", t));
                        } else if (t instanceof RException) {
                                log.error("throwable exception is an RException");
                                ThreadReturn.save(new Throwable("RException in AsyncAffyPowerTools is "+ t.getMessage(), t));
                        } else {
                                log.error("exception caused AsyncAffyPowerTools");
                                ThreadReturn.save(t);
			}

			Email myEmail = new Email();
			myEmail.setTo(userLoggedIn.getEmail());
			myEmail.setSubject("Affymetrix Power Tools process had errors"); 

			String mainContent = userLoggedIn.getFormal_name() + ",\n\n" + 	
				"Thank you for using the PhenoGen Informatics website.  "+
				"The Affymetrix Power Tools process that you initiated ";
			String errorContent = mainContent + "was not completed successfully.  "+
					"The system administrator has been notified of the error. " +
					"\n" +
					"You will be contacted via email once the problem is resolved.";

			String adminErrorContent = "The following email was sent to " + userLoggedIn.getEmail() + ":\n" +
					errorContent + "\n" +
					"The file is " + fileName + 
					"\n" + "The error cause was " + t.getCause() + (t.getCause() != null ? t.getCause().getMessage() : t.getMessage()) + 
                        		"\n and the Message = " + t.getMessage();
	                try {
                		myEmail.setContent(errorContent);
       	                	myEmail.sendEmail();
                		myEmail.setContent(adminErrorContent);
       	                	myEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
				log.debug("just sent email to administrator notifying of Affymetrix Power Tools errors");
			} catch (MessagingException e2) {
				log.error("in exception of AsyncAffyPowerTools while sending email", e2);
				throw new RuntimeException();
			}
			//throw new RuntimeException(e.getMessage());
		} finally {
	        	log.debug("executing finally clause in AsyncAffyPowerTools");
		}
	        log.debug("done with AsyncAffyPowerTools run method");
	}
        
        private String[] splitFile(String file,int numThread, String outputDir) throws FileNotFoundException{
            String[] ret=new String[numThread];
            //read file
            //StringBuffer sb=new StringBuffer();
            ArrayList<String> arrLines=new ArrayList<String>();
            boolean first_line=true;
            String headerline="";
            try {
                BufferedReader in = new BufferedReader(new FileReader(new File(file)));
                String line=in.readLine();
                while (line!=null) {
                    if(first_line){
                        if(line.startsWith("#")){
                            
                        }else{
                            first_line=false;
                            headerline=line;
                        }
                    }else{
                        arrLines.add(line);
                    }
                    line= in.readLine();
                }
                in.close();
            } catch (IOException ex) {
                ex.printStackTrace(System.err);
                log.error("Error splitting probeset file\n",ex);
            }
            
            /*for(int i=0;i<lines.length;i++){
                if(!lines[i].startsWith("#")&&!first_line){
                    arrLines.add(lines[i]);
                }else if(first_line&&!lines[i].startsWith("#")){
                    headerline=lines[i];
                    first_line=false;
                }
            }*/
            //determine # of probes/file
            int probesperfile=arrLines.size()/numThread;
            int remainder=arrLines.size()%numThread;
            for(int i=0;i<numThread;i++){
                //output 1 file per thread
                String files=outputDir+"probes_"+i+file.substring(file.lastIndexOf("."));
                try{
                    BufferedWriter out=new BufferedWriter(new FileWriter(files));
                    //DataOutputStream out=new DataOutputStream(new FileOutputStream(new File(files)));
                    //StringBuilder sbo=new StringBuilder();
                    //sbo.append(headerline+"\n");
                    out.write(headerline+"\n");
                    for(int j=0;j<probesperfile;j++){
                        //sbo.append(arrLines.get(0)+"\n");
                        out.write(arrLines.get(0)+"\n");
                        arrLines.remove(0);
                    }
                    if(remainder>0){
                        //sbo.append(arrLines.get(0)+"\n");
                        out.write(arrLines.get(0)+"\n");
                        arrLines.remove(0);
                        remainder--;
                    }
                    //out.writeBytes(sbo.toString());
                    out.flush();
                    out.close();
                }catch(IOException e){
                    e.printStackTrace(System.err);
                    log.error("Error splitting probeset file\n",e);
                }
                //add path to ret
                ret[i]=files;
            }
            
            return ret;
        }
}
 
