package edu.ucdenver.ccp.PhenoGen.data.internal;

import javax.servlet.http.HttpSession;
import java.util.Arrays;
import java.util.Comparator;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling the datafiles available for markers
 *  @author  Cheryl Hornbaker
 */

public class SAMDataFile extends DataFile {

	private Logger log=null;

	private HttpSession session ;

	public SAMDataFile() {
		log = Logger.getRootLogger();
	}

	public SAMDataFile(String fileName) {
		log = Logger.getRootLogger();
		setFileName(fileName);
	}

	public SAMDataFile(String type, String fileName) {
		super(type, fileName);
		log = Logger.getRootLogger();
	}

        public SAMDataFile(HttpSession session) {
		super(session); 
                log = Logger.getRootLogger();
		log.debug("instantiated MarkerDataFile setting session variable");
	}

	public boolean equals(Object obj) {
		if (!(obj instanceof SAMDataFile)) return false;
		return this.fileName.equals(((SAMDataFile)obj).fileName);
	}
        
	public void print(SAMDataFile myMarkerDataFile) {
		myMarkerDataFile.print();
	}

	public String toString() {
		return "This SAMDataFile has "; 
	}

	public void print() {
		log.debug("MarkerDataFile = " + toString());
	}

	public SAMDataFile[] sortSAMDataFiles (SAMDataFile[] mySAMDataFiles, String sortColumn) {
		setSortColumn(sortColumn);
		Arrays.sort(mySAMDataFiles, new SAMDataFileSortComparator());
		return mySAMDataFiles;
	}

	private String sortColumn;
	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}

	public String getSortColumn() {
		return sortColumn;
	}

	public class SAMDataFileSortComparator implements Comparator<SAMDataFile> {
		int compare;
		SAMDataFile datafile1, datafile2;

		public int compare(SAMDataFile datafile1, SAMDataFile datafile2) 	{ 
			//log.debug("in MarkerDataFileSortComparator. sortOrder = "+getSortOrder() + ", sortColumn = "+getSortColumn());

                	if (getSortColumn().equals("fileName")) {
                        	compare = datafile1.getFileName().compareTo(datafile2.getFileName());
                	} else if (getSortColumn().equals("type")) {
                        	compare = datafile1.getType().compareTo(datafile2.getType());
			}
                	return compare;
        	}
	}
}

