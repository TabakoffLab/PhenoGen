package edu.ucdenver.ccp.PhenoGen.tools.analysis;



import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.mail.MessagingException;
import javax.mail.SendFailedException;

import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.Dataset.DatasetVersion;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.driver.ExecHandler;
import edu.ucdenver.ccp.PhenoGen.driver.ExecException;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.driver.RException;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;
import au.com.forward.threads.ThreadInterruptedException;
import au.com.forward.threads.ThreadException;

/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncParallelAffyPowerToolsWorker implements Runnable {

	private Logger log = null;
        private String aptDir="";
        private String[] functionArgs=new String[0];
        private String[] envVariables=new String[0];
        private String filename="";

	public AsyncParallelAffyPowerToolsWorker(String aptDir,String[] functionArgs,String[] envVariables,String filename) {

                log = Logger.getRootLogger();
                this.aptDir=aptDir;
                this.functionArgs=functionArgs;
                this.envVariables=envVariables;
                this.filename=filename;
                
        }


	public void run() throws RuntimeException {

		Thread thisThread = Thread.currentThread();
	        log.debug("Starting run method of AsyncAffyPowerTools. thisThread = " +thisThread.getName());
		
                        //run single file
                        //run script to generate job list
                        //read job list
                        //create Queue with jobs
                        //create a group of threads equal to number of proc to use
                        //execute them
                        //run script to merge all
			ExecHandler myExecHandler = new ExecHandler(aptDir, 
                        	functionArgs,
				envVariables,
                        	filename);
                        try{
			log.debug("starting APT exec process");
			myExecHandler.runExec();
			log.debug("just finished APT exec process");
                        }catch(ExecException e){
                            log.error("Error running Exec Thread:"+thisThread.getName(),e);
                        }
        }
}
 
