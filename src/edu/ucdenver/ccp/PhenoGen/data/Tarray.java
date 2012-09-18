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
 * Class for handling data related to Tarray
 *  @author  Cheryl Hornbaker
 */

public class Tarray {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public Tarray() {
		log = Logger.getRootLogger();
	}

	public Tarray(int tarray_sysuid) {
		log = Logger.getRootLogger();
		this.setTarray_sysuid(tarray_sysuid);
	}


	private int tarray_sysuid;
	private String tarray_id;
	private String tarray_batchno;
	private int tarray_designid;
	private java.sql.Timestamp tarray_prod_date;
	private String tarray_del_status;
	private String tarray_user;
	private java.sql.Timestamp tarray_last_change;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setTarray_sysuid(int inInt) {
		this.tarray_sysuid = inInt;
	}

	public int getTarray_sysuid() {
		return this.tarray_sysuid;
	}

	public void setTarray_id(String inString) {
		this.tarray_id = inString;
	}

	public String getTarray_id() {
		return this.tarray_id;
	}

	public void setTarray_batchno(String inString) {
		this.tarray_batchno = inString;
	}

	public String getTarray_batchno() {
		return this.tarray_batchno;
	}

	public void setTarray_designid(int inInt) {
		this.tarray_designid = inInt;
	}

	public int getTarray_designid() {
		return this.tarray_designid;
	}

	public void setTarray_prod_date(java.sql.Timestamp inTimestamp) {
		this.tarray_prod_date = inTimestamp;
	}

	public java.sql.Timestamp getTarray_prod_date() {
		return this.tarray_prod_date;
	}

	public void setTarray_del_status(String inString) {
		this.tarray_del_status = inString;
	}

	public String getTarray_del_status() {
		return this.tarray_del_status;
	}

	public void setTarray_user(String inString) {
		this.tarray_user = inString;
	}

	public String getTarray_user() {
		return this.tarray_user;
	}

	public void setTarray_last_change(java.sql.Timestamp inTimestamp) {
		this.tarray_last_change = inTimestamp;
	}

	public java.sql.Timestamp getTarray_last_change() {
		return this.tarray_last_change;
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
	 * Gets all the Tarray
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Tarray objects
	 */
	public Tarray[] getAllTarray(Connection conn) throws SQLException {

		log.debug("In getAllTarray");

		String query = 
			"select "+
			"tarray_sysuid, tarray_id, tarray_batchno, tarray_designid, to_char(tarray_prod_date, 'dd-MON-yyyy hh24:mi:ss'), "+
			"tarray_del_status, tarray_user, to_char(tarray_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tarray "+ 
			"order by tarray_sysuid";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Tarray[] myTarray = setupTarrayValues(myResults);

		myResults.close();

		return myTarray;
	}

	/**
	 * Gets the Tarray object for this Tarray_designID
	 * @param tarray_designid	 the designID of the Tarray
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tarray object
	 */
	public Tarray getTarrayForDesignID(int tarray_designid, Connection conn) throws SQLException {

		log.debug("In TarrayForDesignID");

		String query = 
			"select "+
			"tarray_sysuid, tarray_id, tarray_batchno, tarray_designid, to_char(tarray_prod_date, 'dd-MON-yyyy hh24:mi:ss'), "+
			"tarray_del_status, tarray_user, to_char(tarray_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tarray "+ 
			"where tarray_designid = ?";

		log.debug("query =  " + query);

		Results myResults = new Results(query, tarray_designid, conn);
		Tarray myTarray = new Tarray(-99);

		if (myResults != null && myResults.getNumRows() > 0) {
			myTarray = setupTarrayValues(myResults)[0];
		}
		myResults.close();

		return myTarray;
	}

	/**
	 * Gets the Tarray object for this Tarray_sysuid
	 * @param tarray_sysuid	 the identifier of the Tarray
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tarray object
	 */
	public Tarray getTarray(String tarray_sysuid, Connection conn) throws SQLException {

		log.debug("In getOne Tarray");

		String query = 
			"select "+
			"tarray_sysuid, tarray_id, tarray_batchno, tarray_designid, to_char(tarray_prod_date, 'dd-MON-yyyy hh24:mi:ss'), "+
			"tarray_del_status, tarray_user, to_char(tarray_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tarray "+ 
			"where tarray_sysuid = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, tarray_sysuid, conn);

		Tarray myTarray = setupTarrayValues(myResults)[0];

		myResults.close();

		return myTarray;
	}

	/**
	 * Creates a record in the Tarray table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createTarray(Connection conn) throws SQLException {

		log.debug("In create Tarray");

		int tarray_sysuid = myDbUtils.getUniqueID("Tarray_seq", conn);

		String query = 
			"insert into Tarray "+
			"(tarray_sysuid, tarray_id, tarray_batchno, tarray_designid, tarray_prod_date, "+
			"tarray_del_status, tarray_user, tarray_last_change) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tarray_sysuid);
		pstmt.setString(2, tarray_id);
		pstmt.setString(3, tarray_batchno);
		pstmt.setInt(4, tarray_designid);
		pstmt.setTimestamp(5, tarray_prod_date);
		pstmt.setString(6, "U");
		pstmt.setString(7, tarray_user);
		pstmt.setTimestamp(8, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setTarray_sysuid(tarray_sysuid);

		return tarray_sysuid;
	}

	/**
	 * Creates a record in the Tarray table for the designID specified.
	 * @param designID 	the designID of the array
	 * @param userLoggedIn 	the user object creating the record
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createNewTarrayForDesignID(int designID, User userLoggedIn, Connection conn) throws SQLException {

		log.debug("In create Tarray For DesignID");

		Tarray newTarray = new Tarray();
		newTarray.setTarray_designid(designID);
		newTarray.setTarray_user(userLoggedIn.getUser_name_and_domain());

		log.debug("creating a new array");
		int arrayID = newTarray.createTarray(conn);
		log.debug("returning arrayID of " + arrayID);

		return arrayID;
	}

	/**
	 * Creates a record in the Tarray table for the array_design specified.
	 * @param arrayName 	the name of the array
	 * @param user 	the user creating the record
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createNewTarray(String arrayName, String user, Connection conn) throws SQLException {

		log.debug("In create Tarray");

		String query = 
                	"select tardesin_sysuid "+
			"from tardesin "+
			"where tardesin_design_name = ? "+
			"and tardesin_del_status = 'U' ";

                log.debug("query = "+query); 

                Results myResults = new Results(query, new Object[] {arrayName}, conn);

                int designID = myResults.getIntValueFromFirstRow();

                myResults.close();

		log.debug("designID from 1st query is = "+designID);

		if (designID == -99) {
			log.debug("designID is -99");

			query = 
			"select ebi_array_sysuid*-1 "+
			"from ebi_array_designs "+
			"where ebi_array_description = ?";

                	log.debug("query = "+query); 

                	myResults = new Results(query, arrayName, conn);

                	designID = myResults.getIntValueFromFirstRow();

                	myResults.close();
		}

		log.debug("now designID = "+designID);

                myResults.close();

		Tarray newTarray = new Tarray();
		newTarray.setTarray_designid(designID);
		newTarray.setTarray_user(user);

		log.debug("creating a new array");
		int arrayID = newTarray.createTarray(conn);
		log.debug("returning arrayID of " + arrayID);

		return arrayID;
	}

	/**
	 * Updates a record in the Tarray table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 
			"update Tarray "+
			"set tarray_sysuid = ?, tarray_id = ?, tarray_batchno = ?, tarray_designid = ?, tarray_prod_date = ?, "+
			"tarray_del_status = ?, tarray_user = ?, tarray_last_change = ? "+
			"where tarray_sysuid = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tarray_sysuid);
		pstmt.setString(2, tarray_id);
		pstmt.setString(3, tarray_batchno);
		pstmt.setInt(4, tarray_designid);
		pstmt.setTimestamp(5, tarray_prod_date);
		pstmt.setString(6, tarray_del_status);
		pstmt.setString(7, tarray_user);
		pstmt.setTimestamp(8, tarray_last_change);
		pstmt.setInt(9, tarray_sysuid);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the Tarray table and also deletes child records in related tables.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */
	public void deleteTarray(Connection conn) throws SQLException {

		log.info("in deleteTarray");

		//conn.setAutoCommit(false);

		PreparedStatement pstmt = null;
		try {

			String query = 
				"delete from Tarray " + 
				"where tarray_sysuid = ?";

			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

			pstmt.setInt(1, tarray_sysuid);
			pstmt.executeQuery();
			pstmt.close();

			//conn.commit();
		} catch (SQLException e) {
			log.debug("error in deleteTarray");
			//conn.rollback();
			pstmt.close();
			throw e;
		}
		//conn.setAutoCommit(true);
	}

	/**
	 * Checks to see if a Tarray with the same tarray_sysuid combination already exists.
	 * @param myTarray	the Tarray object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the tarray_sysuid of a Tarray that currently exists
	 */
	public int checkRecordExists(Tarray myTarray, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select tarray_sysuid "+
			"from Tarray "+
			"where tarray_sysuid = ?";

		PreparedStatement pstmt = conn.prepareStatement(query,
			ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tarray_sysuid);

		ResultSet rs = pstmt.executeQuery();

		int pk = (rs.next() ? rs.getInt(1) : -1);
		pstmt.close();
		return pk;
	}

	/**
	 * Creates an array of Tarray objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Tarray
	 * @return	An array of Tarray objects with their values setup 
	 */
	private Tarray[] setupTarrayValues(Results myResults) {

		//log.debug("in setupTarrayValues");

		List<Tarray> TarrayList = new ArrayList<Tarray>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Tarray thisTarray = new Tarray();

			if (dataRow[0] != null && !dataRow[0].equals("")) {
				thisTarray.setTarray_sysuid(Integer.parseInt(dataRow[0]));
			}
			thisTarray.setTarray_id(dataRow[1]);
			thisTarray.setTarray_batchno(dataRow[2]);
			if (dataRow[3] != null && !dataRow[3].equals("")) {
				thisTarray.setTarray_designid(Integer.parseInt(dataRow[3]));
			}
			thisTarray.setTarray_prod_date(new ObjectHandler().getOracleDateAsTimestamp(dataRow[4]));
			thisTarray.setTarray_del_status(dataRow[5]);
			thisTarray.setTarray_user(dataRow[6]);
			thisTarray.setTarray_last_change(new ObjectHandler().getOracleDateAsTimestamp(dataRow[7]));

			TarrayList.add(thisTarray);
		}

		Tarray[] TarrayArray = (Tarray[]) TarrayList.toArray(new Tarray[TarrayList.size()]);

		return TarrayArray;
	}

	/**
	 * Compares Tarray based on different fields.
	 */
	public class TarraySortComparator implements Comparator<Tarray> {
		int compare;
		Tarray tarray1, tarray2;

		public int compare(Tarray object1, Tarray object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				tarray1 = object1;
				tarray2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				tarray2 = object1;
				tarray1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("tarray1 = " +tarray1+ "tarray2 = " +tarray2);

			if (sortColumn.equals("tarray_sysuid")) {
				compare = new Integer(tarray1.getTarray_sysuid()).compareTo(new Integer(tarray2.getTarray_sysuid()));
			} else if (sortColumn.equals("tarray_id")) {
				compare = tarray1.getTarray_id().compareTo(tarray2.getTarray_id());
			} else if (sortColumn.equals("tarray_batchno")) {
				compare = tarray1.getTarray_batchno().compareTo(tarray2.getTarray_batchno());
			} else if (sortColumn.equals("tarray_designid")) {
				compare = new Integer(tarray1.getTarray_designid()).compareTo(new Integer(tarray2.getTarray_designid()));
			} else if (sortColumn.equals("tarray_prod_date")) {
				compare = tarray1.getTarray_prod_date().compareTo(tarray2.getTarray_prod_date());
			} else if (sortColumn.equals("tarray_del_status")) {
				compare = tarray1.getTarray_del_status().compareTo(tarray2.getTarray_del_status());
			} else if (sortColumn.equals("tarray_user")) {
				compare = tarray1.getTarray_user().compareTo(tarray2.getTarray_user());
			} else if (sortColumn.equals("tarray_last_change")) {
				compare = tarray1.getTarray_last_change().compareTo(tarray2.getTarray_last_change());
			}
			return compare;
		}
	}

	public Tarray[] sortTarray (Tarray[] myTarray, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myTarray, new TarraySortComparator());
		return myTarray;
	}


	/**
	 * Converts Tarray object to a String.
	 */
	public String toString() {
		return "This Tarray has tarray_sysuid = " + tarray_sysuid;
	}

	/**
	 * Prints Tarray object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Tarray objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Tarray)) return false;
		return (this.tarray_sysuid == ((Tarray)obj).tarray_sysuid);

	}
}
