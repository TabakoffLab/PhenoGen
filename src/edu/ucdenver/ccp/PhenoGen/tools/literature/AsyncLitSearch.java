package edu.ucdenver.ccp.PhenoGen.tools.literature;

import java.io.File;
import java.io.FileInputStream;
import java.sql.Connection;

import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.util.sql.PropertiesConnection;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.data.LitSearch;
import edu.ucdenver.ccp.PhenoGen.data.User;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadException;
import au.com.forward.threads.ThreadReturn;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncLitSearch implements Runnable {

	private Logger log = null;
	private LitSearch myLitSearch = null;
	private User userLoggedIn = null;
	private HttpSession session;
	private String dbPropertiesFile = "";
	private String mainURL = "";

	public AsyncLitSearch(LitSearch myLitSearch,
				HttpSession session) {

                log = Logger.getRootLogger();

		this.myLitSearch = myLitSearch;
		// This is here in case a Thread loses the database connection, it can re-connect
	        this.userLoggedIn = (User) session.getAttribute("userLoggedIn");
	        this.dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
        	this.mainURL = (String) session.getAttribute("mainURL");
        }

	public void run() throws RuntimeException {

		Thread thisThread = Thread.currentThread();
	        log.debug("Starting run method of AsyncLitSearch. emailAddress = " + userLoggedIn.getEmail());
	        log.debug("in AsyncLitSearch. gene_list_id = " + myLitSearch.getLitSearchGeneList().getGene_list_id());
		Connection conn = null;
		String mainContent = userLoggedIn.getFormal_name() + ",\n\n" + 
					"Thank you for using the PhenoGen Informatics website.  ";

	        try {
	                conn = new PropertiesConnection().getConnection(dbPropertiesFile);

                	myLitSearch.callLiterature();
			log.debug("just finished callLiterature().  Now processing results");
                	myLitSearch.processResults(conn);
			log.debug("about to updateVisible flag for Lit Search");
			myLitSearch.updateVisible(conn);
                        //
                        // If this thread is interrupted, throw an Exception
                        //
                        ThreadReturn.ifInterruptedStop();

			Email myEmail = new Email();
			myEmail.setTo(userLoggedIn.getEmail());
                	myEmail.setSubject("Literature Search process has completed"); 

                	myEmail.setContent(mainContent + "The literature search process called '"+
					myLitSearch.getDescription() +
					"' that you initiated has completed.  You may now view the results on the website at "+
					mainURL + ".  ");
                        myEmail.sendEmail();
			conn.close();

		} catch (Throwable t) {
			log.error("in exception of AsyncLitSearch", new Exception(t));
			log.error("here is the Throwable instance:", t);
                        log.debug("thisThread = " +thisThread.getName());

                        if (t instanceof ThreadException) {
                                log.debug("throwable exception is a ThreadException. cause = "+t.getCause().getMessage());
                                //
                                // This saves the Throwable object so an Exception can be detected
                                // by the calling program
                                //
                                ThreadReturn.save(t);
                        } else if (t instanceof InterruptedException) {
                                log.debug("this thread was interrupted -- AsyncLitSearch");
                                ThreadReturn.save(new Throwable("InterruptedException in AsyncLitSearch", t));
                        } else {
                                log.debug("exception caused in AsyncLitSearch");


				Email myEmail = new Email();
				myEmail.setTo(userLoggedIn.getEmail());
                		myEmail.setSubject("Error while running Literature Search process"); 
                		myEmail.setContent(mainContent + "An error was encountered while running the literature search process called '"+
							myLitSearch.getDescription() +
							"' that you initiated.  An administrator has been notified, and will contact "+
							"you via email once the problem is resolved.");

                        	Email myAdminEmail = new Email();
                        	myAdminEmail.setSubject("Exception thrown in AsyncLitSearch");
                        	myAdminEmail.setContent("Cause = " + t.getMessage() +
                                                		"\n Thread name is "+thisThread.getName()); 
                        	try {
                                		log.debug("sending message to user");
                        			myEmail.sendEmail();
                                		log.debug("sending message to administrator");
                                		myAdminEmail.sendEmailToAdministrator();
                        	} catch (Exception e) {
                                		log.error("error sending message to administrator");
                                		throw new RuntimeException();
                        	}

				// Since AsyncLitSearch is not called by another thread, simply throw
				// the exception
				//ThreadReturn.save(new Throwable("Error in AsyncLitSearch", t));
                                throw new RuntimeException(t);
			}


		} finally {
	        	log.debug("executing finally clause in AsyncLitSearch run method");
		}
	        log.debug("done with AsyncLitSearch run method");
	}
}
 
