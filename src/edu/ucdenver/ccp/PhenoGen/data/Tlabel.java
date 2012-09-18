package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

import edu.ucdenver.ccp.util.Debugger;

import edu.ucdenver.ccp.util.ObjectHandler;

import edu.ucdenver.ccp.util.sql.Results;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to Tlabel
 *  @author  Cheryl Hornbaker
 */

public class Tlabel {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();

	public Tlabel() {
		log = Logger.getRootLogger();
	}

	public Tlabel(int tlabel_sysuid) {
		log = Logger.getRootLogger();
		this.setTlabel_sysuid(tlabel_sysuid);
	}


	private int tlabel_sysuid;
	private String tlabel_id;
	private String tlabel_desc;
		private int tlabel_protocolid;
	private int tlabel_extractid;
	private String tlabel_del_status = "U";
	private String tlabel_user;
	private String tlabel_exp_name;
	private java.sql.Timestamp tlabel_last_change;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setTlabel_sysuid(int inInt) {
		this.tlabel_sysuid = inInt;
	}

	public int getTlabel_sysuid() {
		return this.tlabel_sysuid;
	}

	public void setTlabel_id(String inString) {
		this.tlabel_id = inString;
	}

	public String getTlabel_id() {
		return this.tlabel_id;
	}

	public void setTlabel_desc(String inString) {
		this.tlabel_desc = inString;
	}

	public String getTlabel_desc() {
		return this.tlabel_desc;
	}

	public void setTlabel_protocolid(int inInt) {
		this.tlabel_protocolid = inInt;
	}

	public int getTlabel_protocolid() {
		return this.tlabel_protocolid;
	}

	public void setTlabel_extractid(int inInt) {
		this.tlabel_extractid = inInt;
	}

	public int getTlabel_extractid() {
		return this.tlabel_extractid;
	}

	public void setTlabel_del_status(String inString) {
		this.tlabel_del_status = inString;
	}

	public String getTlabel_del_status() {
		return this.tlabel_del_status;
	}

	public void setTlabel_user(String inString) {
		this.tlabel_user = inString;
	}

	public String getTlabel_user() {
		return this.tlabel_user;
	}

	public void setTlabel_exp_name(String inString) {
		this.tlabel_exp_name = inString;
	}

	public String getTlabel_exp_name() {
		return this.tlabel_exp_name;
	}

	public void setTlabel_last_change(java.sql.Timestamp inTimestamp) {
		this.tlabel_last_change = inTimestamp;
	}

	public java.sql.Timestamp getTlabel_last_change() {
		return this.tlabel_last_change;
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

	public void validateLabel_name(String value, int expID, Connection conn) throws DataException, SQLException {
		log.debug("in validateLabel_name. name = "+value);
		if (myObjectHandler.isEmpty(value)) {
			throw new DataException("ERROR: Labeled Extract Name must be entered.");
		} else if (!isUnique(value, expID, conn)) {
			throw new DataException("ERROR: All Labeled Extract Names in this experiment must be unique.");
		}
	}

	private boolean isUnique(String label_name, int expID, Connection conn) throws DataException, SQLException {
		log.debug("checking if Tlabel isUnique. name = "+label_name);
		String query = 
			"select tlabel_sysuid "+
			"from tlabel, textract, tpooled, tsample "+
			"where tsample_exprid = ? "+
			"and textract_sysuid = tlabel_extractid "+
			"and textract_sysuid = tpooled_extractid "+
			"and tsample_sysuid = tpooled_sampleid "+
			"and tlabel_id = ?"; 
	
		log.debug("query = " + query);

		Results myResults = new Results(query, new Object[] {expID, label_name}, conn);

		int existingID = myResults.getIntValueFromFirstRow();

		myResults.close();

		return (existingID == -99 ? true : false);
	}


	/**
	 * Gets all the Tlabel
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Tlabel objects
	 */
	public Tlabel[] getAllTlabel(Connection conn) throws SQLException {

		log.debug("In getAllTlabel");

		String query = 
			"select "+
			"tlabel_sysuid, tlabel_id, tlabel_desc, tlabel_protocolid, tlabel_extractid, "+
			"tlabel_del_status, tlabel_user, to_char(tlabel_last_change, 'dd-MON-yyyy hh24:mi:ss'), exp_name "+
			"from experimentdetails "+ 
			"order by tlabel_sysuid";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Tlabel[] myTlabel = setupTlabelValues(myResults);

		myResults.close();

		return myTlabel;
	}

        /**
         * Gets the records in the Tlabel table that are children of Protocol.
         * @param protocol_id       identifier of the Protocol table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public Tlabel[] getAllTlabelForProtocol(int protocol_id, Connection conn) throws SQLException {

                log.info("in getAllTlabelForProtocol");

                //Make sure committing is handled in calling method!

                String query =
			"select "+
			"tlabel_sysuid, tlabel_id, tlabel_desc, tlabel_protocolid, tlabel_extractid, "+
			"tlabel_del_status, tlabel_user, to_char(tlabel_last_change, 'dd-MON-yyyy hh24:mi:ss'), exp_name "+
			"from experimentDetails "+ 
                        "where tlabel_protocolid = ? "+
                        "and tlabel_del_status = 'U' "+
			"order by tlabel_sysuid";

                Results myResults = new Results(query, protocol_id, conn);

		Tlabel[] myTlabel = setupTlabelValues(myResults);

                myResults.close();

		return myTlabel;

        }

	/**
	 * Gets the Tlabel object for this tlabel_sysuid
	 * @param tlabel_sysuid	 the identifier of the Tlabel
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tlabel object
	 */
	public Tlabel getTlabel(int tlabel_sysuid, Connection conn) throws SQLException {

		log.debug("In getOne Tlabel");

		String query = 
			"select "+
			"tlabel_sysuid, tlabel_id, tlabel_desc, tlabel_protocolid, tlabel_extractid, "+
			"tlabel_del_status, tlabel_user, to_char(tlabel_last_change, 'dd-MON-yyyy hh24:mi:ss'), exp_name "+
			"from experimentdetails "+ 
			"where tlabel_sysuid = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, tlabel_sysuid, conn);

		Tlabel myTlabel = setupTlabelValues(myResults)[0];

		myResults.close();

		return myTlabel;
	}

	/**
	 * Creates a record in the Tlabel table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createTlabel(Connection conn) throws SQLException {

		int tlabel_sysuid = myDbUtils.getUniqueID("Tlabel_seq", conn);

		log.debug("In create Tlabel");

		String query = 
			"insert into Tlabel "+
			"(tlabel_sysuid, tlabel_id, tlabel_desc, tlabel_protocolid, tlabel_extractid, "+
			"tlabel_del_status, tlabel_user, tlabel_last_change) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tlabel_sysuid);
		pstmt.setString(2, tlabel_id);
		pstmt.setString(3, tlabel_desc);
		myDbUtils.setToNullIfZero(pstmt, 4, tlabel_protocolid);
		pstmt.setInt(5, tlabel_extractid);
		pstmt.setString(6, "U");
		pstmt.setString(7, tlabel_user);
		pstmt.setTimestamp(8, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setTlabel_sysuid(tlabel_sysuid);

		return tlabel_sysuid;
	}

	/**
	 * Updates a record in the Tlabel table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 

			"update Tlabel "+
			"set tlabel_sysuid = ?, tlabel_id = ?, tlabel_desc = ?, tlabel_protocolid = ?, tlabel_extractid = ?, "+
			"tlabel_del_status = ?, tlabel_user = ?, tlabel_last_change = ? "+
			"where tlabel_sysuid = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tlabel_sysuid);
		pstmt.setString(2, tlabel_id);
		pstmt.setString(3, tlabel_desc);
		myDbUtils.setToNullIfZero(pstmt, 4, tlabel_protocolid);
		pstmt.setInt(5, tlabel_extractid);
		pstmt.setString(6, tlabel_del_status);
		pstmt.setString(7, tlabel_user);
		pstmt.setTimestamp(8, now);
		pstmt.setInt(9, tlabel_sysuid);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the Tlabel table and also deletes child records in related tables.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */

	public void deleteTlabel(Connection conn) throws SQLException {

		log.info("in deleteTlabel");

		//conn.setAutoCommit(false);

		PreparedStatement pstmt = null;
		try {
                        new Tlabhyb().deleteAllTlabhybForTlabel(tlabel_sysuid, conn);

			String query = 
				"delete from Tlabel " + 
				"where tlabel_sysuid = ?";

			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

			pstmt.setInt(1, tlabel_sysuid);
			pstmt.executeQuery();
			pstmt.close();

			//conn.commit();
		} catch (SQLException e) {
			log.debug("error in deleteTlabel");
			//conn.rollback();
			pstmt.close();
			throw e;
		}
		//conn.setAutoCommit(true);
	}

        /**
         * Deletes the records in the Tlabel table that are children of Protocol.
         * @param protocol_id       identifier of the Protocol table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTlabelForProtocol(int protocol_id, Connection conn) throws SQLException {

                log.info("in deleteAllTlabelForProtocol");

                //Make sure committing is handled in calling method!

                String query =
                        "select tlabel_sysuid "+
                        "from Tlabel "+
                        "where tlabel_protocolid = ?";

                Results myResults = new Results(query, protocol_id, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Tlabel(Integer.parseInt(dataRow[0])).deleteTlabel(conn);
                }

                myResults.close();

        }

        /**
         * Deletes the records in the Tlabel table that are children of Textract.
         * @param textract_sysuid       identifier of the Textract table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTlabelForTextract(int textract_sysuid, Connection conn) throws SQLException {

                log.info("in deleteAllTlabelForTextract");

                //Make sure committing is handled in calling method!

                String query =
                        "select tlabel_sysuid "+
                        "from Tlabel "+
                        "where tlabel_extractid = ?";

                Results myResults = new Results(query, textract_sysuid, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Tlabel(Integer.parseInt(dataRow[0])).deleteTlabel(conn);
                }

                myResults.close();

        }
	/**
	 * Checks to see if a Tlabel with the same  combination already exists.
	 * @param myTlabel	the Tlabel object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the tlabel_sysuid of a Tlabel that currently exists
	 */
	public int checkRecordExists(Tlabel myTlabel, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select tlabel_sysuid "+
			"from Tlabel "+
			"where  = ?";

		PreparedStatement pstmt = conn.prepareStatement(query,
			ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_UPDATABLE);


		ResultSet rs = pstmt.executeQuery();

		int pk = (rs.next() ? rs.getInt(1) : -1);
		pstmt.close();
		return pk;
	}

	/**
	 * Creates an array of Tlabel objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Tlabel
	 * @return	An array of Tlabel objects with their values setup 
	 */
	private Tlabel[] setupTlabelValues(Results myResults) {

		//log.debug("in setupTlabelValues");

		List<Tlabel> TlabelList = new ArrayList<Tlabel>();

		Object[] dataRow;

		while ((dataRow = myResults.getNextRowWithClob()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Tlabel thisTlabel = new Tlabel();

			thisTlabel.setTlabel_sysuid(Integer.parseInt((String)dataRow[0]));
			thisTlabel.setTlabel_id((String)dataRow[1]);
			thisTlabel.setTlabel_desc(myResults.getClobAsString(dataRow[2]));
			if (dataRow[3] != null && !((String)dataRow[3]).equals("")) {  
				thisTlabel.setTlabel_protocolid(Integer.parseInt((String)dataRow[3]));
			}
			thisTlabel.setTlabel_extractid(Integer.parseInt((String)dataRow[4]));
			thisTlabel.setTlabel_del_status((String)dataRow[5]);
			thisTlabel.setTlabel_user((String)dataRow[6]);
			thisTlabel.setTlabel_last_change(new ObjectHandler().getOracleDateAsTimestamp((String)dataRow[7]));
			thisTlabel.setTlabel_exp_name((String)dataRow[8]);

			TlabelList.add(thisTlabel);
		}

		Tlabel[] TlabelArray = (Tlabel[]) TlabelList.toArray(new Tlabel[TlabelList.size()]);

		return TlabelArray;
	}

	/**
	 * Compares Tlabel based on different fields.
	 */
	public class TlabelSortComparator implements Comparator<Tlabel> {
		int compare;
		Tlabel tlabel1, tlabel2;

		public int compare(Tlabel object1, Tlabel object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				tlabel1 = object1;
				tlabel2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				tlabel2 = object1;
				tlabel1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("tlabel1 = " +tlabel1+ "tlabel2 = " +tlabel2);

			if (sortColumn.equals("tlabel_sysuid")) {
				compare = new Integer(tlabel1.getTlabel_sysuid()).compareTo(new Integer(tlabel2.getTlabel_sysuid()));
			} else if (sortColumn.equals("tlabel_id")) {
				compare = tlabel1.getTlabel_id().compareTo(tlabel2.getTlabel_id());
			} else if (sortColumn.equals("tlabel_desc")) {
				compare = tlabel1.getTlabel_desc().compareTo(tlabel2.getTlabel_desc());
			} else if (sortColumn.equals("tlabel_protocolid")) {
				compare = new Integer(tlabel1.getTlabel_protocolid()).compareTo(new Integer(tlabel2.getTlabel_protocolid()));
			} else if (sortColumn.equals("tlabel_extractid")) {
				compare = new Integer(tlabel1.getTlabel_extractid()).compareTo(new Integer(tlabel2.getTlabel_extractid()));
			} else if (sortColumn.equals("tlabel_del_status")) {
				compare = tlabel1.getTlabel_del_status().compareTo(tlabel2.getTlabel_del_status());
			} else if (sortColumn.equals("tlabel_user")) {
				compare = tlabel1.getTlabel_user().compareTo(tlabel2.getTlabel_user());
			} else if (sortColumn.equals("tlabel_last_change")) {
				compare = tlabel1.getTlabel_last_change().compareTo(tlabel2.getTlabel_last_change());
			}
			return compare;
		}
	}

	public Tlabel[] sortTlabel (Tlabel[] myTlabel, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myTlabel, new TlabelSortComparator());
		return myTlabel;
	}


	/**
	 * Converts Tlabel object to a String.
	 */
	public String toString() {
		return "This Tlabel has tlabel_sysuid = " + tlabel_sysuid;
	}

	/**
	 * Prints Tlabel object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Tlabel objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Tlabel)) return false;
		return (this.tlabel_sysuid == ((Tlabel)obj).tlabel_sysuid);

	}
}
