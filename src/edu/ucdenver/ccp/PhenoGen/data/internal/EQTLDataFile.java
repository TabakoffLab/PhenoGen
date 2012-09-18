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

public class EQTLDataFile extends DataFile {

	//private Logger log=null;

	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();
	String source = "";

	public EQTLDataFile() {
		log = Logger.getRootLogger();
	}

	public EQTLDataFile(String fileName) {
		super(fileName);
		log = Logger.getRootLogger();
	}

	public EQTLDataFile(String type, String fileName) {
		super(type, fileName);
		log = Logger.getRootLogger();
	}

	public EQTLDataFile(String type, String fileName, String source) {
		super(type, fileName);
		log = Logger.getRootLogger();
		setSource(source);
	}

        public void setSource(String inString) {
                this.source = inString;
        }

        public String getSource() {
                return this.source;
        }

	public boolean equals(Object obj) {
		if (!(obj instanceof EQTLDataFile)) return false;
		return this.fileName.equals(((EQTLDataFile)obj).fileName);
	}
        
	public void print(EQTLDataFile myEQTLDataFile) {
		myEQTLDataFile.print();
	}

	public String toString() {
		return "This EQTLDataFile has type = " + type +
		", fileName = " + fileName; 
	}

	public void print() {
		log.debug("EQTLDataFile = " + toString());
	}

	public EQTLDataFile[] sortEQTLDataFiles (EQTLDataFile[] myEQTLDataFiles, String sortColumn) {
		setSortColumn(sortColumn);
		Arrays.sort(myEQTLDataFiles, new EQTLDataFileSortComparator());
		return myEQTLDataFiles;
	}

	private String sortColumn;
	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}

	public String getSortColumn() {
		return sortColumn;
	}

	public class EQTLDataFileSortComparator implements Comparator<EQTLDataFile> {
		int compare;
		EQTLDataFile datafile1, datafile2;

		public int compare(EQTLDataFile datafile1, EQTLDataFile datafile2) 	{ 
			//log.debug("in EQTLDataFileSortComparator. sortOrder = "+getSortOrder() + ", sortColumn = "+getSortColumn());
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
