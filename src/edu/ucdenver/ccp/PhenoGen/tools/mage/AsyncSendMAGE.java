package edu.ucdenver.ccp.PhenoGen.tools.mage;

import java.io.File;
import java.sql.Connection;

import java.util.ArrayList;
import java.util.List;

import javax.mail.MessagingException;
import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.data.Array;
import edu.ucdenver.ccp.PhenoGen.data.Experiment;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.FileHandler;


/* for handling exceptions in Threads */
//import au.com.forward.threads.ThreadReturn;
//import au.com.forward.threads.*;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncSendMAGE implements Runnable{

	private Logger log = null;
	private Experiment thisExperiment = null;
	private edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = null;
	private User websiteUser = null;
        private HttpSession session = null;

	public AsyncSendMAGE(Experiment thisExperiment,
			edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays,
			User websiteUser,
                        HttpSession session) {

                log = Logger.getRootLogger();

		this.thisExperiment = thisExperiment; 
		this.myArrays = myArrays; 
		this.websiteUser = websiteUser;
                this.session = session;
        }

	public void run() throws RuntimeException {

		String filePrefix = websiteUser.getUserExperimentDir() +
                                        thisExperiment.getExpNameNoSpaces() + "/";

	        log.debug("Starting run method of AsyncSendMAGE. filePrefix = " + filePrefix);

		Thread thisThread = Thread.currentThread();
		Email myEmail = new Email();
		Email ebiEmail = new Email();
		String xmlFile = filePrefix + thisExperiment.getExpName().replaceAll(" ", "_") + ".xml";
		edu.ucdenver.ccp.PhenoGen.data.Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();

		String mainContent = websiteUser.getFormal_name() + ",\n\n" + 	
			"The MAGE-ML file plus the raw data files for the dataset '"+
			thisExperiment.getExpName() + "' ";
	
		myEmail.setTo(websiteUser.getEmail());
		//ebiEmail.setTo("arraysubs@ebi.ac.uk");
		ebiEmail.setTo(websiteUser.getEmail());

		try {

			FileHandler myFileHandler = new FileHandler();

			String userFilesRoot = (String) session.getAttribute("userFilesRoot");
                	List<String> fileList = new ArrayList<String>();
                	fileList.add(xmlFile);
                	for (int i=0; i<myArrays.length; i++) {
                        	fileList.add(myArrays[i].getRawDataFileLocation(userFilesRoot) + myArrays[i].getFile_name());
                	}
			log.debug("fileList = "); new Debugger().print(fileList);

                	String[] files = (String []) fileList.toArray(new String[fileList.size()]);

                	String tarFileName = filePrefix + thisExperiment.getExpName().replaceAll(" ", "") + "_MAGE-ML.tar";
                	String zipFileName = tarFileName + ".gz"; 

                	log.debug("creating tar file");
                	myFileHandler.createTarFile(files, tarFileName);
                	log.debug("creating zip file");
                	myFileHandler.createGZipFile(new File(tarFileName), zipFileName);

                	log.debug("ftping tar.gz file");
			String ebiFileName = "CherylHornbaker_" + thisExperiment.getExpName().replaceAll(" ", "") + "_MAGE-ML.tar.gz";

                	myFileHandler.ftpPutFile("compbio.ucdenver.edu",
                                        	"anonymous",
                                        	"",
                                        	"pub/cmpdrop",
                                        	ebiFileName,
                                        	zipFileName);
/*
                	myFileHandler.ftpPutFile("ftp1.ebi.ac.uk",
                                        	"aexpress",
                                        	"aexpress",
                                        	"",
						ebiFileName,
                                        	zipFileName);
*/

			String successContent = mainContent + "have successfully been "+
						"transferred to Array Express. ";
			myEmail.setSubject("MAGE-ML transfer process has completed"); 
                	myEmail.setContent(successContent);
			ebiEmail.setSubject("Array Express Submission"); 
                	ebiEmail.setContent("We have just submitted a file called "+ebiFileName+" to ftp1.ebi.ac.uk.  It contains "+
					"a MAGE-ML file and associated CEL files for a dataset we would like to submit to ArrayExpress.\n\n"+
					"If you have any questions, please email me at cheryl.hornbaker@ucdenver.edu. \n\n"+
					"Thank you. ");

			try {
				log.debug("sending emails to user and ebi saying submission happened");
       	                	myEmail.sendEmail();
       	                	myEmail.sendEmailToAdministrator();
       	                	ebiEmail.sendEmail();
			//} catch (SendFailedException e) {
			} catch (MessagingException e) {
				log.error("in exception of AsyncSendMAGE while sending email", e);
			}

		} catch (Exception e) {
			myEmail.setSubject("An error occurred while submitting files to Array Express"); 

			String errorContent = mainContent + "had errors when submitting to Array Express. "+ 
					"An administrator has been notified.";

                	myEmail.setContent(errorContent);
	                try {
       	                	myEmail.sendEmail();
				log.debug("just sent email to user notifying them of submission errors");
				errorContent = "The following email was sent to " + websiteUser.getEmail() + ":\n" +
						errorContent + "\n" +
						"The directory is " + filePrefix;
                		myEmail.setContent(errorContent);
       	                	myEmail.sendEmailToAdministrator();
				log.debug("just sent email to administrator notifying of submission errors");
			//} catch (SendFailedException emailException) {
			} catch (MessagingException emailException) {
                        	log.error("exception while trying to send email message about submission", emailException);
				throw new RuntimeException();
                	}
			log.debug("in exception of AsyncSendMAGE", e);
			throw new RuntimeException();
		} finally {
	        	log.debug("executing finally clause in AsyncSendMAGE");
		}
	        log.debug("done with AsyncSendMAGE run method");
	}
}
 
