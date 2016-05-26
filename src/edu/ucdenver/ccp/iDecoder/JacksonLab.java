package edu.ucdenver.ccp.iDecoder;

import java.io.*;
import java.sql.*;
import java.util.*;
import edu.ucdenver.ccp.util.sql.*;
import edu.ucdenver.ccp.util.*;


/* for logging messages */
import org.apache.log4j.Logger;       

public class JacksonLab{

  private Logger log=null;

  public JacksonLab () {
	log = Logger.getRootLogger();
  }

  public Results getCrossRefs(Connection conn) throws SQLException {
  	/*
	 * This query retrieves the list of ids tracked by MGI 
	 * NOTICE THERE IS NO ';' at the end -- because this is querying a Sybase db 
	 */

	String query = 
		"select a.accID, o.accID, l.name "+
		"from ACC_Accession a, ACC_Accession o, ACC_LogicalDB l "+
		"where a._MGIType_key = 2 "+
		"and a._LogicalDB_key = 1 "+
		"and a.prefixPart = 'MGI:' "+
		"and a.preferred = 1 "+
		"and a._Object_key = o._Object_key "+
		"and o._MGIType_key = 2 "+
		"and o._LogicalDB_Key != 1 "+
		"and o.preferred = 1 "+
		"and l.name in ('Ensembl Gene Model', 'Entrez Gene', 'HomoloGene', 'RefSeq', "+
		"		'Sequence DB', 'SWISS-PROT', 'UniGene') "+
		"and o._LogicalDB_key = l._LogicalDB_key "+
		"order by a.accID "; 
 
	log.debug("in getCrossRefs");
	PreparedStatement pstmt = null;

	try {
                pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
	} catch (SQLException e) {
		log.error("In exception of getCrossRefs", e);
		throw e;
	}
	return new Results(pstmt);
  }

  public Results getLogicalDBs(Connection conn) throws SQLException {
  	/*
	 * This query retrieves the list of ids tracked by MGI 
	 * NOTICE THERE IS NO ';' at the end -- because this is querying a Sybase db 
	 */

	String query = 
		"select * from ACC_LogicalDB ";
 
	log.debug("in getLogicalDBs");
	PreparedStatement pstmt = null;

	try {
                pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
	} catch (SQLException e) {
		log.error("In exception of getLogicalDBs", e);
		throw e;
	}
	return new Results(pstmt);
  }

  public void run() {

	try {
		String accFileName = "/Users/smahaffey/iDecoder/InputFiles/MGI/MGIFile.txt";
		String logDBFileName = "/Users/smahaffey/iDecoder/InputFiles/MGI/LogDBFile.txt";

        	Connection jacksonConn = new PropertiesConnection().getConnection("/Library/Tomcat/webapps/PhenoGen/web/common/dbProperties/jacksonMgd.properties");

		JacksonLab myJacksonLab = new JacksonLab();

        	Results myResults = myJacksonLab.getCrossRefs(jacksonConn);

		System.out.println("creating DelimitedFile");
		new FileHandler().writeResultsAsDelimitedFile(myResults, accFileName, "\t");
		System.out.println("finished creating delimitedFile");

        	//myResults = myJacksonLab.getLogicalDBs(jacksonConn);
		//new FileHandler().writeResultsAsDelimitedFile(myResults, logDBFileName, "\t");
        } catch (Exception e) {
                log.debug("in exception of JacksonLab", e);
		
	}
  }
  public static void main(String[] args) {


	try {
		String accFileName = "/Users/smahaffey/iDecoder/InputFiles/MGI/MGIFile.txt";
		String logDBFileName = "/Users/smahaffey/iDecoder/InputFiles/MGI/LogDBFile.txt";

        	Connection jacksonConn = new PropertiesConnection().getConnection("/usr/share/tomcat/webapps/PhenoGen/web/common/dbProperties/jacksonMgd.properties");

		JacksonLab myJacksonLab = new JacksonLab();

        	Results myResults = myJacksonLab.getCrossRefs(jacksonConn);

		System.out.println("creating DelimitedFile");
		new FileHandler().writeResultsAsDelimitedFile(myResults, accFileName, "\t");
		System.out.println("finished creating delimitedFile");

        	//myResults = myJacksonLab.getLogicalDBs(jacksonConn);
		//new FileHandler().writeResultsAsDelimitedFile(myResults, logDBFileName, "\t");
        } catch (Exception e) {
                System.out.println("in exception of JacksonLab");
                e.printStackTrace();
        }

  }

}

