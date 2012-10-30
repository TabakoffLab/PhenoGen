package edu.ucdenver.ccp.PhenoGen.data;

import java.io.File;
import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.SQLException;

import java.util.Hashtable;
import java.util.List;

import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.util.sql.PropertiesConnection;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;
import au.com.forward.threads.ThreadException;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncUpdateUserArrays implements Runnable{

	private Logger log = null;
	private User thisUser;
	private User thisOwner;
	private String updateOrCreate;
	private boolean sendEmail;
	private String mainURL;
	private HttpSession session;
	//
	// arraysList is a list of Array objects
	//
	private List arraysList;
	private Connection conn;
	private String dbPropertiesFile;
	private Thread waitThread = null;

	public AsyncUpdateUserArrays(User thisUser,
				User thisOwner,
				String updateOrCreate,
				List arraysList,
				HttpSession session,
				boolean sendEmail,
				Thread waitThread) {

                log = Logger.getRootLogger();

		this.thisUser = thisUser;
		this.thisOwner = thisOwner;
		this.updateOrCreate = updateOrCreate;
		this.arraysList = arraysList;
                this.dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
                this.mainURL = (String) session.getAttribute("mainURL");
		this.sendEmail = sendEmail;
		this.waitThread = waitThread;
        }

	public AsyncUpdateUserArrays(User thisUser,
				User thisOwner,
				String updateOrCreate,
				List arraysList,
				HttpSession session,
				boolean sendEmail) {

                log = Logger.getRootLogger();

		this.thisUser = thisUser;
		this.thisOwner = thisOwner;
		this.updateOrCreate = updateOrCreate;
		this.arraysList = arraysList;
                this.dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
                this.mainURL = (String) session.getAttribute("mainURL");
		this.sendEmail = sendEmail;
        }

	public void run() throws RuntimeException {

		Thread thisThread = Thread.currentThread();
		Email myEmail = new Email();

		try {
			if (waitThread != null) {
				log.debug("In AsyncUpdateUserArrays waiting on previous thread, '" +
						waitThread.getName() + "',  to finish");

				// 
				// If waitThread threw an exception, then ThreadReturn will
				// detect it and throw the same exception 
				// Otherwise, the join will happen, and will continue to the 
				// next statement.
				//
				ThreadReturn.join(waitThread);
			}

                	Connection conn = new PropertiesConnection().getConnection(dbPropertiesFile);

                        //
                        // If this thread is interrupted, throw an Exception
                        //
                        ThreadReturn.ifInterruptedStop();

			if (updateOrCreate.equals("C")) {
				Hashtable<String, String> user_arrays = new Hashtable<String, String>();
				for (int i=0; i<arraysList.size(); i++) {
					user_arrays.put(Integer.toString(((Array) arraysList.get(i)).getHybrid_id()), 
							Integer.toString(((Array) arraysList.get(i)).getOwner_user_id()));
				}
				log.debug("creating user chips");
				thisUser.setUser_chips(user_arrays);
	                        thisUser.createUser_chips(conn);
			}
			log.debug("updating array approval");
			thisUser.updateArrayApproval(arraysList, conn);
			log.debug("sending notification");
			if (sendEmail) {
				thisUser.sendAccessNotification(mainURL, arraysList);
			}
			conn.close();

		} catch (Throwable t) { 
			log.error("In throwable exception of AsyncUpdateUserArrays", new Exception(t));

                        if (t instanceof ThreadException) {
                                log.debug("throwable exception is a ThreadException. cause = "+t.getCause().getMessage());
                                log.debug("Throwable message = "+t.getMessage());
				ThreadReturn.save(t);
                        } else if (t instanceof InterruptedException) {
                                log.debug("this thread was interrupted -- AsyncUpdateUserArrays");
				ThreadReturn.save(new Throwable("InterruptedException in AsyncUpdateUserArrays", t));
                        } else {
                                log.debug("exception caused in AsyncUpdateUserArrays");
				ThreadReturn.save(new Throwable("Exception in AsyncUpdateUserArrays", t));
                        }

			log.debug("getting ready to send email to " + thisOwner.getEmail() +  
					" saying there was an error in copying files");
                        Email ownerEmail = new Email();
			
                        ownerEmail.setSubject("Error while approving array requests.");
                        ownerEmail.setContent(thisOwner.getFormal_name() + ",\n\n" +
					"We're sorry, but an error occurred when approving some arrays. "+
					"An administrator has been notified of the problem.  You will be notified "+
					"via email once the problem has been resolved.  ");
			ownerEmail.setTo(thisOwner.getEmail());
                        try {
				log.debug("sending message");
                                ownerEmail.sendEmail();
				log.debug("after sending message");
                        } catch (Exception e) {
				log.error("error sending message", e);
				throw new RuntimeException();
//                                ThreadReturn.save(new Throwable("Error sending message to user", t2));
                        }

			log.debug("getting ready to send email to administrator saying there has been an error");
                        Email myAdminEmail = new Email();
                        myAdminEmail.setSubject("Exception thrown in AsyncUpdateUserArrays.");
                        myAdminEmail.setContent("There was an error while approving array requests. \n\n" +
						"Cause = " + t.getCause().getMessage() + 
						"\n Thread name is "+thisThread.getName());
                        try {
				log.debug("sending admin message");
                                myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
				log.debug("after sending admin message");
                        } catch (Exception e) {
				log.error("error sending admin message", e);
				throw new RuntimeException();
//                                ThreadReturn.save(new Throwable("Error sending message to administrator", t2));
                        }

		} finally {
			//log.debug("executing finally clause in AsyncUpdateUserArrays");
		}
	}
}
 
