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
 * Class for handling data related to Texprtyp
 *  @author  Cheryl Hornbaker
 */

public class Texprtyp {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();

	public Texprtyp() {
		log = Logger.getRootLogger();
	}

	public Texprtyp(int texprtyp_exprid, int texprtyp_id) {
		log = Logger.getRootLogger();
		this.setTexprtyp_exprid(texprtyp_exprid);
		this.setTexprtyp_id(texprtyp_id);
	}

	public Texprtyp(int texprtyp_exprid, int texprtyp_id, String texprtyp_del_status) {
		log = Logger.getRootLogger();
		this.setTexprtyp_exprid(texprtyp_exprid);
		this.setTexprtyp_id(texprtyp_id);
		this.setTexprtyp_del_status(texprtyp_del_status);
	}

	private int texprtyp_exprid;
	private int texprtyp_id;
	private String texprtyp_del_status = "U";
	private String texprtyp_user;
	private java.sql.Timestamp texprtyp_last_change;
	private String sortColumn ="";
	private String sortOrder ="A";
	private String typeName;

	public void setTexprtyp_exprid(int inInt) {
		this.texprtyp_exprid = inInt;
	}

	public int getTexprtyp_exprid() {
		return this.texprtyp_exprid;
	}

	public void setTexprtyp_id(int inInt) {
		this.texprtyp_id = inInt;
	}

	public int getTexprtyp_id() {
		return this.texprtyp_id;
	}

	public void setTexprtyp_del_status(String inString) {
		this.texprtyp_del_status = inString;
	}

	public String getTexprtyp_del_status() {
		return this.texprtyp_del_status;
	}

	public void setTexprtyp_user(String inString) {
		this.texprtyp_user = inString;
	}

	public String getTexprtyp_user() {
		return this.texprtyp_user;
	}

	public void setTexprtyp_last_change(java.sql.Timestamp inTimestamp) {
		this.texprtyp_last_change = inTimestamp;
	}

	public java.sql.Timestamp getTexprtyp_last_change() {
		return this.texprtyp_last_change;
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

	public void setTypeName(String inString) {
		this.typeName = inString;
	}

	public String getTypeName() {
		return this.typeName;
	}

	/** 
	 * Gets the experiment type names as a Set
	 * @param myTypes	an array of Texprtyp objects
	 * @return	a Set of the texprtyp names
	 */
/*
	public Set<String> getAsSet(Texprtyp[] myTypes) {
		log.debug("in Texprtyp getAsSet");

		Set<String> values = new TreeSet<String>();
		for (int i=0; i<myTypes.length; i++) {
			values.add(myTypes[i].getTypeName());
		}
		return values; 
	}

*/

	/**
	 * Gets all the Texprtyp for an experimet
	 * @param expID 	the id of the experiment
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Texprtyp objects
	 */
	public Texprtyp[] getAllTexprtypForExp(int expID, Connection conn) throws SQLException {

		log.debug("In getAllTexprtypForExp");

		String query = 
			"select "+
			"texprtyp_exprid, texprtyp_id, texprtyp_del_status, texprtyp_user, to_char(texprtyp_last_change, 'dd-MON-yyyy hh24:mi:ss'), "+
			"vt.value "+
			"from Texprtyp, valid_terms vt "+ 
			"where texprtyp_exprid = ? "+
			"and texprtyp_id = vt.term_id "+
			"and texprtyp_del_status = 'U' "+
			"and vt.value != 'other' "+
			"union "+
			"select  "+
			"texprtyp_exprid, texprtyp_id, texprtyp_del_status, texprtyp_user, to_char(texprtyp_last_change, 'dd-MON-yyyy hh24:mi:ss'),  "+
			"tothers_value "+
			"from Texprtyp, valid_terms vt, Tothers "+
			"where texprtyp_exprid = ?  "+
			"and tothers_exprid = texprtyp_exprid "+
			"and tothers_id = 'EXPERIMENT_TYPE' "+
			"and texprtyp_id = vt.term_id "+
			"and texprtyp_del_status = 'U'  "+
			"and tothers_del_status = 'U' "+
			"and vt.value = 'other' "+
			"and tothers_value is not null "+
			"order by texprtyp_exprid, texprtyp_id, texprtyp_del_status";

		log.debug("query =  " + query);

		Results myResults = new Results(query, new Object[] {expID, expID}, conn);

		Texprtyp[] myTexprtyp = setupTexprtypValues(myResults);

		myResults.close();

		return myTexprtyp;
	}

	/**
	 * Gets the Texprtyp object for this texprtyp_exprid
	 * @param texprtyp_exprid	 the identifier of the Texprtyp
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Texprtyp object
	 */
	public Texprtyp getTexprtyp(int texprtyp_exprid, Connection conn) throws SQLException {

		log.debug("In getOne Texprtyp");

		String query = 
			"select "+
			"texprtyp_exprid, texprtyp_id, texprtyp_del_status, texprtyp_user, to_char(texprtyp_last_change, 'dd-MON-yyyy hh24:mi:ss'), "+
			"vt.value "+
			"from Texprtyp, valid_terms vt "+ 
			"where texprtyp_exprid = ? "+
			"and texprtyp_del_status = 'U' "+
			"and texprtyp_id = vt.term_id";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, texprtyp_exprid, conn);

		Texprtyp myTexprtyp = setupTexprtypValues(myResults)[0];

		myResults.close();

		return myTexprtyp;
	}

	/**
	 * Creates a record in the Texprtyp table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void  createTexprtyp(Connection conn) throws SQLException {

		log.debug("In create Texprtyp");

		String query = 
			"insert into Texprtyp "+
			"(texprtyp_exprid, texprtyp_id, texprtyp_del_status, texprtyp_user, texprtyp_last_change) "+
			"values "+
			"(?, ?, ?, ?, ?)";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, texprtyp_exprid);
		pstmt.setInt(2, texprtyp_id);
		pstmt.setString(3, "U");
		pstmt.setString(4, texprtyp_user);
		pstmt.setTimestamp(5, now);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Updates a record in the Texprtyp table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 

			"update Texprtyp "+
			"set texprtyp_exprid = ?, texprtyp_id = ?, texprtyp_del_status = ?, texprtyp_user = ?, texprtyp_last_change = ? "+
			"where texprtyp_exprid = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, texprtyp_exprid);
		pstmt.setInt(2, texprtyp_id);
		pstmt.setString(3, texprtyp_del_status);
		pstmt.setString(4, texprtyp_user);
		pstmt.setTimestamp(5, now);
		pstmt.setInt(6, texprtyp_exprid);

		pstmt.executeUpdate();
		pstmt.close();

	}

        /**
         * Deletes the record in the Texprtyp table and also deletes child records in related tables.
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteTexprtyp(Connection conn) throws SQLException {

                log.info("in deleteTexprtyp");

                //conn.setAutoCommit(false);

                PreparedStatement pstmt = null;
                try {
                        String query =
                                "delete from Texprtyp " +
                                "where texprtyp_exprid = ? "+
                                "and texprtyp_id = ?";

                        pstmt = conn.prepareStatement(query,
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                        pstmt.setInt(1, texprtyp_exprid);
                        pstmt.setInt(2, texprtyp_id);
                        pstmt.executeQuery();
                        pstmt.close();

                        //conn.commit();
                } catch (SQLException e) {
                        log.debug("error in deleteTexprtyp");
                        //conn.rollback();
                        pstmt.close();
                        throw e;
                }
                //conn.setAutoCommit(true);
        }

        /**
         * Deletes the records in the Texprtyp table that are children of Experiment.
         * @param exp_id       identifier of the Experiment table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTexprtypForExperiment(int exp_id, Connection conn) throws SQLException {

                log.info("in deleteAllTexprtypForExperiment");

                //Make sure committing is handled in calling method!

                String query =
                        "select texprtyp_exprid, texprtyp_id "+
                        "from Texprtyp "+
                        "where texprtyp_exprid = ?";

                Results myResults = new Results(query, exp_id, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Texprtyp(Integer.parseInt(dataRow[0]), Integer.parseInt(dataRow[1])).deleteTexprtyp(conn);
                }

                myResults.close();

        }

	/**
	 * Checks to see if a Texprtyp with the same  combination already exists.
	 * @param myTexprtyp	the Texprtyp object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the texprtyp_exprid of a Texprtyp that currently exists
	 */
	public int checkRecordExists(Texprtyp myTexprtyp, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select texprtyp_exprid "+
			"from Texprtyp "+
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
	 * Creates an array of Texprtyp objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Texprtyp
	 * @return	An array of Texprtyp objects with their values setup 
	 */
	private Texprtyp[] setupTexprtypValues(Results myResults) {

		//log.debug("in setupTexprtypValues");

		List<Texprtyp> TexprtypList = new ArrayList<Texprtyp>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Texprtyp thisTexprtyp = new Texprtyp();

			thisTexprtyp.setTexprtyp_exprid(Integer.parseInt(dataRow[0]));
			thisTexprtyp.setTexprtyp_id(Integer.parseInt(dataRow[1]));
			thisTexprtyp.setTexprtyp_del_status(dataRow[2]);
			thisTexprtyp.setTexprtyp_user(dataRow[3]);
			thisTexprtyp.setTexprtyp_last_change(new ObjectHandler().getOracleDateAsTimestamp(dataRow[4]));
			thisTexprtyp.setTypeName(dataRow[5]);

			TexprtypList.add(thisTexprtyp);
		}

		Texprtyp[] TexprtypArray = (Texprtyp[]) TexprtypList.toArray(new Texprtyp[TexprtypList.size()]);

		return TexprtypArray;
	}

	/**
	 * Compares Texprtyp based on different fields.
	 */
	public class TexprtypSortComparator implements Comparator<Texprtyp> {
		int compare;
		Texprtyp texprtyp1, texprtyp2;

		public int compare(Texprtyp object1, Texprtyp object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				texprtyp1 = object1;
				texprtyp2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				texprtyp2 = object1;
				texprtyp1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("texprtyp1 = " +texprtyp1+ "texprtyp2 = " +texprtyp2);

			if (sortColumn.equals("texprtyp_exprid")) {
				compare = new Integer(texprtyp1.getTexprtyp_exprid()).compareTo(new Integer(texprtyp2.getTexprtyp_exprid()));
			} else if (sortColumn.equals("texprtyp_id")) {
				compare = new Integer(texprtyp1.getTexprtyp_id()).compareTo(new Integer(texprtyp2.getTexprtyp_id()));
			} else if (sortColumn.equals("texprtyp_del_status")) {
				compare = texprtyp1.getTexprtyp_del_status().compareTo(texprtyp2.getTexprtyp_del_status());
			} else if (sortColumn.equals("texprtyp_user")) {
				compare = texprtyp1.getTexprtyp_user().compareTo(texprtyp2.getTexprtyp_user());
			} else if (sortColumn.equals("texprtyp_last_change")) {
				compare = texprtyp1.getTexprtyp_last_change().compareTo(texprtyp2.getTexprtyp_last_change());
			}
			return compare;
		}
	}

	public Texprtyp[] sortTexprtyp (Texprtyp[] myTexprtyp, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myTexprtyp, new TexprtypSortComparator());
		return myTexprtyp;
	}


	/**
	 * Converts Texprtyp object to a String.
	 */
	public String toString() {
		return "This Texprtyp has texprtyp_exprid = " + texprtyp_exprid + " and name = "+typeName;
	}

	/**
	 * Prints Texprtyp object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Texprtyp objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Texprtyp)) return false;
		return (this.texprtyp_exprid == ((Texprtyp)obj).texprtyp_exprid);

	}
}
