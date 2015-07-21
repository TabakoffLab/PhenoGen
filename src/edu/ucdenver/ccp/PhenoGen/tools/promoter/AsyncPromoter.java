package edu.ucdenver.ccp.PhenoGen.tools.promoter;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import java.sql.Connection;
import java.sql.SQLException;

import javax.mail.MessagingException;

import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;
import edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis;
import edu.ucdenver.ccp.PhenoGen.data.Promoter;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.driver.PerlException;
import edu.ucdenver.ccp.PhenoGen.driver.PerlHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.PropertiesConnection;
import javax.sql.DataSource;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncPromoter implements Runnable{

	private Logger log = null;
	private HttpSession session = null;
	private String perlDir = null;
	private String conservationLevel = null;
	private String thresholdLevel = null;
	private String searchRegionLevel = null;
	private User userLoggedIn = null;
	private String filePrefix = null;
	private String dbPropertiesFile = null;
	private Promoter myPromoter = null;
	private GeneList selectedGeneList = null;
	private String mainURL = null;
        private String idType=null;
        private DataSource pool=null;
        private GeneListAnalysis myGeneListAnalysis=null;

	public AsyncPromoter(HttpSession session,
				String conservationLevel,
				String thresholdLevel,
				String searchRegionLevel,
				Promoter myPromoter,
                                GeneListAnalysis myGeneListAnalysis,
				String filePrefix,
                                String idType) {

                log = Logger.getRootLogger();
		this.session = session;
		this.conservationLevel = conservationLevel;
		this.thresholdLevel = thresholdLevel;
		this.searchRegionLevel = searchRegionLevel;
		this.myPromoter = myPromoter;
		this.filePrefix = filePrefix;
                this.idType=idType;

		this.dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
        	this.mainURL = (String) session.getAttribute("mainURL");
	        this.userLoggedIn = (User) session.getAttribute("userLoggedIn");
	        this.selectedGeneList = (GeneList) session.getAttribute("selectedGeneList");
		this.perlDir = (String) session.getAttribute("perlDir") + "scripts/";
                this.pool = (DataSource) session.getAttribute("dbPool");
                this.myGeneListAnalysis = myGeneListAnalysis;

        }

	public void run() throws RuntimeException {

	        log.debug("Starting run method of AsyncPromoter. filePrefix = " + filePrefix);
		Thread thisThread = Thread.currentThread();
		Email myEmail = new Email();
		myEmail.setTo(userLoggedIn.getEmail());

		String mainContent = userLoggedIn.getFormal_name() + ",\n\n" + 	
				"Thank you for using the PhenoGen Informatics website.  "+
				"The oPOSSUM promoter process called '"+
				myPromoter.getDescription() + "' that you initiated ";

                String promoterOrganism = (selectedGeneList.getOrganism().equals("Hs") ? "Human" : "Mouse");

		String [] functionArgs = new String[] {
                                        perlDir + "default_analysis.pl",
                                        "-g", filePrefix + "promoterGenes.txt",
                                        "-s", promoterOrganism,
                                        "-i", idType,
                                //      "-ic", "8",
                                        "-tax", "vertebrate",
                                        "-cl", conservationLevel,
                                        "-thl", thresholdLevel,
                                        "-srl", searchRegionLevel,
                                        "-o", filePrefix + "output.txt",
                                        //"-f", filePrefix + "fisher.txt",
                                        //"-z", filePrefix + "zscore.txt",
                                        "-h", filePrefix + "tfbsHits.txt"
                                };

		PerlHandler myPerlHandler = new PerlHandler(perlDir,
                        	functionArgs,
                        	filePrefix);
		try {
			myPerlHandler.runPerl();

			String successContent = mainContent + "has completed.  " +
						"You may now view the results on the website at "+mainURL+".";
			myEmail.setSubject("Promoter process has completed"); 
                	myEmail.setContent(successContent);

		        Connection conn = new PropertiesConnection().getConnection(dbPropertiesFile);

			try {
                                myGeneListAnalysis.updateStatus(pool,"Complete");
				/*int promoter_id = myPromoter.createPromoterResult(conn);
				GeneListAnalysis thisGeneListAnalysis = new GeneListAnalysis(promoter_id);*/
				//thisGeneListAnalysis.updateVisible(conn);
       	                	myEmail.sendEmail();
			} catch (MessagingException e) {
				log.error("in exception of AsyncPromoter while sending email", e);
			} catch (SQLException e) {
				log.error("in exception of AsyncPromoter while getting promoter id", e);
			}

			conn.close();
		} catch (IOException e) {
			log.error("in IOexception of AsyncPromoter while loading properties file", e);
			throw new RuntimeException(e);
		} catch (SQLException e) {
			log.error("in exception of AsyncPromoter while getting promoter id", e);
			throw new RuntimeException(e);
		} catch(PerlException e) {
			log.error("in PerlException of AsyncPromoter ", e);
			myEmail.setSubject("Promoter process had errors"); 

			String perlErrors = myPerlHandler.getErrors();
			String errorContent = mainContent + "was not completed successfully.  "+
					"The system administrator has been notified of the following errors that occurred: " +
					"\n" +
					perlErrors +
					"\n" +
					"You will be contacted via email once the problem is resolved.";

			String adminErrorContent = "The following email was sent to " + userLoggedIn.getEmail() + ":\n" +
						errorContent + "\n" +
						"The directory is " + filePrefix;
	                try {
                		myEmail.setContent(errorContent);
       	                	myEmail.sendEmail();
				log.debug("just sent email to user notifying them of perl errors");

                		myEmail.setContent(adminErrorContent);
       	                	myEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
				log.debug("just sent email to administrator notifying of perl errors");
			} catch (MessagingException e2) {
				log.error("in exception of AsyncPromoter while sending email", e2);
				throw new RuntimeException(e2);
			}
			throw new RuntimeException(e);
		} catch (Exception e) {
			log.error("in exception of AsyncPromoter", e);
			throw new RuntimeException(e);
		} finally {
	        	log.debug("executing finally clause in AsyncPromoter");
		}
	        log.debug("done with AsyncPromoter run method");
	}
}
 
