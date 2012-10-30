package edu.ucdenver.ccp.PhenoGen.web;

import java.io.File;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.HDF5.PhenoGen_HDF5_File;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncFileDownload implements Runnable{
	
  	private Logger log=null;
	private FileHandler myFileHandler = new FileHandler();
	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();
	private ArrayList<String> checkedList = null;
	
	private String downloadDir = null;
	private String fileName = null;
	private boolean zipIt = true;
        private boolean perFile=false;
	private List<String> zipFileList = null;
        private User userLoggedIn=null;
        private HttpServletRequest request;
	
	public AsyncFileDownload(HttpServletRequest request, ArrayList<String> checkedList, String downloadDir, String fileName,User userLoggedIn, boolean zipIt) {

		log = Logger.getRootLogger();
		log.debug("just instantiated AsyncFileDownload");
		this.request=request;
		this.checkedList = checkedList;
		this.downloadDir = downloadDir;
		this.fileName = fileName;
		this.zipIt = zipIt;
                this.userLoggedIn=userLoggedIn;
		myFileHandler.createDir(downloadDir);
		 
		//log.debug("checkedList = "); myDebugger.print(checkedList);
	}
	
        public void setZipFileList(List<String> inList) {
                this.zipFileList = inList;
        }

        public List<String> getZipFileList() {
                return zipFileList;
        }
	@Override
	public void run() throws RuntimeException {
		log.debug("in run of AsyncFileDownload");
		String theTime = new ObjectHandler().getNowAsMMddyyyy_HHmmss();
		List<String> zipFileList = new ArrayList<String>();
		if (checkedList != null && checkedList.size() > 0) {
			log.debug("checkedList is not null");
			if (zipIt) {
				String [] fileLists = myObjectHandler.getAsArray(checkedList, String.class);
                                List<String[]> chunks = splitupIntoChunks(fileLists);
                                int fileCtr = 1;
                                for (String[] fileList : chunks) {
                                        String fileToDownload = fileName + "_" + theTime + "Part" + fileCtr + ".zip";
                                        String zipFileName = downloadDir + fileToDownload;
                                        String relativeFileName = myFileHandler.getPathFromUserFiles(downloadDir)  + fileToDownload;  				
                                        log.debug("zipFileName = "+zipFileName);
                                        //log.debug("downloadDir = " +downloadDir);
                                        //log.debug("relativeFileName = " +relativeFileName);

                                        createZipFile(fileList,  zipFileName);
                                        zipFileList.add(relativeFileName);
                                        fileCtr++;
                                }
                                
			} else {
				log.debug("just before setting fileList to checkedList in AsyncFileDownload. it is: "); myDebugger.print(checkedList);
				for (String fileName : checkedList) {
					String relativeFileName = myFileHandler.getPathFromUserFiles(fileName); 
					zipFileList.add(relativeFileName);
				}
			}
			log.debug("just before setting fileList in AsyncFileDownload. it is: "); myDebugger.print(zipFileList);
			setZipFileList(zipFileList);
			log.debug("after setting fileList in AsyncFileDownload");
		}
	}
	
	/**
	 * Takes the complete file list and splits it up into a List of String arrays containing the 
	 * names of files whose total size is less than 500Mb before compression. 
	 * 
	 * @param fileList
	 * @return a List of String arrays containing the names of the files broken into chunks of 500Mb
	 */
	public List<String[]> splitupIntoChunks(String[] fileList){
		log.debug("in AsyncFileDownload.splitupIntoChunks");
		long           totalBytes      = 0L;
		List<String[]> chunks           = new ArrayList<String[]>();
		List<String>   holder          = new ArrayList<String>();
		
		for (int i=0; i<fileList.length; i++) {
			File f = new File(fileList[i]);
                        boolean success=true;
                        if(!f.exists()){
                            try{
                                String path=fileList[i].substring(0,fileList[i].lastIndexOf("/"));
                                path=path+"/Affy.NormVer.h5";
                                System.out.println("Affy hdf PATH:"+path);
                                File h5file=new File(path);
                                if(h5file.exists()){
                                    PhenoGen_HDF5_File hdf=new PhenoGen_HDF5_File(path);
                                    String version=fileList[i].substring(fileList[i].lastIndexOf("/")+1);
                                    version=version.substring(0,version.indexOf("_"));
                                    System.out.println("Version+"+version);
                                    hdf.openVersion(version);
                                    hdf.outputCSV(version,fileList[i]);
                                    hdf.close();
                                    f=new File(fileList[i]);
                                }else{
                                    throw new Exception();
                                }
                            }catch(Exception e){
                                success=false;
                                e.printStackTrace(System.out);
                                log.debug("send an email to User saying there is an error, and also one to Administrator");	
                                Email myEmail = new Email();
                                myEmail.setSubject("Error Downloading PhenoGen Dataset");
                                StringBuffer emailBody = new StringBuffer();
                                emailBody.append("An error occurred in downloading " + fileList[i] + "\n\n");
                                emailBody.append("The System Administrator has been notified." + "\n\n");
                                myEmail.setContent(String.valueOf(emailBody));
                                myEmail.setTo(userLoggedIn.getEmail());
                                emailBody.append("This email was sent to " + userLoggedIn.getFull_name() + "\n\n");
                                try {
                                        myEmail.sendEmailToAdministrator((String) request.getSession().getAttribute("adminEmail"));
                                } catch (Exception e2) {
                                        
                                }
                            }
                        }
                        if(success){
                            totalBytes += f.length();

                            holder.add(fileList[i]);
                            //log.debug("totalBytes = "+totalBytes);
                            // If total size is over 500 Mb, split it up

                            if (totalBytes >= 1000000000){
                                    log.debug("total size is over 500Mb");

                                    String str [] = (String []) holder.toArray (new String [holder.size ()]);
                                    chunks.add(str);

                                    holder.clear();
                                    totalBytes = 0L;
                            }

                            if (i==fileList.length-1){
                                    String str [] = (String []) holder.toArray (new String [holder.size ()]);
                                    chunks.add(str);
                            }
                        }
		}
		return chunks;
	}
	
	
	public void createZipFile(String[]fileList, String zipFileName){
		log.debug("in AsyncFileDownload.createZipFile");
		try {
			myFileHandler.createZipFile(fileList, zipFileName);
		} catch (Exception e) {
			log.debug("Exception creating zip file", e);
			throw new RuntimeException();
		}
	}
	
}
