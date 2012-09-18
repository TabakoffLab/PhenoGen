package edu.ucdenver.ccp.PhenoGen.data.internal;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.User;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.ObjectHandler;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling the datafiles available on dataFiles
 *  @author  Cheryl Hornbaker
 */

public abstract class DataFile {

	protected Logger log=null;

	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();
	public DataFile[] datafiles = null;
	private String sysBioDir;
	private String datasetsDir;
        private User userLoggedIn = null;
	private HttpSession session ;

        private String dataset;
        protected String fileName;
        protected String type;
        protected String panel;

	public DataFile() {
		log = Logger.getRootLogger();
	}

	public DataFile(String fileName) {
		log = Logger.getRootLogger();
		setFileName(fileName);
	}
        
        public DataFile(String type, String fileName) {
		log = Logger.getRootLogger();
		setType(type);
		setFileName(fileName);
	}

	public DataFile(String type, String fileName, String panel) {
		log = Logger.getRootLogger();
		setType(type);
		setFileName(fileName);
                setPanel(panel);
	}

        public DataFile(HttpSession session) {
                log = Logger.getRootLogger();
		setSession(session); 
		//log.debug("instantiated DataFile setting session variable");
	}

        public void setDataset(String inString) {
                this.dataset = inString;
        }

        public String getDataset() {
                return this.dataset;
        }

        public void setType(String inString) {
                this.type = inString;
        }

        public String getType() {
                return this.type;
        }

        public void setFileName(String inString) {
                this.fileName = inString;
        }

        public String getFileName() {
                return this.fileName;
        }
        
        public void setPanel(String p){
            this.panel=p;
        }
        
        public String getPanel(){
            return this.panel;
        }

	public HttpSession getSession() {
		log.debug("in getSession");
		return session;
	}

	public void setSession(HttpSession inSession) {
		log.debug("in DataFile.setSession");
		this.session = inSession;
	        this.sysBioDir = (String) session.getAttribute("sysBioDir");
	        this.datasetsDir = (String) session.getAttribute("datasetsDir");
	        this.userLoggedIn = (User) session.getAttribute("userLoggedIn");
	}

        public void setDataFiles(DataFile[] inDataFiles) {
                this.datafiles = inDataFiles;
        }

        public DataFile[] getDataFiles() {
                return this.datafiles;
        }

	public boolean equals(Object obj) {
		if (!(obj instanceof DataFile)) return false;
		return this.fileName.equals(((DataFile)obj).fileName);
	}
        
	public void print(DataFile myDataFile) {
		myDataFile.print();
	}

	public String toString() {
		return "This DataFile has fileName = " + fileName + ", and dataset = " + dataset;
	}

	public void print() {
		log.debug("DataFile = " + toString());
	}

/*
	public DataFile[] sortDataFiles (DataFile[] myDataFiles, String sortColumn) {
		setSortColumn(sortColumn);
		Arrays.sort(myDataFiles, new DataFileSortComparator());
		return myDataFiles;
	}

	private String sortColumn;
	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}

	public String getSortColumn() {
		return sortColumn;
	}

	public class DataFileSortComparator implements Comparator<DataFile> {
		int compare;
		DataFile datafile1, datafile2;

		public int compare(DataFile datafile1, DataFile datafile2) 	{ 
			//log.debug("in DataFileSortComparator. sortOrder = "+getSortOrder() + ", sortColumn = "+getSortColumn());
			//log.debug("datafile1 fileName = "+datafile1.getFileName()+ ", datafile2 fileName = "+datafile2.getFileName());

                	if (getSortColumn().equals("dataset")) {
                        	compare = datafile1.getDataset().compareTo(datafile2.getDataset());
                	} else if (getSortColumn().equals("fileName")) {
                        	compare = datafile1.getFileName().compareTo(datafile2.getFileName());
			}
                	return compare;
        	}
	}
*/
}
