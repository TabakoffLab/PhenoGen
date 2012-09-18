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
 * Class for handling data related to Hybridization
 *  @author  Cheryl Hornbaker
 */

public class Hybridization {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();

	public Hybridization() {
		log = Logger.getRootLogger();
	}

	public Hybridization(int hybrid_id) {
		log = Logger.getRootLogger();
		this.setHybrid_id(hybrid_id);
	}


	private int hybrid_id;
	private String name;
	private String description;
	private int protocol_id;
	private int scan_protocol_id;
	private int norm_protocol_id;
	private int array_id;
	private String created_by_login;
	private String exp_name;
	private java.sql.Timestamp create_date;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setHybrid_id(int inInt) {
		this.hybrid_id = inInt;
	}

	public int getHybrid_id() {
		return this.hybrid_id;
	}

	public void setName(String inString) {
		this.name = inString;
	}

	public String getName() {
		return this.name;
	}

	public void setDescription(String inString) {
		this.description = inString;
	}

	public String getDescription() {
		return this.description;
	}

	public void setProtocol_id(int inInt) {
		this.protocol_id = inInt;
	}

	public int getProtocol_id() {
		return this.protocol_id;
	}

	public void setScan_protocol_id(int inInt) {
		this.scan_protocol_id = inInt;
	}

	public int getScan_protocol_id() {
		return this.scan_protocol_id;
	}

	public void setNorm_protocol_id(int inInt) {
		this.norm_protocol_id = inInt;
	}

	public int getNorm_protocol_id() {
		return this.norm_protocol_id;
	}

	public void setArray_id(int inInt) {
		this.array_id = inInt;
	}

	public int getArray_id() {
		return this.array_id;
	}

	public void setCreated_by_login(String inString) {
		this.created_by_login = inString;
	}

	public String getCreated_by_login() {
		return this.created_by_login;
	}

	public void setExp_name(String inString) {
		this.exp_name = inString;
	}

	public String getExp_name() {
		return this.exp_name;
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

	public void validateHybrid_id(String hybrid_id, int expID, Connection conn) throws DataException, SQLException {
		log.debug("in validateHybrid_id. hybrid_id = "+hybrid_id);
		if (myObjectHandler.isEmpty(hybrid_id)) {
			throw new DataException("ERROR: Hybrid Name must be entered.");
		} else if (!isUnique(hybrid_id, expID, conn)) {
			throw new DataException("ERROR: Hybrid Names must be unique within this experiment.");
		}
	}

	private boolean isUnique(String hybrid_id, int expID, Connection conn) throws DataException, SQLException {
		log.debug("in Hybridization isUnique. name = "+hybrid_id);
		String query = 
			"select hybrid_id "+
                        "from hybridizations, tlabhyb, tlabel, textract, tpooled, tsample "+
                        "where tsample_exprid = ? "+
                        "and textract_sysuid = tlabel_extractid "+
                        "and textract_sysuid = tpooled_extractid "+
                        "and tsample_sysuid = tpooled_sampleid "+
			"and hybrid_id = tlabhyb_hybridid "+
			"and tlabel_sysuid = tlabhyb_labelid "+
			"and name = ?"; 
	
		Results myResults = new Results(query, new Object[] {expID, hybrid_id}, conn);

		int existingID = myResults.getIntValueFromFirstRow();

		myResults.close();

		log.debug("existingID = "+existingID);
		return (existingID == -99 ? true : false);
	}

	/**
	 * Gets all the Hybridizations
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Hybridization objects
	 */
	public Hybridization[] getAllHybridization(Connection conn) throws SQLException {

		log.debug("In getAllHybridization");

		String query = 
			"select "+
			"hybrid_id, hybrid_name, hybrid_description, hybrid_protocol_id, hybrid_scan_protocol_id, "+
			"hybrid_norm_protocol_id, hybrid_array_id, hybrid_created_by_login, to_char(hybrid_create_date, 'dd-MON-yyyy hh24:mi:ss'), exp_name "+
			"from experimentdetails "+ 
			"order by hybrid_id";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Hybridization[] myHybridization = setupHybridizationValues(myResults);

		myResults.close();

		return myHybridization;
	}

	/**
	 * Gets all the Hybridization for a particular protocol ID.
         * @param protocol_id       identifier of the Protocol table
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Hybridization objects
	 */
	public Hybridization[] getAllHybridizationForProtocol(int protocol_id, Connection conn) throws SQLException {

		log.debug("In getAllHybridizationForProtocol");
		String query = 
			"select "+
			"hybrid_id, hybrid_name, hybrid_description, hybrid_protocol_id, hybrid_scan_protocol_id, "+
			"hybrid_norm_protocol_id, hybrid_array_id, hybrid_created_by_login, to_char(hybrid_create_date, 'dd-MON-yyyy hh24:mi:ss'), exp_name "+
			"from experimentDetails "+ 
                        "where (hybrid_norm_protocol_id = ? "+
                        "or hybrid_scan_protocol_id = ? "+
                        "or hybrid_protocol_id = ?) "+
			"order by hybrid_id";

		//log.debug("query =  " + query);
                Results myResults = new Results(query, new Object[] {protocol_id, protocol_id, protocol_id}, conn);

		Hybridization[] myHybridization = setupHybridizationValues(myResults);

		myResults.close();

		return myHybridization;
	}

	/**
	 * Gets the Hybridization object for this hybrid_id
	 * @param hybrid_id	 the identifier of the Hybridization
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Hybridization object
	 */
	public Hybridization getHybridization(int hybrid_id, Connection conn) throws SQLException {

		log.debug("In getOne Hybridization");

		String query = 
			"select "+
			"hybrid_id, hybrid_name, hybrid_description, hybrid_protocol_id, hybrid_scan_protocol_id, "+
			"hybrid_norm_protocol_id, hybrid_array_id, hybrid_created_by_login, to_char(hybrid_create_date, 'dd-MON-yyyy hh24:mi:ss'), exp_name "+
			"from experimentdetails "+ 
			"where hybrid_id = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, hybrid_id, conn);

		Hybridization myHybridization = setupHybridizationValues(myResults)[0];

		myResults.close();

		return myHybridization;
	}

	/**
	 * Creates a record in the Hybridization table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createHybridization(Connection conn) throws SQLException {

		int hybrid_id = myDbUtils.getUniqueID("hybridizations_seq", conn);

		log.debug("In create Hybridization");

		String query = 
			"insert into hybridizations "+
			"(hybrid_id, name, description, protocol_id, scan_protocol_id, "+
			"norm_protocol_id, array_id, created_by_login, create_date) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?, ?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, hybrid_id);
		pstmt.setString(2, name);
		pstmt.setString(3, description);
		myDbUtils.setToNullIfZero(pstmt, 4, protocol_id);
		myDbUtils.setToNullIfZero(pstmt, 5, scan_protocol_id);
		myDbUtils.setToNullIfZero(pstmt, 6, norm_protocol_id);
		pstmt.setInt(7, array_id);
		pstmt.setString(8, created_by_login);
		pstmt.setTimestamp(9, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setHybrid_id(hybrid_id);

		return hybrid_id;
	}

	/**
	 * Updates a record in the hybridizations table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 

			"update hybridizations "+
			"set hybrid_id = ?, name = ?, description = ?, protocol_id = ?, scan_protocol_id = ?, "+
			"norm_protocol_id = ?, array_id = ?, created_by_login = ?, create_date = ? "+
			"where hybrid_id = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, hybrid_id);
		pstmt.setString(2, name);
		pstmt.setString(3, description);
		myDbUtils.setToNullIfZero(pstmt, 4, protocol_id);
		myDbUtils.setToNullIfZero(pstmt, 5, scan_protocol_id);
		myDbUtils.setToNullIfZero(pstmt, 6, norm_protocol_id);
		pstmt.setInt(7, array_id);
		pstmt.setString(8, created_by_login);
		pstmt.setTimestamp(9, now);
		pstmt.setInt(10, hybrid_id);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the hybridizations table and also deletes child records in related tables.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */

	public void deleteHybridization(Connection conn) throws SQLException {

		log.info("in deleteHybridization");

		//conn.setAutoCommit(false);

		PreparedStatement pstmt = null;
		try {
                        new Data_file().deleteAllData_filesForHybridization(hybrid_id, conn);
			log.debug("calling deleteAllTlabhybForHybridization with this hybridID: "+hybrid_id);
                        new Tlabhyb().deleteAllTlabhybForHybridization(hybrid_id, conn);

			String query = 
				"delete from hybridizations " + 
				"where hybrid_id = ?";

			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

			pstmt.setInt(1, hybrid_id);
			pstmt.executeQuery();
			pstmt.close();

			//conn.commit();
		} catch (SQLException e) {
			log.debug("error in deleteHybridization");
			//conn.rollback();
			pstmt.close();
			throw e;
		}
		//conn.setAutoCommit(true);
	}

        /**
         * Deletes the records in the hybridizations table that are children of Protocol.
         * @param protocol_id       identifier of the Protocol table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllHybridizationForProtocol(int protocol_id, Connection conn) throws SQLException {

                log.info("in deleteAllHybridizationForProtocol");

                //Make sure committing is handled in calling method!

                String query =
                        "select hybrid_id "+
                        "from hybridizations "+
                        "where norm_protocol_id = ? "+
                        "or scan_protocol_id = ? "+
                        "or protocol_id = ?";

                Results myResults = new Results(query, new Object[] {protocol_id, protocol_id, protocol_id}, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Hybridization(Integer.parseInt(dataRow[0])).deleteHybridization(conn);
                }

                myResults.close();

        }

	/**
	 * Checks to see if a Hybridization with the same  combination already exists.
	 * @param myHybridization	the Hybridization object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the hybrid_id of a Hybridization that currently exists
	 */
	public int checkRecordExists(Hybridization myHybridization, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select hybrid_id "+
			"from hybridizations "+
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
	 * Creates an array of Hybridization objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Hybridization
	 * @return	An array of Hybridization objects with their values setup 
	 */
	private Hybridization[] setupHybridizationValues(Results myResults) {

		//log.debug("in setupHybridizationValues");

		List<Hybridization> HybridizationList = new ArrayList<Hybridization>();

		Object[] dataRow;

		while ((dataRow = myResults.getNextRowWithClob()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Hybridization thisHybridization = new Hybridization();

			thisHybridization.setHybrid_id(Integer.parseInt((String)dataRow[0]));
			thisHybridization.setName((String)dataRow[1]);
			thisHybridization.setDescription(myResults.getClobAsString(dataRow[2]));
			if (dataRow[3] != null && !((String)dataRow[3]).equals("")) {  
				thisHybridization.setProtocol_id(Integer.parseInt((String)dataRow[3]));
			}
			if (dataRow[4] != null && !((String)dataRow[4]).equals("")) {  
				thisHybridization.setScan_protocol_id(Integer.parseInt((String)dataRow[4]));
			}
			if (dataRow[5] != null && !((String)dataRow[5]).equals("")) {  
				thisHybridization.setNorm_protocol_id(Integer.parseInt((String)dataRow[5]));
			}
			if (dataRow[6] != null && !((String)dataRow[6]).equals("")) {  
				thisHybridization.setArray_id(Integer.parseInt((String)dataRow[6]));
			}
			thisHybridization.setCreated_by_login((String)dataRow[7]);
			thisHybridization.setCreate_date(new ObjectHandler().getOracleDateAsTimestamp((String)dataRow[8]));
			thisHybridization.setExp_name((String)dataRow[9]);

			HybridizationList.add(thisHybridization);
		}

		Hybridization[] HybridizationArray = (Hybridization[]) HybridizationList.toArray(new Hybridization[HybridizationList.size()]);

		return HybridizationArray;
	}

	/**
	 * Compares Hybridization based on different fields.
	 */
	public class HybridizationSortComparator implements Comparator<Hybridization> {
		int compare;
		Hybridization hybridization1, hybridization2;

		public int compare(Hybridization object1, Hybridization object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				hybridization1 = object1;
				hybridization2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				hybridization2 = object1;
				hybridization1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("hybridization1 = " +hybridization1+ "hybridization2 = " +hybridization2);

			if (sortColumn.equals("hybrid_id")) {
				compare = new Integer(hybridization1.getHybrid_id()).compareTo(new Integer(hybridization2.getHybrid_id()));
			} else if (sortColumn.equals("name")) {
				compare = hybridization1.getName().compareTo(hybridization2.getName());
			} else if (sortColumn.equals("description")) {
				compare = hybridization1.getDescription().compareTo(hybridization2.getDescription());
			} else if (sortColumn.equals("protocol_id")) {
				compare = new Integer(hybridization1.getProtocol_id()).compareTo(new Integer(hybridization2.getProtocol_id()));
			} else if (sortColumn.equals("scan_protocol_id")) {
				compare = new Integer(hybridization1.getScan_protocol_id()).compareTo(new Integer(hybridization2.getScan_protocol_id()));
			} else if (sortColumn.equals("norm_protocol_id")) {
				compare = new Integer(hybridization1.getNorm_protocol_id()).compareTo(new Integer(hybridization2.getNorm_protocol_id()));
			} else if (sortColumn.equals("array_id")) {
				compare = new Integer(hybridization1.getArray_id()).compareTo(new Integer(hybridization2.getArray_id()));
			} else if (sortColumn.equals("created_by_login")) {
				compare = hybridization1.getCreated_by_login().compareTo(hybridization2.getCreated_by_login());
			} else if (sortColumn.equals("create_date")) {
				compare = hybridization1.getCreate_date().compareTo(hybridization2.getCreate_date());
			}
			return compare;
		}
	}

	public Hybridization[] sortHybridization (Hybridization[] myHybridization, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myHybridization, new HybridizationSortComparator());
		return myHybridization;
	}


	/**
	 * Converts Hybridization object to a String.
	 */
	public String toString() {
		return "This Hybridization has hybrid_id = " + hybrid_id;
	}

	/**
	 * Prints Hybridization object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Hybridization objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Hybridization)) return false;
		return (this.hybrid_id == ((Hybridization)obj).hybrid_id);

	}
}
