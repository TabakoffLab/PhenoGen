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
import edu.ucdenver.ccp.PhenoGen.driver.ExecHandler;
import edu.ucdenver.ccp.PhenoGen.driver.ExecException;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;
import edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.PropertiesConnection;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier;

import org.ensembl.datamodel.Sequence;
import org.ensembl.driver.CoreDriver;
import org.ensembl.driver.CoreDriverFactory;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;
import java.util.Set;
import javax.sql.DataSource;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncPromoterExtraction implements Runnable{

	private Logger log = null;
	private HttpSession session = null;
	private String fileName = null;
	private String[] geneArray = null;
	private User userLoggedIn = null;
	private String dbPropertiesFile = null;
        private String ensemblDBPropertiesFile=null;
	private GeneListAnalysis myGeneListAnalysis = null;
	private String mainURL = "";
	private boolean runningMeme = true;
        private DataSource pool=null;
        private IDecoderClient myIDecoderClient= null;
        private Identifier myIdentifier=null;
        private String geneFile="";
        private String perlEnvVar=null;
        private String perlDir=null;
        private String geneDir=null;

	public AsyncPromoterExtraction(HttpSession session,
				String fileName,
				boolean runningMeme,
				GeneListAnalysis myGeneListAnalysis) {

                log = Logger.getRootLogger();

		this.session = session;
		this.fileName = fileName;
                this.userLoggedIn = (User) session.getAttribute("userLoggedIn");
            
                this.geneDir= fileName.substring(0, fileName.lastIndexOf("/")+1);
                this.geneFile=geneDir+"genelist.txt";
		this.runningMeme = runningMeme;
		this.myGeneListAnalysis = myGeneListAnalysis;

		this.geneArray = ((GeneList) session.getAttribute("selectedGeneList")).getGenes();
                this.perlDir = (String) session.getAttribute("perlDir") + "scripts/";
	        this.perlEnvVar=(String)session.getAttribute("perlEnvVar");
		this.dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
                this.ensemblDBPropertiesFile = (String)session.getAttribute("ensDbPropertiesFile");
        	this.mainURL = (String) session.getAttribute("mainURL");
                this.pool = (DataSource) session.getAttribute("dbPool");
                this.myIDecoderClient=new IDecoderClient();
                this.myIdentifier = new Identifier();
        }

	public void run() throws RuntimeException {
                boolean atLeastOneEnsemblIDFound=false;
	        log.debug("Starting run method of AsyncPromoterExtraction " );
		Thread thisThread = Thread.currentThread();
		Email myEmail = new Email();
		myEmail.setTo(userLoggedIn.getEmail());

		String mainContent = userLoggedIn.getFormal_name() + ",\n\n" + 	
				"Thank you for using the PhenoGen Informatics website.  "+
				"The upstream sequence extraction process called '"+
				myGeneListAnalysis.getDescription() + "' that you initiated ";
                String[] targets = new String[] {"Ensembl ID"};
                HashMap<String,String> included=new HashMap<String,String>();
		try {
			String geneListOrganism = myGeneListAnalysis.getAnalysisGeneList().getOrganism();
                        int id=((GeneList) session.getAttribute("selectedGeneList")).getGene_list_id();
			Set iDecoderSet = myIDecoderClient.getIdentifiersByInputIDAndTarget(id, targets, pool);
                        ArrayList<String> noIDecoderList = new ArrayList<String>();
                        if(iDecoderSet.size()>0){
                                Iterator itr = iDecoderSet.iterator();
                                ArrayList<Identifier> altDecoderList=new ArrayList<Identifier>();
                                while (itr.hasNext()) {
                                        Identifier thisIdentifier = (Identifier) itr.next();
                                        if (thisIdentifier.getRelatedIdentifiers().size() == 0) {
                                                Set tmp=myIDecoderClient.getIdentifiersByInputID(thisIdentifier.getIdentifier(),geneListOrganism,targets, pool);
                                                Iterator tmpItr=tmp.iterator();
                                                while (tmpItr.hasNext()){
                                                        Identifier thisId = (Identifier) tmpItr.next();
                                                        if (thisId.getRelatedIdentifiers().size() != 0) {
                                                                //thisId.setLowerCaseIdentifier();
                                                                altDecoderList.add(thisId);
                                                        }
                                                }
                                                noIDecoderList.add(thisIdentifier.getIdentifier());
                                        }
                                }
                                for (int i=0; i<noIDecoderList.size(); i++) {
                                        iDecoderSet.remove(new Identifier((String) noIDecoderList.get(i)));
                                }
                                for (int i=0; i<altDecoderList.size(); i++) {
                                        iDecoderSet.add(altDecoderList.get(i));
                                }
                        }else{
                                iDecoderSet = myIDecoderClient.getIdentifiersByInputIDAndTargetCaseInsensitive(id, targets, pool);
                                //log.debug("iDecoderSet = "); myDebugger.print(iDecoderSet);
                                if(iDecoderSet.size()>0){
                                        Iterator itr = iDecoderSet.iterator();
                                        while (itr.hasNext()) {
                                                Identifier thisIdentifier = (Identifier) itr.next();
                                                //thisIdentifier.setLowerCaseIdentifier();
                                                //log.debug("******ID"+thisIdentifier.getIdentifier());
                                                if (thisIdentifier.getRelatedIdentifiers().size() == 0) {
                                                        log.debug("remove id:"+thisIdentifier.getIdentifier());
                                                        noIDecoderList.add(thisIdentifier.getIdentifier());
                                                }
                                        }
                                        for (int i=0; i<noIDecoderList.size(); i++) {
                                                iDecoderSet.remove(new Identifier((String) noIDecoderList.get(i)));
                                        }
                                }
                        }
                        for (int i=0; i<geneArray.length; i++) {
                            Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(geneArray[i], iDecoderSet);
                            if(thisIdentifier ==null){
                                    thisIdentifier = myIdentifier.getIdentifierFromSetIgnoreCase(geneArray[i], iDecoderSet);
                            }
                            if (thisIdentifier != null) {
				Set ensemblIDs = myIDecoderClient.getIdentifiersForTargetForOneID(thisIdentifier.getTargetHashMap(),new String[] {"Ensembl ID"});
                                Iterator ite=ensemblIDs.iterator();
                                while(ite.hasNext()){
                                    Identifier cur=(Identifier)ite.next();
                                    String tmpID=cur.getIdentifier();
                                    if(tmpID.contains("ENSMUSG")||tmpID.contains("ENSRNOG")){
                                        atLeastOneEnsemblIDFound=true;
                                        if(included.containsKey(tmpID)){
                                            String tmp=included.get(tmpID);
                                            tmp=tmp+","+geneArray[i];
                                            included.put(tmpID, tmp);
                                        }else{
                                            included.put(tmpID, geneArray[i]);
                                        }
                                    }
                                }
                            }
                        }
			int upstreamLength = Integer.parseInt(myGeneListAnalysis.getThisParameter("Sequence Length"));
                	BufferedWriter bufferedWriter = new FileHandler().getBufferedWriter(geneFile);
                        if(atLeastOneEnsemblIDFound){
                            Iterator itr2=included.keySet().iterator();
                            while(itr2.hasNext()){
                                String ens=(String)itr2.next();
                                String glID=included.get(ens);
                                bufferedWriter.write(ens+";"+glID);
                                bufferedWriter.newLine();
                            }
                        }
        		bufferedWriter.close();
                        if(atLeastOneEnsemblIDFound){
                            File ensPropertiesFile = new File(ensemblDBPropertiesFile);
                            Properties myENSProperties = new Properties();
                            myENSProperties.load(new FileInputStream(ensPropertiesFile));
                            String ensHost=myENSProperties.getProperty("HOST");
                            String ensPort=myENSProperties.getProperty("PORT");
                            String ensUser=myENSProperties.getProperty("USER");
                            String ensPassword=myENSProperties.getProperty("PASSWORD");
                            //construct perl Args
                            String[] perlArgs = new String[10];
                            perlArgs[0] = "perl";
                            perlArgs[1] = perlDir + "readEnsemblUpstreamSeq.pl";
                            perlArgs[2] = geneFile;
                            perlArgs[3] = fileName;
                            perlArgs[4] = "gene";
                            perlArgs[5] = Integer.toString(upstreamLength);
                            perlArgs[6] = ensHost;
                            perlArgs[7] = ensPort;
                            perlArgs[8] = ensUser;
                            perlArgs[9] = ensPassword;


                            //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
                            String[] envVar=perlEnvVar.split(",");

                            for (int i = 0; i < envVar.length; i++) {
                                log.debug(i + " EnvVar::" + envVar[i]);
                                /*if(envVar[i].startsWith("PERL5LIB")&&organism.equals("Mm")){
                                    envVar[i]=envVar[i].replaceAll("ensembl_ucsc", "ensembl_ucsc_old");
                                }*/
                            }


                            //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
                            ExecHandler myExec_session = new ExecHandler(perlDir, perlArgs, envVar, geneDir);
                            boolean exception = false;
                            try {

                                myExec_session.runExec();

                            } catch (ExecException e) {
                                exception=true;
                                log.error("In Exception of run writeXML_RegionView.pl Exec_session", e);

                                Email myAdminEmail = new Email();
                                myAdminEmail.setSubject("Exception thrown in Exec_session");
                                myAdminEmail.setContent("There was an error while running "
                                        + perlArgs[1] + " (" + perlArgs[2] +" , "+perlArgs[3]+" , "+perlArgs[4]+" )\n\n"+myExec_session.getErrors());
                                try {
                                    myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
                                } catch (Exception mailException) {
                                    log.error("error sending message", mailException);
                                    try {
                                        myAdminEmail.sendEmailToAdministrator("");
                                    } catch (Exception mailException1) {
                                        //throw new RuntimeException();
                                    }
                                }
                            }
                        
                        }else{
                                log.debug("No ensembl id found");
                                bufferedWriter.write(">NoEnsemblIDs found for given gene list");
                                bufferedWriter.newLine();
        		}
                        
                        
                        
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
 
