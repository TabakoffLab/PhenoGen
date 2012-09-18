package edu.ucdenver.ccp.PhenoGen.tools.pathway;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import java.sql.Connection;
import java.sql.SQLException;

import javax.mail.MessagingException;
import javax.mail.SendFailedException;

import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.PhenoGen.web.mail.Email;

import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;
import edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis;
import edu.ucdenver.ccp.PhenoGen.data.ParameterValue;
import edu.ucdenver.ccp.PhenoGen.data.User;

import edu.ucdenver.ccp.PhenoGen.driver.RException;
import edu.ucdenver.ccp.PhenoGen.driver.R_session;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;

import edu.ucdenver.ccp.util.sql.PropertiesConnection;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncPathway implements Runnable{

	private Logger log = null;
	private HttpSession session = null;
	private String method = null;
	private String mainURL = "";
	private GeneListAnalysis myGeneListAnalysis = new GeneListAnalysis();

        private R_session myR_session = new R_session();
        private Debugger myDebugger = new Debugger();
        private ObjectHandler myObjectHandler = new ObjectHandler();
        private FileHandler myFileHandler = new FileHandler();
	private String[] rErrorMsg = null;

	public AsyncPathway(HttpSession session,
			String method) {

                log = Logger.getRootLogger();

		this.session = session;
		this.method = method;
        	this.mainURL = (String) session.getAttribute("mainURL");
        }

	public void run() throws RuntimeException {

	        log.debug("Starting run method of AsyncPathway" );

		Thread thisThread = Thread.currentThread();
		Email myEmail = new Email();

		User userLoggedIn = (User) session.getAttribute("userLoggedIn");
		String userFilesRoot = (String) session.getAttribute("userFilesRoot");
		String dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
        	GeneList selectedGeneList = ((GeneList) session.getAttribute("selectedGeneList") == null ?
                        new GeneList(-99) :
                        (GeneList) session.getAttribute("selectedGeneList"));
        	String rFunctionDir = (String) session.getAttribute("rFunctionDir");

		myEmail.setTo(userLoggedIn.getEmail());
		String mainContent = userLoggedIn.getFormal_name() + ",\n\n" + 	
				"Thank you for using the PhenoGen Informatics website.  "+
				"The Pathway process that you initiated ";
                String geneListAnalysisDir = selectedGeneList.getGeneListAnalysisDir(userLoggedIn.getUserMainDir());
                String pathwayDir = selectedGeneList.getPathwayDir(geneListAnalysisDir);
                String foldChangeFileName = pathwayDir + selectedGeneList.getGene_list_name_no_spaces() + "_GenesPlusFoldChange.txt";

		try {
		        Connection conn = new PropertiesConnection().getConnection(dbPropertiesFile);

			Dataset thisDataset = new Dataset().getDataset(selectedGeneList.getDataset_id(), conn);
			String analysisLevel = new ParameterValue().getAnalysisLevelNormalizationParameter(selectedGeneList.getDataset_id(), selectedGeneList.getVersion(), conn);
			log.debug("analysisLevel = "+analysisLevel);
			String chipType = new edu.ucdenver.ccp.PhenoGen.data.Array().getManufactureArrayName(thisDataset.getArray_type(), conn);
			log.debug("chipType = "+chipType);

                        myFileHandler.createDir(pathwayDir);
                        log.debug("no problems creating geneListAnalysisDir or pathwayDir directory in pathway.jsp");
                        myFileHandler.writeFile(selectedGeneList.getGenesPlusFoldChange(conn), foldChangeFileName);

                	//
                	// If this thread is interrupted, throw an Exception
                	//
                	ThreadReturn.ifInterruptedStop();
			// 
                        String now = myObjectHandler.getNowAsMMddyyyy_HHmmss();
                        java.sql.Timestamp timeNow = myObjectHandler.getNowAsTimestamp();

                	String rFunction = "SimpleSPIA";

			// If the dataset is an exon dataset, need to know the analysis level, and include that in the reference file name
                	String refFile = selectedGeneList.getPublicGeneListsPath(userFilesRoot) + 
						"ReferenceFiles/"+ chipType + 
						(analysisLevel.equals("Unknown") ? "" : "." + analysisLevel) + 
						"_Final.txt";
                	String organism = selectedGeneList.getOrganism();
			String orgString = (organism.equals("Mm") ? "mmu" :
						organism.equals("Hs") ? "hsa" :
							organism.equals("Rn") ? "rno" :
								organism.equals("Dm") ? "dme" : "");
                	String analysisDir = selectedGeneList.getGeneListAnalysisDir(userLoggedIn.getUserMainDir());
                	String analysisPath = selectedGeneList.getPathwayDir(analysisDir);
                	String analysisPathPlusTime = analysisPath + now + "_";

                	String[] functionArgs = new String[7];
                	functionArgs[0] = "DEList = '" + foldChangeFileName + "'";
                	functionArgs[1] = "ReferenceTable = '"+ refFile + "'";
                	functionArgs[2] = "organism = '" + orgString + "'";
                	functionArgs[3] = "method = '" + method + "'";
                	functionArgs[4] = "MainTableName = '" + analysisPathPlusTime + "OutputTable.txt" + "'";
                	functionArgs[5] = "AuxTableName = '" + analysisPathPlusTime + "AuxTable.txt" + "'";
                	functionArgs[6] = "plotName = '" + analysisPathPlusTime + "Plot.jpg" + "'";

                	log.debug("functionArgs = "); myDebugger.print(functionArgs);

                	if ((rErrorMsg =
                        	myR_session.callR(rFunctionDir, rFunction, functionArgs, analysisPath, -99)) != null) {
                        	String errorMsg = myObjectHandler.getAsSeparatedString(rErrorMsg, "<BR>");
                        	log.debug("after R call for SimpleSPIA, got errorMsg. It is "+errorMsg);
                        	throw new RException(errorMsg);
                	}

			String successContent = mainContent + "has completed.  " +
						"You may now view the results on the website at " + mainURL + ". ";
			myEmail.setSubject("Pathway process has completed"); 
                	myEmail.setContent(successContent);



                        int parameter_group_id = new ParameterValue().createParameterGroup(conn);

                        myGeneListAnalysis.setGene_list_id(selectedGeneList.getGene_list_id());
                        myGeneListAnalysis.setUser_id(userLoggedIn.getUser_id());
                        myGeneListAnalysis.setCreate_date(timeNow);
                        myGeneListAnalysis.setAnalysis_type("Pathway");
                        myGeneListAnalysis.setDescription(selectedGeneList.getGene_list_name() +
                                                        "_" + now + "_Pathway Analysis");
                        myGeneListAnalysis.setAnalysisGeneList(selectedGeneList);
                        myGeneListAnalysis.setParameter_group_id(parameter_group_id);

                        ParameterValue[] myParameterValues = new ParameterValue[1];
                        myParameterValues[0] = new ParameterValue();
                        myParameterValues[0].setCreate_date();
                        myParameterValues[0].setParameter_group_id(parameter_group_id);
                        myParameterValues[0].setCategory("Pathway Analysis");
                        myParameterValues[0].setParameter("P-value Used");
                        myParameterValues[0].setValue(method);

                        myGeneListAnalysis.setParameterValues(myParameterValues);
			myGeneListAnalysis.createGeneListAnalysis(conn);
			myGeneListAnalysis.updateVisible(conn);
       	                myEmail.sendEmail();
			conn.close();
		} catch (SendFailedException e) {
			log.error("in exception of AsyncPathway while sending email", e);
		} catch (RException e) {
			log.error("in RException of AsyncPathway", e);
			throw new RuntimeException(e.getMessage());
		} catch (Exception e) {
			log.error("in exception of AsyncPathway", e);
			myEmail.setSubject("Pathway process had errors"); 
			String errorContent = mainContent + "was not completed successfully.  "+
					"The system administrator has been notified of the error. " +
					"\n" +
					"You will be contacted via email once the problem is resolved.";

			String adminErrorContent = "The following email was sent to " + userLoggedIn.getEmail() + ":\n" +
					errorContent + "\n" +
					"The file is " + foldChangeFileName + 
					"\n" + "The error type was "+e.getClass(); 
	                try {
                		myEmail.setContent(errorContent);
       	                	myEmail.sendEmail();
                		myEmail.setContent(adminErrorContent);
       	                	myEmail.sendEmailToAdministrator();
				log.debug("just sent email to administrator notifying of Pathway errors");
			} catch (MessagingException e2) {
				log.error("in exception of AsyncPathway while sending email", e2);
				throw new RuntimeException(e2.getMessage());
			}
			throw new RuntimeException(e.getMessage());
		} finally {
	        	log.debug("executing finally clause in AsyncPathway");
		}
	        log.debug("done with AsyncPathway run method");
	}
}
 
