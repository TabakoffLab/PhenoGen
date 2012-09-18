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
 * Class for handling data related to Tpooled
 *  @author  Cheryl Hornbaker
 */

public class Tpooled {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public Tpooled() {
		log = Logger.getRootLogger();
	}

	public Tpooled(int tpooled_sysuid) {
		log = Logger.getRootLogger();
		this.setTpooled_sysuid(tpooled_sysuid);
	}


	private int tpooled_sysuid;
	private int tpooled_sampleid;
	private int tpooled_extractid;
	private int tpooled_subid;
	private String tpooled_del_status = "U";
	private String tpooled_user;
	private java.sql.Timestamp tpooled_last_change;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setTpooled_sysuid(int inInt) {
		this.tpooled_sysuid = inInt;
	}

	public int getTpooled_sysuid() {
		return this.tpooled_sysuid;
	}

	public void setTpooled_sampleid(int inInt) {
		this.tpooled_sampleid = inInt;
	}

	public int getTpooled_sampleid() {
		return this.tpooled_sampleid;
	}

	public void setTpooled_extractid(int inInt) {
		this.tpooled_extractid = inInt;
	}

	public int getTpooled_extractid() {
		return this.tpooled_extractid;
	}

	public void setTpooled_subid(int inInt) {
		this.tpooled_subid = inInt;
	}

	public int getTpooled_subid() {
		return this.tpooled_subid;
	}

	public void setTpooled_del_status(String inString) {
		this.tpooled_del_status = inString;
	}

	public String getTpooled_del_status() {
		return this.tpooled_del_status;
	}

	public void setTpooled_user(String inString) {
		this.tpooled_user = inString;
	}

	public String getTpooled_user() {
		return this.tpooled_user;
	}

	public void setTpooled_last_change(java.sql.Timestamp inTimestamp) {
		this.tpooled_last_change = inTimestamp;
	}

	public java.sql.Timestamp getTpooled_last_change() {
		return this.tpooled_last_change;
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
	 * Gets all the Tpooled
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Tpooled objects
	 */
	public Tpooled[] getAllTpooled(Connection conn) throws SQLException {

		log.debug("In getAllTpooled");

		String query = 
			"select "+
			"tpooled_sysuid, tpooled_sampleid, tpooled_extractid, tpooled_subid, tpooled_del_status, "+
			"tpooled_user, to_char(tpooled_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tpooled "+ 
			"order by tpooled_sysuid";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Tpooled[] myTpooled = setupTpooledValues(myResults);

		myResults.close();

		return myTpooled;
	}

	/**
	 * Gets the Tpooled object for this tpooled_sysuid
	 * @param tpooled_sysuid	 the identifier of the Tpooled
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tpooled object
	 */
	public Tpooled getTpooled(int tpooled_sysuid, Connection conn) throws SQLException {

		log.debug("In getOne Tpooled");

		String query = 
			"select "+
			"tpooled_sysuid, tpooled_sampleid, tpooled_extractid, tpooled_subid, tpooled_del_status, "+
			"tpooled_user, to_char(tpooled_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tpooled "+ 
			"where tpooled_sysuid = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, tpooled_sysuid, conn);

		Tpooled myTpooled = setupTpooledValues(myResults)[0];

		myResults.close();

		return myTpooled;
	}

	/**
	 * Creates a record in the Tpooled table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createTpooled(Connection conn) throws SQLException {

		int tpooled_sysuid = myDbUtils.getUniqueID("Tpooled_seq", conn);

		log.debug("In create Tpooled");

		String query = 
			"insert into Tpooled "+
			"(tpooled_sysuid, tpooled_sampleid, tpooled_extractid, tpooled_subid, tpooled_del_status, "+
			"tpooled_user, tpooled_last_change) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tpooled_sysuid);
		pstmt.setInt(2, tpooled_sampleid);
		pstmt.setInt(3, tpooled_extractid);
		pstmt.setInt(4, tpooled_subid);
		pstmt.setString(5, "U");
		pstmt.setString(6, tpooled_user);
		pstmt.setTimestamp(7, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setTpooled_sysuid(tpooled_sysuid);

		return tpooled_sysuid;
	}

	/**
	 * Updates a record in the Tpooled table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 

			"update Tpooled "+
			"set tpooled_sysuid = ?, tpooled_sampleid = ?, tpooled_extractid = ?, tpooled_subid = ?, tpooled_del_status = ?, "+
			"tpooled_user = ?, tpooled_last_change = ? "+
			"where tpooled_sysuid = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tpooled_sysuid);
		pstmt.setInt(2, tpooled_sampleid);
		pstmt.setInt(3, tpooled_extractid);
		pstmt.setInt(4, tpooled_subid);
		pstmt.setString(5, tpooled_del_status);
		pstmt.setString(6, tpooled_user);
		pstmt.setTimestamp(7, now);
		pstmt.setInt(8, tpooled_sysuid);

		pstmt.executeUpdate();
		pstmt.close();

	}

        /**
         * Deletes the record in the Tpooled table and also deletes child records in related tables.
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteTpooled(Connection conn) throws SQLException {

                log.info("in deleteTpooled");

                //conn.setAutoCommit(false);

                PreparedStatement pstmt = null;
                try {
                        String query =
                                "delete from Tpooled " +
                                "where tpooled_sysuid = ?";

                        pstmt = conn.prepareStatement(query,
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                        pstmt.setInt(1, tpooled_sysuid);
                        pstmt.executeQuery();
                        pstmt.close();

                        //conn.commit();
                } catch (SQLException e) {
                        log.debug("error in deleteTpooled");
                        //conn.rollback();
                        pstmt.close();
                        throw e;
                }
                //conn.setAutoCommit(true);
        }

        /**
         * Deletes the records in the Tpooled table that are children of Tsample.  Also deletes the
	 * Textract records.
         * @param tsample_sysuid        identifier of the Tsample table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTpooledForTsample(int tsample_sysuid, Connection conn) throws SQLException {

                log.info("in deleteAllTpooledForTsample");

                //Make sure committing is handled in calling method!

                String query =
                        "select tpooled_sysuid "+
                        "from Tpooled "+
                        "where tpooled_sampleid = ?";

                Results myResults = new Results(query, tsample_sysuid, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Tpooled(Integer.parseInt(dataRow[0])).deleteTpooled(conn);
                }

                query =
                        "select tpooled_extractid "+
                        "from Tpooled "+
                        "where tpooled_sampleid = ?";

                myResults = new Results(query, tsample_sysuid, conn);

                while ((dataRow = myResults.getNextRow()) != null) {
			log.debug("deleting Textract with this Tpooled_extractid: "+ dataRow[0]);
                        new Textract(Integer.parseInt(dataRow[0])).deleteTextract(conn);
                }

                myResults.close();

        }

        /**
         * Deletes the records in the Tpooled table that are children of Textract.
         * @param textract_sysuid       identifier of the Textract table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTpooledForTextract(int textract_sysuid, Connection conn) throws SQLException {

                log.info("in deleteAllTpooledForTextract");

                //Make sure committing is handled in calling method!

                String query =
                        "select tpooled_sysuid "+
                        "from Tpooled "+
                        "where tpooled_extractid = ?";

                Results myResults = new Results(query, textract_sysuid, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Tpooled(Integer.parseInt(dataRow[0])).deleteTpooled(conn);
                }

                myResults.close();

        }

	/**
	 * Checks to see if a Tpooled with the same  combination already exists.
	 * @param myTpooled	the Tpooled object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the tpooled_sysuid of a Tpooled that currently exists
	 */
	public int checkRecordExists(Tpooled myTpooled, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select tpooled_sysuid "+
			"from Tpooled "+
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
	 * Creates an array of Tpooled objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Tpooled
	 * @return	An array of Tpooled objects with their values setup 
	 */
	private Tpooled[] setupTpooledValues(Results myResults) {

		//log.debug("in setupTpooledValues");

		List<Tpooled> TpooledList = new ArrayList<Tpooled>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Tpooled thisTpooled = new Tpooled();

			thisTpooled.setTpooled_sysuid(Integer.parseInt(dataRow[0]));
			thisTpooled.setTpooled_sampleid(Integer.parseInt(dataRow[1]));
			thisTpooled.setTpooled_extractid(Integer.parseInt(dataRow[2]));
			thisTpooled.setTpooled_subid(Integer.parseInt(dataRow[3]));
			thisTpooled.setTpooled_del_status(dataRow[4]);
			thisTpooled.setTpooled_user(dataRow[5]);
			thisTpooled.setTpooled_last_change(new ObjectHandler().getOracleDateAsTimestamp(dataRow[6]));

			TpooledList.add(thisTpooled);
		}

		Tpooled[] TpooledArray = (Tpooled[]) TpooledList.toArray(new Tpooled[TpooledList.size()]);

		return TpooledArray;
	}

	/**
	 * Compares Tpooled based on different fields.
	 */
	public class TpooledSortComparator implements Comparator<Tpooled> {
		int compare;
		Tpooled tpooled1, tpooled2;

		public int compare(Tpooled object1, Tpooled object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				tpooled1 = object1;
				tpooled2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				tpooled2 = object1;
				tpooled1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("tpooled1 = " +tpooled1+ "tpooled2 = " +tpooled2);

			if (sortColumn.equals("tpooled_sysuid")) {
				compare = new Integer(tpooled1.getTpooled_sysuid()).compareTo(new Integer(tpooled2.getTpooled_sysuid()));
			} else if (sortColumn.equals("tpooled_sampleid")) {
				compare = new Integer(tpooled1.getTpooled_sampleid()).compareTo(new Integer(tpooled2.getTpooled_sampleid()));
			} else if (sortColumn.equals("tpooled_extractid")) {
				compare = new Integer(tpooled1.getTpooled_extractid()).compareTo(new Integer(tpooled2.getTpooled_extractid()));
			} else if (sortColumn.equals("tpooled_subid")) {
				compare = new Integer(tpooled1.getTpooled_subid()).compareTo(new Integer(tpooled2.getTpooled_subid()));
			} else if (sortColumn.equals("tpooled_del_status")) {
				compare = tpooled1.getTpooled_del_status().compareTo(tpooled2.getTpooled_del_status());
			} else if (sortColumn.equals("tpooled_user")) {
				compare = tpooled1.getTpooled_user().compareTo(tpooled2.getTpooled_user());
			} else if (sortColumn.equals("tpooled_last_change")) {
				compare = tpooled1.getTpooled_last_change().compareTo(tpooled2.getTpooled_last_change());
			}
			return compare;
		}
	}

	public Tpooled[] sortTpooled (Tpooled[] myTpooled, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myTpooled, new TpooledSortComparator());
		return myTpooled;
	}


	/**
	 * Converts Tpooled object to a String.
	 */
	public String toString() {
		return "This Tpooled has tpooled_sysuid = " + tpooled_sysuid;
	}

	/**
	 * Prints Tpooled object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Tpooled objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Tpooled)) return false;
		return (this.tpooled_sysuid == ((Tpooled)obj).tpooled_sysuid);

	}
}
