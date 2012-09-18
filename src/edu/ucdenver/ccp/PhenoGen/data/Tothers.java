package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Hashtable;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

import edu.ucdenver.ccp.util.Debugger;

import edu.ucdenver.ccp.util.ObjectHandler;

import edu.ucdenver.ccp.util.sql.Results;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to Tothers
 *  @author  Cheryl Hornbaker
 */

public class Tothers {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();

	public Tothers() {
		log = Logger.getRootLogger();
	}

	public Tothers(int tothers_sysuid) {
		log = Logger.getRootLogger();
		this.setTothers_sysuid(tothers_sysuid);
	}


	private int tothers_sysuid;
	private String tothers_id;
	private String tothers_value;
	private String tothers_descr;
	private int tothers_exprid;
	private int tothers_sampleid;
	private int tothers_publicid;
	private int tothers_qcid;
	private int tothers_tardesinid;
	private int tothers_tareltypid;
	private int tothers_header_prtclid;
	private int tothers_detail_prtclid;
	private String tothers_del_status;
	private String tothers_user;
	private java.sql.Timestamp tothers_last_change;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setTothers_sysuid(int inInt) {
		this.tothers_sysuid = inInt;
	}

	public int getTothers_sysuid() {
		return this.tothers_sysuid;
	}

	public void setTothers_id(String inString) {
		this.tothers_id = inString;
	}

	public String getTothers_id() {
		return this.tothers_id;
	}

	public void setTothers_value(String inString) {
		this.tothers_value = inString;
	}

	public String getTothers_value() {
		return this.tothers_value;
	}

	public void setTothers_descr(String inString) {
		this.tothers_descr = inString;
	}

	public String getTothers_descr() {
		return this.tothers_descr;
	}

	public void setTothers_exprid(int inInt) {
		this.tothers_exprid = inInt;
	}

	public int getTothers_exprid() {
		return this.tothers_exprid;
	}

	public void setTothers_sampleid(int inInt) {
		this.tothers_sampleid = inInt;
	}

	public int getTothers_sampleid() {
		return this.tothers_sampleid;
	}

	public void setTothers_publicid(int inInt) {
		this.tothers_publicid = inInt;
	}

	public int getTothers_publicid() {
		return this.tothers_publicid;
	}

	public void setTothers_qcid(int inInt) {
		this.tothers_qcid = inInt;
	}

	public int getTothers_qcid() {
		return this.tothers_qcid;
	}

	public void setTothers_tardesinid(int inInt) {
		this.tothers_tardesinid = inInt;
	}

	public int getTothers_tardesinid() {
		return this.tothers_tardesinid;
	}

	public void setTothers_tareltypid(int inInt) {
		this.tothers_tareltypid = inInt;
	}

	public int getTothers_tareltypid() {
		return this.tothers_tareltypid;
	}

	public void setTothers_header_prtclid(int inInt) {
		this.tothers_header_prtclid = inInt;
	}

	public int getTothers_header_prtclid() {
		return this.tothers_header_prtclid;
	}

	public void setTothers_detail_prtclid(int inInt) {
		this.tothers_detail_prtclid = inInt;
	}

	public int getTothers_detail_prtclid() {
		return this.tothers_detail_prtclid;
	}

	public void setTothers_del_status(String inString) {
		this.tothers_del_status = inString;
	}

	public String getTothers_del_status() {
		return this.tothers_del_status;
	}

	public void setTothers_user(String inString) {
		this.tothers_user = inString;
	}

	public String getTothers_user() {
		return this.tothers_user;
	}

	public void setTothers_last_change(java.sql.Timestamp inTimestamp) {
		this.tothers_last_change = inTimestamp;
	}

	public java.sql.Timestamp getTothers_last_change() {
		return this.tothers_last_change;
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
	 * Gets all Tothers for a sample ID and Type
	 * @param sampleID	the identifier of the sample
	 * @param type	the type of tothers record
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tothers record
	 */
	public Tothers getTothersForSampleByType(int sampleID, String type, Connection conn) throws SQLException {

		log.debug("In getTothersForSample. sampleID=" + sampleID + ", type = " + type);

		String query = 
			"select "+
			"tothers_sysuid, tothers_id, tothers_value, tothers_descr, tothers_exprid, "+
			"tothers_sampleid, tothers_publicid, tothers_qcid, tothers_tardesinid, tothers_tareltypid, "+
			"tothers_header_prtclid, tothers_detail_prtclid, tothers_del_status, tothers_user, to_char(tothers_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tothers "+ 
			"where tothers_del_status = 'U' "+
			"and tothers_sampleid = ? "+
			"and tothers_id = ? "+
			"order by tothers_id, tothers_value";

		log.debug("query =  " + query);

		Results myResults = new Results(query, new Object[] {sampleID, type}, conn);

		Tothers myTother = (myResults != null && myResults.getNumRows() > 0 ? setupTothersValues(myResults)[0] : null);

		myResults.close();

		return myTother;
	}

	/**
	 * Gets all Tothers for an exp ID and Type
	 * @param expID	the identifier of the experiment
	 * @param type	the type of tothers record
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tothers record
	 */
	public Tothers getTothersForExpByType(int expID, String type, Connection conn) throws SQLException {

		log.debug("In getTothersForExp. expID=" + expID + ", type = " + type);

		String query = 
			"select "+
			"tothers_sysuid, tothers_id, tothers_value, tothers_descr, tothers_exprid, "+
			"tothers_sampleid, tothers_publicid, tothers_qcid, tothers_tardesinid, tothers_tareltypid, "+
			"tothers_header_prtclid, tothers_detail_prtclid, tothers_del_status, tothers_user, to_char(tothers_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tothers "+ 
			"where tothers_del_status = 'U' "+
			"and tothers_exprid = ? "+
			"and tothers_id = ? "+
			"order by tothers_id, tothers_value";

		log.debug("query =  " + query);

		Results myResults = new Results(query, new Object[] {expID, type}, conn);

		Tothers myTother = (myResults != null && myResults.getNumRows() > 0 ? setupTothersValues(myResults)[0] : null);

		myResults.close();

		return myTother;
	}

	/**
	 * Gets all the Tothers
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Tothers objects
	 */
	public Tothers[] getAllTothers(Connection conn) throws SQLException {

		log.debug("In getAllTothers");

		String query = 
			"select "+
			"tothers_sysuid, tothers_id, tothers_value, tothers_descr, tothers_exprid, "+
			"tothers_sampleid, tothers_publicid, tothers_qcid, tothers_tardesinid, tothers_tareltypid, "+
			"tothers_header_prtclid, tothers_detail_prtclid, tothers_del_status, tothers_user, to_char(tothers_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tothers "+ 
			"order by tothers_id, tothers_value";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Tothers[] myTothers = setupTothersValues(myResults);

		myResults.close();

		return myTothers;
	}

	/**
	 * Gets the Tothers object for this tothers_sysuid
	 * @param tothers_sysuid	 the identifier of the Tothers
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tothers object
	 */
	public Tothers getTothers(int tothers_sysuid, Connection conn) throws SQLException {

		log.debug("In getOne Tothers");

		String query = 
			"select "+
			"tothers_sysuid, tothers_id, tothers_value, tothers_descr, tothers_exprid, "+
			"tothers_sampleid, tothers_publicid, tothers_qcid, tothers_tardesinid, tothers_tareltypid, "+
			"tothers_header_prtclid, tothers_detail_prtclid, tothers_del_status, tothers_user, to_char(tothers_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tothers "+ 
			"where tothers_sysuid = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, tothers_sysuid, conn);

		Tothers myTothers = setupTothersValues(myResults)[0];

		myResults.close();

		return myTothers;
	}

	/**
	 * Creates a record in the Tothers table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createTothers(Connection conn) throws SQLException {

		log.debug("In create Tothers");

		int tothers_sysuid = myDbUtils.getUniqueID("Tothers_seq", conn);

		String query = 
			"insert into Tothers "+
			"(tothers_sysuid, tothers_id, tothers_value, tothers_descr, tothers_exprid, "+
			"tothers_sampleid, tothers_publicid, tothers_qcid, tothers_tardesinid, tothers_tareltypid, "+
			"tothers_header_prtclid, tothers_detail_prtclid, tothers_del_status, tothers_user, tothers_last_change) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?, ?, ?, ?, "+
			"?, ?, ?, ?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tothers_sysuid);
		pstmt.setString(2, tothers_id);
		pstmt.setString(3, tothers_value);
		pstmt.setString(4, tothers_descr);
		pstmt.setInt(5, tothers_exprid);
		pstmt.setInt(6, tothers_sampleid);
		pstmt.setInt(7, tothers_publicid);
		pstmt.setInt(8, tothers_qcid);
		pstmt.setInt(9, tothers_tardesinid);
		pstmt.setInt(10, tothers_tareltypid);
		pstmt.setInt(11, tothers_header_prtclid);
		pstmt.setInt(12, tothers_detail_prtclid);
		pstmt.setString(13, "U");
		pstmt.setString(14, tothers_user);
		pstmt.setTimestamp(15, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setTothers_sysuid(tothers_sysuid);

		return tothers_sysuid;
	}

	/**
	 * Updates the sample id of a record in the Tothers table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void updateTothers_sampleid(Connection conn) throws SQLException {

		log.debug("in updateTothers_sampleid.  sysuid = " + tothers_sysuid + ", and sampleid = " + tothers_sampleid);
		String query = 
			"update Tothers "+
			"set tothers_sampleid = ?, tothers_last_change = ? "+
			"where tothers_sysuid = ?";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tothers_sampleid);
		pstmt.setTimestamp(2, now);
		pstmt.setInt(3, tothers_sysuid);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Updates a record in the Tothers table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		log.debug("in update tothers.  sysuid = " + tothers_sysuid + ", and sampleid = " + tothers_sampleid);
		String query = 
			"update Tothers "+
			"set tothers_sysuid = ?, tothers_id = ?, tothers_value = ?, tothers_descr = ?, tothers_exprid = ?, "+
			"tothers_sampleid = ?, tothers_publicid = ?, tothers_qcid = ?, tothers_tardesinid = ?, tothers_tareltypid = ?, "+
			"tothers_header_prtclid = ?, tothers_detail_prtclid = ?, tothers_del_status = ?, tothers_user = ?, tothers_last_change = ? "+
			"where tothers_sysuid = ?";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tothers_sysuid);
		pstmt.setString(2, tothers_id);
		pstmt.setString(3, tothers_value);
		pstmt.setString(4, tothers_descr);
		pstmt.setInt(5, tothers_exprid);
		pstmt.setInt(6, tothers_sampleid);
		pstmt.setInt(7, tothers_publicid);
		pstmt.setInt(8, tothers_qcid);
		pstmt.setInt(9, tothers_tardesinid);
		pstmt.setInt(10, tothers_tareltypid);
		pstmt.setInt(11, tothers_header_prtclid);
		pstmt.setInt(12, tothers_detail_prtclid);
		pstmt.setString(13, tothers_del_status);
		pstmt.setString(14, tothers_user);
		pstmt.setTimestamp(15, now);
		pstmt.setInt(16, tothers_sysuid);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the Tothers table and commits it
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */
	public void deleteAndCommit(Connection conn) throws SQLException {
		log.debug("in deleteAndCommit");

		try {
			deleteTothers(conn);
			conn.commit();
		} catch (SQLException e) {
			log.debug("got error deleting Tothers", e);
			conn.rollback();
			throw e;
		}
	}

	/**
	 * Deletes the record in the Tothers table 
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */
	public void deleteTothers(Connection conn) throws SQLException {

		log.info("in deleteTothers");

		String query = 
			"delete from Tothers " + 
			"where tothers_sysuid = ?";

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

		pstmt.setInt(1, tothers_sysuid);
		pstmt.executeQuery();
		pstmt.close();

	}

	/**
	 * Checks to see if a Tothers with the same tothers_sysuid combination already exists.
	 * @param myTothers	the Tothers object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the tothers_sysuid of a Tothers that currently exists
	 */
	public int checkRecordExists(Tothers myTothers, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select tothers_sysuid "+
			"from Tothers "+
			"where tothers_sysuid = ?";

		PreparedStatement pstmt = conn.prepareStatement(query,
			ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tothers_sysuid);

		ResultSet rs = pstmt.executeQuery();

		int pk = (rs.next() ? rs.getInt(1) : -1);
		pstmt.close();
		return pk;
	}

	/**
	 * Creates an array of Tothers objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Tothers
	 * @return	An array of Tothers objects with their values setup 
	 */
	private Tothers[] setupTothersValues(Results myResults) {

		//log.debug("in setupTothersValues");

		List<Tothers> TothersList = new ArrayList<Tothers>();

		Object[] dataRow;

		while ((dataRow = myResults.getNextRowWithClob()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Tothers thisTothers = new Tothers();

			if (dataRow[0] != null && !((String)dataRow[0]).equals("")) {
				thisTothers.setTothers_sysuid(Integer.parseInt((String)dataRow[0]));
			}
			thisTothers.setTothers_id((String)dataRow[1]);
			thisTothers.setTothers_value((String)dataRow[2]);
			thisTothers.setTothers_descr(myResults.getClobAsString(dataRow[3]));
			if (dataRow[4] != null && !((String)dataRow[4]).equals("")) {
				thisTothers.setTothers_exprid(Integer.parseInt((String)dataRow[4]));
			}
			if (dataRow[5] != null && !((String)dataRow[5]).equals("")) {
				thisTothers.setTothers_sampleid(Integer.parseInt((String)dataRow[5]));
			}
			if (dataRow[6] != null && !((String)dataRow[6]).equals("")) {
				thisTothers.setTothers_publicid(Integer.parseInt((String)dataRow[6]));
			}
			if (dataRow[7] != null && !((String)dataRow[7]).equals("")) {
				thisTothers.setTothers_qcid(Integer.parseInt((String)dataRow[7]));
			}
			if (dataRow[8] != null && !((String)dataRow[8]).equals("")) {
				thisTothers.setTothers_tardesinid(Integer.parseInt((String)dataRow[8]));
			}
			if (dataRow[9] != null && !((String)dataRow[9]).equals("")) {
				thisTothers.setTothers_tareltypid(Integer.parseInt((String)dataRow[9]));
			}
			if (dataRow[10] != null && !((String)dataRow[10]).equals("")) {
				thisTothers.setTothers_header_prtclid(Integer.parseInt((String)dataRow[10]));
			}
			if (dataRow[11] != null && !((String)dataRow[11]).equals("")) {
				thisTothers.setTothers_detail_prtclid(Integer.parseInt((String)dataRow[11]));
			}
			thisTothers.setTothers_del_status((String)dataRow[12]);
			thisTothers.setTothers_user((String)dataRow[13]);
			thisTothers.setTothers_last_change(new ObjectHandler().getOracleDateAsTimestamp((String)dataRow[14]));

			TothersList.add(thisTothers);
		}

		Tothers[] TothersArray = (Tothers[]) TothersList.toArray(new Tothers[TothersList.size()]);

		return TothersArray;
	}

	/**
	 * Compares Tothers based on different fields.
	 */
	public class TothersSortComparator implements Comparator<Tothers> {
		int compare;
		Tothers tothers1, tothers2;

		public int compare(Tothers object1, Tothers object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				tothers1 = object1;
				tothers2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				tothers2 = object1;
				tothers1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("tothers1 = " +tothers1+ "tothers2 = " +tothers2);

			if (sortColumn.equals("tothers_sysuid")) {
				compare = new Integer(tothers1.getTothers_sysuid()).compareTo(new Integer(tothers2.getTothers_sysuid()));
			} else if (sortColumn.equals("tothers_id")) {
				compare = tothers1.getTothers_id().compareTo(tothers2.getTothers_id());
			} else if (sortColumn.equals("tothers_value")) {
				compare = tothers1.getTothers_value().compareTo(tothers2.getTothers_value());
			} else if (sortColumn.equals("tothers_descr")) {
				compare = tothers1.getTothers_descr().compareTo(tothers2.getTothers_descr());
			} else if (sortColumn.equals("tothers_exprid")) {
				compare = new Integer(tothers1.getTothers_exprid()).compareTo(new Integer(tothers2.getTothers_exprid()));
			} else if (sortColumn.equals("tothers_sampleid")) {
				compare = new Integer(tothers1.getTothers_sampleid()).compareTo(new Integer(tothers2.getTothers_sampleid()));
			} else if (sortColumn.equals("tothers_publicid")) {
				compare = new Integer(tothers1.getTothers_publicid()).compareTo(new Integer(tothers2.getTothers_publicid()));
			} else if (sortColumn.equals("tothers_qcid")) {
				compare = new Integer(tothers1.getTothers_qcid()).compareTo(new Integer(tothers2.getTothers_qcid()));
			} else if (sortColumn.equals("tothers_tardesinid")) {
				compare = new Integer(tothers1.getTothers_tardesinid()).compareTo(new Integer(tothers2.getTothers_tardesinid()));
			} else if (sortColumn.equals("tothers_tareltypid")) {
				compare = new Integer(tothers1.getTothers_tareltypid()).compareTo(new Integer(tothers2.getTothers_tareltypid()));
			} else if (sortColumn.equals("tothers_header_prtclid")) {
				compare = new Integer(tothers1.getTothers_header_prtclid()).compareTo(new Integer(tothers2.getTothers_header_prtclid()));
			} else if (sortColumn.equals("tothers_detail_prtclid")) {
				compare = new Integer(tothers1.getTothers_detail_prtclid()).compareTo(new Integer(tothers2.getTothers_detail_prtclid()));
			} else if (sortColumn.equals("tothers_del_status")) {
				compare = tothers1.getTothers_del_status().compareTo(tothers2.getTothers_del_status());
			} else if (sortColumn.equals("tothers_user")) {
				compare = tothers1.getTothers_user().compareTo(tothers2.getTothers_user());
			} else if (sortColumn.equals("tothers_last_change")) {
				compare = tothers1.getTothers_last_change().compareTo(tothers2.getTothers_last_change());
			}
			return compare;
		}
	}

	public Tothers[] sortTothers (Tothers[] myTothers, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myTothers, new TothersSortComparator());
		return myTothers;
	}


	/**
	 * Converts Tothers object to a String.
	 */
	public String toString() {
		return "This Tothers has tothers_sysuid = " + tothers_sysuid;
	}

	/**
	 * Prints Tothers object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Tothers objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Tothers)) return false;
		return (this.tothers_sysuid == ((Tothers)obj).tothers_sysuid);

	}
}
