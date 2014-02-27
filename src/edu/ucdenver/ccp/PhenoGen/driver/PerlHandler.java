package edu.ucdenver.ccp.PhenoGen.driver;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.Debugger;

/* for logging messages */
import org.apache.log4j.Logger;

public class PerlHandler {

	private Logger log = null;
	private String perlFunctionPath = null;
	private String[] functionArgs = null;
	private String filePrefix = null;
	private String perlErrors = null;

	public PerlHandler(String perlFunctionPath, 
				String[] functionArgs, 
				String filePrefix) {

                log = Logger.getRootLogger();

		this.perlFunctionPath = perlFunctionPath;
		this.functionArgs = functionArgs;
		this.filePrefix = filePrefix; 
        }

	public void setErrors(String inString) {
		this.perlErrors = inString;
	} 

	public String getErrors() {
		return perlErrors;
	} 

	public void runPerl() throws PerlException {

	        log.debug("Starting run method of PerlHandler. filePrefix = " + filePrefix + ", functionArgs[0] = "+functionArgs[0]);
		new Debugger().print(System.getenv());

		try {
	                Process p = Runtime.getRuntime().exec(
				functionArgs, 
				new String[0],
				new File(perlFunctionPath));
	
			InputStream inputStream = p.getInputStream();
			InputStream errorStream = p.getErrorStream();

			String errorFileName = filePrefix +"_perlErrors.txt";
			String inputFileName = filePrefix +"_perlInput.txt";

                	File errorFile = new File(errorFileName);
	                File inputFile = new File(inputFileName);

			FileOutputStream fosErrors = new FileOutputStream(errorFileName); 
			FileOutputStream fosInput = new FileOutputStream(inputFileName);
			

                        int c;
                        while((c = inputStream.read()) != -1) {
                                fosInput.write(c);
                        }
                        while((c = errorStream.read()) != -1) {
                                fosErrors.write(c);
                        }
                        fosInput.close();
                        fosErrors.close();

			int wait = p.waitFor();

			log.debug("in PerlHandler.  process completed for: " + filePrefix + ". exit value is "+wait);
			//
			// There's some problem
			//
			if (wait != 0) {
				throw new PerlException("problem running Perl process.  Exit value was not 0.");
			}

                	String[] errorFileContents = null;
                	String[] inputFileContents = null;
                	perlErrors = "";
			FileHandler myFileHandler = new FileHandler();

                	if (errorFile.exists() && errorFile.length() > 0) {
                        	errorFileContents = myFileHandler.getFileContents(errorFile);
                                if(errorFileContents.length>0 && !errorFileContents[0].equals("")){
                                    inputFileContents = myFileHandler.getFileContents(inputFile);
                                    for (int i=0; i<errorFileContents.length; i++) {
                                            perlErrors = perlErrors + "\n" + errorFileContents[i];
                                    }
                                    perlErrors = perlErrors + "\n\n" + 
                                            "The following information may be useful in determining "+
                                             "where the problem occurred:\n";
                                    for (int i=0; i<inputFileContents.length; i++) {
                                            perlErrors = perlErrors + "\n" + inputFileContents[i];
                                    }
                                }
                	} else {
                        	log.info("No Perl errors found");
                	}

			setErrors(perlErrors);

			if (perlErrors.length() > 0) {
				log.debug("got error running perl process");
				throw new PerlException("Error while running perl process");
			}

		} catch(InterruptedException e) {
			log.error("in Interrupted exception of PerlHandler while executing perl", e);
			throw new PerlException();
		} catch(IOException e) {
			log.error("in IO exception of PerlHandler while executing perl", e);
			throw new PerlException();
		} catch(Exception e) {
			log.error("in exception of PerlHandler while executing perl", e);
			throw new PerlException();
		}
	}
}
 
