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
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.tools.analysis.Statistic;
import edu.ucdenver.ccp.PhenoGen.driver.RException;
import edu.ucdenver.ccp.PhenoGen.driver.R_session;
import edu.ucdenver.ccp.util.ObjectHandler;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;
import au.com.forward.threads.ThreadInterruptedException;
import au.com.forward.threads.ThreadException;
import java.io.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.logging.Level;

import org.apache.log4j.Logger;


/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncGeneDataThread extends Thread {
        private String[] rErrorMsg = null;
        Statistic myStatistic=null;
        HttpSession session=null;
        private Logger log = null;
        private String perlDir = "", fullPath = "";
        private String rFunctDir = "";
        private String userFilesRoot = "";
        private String urlPrefix = "";
        private String perlEnvVar="";
        private String ucscDir="";
        private String bedDir="";
        private String ver="";
        private String genomeVer="";
        private Connection dbConn = null;
        String outputDir="";
        String pListFile="";
        boolean doneThread=false,pathReady=false;
        private GeneDataTools gdt;
        String chromosome="",panel="",myOrganism="Rn";
        int min=0,max=0,fullMin=0,fullMax=0,rnaDatasetID=0,arrayTypeID=0;
        double forwardPValueCutoff=0.01;

        
       
        
    public AsyncGeneDataThread(HttpSession inSession,GeneDataTools gdt,String chromosome,int min,int max,int fullmin,int fullmax,String panel,String myOrganism,String genomeVer,int rnaDatasetID,int arrayTypeID,double forwardPValueCutoff) {
                this.session = inSession;
                this.gdt=gdt;
                this.gdt.resetPathReady();
                this.pListFile=pListFile;
                
                this.chromosome=chromosome;
                this.panel=panel;
                this.min=min;
                this.max=max;
                this.fullMin=fullmin;
                this.fullMax=fullmax;
                this.arrayTypeID=arrayTypeID;
                this.rnaDatasetID=rnaDatasetID;
                this.myOrganism=myOrganism;
                this.forwardPValueCutoff=forwardPValueCutoff;
                this.genomeVer=genomeVer;
                log = Logger.getRootLogger();
                log.debug("in GeneDataTools.setSession");
                this.session = inSession;

                log.debug("AsyncGeneDataExpr Start");

                //this.selectedDataset = (Dataset) session.getAttribute("selectedDataset");
                //this.selectedDatasetVersion = (Dataset.DatasetVersion) session.getAttribute("selectedDatasetVersion");
                //this.publicDatasets = (Dataset[]) session.getAttribute("publicDatasets");
                this.dbConn = (Connection) session.getAttribute("dbConn");
                //log.debug("db");
                this.perlDir = (String) session.getAttribute("perlDir") + "scripts/";
                //log.debug("perl" + perlDir);
                String contextRoot = (String) session.getAttribute("contextRoot");
                //log.debug("context" + contextRoot);
                String appRoot = (String) session.getAttribute("applicationRoot");
                //log.debug("app" + appRoot);
                this.fullPath = appRoot + contextRoot;
                //log.debug("fullpath");
                this.rFunctDir = (String) session.getAttribute("rFunctionDir");
                //log.debug("rFunction");
                this.userFilesRoot = (String) session.getAttribute("userFilesRoot");
                //log.debug("userFilesRoot");
                this.urlPrefix = (String) session.getAttribute("mainURL");
                if (urlPrefix.endsWith(".jsp")) {
                    urlPrefix = urlPrefix.substring(0, urlPrefix.lastIndexOf("/") + 1);
                }
                //log.debug("mainURL");
                this.perlEnvVar = (String) session.getAttribute("perlEnvVar");
                //log.debug("PerlEnv");
                this.ucscDir = (String) session.getAttribute("ucscDir");
                //log.debug("ucsc");
                this.bedDir = (String) session.getAttribute("bedDir");
                //log.debug("bedDir");
                myStatistic = new Statistic();
                myStatistic.setSession(session);
                myStatistic.setRFunctionDir(this.rFunctDir);
    }
    
    
    
    
    public void run() throws RuntimeException {
        doneThread=false;
        pathReady=false;
        outputDir=gdt.getImageRegionData(chromosome,min,max,panel,myOrganism,genomeVer,rnaDatasetID,arrayTypeID,forwardPValueCutoff,true);
        pathReady=true;
        //call full version for adding files later
        gdt.getRegionData(chromosome,fullMin,fullMax,panel,myOrganism,genomeVer,rnaDatasetID,arrayTypeID,forwardPValueCutoff,false);
        doneThread=true;
    }

    public boolean isDone() {
        return doneThread;
    }
    
    public boolean isPathReady(){
        return pathReady;
    }
    
    public String getPath(){
        return outputDir;
    }
    
    
}
 
