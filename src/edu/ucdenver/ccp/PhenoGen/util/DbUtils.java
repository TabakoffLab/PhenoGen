package edu.ucdenver.ccp.PhenoGen.util;

import java.sql.*;
import edu.ucdenver.ccp.util.sql.Results;

/* for logging messages */
import org.apache.log4j.Logger;       

/**
 * Class for manipulating data retrieved from the database. 
 *  @author  Cheryl Hornbaker
 */

public class DbUtils{

  private Logger log=null;

  public DbUtils () {
	log = Logger.getRootLogger();
  }

  /**
   * Sets the value to the empty character string '' if the column value is null (i.e., there is no value)
   * @param myString	the column value
   * @return            the column value or ''
   */
  public String setToEmptyIfNull(String myString) {
	
	if (myString == null) {
		return "";
	} else {
		return myString;
	}
  }

  /**
   * Sets the value to the character string 'None' if the column value is null (i.e., there is no value)
   * @param myString	the column value
   * @return            the column value or 'None'
   */
  public String setToNoneIfNull(String myString) {
	
	if (myString == null) {
		return "None";
	} else {
		return myString;
	}
  }

  public void setToNullIfZero(PreparedStatement pstmt, int parameterIndex, int dbColumn) throws SQLException {
	//
	// set the column to NULL if the column value is 0 (this prevents foreign
	// key reference problems)
	//
	//log.debug("in setToNullIfZero. dbColumn = "+dbColumn);
        try {
        	if (dbColumn == 0 || dbColumn == -99) {
			//log.debug("setting it to null");
        		pstmt.setNull(parameterIndex, java.sql.Types.INTEGER);
	        } else {
			//log.debug("setting it to the value");
		        pstmt.setInt(parameterIndex, dbColumn); 
		}
        } catch (SQLException e) {
		log.error("in exception of setToNullIfZero", e);
		throw e;
        }
  }

  public void setDoubleToNullIfZero(PreparedStatement pstmt, int parameterIndex, double dbColumn) throws SQLException {
	//
	// set the column to NULL if the column value is 0 (this prevents foreign
	// key reference problems)
	//
	
        try {
        	if (dbColumn == 0 || dbColumn == -99) {
        		pstmt.setNull(parameterIndex, java.sql.Types.DOUBLE);
	        } else {
		        pstmt.setDouble(parameterIndex, dbColumn); 
		}
        } catch (SQLException e) {
		log.error("in exception of setDoubleToNullIfZero", e);
		throw e;
        }
  }

	//
	// gets the next value from the sequence passed in 
	//
	public int getUniqueID(String sequence, Connection conn) throws SQLException {
	
		//log.debug("in getUniqueID");
        	String query =
                	"select "+
			sequence + 
			".nextval "+
                	"from dual";

                	Results myResults = new Results(query, conn);

                	int uniqueID = myResults.getIntValueFromFirstRow();

                	myResults.close();

			uniqueID = (uniqueID == -99 ? 0 : uniqueID);

 		return uniqueID;
	}

  public String getRownumClause (String typeOfQuery) {
        String rownumClause = "";

        if (typeOfQuery.equals("SELECT10")) {
                rownumClause = " and rownum < 10 ";
        } 
	return rownumClause;
  }

  public String getSelectClause (String typeOfQuery) {
        String selectClause = "";

	if (typeOfQuery.equals("SELECT")) {
                selectClause = "select * ";
        } else if (typeOfQuery.equals("SELECT10")) {
                selectClause = "select * ";
        } else if (typeOfQuery.equals("DELETE")) {
                selectClause = "delete ";
        } else if (typeOfQuery.equals("COUNT")) {
                selectClause = "select count(*) ";
        }
	return selectClause;
  }

  public String[] getDBVersion(Connection conn) throws SQLException {
  	
  	String query = 
  		"select version_number, last_updated_date " +
		"from db_version";
  	
  	log.debug("In DbUtils.getDBVersion");
  	
	String[] values = new String[2];

	String[] dataRow;
        Results myResults = new Results(query, conn);
        while ((dataRow = myResults.getNextRow()) != null) {
                 values[0] = dataRow[0];
                 values[1] = dataRow[1];
        }
        myResults.close();

  	return values;
  }
  
}

