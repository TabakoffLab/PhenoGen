package edu.ucdenver.ccp.PhenoGen.web;

import java.io.File;

import java.sql.Connection;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.List;

import javax.mail.MessagingException;
import javax.mail.SendFailedException;
import javax.servlet.http.HttpServletRequest;

import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.Download;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.data.internal.Resource;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncResourceDownload implements Runnable{
	
  	private Logger log=null;
	private FileHandler myFileHandler = new FileHandler();
	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();
	private User userLoggedIn       = null;
	private Dataset selectedDataset = null;
	private Resource thisResource = null;
	private String type = null;
	private ArrayList<String> checkedList = null;
	private Connection conn;
	
	private String scheme = null;
	private String serverName = null;
	private String contextPath = null;
	private String downloadDir = null;
	private String downloadURL = null;
	private HttpServletRequest request = null;
	
	
	public AsyncResourceDownload(HttpServletRequest request, Resource thisResource, String type, ArrayList<String> checkedList) {

		log = Logger.getRootLogger();
		log.debug("just instantiated AsyncResourceDownload");

		this.thisResource = thisResource;
		this.type = type;
		this.selectedDataset = (Dataset) request.getSession().getAttribute("selectedDataset");
		this.userLoggedIn = (User) request.getSession().getAttribute("userLoggedIn");
		this.conn = (Connection) request.getSession().getAttribute("dbConn");
		this.downloadURL = (String) request.getSession().getAttribute("downloadURL");
		this.checkedList = checkedList;
		this.scheme = (String) request.getScheme();
		this.serverName = (String) request.getServerName();
		this.contextPath = (String) request.getContextPath();
                if(this.contextPath.startsWith("//")){
                    this.contextPath=this.contextPath.substring(1);
                }
		this.request = request;

		//log.debug("checkedList = "); myDebugger.print(checkedList);
	}
	
	@Override
	public void run() throws RuntimeException {
		log.debug("in AsyncResourceDownload run");
		AsyncFileDownload thisFileDownload = new AsyncFileDownload(request, checkedList, thisResource.getDataset().getDownloadsDir(), thisResource.getDataset().getNameNoSpaces() +"_"+ type + "_Resources",this.userLoggedIn, false);
		Thread thread = new Thread(thisFileDownload);
		thread.start();
		try {
			log.debug("waiting to join AsyncFileDownload");
			thread.join();
			log.debug("just finished waiting to join AsyncFileDownload");
			List<String> fileList = thisFileDownload.getZipFileList(); 
			//log.debug("fileList = "); myDebugger.print(fileList);
			sendEmail(userLoggedIn, fileList);
		} catch (InterruptedException e) {
			log.debug("send an email to User saying there is an error, and also one to Administrator");	
			Email myEmail = new Email();
			myEmail.setSubject("Error Downloading PhenoGen Resource");
			StringBuffer emailBody = new StringBuffer();
			emailBody.append("An error occurred in downloading " + selectedDataset.getName() + "\n\n");
			emailBody.append("The System Administrator has been notified." + "\n\n");
			myEmail.setContent(String.valueOf(emailBody));
			myEmail.setTo(userLoggedIn.getEmail());
			emailBody.append("This email was sent to " + userLoggedIn.getFull_name() + "\n\n");
			try {
				myEmail.sendEmailToAdministrator((String) request.getSession().getAttribute("adminEmail"));
			} catch (Exception e2) {
				throw new RuntimeException(e2);
			}
		}
	}
	
	public void sendEmail(User user, List<String> fileList) {
		log.debug("in AsyncResourceDownload.sendEmail");
		int totalNumberOfFiles = fileList.size();
		Email myEmail = new Email();
		StringBuffer emailBody = new StringBuffer();
		emailBody.append(user.getFull_name() +", \n\n");
		emailBody.append("Your request is ready for download. ");
		myEmail.setSubject("Your PhenoGen Resource Download");
		myEmail.setTo(user.getEmail());
		try {
			int currentFileNumber = 1;
			for (String fileName : fileList) {
				String downloadLink = this.scheme + "://" + this.serverName + this.contextPath + fileName + "\n\n";
				Download thisDownload = new Download();
				thisDownload.setURL(downloadLink);
				int download_id = thisDownload.createDownload(conn);
				String emailLink = downloadURL + "?id=" + download_id + "\n\n";
 
				emailBody.append("This is part "+ 
						currentFileNumber+ " of " + 
						totalNumberOfFiles + ".\n\n");
				emailBody.append(emailLink);
				currentFileNumber++;
			}
			emailBody.append("The download link(s) will be active for 30 days. \n\n");
			emailBody.append("Thank you for using PhenoGen. \n\n");
			myEmail.setContent(String.valueOf(emailBody));
			myEmail.sendEmail();
		} catch (SQLException e) {
			log.debug("Exception creating download record", e);
			throw new RuntimeException(e);
		} catch (SendFailedException e) {
			log.debug("Exception sending email", e);
			throw new RuntimeException();
		} catch (MessagingException e) {
			log.debug("Exception sending email", e);
			throw new RuntimeException();
		}
	}
	

}
