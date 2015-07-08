package edu.ucdenver.ccp.PhenoGen.data.internal;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.data.User;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.ObjectHandler;
import java.sql.Timestamp;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling the resources available for downloading
 *  @author  Cheryl Hornbaker
 */

public class PublicationFile extends DataFile{

	private Logger log=null;
        
        public PublicationFile(){
            log = Logger.getRootLogger();
        }
        
        public PublicationFile(String type, String fileName) {
		super(type, fileName);
		log = Logger.getRootLogger();
	}

    
        public boolean equals(Object obj) {
		if (!(obj instanceof PublicationFile)) return false;
		return this.fileName.equals(((PublicationFile)obj).fileName);
	}
        
	public void print(PublicationFile myPublicationFile) {
		myPublicationFile.print();
	}

	public String toString() {
		return "This PublicationFile  , fileName = " + this.fileName; 
	}

	public void print() {
		log.debug("PublicationFile = " + toString());
	}

	public PublicationFile[] sortPublicationFiles (PublicationFile[] myPublicationFiles, String sortColumn) {
		setSortColumn(sortColumn);
		Arrays.sort(myPublicationFiles, new PublicationFileSortComparator());
		return myPublicationFiles;
	}

	private String sortColumn;
	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}

	public String getSortColumn() {
		return sortColumn;
	}

	public class PublicationFileSortComparator implements Comparator<PublicationFile> {
		int compare;
		PublicationFile datafile1, datafile2;

		public int compare(PublicationFile datafile1, PublicationFile datafile2) 	{ 
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
