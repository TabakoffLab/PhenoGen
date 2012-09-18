package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

import edu.ucdenver.ccp.util.Debugger;

import edu.ucdenver.ccp.util.ObjectHandler;

import edu.ucdenver.ccp.util.sql.Results;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to Texpfctr
 *  @author  Cheryl Hornbaker
 */

public class Texpfctr {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public Texpfctr() {
		log = Logger.getRootLogger();
	}

	public Texpfctr(int texpfctr_exprid, int texpfctr_id) {
		log = Logger.getRootLogger();
		this.setTexpfctr_exprid(texpfctr_exprid);
		this.setTexpfctr_id(texpfctr_id);
	}

	public Texpfctr(int texpfctr_exprid, int texpfctr_id, String texpfctr_del_status) {
		log = Logger.getRootLogger();
		this.setTexpfctr_exprid(texpfctr_exprid);
		this.setTexpfctr_id(texpfctr_id);
		this.setTexpfctr_del_status(texpfctr_del_status);
	}


	private int texpfctr_exprid;
	private int texpfctr_id;
	private String texpfctr_del_status = "U";
	private String texpfctr_user;
	private java.sql.Timestamp texpfctr_last_change;
	private String sortColumn ="";
	private String sortOrder ="A";
	private String factorName;

	public void setTexpfctr_exprid(int inInt) {
		this.texpfctr_exprid = inInt;
	}

	public int getTexpfctr_exprid() {
		return this.texpfctr_exprid;
	}

	public void setTexpfctr_id(int inInt) {
		this.texpfctr_id = inInt;
	}

	public int getTexpfctr_id() {
		return this.texpfctr_id;
	}

	public void setTexpfctr_del_status(String inString) {
		this.texpfctr_del_status = inString;
	}

	public String getTexpfctr_del_status() {
		return this.texpfctr_del_status;
	}

	public void setTexpfctr_user(String inString) {
		this.texpfctr_user = inString;
	}

	public String getTexpfctr_user() {
		return this.texpfctr_user;
	}

	public void setTexpfctr_last_change(java.sql.Timestamp inTimestamp) {
		this.texpfctr_last_change = inTimestamp;
	}

	public java.sql.Timestamp getTexpfctr_last_change() {
		return this.texpfctr_last_change;
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

	public void setFactorName(String inString) {
		this.factorName = inString;
	}

	public String getFactorName() {
		return this.factorName;
	}



	/**
	 * Gets all the Texpfctr for an experiment
	 * @param expID 	the id of the experiment
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Texpfctr objects
	 */
	public Texpfctr[] getAllTexpfctrForExp(int expID, Connection conn) throws SQLException {

		log.debug("In getAllTexpfctrForExp");

		String query = 
			"select "+
			"texpfctr_exprid, texpfctr_id, texpfctr_del_status, texpfctr_user, to_char(texpfctr_last_change, 'dd-MON-yyyy hh24:mi:ss'), "+
			"vt.value "+
			"from Texpfctr, valid_terms vt "+ 
			"where texpfctr_exprid = ? "+
			"and vt.term_id = texpfctr_id "+
			"and texpfctr_del_status = 'U' "+
			"and vt.value != 'other' "+
			"union "+
			"select  "+
			"texpfctr_exprid, texpfctr_id, texpfctr_del_status, texpfctr_user, to_char(texpfctr_last_change, 'dd-MON-yyyy hh24:mi:ss'), "+
			"tothers_value "+
			"from Texpfctr, valid_terms vt, Tothers "+
			"where texpfctr_exprid = ?  "+
			"and tothers_exprid = texpfctr_exprid "+
			"and tothers_id = 'EXPERIMENTAL_FACTOR' "+
			"and texpfctr_id = vt.term_id "+
			"and texpfctr_del_status = 'U'  "+
			"and tothers_del_status = 'U' "+
			"and vt.value = 'other' "+
			"and tothers_value is not null "+
			"order by texpfctr_exprid, texpfctr_id, texpfctr_del_status";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, new Object[] {expID, expID}, conn);

		Texpfctr[] myTexpfctr = setupTexpfctrValues(myResults);

		myResults.close();

		return myTexpfctr;
	}

	/**
	 * Gets the Texpfctr object for this texpfctr_exprid
	 * @param texpfctr_exprid	 the identifier of the Texpfctr
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Texpfctr object
	 */
	public Texpfctr getTexpfctr(int texpfctr_exprid, Connection conn) throws SQLException {

		log.debug("In getOne Texpfctr");

		String query = 
			"select "+
			"texpfctr_exprid, texpfctr_id, texpfctr_del_status, texpfctr_user, to_char(texpfctr_last_change, 'dd-MON-yyyy hh24:mi:ss'), "+
			"vt.value "+
			"from Texpfctr, valid_terms vt "+ 
			"where texpfctr_exprid = ? "+
			"and texpfctr_id = vt.term_id";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, texpfctr_exprid, conn);

		Texpfctr myTexpfctr = setupTexpfctrValues(myResults)[0];

		myResults.close();

		return myTexpfctr;
	}

	/**
	 * Creates a record in the Texpfctr table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void createTexpfctr(Connection conn) throws SQLException {

		log.debug("In create Texpfctr");

		String query = 
			"insert into Texpfctr "+
			"(texpfctr_exprid, texpfctr_id, texpfctr_del_status, texpfctr_user, texpfctr_last_change) "+
			"values "+
			"(?, ?, ?, ?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, texpfctr_exprid);
		pstmt.setInt(2, texpfctr_id);
		pstmt.setString(3, "U");
		pstmt.setString(4, texpfctr_user);
		pstmt.setTimestamp(5, now);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Updates a record in the Texpfctr table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 
			"update Texpfctr "+
			"set texpfctr_exprid = ?, texpfctr_id = ?, texpfctr_del_status = ?, texpfctr_user = ?, texpfctr_last_change = ? "+
			"where texpfctr_exprid = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, texpfctr_exprid);
		pstmt.setInt(2, texpfctr_id);
		pstmt.setString(3, texpfctr_del_status);
		pstmt.setString(4, texpfctr_user);
		pstmt.setTimestamp(5, now);
		pstmt.setInt(6, texpfctr_exprid);

		pstmt.executeUpdate();
		pstmt.close();

	}

        /**
         * Deletes the record in the Texpfctr table and also deletes child records in related tables.
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteTexpfctr(Connection conn) throws SQLException {

                log.info("in deleteTexpfctr");

                //conn.setAutoCommit(false);

                PreparedStatement pstmt = null;
                try {
                        String query =
                                "delete from Texpfctr " +
                                "where texpfctr_exprid = ? "+
                                "and texpfctr_id = ?";

                        pstmt = conn.prepareStatement(query,
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                        pstmt.setInt(1, texpfctr_exprid);
                        pstmt.setInt(2, texpfctr_id);
                        pstmt.executeQuery();
                        pstmt.close();

                        //conn.commit();
                } catch (SQLException e) {
                        log.debug("error in deleteTexpfctr");
                        //conn.rollback();
                        pstmt.close();
                        throw e;
                }
                //conn.setAutoCommit(true);
        }

        /**
         * Deletes the records in the Texpfctr table that are children of Experiment.
         * @param exp_id       identifier of the Experiment table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTexpfctrForExperiment(int exp_id, Connection conn) throws SQLException {

                log.info("in deleteAllTexpfctrForExperiment");

                //Make sure committing is handled in calling method!

                String query =
                        "select texpfctr_exprid, texpfctr_id "+
                        "from Texpfctr "+
                        "where texpfctr_exprid = ?";

                Results myResults = new Results(query, exp_id, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Texpfctr(Integer.parseInt(dataRow[0]), Integer.parseInt(dataRow[1])).deleteTexpfctr(conn);
                }

                myResults.close();
        }

	/**
	 * Checks to see if a Texpfctr with the same  combination already exists.
	 * @param myTexpfctr	the Texpfctr object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the texpfctr_exprid of a Texpfctr that currently exists
	 */
	public int checkRecordExists(Texpfctr myTexpfctr, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select texpfctr_exprid "+
			"from Texpfctr "+
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
	 * Creates an array of Texpfctr objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Texpfctr
	 * @return	An array of Texpfctr objects with their values setup 
	 */
	private Texpfctr[] setupTexpfctrValues(Results myResults) {

		//log.debug("in setupTexpfctrValues");

		List<Texpfctr> TexpfctrList = new ArrayList<Texpfctr>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Texpfctr thisTexpfctr = new Texpfctr();

			thisTexpfctr.setTexpfctr_exprid(Integer.parseInt(dataRow[0]));
			thisTexpfctr.setTexpfctr_id(Integer.parseInt(dataRow[1]));
			thisTexpfctr.setTexpfctr_del_status(dataRow[2]);
			thisTexpfctr.setTexpfctr_user(dataRow[3]);
			thisTexpfctr.setTexpfctr_last_change(new ObjectHandler().getOracleDateAsTimestamp(dataRow[4]));
			thisTexpfctr.setFactorName(dataRow[5]);

			TexpfctrList.add(thisTexpfctr);
		}

		Texpfctr[] TexpfctrArray = (Texpfctr[]) TexpfctrList.toArray(new Texpfctr[TexpfctrList.size()]);

		return TexpfctrArray;
	}

	/**
	 * Compares Texpfctr based on different fields.
	 */
	public class TexpfctrSortComparator implements Comparator<Texpfctr> {
		int compare;
		Texpfctr texpfctr1, texpfctr2;

		public int compare(Texpfctr object1, Texpfctr object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				texpfctr1 = object1;
				texpfctr2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				texpfctr2 = object1;
				texpfctr1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("texpfctr1 = " +texpfctr1+ "texpfctr2 = " +texpfctr2);

			if (sortColumn.equals("texpfctr_exprid")) {
				compare = new Integer(texpfctr1.getTexpfctr_exprid()).compareTo(new Integer(texpfctr2.getTexpfctr_exprid()));
			} else if (sortColumn.equals("texpfctr_id")) {
				compare = new Integer(texpfctr1.getTexpfctr_id()).compareTo(new Integer(texpfctr2.getTexpfctr_id()));
			} else if (sortColumn.equals("texpfctr_del_status")) {
				compare = texpfctr1.getTexpfctr_del_status().compareTo(texpfctr2.getTexpfctr_del_status());
			} else if (sortColumn.equals("texpfctr_user")) {
				compare = texpfctr1.getTexpfctr_user().compareTo(texpfctr2.getTexpfctr_user());
			} else if (sortColumn.equals("texpfctr_last_change")) {
				compare = texpfctr1.getTexpfctr_last_change().compareTo(texpfctr2.getTexpfctr_last_change());
			}
			return compare;
		}
	}

	public Texpfctr[] sortTexpfctr (Texpfctr[] myTexpfctr, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myTexpfctr, new TexpfctrSortComparator());
		return myTexpfctr;
	}


	/**
	 * Converts Texpfctr object to a String.
	 */
	public String toString() {
		return "This Texpfctr has texpfctr_exprid = " + texpfctr_exprid;
	}

	/**
	 * Prints Texpfctr object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Texpfctr objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Texpfctr)) return false;
		return (this.texpfctr_exprid == ((Texpfctr)obj).texpfctr_exprid);

	}
}
