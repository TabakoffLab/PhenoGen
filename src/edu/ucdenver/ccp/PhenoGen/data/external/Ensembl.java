package edu.ucdenver.ccp.PhenoGen.data.external;

import java.io.*;
import java.sql.*;
import java.util.*;
import edu.ucdenver.ccp.util.sql.*;
import edu.ucdenver.ccp.util.*;


/* for logging messages */
import org.apache.log4j.Logger;       


/**
 * Class for handling data retrieved from the Ensembl organization.
 *  @author  Cheryl Hornbaker
 */

public class Ensembl{

  private Logger log=null;

  public Ensembl () {
	log = Logger.getRootLogger();
  }

        /**
         * Retrieves the transcripts for a set of Ensembl IDs.
         * @param allEnsemblSet  a set of Ensembl IDs
         * @param conn  the Ensembl database connection
         * @throws            SQLException if a database error occurs
         * @return            a Hashtable of Ensembl IDs mapped to transcript IDs 
         */
	public Hashtable getTranscripts(Set<String> allEnsemblSet, Connection conn) throws SQLException {

		String query = "";
		Hashtable<String, List<String>> ensemblHash = new Hashtable<String, List<String>>();
		ObjectHandler myObjectHandler = new ObjectHandler();

		if (allEnsemblSet != null && allEnsemblSet.size() > 0) {
        		String[] allEnsemblArray = (String[]) allEnsemblSet.toArray(new String[allEnsemblSet.size()]);

                	//
                	// Get the transcripts for all the Ensembl IDs
                	//
                	String allEnsemblString = "(" + myObjectHandler.getAsSeparatedString(allEnsemblSet, ", ", "'", 999) + ")";

			query = 
			"select gs.stable_id, ts.stable_id "+
			"from transcript t, gene g, transcript_stable_id ts, gene_stable_id gs "+
			"where t.transcript_id = ts.transcript_id "+
			"and t.gene_id = g.gene_id "+
			"and g.gene_id = gs.gene_id "+
			"and gs.stable_id in "+
			allEnsemblString +
			" "+
			"order by gs.stable_id";
 
			log.debug("in getTranscripts");
			//log.debug("query =" + query);

			// Set the timeout length
			log.debug("instantiating a new Results object and setting the timeout to 5 seconds");
			Results myResults = new Results();
			myResults.setQuery(query);
			myResults.setConnection(conn);
			myResults.setTimeout(5);
			myResults.execute();
                	ensemblHash = myObjectHandler.getResultsAsHashtablePlusList(myResults);

                	//log.debug("ensemblHash = "); myDebugger.print(ensemblHash);
                	myResults.close();

		}  
		return ensemblHash;
	}

/*
	public Results descAllTables(Connection conn) throws SQLException {

		String query = 
			"desc assembly; desc assembly_exception; desc attrib_type;";

		log.debug("in descAllTables");
		PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);

		return new Results(pstmt);
	}

	public Results showTables(Connection conn) throws SQLException {

		String query = 
			"show tables";
 
		log.debug("in showTables");
		PreparedStatement pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
		return new Results(pstmt);
	}

*/
	public Results descTranscript(Connection conn) throws SQLException {

		String query = 
			"desc object_xref";
 
		log.debug("in descTranscript");

		return new Results(query, conn);
	}

  public static void main(String[] args) {

	try {
		String resultsFile = "/home/cherylh/ensemblResults.txt";
		//String logDBFileName = "/home/cherylh/iDecoderFiles/LogDBFile.txt";

		File myPropertiesFile = 
			new File("/usr/share/tomcat/webapps/PhenoGen/web/common/dbProperties/ensemblMouse.properties");

        	Connection ensemblConn = new PropertiesConnection().getConnection(myPropertiesFile);

		Ensembl myEnsembl = new Ensembl();

        	//int count = myEnsembl.getCrossRefsCount(ensemblConn);
		//System.out.println("count =  " + count);

        	//Results myResults = myEnsembl.showTables(ensemblConn);
        	//Results myResults = myEnsembl.descAllTables(ensemblConn);
        	Results myResults = myEnsembl.descTranscript(ensemblConn);
		new FileHandler().writeResultsAsDelimitedFile(myResults, resultsFile, "\t");
		//Hashtable myHash = new ObjectHandler().getResultsAsHashtablePlusList(myResults);

//        	myResults = new Results(myEnsembl.getLogicalDBs(ensemblConn));
//		myResults.createDelimitedFile(logDBFileName, "\t");
        } catch (Exception e) {
                System.out.println("in exception of Ensembl");
                e.printStackTrace();
        }

  }

}

