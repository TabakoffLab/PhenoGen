package edu.ucdenver.ccp.PhenoGen.driver;

import java.util.*;
import java.io.*;
import java.sql.*;
import java.lang.*;
import edu.ucdenver.ccp.PhenoGen.data.*;
import edu.ucdenver.ccp.PhenoGen.web.mail.*;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.ObjectHandler;


/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling calls to 'R'.
 *  @author  Cheryl Hornbaker
 */

public class R_session {
	private String rFunctionDir;
	String [] rErrorMsg = null;
	String [] functionArgs = null;
	String rFunction = "";
        String [] envVar=new String[0];

	private Logger log = null;
	private Debugger myDebugger = new Debugger();

        public R_session() {
                log = Logger.getRootLogger();
        }

	public void setRFunctionDir(String inString) {
		this.rFunctionDir = inString;
	}

	public String getRFunctionDir() {
		return rFunctionDir; 
	}

        public void setREnvVar(String inString) {
		this.envVar = new String[0];
                if(!inString.isEmpty()){
                    File renv=new File(inString+"rEnv.txt");
                    if(renv.exists()){
                        String[] contents;
                        FileHandler fh=new FileHandler();
                        try{
                            contents=fh.getFileContents(renv);
                            if(contents.length>0){
                                this.envVar=contents;
                            }
                        }catch(IOException e){
                            
                        }
                    }
                }
	}

        /**
         * Creates a file to call R.
         * @param rFunctionPath	the directory that contains the R source code
         * @param functionName       the R function to be executed
         * @param functionArgs       the set of arguments 
         * @param sessionPath       the working directory 
         * @param file_number       the output file name
	 * @throws RException	if an R error occurs
         * @return 	an array containing errors generated by calling R, if any
         */
	public String[] callR(String rFunctionPath, 
				String functionName, 
				String[] functionArgs, 
				String sessionPath,
				int file_number) throws RException {

		String rFile =	"'" + 
				rFunctionPath + 
				functionName + 
				".R'"; 
                
                this.setREnvVar(rFunctionPath);

		String tempRFilename = sessionPath + "call_" + functionName;
		//log.debug("tempRFilename = "+tempRFilename);
		if (file_number != -99) {
			tempRFilename = tempRFilename + "_" + file_number;
		}
		Email myAdminEmail = new Email();
		try {
			//File tempRFile = new File(tempRFilename);
			//tempRFile.createNewFile();
	
			BufferedWriter callRWriter = 
				new FileHandler().getBufferedWriter(tempRFilename);
			//(new FileWriter(tempRFile), 10000);
			//
			// create the file that will call R
			//
			callRWriter.write("source(" + rFile + ")\n");
			callRWriter.newLine();
			String parameters = functionName + "(" + new ObjectHandler().getAsSeparatedString(functionArgs, ", ") + ")";
			callRWriter.write(parameters);
			callRWriter.newLine();
			callRWriter.flush();
			callRWriter.close();
                        String[] errorMsg=null;
                        
                        errorMsg = runR(tempRFilename, sessionPath,rFunctionPath);
                       
                        
	
                        if (errorMsg != null) {
                                //log.debug("there is an error in the R process in callR.  It is: "); myDebugger.print(errorMsg);
                                //throw new IOException("Error in R process");
                                String fullerrmsg="";
                                for(int i=0;i<errorMsg.length;i++){
                                    fullerrmsg=fullerrmsg+errorMsg[i];
                                }
                                
                                String fullOutput="";
                                File outFile=new File(tempRFilename+".Rout");
                                String[] outputContents=new String[0];
                                try{
                                    outputContents=new FileHandler().getFileContents(outFile);
                                }catch(IOException ioe){
                                    
                                }
                                for(int i=0;i<outputContents.length;i++){
                                    fullOutput=fullOutput+outputContents[i]+"\n";
                                }        
                        	myAdminEmail.setSubject("Exception thrown in R_session");
                        	myAdminEmail.setContent("There was an error while running "+
							tempRFilename + "\n\nFull Error Message:\n\n"+fullerrmsg+"\n\nFull Output:\n"+fullOutput); 
                        	try {
                                	myAdminEmail.sendEmailToAdministrator("");
					return errorMsg;
                        	} catch (Exception e) {
					log.error("error sending message", e);
					throw new RException("problem running R process.  Error:\n"+fullerrmsg+"\n\nFull Output:\n"+fullOutput);
                        	}
                                
                        } 
		} catch (Exception e) {
			log.error("In Exception of R_session", e);
                        String fullerrmsg=e.getMessage();
                        StackTraceElement[] tmpEx=e.getStackTrace();
                        for(int i=0;i<tmpEx.length;i++){
                                    fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                        }
                        String fullOutput="";
                        File outFile=new File(tempRFilename+".Rout");
                        String[] outputContents=new String[0];
                        try{
                                outputContents=new FileHandler().getFileContents(outFile);
                        }catch(IOException ioe){
                                    
                        }
                        for(int i=0;i<outputContents.length;i++){
                                fullOutput=fullOutput+outputContents[i]+"\n";
                        }
                        myAdminEmail.setSubject("Exception thrown in R_session");
                        myAdminEmail.setContent("There was an error while running "+
						tempRFilename + "\n\nFull Exception:\n"+fullerrmsg+"\n\nFull Output:\n"+fullOutput); 
                        try {
                                myAdminEmail.sendEmailToAdministrator("");
                        } catch (Exception mailException) {
				log.error("error sending message", mailException);
				throw new RuntimeException();
                        }
			throw new RException(e.getMessage());
		}
		return (String[]) null;
	}
        


        /**
         * Creates a file that calls R.
         * @param callRFileName	the name of the file that contains the R call
         * @param sessionPath       the working directory for the R process
	 * @throws RException	if an R error occurs
         * @return 	an array containing errors generated by calling R, if any
         */
	public String[] runR(String callRFileName, 
				String sessionPath,String rFunctionPath) throws RException {
                String[] errorMsg=null;
		try {
			// execute process 
                        log.debug("executing script which calls R. sessionPath = " + sessionPath +
                                ", callRFileName = " + callRFileName);
                        String[] argtmp=null;
                        argtmp=new String[]{"R", "CMD", "BATCH", "--no-save", "--no-restore", callRFileName};
                        
                        int envLen=0;
                        if(this.envVar.length>0){
                            envLen=this.envVar.length;
                        }
                        String[] finalEnvVar=new String[envLen+1];
                        finalEnvVar[0]="R_PROFILE_USER="+rFunctionPath+".Rprofile";
                        for(int i=1;i<=envLen;i++){
                            finalEnvVar[i]=this.envVar[i-1];
                        }
                        
			Process p = Runtime.getRuntime().exec(argtmp, finalEnvVar, new File(sessionPath));
	
			int wait = p.waitFor();
			log.debug("in runR.  process completed. exit value is "+wait);
			//
			// There's some problem
			//
			if (wait != 0) {
				new FileHandler().copyFile(new File(callRFileName + ".Rout"), new File(callRFileName + ".Rout.Error"));
                                 errorMsg= new FileHandler().checkFileForErrors(
                                    new File(callRFileName + ".Rout"), "Error", "Execution halted");
                                 if(errorMsg==null){
                                     errorMsg=new String[1];
                                     errorMsg[0]="exit value was not 0.  value was "+wait;
                                 }
                                 
                                log.debug("there is an error in the R process in runR. errorMsg here = "); myDebugger.print(errorMsg);
				//throw new RException("problem running R process.  Exit value was not 0.");
			}

                        
                        /*if (errorMsg != null) {
				new FileHandler().copyFile(new File(callRFileName + ".Rout"), new File(callRFileName + ".Rout.Error"));
                                
                                //throw new IOException("Error in R process");
				return errorMsg;
                        } */

		} catch (Exception e) {
			log.error("In Exception of R_session", e);
			throw new RException(e.getMessage());
		}
		return errorMsg;
	}
}
 
