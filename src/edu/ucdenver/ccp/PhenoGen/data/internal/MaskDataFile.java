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

public class MaskDataFile extends DataFile {

	private Logger log=null;

	private HttpSession session ;

	public MaskDataFile() {
		log = Logger.getRootLogger();
	}

	public MaskDataFile(String fileName) {
		log = Logger.getRootLogger();
		setFileName(fileName);
	}

	public MaskDataFile(String type, String fileName) {
		super(type, fileName);
		log = Logger.getRootLogger();
	}

        public MaskDataFile(HttpSession session) {
		super(session); 
                log = Logger.getRootLogger();
		log.debug("instantiated MarkerDataFile setting session variable");
	}

	public boolean equals(Object obj) {
		if (!(obj instanceof MaskDataFile)) return false;
		return this.fileName.equals(((MaskDataFile)obj).fileName);
	}
        
	public void print(MaskDataFile myMarkerDataFile) {
		myMarkerDataFile.print();
	}

	public String toString() {
		return "This SAMDataFile has "; 
	}

	public void print() {
		log.debug("MarkerDataFile = " + toString());
	}

	public MaskDataFile[] sortSAMDataFiles (MaskDataFile[] myMaskDataFiles, String sortColumn) {
		setSortColumn(sortColumn);
		Arrays.sort(myMaskDataFiles, new MaskDataFileSortComparator());
		return myMaskDataFiles;
	}

	private String sortColumn;
	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}

	public String getSortColumn() {
		return sortColumn;
	}

	public class MaskDataFileSortComparator implements Comparator<MaskDataFile> {
		int compare;
		MaskDataFile datafile1, datafile2;

		public int compare(MaskDataFile datafile1, MaskDataFile datafile2) 	{ 
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

