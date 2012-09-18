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

public class MarkerDataFile extends DataFile {

	private Logger log=null;
	private HttpSession session ;

	public MarkerDataFile() {
		log = Logger.getRootLogger();
	}

	public MarkerDataFile(String fileName) {
		log = Logger.getRootLogger();
		setFileName(fileName);
	}

	public MarkerDataFile(String type, String fileName, String panel) {
		super(type, fileName,panel);
		log = Logger.getRootLogger();
	}

        public MarkerDataFile(HttpSession session) {
		super(session); 
                log = Logger.getRootLogger();
		log.debug("instantiated MarkerDataFile setting session variable");
	}

	public boolean equals(Object obj) {
		if (!(obj instanceof MarkerDataFile)) return false;
		return this.fileName.equals(((MarkerDataFile)obj).fileName);
	}
        
	public void print(MarkerDataFile myMarkerDataFile) {
		myMarkerDataFile.print();
	}

	public String toString() {
		return "This MarkerDataFile has "; 
	}

	public void print() {
		log.debug("MarkerDataFile = " + toString());
	}

	public MarkerDataFile[] sortMarkerDataFiles (MarkerDataFile[] myMarkerDataFiles, String sortColumn) {
		setSortColumn(sortColumn);
		Arrays.sort(myMarkerDataFiles, new MarkerDataFileSortComparator());
		return myMarkerDataFiles;
	}

	private String sortColumn;
	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}

	public String getSortColumn() {
		return sortColumn;
	}

	public class MarkerDataFileSortComparator implements Comparator<MarkerDataFile> {
		int compare;
		MarkerDataFile datafile1, datafile2;

		public int compare(MarkerDataFile datafile1, MarkerDataFile datafile2) 	{ 
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

