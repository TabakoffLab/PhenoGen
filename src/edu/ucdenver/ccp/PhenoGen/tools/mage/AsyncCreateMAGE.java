package edu.ucdenver.ccp.PhenoGen.tools.mage;

import java.io.File;

import java.sql.Connection;

import java.util.List;

import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.PhenoGen.data.Array;
import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.Experiment;
import edu.ucdenver.ccp.PhenoGen.data.User;

import edu.ucdenver.ccp.PhenoGen.driver.PerlException;
import edu.ucdenver.ccp.PhenoGen.driver.PerlHandler;

import edu.ucdenver.ccp.PhenoGen.web.mail.Email;

import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;

//import MAGEloader.MAGEdriver;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncCreateMAGE implements Runnable{

	private Logger log = null;
	private Experiment selectedExperiment = null;
	private User userLoggedIn = null;
	private HttpSession session = null;
	private Connection conn;

	public AsyncCreateMAGE(HttpSession session) {

                log = Logger.getRootLogger();

		this.session = session; 
	        this.selectedExperiment = (Experiment) session.getAttribute("selectedExperiment");
	        this.userLoggedIn = (User) session.getAttribute("userLoggedIn");
        	this.conn = (Connection) session.getAttribute("dbConn");
        }

	public void run() throws RuntimeException {

		String filePrefix = userLoggedIn.getUserExperimentDir() +
					selectedExperiment.getExpNameNoSpaces() + "/";

	        log.debug("Starting run method of AsyncCreateMAGE. filePrefix = " + filePrefix);

		Thread thisThread = Thread.currentThread();
		FileHandler myFileHandler = new FileHandler();
		Email myEmail = new Email();
                String mageDir = "/srv/miamexpress/www/cgi-bin/magexpress/";
		String xmlFileName = filePrefix + selectedExperiment.getExpName().replaceAll(" ", "_") + ".xml";
		File xmlFile = new File(xmlFileName);
		//log.debug("xmlFile.getParent() = "+xmlFile.getParent());
		String experimentAccno = "";
		String userFilesRoot = (String) session.getAttribute("userFilesRoot");
		edu.ucdenver.ccp.PhenoGen.data.Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();

		try {
        		experimentAccno = myArray.getNextAccno(conn);
			log.debug("experimentAccno = "+experimentAccno);
		} catch(Exception e) {
			log.error("in exception of AsyncCreateMAGE while getting next experiment number", e);
			throw new RuntimeException();
		}


                String [] xmlFunctionArgs = new String[] {
                        	"perl5.8.3", 
                        	mageDir + "experiment_mageml.pl",
                        	selectedExperiment.getExpName(),
                        	"GenePix",
				experimentAccno,
                        	xmlFileName
                	};

		PerlHandler xmlPerlHandler = new PerlHandler(mageDir,
                        			xmlFunctionArgs,
                        			filePrefix + "MAGE");
		
                String [] validatorFunctionArgs = new String[] {
                        	"perl5.8.7", 
                        	mageDir + "expt_check.pl",
				"-l", 
                        	selectedExperiment.getCreated_by_login(),
				"-p", 
                        	filePrefix,
                        	"-t",
				selectedExperiment.getExpName(),
				"-c"
                	};

		PerlHandler validatorPerlHandler = new PerlHandler(mageDir,
                        			validatorFunctionArgs,
                        			filePrefix + "Validate");

                String [] mergeFunctionArgs = new String[] {
                        	"perl5.8.7", 
                        	mageDir + "mx_add_affy.pl",
				"-l", 
                        	selectedExperiment.getCreated_by_login(),
                        	"-t",
				selectedExperiment.getExpName(),
                        	"-o",
				xmlFileName
                	};

		PerlHandler mergePerlHandler = new PerlHandler(mageDir,
                        			mergeFunctionArgs,
                        			filePrefix + "Merge");


		String mainContent = userLoggedIn.getFormal_name() + ",\n\n" + 	
			"The MAGE-ML file for the dataset '"+
			selectedExperiment.getExpName() + "' ";

		String validatorErrors = "";
		String mergeErrors = "";
		//myEmail.setTo(userLoggedIn.getEmail());
	
		try {

			xmlPerlHandler.runPerl();
			log.debug("just finished creating xml");
			validatorPerlHandler.runPerl();
			log.debug("just finished validating xml");
			File validatorLogFile = new File(filePrefix + 
							"expt_" +
							selectedExperiment.getCreated_by_login() +
							"_sub" +
							selectedExperiment.getSubid() +
							"_error.log");

			log.debug("validatorLogFile = "+validatorLogFile.getPath());
			String[] validatorErrorArray = myFileHandler.checkFileForErrors(validatorLogFile, "Error", "LineOnly");

			if  (validatorErrorArray != null && validatorErrorArray.length > 0) {
				log.debug("validatorErrorArray is not null.  Length = "+validatorErrorArray.length);
				validatorErrors = new ObjectHandler().getAsSeparatedString(validatorErrorArray, "\n");
				throw new ValidatorException();
			}

                	String mergingFileName = myArray.getExperimentDataFilesLocation(userFilesRoot) + selectedExperiment.getCreated_by_login() + "/" +
                                                	"submission" + selectedExperiment.getSubid() + "/" + 
							selectedExperiment.getExpName().replaceAll(" ", "_") + ".xml";
			//log.debug("mergingFileName = "+mergingFileName);
			myFileHandler.copyFile(xmlFile, new File(mergingFileName));
			if (selectedExperiment.getPlatform().equals(new Dataset().AFFYMETRIX_PLATFORM)) {
				log.debug("starting merge process for Affy expt");
				mergePerlHandler.runPerl();
				log.debug("just finished merging xml");
			}
			if (selectedExperiment.getPlatform().equals(new Dataset().CODELINK_PLATFORM)) {
				// run convert_to_mcmr.pl
			}

			/*
			String fileContents = myFileHandler.getFileContents(xmlFile);

			for (int i=0; i<fileContents.length; i++) {
				fileContents[i] = fileContents[i].replaceAll("ucdenver.edu stuff", "ebi.ac.uk stuff");
			}
			*/
			String successContent = mainContent + "has successfully been created.  "+
						//"The following log file was generated "+
						//"during validation.  If required, fix the errors and re-generate the MAGE-ML file.  "+
						//"If no problems were encountered, "+
						"You may go to the website at "+
						session.getAttribute("mainURL") +
						" and select "+
						"'Submit Experiment To ArrayExpress' "+
						"to transfer the files to Array Express. \n\n";
						//"Log file contents: \n"+
						//validatorFileContents + "\n";
			myEmail.setSubject("MAGE-ML creation process has completed"); 
                	myEmail.setContent(successContent);

			try {
				//log.debug("sending success message to user that MAGE-ML created successfully");
				// Now just sent to administrator because they have to curate xml file before sending 
       	                	//myEmail.sendEmail();
				log.debug("sending success message to administrator that MAGE-ML created successfully");
       	                	myEmail.sendEmailToAdministrator();
			} catch (Exception e) {
				log.error("in exception of AsyncCreateMAGE while sending email", e);
			}

		} catch (PerlException perlException) {
			log.error("in PerlException of AsyncCreateMAGE");
			String xmlPerlErrors = xmlPerlHandler.getErrors();
			String validatorPerlErrors = validatorPerlHandler.getErrors();
			myEmail.setSubject("MAGE-ML creation process had errors"); 

			String errorContent = mainContent + "was not completed.  "+
					"The system administrator has been notified of the following errors that occurred: " + 
					"\n" + xmlPerlErrors + "\n" +
					validatorPerlErrors;

                	myEmail.setContent(errorContent);
			//
			// reset the Accno so that the experiment does not show up in the
			// list of experiments that can be sent to ArrayExpress
			//
			try {
				myArray.updateAccno(selectedExperiment.getSubid(), null, conn);
			} catch(Exception e) {
				log.error("in PerlException of AsyncCreateMAGE while re-setting next experiment number", e);
				throw new RuntimeException();
			}
	                try {
				//log.debug("trying to send email to "+userLoggedIn.getEmail()+" about perl errors");
       	                	//myEmail.sendEmail();
				log.debug("just sent email to user notifying them of perl errors");
				errorContent = "The following email was sent to " + userLoggedIn.getEmail() + ":\n" +
						errorContent + "\n" +
						"The directory is " + filePrefix;
                		myEmail.setContent(errorContent);
       	                	myEmail.sendEmailToAdministrator();
				log.debug("just sent email to administrator notifying of perl errors");
			} catch (Exception e) {
                        	log.error("exception while trying to send email message about perl", e);
				throw new RuntimeException();
                	}
                        log.debug("in PerlException of AsyncCreateMAGE while executing perl", perlException);
                        throw new RuntimeException();
		} catch (ValidatorException validatorException) {
			log.error("ValidatorException thrown in AsyncCreateMAGE");
			myEmail.setSubject("MAGE-ML creation process had errors during validation"); 

			String errorContent = mainContent + "was successfully generated, but encountered the following problems when validated: \n" +  
					"\n" + validatorErrors + "\n" +
					"\n" + "These errors must be fixed before you may submit to ArrayExpress.  " + "\n";

                	myEmail.setContent(errorContent);
			//
			// reset the Accno so that the experiment does not show up in the
			// list of experiments that can be sent to ArrayExpress
			//
			try {
				myArray.updateAccno(selectedExperiment.getSubid(), null, conn);
			} catch(Exception e) {
				log.error("in ValidatorException of AsyncCreateMAGE while re-setting next experiment number", e);
				throw new RuntimeException();
			}

	                try {
       	                	//myEmail.sendEmail();
				log.debug("just sent email to user notifying them of validator errors");
				errorContent = "The following email was sent to " + userLoggedIn.getEmail() + ":\n" +
						errorContent + "\n" +
						"The directory is " + filePrefix;
                		myEmail.setContent(errorContent);
       	                	myEmail.sendEmailToAdministrator();
				log.debug("just sent email to administrator notifying of validator errors");
			} catch (Exception e) {
                        	log.error("exception while trying to send email message about validator", e);
				throw new RuntimeException();
                	}
                        log.debug("in ValidatorException of AsyncCreateMAGE while executing validator", validatorException);
                        throw new RuntimeException();
		} catch(Exception e) {
                        log.error("in Exception of AsyncCreateMAGE");

                        String xmlPerlErrors = xmlPerlHandler.getErrors();
                        String validatorPerlErrors = validatorPerlHandler.getErrors();
                        myEmail.setSubject("MAGE-ML creation process had errors");

                        String errorContent = mainContent + "was not completed.  "+
                                        "The system administrator has been notified of the following errors that occurred: " +
                                        "\n" + xmlPerlErrors + "\n" +
                                        validatorPerlErrors;

                        myEmail.setContent(errorContent);
			//
			// reset the Accno so that the experiment does not show up in the
			// list of experiments that can be sent to ArrayExpress
			//
			try {
				myArray.updateAccno(selectedExperiment.getSubid(), null, conn);
			} catch(Exception e2) {
				log.error("in main Exception of AsyncCreateMAGE while re-setting next experiment number", e2);
				throw new RuntimeException();
			}
                        try {
                                log.debug("trying to send email to "+userLoggedIn.getEmail()+" about perl errors");
                                //myEmail.sendEmail();
                                log.debug("just sent email to user notifying them of perl errors");
                                errorContent = "The following email was sent to " + userLoggedIn.getEmail() + ":\n" +
                                                errorContent + "\n" +
                                                "The directory is " + filePrefix;
                                myEmail.setContent(errorContent);
                                myEmail.sendEmailToAdministrator();
                                log.debug("just sent email to administrator notifying of perl errors");
                        } catch (Exception e2) {
                                log.error("exception while trying to send email message about perl", e2);
                                throw new RuntimeException();
                        }

			log.debug("in main exception of AsyncCreateMAGE while executing perl", e);
			throw new RuntimeException();
		} finally {
	        	log.debug("executing finally clause in AsyncCreateMAGE");
		}
	        log.debug("done with AsyncCreateMAGE run method");
	}
}
 
