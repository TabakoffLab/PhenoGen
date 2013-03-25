package edu.ucdenver.ccp.PhenoGen.tools.analysis;

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
import edu.ucdenver.ccp.PhenoGen.driver.ExecHandler;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.driver.RException;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;
import au.com.forward.threads.ThreadInterruptedException;
import au.com.forward.threads.ThreadException;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncAffyPowerTools implements Runnable {

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

	public AsyncAffyPowerTools(Dataset.DatasetVersion newDatasetVersion,
				Dataset selectedDataset,
	 			HttpSession session,
				String analysis_level,
				String annotation_level,
				String normalize_method,
				String probeMask) {

                log = Logger.getRootLogger();

		this.newDatasetVersion = newDatasetVersion;
		this.selectedDataset = selectedDataset;
		this.session = session;
		this.analysis_level = analysis_level;
		this.annotation_level = annotation_level;
		this.normalize_method = normalize_method;
		this.probeMask = probeMask;
		this.userLoggedIn = (User) session.getAttribute("userLoggedIn");
        }

	/** This constructor is used when running this for QC.  
	 *  Analysis_level, annotation_level, and normalize_method are all hard-coded for this call.
	 */
	public AsyncAffyPowerTools(Dataset selectedDataset,
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
			String version = (mouse ? "mm8." : "rn5."); 
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

			if (analysis_level.equals("probeset")) {
				functionArgsList.add("-s");
				functionArgsList.add(probesetsFile);
			} else {
				functionArgsList.add("-m");
				functionArgsList.add(transcriptsFile);
			}
			String[] functionArgs = (String []) functionArgsList.toArray(new String[functionArgsList.size()]);
                	log.debug("functionArgs = "); myDebugger.print(functionArgs);

	
			String[] envVariables = new String[] { 
				"PATH=$PATH:" + aptDir
			};
			log.debug("envVariables = "); new Debugger().print(envVariables);

			ExecHandler myExecHandler = new ExecHandler(aptDir, 
                        	functionArgs,
				envVariables,
                        	fileName);

			log.debug("starting APT exec process");
			myExecHandler.runExec();
			log.debug("just finished APT exec process");
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
       	                	myEmail.sendEmailToAdministrator("");
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
}
 
