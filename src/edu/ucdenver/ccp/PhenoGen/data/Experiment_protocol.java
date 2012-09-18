package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

import edu.ucdenver.ccp.util.Debugger;

import edu.ucdenver.ccp.util.ObjectHandler;

import edu.ucdenver.ccp.util.sql.Results;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to Experiment_protocols
 *  @author  Cheryl Hornbaker
 */

public class Experiment_protocol {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();
	private List<Object> queryVariables = new ArrayList<Object>();

	public Experiment_protocol() {
		log = Logger.getRootLogger();
	}

	public Experiment_protocol(int exp_id, int protocol_id) {
		log = Logger.getRootLogger();
		this.setExp_id(exp_id);
		this.setProtocol_id(protocol_id);
	}


	private int exp_id;
	private int protocol_id;
	private String expName;
	private String protocolName;
	private String globid;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setExp_id(int inInt) {
		this.exp_id = inInt;
	}

	public int getExp_id() {
		return this.exp_id;
	}

	public void setProtocol_id(int inInt) {
		this.protocol_id = inInt;
	}

	public int getProtocol_id() {
		return this.protocol_id;
	}

	public void setExpName(String inString) {
		this.expName = inString;
	}

	public String getExpName() {
		return this.expName;
	}

	public void setProtocolName(String inString) {
		this.protocolName = inString;
	}

	public String getProtocolName() {
		return this.protocolName;
	}

	public void setGlobid(String inString) {
		this.globid = inString;
	}

	public String getGlobid() {
		return this.globid;
	}

	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}

	public String getSortColumn() {
		return this.sortColumn;
	}

	public void setSortOrder(String inString) {
		this.sortOrder = inString;
	}

	public String getSortOrder() {
		return this.sortOrder;
	}


	/**
	 * Gets all the Experiment_protocols
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Experiment_protocol objects
	 */
	public Experiment_protocol[] getAllExperiment_protocols(Connection conn) throws SQLException {
		log.debug("In getAll Experiment_protocols");
		String query = 
			"select "+
			"exp_id, protocol_id "+
			"from experiment_protocols "+ 
			"order by exp_id, protocol_id";

		Results myResults = new Results(query, conn);

		Experiment_protocol[] myExperiment_protocols = setupExperiment_protocolValues(myResults);

		myResults.close();

		return myExperiment_protocols;
	}

	/**
	 * Gets the Experiment_protocols for an experiment
	 * @param expID the id of the experiment
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Experiment_protocol objects
	 */
	public Experiment_protocol[] getExperiment_protocolsForExperiment(int expID, Connection conn) throws SQLException {
		log.debug("In getExperiment_protocolsForExperiment. expID=" + expID);
		String query = 
			"select "+
			"exp_id, protocol_id "+
			"from experiment_protocols "+ 
			"where exp_id = ? "+
			"order by exp_id, protocol_id";

		Results myResults = new Results(query, new Object[] {expID}, conn);

		Experiment_protocol[] myExperiment_protocols = setupExperiment_protocolValues(myResults);

		myResults.close();

		return myExperiment_protocols;
	}

	/**
	 * Gets all the Experiment_protocols for a particular type of protocol
	 * @param expName 	the name of the experiment
	 * @param protocolType 	the type of protocol -- either SAMPLE_GROWTH_PROTOCOL, SAMPLE_LABORATORY_PROTOCOL,
	 * EXTRACT_LABORATORY_PROTOCOL, LABEL_LABORATORY_PROTOCOL, HYBRID_LABORATORY_PROTOCOL, or SCANNING_LABORATORY_PROTOCOL
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Experiment_protocol objects
	 */
	public Experiment_protocol[] getExperiment_protocolsByType(String expName, String protocolType, Connection conn) throws SQLException {

		log.debug("In getExperiment_protocolsByType. expName = " + expName + ", and protocolType = "+protocolType);
		String query = 
			"select "+
			"ep.exp_id, ep.protocol_id, e.exp_name, p.protocol_name, p.globid "+
			"from experiment_protocols ep, experiments e, protocols p, valid_terms v "+ 
			"where ep.exp_id = e.exp_id "+
			"and ep.protocol_id = p.protocol_id "+
			"and p.protocol_type = v.term_id "+
			"and v.value = ? "+
			"and e.exp_name = ? "+
			"order by e.exp_id, ep.protocol_id";


		log.debug("query = "+query);

		Results myResults = new Results(query, new Object[] {protocolType, expName}, conn);
		log.debug("numRows = "+myResults.getNumRows());

		Experiment_protocol[] myExperiment_protocols = setupExperiment_protocolValues(myResults);

		myResults.close();

		return myExperiment_protocols;
	}

	/**
	 * Gets the Experiment_protocol object for this exp_id
	 * @param exp_id	 the exp_id of the Experiment_protocol
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Experiment_protocol object
	 */
	public Experiment_protocol getExperiment_protocol(int exp_id, Connection conn) throws SQLException {
		log.debug("In getOne Experiment_protocol");
		String query = 
			"select "+
			"exp_id, protocol_id "+
			"from experiment_protocols "+ 
			"where exp_id = ?";

		Results myResults = new Results(query, exp_id, conn);

		Experiment_protocol myExperiment_protocol = setupExperiment_protocolValues(myResults)[0];

		myResults.close();

		return myExperiment_protocol;
	}
	
	
	/**
	 * Retrieves all Experiment_protocol records via their protocol id
	 * @param protocol_id
	 * @param conn
	 * @return array of Experiment_protocol
	 * @throws SQLException
	 */
    public Experiment_protocol[] getExperiment_protocolsByProtocolId(int protocol_id, Connection conn) throws SQLException {
		
       String query = 
                "select "+
                "exp_id, protocol_id "+
                "from Experiment_protocols "+ 
                "where protocol_id = ?";

       Results myResults = new Results(query, protocol_id, conn);		
		
       Experiment_protocol[] experimentProtocols = setupExperiment_protocolValues(myResults);
		
       myResults.close();
		
       return experimentProtocols;
		
    }
	
	


        /**
         * Creates multiple records in the experiment_protocols table
         * @param userLoggedIn User object of the person logged in
         * @param fieldValues fieldNames mapped to their values
         * @param multipleFieldValues fieldNames mapped to their multiple values
         * @param conn  the database connection
         * @throws SQLException if an error occurs while accessing the database
         */
        public void createExperiment_protocol(User userLoggedIn, Hashtable<String, String> fieldValues,
                                HashMap<String, String[]> multipleFieldValues, Connection conn) throws SQLException {

                log.debug("in experiment_protocols create with fieldValues and multipleFieldValues");
                log.debug("fieldValues = "); myDebugger.print(fieldValues);
                log.debug("multipleFieldValues = "); myDebugger.print(multipleFieldValues);
		Experiment_protocol myExperiment_protocol = new Experiment_protocol();                        
		String[] protocols; 

                conn.setAutoCommit(false);
                try {
	                myExperiment_protocol.setExp_id(Integer.parseInt((String) fieldValues.get("experimentID")));                
	                log.debug("experimentID = " + myExperiment_protocol.getExp_id());
			if (multipleFieldValues != null) {
                        	for (Iterator itr = multipleFieldValues.keySet().iterator(); itr.hasNext();) {
                                	String protocolType = (String) itr.next();
					log.debug("protocolType = "+protocolType);
					protocols = (String[]) multipleFieldValues.get(protocolType);
					log.debug("there are = "+protocols.length + " protocols of this type");
					for (int i=0; i<protocols.length; i++) { 
						try {
                        				myExperiment_protocol.setProtocol_id(Integer.parseInt(protocols[i]));
                        				myExperiment_protocol.createExperiment_protocol(conn);
						} catch (SQLException e) {
							// Got ORA-2291 error that protocol record doesn't exist, so need to create it
                                        		if (e.getErrorCode() == 2291) {
                                                		log.error("SQLException in create Experiment_protocols for protocol_id = " + protocols[i]);
								int protocolID = new Protocol().createForPublicProtocol(userLoggedIn, Integer.parseInt(protocols[i]), protocolType, conn);
                        					myExperiment_protocol.setProtocol_id(protocolID);
                        					myExperiment_protocol.createExperiment_protocol(conn);
                                        		} else {
                                                		log.debug("Got a SQLException while in create Experiment_protocols. Error code = "+e.getErrorCode());
                                                		throw e;
                                        		}
						}
					}
				}
			}
                        conn.commit();
                } catch (SQLException e) {
                        log.error("In exception of create Experiment_protocol", e);
                        conn.rollback();
                        throw e;
                }
                conn.setAutoCommit(true);
		log.debug("finished create experiment_protocol");
	}

	/**
	 * Creates a record in the Experiment_protocols table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void createExperiment_protocol(Connection conn) throws SQLException {

		log.debug("In create Experiment_protocol");
		String query = 
			"insert into experiment_protocols "+
			"(exp_id, protocol_id) "+
			"values "+
			"(?, ?)";

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, exp_id);
		pstmt.setInt(2, protocol_id);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Updates a record in the Experiment_protocols table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 
			"update experiment_protocols "+
			"set exp_id = ?, protocol_id = ? "+
			"where exp_id = ?";


		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, exp_id);
		pstmt.setInt(2, protocol_id);
		pstmt.setInt(3, exp_id);

		pstmt.executeUpdate();
		pstmt.close();

	}

        /**
         * Deletes the record in the Experiment_protocol table and also deletes child records in related tables.
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteExperiment_protocol(Connection conn) throws SQLException {

                log.info("in deleteExperiment_protocol");

                //conn.setAutoCommit(false);

                PreparedStatement pstmt = null;
                try {

                        String query =
                                "delete from experiment_protocols " +
                                "where exp_id = ? "+
                                "and protocol_id = ?";

                        pstmt = conn.prepareStatement(query,
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                        pstmt.setInt(1, exp_id);
                        pstmt.setInt(2, protocol_id);
                        pstmt.executeQuery();
                        pstmt.close();

                        //conn.commit();
                } catch (SQLException e) {
                        log.debug("error in deleteExperiment_protocol");
                        //conn.rollback();
                        pstmt.close();
                        throw e;
                }
                //conn.setAutoCommit(true);
        }

        /**
         * Deletes the records in the Experiment_protocol table that are children of Experiment.
         * @param exp_id       identifier of the Experiment table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllExperiment_protocolsForExperiment(int exp_id, Connection conn) throws SQLException {

                log.info("in deleteAllExperiment_protocolsForExperiment");

                //Make sure committing is handled in calling method!

                String query =
                        "select exp_id, protocol_id "+
                        "from experiment_protocols "+
                        "where exp_id = ?";

                Results myResults = new Results(query, exp_id, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Experiment_protocol(Integer.parseInt(dataRow[0]), Integer.parseInt(dataRow[1])).deleteExperiment_protocol(conn);
                }

                myResults.close();

        }

        /**
         * Deletes the records in the Experiment_protocol table that are children of Protocol.
         * @param protocol_id       identifier of the Protocol table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllExperiment_protocolsForProtocol(int protocol_id, Connection conn) throws SQLException {

                log.info("in deleteAllExperiment_protocolsForProtocol");

                //Make sure committing is handled in calling method!

                String query =
                        "select exp_id, protocol_id "+
                        "from experiment_protocols "+
                        "where protocol_id = ?";

                Results myResults = new Results(query, protocol_id, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Experiment_protocol(Integer.parseInt(dataRow[0]), Integer.parseInt(dataRow[1])).deleteExperiment_protocol(conn);
                }

                myResults.close();

        }

	/**
	 * Creates an array of Experiment_protocol objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Experiment_protocols
	 * @return	An array of Experiment_protocol objects with their values setup 
	 */
	private Experiment_protocol[] setupExperiment_protocolValues(Results myResults) {

		//log.debug("in setupExperiment_protocolValues");

		List<Experiment_protocol> Experiment_protocolList = new ArrayList<Experiment_protocol>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Experiment_protocol thisExperiment_protocol = new Experiment_protocol();

			thisExperiment_protocol.setExp_id(Integer.parseInt(dataRow[0]));
			thisExperiment_protocol.setProtocol_id(Integer.parseInt(dataRow[1]));
			if (dataRow.length > 2) {
				thisExperiment_protocol.setExpName(dataRow[2]);
				thisExperiment_protocol.setProtocolName(dataRow[3]);
				thisExperiment_protocol.setGlobid(dataRow[4]);
			}

			Experiment_protocolList.add(thisExperiment_protocol);
		}

		Experiment_protocol[] Experiment_protocolArray = (Experiment_protocol[]) Experiment_protocolList.toArray(new Experiment_protocol[Experiment_protocolList.size()]);

		return Experiment_protocolArray;
	}

	/**
	 * Compares Experiment_protocols based on different fields.
	 */
	public class Experiment_protocolSortComparator implements Comparator<Experiment_protocol> {
		int compare;
		Experiment_protocol experiment_protocol1, experiment_protocol2;

		public int compare(Experiment_protocol object1, Experiment_protocol object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				experiment_protocol1 = object1;
				experiment_protocol2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				experiment_protocol2 = object1;
				experiment_protocol1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("experiment_protocol1 = " +experiment_protocol1+ "experiment_protocol2 = " +experiment_protocol2);

			if (sortColumn.equals("exp_id")) {
				compare = new Integer(experiment_protocol1.getExp_id()).compareTo(new Integer(experiment_protocol2.getExp_id()));
			} else if (sortColumn.equals("protocol_id")) {
				compare = new Integer(experiment_protocol1.getProtocol_id()).compareTo(new Integer(experiment_protocol2.getProtocol_id()));
			}
			return compare;
		}
	}

	public Experiment_protocol[] sortExperiment_protocols (Experiment_protocol[] myExperiment_protocols, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myExperiment_protocols, new Experiment_protocolSortComparator());
		return myExperiment_protocols;
	}

	/**
	 * Converts Experiment_protocols object to a String.
	 */
	public String toString() {
		return "This Experiment_protocol has exp_id = "+ exp_id;
	}

	/**
	 * Prints Experiment_protocol object to logs.
	 */
	public void print() {
		log.debug(toString());
	}

}
