package edu.ucdenver.ccp.util;

import java.io.PrintWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.Results;
import edu.ucdenver.ccp.util.sql.PropertiesConnection;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for creating java code based on database structure;
 *  @author  Cheryl Hornbaker
 */

public class CodeGenerator{
	private String table_name;
	private String table_name_plural;
	private String table_name_lower_case;
	private PrintWriter writer = null;
	String oneTab = "\t";
	String twoTabs = oneTab + "\t";
	String threeTabs = twoTabs + "\t";
	String fourTabs = threeTabs + "\t";
	String fiveTabs = fourTabs + "\t";

	private int user_id;

	private Logger log = null;

	private DbUtils myDbUtils = new DbUtils();
        private Debugger myDebugger = new Debugger();
        private ObjectHandler myObjectHandler = new ObjectHandler();
        private static Connection dbConn; 
        private static String baseDir = "/usr/share/tomcat/webapps/PhenoGen/";
        private static String propertiesFileName = baseDir + "web/common/dbProperties/stan_halDev.properties";

	public CodeGenerator () {
		log = Logger.getRootLogger();
	}

	public CodeGenerator (String table_name, String noPlural) {
		log = Logger.getRootLogger();
		this.setTable_name(table_name);
		this.setTable_name_lower_case(table_name.toLowerCase());
		this.setTable_name_plural(table_name);
	}

	public CodeGenerator (String table_name) {
		log = Logger.getRootLogger();
		this.setTable_name(table_name);
		this.setTable_name_lower_case(table_name.toLowerCase());
		this.setTable_name_plural(table_name + "s");
	}

	public String getTable_name() {
		return table_name; 
	}

	public void setTable_name(String inString) {
		this.table_name = inString;
	}

	public String getTable_name_plural() {
		return table_name_plural; 
	}

	public void setTable_name_plural(String inString) {
		this.table_name_plural = inString;
	}

	public String getTable_name_lower_case() {
		return table_name_lower_case; 
	}

	public void setTable_name_lower_case(String inString) {
		this.table_name_lower_case = inString;
	}

	public int getCodeGenerator_id() {
    		return user_id; 
  	}

  	public void setCodeGenerator_id(int inInt) {
    		this.user_id = inInt;
  	}

	/**
	 * Gets the primary and unique keys for this table
	 * @param type	either 'P' for 'Primary' or 'U' for 'Unique'
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a list of Column objects for the primary or unique keys of this table
	 */
	public List<Column> getKeys(String type, Connection conn) throws SQLException {
	
		log.debug("in getKeys. table_name = " + this.table_name);

        	String query =
			"select lower(cols.column_name), "+
			//"initcap(cols.column_name), "+
			// Had to do this replace so that letters right after an underscore are not initcap
			// Put the number 7 in there in case the column name has an x before or after the 
			// underscore
			"replace(initcap(replace(cols.column_name, '_', 'X7X')), 'x7x', '_'), "+
			"decode(utc.data_type, "+
        		"	'NUMBER', decode(utc.data_scale, 0, 'int', 'double'), "+
        		"	'VARCHAR2', 'String', "+
        		"	'DATE', 'java.sql.Timestamp', "+
        		"	'String') data_type, "+
			"initcap(decode(utc.data_type, "+
        		"	'NUMBER', decode(utc.data_scale, 0, 'int', 'double'), "+
        		"	'VARCHAR2', 'String', "+
        		"	'DATE', 'Timestamp', "+
        		"	'String')) data_type_initcap "+
			"from user_cons_columns cols, "+
			"user_constraints cons, "+
			"user_tab_columns utc "+
			"where utc.table_name = upper(?) "+
			"and cons.constraint_name = cols.constraint_name "+
			"and cons.constraint_type = ? "+
			"and utc.table_name = cons.table_name "+
			"and utc.column_name = cols.column_name "+
			"order by position";

		//log.debug("query = "+query);

		List<Column> columns = new ArrayList<Column>();

        	Results myResults = new Results(query, new Object[] {this.table_name_plural, type}, conn);
		String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        Column thisColumn = setupColumnValues(dataRow);
                        columns.add(thisColumn);
                }

        	myResults.close();

		return columns;
	}

	/**
	 * Gets the columns for this table
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a list of Column objects for this table
	 */
	public List<Column> getColumns(Connection conn) throws SQLException {
	
		log.debug("in getColumns. table_name = " + this.table_name + " and plural = " + this.table_name_plural);

        	String query =
                	"select lower(column_name), "+
                	//"initcap(column_name), "+
			// Had to do this replace so that letters right after an underscore are not initcap
			// Put the number 7 in there in case the column name has an x before or after the 
			// underscore
			"replace(initcap(replace(column_name, '_', 'X7X')), 'x7x', '_'), "+
			"decode(data_type, "+
        		"	'NUMBER', decode(data_scale, 0, 'int', 'double'), "+
        		"	'VARCHAR2', 'String', "+
        		"	'DATE', 'java.sql.Timestamp', "+
        		"	'String') data_type, "+
			"initcap(decode(data_type, "+
        		"	'NUMBER', decode(data_scale, 0, 'int', 'double'), "+
        		"	'VARCHAR2', 'String', "+
        		"	'DATE', 'Timestamp', "+
        		"	'String')) data_type_initcap "+
                	"from user_tab_cols "+
			"where table_name = upper(?) "+
			"order by column_id";

		//log.debug("query = "+query);

		List<Column> columns = new ArrayList<Column>();

        	Results myResults = new Results(query, this.table_name_plural, conn);
		String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        Column thisColumn = setupColumnValues(dataRow);
                        columns.add(thisColumn);
                }
		log.debug("There are "+columns.size() + " columns");

        	myResults.close();

		return columns;
	}

        /**
         * Creates a new Column object and sets the data values to those retrieved from the database.
         * @param dataRow       the row of data corresponding to one Column 
         * @return            A Column object with its values setup 
         */
        private Column setupColumnValues(String[] dataRow) {

                //log.debug("in setupColumnValues");

                Column myColumn = new Column();

                myColumn.setColumn_name(dataRow[0]);
                myColumn.setColumn_name_initcap(dataRow[1]);
                myColumn.setData_type(dataRow[2]);
                myColumn.setData_type_initcap(dataRow[3]);

                return myColumn;
        }

        /**
         * Writes the method to see if the record already exists 
         * @param primaryKey       First primaryKey column
         * @param uniqueKeys       List of Column objects containing the unique keys
         */
        public void writeCheckRecordExistsMethod(Column primaryKey, List<Column> uniqueKeys) {
                log.debug("in writeCheckRecordExistsMethod");
                writer.println();
        	writer.println(oneTab + "/**");
	 	writer.println(oneTab + " * Checks to see if a " + table_name + " with the same " + createKeyString(uniqueKeys, "/") + " combination already exists."); 
	 	writer.println(oneTab + " * @param my" + table_name + "\tthe " +table_name + " object being tested");
	 	writer.println(oneTab + " * @param conn	the database connection");
	 	writer.println(oneTab + " * @throws            SQLException if an error occurs while accessing the database");
	 	writer.println(oneTab + " * @return	the " + primaryKey.getColumn_name() + " of a " + table_name + " that currently exists");
	 	writer.println(oneTab + " */");
		writer.println(oneTab + "public int checkRecordExists(" + table_name + " my"+ table_name + ", Connection conn) throws SQLException {");
                writer.println();
		writer.println(twoTabs + "log.debug(\"in checkRecordExists\");");
                writer.println();
		writer.println(twoTabs + "String query = ");
		writer.println(threeTabs + "\"select " + primaryKey.getColumn_name() + " \"+"); 
		writer.println(threeTabs + "\"from " + table_name_plural + " \"+");
		writer.println(threeTabs + "\"where " + createKeyString(uniqueKeys, " = ? \"+ \n " + threeTabs + "\"and ") + " = ?\";");
                writer.println();
		writer.println(twoTabs + "PreparedStatement pstmt = conn.prepareStatement(query,"); 
		writer.println(threeTabs + "ResultSet.TYPE_SCROLL_INSENSITIVE,");
		writer.println(threeTabs + "ResultSet.CONCUR_UPDATABLE);");
                writer.println();
		printPstmtStuff(uniqueKeys);
                writer.println();
		writer.println(twoTabs + "ResultSet rs = pstmt.executeQuery();");
                writer.println();
    		writer.println(twoTabs + "int pk = (rs.next() ? rs.getInt(1) : -1);");
		writer.println(twoTabs + "pstmt.close();");
    		writer.println(twoTabs + "return pk;");
		writer.println(oneTab + "}");
	}

	/**
	 * Gets the User object for this user_name
	 * @param user_name the user_name of the user
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a User object
	 */
/*
	public User getUser(String user_name, Connection conn) throws SQLException {
	
		//log.debug("in getUser as a User object passing in user_name");

		int user_id = getUser_id(user_name, conn);

        	User myUser = getUser(user_id, conn);

        	return myUser;
	}
*/

        
        /**
         * Writes the method to delete this object
         * @param primaryKey       First primaryKey column
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
         */
        public void writeDeleteMethod(Column primaryKey, Connection conn) throws SQLException {
                log.debug("in writeDeleteMethod");
                writer.println();
        	writer.println(oneTab + "/**");
	 	writer.println(oneTab + " * Deletes the record in the " + table_name + " table and also deletes child records in related tables."); 
	 	writer.println(oneTab + " * @param conn	the database connection");
	 	writer.println(oneTab + " * @throws            SQLException if an error occurs while accessing the database");
	 	writer.println(oneTab + " */");
		writer.println(oneTab + "public void delete" + table_name + "(Connection conn) throws SQLException {");
  	
                writer.println();
		writer.println(twoTabs + "log.info(\"in delete" + table_name + "\");");
                writer.println();
		writer.println(twoTabs + "//conn.setAutoCommit(false);");
                writer.println();

        	String query =
			"select replace(initcap(replace(a.table_name, '_', 'X7X')), 'x7x', '_') "+
			"from all_constraints a, all_constraints r "+
			"where a.r_constraint_name = r.constraint_name "+
			"and r.constraint_type in ('P') "+
			"and r.table_name = upper(?) ";

		//log.debug("query = "+query + ", table = " + table_name_plural);

		List<String> tables = new ArrayList<String>();

        	Results myResults = new Results(query, this.table_name_plural, conn);
		String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
			tables.add(dataRow[0]);
		}

		writer.println(twoTabs + "PreparedStatement pstmt = null;");
        	writer.println(twoTabs + "try {");
                writer.println();
		for (Iterator itr = tables.iterator(); itr.hasNext();) {
			String table = (String) itr.next();
			// This gets the plural form of the table, which is not the object name -- AAGH!
			writer.println(threeTabs + "new " + table + "().deleteAll" + table + "For" + table_name + "(" + primaryKey.getColumn_name() + ", conn);");
		}

                writer.println();
		writer.println(threeTabs + "String query = ");
		writer.println(fourTabs + "\"delete from " + table_name_plural + " \" + ");
		writer.println(fourTabs + "\"where " + primaryKey.getColumn_name() + " = ?\";");
                writer.println();

		writer.println(threeTabs + "pstmt = conn.prepareStatement(query, "); 
		writer.println(fourTabs + "ResultSet.TYPE_SCROLL_INSENSITIVE, ");
		writer.println(fourTabs + "ResultSet.CONCUR_UPDATABLE); ");
                writer.println();
		writer.println(threeTabs + "pstmt.setInt(1, " + primaryKey.getColumn_name() + ");");

		writer.println(threeTabs + "pstmt.executeQuery();");

		writer.println(threeTabs + "pstmt.close();");

			/*
			String getUsersGeneLists = 
				"select gene_list_id from gene_lists " +
				"where created_by_user_id = ?";

			pstmt = conn.prepareStatement(getUsersGeneLists, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
			pstmt.setInt(1, userID);

			rs = pstmt.executeQuery();

                	while (rs.next()) {
                        	int geneListID = rs.getInt(1);
				log.debug("geneListID created by this user = "+geneListID);
				new GeneList().deleteGeneList(geneListID, conn);
                	}
                	pstmt.close();

			deleteUserChipsForUser(userID, conn);

			String[] query = new String[4];

  			query[0] =
				"delete from roles " +
				"where user_id = ?";

  			query[1] =
				"delete from group_subjects " +
				"where group_id in (select group_id from isbra_groups where created_by_user_id = ?)";
	
			query[2] = 
				"delete from isbra_groups " +
				"where created_by_user_id = ?";

  			query[3] =
				"delete from users " +
				"where user_id = ?";

                	for (int i=0; i<query.length; i++) {
                        	log.debug("i = " + i + ", query = " + query[i]);
                        	pstmt = conn.prepareStatement(query[i],
                            			ResultSet.TYPE_SCROLL_INSENSITIVE,
                            			ResultSet.CONCUR_UPDATABLE);
                        	pstmt.setInt(1, userID);

                        	pstmt.executeUpdate();
                        	pstmt.close();
                	}
			*/
                writer.println();
		writer.println(threeTabs + "//conn.commit();");
		writer.println(twoTabs + "} catch (SQLException e) {");
		writer.println(threeTabs + "log.debug(\"error in delete" + table_name + "\");");
		writer.println(threeTabs + "//conn.rollback();");
		writer.println(threeTabs + "pstmt.close();");
		writer.println(threeTabs + "throw e;");
		writer.println(twoTabs + "}");
		writer.println(twoTabs + "//conn.setAutoCommit(true);");
		writer.println(oneTab + "}");

  	}

        /**
         * Writes the method to delete all objects for a foreign key
         * @param primaryKey       First primaryKey column
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
         */
        public void writeDeleteAllMethods(Column primaryKey, Connection conn) throws SQLException {
                log.debug("in writeDeleteAllMethods");
        	String query =
			"select replace(initcap(replace(a.table_name, '_', 'X7X')), 'x7x', '_'), "+
			"r.table_name, "+
			"lower(c.column_name), "+
			"lower(rc.column_name) "+
			"from all_constraints a, all_constraints r, all_cons_columns c, all_cons_columns rc "+
			"where a.constraint_name = r.r_constraint_name "+
			"and a.constraint_name = c.constraint_name "+
			"and r.constraint_name = rc.constraint_name "+
			"and r.constraint_type = 'R' "+
			"and r.table_name = upper(?) ";

        	Results myResults = new Results(query, this.table_name_plural, conn);

		//log.debug("query = "+query + ", table = " + table_name_plural);

		List<String> tables = new ArrayList<String>();

		String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
			String relatedTable = dataRow[0];
			String table = dataRow[1];
			String relatedColumn = dataRow[2];
			String column = dataRow[3];

                	writer.println();
        		writer.println(oneTab + "/**");
	 		writer.println(oneTab + " * Deletes the records in the " + table_name + " table that are children of "+ relatedTable + "."); 
	 		writer.println(oneTab + " * @param " + relatedColumn + "	identifier of the " + relatedTable + " table");
	 		writer.println(oneTab + " * @param conn	the database connection");
	 		writer.println(oneTab + " * @throws            SQLException if an error occurs while accessing the database");
	 		writer.println(oneTab + " */");

			writer.println(oneTab + "public void deleteAll" + this.table_name_plural + "For" + relatedTable + "(int " + 
							relatedColumn + ", Connection conn) throws SQLException {");
  	
                	writer.println();
			writer.println(twoTabs + "log.info(\"in deleteAll" + this.table_name_plural + "For" + relatedTable + "\");");
                	writer.println();
			writer.println(twoTabs + "//Make sure committing is handled in calling method!");
                	writer.println();
			writer.println(twoTabs + "String query = ");
			writer.println(threeTabs + "\"select " + primaryKey.getColumn_name()+ " \"+");
			writer.println(threeTabs + "\"from " + table_name_plural + " \"+");
			writer.println(threeTabs + "\"where " + column + " = ?\";");
                	writer.println();
        		writer.println(twoTabs + "Results myResults = new Results(query, " + relatedColumn + ", conn);");

         		writer.println();
         		writer.println(twoTabs + "String[] dataRow;");
         		writer.println();
                	writer.println(twoTabs + "while ((dataRow = myResults.getNextRow()) != null) {");
                	writer.println(threeTabs + "new " + table_name + "(Integer.parseInt(dataRow[0])).delete" + table_name + "(conn);");
                	writer.println(twoTabs + "}");
         		writer.println();
			writer.println(twoTabs + "myResults.close();");
                	writer.println();
			writer.println(oneTab + "}");
  		}

	}

        /**
         * Writes the comparator method 
         * @param columns       List of column objects
         */
        public void writeComparatorMethod(List<Column> columns) {
                log.debug("in writeComparatorMethod");
                writer.println();
        	writer.println(oneTab + "/**");
	 	writer.println(oneTab + " * Compares "+table_name_plural + " based on different fields."); 
	 	writer.println(oneTab + " */");
		writer.println(oneTab + "public class " + table_name + "SortComparator implements Comparator<"+table_name+"> {");
        	writer.println(twoTabs + "int compare;");
                writer.println(twoTabs + table_name + " " + table_name_lower_case + "1, "+ table_name_lower_case + "2;");
                writer.println();
                writer.println(twoTabs + "public int compare("+table_name + " object1, "+table_name + " object2) {");
		writer.println(threeTabs + "String sortColumn = getSortColumn();");
                writer.println(threeTabs + "String sortOrder = getSortOrder();");
                writer.println();
                writer.println(threeTabs + "if (sortOrder.equals(\"A\")) {");
                writer.println(fourTabs + table_name_lower_case + "1 = object1;");
                writer.println(fourTabs + table_name_lower_case + "2 = object2;");
                writer.println(fourTabs + "// default for null columns for ascending order");
                writer.println(fourTabs + "compare = 1;");
                writer.println(threeTabs + "} else {");
                writer.println(fourTabs + table_name_lower_case + "2 = object1;");
                writer.println(fourTabs + table_name_lower_case + "1 = object2;");
                writer.println(fourTabs + "// default for null columns for ascending order");
                writer.println(fourTabs + "compare = -1;");
                writer.println(threeTabs + "}");
                writer.println();
		writer.println(threeTabs + "//log.debug(\"" + table_name_lower_case + "1 = \" +"+table_name_lower_case + 
					"1+ \""+ table_name_lower_case + "2 = \" +"+table_name_lower_case + "2);");
                writer.println();

		int colNum = 0;
		for (Iterator itr = columns.iterator(); itr.hasNext();) {
                	Column column = (Column) itr.next(); 
                        writer.println(threeTabs + (colNum > 0 ? "} else ":"") +  "if (sortColumn.equals(\""+ column.getColumn_name() + "\")) {");
			writer.println(fourTabs + "compare = " + (column.getData_type().equals("int") ? "new Integer(" : "") + 
							table_name_lower_case + "1.get" + 
							column.getColumn_name_initcap() + "()" +
							(column.getData_type().equals("int") ? ")" : "") + 
							".compareTo(" + 
							(column.getData_type().equals("int") ? "new Integer(" : "") + 
							table_name_lower_case + "2.get" + column.getColumn_name_initcap() + "()" +
							(column.getData_type().equals("int") ? ")" : "") + 
							");");
			colNum++;
		}
                writer.println(threeTabs + "}");
                writer.println(threeTabs + "return compare;");
                writer.println(twoTabs + "}");
                writer.println(oneTab + "}");
                writer.println();
        	writer.println(oneTab + "public " + table_name + "[] sort" + table_name_plural + " (" + table_name + "[] my" + table_name_plural + 
					", String sortColumn, String sortOrder) {");
                writer.println(twoTabs + "setSortColumn(sortColumn);");
                writer.println(twoTabs + "setSortOrder(sortOrder);");
                writer.println(twoTabs + "Arrays.sort(my" + table_name_plural + ", new " + table_name + "SortComparator());");
                writer.println(twoTabs + "return my" + table_name_plural + ";");
                writer.println(oneTab + "}");
                writer.println();
        }

	/** Writes the equals method
	 * @param primaryKey 	the first primary key
	 */
	public void writeEqualsMethod(Column primaryKey) {
                log.debug("in writeEqualsMethod");
                writer.println();
        	writer.println(oneTab + "/**");
	 	writer.println(oneTab + " * Determines equality of "+ table_name + " objects."); 
	 	writer.println(oneTab + " */");
		writer.println(oneTab + "public boolean equals(Object obj) {");
		writer.println(twoTabs + "if (!(obj instanceof " + table_name + ")) return false;");
		writer.println(twoTabs + "return (this."+primaryKey.getColumn_name() + 
					" == ((" + table_name + ")obj)."+ primaryKey.getColumn_name() + ");");
                writer.println();
                writer.println(oneTab + "}");
	}
        
        /**
         * Writes the toString and print methods 
         * @param primaryKey       The first primary key
         */
        public void writePrintMethod(Column primaryKey) {
                log.debug("in writePrintMethod");
                writer.println();
        	writer.println(oneTab + "/**");
	 	writer.println(oneTab + " * Converts "+ table_name_plural + " object to a String."); 
	 	writer.println(oneTab + " */");
		writer.println(oneTab + "public String toString() {");
        	writer.println(twoTabs + "return \"This " + table_name + " has "+ primaryKey.getColumn_name() + " = \" + " + primaryKey.getColumn_name() + ";");
                writer.println(oneTab + "}");
                writer.println();
        	writer.println(oneTab + "/**");
	 	writer.println(oneTab + " * Prints "+ table_name + " object to the log."); 
	 	writer.println(oneTab + " */");
		writer.println(oneTab + "public void print() {");
        	writer.println(twoTabs + "log.debug(toString());");
                writer.println(oneTab + "}");
                writer.println();
	}

        /**
         * Writes header stuff to file
         */
        public void writeHeaderStuff(List<Column> primaryKeys) {
                log.debug("in writeHeaderStuff");
		String[] lines = new String[] {
		"package edu.ucdenver.ccp.PhenoGen.data;", "",
		"import java.sql.Connection;",
		"import java.sql.PreparedStatement;",
		"import java.sql.ResultSet;",
		"import java.sql.SQLException;", "",
		"import java.util.ArrayList;",
		"import java.util.Arrays;",
		"import java.util.Comparator;",
		"import java.util.List;", "",
		"import edu.ucdenver.ccp.PhenoGen.util.DbUtils;", "",
		"import edu.ucdenver.ccp.util.Debugger;", "",
		"import edu.ucdenver.ccp.util.ObjectHandler;", "",
		"import edu.ucdenver.ccp.util.sql.Results;", "",
		"/*",
		"import package edu.ucdenver.ccp.PhenoGen.data;",
		"import java.io.BufferedReader;",
		"import java.io.BufferedWriter;",
		"import java.io.File;",
		"import java.io.FilenameFilter;",
		"import java.io.FileWriter;",
		"import java.io.IOException;", "",
		"import java.util.HashMap;",
		"import java.util.HashSet;",
		"import java.util.Hashtable;",
		"import java.util.Iterator;",
		"import java.util.LinkedHashMap;",
		"import java.util.LinkedHashSet;",
		"import java.util.Properties;",
		"import java.util.Set;",
		"import java.util.TreeMap;",
		"import java.util.TreeSet;", "",
		"import edu.ucdenver.ccp.util.FileHandler;",
		"import edu.ucdenver.ccp.util.sql.PropertiesConnection;", "",
		"import edu.ucdenver.ccp.PhenoGen.data.AsyncUpdateDataset;",
		"import edu.ucdenver.ccp.PhenoGen.data.Dataset;",
		"import edu.ucdenver.ccp.PhenoGen.data.Experiment;",
		"import edu.ucdenver.ccp.PhenoGen.data.GeneList;",
		"import edu.ucdenver.ccp.PhenoGen.data.ParameterValue;",
		"import edu.ucdenver.ccp.PhenoGen.data.User;", "",
		"import edu.ucdenver.ccp.PhenoGen.driver.Async_R_Session;",
		"import edu.ucdenver.ccp.PhenoGen.driver.RException;",
		"import edu.ucdenver.ccp.PhenoGen.driver.R_session;", "",
		"import edu.ucdenver.ccp.PhenoGen.web.mail.Email; ",
		"import edu.ucdenver.ccp.PhenoGen.web.SessionHandler;", "",
		"import edu.ucdenver.ccp.PhenoGen.web.ErrorException;",
		"*/", "",
		"/* for logging messages */",
		"import org.apache.log4j.Logger;", "",
		"/**",
		" * Class for handling data related to " + table_name_plural,
		" *  @author  Cheryl Hornbaker",
		" */", "",
		"public class " + table_name + " {", "",
		oneTab + "private Logger log=null;", "",
		oneTab + "private DbUtils myDbUtils = new DbUtils();",
        	oneTab + "private Debugger myDebugger = new Debugger();", "",
		oneTab + "public " + table_name + "() {",
		twoTabs + "log = Logger.getRootLogger();",
		oneTab + "}", "",
		oneTab + "public " + table_name + "(" + createPrimaryKeyConstructorString(primaryKeys) + ") {",  
		twoTabs + "log = Logger.getRootLogger();"
		};
		for (int i=0; i<lines.length; i++) {
			writer.println(lines[i]);
		}
		for (Iterator itr = primaryKeys.iterator(); itr.hasNext();) {
			Column primaryKey = (Column) itr.next();	
			writer.println(twoTabs + "this.set" + primaryKey.getColumn_name_initcap() + "(" + primaryKey.getColumn_name() + ");");
		}
		writer.println(oneTab + "}");
		writer.println();
       }

	/**
	 * Returns a String with the primary keys and their datatypes for use in a constructor.
	 * @param primaryKeys	List of column objects containing the primary keys	
	 * @return	 a String in the form: "int primaryKey1, String primaryKey2"
	 */
	private String createPrimaryKeyConstructorString(List<Column> primaryKeys) {
		log.debug("in createPrimaryKeyConstructorString");
		String pk = "";
		int i=0;
		for (Iterator itr = primaryKeys.iterator(); itr.hasNext();) {
			Column primaryKey = (Column) itr.next();	
			pk = pk + primaryKey.getData_type() + " " + primaryKey.getColumn_name();
			if (i < primaryKeys.size() - 1) {  
				pk = pk + ", ";
			}
			i++;
		}
		return pk;
	}

	/**
	 * Returns a String with the keys separated by the separator
	 * @param keys	List of column objects containing the primary or unique keys	
	 * @param separator	String to separate
	 * @return	 a String in the form: "key1, key2"
	 */
	private String createKeyString(List<Column> keys, String separator) {
		log.debug("in createKeyString. # = " + keys.size());
		//log.debug("keys = "); myDebugger.print(keys);
		String keyString = "";
		if (keys.size() > 0) {
			for (Iterator itr = keys.iterator(); itr.hasNext();) {
				Column key = (Column) itr.next();	
				keyString = keyString + key.getColumn_name();
				if (itr.hasNext()) {  
					keyString = keyString + separator;
				}
			}
		}
		return keyString;
	}

	/**
	 * Writes objects in sets of 5.
	 * Prints them out as:	
	 * first, others, others, others, fifth
	 * others, others, last
	 * @param i	the index of the object
	 * @param totalLength	the total number of objects
	 * @param first	what to print on the first occasion
	 * @param last	what to print on the last occasion
	 * @param fifth	what to print on the fifth occasion
	 * @param others	what to print on all other occasions
	 */
	private void writeSetsOfFive(int i, int totalLength, 
					String first, String last, String fifth, String others) {
		//log.debug("i = " + i);
		if (i == 0) {
			writer.print(first);
			//log.debug("first = " + first);
		} else if (i == totalLength - 1) {
			writer.print(last);
			//log.debug("last = " + last);
		} else if (i%5 == 0) {
			writer.print(fifth);
			//log.debug("fifth = " + fifth);
		} else {
			writer.print(others);
			//log.debug("others = " + others);
		}
	}

	/**
	 * Writes Column objects in sets of 5.
	 * Prints them out as:	
	 * first, others, others, others, fifth
	 * others, others, last
	 * @param columns	a List of Column objects
	 * @param first	what to print on the first occasion
	 * @param last	what to print on the last occasion
	 * @param fifth	what to print on the fifth occasion
	 * @param others	what to print on all other occasions
	 * @param printToCharCode	"Y" to print the to_char() around date columns, "N" to not print it
	 */
	private void writeColumnsInSetsOfFive (List<Column> columns, 
						String first, String last, String fifth, String others, String printToCharCode) {
		/*
		log.debug("in writeColumnsInSetsOfFive");
		log.debug("first = "+first);
		log.debug("last = "+last);
		log.debug("fifth = "+fifth);
		log.debug("others = "+others);
		log.debug("size = "+columns.size());
		*/
		
		int i=0;
		for (Iterator itr = columns.iterator(); itr.hasNext();) {
                	Column column = (Column) itr.next(); 
			String whatToPrint = (printToCharCode.equals("Y") && column.getData_type().equals("java.sql.Timestamp") ? 
							"to_char(" + column.getColumn_name() + ", 'dd-MON-yyyy hh24:mi:ss')" : column.getColumn_name()); 
			//log.debug("column = "+column);
			writeSetsOfFive(i, 
				columns.size(), 
				first.replaceAll("&COLUMN_NAME", whatToPrint),
				last.replaceAll("&COLUMN_NAME", whatToPrint),
				fifth.replaceAll("&COLUMN_NAME", whatToPrint),
				others.replaceAll("&COLUMN_NAME", whatToPrint));
			i++;
		}
	}

        /**
         * Writes the JSP file to create a new record
         * @param columns       List of column objects
         * @param primaryKey       Column object containing primary key
         */
        public void writeJSPCreateFile(List<Column> columns, Column primaryKey) {
                //log.debug("in writeJSPCreateFile");
		writer.println("<%@ include file=\"/web/geneLists/include/geneListHeader.jsp\"  %>");
		writer.println();
		writer.println("<jsp:useBean id=\"my" + table_name + 
				"\" class=\"edu.ucdenver.ccp.PhenoGen.data." + table_name + "\"> </jsp:useBean>");
		writer.println();
		writer.println("<%");
		writer.println();

        	writer.println(oneTab + "if ((action != null) && action.equals(\"Create\")) {");
		for (Iterator itr = columns.iterator(); itr.hasNext();) {
                	Column column = (Column) itr.next(); 
                	writer.print(twoTabs + column.getData_type() + " " + column.getColumn_name() + " = ");
			if (column.getData_type().equals("int")) {
                		writer.println("Integer.parseInt((String) request.getParameter(\"" + column.getColumn_name() + "\"));");
			} else {
                		writer.println("(String) request.getParameter(\"" + column.getColumn_name() + "\");");
			}
		}
		writer.println();
		for (Iterator itr = columns.iterator(); itr.hasNext();) {
                	Column column = (Column) itr.next(); 
			writer.println(twoTabs + "my" + table_name + ".set" + column.getColumn_name_initcap() + "(" +  
                		column.getColumn_name() + ");");
		}
		writer.println(twoTabs + "my" + table_name + ".create" + table_name + "(dbConn);");

		writer.println(twoTabs + "session.setAttribute(\"successMsg\", \"XXX-XXX\");");
		writer.println(twoTabs + "response.sendRedirect(commonDir + \"successMsg.jsp\");");
		writer.println(oneTab + "}");
		writer.println("%>");
		writer.println();
		writer.println("<%@ include file=\"/web/common/headTags.jsp\"%>");
		writer.println();
		writer.println(oneTab + "<form method=\"post\"");
		writer.println(twoTabs + "name=\"" + table_name + "\"");
		writer.println(twoTabs + "action=\"create" + table_name + ".jsp\"");
		writer.println(twoTabs + "enctype=\"application/x-www-form-urlencoded\">");
		writer.println();
		writer.println(oneTab + "<div class=\"page-intro\">");
		writer.println(twoTabs + "<p>Fill in the form below to create a new " + table_name + "."); 
		writer.println(twoTabs + "</p>");
		writer.println(oneTab + "</div> <!-- // end page-intro -->");
		writer.println(oneTab + "<div class=\"brClear\"></div>");
		writer.println();

      		writer.println(oneTab + "<table name=\"items\" class=\"list_base\" cellpadding=\"0\" cellspacing=\"3\" >");
        	writer.println(twoTabs + "<tr>");
		for (Iterator itr = columns.iterator(); itr.hasNext();) {
                	Column column = (Column) itr.next(); 
                	writer.println(threeTabs + "<td valign=\"top\"> <strong>" + column.getColumn_name_initcap().replaceAll("_", " ") + 
					":</strong> </td>");
                	writer.println(threeTabs + "<td> <input type=\"text\" name=\"" + column.getColumn_name() + "\"" + "> </td>");
        		writer.println(twoTabs + "</tr>");
		}
                writer.println("<input type=\"submit\" name=\"action\" value=\"Create\">");
		writer.println("</form>");
	}


        /**
         * Writes the JSP file to display all records 
         * @param columns       List of column objects
         * @param primaryKey       Column object containing primary key
         */
        public void writeJSPListFile(List<Column> columns, Column primaryKey) {
                //log.debug("in writeJSPListFile");

		writer.println("<%@ include file=\"/web/geneLists/include/geneListHeader.jsp\"  %>");
		writer.println("<%");
		writer.println(oneTab + "extrasList.add(\"list" + table_name + ".js\");");
		writer.println(oneTab + "// Need to include this here, so that it's available on the modal");
		writer.println(oneTab + "extrasList.add(\"create" + table_name + ".js\");");
		writer.println("%>");
		writer.println();
		writer.println("<%@ include file=\"/web/common/header.jsp\"%>");
		writer.println(oneTab + "<div class=\"page-intro\">");
		writer.println(twoTabs + "<p>Click on a " + table_name + 
				" to select it for further investigation, or create a new " + table_name + ".");
		writer.println(twoTabs + "</p>");
		writer.println(oneTab + "</div> <!-- // end page-intro -->");
		writer.println(oneTab + "<div class=\"brClear\"></div>");
		writer.println();

		writer.println(oneTab + "<div class=\"list_container\">");
		writer.println(oneTab + "<form name=\"choose" + table_name + "\" action=\"choose" + table_name + ".jsp\" method=\"get\">");
		writer.println();

		writer.println(twoTabs + "<div class=\"left inlineButton\" name=\"createGeneList\"> Create New "+ table_name +"</div>");
		writer.println(twoTabs + "<div class=\"title\"> " + table_name_plural + " </div>");
		writer.println(twoTabs + "<table name=\"items\" class=\"list_base tablesorter\"" + 
					" cellpadding=\"0\" cellspacing=\"2\" width=\"98%\">");
		writer.println();
        	writer.println(twoTabs + "<thead>");
        	writer.println(twoTabs + "<tr class=\"col_title\">");
		for (Iterator itr = columns.iterator(); itr.hasNext();) {
                	Column column = (Column) itr.next(); 
                	writer.println(threeTabs + "<th>" + column.getColumn_name_initcap().replaceAll("_", " ") + "</th>"); 
		}
		writer.println(threeTabs + "<th class=\"noSort\">Details");
                writer.println(fourTabs + "<span class=\"info\" title=\"Parameters used in creating this " + table_name + ".\">");
                writer.println(fourTabs + "<img src=\"<%=imagesDir%>icons/info.gif\" alt=\"Help\">");
                writer.println(fourTabs + "</span>");
		writer.println(threeTabs + "</th>");
		writer.println(threeTabs + "<th class=\"noSort\">Delete</th>");
		writer.println(threeTabs + "<th class=\"noSort\">Download</th>");
        	writer.println(threeTabs + "</tr>");
        	writer.println(threeTabs + "</thead>");
        	writer.println(threeTabs + "<tbody>");
		writer.println();
		writer.println(twoTabs + "<%");
        	writer.println(twoTabs + "//");
        	writer.println(twoTabs + "// Get the " + table_name_plural + " which are stored in PhenoGen");
        	writer.println(twoTabs + "//");
                writer.println(twoTabs + table_name + "[] my" + table_name_plural + 
				" = new " + table_name + "().getAll" + table_name_plural + "(dbConn); ");
		writer.println();
        	writer.println(twoTabs + "for ( int i = 0; i < my" + table_name_plural + ".length; i++ ) {");
                writer.println(threeTabs + table_name + " this" + table_name + " = (" + table_name + ") my" + table_name_plural + "[i];  %>");
                writer.println(threeTabs + "<tr id=\"<%=this" + table_name + ".get" + primaryKey.getColumn_name_initcap() + "()%>\">");
		for (Iterator itr = columns.iterator(); itr.hasNext();) {
                	Column column = (Column) itr.next(); 
                	writer.println(fourTabs + "<td><%=this" + table_name + ".get" + column.getColumn_name_initcap() + "()%></td>"); 
		}
    		writer.println(fourTabs + "<td class=\"details\"> View</td>");
		writer.println(fourTabs + "<td class=\"actionIcons\">");
		writer.println(fiveTabs + "<div class=\"linkedImg delete\"></div>");
		writer.println(fourTabs + "</td>");
		writer.println(fourTabs + "<td class=\"actionIcons\">");
		writer.println(fiveTabs + "<div class=\"linkedImg download\"></div>");
		writer.println(fourTabs + "</td>");
		writer.println(fourTabs + "</tr>");
		writer.println(threeTabs + "<% } %>");
		writer.println(threeTabs + "</tbody>");
		writer.println(twoTabs + "</table>");
		writer.println(twoTabs + "<input type=\"hidden\" name=\"" + primaryKey.getColumn_name() + "\" />");
		writer.println(twoTabs + "<input type=\"hidden\" name=\"action\" value=\"\" />");
		writer.println(twoTabs + "</form>");
		writer.println(twoTabs + "</div>");
		writer.println(oneTab + "<div class=\"itemDetails\"></div>");
		writer.println(oneTab + "<div class=\"createGeneList\"></div>");
		writer.println(oneTab + "<div class=\"deleteItem\"></div>");
		writer.println(oneTab + "<div class=\"downloadItem\"></div>");
		writer.println(oneTab + "<div class=\"load\">Loading...</div>");
		writer.println(oneTab + "<script type=\"text/javascript\">");
		writer.println(twoTabs + "$(document).ready(function() {");
		writer.println(twoTabs + "setupPage();");
		writer.println(twoTabs + "setTimeout(\"setupMain()\", 100); ");
		writer.println(twoTabs + "});");
		writer.println(oneTab + "</script>");
		writer.println();
		writer.println("<%@ include file=\"/web/common/footer.jsp\"%>");
	}



        /**
         * Writes create method
         * @param columns       List of column objects
         * @param primaryKey       Column object containing primary key
         */
        public void writeCreateMethod(List<Column> columns, Column primaryKey) {
                log.debug("in writeCreateMethod. PrimaryKey = " + primaryKey);
                writer.println();
        	writer.println(oneTab + "/**");
	 	writer.println(oneTab + " * Creates a record in the "+table_name_plural + " table."); 
	 	writer.println(oneTab + " * @param conn \tthe database connection");
	 	writer.println(oneTab + " * @throws SQLException\tif an error occurs while accessing the database");
	 	writer.println(oneTab + " * @return\tthe identifier of the record created");
	 	writer.println(oneTab + " */");
		writer.println(oneTab + "public int create" + table_name + "(Connection conn) throws SQLException {");
		writer.println();
		writer.println(twoTabs + "log.debug(\"In create " + table_name + "\");");
		writer.println();
        	writer.println(twoTabs + "int " + primaryKey.getColumn_name() + " = myDbUtils.getUniqueID(\"" + table_name_plural + "_seq\", conn);");
		writer.println();
		// Write select statement with 5 columns on each line
        	writer.println(twoTabs + "String query = ");
        	writer.println(threeTabs + "\"insert into " + table_name_plural + " \"+");
		writeColumnsInSetsOfFive(columns, 
        			threeTabs + "\"(" + "&COLUMN_NAME" + ", ",
				"&COLUMN_NAME" + ") \"+" + "\n",
				"\"+" + "\n" +  threeTabs + "\"" + "&COLUMN_NAME" + ", ",
        			"&COLUMN_NAME" + ", ", 
				"N");

		writer.println(threeTabs + "\"values \"+");
		for (int j=0; j<columns.size(); j++) {
			writeSetsOfFive(j, 
				columns.size(),
        			threeTabs + "\"(" + "?, ",
                		"?)\";",
				"\"+" + "\n" + threeTabs + "\"?, ",
                		"?, ");
		}
		writer.println();
		writer.println();
		writer.println(twoTabs + "//log.debug(\"query =  \" + query);");
		writer.println();
                writer.println(twoTabs + "java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());");
        	writer.println(twoTabs + "PreparedStatement pstmt = conn.prepareStatement(query, ");
		writer.println(fourTabs + "ResultSet.TYPE_SCROLL_INSENSITIVE,");
		writer.println(fourTabs + "ResultSet.CONCUR_UPDATABLE);");
		writer.println();
                //writer.println(threeTabs + "" + "pstmt.setInt(1, " + primaryKey.getColumn_name() + ");");  

		printPstmtStuff(columns);

		writer.println();
        	writer.println(twoTabs + "pstmt.executeUpdate();");
        	writer.println(twoTabs + "pstmt.close();");
		writer.println();
        	writer.println(twoTabs + "this.set" + primaryKey.getColumn_name_initcap() + "(" + primaryKey.getColumn_name() + ");");

		writer.println();
  		writer.println(twoTabs + "return " + primaryKey.getColumn_name() + ";");
		writer.println(oneTab + "}");
	}

        /**
         * Writes update method
         * @param columns       List of column objects
         * @param primaryKey       Column object containing primary key
         */
        public void writeUpdateMethod(List<Column> columns, Column primaryKey) {
                log.debug("in writeUpdateMethod");
                writer.println();
        	writer.println(oneTab + "/**");
	 	writer.println(oneTab + " * Updates a record in the "+ table_name_plural + " table."); 
	 	writer.println(oneTab + " * @param conn \tthe database connection");
	 	writer.println(oneTab + " * @throws SQLException\tif an error occurs while accessing the database");
	 	writer.println(oneTab + " */");
		writer.println(oneTab + "public void update(Connection conn) throws SQLException {");
		writer.println();
        	writer.println(twoTabs + "String query = ");
        	writer.println(threeTabs + "\"update " + table_name_plural + " \"+");
		// Write select statement with 5 columns on each line
		writeColumnsInSetsOfFive(columns,
        			threeTabs + "\"set " + "&COLUMN_NAME" + " = ?, ",
                		"&COLUMN_NAME" + " = ? \"+" + "\n",
				"\"+" + "\n" +  threeTabs + "\"" + "&COLUMN_NAME" + " = ?, ",
        			"&COLUMN_NAME" + " = ?, ",
				"N");

		writer.println(threeTabs + "\"where " + primaryKey.getColumn_name() + " = ?\";");
		writer.println();
		writer.println(twoTabs + "log.debug(\"query =  \" + query);");
		writer.println();
                writer.println(twoTabs + "java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());");

		writer.println();
        	writer.println(twoTabs + "PreparedStatement pstmt = conn.prepareStatement(query, ");
		writer.println(fourTabs + "ResultSet.TYPE_SCROLL_INSENSITIVE,");
		writer.println(fourTabs + "ResultSet.CONCUR_UPDATABLE);");
		writer.println();
		
		printPstmtStuff(columns);

                writer.println(twoTabs + "" + "pstmt.setInt(" + (columns.size() + 1) + ", " + primaryKey.getColumn_name() + ");");  
		writer.println();

        	writer.println(twoTabs + "pstmt.executeUpdate();");
        	writer.println(twoTabs + "pstmt.close();");
		writer.println();
		writer.println(oneTab + "}");
	}

        /**
         * Writes pstmt set commands
         * @param columns       List of column objects
         * @param primaryKey       Column object containing primary key
         */
	private void printPstmtStuff(List<Column> columns) {
		int k=1;
		for (Iterator itr = columns.iterator(); itr.hasNext();) {
                	Column column = (Column) itr.next(); 
			log.debug(column);
                	if (column.getData_type().equals("int")) {
                		writer.println(twoTabs + "" + "pstmt.setInt(" + k + ", " + column.getColumn_name() + ");");  
                	} else if (column.getData_type().equals("java.sql.Timestamp")) {
                		//writer.println(twoTabs + "" + "pstmt.setTimestamp(" + k + ", " + column.getColumn_name() + ");");  
                		writer.println(twoTabs + "" + "pstmt.setTimestamp(" + k + ", " + "now" + ");");  
			} else {
                		writer.println(twoTabs + "" + "pstmt.setString(" + k + ", " + column.getColumn_name() + ");");  
			}
			k++;
		}
	}

        /**
         * Writes getAllXXX method
         * @param columns       List of column objects
         * @param primaryKeys       List of column objects containing the primaryKeys
         */
        public void writeGetAllMethod(List<Column> columns, List<Column> primaryKeys) {
                log.debug("in writeGetAllMethod");
                writer.println();
        	writer.println(oneTab + "/**");
	 	writer.println(oneTab + " * Gets all the "+table_name_plural); 
	 	writer.println(oneTab + " * @param conn \tthe database connection");
	 	writer.println(oneTab + " * @throws SQLException\tif an error occurs while accessing the database");
	 	writer.println(oneTab + " * @return\tan array of "+ table_name + " objects");
	 	writer.println(oneTab + " */");

		writer.println(oneTab + "public " + table_name + "[] getAll" + table_name_plural + "(Connection conn) throws SQLException {");
                writer.println();
		writer.println(twoTabs + "log.debug(\"In getAll" + table_name_plural + "\");");
                writer.println();

		// Write select statement with 5 columns on each line
        	writer.println(twoTabs + "String query = ");
        	writer.println(threeTabs + "\"select \"+");
		writeColumnsInSetsOfFive(columns, 
        			threeTabs + "\"" + "&COLUMN_NAME" + ", ",
				"&COLUMN_NAME" + " \"+\n",
				"\"+" + "\n" +  threeTabs + "\"" + "&COLUMN_NAME" + ", ",
        			"&COLUMN_NAME" + ", ",
				"Y");

		writer.println(threeTabs + "\"from " + table_name_plural + " \"+ ");
		writer.println(threeTabs + "\"order by " + createKeyString(primaryKeys, ", ") + "\";");
		writer.println();
		writer.println(twoTabs + "//log.debug(\"query =  \" + query);");
		writer.println();
        	writer.println(twoTabs + "Results myResults = new Results(query, conn);");
		writer.println();
        	writer.println(twoTabs + "" + table_name + "[] my" + table_name_plural + " = setup" + table_name + "Values(myResults);");
		writer.println();
        	writer.println(twoTabs + "myResults.close();");
		writer.println();
        	writer.println(twoTabs + "return my" + table_name_plural + ";");
		writer.println(oneTab + "}");
	}

        /**
         * Writes getOneXXX method
         * @param columns       List of column objects
         * @param primaryKey       Column object containing primary key
         */
        public void writeGetOneMethod(List<Column> columns, Column primaryKey) {
                log.debug("in writeGetOneMethod");
		//String theseKeys = myObjectHandler.getAsSeparatedString(primaryKeys, ", ");
                writer.println();
        	writer.println(oneTab + "/**");
	 	writer.println(oneTab + " * Gets the "+table_name+" object for this "+primaryKey.getColumn_name());
	 	writer.println(oneTab + " * @param "+ primaryKey.getColumn_name() + oneTab + " the identifier of the " + table_name);
	 	writer.println(oneTab + " * @param conn \tthe database connection");
	 	writer.println(oneTab + " * @throws SQLException\tif an error occurs while accessing the database");
	 	writer.println(oneTab + " * @return\ta "+ table_name + " object");
	 	writer.println(oneTab + " */");
		writer.println(oneTab + "public " + table_name + " get" + table_name + "(" + primaryKey.getData_type() + " " + 
				primaryKey.getColumn_name() + ", Connection conn) throws SQLException {");
                writer.println();
		writer.println(twoTabs + "log.debug(\"In getOne " + table_name + "\");");
                writer.println();
		// Write select statement with 5 columns on each line
        	writer.println(twoTabs + "String query = ");
        	writer.println(threeTabs + "\"select \"+");
		writeColumnsInSetsOfFive(columns, 
        			threeTabs + "\"" + "&COLUMN_NAME" + ", ",
				"&COLUMN_NAME" + " \"+\n",
				"\"+" + "\n" +  threeTabs + "\"" + "&COLUMN_NAME" + ", ",
        			"&COLUMN_NAME" + ", ",
				"Y");

		writer.println(threeTabs + "\"from " + table_name_plural + " \"+ ");
		writer.println(threeTabs + "\"where " + primaryKey.getColumn_name() + " = ?\";");
		writer.println();
		writer.println(twoTabs + "//log.debug(\"query =  \" + query);");
		writer.println();
        	writer.println(twoTabs + "Results myResults = new Results(query, "+primaryKey.getColumn_name() + ", conn);");
		writer.println();
        	writer.println(twoTabs + "" + table_name + " my" + table_name + " = setup" + table_name + "Values(myResults)[0];");
		writer.println();
        	writer.println(twoTabs + "myResults.close();");
		writer.println();
        	writer.println(twoTabs + "return my" + table_name + ";");
		writer.println(oneTab + "}");
	}


        /**
         * Writes setupXXXValues method
         * @param columns       List of column objects
         */
        public void writeSetupMethod(List<Column> columns) {
                log.debug("in writeSetupMethod");
                writer.println();
        	writer.println(oneTab + "/**");
         	writer.println(oneTab + " * Creates an array of " + table_name + " objects and sets the data values to those retrieved from the database.");
         	writer.println(oneTab + " * @param myResults\tthe Results object corresponding to a set of " + table_name_plural);
         	writer.println(oneTab + " * @return\tAn array of "+ table_name + " objects with their values setup ");
         	writer.println(oneTab + " */");
        	writer.println(oneTab + "private " + table_name + "[] setup" + table_name + "Values(Results myResults) {");
         	writer.println();
                writer.println(twoTabs + "//log.debug(\"in setup"+table_name+"Values\");");
         	writer.println();
		writer.println(twoTabs + "List<" + table_name + "> " + table_name + "List = new ArrayList<" + table_name + ">();");
         	writer.println();
         	writer.println(twoTabs + "String[] dataRow;");
         	writer.println();
                writer.println(twoTabs + "while ((dataRow = myResults.getNextRow()) != null) {");
         	writer.println();
                writer.println(threeTabs + "//log.debug(\"dataRow= \"); myDebugger.print(dataRow);");
         	writer.println();
                writer.println(threeTabs + "" + table_name + " this" + table_name + " = new "+ table_name + "();");
         	writer.println();
		//Set the values
		int i=0;
		for (Iterator itr = columns.iterator(); itr.hasNext();) {
                	Column column = (Column) itr.next(); 
                	if (column.getData_type().equals("int") || column.getData_type().equals("double")) {
                		writer.println(threeTabs + "if (dataRow[" + i + "] != null && !dataRow[" + i + "].equals(\"\")) {");
                		if (column.getData_type().equals("int")) {
                			writer.println(fourTabs + "" + "this" + table_name + ".set" + column.getColumn_name_initcap() + 
						"(Integer.parseInt(dataRow[" + i + "]));");
 				} else if (column.getData_type().equals("double")) {
                			writer.println(fourTabs + "" + "this" + table_name + ".set" + column.getColumn_name_initcap() + 
						"(Double.parseDouble(dataRow[" + i + "]));");
				}
				writer.println(threeTabs + "}");
                	} else if (column.getData_type().equals("java.sql.Timestamp")) {
                		writer.println(threeTabs + "" + "this" + table_name + ".set" + column.getColumn_name_initcap() + 
				"(new ObjectHandler().getOracleDateAsTimestamp(dataRow[" + i + "]));");
			} else {
				writer.println(threeTabs + "" + "this" + table_name + ".set" + column.getColumn_name_initcap() + 
				"(dataRow[" + i + "]);");
			}
			i++;
		}
                writer.println();
                writer.println(threeTabs + "" + table_name + "List.add(this" + table_name + ");");
                writer.println(twoTabs + "}");
                writer.println();
                writer.println(twoTabs + "" + table_name + "[] "+ table_name + "Array = ("+ table_name + "[]) "+ table_name + 
			"List.toArray(new " + table_name + "[" + table_name + "List.size()]);");

                writer.println();
                writer.println(twoTabs + "return "+table_name + "Array;");
                writer.println(oneTab + "}");
        }

	/**
	 * Writes the final brace 
	 */
	public void writeFooterStuff() {
		writer.println("}");
	}

        /**
         * Writes column stuff to file
         * @param columns       List of column objects
         */
        public void writeColumnStuff(List<Column> columns) {
                log.debug("in writeColumnStuff");
                writer.println();
		//Print out the column declarations
		for (Iterator itr = columns.iterator(); itr.hasNext();) {
                	Column column = (Column) itr.next(); 
                	writer.println(oneTab + "private " + 
				column.getData_type() + " " + column.getColumn_name() + ";");
		}
		//Print out the declarations for sorting
                writer.println(oneTab + "private String sortColumn =\"\";"); 
                writer.println(oneTab + "private String sortOrder =\"A\";"); 
                writer.println();
		// Print out the set and get methods
		for (Iterator itr = columns.iterator(); itr.hasNext();) {
                	Column column = (Column) itr.next(); 
                	writer.println(oneTab + "" + "public void set" + column.getColumn_name_initcap() + "(" + 
					column.getData_type() + " in" + column.getData_type_initcap() + ") {");
                	writer.println(twoTabs + "" + "this." + column.getColumn_name() + " = in" + column.getData_type_initcap() + ";");
                	writer.println(oneTab + "}");
                	writer.println();
                	writer.println(oneTab + "" + "public " + column.getData_type() + " get" + column.getColumn_name_initcap() + "() {");  
                	writer.println(twoTabs + "" + "return this." + column.getColumn_name() + ";");
                	writer.println(oneTab + "}");
                	writer.println();
		}
                writer.println(oneTab + "public void setSortColumn(String inString) {");
                writer.println(twoTabs + "" + "this.sortColumn = inString;"); 
                writer.println(oneTab + "}");
                writer.println();
                writer.println(oneTab + "" + "public String getSortColumn() {");  
                writer.println(twoTabs + "" + "return this.sortColumn;");
                writer.println(oneTab + "}");
                writer.println();
                writer.println(oneTab + "public void setSortOrder(String inString) {");
                writer.println(twoTabs + "" + "this.sortOrder = inString;"); 
                writer.println(oneTab + "}");
                writer.println();
                writer.println(oneTab + "" + "public String getSortOrder() {");  
                writer.println(twoTabs + "" + "return this.sortOrder;");
                writer.println(oneTab + "}");
                writer.println();
        }

	public Connection getConnection(File propertiesFile) {
        	Connection conn = null;
        	try {
                	conn = new PropertiesConnection().getConnection(propertiesFile);
                	System.out.println("Got database Connection");
        	} catch (IOException e) {
                	System.out.println("Can't find properties file");
        	} catch (ClassNotFoundException e) {
                	System.out.println("Can't get Connection");
        	} catch (SQLException e) {
                	System.out.println("Can't get Connection");
        	}
        	return conn;

  	}

	private void createFiles () {

        	String javaFileName = baseDir + "src/" + getTable_name() + ".jav";
        	String jspListFileName = baseDir + "src/choose" + getTable_name() + ".jsp";
        	String jspCreateFileName = baseDir + "src/create" + getTable_name() + ".jsp";
		FileHandler myFileHandler = new FileHandler();

		try {
			List<Column> columns = getColumns(dbConn);
			List<Column> primaryKeys = getKeys("P", dbConn);
			List<Column> uniqueKeys = getKeys("P", dbConn);
			//List<Column> uniqueKeys = getKeys("U", dbConn);

/*
			List<Column> primaryKeys = new ArrayList<Column>();
			List<Column> uniqueKeys = new ArrayList<Column>();
			Column fakePK = new Column();
			fakePK.setColumn_name("Fake");
                	fakePK.setColumn_name_initcap("Fake");
			fakePK.setData_type("String");
			fakePK.setData_type_initcap("String");
			primaryKeys.add(fakePK);

			Column fakeUK = new Column();
			fakeUK.setColumn_name("Fake");
                	fakeUK.setColumn_name_initcap("Fake");
			fakeUK.setData_type("String");
			fakeUK.setData_type_initcap("String");
			uniqueKeys.add(fakeUK);
*/

			writer = myFileHandler.openFile(javaFileName);
			writeHeaderStuff(primaryKeys);
			writeColumnStuff(columns);
			writeGetAllMethod(columns, primaryKeys);
			//if (primaryKeys.size() >= 1) {
				writeGetOneMethod(columns, (Column) primaryKeys.get(0));
				writeCreateMethod(columns, (Column) primaryKeys.get(0));
				writeUpdateMethod(columns, (Column) primaryKeys.get(0));
				writeDeleteMethod((Column) primaryKeys.get(0), dbConn);
				writeDeleteAllMethods((Column) primaryKeys.get(0), dbConn);
			//}
			writeCheckRecordExistsMethod((Column) primaryKeys.get(0), uniqueKeys);
			writeSetupMethod(columns);
			writeComparatorMethod(columns);
			writePrintMethod((Column) primaryKeys.get(0));
			writeEqualsMethod((Column) primaryKeys.get(0));
			writeFooterStuff();
			writer.close();

			writer = myFileHandler.openFile(jspListFileName);
			writeJSPListFile(columns, (Column) primaryKeys.get(0));
			writer.close();

			writer = myFileHandler.openFile(jspCreateFileName);
			writeJSPCreateFile(columns, (Column) primaryKeys.get(0));
			writer.close();
				
		} catch (IOException e) {
                	System.out.println("got IOException");
		} catch (SQLException e) {
                	System.out.println("got SQLException");
		}
	}


	public class Column {
		private int user_chip_id;
		private String column_name;
		private String column_name_initcap;
		private String data_type;
		private String data_type_initcap;
	
		public Column() {
			log = Logger.getRootLogger();
		}

		public void setUser_chip_id(int inInt) {
			user_chip_id = inInt;
		}

		public int getUser_chip_id() {
			return user_chip_id;
		}
	
		public void setColumn_name(String inString) {
			this.column_name = inString;
		}

		public String getColumn_name() {
			return this.column_name;
		}

		public void setColumn_name_initcap(String inString) {
			this.column_name_initcap = inString;
		}

		public String getColumn_name_initcap() {
			return this.column_name_initcap;
		}

		public void setData_type(String inString) {
			this.data_type = inString;
		}

		public String getData_type() {
			return this.data_type;
		}

		public void setData_type_initcap(String inString) {
			this.data_type_initcap = inString;
		}

		public String getData_type_initcap() {
			return this.data_type_initcap;
		}

		public String toString() {
			return "This Column has name = " + column_name +
			", dataType = " + data_type;
		}

		public void print() {
			log.debug(toString());
		}

	}

	public static void main(String[] args) {
        	System.out.println("In CodeGenerator");

        	dbConn = new CodeGenerator().getConnection(new File(propertiesFileName));

        	//CodeGenerator myCodeGenerator = new CodeGenerator();


		// *** Tables should have initial caps and be singular ***
		//String [] tables = new String[] {"Function", "Argument"};
		String [] tables = new String[] {
			/*
			"Experimentdetail",
			"Experiment_protocol",
			"Ebi_array_design",
			"Public_experiment"
			*/
			"Download"
			};
		String [] nonPluralTables = new String[] {
/*
			"Tctlvcb",
			"Texpfctr",
			"Texprmnt",
			"Texprtyp",
			"Tpublic",
			"Tsubmis",
			"Tprotcls",
			"Tardesin",
			"Tarray",
			"Tauthor",
			"Textract",
			"Tfctrval",
			"Tfile",
			"Thybrid",
			"Tlabel",
			"Tlabhyb",
			"Tntxsyn",
			"Tothers",
			"Tpooled",
			"Tprotdts",
			"Tsample",
			"Tsubmtr"
*/
			};

		for (int i=0; i<tables.length; i++) {
        		new CodeGenerator(tables[i]).createFiles();
		}
		for (int i=0; i<nonPluralTables.length; i++) {
        		new CodeGenerator(nonPluralTables[i], "nonPlural").createFiles();
		}
	}
}

