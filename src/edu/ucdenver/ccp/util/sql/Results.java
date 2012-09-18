package edu.ucdenver.ccp.util.sql;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Clob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.ObjectHandler;

/* for logging messages */
import org.apache.log4j.Logger;


/**
 * Class for handling result sets from database queries.
 *  @author  Cheryl Hornbaker
 */

public class Results{
	private ResultSet rs;
	private ResultSetMetaData rsmd; 
	private PreparedStatement pstmt;
	public int timeout = 0;
	public String query;
	public Connection conn;

	private Logger log=null;

        public void setTimeout(int inInt) {
                this.timeout = inInt;
        }

        public int getTimeout() {
                return timeout;
        }

        public void setQuery(String inString) {
                this.query = inString;
        }

        public String getQuery() {
                return query;
        }

        public void setConnection(Connection inConnection) {
                this.conn = inConnection;
        }

        public Connection getConnection() {
                return conn;
        }

	public Results() throws SQLException {
		log = Logger.getRootLogger();
	}

	/**
	 * Constructs a Results object for the PreparedStatement.
	 * @throws            SQLException if a database error occurs
	 */
	public Results(PreparedStatement pstmt) throws SQLException {
		log = Logger.getRootLogger();
		log.debug("pstmt is open here 1. Think about fixing");
		rs = pstmt.executeQuery();
		rsmd = rs.getMetaData();
  	}

	/**
	 * Constructs a Results object for the query and database connection.  
	 * NOTE: close() must be called to close the PreparedStatement when this contructor is used.
	 * @throws            SQLException if a database error occurs
	 */
	public Results(String query, Connection conn) throws SQLException {
		log = Logger.getRootLogger();
	
		//log.debug("pstmt is open here 2.  No problem ");
                pstmt = conn.prepareStatement(query,
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);
		rs = pstmt.executeQuery();
		rsmd = rs.getMetaData();
  	}

	/**
	 * Constructs a Results object for the query and database connection.  
	 * Creates a PreparedStatement with the given variables bound to the query variable.
	 * NOTE: close() must be called to close the PreparedStatement when this contructor is used.
	 * @throws            SQLException if a database error occurs
	 */
	public Results(String query, Object[] queryVariables, Connection conn) throws SQLException {
		log = Logger.getRootLogger();

		//log.debug("pstmt is open here 2.5. This is good");
		//log.debug("in Results passing in queryVariables");
	
                pstmt = conn.prepareStatement(query,
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		int ctr = 1;
        	for (int i=0; i<queryVariables.length; i++) {
			Object thisVar = queryVariables[i];
			String className = thisVar.getClass().getName();
			//log.debug("object value = "+((String)thisVar).toString());
			//log.debug("object class = "+className);
			if (className.equals("java.lang.String")) {
				pstmt.setString(ctr, (String) thisVar);
			} else if (className.equals("java.lang.Double")) {
				pstmt.setDouble(ctr, (Double) thisVar);
			} else if (className.equals("java.lang.Integer")) {
				pstmt.setInt(ctr, (Integer) thisVar);
			}
			ctr++;
        	}

		rs = pstmt.executeQuery();
		rsmd = rs.getMetaData();
  	}

	/**
	 * Constructs a Results object for the query and database connection.  
	 * Creates a PreparedStatement with the given variables bound to the query variable.
	 * NOTE: close() must be called to close the PreparedStatement when this contructor is used.
	 * @throws            SQLException if a database error occurs
	 */
	public Results(String query, List<Object>queryVariables, Connection conn) throws SQLException {
		log = Logger.getRootLogger();

		log.debug("pstmt is open here 3. Should be fixed. query = " +query);
		//log.debug("in Results passing in queryVariables");
	
                pstmt = conn.prepareStatement(query,
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		int ctr = 1;
        	for (Iterator itr = queryVariables.iterator(); itr.hasNext();) {
			Object thisVar = (Object) itr.next();
			String className = thisVar.getClass().getName();
			//log.debug("object value = "+((String)thisVar).toString());
			//log.debug("object class = "+className);
			if (className.equals("java.lang.String")) {
				pstmt.setString(ctr, (String) thisVar);
			} else if (className.equals("java.lang.Integer")) {
				pstmt.setInt(ctr, (Integer) thisVar);
			}
			ctr++;
        	}

		rs = pstmt.executeQuery();
		rsmd = rs.getMetaData();
  	}

	/**
	 * Constructs a Results object for the query and database connection.  
	 * Creates a PreparedStatement with the given integer bound to the query variable.
	 * NOTE: close() must be called to close the PreparedStatement when this contructor is used.
	 * @throws            SQLException if a database error occurs
	 */
	public Results(String query, int inInt, Connection conn) throws SQLException {
		log = Logger.getRootLogger();
		//log.debug("pstmt is open here 4. Not a problem");
	
                pstmt = conn.prepareStatement(query,
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, inInt);

		rs = pstmt.executeQuery();
		rsmd = rs.getMetaData();
  	}

	/**
	 * Constructs a Results object for the query and database connection.  
	 * Creates a PreparedStatement with the given String bound to the query variable.
	 * NOTE: close() must be called to close the PreparedStatement when this contructor is used.
	 * @throws            SQLException if a database error occurs
	 */
	public Results(String query, String inString, Connection conn) throws SQLException {
		log = Logger.getRootLogger();
	
		//log.debug("pstmt is open here 5. Not a problem ");
		//log.debug("in Results passing in query and String");
                pstmt = conn.prepareStatement(query,
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);
		pstmt.setString(1, inString);

		rs = pstmt.executeQuery();
		rsmd = rs.getMetaData();
  	}

	/**
	 * Constructs a Results object for the query and database connection.  
	 * Creates a PreparedStatement with the given Strings bound to the query variable.
	 * NOTE: close() must be called to close the PreparedStatement when this contructor is used.
	 * @throws            SQLException if a database error occurs
	 */
	public Results(String query, String inString, String inString2, Connection conn) throws SQLException {
		log = Logger.getRootLogger();
	
		log.debug("pstmt is open here 6. Should be fixed. query = " + query);
                pstmt = conn.prepareStatement(query,
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);
		pstmt.setString(1, inString);
		pstmt.setString(2, inString2);

		rs = pstmt.executeQuery();
		rsmd = rs.getMetaData();
  	}

	/**
	 * Constructs a Results object for the query and database connection.  
	 * Creates a PreparedStatement with the given int bound to the first query variable and the 
	 * given int bound to the second query variable.
	 * NOTE: close() must be called to close the PreparedStatement when this contructor is used.
	 * @throws            SQLException if a database error occurs
	 */
	public Results(String query, int inInt, int inInt2, Connection conn) throws SQLException {
		log = Logger.getRootLogger();
		log.debug("pstmt is open here 7. Should be fixed. query = " + query);
	
                pstmt = conn.prepareStatement(query,
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, inInt);
		pstmt.setInt(2, inInt2);

		rs = pstmt.executeQuery();
		rsmd = rs.getMetaData();
  	}

	/**
	 * Constructs a Results object for the query and database connection.  
	 * Creates a PreparedStatement with the first given int bound to the first query variable 
	 * and the second given int bound to the second query variable and the third bound to the third query variable.
	 * NOTE: close() must be called to close the PreparedStatement when this contructor is used.
	 * @throws            SQLException if a database error occurs
	 */
	public Results(String query, int inInt, int inInt2, int inInt3, Connection conn) throws SQLException {
		log = Logger.getRootLogger();
		log.debug("pstmt is open here 8. Should be fixed. query = " + query);
	
                pstmt = conn.prepareStatement(query,
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, inInt);
		pstmt.setInt(2, inInt2);
		pstmt.setInt(3, inInt3);

		rs = pstmt.executeQuery();
		rsmd = rs.getMetaData();
  	}

	/**
	 * Constructs a Results object for the query and database connection.  
	 * Creates a PreparedStatement with the given String bound to the first query variable 
	 * and the given int bound to the second query variable.
	 * NOTE: close() must be called to close the PreparedStatement when this contructor is used.
	 * @throws            SQLException if a database error occurs
	 */
	public Results(String query, String inString, int inInt, Connection conn) throws SQLException {
		log = Logger.getRootLogger();
	
		log.debug("pstmt is open here 9. Should be fixed. query = "+ query);
                pstmt = conn.prepareStatement(query,
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);
		pstmt.setString(1, inString);
		pstmt.setInt(2, inInt);

		rs = pstmt.executeQuery();
		rsmd = rs.getMetaData();
  	}

	/**
	 * Executes a query on a connection previously defined.
	 * NOTE: close() must be called to close the PreparedStatement when this contructor is used.
	 * @throws            SQLException if a database error occurs
	 */
	public void execute() throws SQLException {

                pstmt = this.conn.prepareStatement(this.query,
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		if (timeout != 0) {
			log.debug("executing the statement, setting the query timeout");
			pstmt.setQueryTimeout(timeout);
		}
		rs = pstmt.executeQuery();
		rsmd = rs.getMetaData();
  	}

	/**
	 * Returns the String value from the first row 
         * @return	the String from the first row
	 * @throws            SQLException if a database error occurs
	 */
	public String getStringValueFromFirstRow() throws SQLException {
		if (rs.next()) { 
			return rs.getString(1);
		} else {
			return "";
		}
  	}

	/**
	 * Returns the integer value from the first row 
         * @return	the integer from the first row
	 * @throws            SQLException if a database error occurs
	 */
	public int getIntValueFromFirstRow() throws SQLException {
		if (rs.next()) { 
			return rs.getInt(1);
		} else {
			return -99;
		}
  	}

	/**
	 * Close the PreparedStatement used by this Results object.
	 */
	public void close() throws SQLException {
		if (pstmt != null) {
			//log.debug("in Results.close().  closing pstmt");
			pstmt.close();
		}
	}

	public ResultSet getResultSet () {
		return rs;
	}

	public ResultSetMetaData getResultSetMetaData () {
		return rsmd;
	}

	public void goToFirstRow() {
		try {
			if (rs != null) {	
				rs.beforeFirst();
			}
		} catch (SQLException e) {
			log.error("In exception of firstRow", e);
    		}
	}

	public int getNumRows () {
  		int numRows = 0;
 		   try {
			if (rs != null) {
				//
				// Set the pointer to the last row in the result 
				// set in order to count the number of rows returned.
				//
				boolean isResultSetNotNull = rs.last();
				
				if (isResultSetNotNull) {
					numRows = rs.getRow(); 
				}
				//
				// Set the pointer back to just before the first 
				// row so that all subsequent calls will start at 
				// the first row
				//
				goToFirstRow();
			}
    		} catch (SQLException e) {
			log.error("In exception of getNumRows", e);
    		}

		return numRows;
  	}

	public int getNumCols() { 
		int numCols = 0;

		try {
			numCols = rsmd.getColumnCount();

		} catch (SQLException e) {
			log.error("In exception of getNumCols", e);
		}
		return numCols;
  	}

	public String[] getColumnHeaders() {  

		String[] columnHeader = null; 
		
		try {
			int size = getNumCols(); 
			columnHeader = new String[size];
	
		       	for (int i = 0; i<size; i++) {
    				columnHeader[i] = rsmd.getColumnLabel(i+1);
			}
		} catch (SQLException e) {
			log.error("In exception of getColumnHeaders", e);
		}
		return columnHeader;
  	}

	public Object[] getNextRowWithClobInBatches(int rowNum, int batchSize, int batchNum) {  
		int size;
		boolean rowsLeft;
		Object[] resultRow = null; 
			
		try {
			size = getNumCols();
			resultRow = new Object[size];
			int rowNumber = (batchSize * batchNum) + rowNum;
			rowsLeft = rs.absolute(rowNumber);
			if (rowsLeft) {
				for (int i = 0; i<size; i++) {
					if (rs.getObject(i+1) != null && 
						(rs.getObject(i+1).getClass().getName()).equals("oracle.sql.CLOB")) {
						resultRow[i] = rs.getClob(i+1);
					} else {
						resultRow[i] = rs.getString(i+1);
					}
				}
			} else {
				resultRow = null;
			}
		} catch (SQLException e) {
			log.error("In exception of getNextRowWithClobInBatches", e);
		}
		return resultRow;
  	}

	/**
	 * Returns the integer value from the first row 
	 * @param clob	instance of an object array returned from getNextRowWithClob
	 * @return	the object as a String
	 */
	public String getClobAsString(Object clob) {

                BufferedReader clobReader = null;
		String clobAsString = "";
                String newClobAsString = "";

        	if (((Clob) clob) != null) {
                        try {
                		clobReader = new BufferedReader(((Clob) clob).getCharacterStream());
                        	while((clobAsString = clobReader.readLine()) != null) {
                                	newClobAsString = newClobAsString + clobAsString;
				}
                        } catch (IOException e) {
                                log.debug("IOException reading clob", e);
                        } catch (SQLException e) {
                                log.debug("SQLException reading clob", e);
                        }
		}
		return newClobAsString;
  	}

	/**
	 * Returns the integer value from the first row 
	 * @throws            SQLException if a database error occurs
	 */
	public Object[] getNextRowWithClob() {  
		int size;
		boolean rowsLeft;
		Object[] resultRow = null; 
			
		try {
			size = getNumCols();
			resultRow = new Object[size];
			rowsLeft = rs.next();
			if (rowsLeft) {
				for (int i = 0; i<size; i++) {
					if (rs.getObject(i+1) != null && 
						(rs.getObject(i+1).getClass().getName()).equals("oracle.sql.CLOB")) {
						resultRow[i] = rs.getClob(i+1);
					} else {
						resultRow[i] = rs.getString(i+1);
					}
				}
			} else {
				resultRow = null;
			}
		} catch (SQLException e) {
			log.error("In exception of getNextRowWithClob", e);
		}
		return resultRow;
  	}

	public String[] getNextRowInBatches(int rowNum, int batchSize, int batchNum) {  
		int size;
		boolean rowsLeft;
		String[] resultRow = null; 
			
		try {
			size = getNumCols();
			resultRow = new String[size];
			int rowNumber = (batchSize * batchNum) + rowNum;
			rowsLeft = rs.absolute(rowNumber);
			if (rowsLeft) {
				for (int i = 0; i<size; i++) {
					resultRow[i] = rs.getString(i+1);
				}
			} else {
				resultRow = null;
			}
		} catch (SQLException e) {
			log.error("In exception of getNextRowInBatches", e);
		}
		return resultRow;
  	}

	public String[] getPreviousRow() {  
		int size;
		boolean rowsLeft;
		String[] resultRow = null; 
			
		try {
			size = getNumCols();
			resultRow = new String[size];
			rowsLeft = rs.previous();
			if (rowsLeft) {
				for (int i = 0; i<size; i++) {
					resultRow[i] = rs.getString(i+1);
				}
			} else {
				resultRow = null;
			}
		} catch (SQLException e) {
			log.error("In exception of getPreviousRow", e);
		}
		return resultRow;
  	}

	public String[] getNextRow() {  
		int size;
		boolean rowsLeft;
		String[] resultRow = null; 
			
		try {
			size = getNumCols();
			resultRow = new String[size];
			rowsLeft = rs.next();
			if (rowsLeft) {
				for (int i = 0; i<size; i++) {
					resultRow[i] = rs.getString(i+1);
				}
			} else {
				resultRow = null;
			}
		} catch (SQLException e) {
			log.error("In exception of getNextRow", e);
			log.debug("resultRow = "); new Debugger().print(resultRow);
			log.error(e);
		}
		//log.debug("resultRow = "); new Debugger().print(resultRow);
		return resultRow;
  	}

	/**
 	 * Returns the results of multiple queries as a List of a List of String[].  
	 * The outer list contains all the queries, the inner List is all the rows from one query.
	 * @param query		an array of Strings containing database queries 
	 * @param inInt		the id of the record that should be passes to each of the queries.
	 * @param conn		the database connection
	 * @return		a List of a List of String arrays.
	 */

	public List<List<String[]>> getAllResults (String[] query, int inInt, Connection conn) throws SQLException {

        	PreparedStatement pstmt = null;
        	Results myResults = null;
        	List<List<String[]>> allResults = new ArrayList<List<String[]>>();

        	try {
                	for (int i=0; i<query.length; i++) {
                        	pstmt = conn.prepareStatement(query[i],
                            		ResultSet.TYPE_SCROLL_INSENSITIVE,
                            		ResultSet.CONCUR_UPDATABLE);

                        	pstmt.setInt(1, inInt);
                        	myResults = new Results(pstmt);
                        	if (myResults != null && myResults.getNumRows() > 0) {
					List<String[]> thisList = new ArrayList<String[]>();
					if (myResults.getNumRows() > 10) {
						String[] moreThanTen = new String[1];
						moreThanTen[0] = "there are more than 10 rows returned for this query:  " + 
								query[i];
						thisList.add(moreThanTen);
						allResults.add(thisList);
					} else {
						allResults.add(new ObjectHandler().getResultsAsListOfStringArrays(myResults));
                                		//thisList = new ObjectHandler().getResultsAsListOfStringArrays(myResults);
					}
                                	//log.debug("Results for this query are not null. length = " +thisList.size());
                                	//log.debug("thisList = "); new Debugger().print(thisList);
                                	//allResults.add(thisList);
                        	} else {
                                	log.debug("Results for this query are null");
                        	}
        			log.debug("closing pstmt");
                	}

        	} catch (SQLException e) {
                	log.error("In exception of getAllResults", e);
                	throw e;
        	} finally {
        		pstmt.close();
		}
		log.debug("Here allResults is "+allResults.size()+" rows long blah blah blah");
		return allResults;
	}

	/**
	 * Print the Results object
	 */
	public void print() {

		String [] dataRow;

		try {
                	while ((dataRow = this.getNextRow()) != null) {
				for (int i=0; i<dataRow.length; i++) {
        				log.debug(rsmd.getColumnLabel(i+1) + " = " + dataRow[i]);
				}
        			log.debug("");
			}
		} catch (Exception e) {
			log.debug("got Exception in Results.print()", e);
		}
	}
}

