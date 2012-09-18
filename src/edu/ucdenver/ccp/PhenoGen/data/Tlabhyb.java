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
 * Class for handling data related to Tlabhyb
 *  @author  Cheryl Hornbaker
 */

public class Tlabhyb {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public Tlabhyb() {
		log = Logger.getRootLogger();
	}

	public Tlabhyb(int tlabhyb_sysuid) {
		log = Logger.getRootLogger();
		this.setTlabhyb_sysuid(tlabhyb_sysuid);
	}


	private int tlabhyb_sysuid;
	private int tlabhyb_labelid;
	private int tlabhyb_hybridid;
	private int tlabhyb_subid;
	private String tlabhyb_del_status = "U";
	private String tlabhyb_user;
	private java.sql.Timestamp tlabhyb_last_change;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setTlabhyb_sysuid(int inInt) {
		this.tlabhyb_sysuid = inInt;
	}

	public int getTlabhyb_sysuid() {
		return this.tlabhyb_sysuid;
	}

	public void setTlabhyb_labelid(int inInt) {
		this.tlabhyb_labelid = inInt;
	}

	public int getTlabhyb_labelid() {
		return this.tlabhyb_labelid;
	}

	public void setTlabhyb_hybridid(int inInt) {
		this.tlabhyb_hybridid = inInt;
	}

	public int getTlabhyb_hybridid() {
		return this.tlabhyb_hybridid;
	}

	public void setTlabhyb_subid(int inInt) {
		this.tlabhyb_subid = inInt;
	}

	public int getTlabhyb_subid() {
		return this.tlabhyb_subid;
	}

	public void setTlabhyb_del_status(String inString) {
		this.tlabhyb_del_status = inString;
	}

	public String getTlabhyb_del_status() {
		return this.tlabhyb_del_status;
	}

	public void setTlabhyb_user(String inString) {
		this.tlabhyb_user = inString;
	}

	public String getTlabhyb_user() {
		return this.tlabhyb_user;
	}

	public void setTlabhyb_last_change(java.sql.Timestamp inTimestamp) {
		this.tlabhyb_last_change = inTimestamp;
	}

	public java.sql.Timestamp getTlabhyb_last_change() {
		return this.tlabhyb_last_change;
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
	 * Gets all the Tlabhyb
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Tlabhyb objects
	 */
	public Tlabhyb[] getAllTlabhyb(Connection conn) throws SQLException {

		log.debug("In getAllTlabhyb");

		String query = 
			"select "+
			"tlabhyb_sysuid, tlabhyb_labelid, tlabhyb_hybridid, tlabhyb_subid, tlabhyb_del_status, "+
			"tlabhyb_user, to_char(tlabhyb_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tlabhyb "+ 
			"order by tlabhyb_sysuid";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Tlabhyb[] myTlabhyb = setupTlabhybValues(myResults);

		myResults.close();

		return myTlabhyb;
	}

	/**
	 * Gets the Tlabhyb object for this tlabhyb_sysuid
	 * @param tlabhyb_sysuid	 the identifier of the Tlabhyb
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tlabhyb object
	 */
	public Tlabhyb getTlabhyb(int tlabhyb_sysuid, Connection conn) throws SQLException {

		log.debug("In getOne Tlabhyb");

		String query = 
			"select "+
			"tlabhyb_sysuid, tlabhyb_labelid, tlabhyb_hybridid, tlabhyb_subid, tlabhyb_del_status, "+
			"tlabhyb_user, to_char(tlabhyb_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tlabhyb "+ 
			"where tlabhyb_sysuid = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, tlabhyb_sysuid, conn);

		Tlabhyb myTlabhyb = setupTlabhybValues(myResults)[0];

		myResults.close();

		return myTlabhyb;
	}

	/**
	 * Creates a record in the Tlabhyb table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createTlabhyb(Connection conn) throws SQLException {

		int tlabhyb_sysuid = myDbUtils.getUniqueID("Tlabhyb_seq", conn);

		log.debug("In create Tlabhyb");

		String query = 
			"insert into Tlabhyb "+
			"(tlabhyb_sysuid, tlabhyb_labelid, tlabhyb_hybridid, tlabhyb_subid, tlabhyb_del_status, "+
			"tlabhyb_user, tlabhyb_last_change) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tlabhyb_sysuid);
		pstmt.setInt(2, tlabhyb_labelid);
		pstmt.setInt(3, tlabhyb_hybridid);
		pstmt.setInt(4, tlabhyb_subid);
		pstmt.setString(5, "U");
		pstmt.setString(6, tlabhyb_user);
		pstmt.setTimestamp(7, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setTlabhyb_sysuid(tlabhyb_sysuid);

		return tlabhyb_sysuid;
	}

	/**
	 * Updates a record in the Tlabhyb table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 

			"update Tlabhyb "+
			"set tlabhyb_sysuid = ?, tlabhyb_labelid = ?, tlabhyb_hybridid = ?, tlabhyb_subid = ?, tlabhyb_del_status = ?, "+
			"tlabhyb_user = ?, tlabhyb_last_change = ? "+
			"where tlabhyb_sysuid = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tlabhyb_sysuid);
		pstmt.setInt(2, tlabhyb_labelid);
		pstmt.setInt(3, tlabhyb_hybridid);
		pstmt.setInt(4, tlabhyb_subid);
		pstmt.setString(5, tlabhyb_del_status);
		pstmt.setString(6, tlabhyb_user);
		pstmt.setTimestamp(7, now);
		pstmt.setInt(8, tlabhyb_sysuid);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the Tlabhyb table and also deletes child records in related tables.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */

	public void deleteTlabhyb(Connection conn) throws SQLException {

		log.info("in deleteTlabhyb");

		//conn.setAutoCommit(false);

		PreparedStatement pstmt = null;
		try {
			String query = 
				"delete from Tlabhyb " + 
				"where tlabhyb_sysuid = ?";

			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

			pstmt.setInt(1, tlabhyb_sysuid);
			pstmt.executeQuery();
			pstmt.close();

			//conn.commit();
		} catch (SQLException e) {
			log.debug("error in deleteTlabhyb");
			//conn.rollback();
			pstmt.close();
			throw e;
		}
		//conn.setAutoCommit(true);
	}

        /**
         * Deletes the records in the Tlabhyb table that are children of Hybridization.
         * @param hybrid_id        identifier of the Hybridization table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTlabhybForHybridization(int hybrid_id, Connection conn) throws SQLException {

                log.info("in deleteAllTlabhybForHybridization");

                //Make sure committing is handled in calling method!

                String query =
                        "select tlabhyb_sysuid "+
                        "from Tlabhyb "+
                        "where tlabhyb_hybridid = ?";

                Results myResults = new Results(query, hybrid_id, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
			log.debug("deleting labhyb for this hybridID: "+dataRow[0]);
                        new Tlabhyb(Integer.parseInt(dataRow[0])).deleteTlabhyb(conn);
                }

                myResults.close();

        }
        /**
         * Deletes the records in the Tlabhyb table that are children of Tlabel.
         * @param tlabel_sysuid identifier of the Tlabel table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTlabhybForTlabel(int tlabel_sysuid, Connection conn) throws SQLException {

                log.info("in deleteAllTlabhybForTlabel");

                //Make sure committing is handled in calling method!

                String query =
                        "select tlabhyb_sysuid "+
                        "from Tlabhyb "+
                        "where tlabhyb_labelid = ?";

                Results myResults = new Results(query, tlabel_sysuid, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Tlabhyb(Integer.parseInt(dataRow[0])).deleteTlabhyb(conn);
                }

                query =
                        "select tlabhyb_hybridid "+
                        "from Tlabhyb "+
                        "where tlabhyb_labelid = ?";

                myResults = new Results(query, tlabel_sysuid, conn);

                while ((dataRow = myResults.getNextRow()) != null) {
			log.debug("deleting Hybridizations for this labhyb labelid: "+tlabel_sysuid + ". This hybridID is "+dataRow[0]);
                        new Hybridization(Integer.parseInt(dataRow[0])).deleteHybridization(conn);
                }

                myResults.close();

        }

	/**
	 * Checks to see if a Tlabhyb with the same  combination already exists.
	 * @param myTlabhyb	the Tlabhyb object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the tlabhyb_sysuid of a Tlabhyb that currently exists
	 */
	public int checkRecordExists(Tlabhyb myTlabhyb, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select tlabhyb_sysuid "+
			"from Tlabhyb "+
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
	 * Creates an array of Tlabhyb objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Tlabhyb
	 * @return	An array of Tlabhyb objects with their values setup 
	 */
	private Tlabhyb[] setupTlabhybValues(Results myResults) {

		//log.debug("in setupTlabhybValues");

		List<Tlabhyb> TlabhybList = new ArrayList<Tlabhyb>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Tlabhyb thisTlabhyb = new Tlabhyb();

			thisTlabhyb.setTlabhyb_sysuid(Integer.parseInt(dataRow[0]));
			thisTlabhyb.setTlabhyb_labelid(Integer.parseInt(dataRow[1]));
			thisTlabhyb.setTlabhyb_hybridid(Integer.parseInt(dataRow[2]));
			thisTlabhyb.setTlabhyb_subid(Integer.parseInt(dataRow[3]));
			thisTlabhyb.setTlabhyb_del_status(dataRow[4]);
			thisTlabhyb.setTlabhyb_user(dataRow[5]);
			thisTlabhyb.setTlabhyb_last_change(new ObjectHandler().getOracleDateAsTimestamp(dataRow[6]));

			TlabhybList.add(thisTlabhyb);
		}

		Tlabhyb[] TlabhybArray = (Tlabhyb[]) TlabhybList.toArray(new Tlabhyb[TlabhybList.size()]);

		return TlabhybArray;
	}

	/**
	 * Compares Tlabhyb based on different fields.
	 */
	public class TlabhybSortComparator implements Comparator<Tlabhyb> {
		int compare;
		Tlabhyb tlabhyb1, tlabhyb2;

		public int compare(Tlabhyb object1, Tlabhyb object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				tlabhyb1 = object1;
				tlabhyb2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				tlabhyb2 = object1;
				tlabhyb1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("tlabhyb1 = " +tlabhyb1+ "tlabhyb2 = " +tlabhyb2);

			if (sortColumn.equals("tlabhyb_sysuid")) {
				compare = new Integer(tlabhyb1.getTlabhyb_sysuid()).compareTo(new Integer(tlabhyb2.getTlabhyb_sysuid()));
			} else if (sortColumn.equals("tlabhyb_labelid")) {
				compare = new Integer(tlabhyb1.getTlabhyb_labelid()).compareTo(new Integer(tlabhyb2.getTlabhyb_labelid()));
			} else if (sortColumn.equals("tlabhyb_hybridid")) {
				compare = new Integer(tlabhyb1.getTlabhyb_hybridid()).compareTo(new Integer(tlabhyb2.getTlabhyb_hybridid()));
			} else if (sortColumn.equals("tlabhyb_subid")) {
				compare = new Integer(tlabhyb1.getTlabhyb_subid()).compareTo(new Integer(tlabhyb2.getTlabhyb_subid()));
			} else if (sortColumn.equals("tlabhyb_del_status")) {
				compare = tlabhyb1.getTlabhyb_del_status().compareTo(tlabhyb2.getTlabhyb_del_status());
			} else if (sortColumn.equals("tlabhyb_user")) {
				compare = tlabhyb1.getTlabhyb_user().compareTo(tlabhyb2.getTlabhyb_user());
			} else if (sortColumn.equals("tlabhyb_last_change")) {
				compare = tlabhyb1.getTlabhyb_last_change().compareTo(tlabhyb2.getTlabhyb_last_change());
			}
			return compare;
		}
	}

	public Tlabhyb[] sortTlabhyb (Tlabhyb[] myTlabhyb, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myTlabhyb, new TlabhybSortComparator());
		return myTlabhyb;
	}


	/**
	 * Converts Tlabhyb object to a String.
	 */
	public String toString() {
		return "This Tlabhyb has tlabhyb_sysuid = " + tlabhyb_sysuid;
	}

	/**
	 * Prints Tlabhyb object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Tlabhyb objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Tlabhyb)) return false;
		return (this.tlabhyb_sysuid == ((Tlabhyb)obj).tlabhyb_sysuid);

	}
}
