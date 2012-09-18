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
 * Class for handling data related to Tpublic
 *  @author  Cheryl Hornbaker
 */

public class Tpublic {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public Tpublic() {
		log = Logger.getRootLogger();
	}

	public Tpublic(int tpublic_sysuid) {
		log = Logger.getRootLogger();
		this.setTpublic_sysuid(tpublic_sysuid);
	}


	private int tpublic_sysuid;
	private int tpublic_subid;
	private String tpublic_title;
	private int tpublic_status;
	private int tpublic_publication;
	private int tpublic_year;
	private String tpublic_volume;
	private int tpublic_first_page;
	private int tpublic_last_page;
	private String tpublic_del_status = "U";
	private String tpublic_user;
	private java.sql.Timestamp tpublic_last_change;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setTpublic_sysuid(int inInt) {
		this.tpublic_sysuid = inInt;
	}

	public int getTpublic_sysuid() {
		return this.tpublic_sysuid;
	}

	public void setTpublic_subid(int inInt) {
		this.tpublic_subid = inInt;
	}

	public int getTpublic_subid() {
		return this.tpublic_subid;
	}

	public void setTpublic_title(String inString) {
		this.tpublic_title = inString;
	}

	public String getTpublic_title() {
		return this.tpublic_title;
	}

	public void setTpublic_status(int inInt) {
		this.tpublic_status = inInt;
	}

	public int getTpublic_status() {
		return this.tpublic_status;
	}

	public void setTpublic_publication(int inInt) {
		this.tpublic_publication = inInt;
	}

	public int getTpublic_publication() {
		return this.tpublic_publication;
	}

	public void setTpublic_year(int inInt) {
		this.tpublic_year = inInt;
	}

	public int getTpublic_year() {
		return this.tpublic_year;
	}

	public void setTpublic_volume(String inString) {
		this.tpublic_volume = inString;
	}

	public String getTpublic_volume() {
		return this.tpublic_volume;
	}

	public void setTpublic_first_page(int inInt) {
		this.tpublic_first_page = inInt;
	}

	public int getTpublic_first_page() {
		return this.tpublic_first_page;
	}

	public void setTpublic_last_page(int inInt) {
		this.tpublic_last_page = inInt;
	}

	public int getTpublic_last_page() {
		return this.tpublic_last_page;
	}

	public void setTpublic_del_status(String inString) {
		this.tpublic_del_status = inString;
	}

	public String getTpublic_del_status() {
		return this.tpublic_del_status;
	}

	public void setTpublic_user(String inString) {
		this.tpublic_user = inString;
	}

	public String getTpublic_user() {
		return this.tpublic_user;
	}

	public void setTpublic_last_change(java.sql.Timestamp inTimestamp) {
		this.tpublic_last_change = inTimestamp;
	}

	public java.sql.Timestamp getTpublic_last_change() {
		return this.tpublic_last_change;
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
	 * Gets all the Tpublic
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Tpublic objects
	 */
	public Tpublic[] getAllTpublic(Connection conn) throws SQLException {

		log.debug("In getAllTpublic");

		String query = 
			"select "+
			"tpublic_sysuid, tpublic_subid, tpublic_title, tpublic_status, tpublic_publication, "+
			"tpublic_year, tpublic_volume, tpublic_first_page, tpublic_last_page, tpublic_del_status, "+
			"tpublic_user, to_char(tpublic_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tpublic "+ 
			"order by tpublic_sysuid";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Tpublic[] myTpublic = setupTpublicValues(myResults);

		myResults.close();

		return myTpublic;
	}

	/**
	 * Gets the Tpublic object for this tpublic_sysuid
	 * @param tpublic_sysuid	 the identifier of the Tpublic
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tpublic object
	 */
	public Tpublic getTpublic(int tpublic_sysuid, Connection conn) throws SQLException {

		log.debug("In getOne Tpublic");

		String query = 
			"select "+
			"tpublic_sysuid, tpublic_subid, tpublic_title, tpublic_status, tpublic_publication, "+
			"tpublic_year, tpublic_volume, tpublic_first_page, tpublic_last_page, tpublic_del_status, "+
			"tpublic_user, to_char(tpublic_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tpublic "+ 
			"where tpublic_sysuid = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, tpublic_sysuid, conn);

		Tpublic myTpublic = setupTpublicValues(myResults)[0];

		myResults.close();

		return myTpublic;
	}

	/**
	 * Creates a record in the Tpublic table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createTpublic(Connection conn) throws SQLException {

		int tpublic_sysuid = myDbUtils.getUniqueID("Tpublic_seq", conn);

		log.debug("In create Tpublic");

		String query = 
			"insert into Tpublic "+
			"(tpublic_sysuid, tpublic_subid, tpublic_title, tpublic_status, tpublic_publication, "+
			"tpublic_year, tpublic_volume, tpublic_first_page, tpublic_last_page, tpublic_del_status, "+
			"tpublic_user, tpublic_last_change) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?, ?, ?, ?, "+
			"?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tpublic_sysuid);
		pstmt.setInt(2, tpublic_subid);
		pstmt.setString(3, tpublic_title);
		pstmt.setInt(4, tpublic_status);
		pstmt.setInt(5, tpublic_publication);
		pstmt.setInt(6, tpublic_year);
		pstmt.setString(7, tpublic_volume);
		pstmt.setInt(8, tpublic_first_page);
		pstmt.setInt(9, tpublic_last_page);
		pstmt.setString(10, "U");
		pstmt.setString(11, tpublic_user);
		pstmt.setTimestamp(12, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setTpublic_sysuid(tpublic_sysuid);

		return tpublic_sysuid;
	}

	/**
	 * Updates a record in the Tpublic table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 

			"update Tpublic "+
			"set tpublic_sysuid = ?, tpublic_subid = ?, tpublic_title = ?, tpublic_status = ?, tpublic_publication = ?, "+
			"tpublic_year = ?, tpublic_volume = ?, tpublic_first_page = ?, tpublic_last_page = ?, tpublic_del_status = ?, "+
			"tpublic_user = ?, tpublic_last_change = ? "+
			"where tpublic_sysuid = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tpublic_sysuid);
		pstmt.setInt(2, tpublic_subid);
		pstmt.setString(3, tpublic_title);
		pstmt.setInt(4, tpublic_status);
		pstmt.setInt(5, tpublic_publication);
		pstmt.setInt(6, tpublic_year);
		pstmt.setString(7, tpublic_volume);
		pstmt.setInt(8, tpublic_first_page);
		pstmt.setInt(9, tpublic_last_page);
		pstmt.setString(10, tpublic_del_status);
		pstmt.setString(11, tpublic_user);
		pstmt.setTimestamp(12, now);
		pstmt.setInt(13, tpublic_sysuid);

		pstmt.executeUpdate();
		pstmt.close();

	}


        /**
         * Deletes the record in the Tpublic table and also deletes child records in related tables.
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteTpublic(Connection conn) throws SQLException {

                log.info("in deleteTpublic");

                //conn.setAutoCommit(false);

                PreparedStatement pstmt = null;
                try {

                        //new Tauthor().deleteAllTauthorForTpublic(tpublic_sysuid, conn);

                        String query =
				"delete from Tpublic " + 
				"where tpublic_sysuid = ?";

                        pstmt = conn.prepareStatement(query,
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                        pstmt.setInt(1, tpublic_sysuid);
                        pstmt.executeQuery();
                        pstmt.close();

                        //conn.commit();
                } catch (SQLException e) {
                        log.debug("error in deleteTpublic");
                        //conn.rollback();
                        pstmt.close();
                        throw e;
                }
                //conn.setAutoCommit(true);
        }

        /**
         * Deletes the records in the Tpublic table that are children of Experiment.
         * @param subid        the subid from the Experiment table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTpublicForExperiment(int subid, Connection conn) throws SQLException {

                log.info("in deleteAllTpublicForExperiment");

                //Make sure committing is handled in calling method!

                String query =
                        "select tpublic_sysuid "+
                        "from Tpublic "+
                        "where tpublic_subid = ?";

                Results myResults = new Results(query, subid, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Tpublic(tpublic_sysuid).deleteTpublic(conn);
                }

                myResults.close();

        }

	/**
	 * Checks to see if a Tpublic with the same  combination already exists.
	 * @param myTpublic	the Tpublic object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the tpublic_sysuid of a Tpublic that currently exists
	 */
	public int checkRecordExists(Tpublic myTpublic, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select tpublic_sysuid "+
			"from Tpublic "+
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
	 * Creates an array of Tpublic objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Tpublic
	 * @return	An array of Tpublic objects with their values setup 
	 */
	private Tpublic[] setupTpublicValues(Results myResults) {

		//log.debug("in setupTpublicValues");

		List<Tpublic> TpublicList = new ArrayList<Tpublic>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Tpublic thisTpublic = new Tpublic();

			thisTpublic.setTpublic_sysuid(Integer.parseInt(dataRow[0]));
			thisTpublic.setTpublic_subid(Integer.parseInt(dataRow[1]));
			thisTpublic.setTpublic_title(dataRow[2]);
			thisTpublic.setTpublic_status(Integer.parseInt(dataRow[3]));
			thisTpublic.setTpublic_publication(Integer.parseInt(dataRow[4]));
			thisTpublic.setTpublic_year(Integer.parseInt(dataRow[5]));
			thisTpublic.setTpublic_volume(dataRow[6]);
			thisTpublic.setTpublic_first_page(Integer.parseInt(dataRow[7]));
			thisTpublic.setTpublic_last_page(Integer.parseInt(dataRow[8]));
			thisTpublic.setTpublic_del_status(dataRow[9]);
			thisTpublic.setTpublic_user(dataRow[10]);
			thisTpublic.setTpublic_last_change(new ObjectHandler().getOracleDateAsTimestamp(dataRow[11]));

			TpublicList.add(thisTpublic);
		}

		Tpublic[] TpublicArray = (Tpublic[]) TpublicList.toArray(new Tpublic[TpublicList.size()]);

		return TpublicArray;
	}

	/**
	 * Compares Tpublic based on different fields.
	 */
	public class TpublicSortComparator implements Comparator<Tpublic> {
		int compare;
		Tpublic tpublic1, tpublic2;

		public int compare(Tpublic object1, Tpublic object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				tpublic1 = object1;
				tpublic2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				tpublic2 = object1;
				tpublic1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("tpublic1 = " +tpublic1+ "tpublic2 = " +tpublic2);

			if (sortColumn.equals("tpublic_sysuid")) {
				compare = new Integer(tpublic1.getTpublic_sysuid()).compareTo(new Integer(tpublic2.getTpublic_sysuid()));
			} else if (sortColumn.equals("tpublic_subid")) {
				compare = new Integer(tpublic1.getTpublic_subid()).compareTo(new Integer(tpublic2.getTpublic_subid()));
			} else if (sortColumn.equals("tpublic_title")) {
				compare = tpublic1.getTpublic_title().compareTo(tpublic2.getTpublic_title());
			} else if (sortColumn.equals("tpublic_status")) {
				compare = new Integer(tpublic1.getTpublic_status()).compareTo(new Integer(tpublic2.getTpublic_status()));
			} else if (sortColumn.equals("tpublic_publication")) {
				compare = new Integer(tpublic1.getTpublic_publication()).compareTo(new Integer(tpublic2.getTpublic_publication()));
			} else if (sortColumn.equals("tpublic_year")) {
				compare = new Integer(tpublic1.getTpublic_year()).compareTo(new Integer(tpublic2.getTpublic_year()));
			} else if (sortColumn.equals("tpublic_volume")) {
				compare = tpublic1.getTpublic_volume().compareTo(tpublic2.getTpublic_volume());
			} else if (sortColumn.equals("tpublic_first_page")) {
				compare = new Integer(tpublic1.getTpublic_first_page()).compareTo(new Integer(tpublic2.getTpublic_first_page()));
			} else if (sortColumn.equals("tpublic_last_page")) {
				compare = new Integer(tpublic1.getTpublic_last_page()).compareTo(new Integer(tpublic2.getTpublic_last_page()));
			} else if (sortColumn.equals("tpublic_del_status")) {
				compare = tpublic1.getTpublic_del_status().compareTo(tpublic2.getTpublic_del_status());
			} else if (sortColumn.equals("tpublic_user")) {
				compare = tpublic1.getTpublic_user().compareTo(tpublic2.getTpublic_user());
			} else if (sortColumn.equals("tpublic_last_change")) {
				compare = tpublic1.getTpublic_last_change().compareTo(tpublic2.getTpublic_last_change());
			}
			return compare;
		}
	}

	public Tpublic[] sortTpublic (Tpublic[] myTpublic, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myTpublic, new TpublicSortComparator());
		return myTpublic;
	}


	/**
	 * Converts Tpublic object to a String.
	 */
	public String toString() {
		return "This Tpublic has tpublic_sysuid = " + tpublic_sysuid;
	}

	/**
	 * Prints Tpublic object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Tpublic objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Tpublic)) return false;
		return (this.tpublic_sysuid == ((Tpublic)obj).tpublic_sysuid);

	}
}
