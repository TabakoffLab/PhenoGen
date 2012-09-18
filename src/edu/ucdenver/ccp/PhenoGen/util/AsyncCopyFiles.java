package edu.ucdenver.ccp.PhenoGen.util;

import java.io.File;

import java.util.List;

import edu.ucdenver.ccp.PhenoGen.data.Array;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.FileHandler;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadException;
import au.com.forward.threads.ThreadReturn;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncCopyFiles implements Runnable{
	

	private Logger log = null;
	//
	// arraysList is a List of Array objects
	//
	private List arraysList = null;
	private String destinationDir = null;
        private String userFilesRoot = "";

	public AsyncCopyFiles(List arraysList,
                       		String userFilesRoot,
				String destinationDir) {

                log = Logger.getRootLogger();

		this.arraysList = arraysList;
                this.userFilesRoot = userFilesRoot;
		this.destinationDir = destinationDir;
        }

	public void run() throws RuntimeException {

                log.info("in AsyncCopyFiles");
		Thread thisThread = Thread.currentThread();
		log.debug("thisThread = "+thisThread.getName());
		String fileName = "";
                String sourceFile = "";
                String destinationFile = "";

		try {
			FileHandler myFileHandler = new FileHandler();

			//log.debug("arraysList here in AsyncCopyFiles = "); new Debugger().print(arraysList);
                        for (int i=0; i<arraysList.size(); i++) {
				Array thisArray = (Array) arraysList.get(i);
				fileName = thisArray.getFile_name();
                        	sourceFile = thisArray.getRawDataFileLocation(userFilesRoot) + fileName;
				destinationFile = destinationDir + fileName;
				//log.debug("about to copy this file: "+sourceFile+" to here: "+destinationFile);

                        	myFileHandler.copyFile(new File(sourceFile), new File(destinationFile));

			}
			//}
			//
			// If this thread is interrupted, throw an Exception
			//
			ThreadReturn.ifInterruptedStop();

		} catch (Throwable t) {
			log.error("In exception of AsyncCopyFiles", new Exception(t));

			if (t instanceof ThreadException) {
				log.error("throwable exception is a ThreadException. cause = "+t.getCause().getMessage());
				log.error("Throwable message = "+t.getMessage());	
				//
				// This saves the Throwable object so an Exception can be detected 
				// by the calling program
				//
				ThreadReturn.save(t);
			} else if (t instanceof InterruptedException) {
				log.error("this thread was interrupted -- AsyncCopyFiles");
                                ThreadReturn.save(new Throwable("InterruptedException in AsyncCopyFiles", t));
			} else {
				log.error("exception caused in AsyncCopyFiles");
				ThreadReturn.save(t);
			}

			Email myAdminEmail = new Email();
			myAdminEmail.setSubject("Exception thrown in AsyncCopyFiles while copying "+
					sourceFile + " to " + destinationFile);
                        myAdminEmail.setContent("Cause = " + t.getCause().getMessage() + 
							"\n Thread name is "+thisThread.getName());
			try {
				log.debug("sending message to administrator");
				myAdminEmail.sendEmailToAdministrator();
			} catch (Exception e) {
				log.error("error sending message to administrator");
				throw new RuntimeException();
			}
		}

		log.debug("done with AsyncCopyFiles");
	}
}
