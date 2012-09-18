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
 * Class for handling data related to Tfctrval
 *  @author  Cheryl Hornbaker
 */

public class Tfctrval {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public Tfctrval() {
		log = Logger.getRootLogger();
	}

	public Tfctrval(int tfctrval_sysuid) {
		log = Logger.getRootLogger();
		this.setTfctrval_sysuid(tfctrval_sysuid);
	}


	private int tfctrval_sysuid;
	private int tfctrval_expfctrid;
	private int tfctrval_sampleid;
	private String tfctrval_freetext;
	private String tfctrval_freetextunit;
	private int tfctrval_subid;
	private String tfctrval_del_status = "U";
	private String tfctrval_user;
	private java.sql.Timestamp tfctrval_last_change;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setTfctrval_sysuid(int inInt) {
		this.tfctrval_sysuid = inInt;
	}

	public int getTfctrval_sysuid() {
		return this.tfctrval_sysuid;
	}

	public void setTfctrval_expfctrid(int inInt) {
		this.tfctrval_expfctrid = inInt;
	}

	public int getTfctrval_expfctrid() {
		return this.tfctrval_expfctrid;
	}

	public void setTfctrval_sampleid(int inInt) {
		this.tfctrval_sampleid = inInt;
	}

	public int getTfctrval_sampleid() {
		return this.tfctrval_sampleid;
	}

	public void setTfctrval_freetext(String inString) {
		this.tfctrval_freetext = inString;
	}

	public String getTfctrval_freetext() {
		return this.tfctrval_freetext;
	}

	public void setTfctrval_freetextunit(String inString) {
		this.tfctrval_freetextunit = inString;
	}

	public String getTfctrval_freetextunit() {
		return this.tfctrval_freetextunit;
	}

	public void setTfctrval_subid(int inInt) {
		this.tfctrval_subid = inInt;
	}

	public int getTfctrval_subid() {
		return this.tfctrval_subid;
	}

	public void setTfctrval_del_status(String inString) {
		this.tfctrval_del_status = inString;
	}

	public String getTfctrval_del_status() {
		return this.tfctrval_del_status;
	}

	public void setTfctrval_user(String inString) {
		this.tfctrval_user = inString;
	}

	public String getTfctrval_user() {
		return this.tfctrval_user;
	}

	public void setTfctrval_last_change(java.sql.Timestamp inTimestamp) {
		this.tfctrval_last_change = inTimestamp;
	}

	public java.sql.Timestamp getTfctrval_last_change() {
		return this.tfctrval_last_change;
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
	 * Gets all the Tfctrval
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Tfctrval objects
	 */
	public Tfctrval[] getAllTfctrval(Connection conn) throws SQLException {

		log.debug("In getAllTfctrval");

		String query = 
			"select "+
			"tfctrval_sysuid, tfctrval_expfctrid, tfctrval_sampleid, tfctrval_freetext, tfctrval_freetextunit, "+
			"tfctrval_subid, tfctrval_del_status, tfctrval_user, to_char(tfctrval_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tfctrval "+ 
			"order by tfctrval_sysuid";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Tfctrval[] myTfctrval = setupTfctrvalValues(myResults);

		myResults.close();

		return myTfctrval;
	}

	/**
	 * Gets the Tfctrval object for this tfctrval_sysuid
	 * @param tfctrval_sysuid	 the identifier of the Tfctrval
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tfctrval object
	 */
	public Tfctrval getTfctrval(int tfctrval_sysuid, Connection conn) throws SQLException {

		log.debug("In getOne Tfctrval");

		String query = 
			"select "+
			"tfctrval_sysuid, tfctrval_expfctrid, tfctrval_sampleid, tfctrval_freetext, tfctrval_freetextunit, "+
			"tfctrval_subid, tfctrval_del_status, tfctrval_user, to_char(tfctrval_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tfctrval "+ 
			"where tfctrval_sysuid = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, tfctrval_sysuid, conn);

		Tfctrval myTfctrval = setupTfctrvalValues(myResults)[0];

		myResults.close();

		return myTfctrval;
	}

	/**
	 * Creates a record in the Tfctrval table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createTfctrval(Connection conn) throws SQLException {

		int tfctrval_sysuid = myDbUtils.getUniqueID("Tfctrval_seq", conn);

		log.debug("In create Tfctrval");

		String query = 
			"insert into Tfctrval "+
			"(tfctrval_sysuid, tfctrval_expfctrid, tfctrval_sampleid, tfctrval_freetext, tfctrval_freetextunit, "+
			"tfctrval_subid, tfctrval_del_status, tfctrval_user, tfctrval_last_change) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?, ?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tfctrval_sysuid);
		pstmt.setInt(2, tfctrval_expfctrid);
		pstmt.setInt(3, tfctrval_sampleid);
		pstmt.setString(4, tfctrval_freetext);
		pstmt.setString(5, tfctrval_freetextunit);
		pstmt.setInt(6, tfctrval_subid);
		pstmt.setString(7, "U");
		pstmt.setString(8, tfctrval_user);
		pstmt.setTimestamp(9, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setTfctrval_sysuid(tfctrval_sysuid);

		return tfctrval_sysuid;
	}

	/**
	 * Updates a record in the Tfctrval table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 

			"update Tfctrval "+
			"set tfctrval_sysuid = ?, tfctrval_expfctrid = ?, tfctrval_sampleid = ?, tfctrval_freetext = ?, tfctrval_freetextunit = ?, "+
			"tfctrval_subid = ?, tfctrval_del_status = ?, tfctrval_user = ?, tfctrval_last_change = ? "+
			"where tfctrval_sysuid = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tfctrval_sysuid);
		pstmt.setInt(2, tfctrval_expfctrid);
		pstmt.setInt(3, tfctrval_sampleid);
		pstmt.setString(4, tfctrval_freetext);
		pstmt.setString(5, tfctrval_freetextunit);
		pstmt.setInt(6, tfctrval_subid);
		pstmt.setString(7, tfctrval_del_status);
		pstmt.setString(8, tfctrval_user);
		pstmt.setTimestamp(9, now);
		pstmt.setInt(10, tfctrval_sysuid);

		pstmt.executeUpdate();
		pstmt.close();

	}


        /**
         * Deletes the record in the Tfctrval table and also deletes child records in related tables.
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */

        public void deleteTfctrval(Connection conn) throws SQLException {

                log.info("in deleteTfctrval");

                //conn.setAutoCommit(false);

                PreparedStatement pstmt = null;
                try {
                        String query =
                                "delete from Tfctrval " +
                                "where tfctrval_sysuid = ?";

                        pstmt = conn.prepareStatement(query,
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                        pstmt.setInt(1, tfctrval_sysuid);
                        pstmt.executeQuery();
                        pstmt.close();

                        //conn.commit();
                } catch (SQLException e) {
                        log.debug("error in deleteTfctrval");
                        //conn.rollback();
                        pstmt.close();
                        throw e;
                }
                //conn.setAutoCommit(true);
        }

        /**
         * Deletes the records in the Tfctrval table that are children of Tsample.
         * @param tsample_sysuid        identifier of the Tsample table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTfctrvalForTsample(int tsample_sysuid, Connection conn) throws SQLException {

                log.info("in deleteAllTfctrvalForTsample");

                //Make sure committing is handled in calling method!

                String query =
                        "select tfctrval_sysuid "+
                        "from Tfctrval "+
                        "where tfctrval_sampleid = ?";

                Results myResults = new Results(query, tsample_sysuid, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Tfctrval(Integer.parseInt(dataRow[0])).deleteTfctrval(conn);
                }

                myResults.close();

        }

	/**
	 * Checks to see if a Tfctrval with the same  combination already exists.
	 * @param myTfctrval	the Tfctrval object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the tfctrval_sysuid of a Tfctrval that currently exists
	 */
	public int checkRecordExists(Tfctrval myTfctrval, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select tfctrval_sysuid "+
			"from Tfctrval "+
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
	 * Creates an array of Tfctrval objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Tfctrval
	 * @return	An array of Tfctrval objects with their values setup 
	 */
	private Tfctrval[] setupTfctrvalValues(Results myResults) {

		//log.debug("in setupTfctrvalValues");

		List<Tfctrval> TfctrvalList = new ArrayList<Tfctrval>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Tfctrval thisTfctrval = new Tfctrval();

			thisTfctrval.setTfctrval_sysuid(Integer.parseInt(dataRow[0]));
			thisTfctrval.setTfctrval_expfctrid(Integer.parseInt(dataRow[1]));
			thisTfctrval.setTfctrval_sampleid(Integer.parseInt(dataRow[2]));
			thisTfctrval.setTfctrval_freetext(dataRow[3]);
			thisTfctrval.setTfctrval_freetextunit(dataRow[4]);
			thisTfctrval.setTfctrval_subid(Integer.parseInt(dataRow[5]));
			thisTfctrval.setTfctrval_del_status(dataRow[6]);
			thisTfctrval.setTfctrval_user(dataRow[7]);
			thisTfctrval.setTfctrval_last_change(new ObjectHandler().getOracleDateAsTimestamp(dataRow[8]));

			TfctrvalList.add(thisTfctrval);
		}

		Tfctrval[] TfctrvalArray = (Tfctrval[]) TfctrvalList.toArray(new Tfctrval[TfctrvalList.size()]);

		return TfctrvalArray;
	}

	/**
	 * Compares Tfctrval based on different fields.
	 */
	public class TfctrvalSortComparator implements Comparator<Tfctrval> {
		int compare;
		Tfctrval tfctrval1, tfctrval2;

		public int compare(Tfctrval object1, Tfctrval object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				tfctrval1 = object1;
				tfctrval2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				tfctrval2 = object1;
				tfctrval1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("tfctrval1 = " +tfctrval1+ "tfctrval2 = " +tfctrval2);

			if (sortColumn.equals("tfctrval_sysuid")) {
				compare = new Integer(tfctrval1.getTfctrval_sysuid()).compareTo(new Integer(tfctrval2.getTfctrval_sysuid()));
			} else if (sortColumn.equals("tfctrval_expfctrid")) {
				compare = new Integer(tfctrval1.getTfctrval_expfctrid()).compareTo(new Integer(tfctrval2.getTfctrval_expfctrid()));
			} else if (sortColumn.equals("tfctrval_sampleid")) {
				compare = new Integer(tfctrval1.getTfctrval_sampleid()).compareTo(new Integer(tfctrval2.getTfctrval_sampleid()));
			} else if (sortColumn.equals("tfctrval_freetext")) {
				compare = tfctrval1.getTfctrval_freetext().compareTo(tfctrval2.getTfctrval_freetext());
			} else if (sortColumn.equals("tfctrval_freetextunit")) {
				compare = tfctrval1.getTfctrval_freetextunit().compareTo(tfctrval2.getTfctrval_freetextunit());
			} else if (sortColumn.equals("tfctrval_subid")) {
				compare = new Integer(tfctrval1.getTfctrval_subid()).compareTo(new Integer(tfctrval2.getTfctrval_subid()));
			} else if (sortColumn.equals("tfctrval_del_status")) {
				compare = tfctrval1.getTfctrval_del_status().compareTo(tfctrval2.getTfctrval_del_status());
			} else if (sortColumn.equals("tfctrval_user")) {
				compare = tfctrval1.getTfctrval_user().compareTo(tfctrval2.getTfctrval_user());
			} else if (sortColumn.equals("tfctrval_last_change")) {
				compare = tfctrval1.getTfctrval_last_change().compareTo(tfctrval2.getTfctrval_last_change());
			}
			return compare;
		}
	}

	public Tfctrval[] sortTfctrval (Tfctrval[] myTfctrval, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myTfctrval, new TfctrvalSortComparator());
		return myTfctrval;
	}


	/**
	 * Converts Tfctrval object to a String.
	 */
	public String toString() {
		return "This Tfctrval has tfctrval_sysuid = " + tfctrval_sysuid;
	}

	/**
	 * Prints Tfctrval object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Tfctrval objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Tfctrval)) return false;
		return (this.tfctrval_sysuid == ((Tfctrval)obj).tfctrval_sysuid);

	}
}
