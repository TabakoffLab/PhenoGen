package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.Results;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to Data_files
 *  @author  Cheryl Hornbaker
 */

public class Data_file {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public Data_file() {
		log = Logger.getRootLogger();
	}

	public Data_file(int file_id) {
		log = Logger.getRootLogger();
		this.setFile_id(file_id);
	}


	private int file_id;
	private String path;
	private int hybrid_id;
	private int trans_hybrid_id;
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

	public void setHybrid_id(int inInt) {
		this.hybrid_id = inInt;
	}

	public int getHybrid_id() {
		return this.hybrid_id;
	}

	public void setTrans_hybrid_id(int inInt) {
		this.trans_hybrid_id = inInt;
	}

	public int getTrans_hybrid_id() {
		return this.trans_hybrid_id;
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
	 * Gets all the Data_files
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Data_file objects
	 */
	public Data_file[] getAllData_files(Connection conn) throws SQLException {

		log.debug("In getAllData_file");

		String query = 
			"select "+
			"file_id, path, "+
			"hybrid_id, trans_hybrid_id, "+
			"created_by_login, to_char(create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from data_files "+ 
			"order by file_id";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Data_file[] myData_file = setupData_fileValues(myResults);

		myResults.close();

		return myData_file;
	}

	/**
	 * Gets the Data_file object for this hybrid_id
	 * @param hybrid_id	 the identifier of the Hybridization
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Data_file object
	 */
	public Data_file getData_fileForHybridId(int hybrid_id, Connection conn) throws SQLException {

		log.debug("In getData_fileForHybridId");

		String query = 
			"select "+
			"file_id, path, "+
			"hybrid_id, trans_hybrid_id, "+
			"created_by_login, to_char(create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from data_files "+ 
			"where hybrid_id = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, hybrid_id, conn);

		Data_file myData_file = (myResults != null && myResults.getNumRows() > 0 ? setupData_fileValues(myResults)[0] : null);

		myResults.close();

		return myData_file;
	}

	/**
	 * Gets the Data_file object for this file_id
	 * @param file_id	 the identifier of the Data_file
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Data_file object
	 */
	public Data_file getData_file(int file_id, Connection conn) throws SQLException {

		log.debug("In getOne Data_file");

		String query = 
			"select "+
			"file_id, path, "+
			"hybrid_id, trans_hybrid_id, "+
			"created_by_login, to_char(create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from data_files "+ 
			"where file_id = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, file_id, conn);

		Data_file myData_file = setupData_fileValues(myResults)[0];

		myResults.close();

		return myData_file;
	}

	/**
	 * Creates a record in the Data_file table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createData_file(Connection conn) throws SQLException {

		log.debug("In create Data_file");

		int file_id = myDbUtils.getUniqueID("data_files_seq", conn);

		String query = 
			"insert into data_files "+
			"(file_id, path, hybrid_id, trans_hybrid_id, created_by_login, "+
			"create_date) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, file_id);
		pstmt.setString(2, path);
		pstmt.setInt(3, hybrid_id);
		myDbUtils.setToNullIfZero(pstmt, 4, trans_hybrid_id);
		pstmt.setString(5, created_by_login);
		pstmt.setTimestamp(6, now);

		pstmt.executeUpdate();
		log.debug("just created data_file");
		pstmt.close();

		this.setFile_id(file_id);

		return file_id;
	}

	/**
	 * Updates a record in the data_files table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 
			"update data_files "+
			"set file_id = ?, path = ?, hybrid_id = ?, trans_hybrid_id = ?, created_by_login = ?, "+
			"create_date = ? "+
			"where file_id = ?";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, file_id);
		pstmt.setString(2, path);
		pstmt.setInt(3, hybrid_id);
		myDbUtils.setToNullIfZero(pstmt, 4, trans_hybrid_id);
		pstmt.setString(5, created_by_login);
		pstmt.setTimestamp(6, now);
		pstmt.setInt(7, file_id);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the data_files table and also deletes child records in related tables.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */
	public void deleteData_file(Connection conn) throws SQLException {

		log.info("in deleteData_file");

		//conn.setAutoCommit(false);

		PreparedStatement pstmt = null;
		try {
			String query = 
				"delete from data_files " + 
				"where file_id = ?";

			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

			pstmt.setInt(1, file_id);
			pstmt.executeQuery();
			pstmt.close();

			//conn.commit();
		} catch (SQLException e) {
			log.debug("error in deleteData_file");
			//conn.rollback();
			pstmt.close();
			throw e;
		}
		//conn.setAutoCommit(true);
	}

	/**
	 * Deletes the records in the data_files table that are children of Hybridization.
	 * @param hybrid_id	identifier of the Hybridization table
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */
	public void deleteAllData_filesForHybridization(int hybrid_id, Connection conn) throws SQLException {

		log.info("in deleteAllData_filesForHybridization");

		//Make sure committing is handled in calling method!

		String query = 
			"select file_id "+
			"from data_files "+
			"where hybrid_id = ?";

		Results myResults = new Results(query, hybrid_id, conn);

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {
			new Data_file(Integer.parseInt(dataRow[0])).deleteData_file(conn);
		}

		myResults.close();

	}

	/**
	 * Checks to see if a Data_file with the same  combination already exists.
	 * @param myData_file	the Data_file object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the file_id of a Data_file that currently exists
	 */
/*
	public int checkRecordExists(Data_file myData_file, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select file_id "+
			"from data_files "+
			"where path = ?";

		PreparedStatement pstmt = conn.prepareStatement(query,
			ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_UPDATABLE);


		ResultSet rs = pstmt.executeQuery();

		int pk = (rs.next() ? rs.getInt(1) : -1);
		pstmt.close();
		return pk;
	}
*/


	/**
	 * Moves the CEL file from the temporary upload directory, and either updates the existing Data_file record or creates a new one
	 * @param tempFile	the File object in the Experiments/uploads directory
	 * @param dummyFile	the File object using the MIAMExpress directory structure directory (creates a file pointing to centralLocation)
	 * @param centralLocation	the File object file using the Array_datafiles directory
	 * @param hybridID	the identifier of the hybrid record
	 * @param userName	the name of the user
	 * @param conn	the database connection
	 * @throws	IOException if an error occurs while copying the file
	 * @throws      SQLException if an error occurs while accessing the database
	 */
	public void putFileInPlace(File tempFile, File dummyFile, File centralLocation, int hybridID, String userName, Connection conn) throws IOException, SQLException {
		log.debug("in Data_file putFileInPlace. dummyFile = "+dummyFile);
		createDummyFile(dummyFile, centralLocation);
		new FileHandler().copyFile(tempFile, centralLocation);
                Data_file thisData_file = new Data_file().getData_fileForHybridId(hybridID, conn);
                if (thisData_file != null) {
                	thisData_file.setPath(dummyFile.getName());
                        log.debug("setting Path to  "+dummyFile.getName());
                        thisData_file.update(conn); 
                        log.debug("updated existing file ID = "+thisData_file.getFile_id());
                } else {
                	Data_file myData_file = new Data_file();
                        myData_file.setPath(dummyFile.getName());
                        myData_file.setHybrid_id(hybridID);
                        myData_file.setCreated_by_login(userName);
                        int file_id = myData_file.createData_file(conn); 
                        log.debug("created new file ID = "+file_id);
                }
	}

        /** Creates a dummy file in the directory structure leftover from MIAMExpress.
         *
         */
        public void createDummyFile(File thisFile, File pointsTo) throws IOException {
                String newFileName = thisFile.getPath() + ".dummy";
		BufferedWriter fileWriter = new BufferedWriter(new FileWriter(new File(newFileName)));

                fileWriter.write("This is an empty file.  Actual file is stored in the " + pointsTo.getParent() + " directory");
                fileWriter.newLine();
                fileWriter.close();
        }



	/** Upload data file
	 *
	 */
	public String uploadDataFile(HttpSession session, String nextFileName, int hybridID, Experiment selectedExperiment, Connection conn) throws Exception {
		String userFilesRoot = (String) session.getAttribute("userFilesRoot");
		User userLoggedIn = (User) session.getAttribute("userLoggedIn");
		log.debug("userLoggedIn = "+userLoggedIn);
	        String experimentUploadDir = userLoggedIn.getUserExperimentUploadDir();
                edu.ucdenver.ccp.PhenoGen.data.Array thisArray =
                                new edu.ucdenver.ccp.PhenoGen.data.Array().getSampleDetailsForHybridID(hybridID, conn);
                log.debug("thisArray submitter = "+thisArray.getSubmitter());
		String rawDataFileLocation = thisArray.getRawDataFileLocation(userFilesRoot);
		String arrayDatafilesDir = thisArray.getArrayDataFilesLocation(userFilesRoot);

		new FileHandler().createDir(rawDataFileLocation);
		log.debug("raw datafile upload dir = "+rawDataFileLocation);
                String tempFileName = experimentUploadDir + nextFileName;
		File tempFile = new File(tempFileName);
                String celFileName = rawDataFileLocation + nextFileName;
                File celFile = new File(celFileName);
                String centralLocation = arrayDatafilesDir + nextFileName;
		File centralFile = new File(centralLocation);
                log.debug("celFileName = "+celFileName);

                boolean celFileIsUnique = fileNameIsUnique(nextFileName, hybridID, selectedExperiment.getExp_id(), conn);
		boolean celFileIsUnique2 = fileNameIsUnique(nextFileName, hybridID, conn);
		log.debug("celFileIsUnique = "+celFileIsUnique);
                log.debug("celFileIsUnique2 = "+celFileIsUnique2);
                if (!celFileIsUnique) {
                        session.setAttribute("additionalInfo", "Duplicate data file name is: "+nextFileName);
			return ("EXP-049");
		} else if (!celFileIsUnique2) {
                        session.setAttribute("additionalInfo", "Duplicate data file name is: "+nextFileName);
			return ("EXP-053");
		} else {
                	// 
                        // If the length of the file that was created on the server is 0,
                        // the remote file must not have existed.
                        //
                        if (tempFile.length() == 0) {
                        	tempFile.delete();
				//Error - "File does not exist"
                                return ("GL-002");
			} else {
                        	try {
                                	putFileInPlace(tempFile, celFile, centralFile, hybridID, selectedExperiment.getCreated_by_login(), conn);
					return("");
				} catch (Exception e) {
					log.error("did not successfully upload CEL Files because of Error.");
					throw e;
				}
			}
		}
	}

	/**
	 * Checks to see that the file name is unique for the experiment
	 * @param file_name	the name of the raw data file
	 * @param hybridID	the identifier of the array
	 * @param expID	the identifier of the experiment
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	true if the file name is unique, false otherwise
	 */
	public boolean fileNameIsUnique(String file_name, int hybridID, int expID, Connection conn) throws SQLException {
		log.debug("in Data_file fileNameIsUnique. name = "+file_name);
		String query = 
			"select file_id "+
			"from experimentdetails "+
			"where exp_id = ? "+
			"and hybrid_id != ? " +
			"and path = ?"; 
		
		log.debug("query = "+query);
	
		Results myResults = new Results(query, new Object[] {expID, hybridID, file_name}, conn);

		int existingID = myResults.getIntValueFromFirstRow();

		myResults.close();

		return (existingID == -99 ? true : false);
	}

	/**
	 * Checks to see that the file name is unique for all experiments
	 * @param file_name	the name of the raw data file
	 * @param hybridID	the identifier of the array
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	true if the file name is unique, false otherwise
	 */
	public boolean fileNameIsUnique(String file_name, int hybridID, Connection conn) throws SQLException {
		log.debug("in Data_file fileNameIsUnique. name = "+file_name);
		String query = 
			"select file_id "+
			"from experimentdetails "+
			"where path = ? "+ 
			"and hybrid_id != ?";
		
		log.debug("query = "+query);
	
		Results myResults = new Results(query, new Object[] {file_name, hybridID}, conn);

		int existingID = myResults.getIntValueFromFirstRow();

		myResults.close();

		return (existingID == -99 ? true : false);
	}

	/**
	 * Creates an array of Data_file objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Data_file
	 * @return	An array of Data_file objects with their values setup 
	 */
	private Data_file[] setupData_fileValues(Results myResults) {

		//log.debug("in setupData_fileValues");

		List<Data_file> Data_fileList = new ArrayList<Data_file>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Data_file thisData_file = new Data_file();

			thisData_file.setFile_id(Integer.parseInt(dataRow[0]));
			thisData_file.setPath(dataRow[1]);
                        if (dataRow[2] != null) {
				thisData_file.setHybrid_id(Integer.parseInt(dataRow[2]));
			}
                        if (dataRow[3] != null) {
				thisData_file.setTrans_hybrid_id(Integer.parseInt(dataRow[3]));
			}
			thisData_file.setCreated_by_login(dataRow[4]);
			thisData_file.setCreate_date(new ObjectHandler().getOracleDateAsTimestamp(dataRow[5]));

			Data_fileList.add(thisData_file);
		}

		Data_file[] Data_fileArray = (Data_file[]) Data_fileList.toArray(new Data_file[Data_fileList.size()]);

		return Data_fileArray;
	}

	/**
	 * Compares Data_file based on different fields.
	 */
	public class Data_fileSortComparator implements Comparator<Data_file> {
		int compare;
		Data_file data_file1, data_file2;

		public int compare(Data_file object1, Data_file object2) {
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
			} else if (sortColumn.equals("hybrid_id")) {
				compare = new Integer(data_file1.getHybrid_id()).compareTo(new Integer(data_file2.getHybrid_id()));
			} else if (sortColumn.equals("trans_hybrid_id")) {
				compare = new Integer(data_file1.getTrans_hybrid_id()).compareTo(new Integer(data_file2.getTrans_hybrid_id()));
			} else if (sortColumn.equals("created_by_login")) {
				compare = data_file1.getCreated_by_login().compareTo(data_file2.getCreated_by_login());
			} else if (sortColumn.equals("create_date")) {
				compare = data_file1.getCreate_date().compareTo(data_file2.getCreate_date());
			}
			return compare;
		}
	}

	public Data_file[] sortData_file (Data_file[] myData_file, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myData_file, new Data_fileSortComparator());
		return myData_file;
	}


	/**
	 * Converts Data_file object to a String.
	 */
	public String toString() {
		return "This Data_file has file_id = " + file_id;
	}

	/**
	 * Prints Data_file object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Data_file objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Data_file)) return false;
		return (this.file_id == ((Data_file)obj).file_id);

	}
}
