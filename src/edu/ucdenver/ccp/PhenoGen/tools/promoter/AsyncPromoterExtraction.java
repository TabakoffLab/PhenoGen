package edu.ucdenver.ccp.PhenoGen.tools.promoter;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.FileInputStream;

import java.sql.Connection;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.List;

import javax.mail.MessagingException;
import javax.mail.SendFailedException;

import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;
import edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.PropertiesConnection;

import org.ensembl.datamodel.Sequence;
import org.ensembl.driver.CoreDriver;
import org.ensembl.driver.CoreDriverFactory;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncPromoterExtraction implements Runnable{

	private Logger log = null;
	private HttpSession session = null;
	private String fileName = null;
	private String[] geneArray = null;
	private User userLoggedIn = null;
	private String dbPropertiesFile = null;
	private GeneListAnalysis myGeneListAnalysis = null;
	private String mainURL = "";
	private boolean runningMeme = true;

	public AsyncPromoterExtraction(HttpSession session,
				String fileName,
				boolean runningMeme,
				GeneListAnalysis myGeneListAnalysis) {

                log = Logger.getRootLogger();

		this.session = session;
		this.fileName = fileName;
		this.runningMeme = runningMeme;
		this.myGeneListAnalysis = myGeneListAnalysis;

		this.geneArray = ((GeneList) session.getAttribute("selectedGeneList")).getGenes();
	        this.userLoggedIn = (User) session.getAttribute("userLoggedIn");
		this.dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
        	this.mainURL = (String) session.getAttribute("mainURL");

        }

	public void run() throws RuntimeException {

	        log.debug("Starting run method of AsyncPromoterExtraction " );
		Thread thisThread = Thread.currentThread();
		Email myEmail = new Email();
		myEmail.setTo(userLoggedIn.getEmail());

		String mainContent = userLoggedIn.getFormal_name() + ",\n\n" + 	
				"Thank you for using the PhenoGen Informatics website.  "+
				"The upstream sequence extraction process called '"+
				myGeneListAnalysis.getDescription() + "' that you initiated ";

		try {
			String geneListOrganism = myGeneListAnalysis.getAnalysisGeneList().getOrganism();
			log.debug("geneListOrganism = "+geneListOrganism);

			CoreDriver coreDriver = null;

			String propertiesDir = (new File(dbPropertiesFile)).getParent() + "/";
			log.debug("propertiesDir = " + propertiesDir);
			if (geneListOrganism.equals("Mm")) {
                        	coreDriver = 
					CoreDriverFactory.createCoreDriver(
						propertiesDir + 
						"ensemblMouse.properties");
                	} else if (geneListOrganism.equals("Rn")) {
                        	coreDriver = 
					CoreDriverFactory.createCoreDriver(
						propertiesDir + 
						"ensemblRat.properties");
                	} else if (geneListOrganism.equals("Hs")) {
                        	coreDriver = 
					CoreDriverFactory.createCoreDriver(
						propertiesDir + 
						"ensemblHuman.properties");
                	}

			int upstreamLength = Integer.parseInt(myGeneListAnalysis.getThisParameter("Sequence Length"));

			log.debug("upstreamLength = "+upstreamLength);
                	//FileWriter outFile = new FileWriter(fileName);
                	//BufferedWriter bufferedWriter = new BufferedWriter(outFile);
                	BufferedWriter bufferedWriter = new FileHandler().getBufferedWriter(fileName);

        		boolean atLeastOneEnsemblIDFound = false;
			log.debug("geneArray len = "+geneArray.length);
        		for (int i = 0; i < geneArray.length; i++) {
                		List<org.ensembl.datamodel.Gene> genes = null;
                		//
                		// we want genes to be a "List" of "Genes", but 
				// if you fetch() using an Ensembl ID, you get back a "Gene",
                		// so that's why this is structured as so
                		//
                                //log.debug("before getGenes("+geneArray[i]+")");
                		if (!geneArray[i].startsWith("ENS")) {
                        		genes = coreDriver.getGeneAdaptor().fetchBySynonym(geneArray[i]);
                		} else {
                        		genes = new ArrayList<org.ensembl.datamodel.Gene>(1);
                        		genes.add(coreDriver.getGeneAdaptor().fetch(geneArray[i]));
                		}
                                //log.debug("after getGenes()");

                		//log.debug("size of genes = " + genes.size());
                		if (genes.size() > 0) {
                        		atLeastOneEnsemblIDFound = true;
                		}
                		for (int j = 0; j < genes.size(); j++) {
                                    if(genes.get(j)!=null){
                        		String geneAccession = 
						((org.ensembl.datamodel.Gene) genes.get(j)).
							getAccessionID();
                                        if(geneAccession!=null){
                                            org.ensembl.datamodel.Gene gene = 
                                                    coreDriver.getGeneAdaptor().fetch(geneAccession);
                                            if(gene!=null){
                                                /*log.debug("geneAccession = "+
                                                                geneAccession + 
                                                                ", gene= "+gene + 
                                                                ", geneLocation= "+
                                                                gene.getLocation());*/
                                                if(gene.getLocation()!=null){
                                                    //log.debug("before getSequence");
                                                    Sequence sequence = coreDriver.getSequenceAdaptor().fetch(
                                                                            gene.getLocation().
                                                                            transform(upstreamLength * -1,0));
                                                    //log.debug("after getSequence");
                                                    //
                                                    // Format the sequence into 80-character lines
                                                    //
                                                    
                                                    String newLine = "\n";
                                                    String promoterSequence = 
                                                            new ObjectHandler().getAsSeparatedString(
                                                                    sequence.getString().
                                                                            substring(0, upstreamLength), 
                                                                            80, newLine);
                                                    
                                                    bufferedWriter.write(">" + geneArray[i] + "|" + geneAccession);
                                                    bufferedWriter.write(promoterSequence);
                                                    //log.debug("after sequence written");
                                                }else{
                                                    log.debug("********************************\nERROR: NULL GENE LOCATATION\n");
                                                }
                                  
                                            }else{
                                                log.debug("********************************\nERROR: NULL GENE\n");
                                            }
                                            
                                        }else{
                                            log.debug("********************************\nERROR: NULL GENE ACCESSION\n");
                                        }
                                        //bufferedWriter.newLine();
                                     }else{
                                         log.debug("********************************\nERROR: GENE@"+j+"\n");
                                     }
                                         
                		}
        		}
        		if (!atLeastOneEnsemblIDFound) {
                                log.debug("No ensembl id found");
                                bufferedWriter.write(">NoEnsemblIDs found for given gene list");
                                bufferedWriter.newLine();
        		}
        		bufferedWriter.close();

			String successContent = mainContent + "has completed.  " +
						"You may now view the results on the website at " +
						 mainURL + ". ";
			myEmail.setSubject("Upstream extraction process has completed"); 
                	myEmail.setContent(successContent);

		        Connection conn = new PropertiesConnection().getConnection(dbPropertiesFile);

			try {
				if (!runningMeme) {
					myGeneListAnalysis.createGeneListAnalysis(conn);
					myGeneListAnalysis.updateVisible(conn);
       	                		myEmail.sendEmail();
				}
			} catch (SendFailedException e) {
				log.error("in exception of AsyncPromoterExtraction while sending email", e);
			} catch (SQLException e) {
				log.error("in exception of AsyncPromoterExtraction while getting promoter id", e);
			}

			conn.close();
		} catch (Exception e) {
			log.error("in Exception of AsyncPromoterExtraction", e);
			String errorContent = mainContent + "was not completed successfully.  "+
					"The system administrator has been notified of the error. " +
					"\n" +
					"You will be contacted via email once the problem is resolved.";

			String adminErrorContent = "The following email was sent to " + userLoggedIn.getEmail() + ":\n" +
						errorContent + "\n" +
						"The file is " + fileName;
                        
                        String error=e.getMessage();
                        StackTraceElement[] st;
                        st = e.getStackTrace();
                        for(int i=0;i<st.length;i++){
                            error=error+"\n"+st[i].getClassName()+"."+st[i].getMethodName()+"("+st[i].getFileName()+":"+st[i].getLineNumber()+")";
                        }
                        
                        adminErrorContent=adminErrorContent+"\nStack Trace:\n"+error;

			myEmail.setSubject("Promoter Extraction process had errors"); 
	                try {
                		myEmail.setContent(errorContent);
       	                	myEmail.sendEmail();
				log.debug("just sent email to user notifying of extraction errors");
                		myEmail.setContent(adminErrorContent);
       	                	myEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
				log.debug("just sent email to administrator notifying of extraction errors");
			} catch (MessagingException e2) {
				log.error("in exception of AsyncPromoterExtraction while sending email", e2);
				throw new RuntimeException();
			}
			throw new RuntimeException();
		} finally {
	        	log.debug("executing finally clause in AsyncPromoterExtraction");
		}
	        log.debug("done with AsyncPromoterExtraction run method");
	}
}
 
