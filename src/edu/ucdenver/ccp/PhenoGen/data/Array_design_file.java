package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
/*
import java.io.File;

*/
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
 * Class for handling data related to Array_design_files
 *  @author  Cheryl Hornbaker
 */

public class Array_design_file {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public Array_design_file() {
		log = Logger.getRootLogger();
	}

	public Array_design_file(int file_id) {
		log = Logger.getRootLogger();
		this.setFile_id(file_id);
	}


	private int file_id;
	private String path;
	private int ardesin_id;
	private String created_by_login;
	private java.sql.Timestamp create_date;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setFile_id(int inInt) {
		this.file_id = inInt;
	}

	public int getFile_id() {
		return this.file_id;
	}

	public void setPath(String inString) {
		this.path = inString;
	}

	public String getPath() {
		return this.path;
	}

	public void setArdesin_id(int inInt) {
		this.ardesin_id = inInt;
	}

	public int getArdesin_id() {
		return this.ardesin_id;
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
	 * Gets all the Array_design_files
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Array_design_file objects
	 */
	public Array_design_file[] getAllArray_design_files(Connection conn) throws SQLException {

		log.debug("In getAllArray_design_files");

		String query = 
			"select "+
			"file_id, path, ardesin_id, "+
			"created_by_login, to_char(create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from array_design_files "+ 
			"order by file_id";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Array_design_file[] myArray_design_file = setupArray_design_fileValues(myResults);

		myResults.close();

		return myArray_design_file;
	}

	/**
	 * Gets the Array_design_file object for this file_id
	 * @param file_id	 the identifier of the Array_design_file
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Array_design_file object
	 */
	public Array_design_file getArray_design_file(int file_id, Connection conn) throws SQLException {

		log.debug("In getOne Array_design_file");

		String query = 
			"select "+
			"file_id, path, ardesin_id, "+
			"created_by_login, to_char(create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from array_design_files "+ 
			"where file_id = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, file_id, conn);

		Array_design_file myArray_design_file = setupArray_design_fileValues(myResults)[0];

		myResults.close();

		return myArray_design_file;
	}

	/**
	 * Creates a record in the Array_design_file table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createArray_design_file(Connection conn) throws SQLException {

		log.debug("In create Array_design_file");

		int file_id = myDbUtils.getUniqueID("Array_design_files_seq", conn);

		String query = 
			"insert into array_design_files "+
			"(file_id, path, ardesin_id, created_by_login, create_date) "+
			"values "+
			"(?, ?, ?, ?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, file_id);
		pstmt.setString(2, path);
		myDbUtils.setToNullIfZero(pstmt, 3, ardesin_id);
		pstmt.setString(4, created_by_login);
		pstmt.setTimestamp(5, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setFile_id(file_id);

		return file_id;
	}

	/**
	 * Updates a record in the array_design_files table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 
			"update array_design_files "+
			"set file_id = ?, path = ?, ardesin_id = ?, created_by_login = ?, create_date = ? "+
			"where file_id = ?";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, file_id);
		pstmt.setString(2, path);
		myDbUtils.setToNullIfZero(pstmt, 3, ardesin_id);
		pstmt.setString(4, created_by_login);
		pstmt.setTimestamp(5, now);
		pstmt.setInt(6, file_id);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the array_design_files table and also deletes child records in related tables.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */
	public void deleteArray_design_file(Connection conn) throws SQLException {

		log.info("in deleteArray_design_file");

		//conn.setAutoCommit(false);

		PreparedStatement pstmt = null;
		try {
			String query = 
				"delete from array_design_files " + 
				"where file_id = ?";

			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

			pstmt.setInt(1, file_id);
			pstmt.executeQuery();
			pstmt.close();

			//conn.commit();
		} catch (SQLException e) {
			log.debug("error in deleteArray_design_file");
			//conn.rollback();
			pstmt.close();
			throw e;
		}
		//conn.setAutoCommit(true);
	}

	/**
	 * Creates an array of Array_design_file objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Array_design_file
	 * @return	An array of Array_design_file objects with their values setup 
	 */
	private Array_design_file[] setupArray_design_fileValues(Results myResults) {

		//log.debug("in setupArray_design_fileValues");

		List<Array_design_file> Array_design_fileList = new ArrayList<Array_design_file>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Array_design_file thisArray_design_file = new Array_design_file();

			thisArray_design_file.setFile_id(Integer.parseInt(dataRow[0]));
			thisArray_design_file.setPath(dataRow[1]);
                        if (dataRow[2] != null) {
				thisArray_design_file.setArdesin_id(Integer.parseInt(dataRow[2]));
			}
			thisArray_design_file.setCreated_by_login(dataRow[3]);
			thisArray_design_file.setCreate_date(new ObjectHandler().getOracleDateAsTimestamp(dataRow[4]));

			Array_design_fileList.add(thisArray_design_file);
		}

		Array_design_file[] Array_design_fileArray = (Array_design_file[]) Array_design_fileList.toArray(new Array_design_file[Array_design_fileList.size()]);

		return Array_design_fileArray;
	}

	/**
	 * Compares Array_design_file based on different fields.
	 */
	public class Array_design_fileSortComparator implements Comparator<Array_design_file> {
		int compare;
		Array_design_file data_file1, data_file2;

		public int compare(Array_design_file object1, Array_design_file object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				data_file1 = object1;
				data_file2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				data_file2 = object1;
				data_file1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("data_file1 = " +data_file1+ "data_file2 = " +data_file2);

			if (sortColumn.equals("file_id")) {
				compare = new Integer(data_file1.getFile_id()).compareTo(new Integer(data_file2.getFile_id()));
			} else if (sortColumn.equals("path")) {
				compare = data_file1.getPath().compareTo(data_file2.getPath());
			} else if (sortColumn.equals("ardesin_id")) {
				compare = new Integer(data_file1.getArdesin_id()).compareTo(new Integer(data_file2.getArdesin_id()));
			} else if (sortColumn.equals("created_by_login")) {
				compare = data_file1.getCreated_by_login().compareTo(data_file2.getCreated_by_login());
			} else if (sortColumn.equals("create_date")) {
				compare = data_file1.getCreate_date().compareTo(data_file2.getCreate_date());
			}
			return compare;
		}
	}

	public Array_design_file[] sortArray_design_file (Array_design_file[] myArray_design_file, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myArray_design_file, new Array_design_fileSortComparator());
		return myArray_design_file;
	}


	/**
	 * Converts Array_design_file object to a String.
	 */
	public String toString() {
		return "This Array_design_file has file_id = " + file_id;
	}

	/**
	 * Prints Array_design_file object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Array_design_file objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Array_design_file)) return false;
		return (this.file_id == ((Array_design_file)obj).file_id);

	}
}
