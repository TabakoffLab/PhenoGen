package edu.ucdenver.ccp.PhenoGen.data;

import java.io.File;
import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.SQLException;

import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.util.sql.PropertiesConnection;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;
import au.com.forward.threads.ThreadException;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncUpdateQcStatus implements Runnable{

	private Logger log = null;
	private String qcStepComplete;
	private Dataset selectedDataset;
	private String dbPropertiesFile;
	private User userLoggedIn;
	private String mainURL;
	private Thread waitThread = null;
	private HttpSession session;

	public AsyncUpdateQcStatus(HttpSession session,
				String qcStepComplete,
				Thread waitThread) {
                log = Logger.getRootLogger();

                this.session = session;
		this.qcStepComplete = qcStepComplete;
                this.selectedDataset = (Dataset) session.getAttribute("selectedDataset");
                this.dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
                this.userLoggedIn = (User) session.getAttribute("userLoggedIn");
                this.mainURL = (String) session.getAttribute("mainURL");
		this.waitThread = waitThread;
        }

	public AsyncUpdateQcStatus(HttpSession session,
				String qcStepComplete) {

                log = Logger.getRootLogger();

                this.session = session;
		this.qcStepComplete = qcStepComplete;
                this.selectedDataset = (Dataset) session.getAttribute("selectedDataset");
                this.dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
                this.userLoggedIn = (User) session.getAttribute("userLoggedIn");
                this.mainURL = (String) session.getAttribute("mainURL");
        }

	public void run() throws RuntimeException {
		Thread thisThread = Thread.currentThread();
		String salutation = userLoggedIn.getFormal_name() + ",\n\n";
		Email myEmail = new Email();
		Connection conn = null;

		try {
			// 
			// If waitThread threw an exception, then ThreadReturn will
			// detect it and throw the same exception 
			// Otherwise, the join will happen, and will continue to the 
			// next statement.
			//
			if (waitThread != null) {
				log.debug("In AsyncUpdateQcStatus waiting on previous thread, '" +
					waitThread.getName() + "',  to finish");
				ThreadReturn.join(waitThread);
				log.debug("just finished waiting on thread "+waitThread.getName());
			}

			conn = new PropertiesConnection().getConnection(dbPropertiesFile);

			selectedDataset.updateQc_complete(qcStepComplete, conn);
			log.debug("Finished with updateQC status where step # = "+qcStepComplete);

			//
			// Send an email only when all steps have completed
			//
			if (!qcStepComplete.equals("1")) {
				myEmail.setSubject("Quality Control Check Complete for Dataset '" + selectedDataset.getName() + "'");
                        	myEmail.setTo(userLoggedIn.getEmail());
                        	myEmail.setContent(salutation + 
						"Thank you for using the PhenoGen Informatics website.  "+
						"The quality control checks for your dataset are complete.  You may login to "+
						"the website at " + mainURL + " and select your dataset to view the results.  ");
                        	try {
                                	myEmail.sendEmail();
                        	} catch (Exception e) {
                                	log.error("exception while trying to send message notifying user of errors in quality control", e);
					throw new RuntimeException();
                        	}
				log.debug("Finished with qc process.  Just sent message to user");
			}
		} catch (Throwable t) { 
			log.error("In throwable exception of AsyncUpdateQcStatus", new Exception(t));
			if (t instanceof ThreadException) {
				log.error("throwable exception is a ThreadException. cause = "+t.getCause().getMessage());
				//
				// This saves the Throwable object so an Exception can be detected 
				// by the calling program
				//
				ThreadReturn.save(t);

				myEmail.setSubject("Error occurred during Quality Control Check for Dataset '" + selectedDataset.getName() + "'");
                        	myEmail.setTo(userLoggedIn.getEmail());
                        	myEmail.setContent(salutation + 
					"Thank you for using the PhenoGen Informatics website.  "+
					"Unfortunately, an error occurred during the quality control process "+
					"for your dataset.  The system administrator has been notified of the error "+
					"and will contact you via email once it has been resolved. "); 
                        	Email myAdminEmail = new Email();
                        	myAdminEmail.setSubject("Exception thrown in AsyncUpdateQcStatus");
                        	myAdminEmail.setContent(userLoggedIn.getFormal_name() + " got an error during the "+ qcStepComplete +" step "+
							"in the quality control process.  "+
							"\n Cause = " + t.getCause().getMessage() + 
							"\n Thread name is "+thisThread.getName());
                        	try {
                                	myEmail.sendEmail();
                                	myAdminEmail.sendEmailToAdministrator();
                        	} catch (Exception e) {
					log.error("error sending message", e);
					throw new RuntimeException();
                                	//ThreadReturn.save(t2);
                        	}
			} else { 
				log.error("exception caused in AsyncUpdateQcStatus");
				ThreadReturn.save(new Throwable("Error in AsyncUpdateQcStatus", t));
				throw new RuntimeException();
			}

		} finally {
			//log.debug("executing finally clause in AsyncUpdateQcStatus");
			if (conn != null) {
				try { 
					conn.close();
				} catch (Exception e) {
				}
			}
		}
	}
}
 
