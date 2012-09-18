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
import java.util.Set;
import java.util.TreeSet;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

import edu.ucdenver.ccp.util.Debugger;

import edu.ucdenver.ccp.util.ObjectHandler;

import edu.ucdenver.ccp.util.sql.Results;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to the valid_terms table
 *  @author  Cheryl Hornbaker
 */

public class ValidTerm {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public ValidTerm() {
		log = Logger.getRootLogger();
	}

	public ValidTerm(int term_id) {
		log = Logger.getRootLogger();
		this.setTerm_id(term_id);
	}


	private int term_id;
	private int display_order;
	private String category;
	private String value;
	private String description;
	private String interp;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setTerm_id(int inInt) {
		this.term_id = inInt;
	}

	public int getTerm_id() {
		return this.term_id;
	}

	public void setDisplay_order(int inInt) {
		this.display_order = inInt;
	}

	public int getDisplay_order() {
		return this.display_order;
	}

	public void setCategory(String inString) {
		this.category = inString;
	}

	public String getCategory() {
		return this.category;
	}

	public void setValue(String inString) {
		this.value = inString;
	}

	public String getValue() {
		return this.value;
	}

	public void setDescription(String inString) {
		this.description = inString;
	}

	public String getDescription() {
		return this.description;
	}

	public void setInterp(String inString) {
		this.interp = inString;
	}

	public String getInterp() {
		return this.interp;
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

	/** Gets the value for the matching ValidTerm record
	 * @param term_id	 the sysuid of the record
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the value of the matching ValidTerm record
	 */
	public String getValue(int term_id, Connection conn) throws SQLException {
		log.debug("in getValue for uid = " + term_id);
		return getValidTerm(term_id, conn).getValue();
	}

	/** Gets the sysuid for the matching ValidTerm record
	 * @param value the value to match
	 * @param type	 the type to match
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the system id of the matching ValidTerm record
	 */
	public int getSysuid(String value, String type, Connection conn) throws SQLException {
		log.debug("in getSysuid for value = " + value + ", and type = "+type);
		return getValidTermByValueAndID(value, type, conn).getTerm_id();
	}

	/**
	 * Gets all the ValidTerm of a certain type
	 * @param type 	the type to search for
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of ValidTerm objects
	 */
	public ValidTerm[] getFromValidTerm(String type, Connection conn) throws SQLException {
		String query = 
			"select "+
			"term_id, display_order, category, value, description, "+
			"interp "+
			"from valid_terms "+ 
			"where category = ? "+
			"order by upper(value)";

		Results myResults = new Results(query, type, conn);

		ValidTerm[] myValidTerm = setupValidTermValues(myResults);

		myResults.close();

		return myValidTerm;
	}

	/**
   	* Gets the set of values as select options
	* @param type 	the type to search for
   	* @param conn        the database connection
   	* @throws            SQLException if a database error occurs
   	* @return            a LinkedHashMap of values
   	*/
	public LinkedHashMap<String, String> getValuesAsSelectOptions(String type, Connection conn) throws SQLException {
        	//log.debug("in getValuesAsSelectOptions");

		ValidTerm[] thisArray = getFromValidTerm(type, conn);
        	LinkedHashMap<String, String> optionHash = new LinkedHashMap<String, String>();

        	for (int i=0; i<thisArray.length; i++) {
                	optionHash.put(Integer.toString(thisArray[i].getTerm_id()), thisArray[i].getValue());
        	}
        	return optionHash;
	}

	/**
   	* Gets the default publication status
   	* @param conn        the database connection
   	* @throws            SQLException if a database error occurs
   	* @return            the id of the publication status record for 'not yet submitted'
   	*/
	public int getDefaultPublicationStatus(Connection conn) throws SQLException {
        	//log.debug("in getDefaultPublicationStatus");

		ValidTerm[] thisArray = getFromValidTerm("PUBLICATION_STATUS", conn);
		for (int i=0; i<thisArray.length; i++) {
        		//log.debug("value = " + thisArray[i].getValue());
        		if (thisArray[i].getValue().equals("not yet submitted")) {
        			return thisArray[i].getTerm_id();
			}
		}
		return -99;
	}

	/**
	 * Gets all the ValidTerm
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of ValidTerm objects
	 */
	public ValidTerm[] getAllValidTerm(Connection conn) throws SQLException {

		log.debug("In getAllValidTerm");

		String query = 
			"select "+
			"term_id, display_order, category, value, description, "+
			"interp "+
			"from valid_terms "+ 
			"order by term_id";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, conn);

		ValidTerm[] myValidTerm = setupValidTermValues(myResults);

		myResults.close();

		return myValidTerm;
	}

	/**
	 * Gets the ValidTerm object for this value and category
	 * @param value	 the value of the ValidTerm
	 * @param category	 the id of the ValidTerm
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a ValidTerm object
	 */
	public ValidTerm getValidTermByValueAndID(String value, String category, Connection conn) throws SQLException {

		//log.debug("In getValidTermByValueAndID");

		String query = 
			"select "+
			"term_id, display_order, category, value, description, "+
			"interp "+
			"from valid_terms "+ 
			"where value = ? "+
			"and category = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, new Object[] {value, category}, conn);

		ValidTerm myValidTerm = setupValidTermValues(myResults)[0];

		myResults.close();

		return myValidTerm;
	}

	/**
	 * Gets the ValidTerm object for this term_id
	 * @param term_id	 the identifier of the ValidTerm
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a ValidTerm object
	 */
	public ValidTerm getValidTerm(int term_id, Connection conn) throws SQLException {

		log.debug("In getOne ValidTerm");

		String query = 
			"select "+
			"term_id, display_order, category, value, description, "+
			"interp "+
			"from valid_terms "+ 
			"where term_id = ? ";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, term_id, conn);

		ValidTerm myValidTerm = setupValidTermValues(myResults)[0];

		myResults.close();

		return myValidTerm;
	}

	/**
	 * Creates a record in the valid_terms table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createValidTerm(Connection conn) throws SQLException {

		log.debug("in create ValidTerm");

		int term_id = myDbUtils.getUniqueID("valid_terms_seq", conn);

		String query = 
			"insert into valid_terms "+
			"(term_id, display_order, category, value, description, "+
			"interp) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?)";

		//log.debug("query =  " + query);


		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, term_id);
		pstmt.setInt(2, display_order);
		pstmt.setString(3, category);
		pstmt.setString(4, value);
		pstmt.setString(5, description);
		pstmt.setString(6, interp);

		pstmt.executeUpdate();
		pstmt.close();

		this.setTerm_id(term_id);

		return term_id;
	}

	/**
	 * Updates a record in the valid_terms table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 
			"update valid_terms "+
			"set term_id = ?, display_order = ?, category = ?, value = ?, description = ?, "+
			"interp = ? "+
			"where term_id = ?";


		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, term_id);
		pstmt.setInt(2, display_order);
		pstmt.setString(3, category);
		pstmt.setString(4, value);
		pstmt.setString(5, description);
		pstmt.setString(6, interp);
		pstmt.setInt(7, term_id);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the valid_terms table and also deletes child records in related tables.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */

	public void deleteValidTerm(Connection conn) throws SQLException {

		log.info("in deleteValidTerm");

		conn.setAutoCommit(false);

		PreparedStatement pstmt = null;
		try {
			String query = 
				"delete from valid_terms " + 
				"where term_id = ?";

			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

			pstmt.setInt(1, term_id);
			pstmt.executeQuery();
			pstmt.close();

			conn.commit();
		} catch (SQLException e) {
			log.debug("error in deleteValidTerm");
			conn.rollback();
			pstmt.close();
			throw e;
		}
		conn.setAutoCommit(true);
	}

	/**
	 * Checks to see if a ValidTerm with the same  combination already exists.
	 * @param myValidTerm	the ValidTerm object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the term_id of a ValidTerm that currently exists
	 */
	public int checkRecordExists(ValidTerm myValidTerm, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select term_id "+
			"from valid_terms "+
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
	 * Creates an array of ValidTerm objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of ValidTerm
	 * @return	An array of ValidTerm objects with their values setup 
	 */
	private ValidTerm[] setupValidTermValues(Results myResults) {

		//log.debug("in setupValidTermValues");

		List<ValidTerm> validTermsList = new ArrayList<ValidTerm>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			ValidTerm thisValidTerm = new ValidTerm();

			thisValidTerm.setTerm_id(Integer.parseInt(dataRow[0]));
			thisValidTerm.setDisplay_order(Integer.parseInt(dataRow[1]));
			thisValidTerm.setCategory(dataRow[2]);
			thisValidTerm.setValue(dataRow[3]);
			thisValidTerm.setDescription(dataRow[4]);
			thisValidTerm.setInterp(dataRow[5]);

			validTermsList.add(thisValidTerm);
		}

		ValidTerm[] validTermArray = (ValidTerm[]) validTermsList.toArray(new ValidTerm[validTermsList.size()]);

		return validTermArray;
	}

	/**
	 * Compares ValidTerm based on different fields.
	 */
	public class ValidTermSortComparator implements Comparator<ValidTerm> {
		int compare;
		ValidTerm validTerm1, validTerm2;

		public int compare(ValidTerm object1, ValidTerm object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				validTerm1 = object1;
				validTerm2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				validTerm2 = object1;
				validTerm1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("validTerm1 = " +validTerm1+ "validTerm2 = " +validTerm2);

			if (sortColumn.equals("term_id")) {
				compare = new Integer(validTerm1.getTerm_id()).compareTo(new Integer(validTerm2.getTerm_id()));
			} else if (sortColumn.equals("display_order")) {
				compare = new Integer(validTerm1.getDisplay_order()).compareTo(new Integer(validTerm2.getDisplay_order()));
			} else if (sortColumn.equals("category")) {
				compare = validTerm1.getCategory().compareTo(validTerm2.getCategory());
			} else if (sortColumn.equals("value")) {
				compare = validTerm1.getValue().compareTo(validTerm2.getValue());
			} else if (sortColumn.equals("description")) {
				compare = validTerm1.getDescription().compareTo(validTerm2.getDescription());
			} else if (sortColumn.equals("interp")) {
				compare = validTerm1.getInterp().compareTo(validTerm2.getInterp());
			}
			return compare;
		}
	}

	public ValidTerm[] sortValidTerm (ValidTerm[] myValidTerm, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myValidTerm, new ValidTermSortComparator());
		return myValidTerm;
	}


	/**
	 * Converts ValidTerm object to a String.
	 */
	public String toString() {
		return "This ValidTerm has term_id = " + term_id;
	}

	/**
	 * Prints ValidTerm object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of ValidTerm objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof ValidTerm)) return false;
		return (this.term_id == ((ValidTerm)obj).term_id);

	}
}
