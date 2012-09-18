package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

import edu.ucdenver.ccp.util.Debugger;

import edu.ucdenver.ccp.util.ObjectHandler;

import edu.ucdenver.ccp.util.sql.Results;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to Tntxsyn
 *  @author  Cheryl Hornbaker
 */

public class Tntxsyn {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public Tntxsyn() {
		log = Logger.getRootLogger();
	}

	public Tntxsyn(int tntxsyn_tax_id) {
		log = Logger.getRootLogger();
		this.setTntxsyn_tax_id(tntxsyn_tax_id);
	}


	private int tntxsyn_tax_id;
	private String tntxsyn_name_txt;
	private String tntxsyn_name_class;
	private String tntxsyn_unique_name;
	private String tntxsyn_upper_name_txt;
	private String tntxsyn_user;
	private java.sql.Timestamp tntxsyn_last_change;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setTntxsyn_tax_id(int inInt) {
		this.tntxsyn_tax_id = inInt;
	}

	public int getTntxsyn_tax_id() {
		return this.tntxsyn_tax_id;
	}

	public void setTntxsyn_name_txt(String inString) {
		this.tntxsyn_name_txt = inString;
	}

	public String getTntxsyn_name_txt() {
		return this.tntxsyn_name_txt;
	}

	public void setTntxsyn_name_class(String inString) {
		this.tntxsyn_name_class = inString;
	}

	public String getTntxsyn_name_class() {
		return this.tntxsyn_name_class;
	}

	public void setTntxsyn_unique_name(String inString) {
		this.tntxsyn_unique_name = inString;
	}

	public String getTntxsyn_unique_name() {
		return this.tntxsyn_unique_name;
	}

	public void setTntxsyn_upper_name_txt(String inString) {
		this.tntxsyn_upper_name_txt = inString;
	}

	public String getTntxsyn_upper_name_txt() {
		return this.tntxsyn_upper_name_txt;
	}

	public void setTntxsyn_user(String inString) {
		this.tntxsyn_user = inString;
	}

	public String getTntxsyn_user() {
		return this.tntxsyn_user;
	}

	public void setTntxsyn_last_change(java.sql.Timestamp inTimestamp) {
		this.tntxsyn_last_change = inTimestamp;
	}

	public java.sql.Timestamp getTntxsyn_last_change() {
		return this.tntxsyn_last_change;
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
	 * Gets all the Tntxsyn
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Tntxsyn objects
	 */
	public Tntxsyn[] getAllTntxsyn(Connection conn) throws SQLException {

		log.debug("In getAllTntxsyn");

		String query = 
			"select "+
			"tntxsyn_tax_id, tntxsyn_name_txt, tntxsyn_name_class, tntxsyn_unique_name, tntxsyn_upper_name_txt, "+
			"tntxsyn_user, to_char(tntxsyn_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tntxsyn "+ 
			"where tntxsyn_name_txt = 'Mus musculus' "+ 
			"or tntxsyn_name_txt like 'Rattus norvegicus' "+ 
			"or tntxsyn_name_txt like 'Drosophila melanogaster' "+ 
			"or tntxsyn_name_txt like 'Homo sapiens' "+ 
			"order by tntxsyn_tax_id";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		Tntxsyn[] myTntxsyn = setupTntxsynValues(myResults);

		myResults.close();

		return myTntxsyn;
	}

	/**
   	* Gets the set of values as select options
   	* @param conn        the database connection
   	* @throws            SQLException if a database error occurs
   	* @return            a LinkedHashMap of values
   	*/
	public LinkedHashMap<String, String> getValuesAsSelectOptions(Connection conn) throws SQLException {
        	//log.debug("in getValuesAsSelectOptions");

		Tntxsyn[] thisArray = getAllTntxsyn(conn);
        	LinkedHashMap<String, String> optionHash = new LinkedHashMap<String, String>();

        	for (int i=0; i<thisArray.length; i++) {
                	optionHash.put(Integer.toString(thisArray[i].getTntxsyn_tax_id()), thisArray[i].getTntxsyn_name_txt());
        	}
        	return optionHash;
	}

	/**
	 * Gets the Tntxsyn object for this tntxsyn_name_txt
	 * @param tntxsyn_name_txt	 the name of the Tntxsyn
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tntxsyn object
	 */
	public Tntxsyn getTaxID(String tntxsyn_name_txt, Connection conn) throws SQLException {

		log.debug("In getTaxID");

		String query = 
			"select "+
			"tntxsyn_tax_id, tntxsyn_name_txt, tntxsyn_name_class, tntxsyn_unique_name, tntxsyn_upper_name_txt, "+
			"tntxsyn_user, to_char(tntxsyn_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tntxsyn "+ 
			"where tntxsyn_name_txt = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, new Object[] {tntxsyn_name_txt}, conn);

		Tntxsyn myTntxsyn = setupTntxsynValues(myResults)[0];

		myResults.close();

		return myTntxsyn;
	}

	/**
	 * Gets the Tntxsyn object for this tntxsyn_tax_id
	 * @param tntxsyn_tax_id	 the identifier of the Tntxsyn
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tntxsyn object
	 */
	public Tntxsyn getTntxsyn(int tntxsyn_tax_id, Connection conn) throws SQLException {

		log.debug("In getOne Tntxsyn");

		String query = 
			"select "+
			"tntxsyn_tax_id, tntxsyn_name_txt, tntxsyn_name_class, tntxsyn_unique_name, tntxsyn_upper_name_txt, "+
			"tntxsyn_user, to_char(tntxsyn_last_change, 'dd-MON-yyyy hh24:mi:ss') "+
			"from Tntxsyn "+ 
			"where tntxsyn_tax_id = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, tntxsyn_tax_id, conn);

		Tntxsyn myTntxsyn = setupTntxsynValues(myResults)[0];

		myResults.close();

		return myTntxsyn;
	}

	/**
	 * Creates a record in the Tntxsyn table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createTntxsyn(Connection conn) throws SQLException {

		int tntxsyn_tax_id = myDbUtils.getUniqueID("Tntxsyn_seq", conn);

		log.debug("In create Tntxsyn");

		String query = 
			"insert into Tntxsyn "+
			"(tntxsyn_tax_id, tntxsyn_name_txt, tntxsyn_name_class, tntxsyn_unique_name, tntxsyn_upper_name_txt, "+
			"tntxsyn_user, tntxsyn_last_change) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?)";
		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tntxsyn_tax_id);
		pstmt.setString(2, tntxsyn_name_txt);
		pstmt.setString(3, tntxsyn_name_class);
		pstmt.setString(4, tntxsyn_unique_name);
		pstmt.setString(5, tntxsyn_upper_name_txt);
		pstmt.setString(6, tntxsyn_user);
		pstmt.setTimestamp(7, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setTntxsyn_tax_id(tntxsyn_tax_id);

		return tntxsyn_tax_id;
	}

	/**
	 * Updates a record in the Tntxsyn table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 

			"update Tntxsyn "+
			"set tntxsyn_tax_id = ?, tntxsyn_name_txt = ?, tntxsyn_name_class = ?, tntxsyn_unique_name = ?, tntxsyn_upper_name_txt = ?, "+
			"tntxsyn_user = ?, tntxsyn_last_change = ? "+
			"where tntxsyn_tax_id = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tntxsyn_tax_id);
		pstmt.setString(2, tntxsyn_name_txt);
		pstmt.setString(3, tntxsyn_name_class);
		pstmt.setString(4, tntxsyn_unique_name);
		pstmt.setString(5, tntxsyn_upper_name_txt);
		pstmt.setString(6, tntxsyn_user);
		pstmt.setTimestamp(7, now);
		pstmt.setInt(8, tntxsyn_tax_id);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the Tntxsyn table and also deletes child records in related tables.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */

	public void delete(Connection conn) throws SQLException {

		log.info("in deleteTntxsyn");

		//conn.setAutoCommit(false);

		PreparedStatement pstmt = null;
		try {
                        new Tsample().deleteAllTsampleForTntxsyn(tntxsyn_tax_id, conn);

			String query = 
				"delete from Tntxsyn " + 
				"where tntxsyn_tax_id = ?";

			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

			pstmt.setInt(1, tntxsyn_tax_id);
			pstmt.executeQuery();
			pstmt.close();

			//conn.commit();
		} catch (SQLException e) {
			log.debug("error in deleteTntxsyn");
			//conn.rollback();
			pstmt.close();
			throw e;
		}
		//conn.setAutoCommit(true);
	}

	/**
	 * Checks to see if a Tntxsyn with the same  combination already exists.
	 * @param myTntxsyn	the Tntxsyn object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the tntxsyn_tax_id of a Tntxsyn that currently exists
	 */
	public int checkRecordExists(Tntxsyn myTntxsyn, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select tntxsyn_tax_id "+
			"from Tntxsyn "+
			"where ";

		PreparedStatement pstmt = conn.prepareStatement(query,
			ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_UPDATABLE);


		ResultSet rs = pstmt.executeQuery();

		int pk = (rs.next() ? rs.getInt(1) : -1);
		pstmt.close();
		return pk;
	}

	/**
	 * Creates an array of Tntxsyn objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Tntxsyn
	 * @return	An array of Tntxsyn objects with their values setup 
	 */
	private Tntxsyn[] setupTntxsynValues(Results myResults) {

		//log.debug("in setupTntxsynValues");

		List<Tntxsyn> TntxsynList = new ArrayList<Tntxsyn>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Tntxsyn thisTntxsyn = new Tntxsyn();

			thisTntxsyn.setTntxsyn_tax_id(Integer.parseInt(dataRow[0]));
			thisTntxsyn.setTntxsyn_name_txt(dataRow[1]);
			thisTntxsyn.setTntxsyn_name_class(dataRow[2]);
			thisTntxsyn.setTntxsyn_unique_name(dataRow[3]);
			thisTntxsyn.setTntxsyn_upper_name_txt(dataRow[4]);
			thisTntxsyn.setTntxsyn_user(dataRow[5]);
			thisTntxsyn.setTntxsyn_last_change(new ObjectHandler().getOracleDateAsTimestamp(dataRow[6]));

			TntxsynList.add(thisTntxsyn);
		}

		Tntxsyn[] TntxsynArray = (Tntxsyn[]) TntxsynList.toArray(new Tntxsyn[TntxsynList.size()]);

		return TntxsynArray;
	}

	/**
	 * Compares Tntxsyn based on different fields.
	 */
	public class TntxsynSortComparator implements Comparator<Tntxsyn> {
		int compare;
		Tntxsyn tntxsyn1, tntxsyn2;

		public int compare(Tntxsyn object1, Tntxsyn object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				tntxsyn1 = object1;
				tntxsyn2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				tntxsyn2 = object1;
				tntxsyn1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("tntxsyn1 = " +tntxsyn1+ "tntxsyn2 = " +tntxsyn2);

			if (sortColumn.equals("tntxsyn_tax_id")) {
				compare = new Integer(tntxsyn1.getTntxsyn_tax_id()).compareTo(new Integer(tntxsyn2.getTntxsyn_tax_id()));
			} else if (sortColumn.equals("tntxsyn_name_txt")) {
				compare = tntxsyn1.getTntxsyn_name_txt().compareTo(tntxsyn2.getTntxsyn_name_txt());
			} else if (sortColumn.equals("tntxsyn_name_class")) {
				compare = tntxsyn1.getTntxsyn_name_class().compareTo(tntxsyn2.getTntxsyn_name_class());
			} else if (sortColumn.equals("tntxsyn_unique_name")) {
				compare = tntxsyn1.getTntxsyn_unique_name().compareTo(tntxsyn2.getTntxsyn_unique_name());
			} else if (sortColumn.equals("tntxsyn_upper_name_txt")) {
				compare = tntxsyn1.getTntxsyn_upper_name_txt().compareTo(tntxsyn2.getTntxsyn_upper_name_txt());
			} else if (sortColumn.equals("tntxsyn_user")) {
				compare = tntxsyn1.getTntxsyn_user().compareTo(tntxsyn2.getTntxsyn_user());
			} else if (sortColumn.equals("tntxsyn_last_change")) {
				compare = tntxsyn1.getTntxsyn_last_change().compareTo(tntxsyn2.getTntxsyn_last_change());
			}
			return compare;
		}
	}

	public Tntxsyn[] sortTntxsyn (Tntxsyn[] myTntxsyn, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myTntxsyn, new TntxsynSortComparator());
		return myTntxsyn;
	}


	/**
	 * Converts Tntxsyn object to a String.
	 */
	public String toString() {
		return "This Tntxsyn has tntxsyn_tax_id = " + tntxsyn_tax_id;
	}

	/**
	 * Prints Tntxsyn object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Tntxsyn objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Tntxsyn)) return false;
		return (this.tntxsyn_tax_id == ((Tntxsyn)obj).tntxsyn_tax_id);

	}
}
