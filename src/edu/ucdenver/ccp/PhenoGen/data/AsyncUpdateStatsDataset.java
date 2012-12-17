package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.Connection;
import java.sql.SQLException;

import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.util.sql.PropertiesConnection;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.web.SessionHandler;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadException;
import au.com.forward.threads.ThreadReturn;
import java.io.File;
import java.io.IOException;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncUpdateStatsDataset implements Runnable{

	private Logger log = null;
        private int dsID=-99;
	private Dataset dataset;
	private Dataset.DatasetVersion datasetVersion;
	private String dbPropertiesFile;
	private User userLoggedIn;
	private String sessionID;
	private String mainURL;
        private String methodname;
        private String params;
	private Thread waitThread = null;
	private HttpSession session;
        private DSFilterStat dsfs=null;
        private Connection dbConn;
        private String geneCountAfterStatisticsFileName="";

	public AsyncUpdateStatsDataset(int dsID,int ver,DSFilterStat dsfs,String methodname,String params, String geneCountAfterStatisticsFileName,
				HttpSession session,
				Thread waitThread) {

                log = Logger.getRootLogger();
                this.session = session;
                dbConn=(Connection)session.getAttribute("dbConn");
                this.dsID=dsID;
                try{
                    this.dataset=new Dataset().getDataset(dsID,dbConn);
                }catch(SQLException e){
                    log.error("Error AsyncUpdateStatsDataset",e);
                }
                this.datasetVersion=this.dataset.getDatasetVersion(ver);
                
                this.dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
                this.userLoggedIn = (User) session.getAttribute("userLoggedIn");
		this.sessionID = session.getId();
                this.mainURL = (String) session.getAttribute("mainURL");
		this.waitThread = waitThread;
                this.dsfs=dsfs;
                this.methodname=methodname;
                this.params=params;
                this.geneCountAfterStatisticsFileName=geneCountAfterStatisticsFileName;
        }

	public void run() throws RuntimeException {

		Thread thisThread = Thread.currentThread();
		SessionHandler mySessionHandler = new SessionHandler();
		mySessionHandler.setSession_id(sessionID);
		mySessionHandler.setDataset_id(dataset.getDataset_id());
       		mySessionHandler.setVersion(datasetVersion.getVersion());
		Email myEmail = new Email();

		String mainContent = userLoggedIn.getFormal_name() + ",\n\n" +
					"Thank you for using the PhenoGen Informatics website.  ";
		Connection conn = null;
		try {
			conn = new PropertiesConnection().getConnection(dbPropertiesFile);

			log.debug("In AsyncUpdateDataset waiting on previous thread, '" +
					waitThread.getName() + "',  to finish");
			// 
			// If waitThread threw an exception, then ThreadReturn will
			// detect it and throw the same exception 
			// Otherwise, the join will happen, and will continue to the 
			// next statement.
			//

                        //
                        // If this thread is interrupted, throw an Exception
                        //
                        ThreadReturn.ifInterruptedStop();

			if (waitThread != null) {
			//while (waitThread.isAlive()) {
				log.debug("waiting on thread "+waitThread.getName());
				ThreadReturn.join(waitThread);
				log.debug("just finished waiting on thread "+waitThread.getName());
			}

                        //
                        // If this thread is interrupted, throw an Exception
                        //
                        ThreadReturn.ifInterruptedStop();

			log.debug("before updating visible flag");

                        if(dsfs!=null){
                            //save stats done
                            int tmpcount=-1;
                            if(this.geneCountAfterStatisticsFileName!=null&&!geneCountAfterStatisticsFileName.equals("")){
                                try{
                                    FileHandler myFileHandler=new FileHandler();
                                    tmpcount=Integer.parseInt(myFileHandler.getFileContents(new File(geneCountAfterStatisticsFileName), "noSpaces")[0]);
                                }catch(IOException e){
                                    log.error("Exception Opening Stats Count file:"+e,e);
                                }
                            }
                            
                            dsfs.addStatsStep(methodname,params,tmpcount,1,1,dbConn);
                        }
			

			log.debug("sending email to "+userLoggedIn.getEmail());
			// notify the user that the dataset is ready for viewing
			myEmail.setTo(userLoggedIn.getEmail());
			myEmail.setSubject("Dataset '" + 
						dataset.getName() +
						"_v" + 
						Integer.toString(datasetVersion.getVersion()) +
						"' statistics have completed");
			myEmail.setContent(mainContent  + 
					"The selected statistics method("+methodname+", Parameters:"+params+") has completed, and the dataset is ready for further analysis.  "+
					"You may login to the website at " + mainURL + " and use the available tools to continue"+ 
					" analysis of this dataset.");

			mySessionHandler.setActivity_name("Successfully Completed Statistics Method on Dataset");
			//
			// send an email to the person who normalized the dataset
			//
			try {
				myEmail.sendEmail();
       		        	mySessionHandler.createSessionActivity(mySessionHandler, conn);
				log.debug("just created session activity");
			} catch (Exception e) {
				log.error("exception while trying to send message or createSessionActivity", e);
				throw new RuntimeException();
			}
		} catch (Throwable t) { 
			log.error("In throwable exception of AsyncUpdateDataset", new Exception(t));
                        t.printStackTrace(System.err);
			if (t instanceof ThreadException) {
				log.debug("throwable exception is a ThreadException. cause = "+t.getCause().getMessage());
				//
				// This saves the Throwable object so an Exception can be detected 
				// by the calling program
				//
				log.debug("Throwable cause message = "+t.getCause().getMessage());	
				log.debug("Throwable message = "+t.getMessage());	

				ThreadReturn.save(t);
				//
				// notify the user that the dataset failed during normalization 
				//
				log.debug("sending email that normalization failed to "+userLoggedIn.getEmail());
				myEmail.setTo(userLoggedIn.getEmail());
				myEmail.setSubject("Normalization of Dataset '" + 
						dataset.getName() +
						"_v" + 
						Integer.toString(datasetVersion.getVersion()) +
						"' failed.");
				myEmail.setContent(mainContent + 
							"Unfortunately, there was an error during the normalization process, and "+
							"your data was not successfully normalized.  The "+
							"system administrator has been notified and will investigate the problem.  You "+
							"will be notified via email once it has been resolved.");
				mySessionHandler.setActivity_name("Unsuccessfully tried to normalize dataset");

				try {
       		        		mySessionHandler.createSessionActivity(mySessionHandler, conn);
					log.debug("just created session activity");
					datasetVersion.updateVisibleToError(conn);
				} catch (Exception e) {
					log.error("exception while trying to log session activity or deleteDatasetVersion", e);
					throw new RuntimeException();
				}

	                        Email myAdminEmail = new Email();

				myAdminEmail.setSubject("Normalization of Dataset '" + 
						dataset.getName() +
						"_v" + 
						Integer.toString(datasetVersion.getVersion()) +
						"' failed.");
				myAdminEmail.setContent("Cause = " + t.getCause().getMessage() + 
						"\n Message is "+ t.getMessage() +
						"\n Thread name is "+thisThread.getName() +
						"\n Email has been sent to "+userLoggedIn.getEmail());
                        	try {
					myEmail.sendEmail();
                                	myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                        	} catch (Exception e) {
					log.error("exception while trying to send message", e);
					throw new RuntimeException();
                        	}
			} else {
				log.debug("exception caused in AsyncUpdateDataset");
				ThreadReturn.save(new Throwable("Error in AsyncUpdateDataset", t));
			}

		} finally {
			try {
				conn.close();
			} catch (SQLException e) {
				log.error("exception while closing connection in Async UpdateDataset", e);
				throw new RuntimeException();
			}

		}
	}
}
 
