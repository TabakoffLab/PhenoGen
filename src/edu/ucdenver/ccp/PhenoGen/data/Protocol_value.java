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
 * Class for handling data related to Protocol_values
 *  @author  Cheryl Hornbaker
 */

public class Protocol_value {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public Protocol_value() {
		log = Logger.getRootLogger();
	}

	public Protocol_value(int value_id) {
		log = Logger.getRootLogger();
		this.setValue_id(value_id);
	}


	private int value_id;
	private int protocol_id;
	private int value_type;
	private String value;
	private String description;
	private String created_by_login;
	private java.sql.Timestamp create_date;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setValue_id(int inInt) {
		this.value_id = inInt;
	}

	public int getValue_id() {
		return this.value_id;
	}

	public void setProtocol_id(int inInt) {
		this.protocol_id = inInt;
	}

	public int getProtocol_id() {
		return this.protocol_id;
	}

	public void setValue_type(int inInt) {
		this.value_type = inInt;
	}

	public int getValue_type() {
		return this.value_type;
	}

	public void setValue(String inString) {
		this.value = inString;
	}

	public String getValue() {
		return this.value;
	}

	public void setDescription(String inString) {
		this.description = inString;
	}

	public String getDescription() {
		return this.description;
	}

	public void setCreated_by_login(String inString) {
		this.created_by_login = inString;
	}

	public String getCreated_by_login() {
		return this.created_by_login;
	}

	public void setCreate_date(java.sql.Timestamp inTimestamp) {
		this.create_date = inTimestamp;
	}

	public java.sql.Timestamp getCreate_date() {
		return this.create_date;
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
	 * Gets all the Protocol_values
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Protocol_value objects
	 */
	public Protocol_value[] getAllProtocol_values(Connection conn) throws SQLException {

		log.debug("In getAllProtocol_values");

		String query = 
			"select "+
			"value_id, protocol_id, value_type, value, description, "+
			"created_by_login, to_char(create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from protocol_values "+ 
			"order by value_id";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Protocol_value[] myProtocol_values = setupProtocol_valueValues(myResults);

		myResults.close();

		return myProtocol_values;
	}

	/**
	 * Gets the Protocol_value object for this value_id
	 * @param value_id	 the identifier of the Protocol_value
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Protocol_value object
	 */
	public Protocol_value getProtocol_value(int value_id, Connection conn) throws SQLException {

		log.debug("In getOne Protocol_value");

		String query = 
			"select "+
			"value_id, protocol_id, value_type, value, description, "+
			"created_by_login, to_char(create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from protocol_values "+ 
			"where value_id = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, value_id, conn);

		Protocol_value myProtocol_value = setupProtocol_valueValues(myResults)[0];

		myResults.close();

		return myProtocol_value;
	}

	/**
	 * Creates a record in the Protocol_values table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createProtocol_value(Connection conn) throws SQLException {

		log.debug("In create Protocol_values");

		int value_id = myDbUtils.getUniqueID("protocol_values_seq", conn);

		String query = 
			"insert into protocol_values "+
			"(value_id, protocol_id, value_type, value, description, "+
			"created_by_login, create_date) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, value_id);
		pstmt.setInt(2, protocol_id);
		pstmt.setInt(3, value_type);
		pstmt.setString(4, value);
		pstmt.setString(5, description);
		pstmt.setString(6, created_by_login);
		pstmt.setTimestamp(7, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setValue_id(value_id);

		return value_id;
	}

	/**
	 * Updates a record in the Protocol_values table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 
			"update protocol_values "+
			"set value_id = ?, protocol_id = ?, value_type = ?, value = ?, description = ?, "+
			"created_by_login = ?, create_date = ? "+
			"where value_id = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, value_id);
		pstmt.setInt(2, protocol_id);
		pstmt.setInt(3, value_type);
		pstmt.setString(4, value);
		pstmt.setString(5, description);
		pstmt.setString(6, created_by_login);
		pstmt.setTimestamp(7, now);
		pstmt.setInt(8, value_id);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the Protocol_values table and also deletes child records in related tables.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */
	public void deleteProtocol_value(Connection conn) throws SQLException {

		//log.info("in deleteProtocol_values");

		//conn.setAutoCommit(false);

		PreparedStatement pstmt = null;
		try {


			String query = 
				"delete from protocol_values " + 
				"where value_id = ?";

			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

			pstmt.setInt(1, value_id);
			pstmt.executeQuery();
			pstmt.close();

			//conn.commit();
		} catch (SQLException e) {
			log.debug("error in deleteProtocol_values");
			//conn.rollback();
			pstmt.close();
			throw e;
		}
		//conn.setAutoCommit(true);
	}

	/**
	 * Deletes the records in the Protocol_values table that are children of Protocol.
	 * @param protocol_id	identifier of the Protocol table
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */
	public void deleteAllProtocol_valuesForProtocol(int protocol_id, Connection conn) throws SQLException {

		log.info("in deleteAllProtocol_valuesForProtocol");

		//Make sure committing is handled in calling method!

		String query = 
			"select value_id "+
			"from protocol_values "+
			"where protocol_id = ?";

		Results myResults = new Results(query, protocol_id, conn);

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {
			new Protocol_value(Integer.parseInt(dataRow[0])).deleteProtocol_value(conn);
		}

		myResults.close();

	}

	/**
	 * Checks to see if a Protocol_value with the same  combination already exists.
	 * @param myProtocol_value	the Protocol_value object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the value_id of a Protocol_value that currently exists
	 */
	public int checkRecordExists(Protocol_value myProtocol_value, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select value_id "+
			"from protocol_values "+
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
	 * Creates an array of Protocol_value objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Protocol_values
	 * @return	An array of Protocol_value objects with their values setup 
	 */
	private Protocol_value[] setupProtocol_valueValues(Results myResults) {

		//log.debug("in setupProtocol_valueValues");

		List<Protocol_value> Protocol_valuesList = new ArrayList<Protocol_value>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Protocol_value thisProtocol_value = new Protocol_value();

			thisProtocol_value.setValue_id(Integer.parseInt(dataRow[0]));
			thisProtocol_value.setProtocol_id(Integer.parseInt(dataRow[1]));
			thisProtocol_value.setValue_type(Integer.parseInt(dataRow[2]));
			thisProtocol_value.setValue(dataRow[3]);
			thisProtocol_value.setDescription(dataRow[4]);
			thisProtocol_value.setCreated_by_login(dataRow[5]);
			thisProtocol_value.setCreate_date(new ObjectHandler().getOracleDateAsTimestamp(dataRow[6]));

			Protocol_valuesList.add(thisProtocol_value);
		}

		Protocol_value[] Protocol_valuesArray = (Protocol_value[]) Protocol_valuesList.toArray(new Protocol_value[Protocol_valuesList.size()]);

		return Protocol_valuesArray;
	}

	/**
	 * Compares Protocol_value objects based on different fields.
	 */
	public class Protocol_valueSortComparator implements Comparator<Protocol_value> {
		int compare;
		Protocol_value protocol_value1, protocol_value2;

		public int compare(Protocol_value object1, Protocol_value object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				protocol_value1 = object1;
				protocol_value2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				protocol_value2 = object1;
				protocol_value1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("protocol_value1 = " +protocol_value1+ "protocol_value2 = " +protocol_value2);

			if (sortColumn.equals("value_id")) {
				compare = new Integer(protocol_value1.getValue_id()).compareTo(new Integer(protocol_value2.getValue_id()));
			} else if (sortColumn.equals("protocol_id")) {
				compare = new Integer(protocol_value1.getProtocol_id()).compareTo(new Integer(protocol_value2.getProtocol_id()));
			} else if (sortColumn.equals("value_type")) {
				compare = new Integer(protocol_value1.getValue_type()).compareTo(new Integer(protocol_value2.getValue_type()));
			} else if (sortColumn.equals("value")) {
				compare = protocol_value1.getValue().compareTo(protocol_value2.getValue());
			} else if (sortColumn.equals("description")) {
				compare = protocol_value1.getDescription().compareTo(protocol_value2.getDescription());
			} else if (sortColumn.equals("created_by_login")) {
				compare = protocol_value1.getCreated_by_login().compareTo(protocol_value2.getCreated_by_login());
			} else if (sortColumn.equals("create_date")) {
				compare = protocol_value1.getCreate_date().compareTo(protocol_value2.getCreate_date());
			}
			return compare;
		}
	}

	public Protocol_value[] sortProtocol_values (Protocol_value[] myProtocol_values, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myProtocol_values, new Protocol_valueSortComparator());
		return myProtocol_values;
	}


	/**
	 * Converts Protocol_value object to a String.
	 */
	public String toString() {
		return "This Protocol_value has value_id = " + value_id;
	}

	/**
	 * Prints Protocol_value object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Protocol_value objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Protocol_value)) return false;
		return (this.value_id == ((Protocol_value)obj).value_id);

	}
}
