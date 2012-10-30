package edu.ucdenver.ccp.PhenoGen.driver;

import javax.mail.MessagingException;
import edu.ucdenver.ccp.PhenoGen.driver.R_session;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.util.ObjectHandler;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;
import au.com.forward.threads.ThreadInterruptedException;
import au.com.forward.threads.ThreadException;

/* for logging messages */
import org.apache.log4j.Logger;

public class Async_R_Session implements Runnable{

	private Logger log = null;
	private String rFunctionPath = null;
	private String functionName = null;
	private String sessionPath = null;
	private String[] functionArgs = null;
	private int file_number = -99;
	private Thread waitThread = null;

        public Async_R_Session(String rFunctionPath,
                                String functionName,
                                String[] functionArgs,
                                String sessionPath) {
                log = Logger.getRootLogger();
 
                this.rFunctionPath = rFunctionPath;
                this.functionName = functionName;
                this.functionArgs = functionArgs;
                this.sessionPath = sessionPath;
          }
 
        public Async_R_Session(String rFunctionPath,
                                String functionName,
                                String[] functionArgs,
                                String sessionPath,
                                Thread waitThread) {
                  log = Logger.getRootLogger();
 
                this.rFunctionPath = rFunctionPath;
                this.functionName = functionName;
                this.functionArgs = functionArgs;
                this.sessionPath = sessionPath;
                this.waitThread = waitThread;
          }

	// 
	// This constructor accepts an integer so it will create a separate
	// "call_" file containing a number
	//
	public Async_R_Session(String rFunctionPath, 
				String functionName, 
				String[] functionArgs, 
				String sessionPath,
				int file_number,
				Thread waitThread) {
                log = Logger.getRootLogger();

		this.rFunctionPath = rFunctionPath;
		this.functionName = functionName;
		this.functionArgs = functionArgs;
		this.sessionPath = sessionPath; 
		this.file_number = file_number; 
		this.waitThread = waitThread; 
        }

	public void run() throws RuntimeException {

		Thread thisThread = Thread.currentThread();
	        log.debug("Starting run method of Async_R_Session. R_function = " + functionName + 
				", sessionPath = " + sessionPath + ", thisThread = " +thisThread.getName());
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
				log.debug("in Async_R_Session waiting on thread "+waitThread.getName());
				ThreadReturn.join(waitThread);
				log.debug("just finished waiting on thread "+waitThread.getName());
			} else {
				log.debug("waitThread is null");
			}
			log.debug("after waiting on thread");
	
			R_session myR_session = new R_session();
	
			if ((rErrorMsg = myR_session.callR(rFunctionPath, 
							functionName, 
							functionArgs, 
							sessionPath, 
							file_number)) != null) {
				log.debug("rErrorMsg is not null, so throw an RException with the rErrorMsg");
				throw new RException(new ObjectHandler().getAsSeparatedString(rErrorMsg, "<BR>"));
			}
                        //
                        // If this thread is interrupted, throw an Exception
                        //
                        ThreadReturn.ifInterruptedStop();
	
		} catch (Throwable t) { 
			log.error("In exception of Async_R_Session for thread " + thisThread.getName(), t);

			String rError = "";
			if (rErrorMsg != null) {
				for (int i=0; i<rErrorMsg.length; i++) {
					rError = rError + rErrorMsg[i] + "\n";
				}
			}
                        if (t instanceof ThreadException) {
                                log.error("throwable exception is a ThreadException. cause = "+t.getCause().getMessage());
                                //
                                // This saves the Throwable object so an Exception can be detected
                                // by the calling program
                                //
                                ThreadReturn.save(t);
                        } else if (t instanceof ThreadInterruptedException) {
                                log.error("throwable exception is a ThreadInterruptedException");
                                //ThreadReturn.save(t);
                                ThreadReturn.save(new Throwable("ThreadInterruptedException in Async_R_Session", t));
                        } else if (t instanceof RException) {
                                log.error("throwable exception is an RException");
                                //ThreadReturn.save(t);
                                //ThreadReturn.save(new Throwable("RException in Async_R_Session", t));
                                ThreadReturn.save(new Throwable("RException in Async_R_Session is "+ t.getMessage(), t));
                        } else {
                                log.error("exception caused in Async_R_Session");
                                ThreadReturn.save(t);
				//ThreadReturn.save(new Throwable("Error in R process while running " + functionName + "\n" + rError, t));
                        }

                        Email myAdminEmail = new Email();
                        myAdminEmail.setSubject("Exception thrown in Async_R_Session while running "+ functionName);
                        myAdminEmail.setContent("Cause = " + (t.getCause() != null ? t.getCause().getMessage() : t.getMessage()) + 
                        			"\n Message = " + t.getMessage() + 
						"\n Thread name is "+thisThread.getName() +
						"\n Directory = "+ sessionPath);
                        try {
				log.debug("sending message to notify administrator of problem");
                                myAdminEmail.sendEmailToAdministrator("");
                        } catch (MessagingException e) {
				log.error("error sending message to administrator");
				throw new RuntimeException();
                                //ThreadReturn.save(new Throwable("Error sending message to administrator", e));
			}

		}
	        log.debug("done with Async_R_Session run method for this thread: " + thisThread.getName());

	}


}
 
