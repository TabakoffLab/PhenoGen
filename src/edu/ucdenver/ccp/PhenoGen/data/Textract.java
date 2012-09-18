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
 * Class for handling data related to Textract
 *  @author  Cheryl Hornbaker
 */

public class Textract {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();

	public Textract() {
		log = Logger.getRootLogger();
	}

	public Textract(int textract_sysuid) {
		log = Logger.getRootLogger();
		this.setTextract_sysuid(textract_sysuid);
	}


	private int textract_sysuid;
	private String textract_id;
	private int textract_protocolid;
	private int textract_pool_protocolid;
	private String textract_del_status = "U";
	private String textract_user;
	private String textract_exp_name;
	private java.sql.Timestamp textract_last_change;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setTextract_sysuid(int inInt) {
		this.textract_sysuid = inInt;
	}

	public int getTextract_sysuid() {
		return this.textract_sysuid;
	}

	public void setTextract_id(String inString) {
		this.textract_id = inString;
	}

	public String getTextract_id() {
		return this.textract_id;
	}

	public void setTextract_protocolid(int inInt) {
		this.textract_protocolid = inInt;
	}

	public int getTextract_protocolid() {
		return this.textract_protocolid;
	}

	public void setTextract_pool_protocolid(int inInt) {
		this.textract_pool_protocolid = inInt;
	}

	public int getTextract_pool_protocolid() {
		return this.textract_pool_protocolid;
	}

	public void setTextract_del_status(String inString) {
		this.textract_del_status = inString;
	}

	public String getTextract_del_status() {
		return this.textract_del_status;
	}

	public void setTextract_user(String inString) {
		this.textract_user = inString;
	}

	public String getTextract_user() {
		return this.textract_user;
	}

	public void setTextract_exp_name(String inString) {
		this.textract_exp_name = inString;
	}

	public String getTextract_exp_name() {
		return this.textract_exp_name;
	}

	public void setTextract_last_change(java.sql.Timestamp inTimestamp) {
		this.textract_last_change = inTimestamp;
	}

	public java.sql.Timestamp getTextract_last_change() {
		return this.textract_last_change;
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

	public void validateExtract_name(String value, int expID, Connection conn) throws DataException, SQLException {
		log.debug("in validateExtract_name. name = "+value);
		if (myObjectHandler.isEmpty(value)) {
			throw new DataException("ERROR: Extract Name must be entered.");
		} else if (!isUnique(value, expID, conn)) {
			throw new DataException("ERROR: All Extract Names in this experiment must be unique.");
		}
	}

	private boolean isUnique(String extract_name, int expID, Connection conn) throws DataException, SQLException {
		log.debug("checking if Textract isUnique. name = "+extract_name + " and expID = "+expID);
		String query = 
			"select textract_sysuid "+
			"from textract, tpooled, tsample "+
			"where tsample_exprid = ? "+
			"and textract_sysuid = tpooled_extractid "+
			"and tsample_sysuid = tpooled_sampleid "+
			"and textract_id = ?"; 
	
		log.debug("query = " + query);

		Results myResults = new Results(query, new Object[] {expID, extract_name}, conn);

		int existingID = myResults.getIntValueFromFirstRow();

		log.debug("existingID = " + existingID);

		myResults.close();

		return (existingID == -99 ? true : false);
	}

	/**
	 * Gets all the Textract
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Textract objects
	 */
	public Textract[] getAllTextract(Connection conn) throws SQLException {

		log.debug("In getAllTextract");

		String query = 
			"select "+
			"textract_sysuid, textract_id, textract_protocolid, textract_pool_protocolid, textract_del_status, "+
			"textract_user, to_char(textract_last_change, 'dd-MON-yyyy hh24:mi:ss'), exp_name "+
			"from experimentdetails "+ 
			"order by textract_sysuid";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Textract[] myTextract = setupTextractValues(myResults);

		myResults.close();

		return myTextract;
	}

	/**
	 * Gets the Textract object for this textract_sysuid
	 * @param textract_sysuid	 the identifier of the Textract
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Textract object
	 */
	public Textract getTextract(int textract_sysuid, Connection conn) throws SQLException {

		log.debug("In getOne Textract");

		String query = 
			"select "+
			"textract_sysuid, textract_id, textract_protocolid, textract_pool_protocolid, textract_del_status, "+
			"textract_user, to_char(textract_last_change, 'dd-MON-yyyy hh24:mi:ss'), exp_name "+
			"from experimentdetails "+ 
			"where textract_sysuid = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, textract_sysuid, conn);

		Textract myTextract = setupTextractValues(myResults)[0];

		myResults.close();

		return myTextract;
	}

	/**
	 * Creates a record in the Textract table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createTextract(Connection conn) throws SQLException {

		int textract_sysuid = myDbUtils.getUniqueID("Textract_seq", conn);

		log.debug("In create Textract");

		String query = 
			"insert into Textract "+
			"(textract_sysuid, textract_id, textract_protocolid, textract_pool_protocolid, textract_del_status, "+
			"textract_user, textract_last_change) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, textract_sysuid);
		pstmt.setString(2, textract_id);
		myDbUtils.setToNullIfZero(pstmt, 3, textract_protocolid);
		myDbUtils.setToNullIfZero(pstmt, 4, textract_pool_protocolid);
		pstmt.setString(5, "U");
		pstmt.setString(6, textract_user);
		pstmt.setTimestamp(7, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setTextract_sysuid(textract_sysuid);

		return textract_sysuid;
	}

	/**
	 * Updates a record in the Textract table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 

			"update Textract "+
			"set textract_sysuid = ?, textract_id = ?, textract_protocolid = ?, textract_pool_protocolid = ?, textract_del_status = ?, "+
			"textract_user = ?, textract_last_change = ? "+
			"where textract_sysuid = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, textract_sysuid);
		pstmt.setString(2, textract_id);
		myDbUtils.setToNullIfZero(pstmt, 3, textract_protocolid);
		myDbUtils.setToNullIfZero(pstmt, 4, textract_pool_protocolid);
		pstmt.setString(5, textract_del_status);
		pstmt.setString(6, textract_user);
		pstmt.setTimestamp(7, now);
		pstmt.setInt(8, textract_sysuid);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the Textract table and also deletes child records in related tables.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */

	public void deleteTextract(Connection conn) throws SQLException {

		log.info("in deleteTextract");

		//conn.setAutoCommit(false);

		PreparedStatement pstmt = null;
		try {
                        new Tlabel().deleteAllTlabelForTextract(textract_sysuid, conn);
			log.debug("deleting Tpooled with this extract id : " + textract_sysuid);
                        new Tpooled().deleteAllTpooledForTextract(textract_sysuid, conn);

			String query = 
				"delete from Textract " + 
				"where textract_sysuid = ?";

			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

			pstmt.setInt(1, textract_sysuid);
			pstmt.executeQuery();
			pstmt.close();

			//conn.commit();
		} catch (SQLException e) {
			log.debug("error in deleteTextract");
			//conn.rollback();
			pstmt.close();
			throw e;
		}
		//conn.setAutoCommit(true);
	}

        /**
         * Selects the records in the Textract table that are children of Protocol.
         * @param protocol_id       identifier of the Protocol table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public Textract[] getAllTextractForProtocol(int protocol_id, Connection conn) throws SQLException {

                log.info("in getAllTextractForProtocol");

                String query =
			"select "+
			"textract_sysuid, textract_id, textract_protocolid, textract_pool_protocolid, textract_del_status, "+
			"textract_user, "+
			"to_char(textract_last_change, 'dd-MON-yyyy hh24:mi:ss'), exp_name "+
			"from experimentdetails "+ 
                        "where (textract_protocolid = ? or "+
                        "textract_pool_protocolid = ?) "+
			"and textract_del_status = 'U' "+
			"order by textract_id";

		log.debug("query =  " + query);

                Results myResults = new Results(query, new Object[] {protocol_id, protocol_id}, conn);

		Textract[] myTextract = setupTextractValues(myResults);

		myResults.close();

		return myTextract;

        }

        /**
         * Deletes the records in the Textract table that are children of Protocol.
         * @param protocol_id       identifier of the Protocol table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTextractForProtocol(int protocol_id, Connection conn) throws SQLException {

                log.info("in deleteAllTextractForProtocol");

                //Make sure committing is handled in calling method!

                String query =
                        "select textract_sysuid "+
                        "from Textract "+
                        "where textract_protocolid = ? "+
                        "or textract_pool_protocolid = ?";

                Results myResults = new Results(query, new Object[] {protocol_id, protocol_id}, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Textract(Integer.parseInt(dataRow[0])).deleteTextract(conn);
                }

                myResults.close();

        }

	/**
	 * Checks to see if a Textract with the same  combination already exists.
	 * @param myTextract	the Textract object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the textract_sysuid of a Textract that currently exists
	 */
	public int checkRecordExists(Textract myTextract, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select textract_sysuid "+
			"from Textract "+
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
	 * Creates an array of Textract objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Textract
	 * @return	An array of Textract objects with their values setup 
	 */
	private Textract[] setupTextractValues(Results myResults) {

		//log.debug("in setupTextractValues");

		List<Textract> TextractList = new ArrayList<Textract>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Textract thisTextract = new Textract();

			thisTextract.setTextract_sysuid(Integer.parseInt(dataRow[0]));
			thisTextract.setTextract_id(dataRow[1]);
			if (dataRow[2] != null && !dataRow[2].equals("")) {  
				thisTextract.setTextract_protocolid(Integer.parseInt(dataRow[2]));
			}
			if (dataRow[3] != null && !dataRow[3].equals("")) {  
				thisTextract.setTextract_pool_protocolid(Integer.parseInt(dataRow[3]));
			}
			thisTextract.setTextract_del_status(dataRow[4]);
			thisTextract.setTextract_user(dataRow[5]);
			thisTextract.setTextract_last_change(new ObjectHandler().getOracleDateAsTimestamp(dataRow[6]));
			thisTextract.setTextract_exp_name(dataRow[7]);

			TextractList.add(thisTextract);
		}

		Textract[] TextractArray = (Textract[]) TextractList.toArray(new Textract[TextractList.size()]);

		return TextractArray;
	}

	/**
	 * Compares Textract based on different fields.
	 */
	public class TextractSortComparator implements Comparator<Textract> {
		int compare;
		Textract textract1, textract2;

		public int compare(Textract object1, Textract object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				textract1 = object1;
				textract2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				textract2 = object1;
				textract1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("textract1 = " +textract1+ "textract2 = " +textract2);

			if (sortColumn.equals("textract_sysuid")) {
				compare = new Integer(textract1.getTextract_sysuid()).compareTo(new Integer(textract2.getTextract_sysuid()));
			} else if (sortColumn.equals("textract_id")) {
				compare = textract1.getTextract_id().compareTo(textract2.getTextract_id());
			} else if (sortColumn.equals("textract_protocolid")) {
				compare = new Integer(textract1.getTextract_protocolid()).compareTo(new Integer(textract2.getTextract_protocolid()));
			} else if (sortColumn.equals("textract_pool_protocolid")) {
				compare = new Integer(textract1.getTextract_pool_protocolid()).compareTo(new Integer(textract2.getTextract_pool_protocolid()));
			} else if (sortColumn.equals("textract_del_status")) {
				compare = textract1.getTextract_del_status().compareTo(textract2.getTextract_del_status());
			} else if (sortColumn.equals("textract_user")) {
				compare = textract1.getTextract_user().compareTo(textract2.getTextract_user());
			} else if (sortColumn.equals("textract_last_change")) {
				compare = textract1.getTextract_last_change().compareTo(textract2.getTextract_last_change());
			}
			return compare;
		}
	}

	public Textract[] sortTextract (Textract[] myTextract, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myTextract, new TextractSortComparator());
		return myTextract;
	}


	/**
	 * Converts Textract object to a String.
	 */
	public String toString() {
		return "This Textract has textract_sysuid = " + textract_sysuid;
	}

	/**
	 * Prints Textract object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Textract objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Textract)) return false;
		return (this.textract_sysuid == ((Textract)obj).textract_sysuid);

	}
}
