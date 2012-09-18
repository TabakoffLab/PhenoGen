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
 * Class for handling data related to Downloads
 *  @author  Cheryl Hornbaker
 */

public class Download {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public Download() {
		log = Logger.getRootLogger();
	}

	public Download(int download_id) {
		log = Logger.getRootLogger();
		this.setDownload_id(download_id);
	}


	private int download_id;
	private String url;
	private java.sql.Timestamp create_date;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setDownload_id(int inInt) {
		this.download_id = inInt;
	}

	public int getDownload_id() {
		return this.download_id;
	}

	public void setURL(String inString) {
		this.url = inString;
	}

	public String getURL() {
		return this.url;
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
	 * Gets all the Downloads
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Download objects
	 */
	public Download[] getAllDownloads(Connection conn) throws SQLException {

		log.debug("In getAllDownloads");

		String query = 
			"select "+
			"download_id, url, to_char(create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Downloads "+ 
			"order by download_id";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Download[] myDownloads = setupDownloadValues(myResults);

		myResults.close();

		return myDownloads;
	}

	/**
	 * Gets the Download object for this download_id
	 * @param download_id	 the identifier of the Download
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Download object
	 */
	public Download getDownload(int download_id, Connection conn) throws SQLException {

		log.debug("In getOne Download");

		String query = 
			"select "+
			"download_id, url, to_char(create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Downloads "+ 
			"where download_id = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, download_id, conn);

		Download myDownload = setupDownloadValues(myResults)[0];

		myResults.close();

		return myDownload;
	}

	/**
	 * Creates a record in the Downloads table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createDownload(Connection conn) throws SQLException {

		log.debug("In create Download");

		int download_id = myDbUtils.getUniqueID("downloads_seq", conn);

		String query = 
			"insert into Downloads "+
			"(download_id, url, create_date) "+
			"values "+
			"(?, ?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, download_id);
		pstmt.setString(2, url);
		pstmt.setTimestamp(3, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setDownload_id(download_id);

		return download_id;
	}

	/**
	 * Updates a record in the Downloads table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 
			"update Downloads "+
			"set download_id = ?, url = ?, create_date = ? "+
			"where download_id = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, download_id);
		pstmt.setString(2, url);
		pstmt.setTimestamp(3, now);
		pstmt.setInt(4, download_id);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the Download table and also deletes child records in related tables.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */
	public void deleteDownload(Connection conn) throws SQLException {

		log.info("in deleteDownload");

		//conn.setAutoCommit(false);

		PreparedStatement pstmt = null;
		try {


			String query = 
				"delete from Downloads " + 
				"where download_id = ?";

			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

			pstmt.setInt(1, download_id);
			pstmt.executeQuery();
			pstmt.close();

			//conn.commit();
		} catch (SQLException e) {
			log.debug("error in deleteDownload");
			//conn.rollback();
			pstmt.close();
			throw e;
		}
		//conn.setAutoCommit(true);
	}

	/**
	 * Checks to see if a Download with the same download_id combination already exists.
	 * @param myDownload	the Download object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the download_id of a Download that currently exists
	 */
	public int checkRecordExists(Download myDownload, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select download_id "+
			"from Downloads "+
			"where download_id = ?";

		PreparedStatement pstmt = conn.prepareStatement(query,
			ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, download_id);

		ResultSet rs = pstmt.executeQuery();

		int pk = (rs.next() ? rs.getInt(1) : -1);
		pstmt.close();
		return pk;
	}

	/**
	 * Creates an array of Download objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Downloads
	 * @return	An array of Download objects with their values setup 
	 */
	private Download[] setupDownloadValues(Results myResults) {

		//log.debug("in setupDownloadValues");

		List<Download> DownloadList = new ArrayList<Download>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Download thisDownload = new Download();

			if (dataRow[0] != null && !dataRow[0].equals("")) {
				thisDownload.setDownload_id(Integer.parseInt(dataRow[0]));
			}
			thisDownload.setURL(dataRow[1]);
			thisDownload.setCreate_date(new ObjectHandler().getOracleDateAsTimestamp(dataRow[2]));

			DownloadList.add(thisDownload);
		}

		Download[] DownloadArray = (Download[]) DownloadList.toArray(new Download[DownloadList.size()]);

		return DownloadArray;
	}

	/**
	 * Compares Downloads based on different fields.
	 */
	public class DownloadSortComparator implements Comparator<Download> {
		int compare;
		Download download1, download2;

		public int compare(Download object1, Download object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				download1 = object1;
				download2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				download2 = object1;
				download1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("download1 = " +download1+ "download2 = " +download2);

			if (sortColumn.equals("download_id")) {
				compare = new Integer(download1.getDownload_id()).compareTo(new Integer(download2.getDownload_id()));
			} else if (sortColumn.equals("url")) {
				compare = download1.getURL().compareTo(download2.getURL());
			} else if (sortColumn.equals("create_date")) {
				compare = download1.getCreate_date().compareTo(download2.getCreate_date());
			}
			return compare;
		}
	}

	public Download[] sortDownloads (Download[] myDownloads, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myDownloads, new DownloadSortComparator());
		return myDownloads;
	}


	/**
	 * Converts Downloads object to a String.
	 */
	public String toString() {
		return "This Download has download_id = " + download_id;
	}

	/**
	 * Prints Download object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Download objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Download)) return false;
		return (this.download_id == ((Download)obj).download_id);

	}
}
