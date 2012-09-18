package edu.ucdenver.ccp.PhenoGen.data.internal;

import javax.servlet.http.HttpSession;
import java.util.Arrays;
import java.util.Comparator;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling the datafiles available on dataFiles
 *  @author  Cheryl Hornbaker
 */

public class ExpressionDataFile extends DataFile {

	private Logger log=null;

	private HttpSession session ;

	public ExpressionDataFile() {
		log = Logger.getRootLogger();
	}

	public ExpressionDataFile(String fileName) {
		super(fileName);
		log = Logger.getRootLogger();
	}

	public ExpressionDataFile(String type, String fileName) {
		super(type, fileName);
		log = Logger.getRootLogger();
	}

        public ExpressionDataFile(HttpSession session) {
		super(session); 
                log = Logger.getRootLogger();
		log.debug("instantiated ExpressionDataFile setting session variable");
	}

	public boolean equals(Object obj) {
		if (!(obj instanceof ExpressionDataFile)) return false;
		return this.fileName.equals(((ExpressionDataFile)obj).fileName);
	}
        
	public void print(ExpressionDataFile myExpressionDataFile) {
		myExpressionDataFile.print();
	}

	public String toString() {
		return "This ExpressionDataFile has type = " + type +
		", fileName = " + fileName; 
	}

	public void print() {
		log.debug("ExpressionDataFile = " + toString());
	}

	public ExpressionDataFile[] sortExpressionDataFiles (ExpressionDataFile[] myExpressionDataFiles, String sortColumn) {
		setSortColumn(sortColumn);
		Arrays.sort(myExpressionDataFiles, new ExpressionDataFileSortComparator());
		return myExpressionDataFiles;
	}

	private String sortColumn;
	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}

	public String getSortColumn() {
		return sortColumn;
	}

	public class ExpressionDataFileSortComparator implements Comparator<ExpressionDataFile> {
		int compare;
		ExpressionDataFile datafile1, datafile2;

		public int compare(ExpressionDataFile datafile1, ExpressionDataFile datafile2) 	{ 
			//log.debug("in ExpressionDataFileSortComparator. sortOrder = "+getSortOrder() + ", sortColumn = "+getSortColumn());
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
