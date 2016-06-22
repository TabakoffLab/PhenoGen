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

public class HeritabilityDataFile extends DataFile {

	private Logger log=null;

	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();
	private String datasetsDir;
        private User userLoggedIn = null;
        private Dataset selectedDataset = null;
        private Dataset.DatasetVersion selectedDatasetVersion = null;
	private HttpSession session ;

	public HeritabilityDataFile() {
		log = Logger.getRootLogger();
	}

	public HeritabilityDataFile(String fileName) {
		super(fileName);
		log = Logger.getRootLogger();
	}

	public HeritabilityDataFile(String type, String fileName,String genomeVer) {
		super(type, fileName,"",genomeVer);
		log = Logger.getRootLogger();
	}

        public HeritabilityDataFile(HttpSession session) {
		super(session); 
                log = Logger.getRootLogger();
		log.debug("instantiated HeritabilityDataFile setting session variable");
	}

	public boolean equals(Object obj) {
		if (!(obj instanceof HeritabilityDataFile)) return false;
		return this.fileName.equals(((HeritabilityDataFile)obj).fileName);
	}
        
	public void print(HeritabilityDataFile myHeritabilityDataFile) {
		myHeritabilityDataFile.print();
	}

	public String toString() {
		return "This HeritabilityDataFile has type = " + type +
		", fileName = " + fileName; 
	}

	public void print() {
		log.debug("HeritabilityDataFile = " + toString());
	}

	public HeritabilityDataFile[] sortHeritabilityDataFiles (HeritabilityDataFile[] myHeritabilityDataFiles, String sortColumn) {
		setSortColumn(sortColumn);
		Arrays.sort(myHeritabilityDataFiles, new HeritabilityDataFileSortComparator());
		return myHeritabilityDataFiles;
	}

	private String sortColumn;
	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}

	public String getSortColumn() {
		return sortColumn;
	}

	public class HeritabilityDataFileSortComparator implements Comparator<HeritabilityDataFile> {
		int compare;
		HeritabilityDataFile datafile1, datafile2;

		public int compare(HeritabilityDataFile datafile1, HeritabilityDataFile datafile2) 	{ 
			//log.debug("in HeritabilityDataFileSortComparator. sortOrder = "+getSortOrder() + ", sortColumn = "+getSortColumn());
			//log.debug("datafile1 organism = "+datafile1.getOrganism()+ ", datafile2 organism = "+datafile2.getOrganism());

                	if (getSortColumn().equals("type")) {
                        	compare = datafile1.getType().compareTo(datafile2.getType());
                	} else if (getSortColumn().equals("fileName")) {
                        	compare = datafile1.getFileName().compareTo(datafile2.getFileName());
			}
                	return compare;
        	}
	}
}
