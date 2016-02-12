package edu.ucdenver.ccp.PhenoGen.data;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;
import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.Results;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import javax.sql.DataSource;
import org.apache.log4j.Logger;

/**
 * Class for handling data in the parameter_values and parameter_groups tables. 
 *  @author  Cheryl Hornbaker
 */

public class ParameterValue implements Comparable{
	private int parameter_group_id;
	private int parameter_value_id;
	private String category;
	private String parameter;
	private String value;
	private String create_date_as_string;
	private java.sql.Timestamp create_date;
	private int dataset_id;
	private int version;
	//private int created_by_user_id;

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();

	public ParameterValue() {
		log = Logger.getRootLogger();
	}

	public ParameterValue (String parameter) {
		log = Logger.getRootLogger();
		this.setParameter(parameter);
	}

	public void setParameter_group_id(int inInt) {
		this.parameter_group_id = inInt;
	}

	public int getParameter_group_id() {
		return parameter_group_id;
	}

	public void setParameter_value_id(int inInt) {
		this.parameter_value_id = inInt;
	}

	public int getParameter_value_id() {
		return parameter_value_id;
	}
	
	public void setCategory(String inString) {
		this.category= inString;
	}

	public String getCategory() {
		return category; 
	}

	public void setParameter(String inString) {
		this.parameter= inString;
	}

	public String getParameter() {
		return parameter; 
	}

	public void setValue(String inString) {
		this.value = inString;
	}

	public String getValue() {
		return value; 
	}

	public void setCreate_date(java.sql.Timestamp inTimestamp) {
		this.create_date = inTimestamp;
	}

	/**
	 * Sets the creation date for this instantiation, so that all records have the same date and time.
	 */
	public void setCreate_date() {
		this.create_date = new java.sql.Timestamp(System.currentTimeMillis());
		//log.debug("this.create_date just got set to "+this.create_date.toString());
	}

	public java.sql.Timestamp getCreate_date() {
		return create_date; 
	}

	public void setCreate_date_as_string(String inString) {
		this.create_date_as_string = inString;
	}

	public String getCreate_date_as_string() {
		return create_date_as_string;
	}

	public void setDataset_id(int inInt) {
		this.dataset_id = inInt;
	}

	public int getDataset_id() {
		return dataset_id;
	}

	public void setVersion(int inInt) {
		this.version = inInt;
	}

	public int getVersion() {
		return version;
	}

/*
  public void setCreated_by_user_id(int inInt) {
    this.created_by_user_id = inInt;
  }

  public int getCreated_by_user_id() {
    return created_by_user_id;
  }
*/



	/**
	 * Copies the master parameters to a new parameter group so that all parameters are in the same group.  The new 
	 * parameter values are created with the same create_date as the master parameters.
	 * @param dataset_id	the id of the dataset
	 * @param version	the version number of the dataset
	 * @param conn	the database connection
	 * @return            the identifier of the new parameter group 
	 * @throws            SQLException if a database error occurs
	 */
	public int copyMasterParameters (int dataset_id, int version, Connection conn) throws SQLException {

		log.info("in copyMasterParameters");
		//
		// first create a new parameter group that is NOT a master
		//
		int parameter_group_id = createParameterGroup(dataset_id, version, 0, conn);
		log.debug ("parameter_group_id = "+parameter_group_id);

        	String getMasterGroupID =
                	"select parameter_group_id "+
			"from parameter_groups "+
			"where master = 1 "+
			"and dataset_id = ? "+
			"and version = ?";

        	String query =
                	"insert into parameter_values "+
                	"(parameter_value_id, parameter_group_id, category, parameter, value, create_date) "+
			"select parameter_values_seq.nextval, "+ 
			parameter_group_id + 
			", category, parameter, value, create_date "+
			"from parameter_values "+
			"where parameter_group_id = ? "+
			"and category not like 'Phenotype%'";

		log.debug ("getmasterGroupID query = "+getMasterGroupID);
		log.debug ("query = "+query);
		// 
		// get the group ID of the master parameter group
		// for this dataset
		//

                Results myResults = new Results(getMasterGroupID, new Object[] {dataset_id, version}, conn);

                int masterGroupID = myResults.getIntValueFromFirstRow();

                masterGroupID = (masterGroupID == -99 ? 0 : masterGroupID);

		log.debug ("masterGroupID = "+masterGroupID);

                myResults.close();

		// 
		// insert a new set of parameters for this particular
		// analysis
		//
        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, masterGroupID); 
                pstmt.executeUpdate();
		log.debug("just exectued update");

		pstmt.close();

		return parameter_group_id;
	}


	/**
	 * Copies the parameters into a new parameter grouping.
	 * @param oldParameterGroupID     the parameter_group_id that contains the values 
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 */
	public int copyParameters (int oldParameterGroupID, Connection conn) throws SQLException {

		log.info("in copyParameters. oldParameterGroupID = " + oldParameterGroupID);

		int newParameterGroupID = myDbUtils.getUniqueID("parameter_groups_seq", conn);

        	String query =
                	"insert into parameter_groups "+
                	"(parameter_group_id, dataset_id, version, master, create_date) "+
			"select ?, "+ 
			"dataset_id, version, 0, sysdate "+
			"from parameter_groups "+
			"where parameter_group_id = ?";

		//log.debug("query = "+query);

        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, newParameterGroupID); 
		pstmt.setInt(2, oldParameterGroupID); 

                pstmt.executeUpdate();

        	query =
                	"insert into parameter_values "+
                	"(parameter_value_id, parameter_group_id, category, parameter, value, create_date) "+
			"select parameter_values_seq.nextval, "+ 
			"?, "+
			"category, parameter, value, create_date "+
			"from parameter_values "+
			"where parameter_group_id = ?";

		//log.debug("query2 = "+query);
        	
		pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, newParameterGroupID); 
                pstmt.setInt(2, oldParameterGroupID); 
                pstmt.executeUpdate();

		pstmt.close();
		
		return newParameterGroupID;

	}


	/**
	 * Copies the parameters used when doing a correlation analysis.  
	 * @param phenotypeParameterGroupID     the parameter_group_id that contains the phenotype values used in this analysis
	 * @param parameterGroupID     the parameter_group_id that contains the normalization, filter, 
	 *				and statistics parameters used in this analysis
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 */
	public void copyCorrelationParameters (int phenotypeParameterGroupID, int parameterGroupID, Connection conn) throws SQLException {

		log.info("in copyCorrelationParameters. phenotypeParameterGroupID = " + phenotypeParameterGroupID + 
				", parameterGroupID = "+parameterGroupID);

        	String query =
                	"insert into parameter_values "+
                	"(parameter_value_id, parameter_group_id, category, parameter, value, create_date) "+
			"select parameter_values_seq.nextval, "+ 
			parameterGroupID + 
			", category, parameter, value, create_date "+
			"from parameter_values "+
			"where parameter_group_id = ? "+
			"and category like 'Phenotype%' "+
			"and parameter != 'User ID'";

		//log.debug("query = "+query);
		// 
		// insert a new set of parameters for this particular
		// analysis
		//
        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, phenotypeParameterGroupID); 
                pstmt.executeUpdate();

		pstmt.close();

	}


	/**
	 * Creates a new row in the parameter_groups table.
	 * @param conn	the database connection
	 * @return            the identifier of the parameter group 
	 * @throws            SQLException if a database error occurs
	 */
	public int createParameterGroup (Connection conn) throws SQLException {

		log.info("In ParameterValue.createParameterGroup.");

		parameter_group_id = myDbUtils.getUniqueID("parameter_groups_seq", conn);

        	String query =
                	"insert into parameter_groups "+
                	"(parameter_group_id, create_date) values "+
                	"(?, ?)";

                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, parameter_group_id); 
                pstmt.setTimestamp(2, now);

                pstmt.executeUpdate();
		pstmt.close();

		return parameter_group_id;
	}

	/**
	 * Creates a new row in the parameter_groups table.
	 * @param dataset_id	the id of the dataset
	 * @param version	the version number of the dataset
	 * @param master	1 if this is a master record, otherwise 0
	 * @param conn	the database connection
	 * @return            the identifier of the parameter group 
	 * @throws            SQLException if a database error occurs
	 */
	public int createParameterGroup (int dataset_id, int version, int master, Connection conn) throws SQLException {
		log.debug("in createParameterGroup");

		parameter_group_id = myDbUtils.getUniqueID("parameter_groups_seq", conn);

        	String query =
                	"insert into parameter_groups "+
                	"(parameter_group_id, dataset_id, version, master, create_date) values "+
                	"(?, ?, ?, ?, ?)";


                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, parameter_group_id); 
                pstmt.setInt(2, dataset_id); 
                pstmt.setInt(3, version); 
                pstmt.setInt(4, master); 
                pstmt.setTimestamp(5, now);

                pstmt.executeUpdate();
		pstmt.close();

		log.info("In ParameterValue.createParameterGroup. dataset_id = " + dataset_id + ", version = "+version + ", PGID = "+parameter_group_id);

		return parameter_group_id;
	}

	/** Delete parameter_values records for a particular parameterGroup that contains phenotype data.  This also 
	 * removes records for gene lists that were created using this phenotype data. 
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
	 * @throws            SQLException if a database error occurs
	 */
	public void deletePhenotypeValues(int parameterGroupID, Connection conn) throws SQLException {

		deleteParameterValues(parameterGroupID, conn);

        	String query =
                	"delete from parameter_values "+
			"where category = 'Phenotype Data' "+
			"and parameter = 'Parameter Group ID' "+
			"and value = ?";
	
		log.info("In deletePhenotypeValues.  parameterGroupID = "+ parameterGroupID); 

        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
		pstmt.setString(1, Integer.toString(parameterGroupID));
        	pstmt.executeUpdate();

		pstmt.close();
    
	}


	/** Delete parameter_values records for a particular parameterGroup. 
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
	 * @throws            SQLException if a database error occurs
	 */
	public void deleteParameterValues(int parameterGroupID, Connection conn) throws SQLException {

        	String query =
                	"delete from parameter_values "+
			"where parameter_group_id = ?";
	
		log.info("In deleteParameterValues.  parameterGroupID = "+ parameterGroupID); 

        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, parameterGroupID);
        	pstmt.executeUpdate();

        	query =
                	"delete from parameter_groups "+
			"where parameter_group_id = ?";

		pstmt.setInt(1, parameterGroupID);

        	pstmt.executeUpdate();
		conn.commit();
		pstmt.close();
	}


	/** Delete parameter_values records for a particular category. 
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param category     the category of values to delete
	 * @param conn     the database connection 
	 * @throws            SQLException if a database error occurs
	 */
	public void deleteParameterValuesByCategory (int parameterGroupID, String category, Connection conn) throws SQLException {
	
		log.info("In deleteParameterValuesByCategory.  parameterGroupID = "+
				parameterGroupID + 
				", category = " +
				category);

        	String query =
                	"delete from parameter_values "+
			"where parameter_group_id = ? "+
			"and category like ?";

        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, parameterGroupID);
		pstmt.setString(2, category);

        	pstmt.executeUpdate();
		pstmt.close();
	}

	/** Remove parameter_values for a statistics test.
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
	 * @throws            SQLException if a database error occurs
	 */
	public void deleteStatisticsParameterValues (int parameterGroupID, Connection conn) throws SQLException {

		log.debug("In deleteStatisticsParameterValues.  parameterGroupID = "+ parameterGroupID);

		String query =
			"delete from parameter_values "+
			"where parameter_group_id = ? "+
			"and category like 'Statistical Method'";

		//log.debug("query = "+ query);
		PreparedStatement pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, parameterGroupID);

		pstmt.executeUpdate();
		pstmt.close();
  	}
  
	/** Remove parameter_values for a multiple test.
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
	 * @throws            SQLException if a database error occurs
	 */
	public void deleteMultipleTestParameterValues (int parameterGroupID, Connection conn) throws SQLException {

		log.debug("In deleteMultipleTestParameterValues.  parameterGroupID = "+ parameterGroupID);

		String query =
			"delete from parameter_values "+
			"where parameter_group_id = ? "+
			"and category like 'Multiple Test Method%'";
		//log.debug("query = "+ query);
 
		PreparedStatement pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, parameterGroupID);

		pstmt.executeUpdate();
		pstmt.close();
  	}
  
	/** Remove parameter_groups and their corresponding parameter_values records for 
	 * a particular dataset version.
	 * @param thisVersion	the DatasetVersion object
	 * @param conn     the database connection 
	 * @throws            SQLException if a database error occurs
	 */
	public void deleteParameterGroupsForDatasetVersion (Dataset.DatasetVersion thisVersion, Connection conn) throws SQLException {

		log.info("in deleteParameterGroupsForDatasetVersion");
		String[] queries = new String[2];

  		queries[0] =
			"delete from parameter_values pv "+
        		"where exists "+
				"(select parameter_group_id " +
				"from parameter_groups pg " +
				"where dataset_id = ? " +
				"and version = ? " +
				"and pg.parameter_group_id = pv.parameter_group_id)";
  	
		queries[1] =
			"delete from parameter_groups "+
        		"where dataset_id = ? " +
        		"and version = ?";

	
		for (String thisQuery : queries) {
  			PreparedStatement pstmt = conn.prepareStatement(thisQuery,
                            	ResultSet.TYPE_SCROLL_INSENSITIVE,
                            	ResultSet.CONCUR_UPDATABLE);
			pstmt.setInt(1, thisVersion.getDataset().getDataset_id());
			pstmt.setInt(2, thisVersion.getVersion());

                	pstmt.executeUpdate();
                	pstmt.close();
		}
	}  
  
	/**
	 * Creates a new row in the parameter_values table.  
	 * Prior to this, setCreate_date() should be called so that all rows have the same date and time stamp.
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 */
	public void createParameterValue(Connection conn) throws SQLException {

		int parameter_value_id = myDbUtils.getUniqueID("parameter_values_seq", conn);

        	String query =
                	"insert into parameter_values "+
                	"(parameter_value_id, parameter_group_id, category, parameter, value, create_date) values "+
                	"(?, ?, ?, ?, ?, ?)";

		//log.debug("In createParameterValue.  Parameter = "+
		//		this.getParameter() + 
		//		", Value = " +
		//		this.getValue());

        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, parameter_value_id);
                pstmt.setInt(2, this.getParameter_group_id());
                pstmt.setString(3, this.getCategory());
                pstmt.setString(4, this.getParameter());
                pstmt.setString(5, this.getValue());
                pstmt.setTimestamp(6, this.getCreate_date());

                pstmt.executeUpdate();
		pstmt.close();
	}

	/**
	 * Gets all the parameter groups that contain parameters used during cluster analyses for a user.
	 * @param userID	the id of the user or -99 for all users
	 * @param dataset_id	the id of the dataset or -99 for all datasets
	 * @param datasetVersion	the version of the dataset or -99 for all versions
	 * @param conn	the database connection
	 * @return          an array of ParameterValues
	 * @throws            SQLException if a database error occurs
	 */
	public ParameterValue[] getAllClusterParameterGroups (int userID, int dataset_id, int datasetVersion, Connection conn) throws SQLException {

		log.info("In getAllClusterParameterGroups. userID = " + userID + ", dataset_id = "+dataset_id + ", version = "+datasetVersion);
        	String query =
			"select -99, "+
			"pg.parameter_group_id, "+
			"pv.category, "+
			"pv.parameter, "+
			"pv.value, "+
			"to_char(pg.create_date, 'mm/dd/yyyy hh12:mi AM'), "+
			"pg.dataset_id, "+
			"pg.version "+
			"from parameter_groups pg, "+ 
			"parameter_values pv, "+ 
			"datasets e "+
			"where pg.parameter_group_id = pv.parameter_group_id "+ 
			"and exists "+
			"        (select 'x' "+
			"        from parameter_values pv2 "+
			"        where pv2.parameter_group_id = pv.parameter_group_id "+
			"        and pv2.category = 'Cluster') "+
			"and pv.category = 'Statistical Method' "+ 
			"and pg.dataset_id = e.dataset_id ";
			if (userID != -99) {
				query = query + "and (e.created_by_user_id = ? ";
			} else {
				query = query + "and (1 = ? "; 
			}
			query = query + 
			" 	or e.created_by_user_id = "+
			"	(select user_id "+
			"	from users "+
			"	where user_name = 'public')) ";
			if (dataset_id != -99) {
				query = query + " and e.dataset_id = ? ";
				if (datasetVersion != -99) {
					query = query + " and pg.version = ? ";
				}
			}
			query = query + 
			"group by "+
			"pg.parameter_group_id, "+
			"pv.category, "+
			"pv.parameter, "+
			"pv.value, "+
			"pg.create_date, "+
			"pg.dataset_id, "+
			"pg.version "+
			"order by pg.dataset_id, pg.version, pg.create_date"; 

		//log.debug("query = "+query);

		List<Object> parameterList = new ArrayList<Object>();

		if (userID != -99) {
			parameterList.add(userID);
		} else {
			parameterList.add(1);
		}
		if (dataset_id != -99) {
			parameterList.add(dataset_id);
			if (datasetVersion != -99) {
				parameterList.add(datasetVersion);
			}
		}

		Object[] parameters = (Object[]) parameterList.toArray(new Object[parameterList.size()]);
                Results myResults = new Results(query, parameters, conn); 
        	List<ParameterValue> myParameterValueList = new ArrayList<ParameterValue>();
                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        ParameterValue newParameterValue = setupParameterValue(dataRow);
                        myParameterValueList.add(newParameterValue);
                }

		myResults.close();

		ParameterValue[] myParameterValueArray = 
			(ParameterValue[]) myParameterValueList.toArray(new ParameterValue[myParameterValueList.size()]);

        	return myParameterValueArray;
	}

	/**
	 * Gets the method used in normalizing the dataset version.
	 * @param dataset_id	the id of the dataset
	 * @param version	the version number of the dataset
	 * @param conn	the database connection
	 * @return            the method used
	 * @throws            SQLException if a database error occurs
	 */
	public String getNormalizationMethod (int dataset_id, int version, Connection conn) throws SQLException {
		log.info("In getNormalizationMethod. dataset_id = " + dataset_id + ", and version = "+version);

		ParameterValue[] myNormalizationParameters = getNormalizationParameters(dataset_id, version, conn);
		for (ParameterValue thisParameterValue: myNormalizationParameters) {
			if (thisParameterValue.getParameter().indexOf("Normalization Method") >= 0) {
				return thisParameterValue.getValue();
			} 
		}
		return "Unknown";
	}
	
	/**
	 * Gets the probeMask parameter used in normalizing the dataset version.
	 * @param dataset_id	the id of the dataset
	 * @param version	the version number of the dataset
	 * @param conn	the database connection
	 * @return            the probeMask parameter used in normalizing Affymetrix datasets
	 * @throws            SQLException if a database error occurs
	 */
	public String getProbeMaskParameter (int dataset_id, int version, Connection conn) throws SQLException {
		log.info("In getProbeMaskParameter. dataset_id = " + dataset_id + ", and version = "+version);

		ParameterValue[] myNormalizationParameters = getNormalizationParameters(dataset_id, version, conn);
		for (ParameterValue thisParameterValue: myNormalizationParameters) {
			if (thisParameterValue.getParameter().indexOf("Probe Mask Applied") >= 0) {
				return thisParameterValue.getValue();
			} 
		}
		return "F";
	}
        
        /**
	 * Gets the AnnotationLevel parameter used in normalizing the dataset version.
	 * @param dataset_id	the id of the dataset
	 * @param version	the version number of the dataset
	 * @param conn	the database connection
	 * @return            the AnnotationLevel parameter used in normalizing Affymetrix datasets
	 * @throws            SQLException if a database error occurs
	 */
	public String getAnnotationLevelParameter (int dataset_id, int version, Connection conn) throws SQLException {
		log.info("In getProbeMaskParameter. dataset_id = " + dataset_id + ", and version = "+version);

		ParameterValue[] myNormalizationParameters = getNormalizationParameters(dataset_id, version, conn);
		for (ParameterValue thisParameterValue: myNormalizationParameters) {
			if (thisParameterValue.getParameter().indexOf("Annotation Level") >= 0) {
				return thisParameterValue.getValue();
			} 
		}
		return "F";
	}
        
        /**
	 * Gets the AnalysisLevel parameter used in normalizing the dataset version.
	 * @param dataset_id	the id of the dataset
	 * @param version	the version number of the dataset
	 * @param conn	the database connection
	 * @return            the AnalysisLevel parameter used in normalizing Affymetrix datasets
	 * @throws            SQLException if a database error occurs
	 */
	public String getAnalysisLevelParameter (int dataset_id, int version, Connection conn) throws SQLException {
		log.info("In getProbeMaskParameter. dataset_id = " + dataset_id + ", and version = "+version);

		ParameterValue[] myNormalizationParameters = getNormalizationParameters(dataset_id, version, conn);
		for (ParameterValue thisParameterValue: myNormalizationParameters) {
			if (thisParameterValue.getParameter().indexOf("Analysis Level") >= 0) {
				return thisParameterValue.getValue();
			} 
		}
		return "F";
	}
	
	/**
	 * Gets the CodeLink parameter used in normalizing the dataset version.
	 * @param dataset_id	the id of the dataset
	 * @param version	the version number of the dataset
	 * @param conn	the database connection
	 * @return            the first parameter used in normalizing CodeLink datasets
	 * @throws            SQLException if a database error occurs
	 */
	public String getCodeLinkNormalizationParameter (int dataset_id, int version, Connection conn) throws SQLException {
		log.info("In getCodeLinkNormalizationParameter. dataset_id = " + dataset_id + ", and version = "+version);

		ParameterValue[] myNormalizationParameters = getNormalizationParameters(dataset_id, version, conn);
		for (ParameterValue thisParameterValue: myNormalizationParameters) {
			if (thisParameterValue.getParameter().indexOf("CodeLink Normalization Parameter 1") >= 0) {
				return thisParameterValue.getValue();
			} 
		}
		return "Unknown";
	}
	
	/**
	 * Gets the Annotation Level parameter used in normalizing the dataset version.
	 * @param dataset_id	the id of the dataset
	 * @param version	the version number of the dataset
	 * @param conn	the database connection
	 * @return            the annotation level parameter used in normalizing Exon datasets
	 * @throws            SQLException if a database error occurs
	 */
	public String getAnnotationLevelNormalizationParameter (int dataset_id, int version, Connection conn) throws SQLException {
		log.info("In getAnnotationLevelNormalizationParameter. dataset_id = " + dataset_id + ", and version = "+version);

		ParameterValue[] myNormalizationParameters = getNormalizationParameters(dataset_id, version, conn);
		for (ParameterValue thisParameterValue: myNormalizationParameters) {
			if (thisParameterValue.getParameter().indexOf("Annotation Level") >= 0) {
				return thisParameterValue.getValue();
			} 
		}
		return "Unknown";
	}
	
	/**
	 * Gets the Analysis Level parameter used in normalizing the dataset version.
	 * @param dataset_id	the id of the dataset
	 * @param version	the version number of the dataset
	 * @param conn	the database connection
	 * @return            the analysis level parameter used in normalizing Exon datasets
	 * @throws            SQLException if a database error occurs
	 */
	public String getAnalysisLevelNormalizationParameter (int dataset_id, int version, Connection conn) throws SQLException {
		log.info("In getAnalysisLevelNormalizationParameter. dataset_id = " + dataset_id + ", and version = "+version);

		ParameterValue[] myNormalizationParameters = getNormalizationParameters(dataset_id, version, conn);
		for (ParameterValue thisParameterValue: myNormalizationParameters) {
			if (thisParameterValue.getParameter().indexOf("Analysis Level") >= 0) {
				return thisParameterValue.getValue();
			} 
		}
		return "Unknown";
	}
	
	/**
	 * Gets the parameters used in normalizing the dataset version.
	 * @param dataset_id	the id of the dataset
	 * @param version	the version number of the dataset
	 * @param conn	the database connection
	 * @return            an array of ParameterValue objects 
	 * @throws            SQLException if a database error occurs
	 */
	public ParameterValue[] getNormalizationParameters (int dataset_id, int version, Connection conn) throws SQLException {
	
		String query =
    			"select pv.parameter_value_id, "+
			"pv.parameter_group_id, "+
			"pv.category, "+
			"pv.parameter, "+
			"pv.value, "+
			"to_char(pv.create_date, 'mm/dd/yyyy hh12:mi AM'), "+
			"pg.dataset_id, "+
			"pg.version "+
			"from parameter_values pv, "+
			"parameter_groups pg "+
			"where pv.category like 'Data Normalization%' "+
			"and pg.dataset_id = ? "+
			"and pg.version = ? "+
			"and master = 1 "+
			"and pg.parameter_group_id = pv.parameter_group_id "+ 
			"order by pv.parameter"; 

        	List<ParameterValue> myParameterValueList = new ArrayList<ParameterValue>();

		log.info("In getNormalizationParameters");
		//log.debug("query = "+ query);

                Results myResults = new Results(query, new Object[] {dataset_id, version}, conn);
                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        ParameterValue newParameterValue = setupParameterValue(dataRow);
                        myParameterValueList.add(newParameterValue);
                }

		myResults.close();

		ParameterValue[] myParameterValueArray = (ParameterValue[]) myParameterValueList.toArray(new ParameterValue[myParameterValueList.size()]);

		log.debug("there are "+myParameterValueArray.length + " normalization parameters for this dataset");
        	return myParameterValueArray;
  	}

	/**
	 * Gets the filters used by parameter group ID.
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
	 * @return            An array of ParameterValue objects
	 * @throws            SQLException if a database error occurs
	 */
	public ParameterValue[] getFiltersUsed (int parameterGroupID, Connection conn) throws SQLException {
  		log.info("in getFiltersUsed");
  		log.debug("parameterGroupID = " + parameterGroupID);
  	
  		String query = 
  		
  			"select distinct pv.parameter_value_id, "+
				"parameter_group_id, "+
				"decode(pv.category, 'AbsoluteCallFilter', 'Absolute Call Filter', "+
						"'MAS5AbsoluteCallFilter', 'MAS5 Absolute Call Filter', "+
						"'DABGPValueFilter', 'DABG P-Value Filter', "+
						"'AffyControlGenesFilter', 'Affy Control Genes Filter', "+
						"'CodeLinkCallFilter', 'Codelink Call Filter', "+
						"'CodeLinkControlGenesFilter', 'Codelink Control Genes Filter', "+
						"'CoefficientVariationFilter', 'Coefficient Variation Filter', "+
						"'GeneSpringCallFilter', 'Gene Spring Call Filter', "+
						"'MedianFilter', 'Median Filter', "+
						"'GeneListFilter', 'Gene List Filter', "+
						"'VariationFilter', 'Variation Filter', "+
						"'FoldChangeFilter', 'Fold Change Filter', "+
						"pv.category), "+ 
				"decode(pv.parameter, 'Parameter 1 is Null', ' ', "+ 
						"'Parameter 2 is Null', ' ', "+ 
						"pv.parameter), "+
				"decode(pv.value, 'Null', ' ', "+
				"	pv.value), "+ 
				"to_char(pv.create_date, 'mm/dd/yyyy hh12:mi AM'), "+
				"pv.value, "+
				"pg.dataset_id, "+
				"pg.version "+
				"from parameter_values pv, "+ 
				"parameter_groups pg "+
				"where pv.parameter_group_id = ? "+ 
				"and pv.parameter_group_id = pg.parameter_group_id "+ 
				"and pv.category like '%Filter' "+
				"order by pv.create_date, "+
				"pv.value, "+
				"pv.parameter_value_id";
  		
        	List<ParameterValue> myParameterValueList = new ArrayList<ParameterValue>();

		//log.debug("query = "+ query);

                Results myResults = new Results(query, parameterGroupID, conn);
                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        ParameterValue newParameterValue = setupParameterValue(dataRow);
                        myParameterValueList.add(newParameterValue);
                }

		myResults.close();

		ParameterValue[] myParameterValueArray = (ParameterValue[]) myParameterValueList.toArray(new ParameterValue[myParameterValueList.size()]);

		return myParameterValueArray;
	}
  
        
        /**
	 * Gets the parameters used for creating a gene list.  
	 * It first gets the normalization, filters, and statistical test parameters
	 * and then unions back to parameter_values to get the phenotype values used in a correlation analysis.
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
	 * @return            An array of ParameterValue objects
	 * @throws	SQLException if a database error occurs
	 */
	public ParameterValue[] getGeneListParameters (int parameterGroupID, DataSource pool) throws SQLException {
  		log.info("in getGeneListParameters. parameterGroupID = " + parameterGroupID);
  	
  		String query = 
  			"select distinct pv.parameter_value_id, "+
				"pv.parameter_group_id, "+
				"decode(pv.category, 'Statistical Method', 'Statistical Test', "+
						"'AbsoluteCallFilter', 'Absolute Call Filter', "+
						"'MAS5AbsoluteCallFilter', 'MAS5 Absolute Call Filter', "+
						"'DABGPValueFilter', 'DABG P-Value Filter', "+
						"'AffyControlGenesFilter', 'Affy Control Genes Filter', "+
						"'CodeLinkCallFilter', 'Codelink Call Filter', "+
						"'CodeLinkControlGenesFilter', 'Codelink Control Genes Filter', "+
						"'CoefficientVariationFilter', 'Coefficient Variation Filter', "+
						"'GeneSpringCallFilter', 'Gene Spring Call Filter', "+
						"'MedianFilter', 'Median Filter', "+
						"'GeneListFilter', 'Gene List Filter', "+
						"'VariationFilter', 'Variation Filter', "+
						"'FoldChangeFilter', 'Fold Change Filter', "+
						"pv.category), "+ 
				"decode(pv.parameter, 'Parameter 1 is Null', ' ', "+ 
						"'Parameter 2 is Null', ' ', "+ 
						"pv.parameter), "+
				"decode(pv.value, 'Null', ' ', "+
				"	pv.value), "+ 
				"to_char(pv.create_date, 'mm/dd/yyyy hh12:mi AM'), "+
				"pg.dataset_id, "+
				"pg.version, "+
				"pv.value "+
				"from parameter_values pv, "+ 
				"parameter_groups pg "+
				"where pv.parameter_group_id = ? "+ 
				"and pv.parameter_group_id = pg.parameter_group_id "+
				"and pv.category != 'Data Normalization' "+ 
				"and pv.parameter != 'User ID' "+
				"and pv.parameter != 'Parameter Group ID' "+
				"union "+
				"select pv.parameter_value_id, "+
				"pv.parameter_group_id, "+
				"pv.category, "+
				"pv.parameter, "+
				"pv.value, "+
				"to_char(pv.create_date, 'mm/dd/yyyy hh12:mi AM'), "+
				"pg.dataset_id, "+
				"pg.version, "+
				"pv.value "+
				"from parameter_values pv, "+
				"parameter_values pv2, "+
				"parameter_groups pg "+
				"where pv.parameter_group_id = pv2.value "+
				"and pv.parameter_group_id = pg.parameter_group_id "+
				"and pv2.parameter_group_id = ? "+
				"and pv2.parameter = 'Parameter Group ID' "+
				"and pv.category = 'Phenotype Data' "+
				"and pv.parameter != 'User ID' "+
				"union "+
				"select pv.parameter_value_id, "+
				"pv.parameter_group_id, "+
				"pv.category, "+
				"grps.group_name parameter, "+
				"pv.value, "+
				"to_char(pv.create_date, 'mm/dd/yyyy hh12:mi AM'), "+
				"pg.dataset_id, "+
				"pg.version, "+
				"pv.value "+
				"from parameter_values pv, "+
				"parameter_groups pg, "+
				"parameter_values pv2, "+
				"groups grps, gene_lists gl, dataset_versions dv "+
				"where pv.parameter_group_id = pv2.value "+
				"and pv.parameter_group_id = pg.parameter_group_id "+
				"and gl.parameter_group_id = pv2.parameter_group_id "+
				"and gl.dataset_id = dv.dataset_id "+
				"and gl.version = dv.version "+
				"and dv.grouping_id = grps.grouping_id "+
				"and pv2.parameter_group_id = ? "+
				"and pv.parameter = to_char(grps.group_number) "+
				"and pv2.category = 'Phenotype Data' "+
				"and pv2.parameter = 'Parameter Group ID' "+
				"and pv.category = 'Phenotype Group Value' "+
				"order by 2, "+ //parameter_group_id
				"3, "+ // category
				"4, "+ // parameter
				"9, "+ // value
				"1";   // parameter_value_id
  		
        	List<ParameterValue> myParameterValueList = new ArrayList<ParameterValue>();

		//log.debug("query = "+ query);
                Connection conn=null;
                try{
                    conn=pool.getConnection();
                    Results myResults = new Results(query, new Object[] {parameterGroupID, parameterGroupID, parameterGroupID}, conn);
                    String[] dataRow;

                    while ((dataRow = myResults.getNextRow()) != null) {
                            ParameterValue newParameterValue = setupParameterValue(dataRow);
                            myParameterValueList.add(newParameterValue);
                    }

                    myResults.close();
                    conn.close();
                }catch(SQLException er){
                    throw er;
                }finally{
                    if(conn!=null && !conn.isClosed()){
                        try{
                            conn.close();
                            conn=null;
                        }catch(SQLException e){}
                    }
                }

		ParameterValue[] myParameterValueArray = (ParameterValue[]) myParameterValueList.toArray(new ParameterValue[myParameterValueList.size()]);

		return myParameterValueArray;
	}
        
	/**
	 * Gets the parameters used for creating a gene list.  
	 * It first gets the normalization, filters, and statistical test parameters
	 * and then unions back to parameter_values to get the phenotype values used in a correlation analysis.
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
	 * @return            An array of ParameterValue objects
	 * @throws	SQLException if a database error occurs
	 */
	public ParameterValue[] getGeneListParameters (int parameterGroupID, Connection conn) throws SQLException {
  		log.info("in getGeneListParameters. parameterGroupID = " + parameterGroupID);
  	
  		String query = 
  			"select distinct pv.parameter_value_id, "+
				"pv.parameter_group_id, "+
				"decode(pv.category, 'Statistical Method', 'Statistical Test', "+
						"'AbsoluteCallFilter', 'Absolute Call Filter', "+
						"'MAS5AbsoluteCallFilter', 'MAS5 Absolute Call Filter', "+
						"'DABGPValueFilter', 'DABG P-Value Filter', "+
						"'AffyControlGenesFilter', 'Affy Control Genes Filter', "+
						"'CodeLinkCallFilter', 'Codelink Call Filter', "+
						"'CodeLinkControlGenesFilter', 'Codelink Control Genes Filter', "+
						"'CoefficientVariationFilter', 'Coefficient Variation Filter', "+
						"'GeneSpringCallFilter', 'Gene Spring Call Filter', "+
						"'MedianFilter', 'Median Filter', "+
						"'GeneListFilter', 'Gene List Filter', "+
						"'VariationFilter', 'Variation Filter', "+
						"'FoldChangeFilter', 'Fold Change Filter', "+
						"pv.category), "+ 
				"decode(pv.parameter, 'Parameter 1 is Null', ' ', "+ 
						"'Parameter 2 is Null', ' ', "+ 
						"pv.parameter), "+
				"decode(pv.value, 'Null', ' ', "+
				"	pv.value), "+ 
				"to_char(pv.create_date, 'mm/dd/yyyy hh12:mi AM'), "+
				"pg.dataset_id, "+
				"pg.version, "+
				"pv.value "+
				"from parameter_values pv, "+ 
				"parameter_groups pg "+
				"where pv.parameter_group_id = ? "+ 
				"and pv.parameter_group_id = pg.parameter_group_id "+
				"and pv.category != 'Data Normalization' "+ 
				"and pv.parameter != 'User ID' "+
				"and pv.parameter != 'Parameter Group ID' "+
				"union "+
				"select pv.parameter_value_id, "+
				"pv.parameter_group_id, "+
				"pv.category, "+
				"pv.parameter, "+
				"pv.value, "+
				"to_char(pv.create_date, 'mm/dd/yyyy hh12:mi AM'), "+
				"pg.dataset_id, "+
				"pg.version, "+
				"pv.value "+
				"from parameter_values pv, "+
				"parameter_values pv2, "+
				"parameter_groups pg "+
				"where pv.parameter_group_id = pv2.value "+
				"and pv.parameter_group_id = pg.parameter_group_id "+
				"and pv2.parameter_group_id = ? "+
				"and pv2.parameter = 'Parameter Group ID' "+
				"and pv.category = 'Phenotype Data' "+
				"and pv.parameter != 'User ID' "+
				"union "+
				"select pv.parameter_value_id, "+
				"pv.parameter_group_id, "+
				"pv.category, "+
				"grps.group_name parameter, "+
				"pv.value, "+
				"to_char(pv.create_date, 'mm/dd/yyyy hh12:mi AM'), "+
				"pg.dataset_id, "+
				"pg.version, "+
				"pv.value "+
				"from parameter_values pv, "+
				"parameter_groups pg, "+
				"parameter_values pv2, "+
				"groups grps, gene_lists gl, dataset_versions dv "+
				"where pv.parameter_group_id = pv2.value "+
				"and pv.parameter_group_id = pg.parameter_group_id "+
				"and gl.parameter_group_id = pv2.parameter_group_id "+
				"and gl.dataset_id = dv.dataset_id "+
				"and gl.version = dv.version "+
				"and dv.grouping_id = grps.grouping_id "+
				"and pv2.parameter_group_id = ? "+
				"and pv.parameter = to_char(grps.group_number) "+
				"and pv2.category = 'Phenotype Data' "+
				"and pv2.parameter = 'Parameter Group ID' "+
				"and pv.category = 'Phenotype Group Value' "+
				"order by 2, "+ //parameter_group_id
				"3, "+ // category
				"4, "+ // parameter
				"9, "+ // value
				"1";   // parameter_value_id
  		
        	List<ParameterValue> myParameterValueList = new ArrayList<ParameterValue>();

		//log.debug("query = "+ query);

                Results myResults = new Results(query, new Object[] {parameterGroupID, parameterGroupID, parameterGroupID}, conn);
                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        ParameterValue newParameterValue = setupParameterValue(dataRow);
                        myParameterValueList.add(newParameterValue);
                }

		myResults.close();

		ParameterValue[] myParameterValueArray = (ParameterValue[]) myParameterValueList.toArray(new ParameterValue[myParameterValueList.size()]);

		return myParameterValueArray;
	}
  
        
        /**
	 * Gets the method used for statistical analysis.
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
	 * @return	a string containing the method used
	 * @throws	SQLException if a database error occurs
	 */
	public String getStatisticalMethod (int parameterGroupID, DataSource pool) throws SQLException {
            Connection conn=null;
            String tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getStatisticalMethod(parameterGroupID,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
            return tmp;
	}
        
	/**
	 * Gets the method used for statistical analysis.
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
	 * @return	a string containing the method used
	 * @throws	SQLException if a database error occurs
	 */
	public String getStatisticalMethod (int parameterGroupID, Connection conn) throws SQLException {
  	
  		String query = 
	    		"select value "+ 
			"from parameter_values "+ 
			"where parameter_group_id = ? "+
			"and parameter = 'Method' "+
			"and category = 'Statistical Method'";

		log.debug("In getStatisticalMethod");
		//log.debug("query = "+ query);
	
                Results myResults = new Results(query, parameterGroupID, conn);

                String statMethod = myResults.getStringValueFromFirstRow();

                myResults.close();

		log.debug("statMethod = "+statMethod);
		return statMethod;
	}

        /**
	 * Gets the p-value used for this ANOVA test.
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
	 * @return	a string containing the p-value
	 * @throws	SQLException if a database error occurs
	 */
	public String getAnovaPValue (int parameterGroupID, DataSource pool) throws SQLException {
            Connection conn=null;
            String tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getAnovaPValue(parameterGroupID,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
            return tmp;
  		
	}
        
	/**
	 * Gets the p-value used for this ANOVA test.
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
	 * @return	a string containing the p-value
	 * @throws	SQLException if a database error occurs
	 */
	public String getAnovaPValue (int parameterGroupID, Connection conn) throws SQLException {
  	
  		String query = 
	    		"select value "+ 
			"from parameter_values "+ 
			"where parameter_group_id = ? "+
			"and parameter = 'P-value'";

		log.debug("In getAnovaPValue");
		//log.debug("query = "+ query);

                Results myResults = new Results(query, parameterGroupID, conn);

                String pValue = myResults.getStringValueFromFirstRow();
		if (pValue.equals("")) {
			pValue = "None";
		} else if (!pValue.equals("Model")) {
			pValue = "Contrast";
		}

		log.debug("pValue = " + pValue);
                myResults.close();

		return pValue;
	}

	/**
	 * Gets the number of the Group for the label passed in.
	 * @param dataset_id     the identifier of the dataset
	 * @param version     the version number of the dataset
	 * @param label     the label of the group
	 * @param conn     the database connection 
	 * @return	a string containing the group number
	 * @throws	SQLException if a database error occurs
	 */
	public String getGroupNumber (int dataset_id, int version, String label, Connection conn) throws SQLException {
  	
  		String query = 
                        "select grps.group_number "+
                        "from groups grps, dataset_versions dv "+
                        "where dv.dataset_id = ? "+
                        "and dv.version = ? "+
			"and dv.grouping_id = grps.grouping_id "+
                        "and grps.group_name = ?";

		log.debug("In getGroupNumber");
		//log.debug("query = "+ query);
	
                Results myResults = new Results(query, new Object[] {dataset_id, version, label}, conn);

                String groupNumber = myResults.getStringValueFromFirstRow();

                myResults.close();

		if (groupNumber.equals("")) {
			groupNumber = "None";
		}
		return groupNumber;
	}


	/**
	 * Gets the parameters used for all datasets for a user
	 * @param user_id     the identifier of the user
	 * @param conn     the database connection 
	 * @return            An array of ParameterValue objects
	 * @throws	SQLException if a database error occurs
	 */
	public ParameterValue[] getParameterValuesForAllDatasetsForUser (int user_id, Connection conn) throws SQLException {
  	
  		String query = 
	    		"select pv.parameter_value_id, "+ 
			"pv.parameter_group_id, "+
			"pv.category, "+
			"decode(pv.value, 'Null', ' ', pv.parameter), "+
			"decode(pv.value, 'Null', ' ', pv.value), "+
			"to_char(pv.create_date, 'mm/dd/yyyy hh12:mi AM'), "+
			"pg.dataset_id, "+
			"pg.version "+
			"from parameter_values pv, parameter_groups pg, datasets ds "+ 
			"where pg.dataset_id = ds.dataset_id "+
			"and pv.parameter_group_id = pg.parameter_group_id ";

			if (user_id != -99) {
				query = query +
				"and (ds.created_by_user_id = ? "+
				"or ds.created_by_user_id = "+
				"	(select user_id "+
				"	from users "+
				"	where user_name = 'public')) ";
			}
			query = query + "order by pv.category, pv.parameter";

        	List<ParameterValue> myParameterValueList = new ArrayList<ParameterValue>();

		//log.info("In getParameterValuesForAllDatasetsForUser");
		//log.debug("query for user_id = "+user_id + "  is " + query);
	
                Results myResults = (user_id != -99 ? new Results(query, new Object[] {user_id}, conn) :
							new Results(query, conn));
                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        ParameterValue newParameterValue = setupParameterValue(dataRow);
                        myParameterValueList.add(newParameterValue);
                }

		myResults.close();

		ParameterValue[] myParameterValueArray = (ParameterValue[]) myObjectHandler.getAsArray(myParameterValueList, ParameterValue.class);

        	return myParameterValueArray;
	}

	/**
	 * Gets the parameters used for a dataset version 
	 * @param datasetVersion	the DatasetVersion object
	 * @param conn     the database connection 
	 * @return            An array of ParameterValue objects
	 * @throws	SQLException if a database error occurs
	 */
	public ParameterValue[] getParameterValuesForDatasetVersion (Dataset.DatasetVersion datasetVersion, Connection conn) throws SQLException {
  	
  		String query = 
	    		"select pv.parameter_value_id, "+ 
			"pv.parameter_group_id, "+
			"pv.category, "+
			"decode(pv.value, 'Null', ' ', pv.parameter), "+
			"decode(pv.value, 'Null', ' ', pv.value), "+
			"to_char(pv.create_date, 'mm/dd/yyyy hh12:mi AM'), "+
			"pg.dataset_id, "+
			"pg.version "+
			"from parameter_values pv, parameter_groups pg "+ 
			"where pg.dataset_id = ? "+
			"and pg.version = ? "+
			"and pv.parameter_group_id = pg.parameter_group_id "+
			"order by pv.category, pv.parameter";

        	List<ParameterValue> myParameterValueList = new ArrayList<ParameterValue>();

		//log.info("In getParameterValuesForDatasetVersion");
		//log.debug("query for dataset_id = "+datasetVersion.getDataset().getDataset_id() + " and vsn = "+datasetVersion.getVersion()+ " is " + query);
	
                Results myResults = new Results(query, new Object[] {datasetVersion.getDataset().getDataset_id(), datasetVersion.getVersion()}, conn);
                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        ParameterValue newParameterValue = setupParameterValue(dataRow);
                        myParameterValueList.add(newParameterValue);
                }

		myResults.close();

		ParameterValue[] myParameterValueArray = (ParameterValue[]) myParameterValueList.toArray(new ParameterValue[myParameterValueList.size()]);

        	return myParameterValueArray;
	}

        
        /**
	 * Gets the parameters used by parameter group ID.
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param pool    the database pool 
	 * @return            An array of ParameterValue objects
	 * @throws	SQLException if a database error occurs
	 */
	public ParameterValue[] getParameterValues (int parameterGroupID, DataSource pool) throws SQLException {
            Connection conn=null;
            SQLException err=null;
            ParameterValue[] ret=new ParameterValue[0];
            try{
                conn=pool.getConnection();
                ret=getParameterValues(parameterGroupID,conn);
                conn.close();
            }catch(SQLException e){
                err=e;
            }finally{
                if (conn != null) {
                                 try { conn.close(); } catch (SQLException e) { ; }
                                 conn = null;
                                 if(err!=null){
                                     throw(err);
                                 }
                }
            }
            return ret;
        }
        
	/**
	 * Gets the parameters used by parameter group ID.
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
	 * @return            An array of ParameterValue objects
	 * @throws	SQLException if a database error occurs
	 */
	public ParameterValue[] getParameterValues (int parameterGroupID, Connection conn) throws SQLException {
  	
  		String query = 
	    		"select pv.parameter_value_id, "+ 
			"pv.parameter_group_id, "+
			"pv.category, "+
			"decode(value, 'Null', ' ', pv.parameter), "+
			"decode(value, 'Null', ' ', pv.value), "+
			"to_char(pv.create_date, 'mm/dd/yyyy hh12:mi AM'), "+
			"pg.dataset_id, "+
			"pg.version "+
			"from parameter_values pv, "+ 
			"parameter_groups pg "+
			"where pv.parameter_group_id = ? "+
			"and pv.parameter_group_id = pg.parameter_group_id "+
			"order by pv.category, pv.parameter";

        	List<ParameterValue> myParameterValueList = new ArrayList<ParameterValue>();

		//log.info("In getParameterValues");
		//log.debug("query = "+ query);
	
                Results myResults = new Results(query, parameterGroupID, conn);
                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        ParameterValue newParameterValue = setupParameterValue(dataRow);
                        myParameterValueList.add(newParameterValue);
                }

		myResults.close();

		ParameterValue[] myParameterValueArray = (ParameterValue[]) myParameterValueList.toArray(new ParameterValue[myParameterValueList.size()]);

        	return myParameterValueArray;
	}

	/**
	 * Gets the phenotype values stored for a particular user and grouping.  The DatasetVersion object that is passed contains the 
	 * grouping_id.
	 * @param userID     the identifier of the user 
	 * @param version     the DatasetVersion object
	 * @param conn     the database connection 
	 * @return      An array of Phenotype objects
	 * @throws	SQLException if a database error occurs
	 */
	public Phenotype[] getPhenotypeValuesForGrouping(int userID, Dataset.DatasetVersion version, Connection conn) throws SQLException {

		log.info("In getPhenotypeValuesForGrouping");

		Phenotype[] phenotypesForVersion = getPhenotypeValuesForDataset(userID, version.getDataset(), version.getGrouping_id(), conn);

		//log.debug("now there are "+phenotypesForVersion.size() + "phenotypes for this version");
		phenotypesForVersion = new Phenotype().sortPhenotypes(phenotypesForVersion, "name", "A");

        	return phenotypesForVersion;
	}

	/**
	 * Gets the phenotype values stored for a particular dataset and/or groupingID
	 * @param userID     the identifier of the user 
	 * @param ds     the Dataset object
	 * @param groupingID     the id of the grouping or -99 if all
	 * @param conn     the database connection 
	 * @return      An array of Phenotype objects
	 * @throws	SQLException if a database error occurs
	 */
	public Phenotype[] getPhenotypeValuesForDataset (int userID, Dataset ds, int groupingID, Connection conn) throws SQLException {
  	
		log.info("In getPhenotypeValuesForDataset. datasetID = "+ds.getDataset_id() + " and userID = "+userID + " and groupingID = "+groupingID);
		String groupingIDClause = (groupingID != -99 ? " and dv.grouping_id = " + groupingID : " ") + " ";	

  		String query = 
			"select pg.parameter_group_id, "+
			"dv.grouping_id, "+
			"pg.dataset_id, "+
			"pv.value, "+
			"pv_desc.value,  "+
			"pv_user.value "+
			"from parameter_values pv, "+
			"parameter_groups pg, "+
			"dataset_versions dv, "+
			"parameter_values pv_user, "+
			"parameter_values pv_desc "+
			"where pv.category = 'Phenotype Data' "+
			"and pv.parameter = 'Name' "+
			"and pv.parameter_group_id = pg.parameter_group_id  "+
			"and pv.parameter_group_id = pv_user.parameter_group_id "+
			"and pv.parameter_group_id = pv_desc.parameter_group_id "+
			"and pv_user.parameter = 'User ID' "+
			"and pv_desc.parameter = 'Description' "+
			"and pg.version = dv.version "+
			"and pg.dataset_id = dv.dataset_id "+
			"and pg.dataset_id = ? "+
			"and pv_user.value = ? "+
			groupingIDClause +
			"order by pg.parameter_group_id, pv.parameter";

  		String query2 = 
			"select pg.parameter_group_id, "+
			"pv.category, "+
			"grps.group_number, "+
			"grps.group_name, "+
			"grps.has_expression_data, "+
			"grps.has_genotype_data, "+
			"grps.grouping_id, "+
			"pv.value, "+
			"pv_user.value "+
			"from parameter_values pv,  "+
			"parameter_groups pg,  "+
			"groups grps,  "+
			"parameter_values pv_user, "+
			"dataset_versions dv  "+
			"where pv.category like 'Phenotype%'  "+
			"and pv.parameter != 'User ID'  "+
			"and pv.parameter_group_id = pg.parameter_group_id  "+
			"and pv.parameter_group_id = pv_user.parameter_group_id "+
			"and dv.grouping_id = grps.grouping_id  "+
			"and dv.dataset_id = pg.dataset_id  "+
			"and dv.version = pg.version  "+
			"and pv.parameter = to_char(grps.group_number)  "+
			"and pg.dataset_id = ? "+
			"and pv_user.parameter = 'User ID' "+
			"and pv_user.value = ? "+
			groupingIDClause +
			"order by pg.parameter_group_id, grps.group_number, pv.category";

		//log.debug("query = "+query);
		//log.debug("query2 = "+query2);
	
                Results myResults = new Results(query, new Object[] {ds.getDataset_id(), Integer.toString(userID)}, conn); 
                Results myResults2 = new Results(query2, new Object[] {ds.getDataset_id(), Integer.toString(userID)}, conn); 

                String[] dataRow;

		List<Phenotype> myPhenotypeList = new ArrayList<Phenotype>();
		Dataset myDataset = new Dataset();

                while ((dataRow = myResults.getNextRow()) != null) {
			Phenotype thisPhenotype = new Phenotype();
			thisPhenotype.setParameter_group_id(Integer.parseInt(dataRow[0]));
			thisPhenotype.setGrouping_id(Integer.parseInt(dataRow[1]));
			thisPhenotype.setDataset_id(Integer.parseInt(dataRow[2]));
			thisPhenotype.setName(dataRow[3]);
			thisPhenotype.setDescription(dataRow[4]);
			thisPhenotype.setUser_id(Integer.parseInt(dataRow[5]));
			myPhenotypeList.add(thisPhenotype);
		}
		//log.debug("myPhenotypeList contains "+ myPhenotypeList.size() + " entries");

                while ((dataRow = myResults2.getNextRow()) != null) {
			Phenotype thisPhenotype = myPhenotypeList.get(myPhenotypeList.indexOf(new Phenotype(Integer.parseInt(dataRow[0]))));
			Hashtable<Dataset.Group, Double> means = (thisPhenotype.getMeans() == null ?  
						new Hashtable<Dataset.Group, Double>() : thisPhenotype.getMeans());
			Hashtable<Dataset.Group, Double> variances = (thisPhenotype.getVariances() == null ?  
						new Hashtable<Dataset.Group, Double>() : thisPhenotype.getVariances());
			//log.debug("thisPhenotype paramGroupid = "+thisPhenotype.getParameter_group_id());
			if (dataRow[1].equals("Phenotype Group Value")) {
				Dataset.Group thisGroup = myDataset.new Group(Integer.parseInt(dataRow[2]));
				thisGroup.setGroup_name(dataRow[3]);
				thisGroup.setHas_expression_data(dataRow[4]);
				thisGroup.setHas_genotype_data(dataRow[5]);
				thisGroup.setGrouping_id(Integer.parseInt(dataRow[6]));
				means.put(thisGroup, Double.parseDouble(dataRow[7]));
			} else if (dataRow[1].equals("Phenotype Variance Value")) {
				Dataset.Group thisGroup = myDataset.new Group(Integer.parseInt(dataRow[2]));
				thisGroup.setGroup_name(dataRow[3]);
				thisGroup.setHas_expression_data(dataRow[4]);
				thisGroup.setHas_genotype_data(dataRow[5]);
				thisGroup.setGrouping_id(Integer.parseInt(dataRow[6]));
				variances.put(thisGroup, Double.parseDouble(dataRow[7]));
			}
			thisPhenotype.setMeans(means);
			thisPhenotype.setVariances(variances);
			//log.debug("thisPhenotype has "+ thisPhenotypeList.getMeans().size() + " means");
			//log.debug("thisPhenotype has "+ thisPhenotypeList.getVariances().size() + " variances");
                }

		myResults.close();
		myResults2.close();

                Phenotype[] phenotypeArray = (Phenotype[]) myPhenotypeList.toArray(new Phenotype[myPhenotypeList.size()]);
	        phenotypeArray = new Phenotype().countGroups(phenotypeArray);

        	return phenotypeArray;
	}

        
        /**
	 * Gets the phenotype values stored for a particular parameter group ID.
	 * @param parameterGroupID     the identifier of the parameter group 
	 * @param conn     the database connection 
	 * @return            A Phenotype object
	 * @throws	SQLException if a database error occurs
	 */
	public ParameterValue.Phenotype getPhenotypeValuesForParameterGroupID(int parameterGroupID, DataSource pool) throws SQLException {
  	
  		String query = 
                        "select pv.parameter, "+
                        "pv.value, "+
			"pg.dataset_id "+
                        "from parameter_values pv, "+
			"parameter_groups pg "+
                        "where pv.category = 'Phenotype Data' "+
			"and pv.parameter != 'User ID' "+
			"and pv.parameter_group_id = pg.parameter_group_id "+
			"and pv.parameter_group_id = ? "+
                        "order by pv.parameter";   

  		String query2 = 
                        "select pv.category, "+
                        "grps.group_number, "+
                        "grps.group_name, "+
                        "grps.has_expression_data, "+
                        "grps.has_genotype_data, "+
			"grps.grouping_id, "+
                        "pv.value "+
                        "from parameter_values pv, "+
			"parameter_groups pg, "+
			"groups grps, "+
			"groupings grpings, "+
			"dataset_versions dv "+
                        "where pv.category like 'Phenotype%' "+
			"and pv.parameter != 'User ID' "+
			"and pv.parameter_group_id = pg.parameter_group_id "+
			"and dv.grouping_id = grpings.grouping_id "+
			"and grpings.grouping_id = grps.grouping_id "+
			"and dv.dataset_id = pg.dataset_id "+
			"and dv.version = pg.version "+
                        "and pv.parameter = to_char(grps.group_number) "+
			"and pv.parameter_group_id = ? "+
                        "order by grps.group_number";   

		//log.debug("query = "+query);
		//log.debug("query2 = "+query2);
		log.info("In getPhenotypeValuesForParameterGroupID. parameterGroupID = "+parameterGroupID);
                Connection conn=null;
                Phenotype thisPhenotype = new Phenotype();
                try{
                    conn=pool.getConnection();
                
                    Results myResults = new Results(query, parameterGroupID, conn); 
                    Results myResults2 = new Results(query2, parameterGroupID, conn); 

                    String[] dataRow;

                    
                    thisPhenotype.setParameter_group_id(parameterGroupID);
                    while ((dataRow = myResults.getNextRow()) != null) {
                            thisPhenotype.setDataset_id(Integer.parseInt(dataRow[2]));
                            if (dataRow[0].equals("Name")) {
                                    thisPhenotype.setName(dataRow[1]);
                            } else if (dataRow[0].equals("Description")) {
                                    thisPhenotype.setDescription(dataRow[1]);
                            }
                    }
                    Dataset myDataset = new Dataset();
                    Hashtable<Dataset.Group, Double> means = new Hashtable<Dataset.Group, Double>();
                    Hashtable<Dataset.Group, Double> variances = new Hashtable<Dataset.Group, Double>();
                    while ((dataRow = myResults2.getNextRow()) != null) {
                            if (dataRow[0].equals("Phenotype Group Value")) {
                                    Dataset.Group thisGroup = myDataset.new Group(Integer.parseInt(dataRow[1]));
                                    thisGroup.setGroup_name(dataRow[2]);
                                    thisGroup.setHas_expression_data(dataRow[3]);
                                    thisGroup.setHas_genotype_data(dataRow[4]);
                                    thisGroup.setGrouping_id(Integer.parseInt(dataRow[5]));
                                    means.put(thisGroup, Double.parseDouble(dataRow[6]));
                            } else if (dataRow[0].equals("Phenotype Variance Value")) {
                                    Dataset.Group thisGroup = myDataset.new Group(Integer.parseInt(dataRow[1]));
                                    thisGroup.setGroup_name(dataRow[2]);
                                    thisGroup.setHas_expression_data(dataRow[3]);
                                    thisGroup.setHas_genotype_data(dataRow[4]);
                                    thisGroup.setGrouping_id(Integer.parseInt(dataRow[5]));
                                    variances.put(thisGroup, Double.parseDouble(dataRow[6]));
                            }
                    }
                    thisPhenotype.setMeans(means);
                    thisPhenotype.setVariances(variances);

                    myResults.close();
                    myResults2.close();
                    conn.close();
                }catch(SQLException er){
                    throw er;
                }finally{
                    if(conn!=null && !conn.isClosed()){
                        try{
                            conn.close();
                            conn=null;
                        }catch(SQLException e){}
                    }
                }

        	return thisPhenotype;
	}
        
	 /**
	 * Gets the phenotype values stored for a particular parameter group ID.
	 * @param parameterGroupID     the identifier of the parameter group 
	 * @param conn     the database connection 
	 * @return            A Phenotype object
	 * @throws	SQLException if a database error occurs
	 */
	public ParameterValue.Phenotype getPhenotypeValuesForParameterGroupID(int parameterGroupID, Connection conn) throws SQLException {
  	
  		String query = 
                        "select pv.parameter, "+
                        "pv.value, "+
			"pg.dataset_id "+
                        "from parameter_values pv, "+
			"parameter_groups pg "+
                        "where pv.category = 'Phenotype Data' "+
			"and pv.parameter != 'User ID' "+
			"and pv.parameter_group_id = pg.parameter_group_id "+
			"and pv.parameter_group_id = ? "+
                        "order by pv.parameter";   

  		String query2 = 
                        "select pv.category, "+
                        "grps.group_number, "+
                        "grps.group_name, "+
                        "grps.has_expression_data, "+
                        "grps.has_genotype_data, "+
			"grps.grouping_id, "+
                        "pv.value "+
                        "from parameter_values pv, "+
			"parameter_groups pg, "+
			"groups grps, "+
			"groupings grpings, "+
			"dataset_versions dv "+
                        "where pv.category like 'Phenotype%' "+
			"and pv.parameter != 'User ID' "+
			"and pv.parameter_group_id = pg.parameter_group_id "+
			"and dv.grouping_id = grpings.grouping_id "+
			"and grpings.grouping_id = grps.grouping_id "+
			"and dv.dataset_id = pg.dataset_id "+
			"and dv.version = pg.version "+
                        "and pv.parameter = to_char(grps.group_number) "+
			"and pv.parameter_group_id = ? "+
                        "order by grps.group_number";   

		//log.debug("query = "+query);
		//log.debug("query2 = "+query2);
		log.info("In getPhenotypeValuesForParameterGroupID. parameterGroupID = "+parameterGroupID);
	
                Results myResults = new Results(query, parameterGroupID, conn); 
                Results myResults2 = new Results(query2, parameterGroupID, conn); 

                String[] dataRow;

		Phenotype thisPhenotype = new Phenotype();
		thisPhenotype.setParameter_group_id(parameterGroupID);
                while ((dataRow = myResults.getNextRow()) != null) {
			thisPhenotype.setDataset_id(Integer.parseInt(dataRow[2]));
			if (dataRow[0].equals("Name")) {
				thisPhenotype.setName(dataRow[1]);
			} else if (dataRow[0].equals("Description")) {
				thisPhenotype.setDescription(dataRow[1]);
			}
		}
		Dataset myDataset = new Dataset();
		Hashtable<Dataset.Group, Double> means = new Hashtable<Dataset.Group, Double>();
		Hashtable<Dataset.Group, Double> variances = new Hashtable<Dataset.Group, Double>();
                while ((dataRow = myResults2.getNextRow()) != null) {
			if (dataRow[0].equals("Phenotype Group Value")) {
				Dataset.Group thisGroup = myDataset.new Group(Integer.parseInt(dataRow[1]));
				thisGroup.setGroup_name(dataRow[2]);
				thisGroup.setHas_expression_data(dataRow[3]);
				thisGroup.setHas_genotype_data(dataRow[4]);
				thisGroup.setGrouping_id(Integer.parseInt(dataRow[5]));
				means.put(thisGroup, Double.parseDouble(dataRow[6]));
			} else if (dataRow[0].equals("Phenotype Variance Value")) {
				Dataset.Group thisGroup = myDataset.new Group(Integer.parseInt(dataRow[1]));
				thisGroup.setGroup_name(dataRow[2]);
				thisGroup.setHas_expression_data(dataRow[3]);
				thisGroup.setHas_genotype_data(dataRow[4]);
				thisGroup.setGrouping_id(Integer.parseInt(dataRow[5]));
				variances.put(thisGroup, Double.parseDouble(dataRow[6]));
			}
                }
		thisPhenotype.setMeans(means);
		thisPhenotype.setVariances(variances);

		myResults.close();
		myResults2.close();

        	return thisPhenotype;
	}

	/**
	 * Gets the phenotype names from a list of phenotype values. 
	 * @param allPhenotypeValues     an array of Phenotype objects
         * @return      an array of String objects containing only the names
	 */
	public String[] getPhenotypeNames (Phenotype[] allPhenotypeValues) {
		
		log.info("in getPhenotypeNames passing in an array of Phenotype objects");
                //log.debug("allPhenotypeValues= "); new Debugger().print(allPhenotypeValues);

		List<String> myPhenotypeNameList = new ArrayList<String>();

		for (Phenotype phenotypeValue : allPhenotypeValues) {
			myPhenotypeNameList.add(phenotypeValue.getName());
		}

                String[] myPhenotypeNameArray = (String[]) myPhenotypeNameList.toArray(new String[myPhenotypeNameList.size()]);
                //log.debug("myPhenotypeNameArray= "); new Debugger().print(myPhenotypeNameArray);

        	Arrays.sort(myPhenotypeNameArray); 

                return myPhenotypeNameArray;
	} 

	/**
	 * Gets the phenotype names for a dataset grouping
	 * @param userID     the identifier of the user 
	 * @param ds	the Dataset object
	 * @param groupingID	the grouping_id for the dataset version, or -99 for all
	 * @param conn     the database connection 
         * @return      an array of String objects containing only the names
	 * @throws	SQLException if a database error occurs
	 */
	public String[] getPhenotypeNames (int userID, Dataset ds, int groupingID, Connection conn) throws SQLException {
		
		//log.info("in getPhenotypeNames");
		Phenotype[] allPhenotypeValues = getPhenotypeValuesForDataset(userID, ds, groupingID, conn);
                //log.debug("allPhenotypeValues= "); new Debugger().print(allPhenotypeValues);

		String[] myPhenotypeNamesArray = getPhenotypeNames(allPhenotypeValues);

                return myPhenotypeNamesArray;

	} 

	/**
	 * Gets the phenotype name from a set of phenotype values. 
	 * @param parameterGroupID     the identifier of the parameter group
	 * @param conn     the database connection 
         * @return      the name of the phenotype
	 * @throws	SQLException if a database error occurs
	 */
	public String getPhenotypeName (int parameterGroupID, Connection conn) throws SQLException {
		
		log.debug("in getPhenotypeName");
		ParameterValue[] allPhenotypeValues = getParameterValues(parameterGroupID, conn);
                //log.debug("allPhenotypeValues= "); new Debugger().print(allPhenotypeValues);

		String phenotypeName = "";
		for (ParameterValue parameterValue : allPhenotypeValues) {
			if (parameterValue.getParameter().equals("Name")) {
				phenotypeName = parameterValue.getValue();
			}
		}

                return phenotypeName;
	} 

	/**
	 * Checks to see if the phenotype name being created already exists for the grouping used by this dataset version and user
	 * @param name	the name of the new phenotype
	 * @param userID	the id of the user creating the phenotype
	 * @param thisVersion	the version of the dataset
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            true if a set of phenotype values with this name already exists, or false otherwise
	 */
	public boolean checkPhenotypeNameExists(String name, int userID, Dataset.DatasetVersion thisVersion, Connection conn) throws SQLException {

        	String query =
			"select 'x' "+
			"from parameter_values pv, "+
			"parameter_groups pg, "+
			"dataset_versions dv "+
			"where pv.parameter_group_id = pg.parameter_group_id "+
			"and pv.category = 'Phenotype Data' "+
			"and pv.parameter = 'Name' "+
			"and pv.value = ? "+
			"and dv.dataset_id = pg.dataset_id "+
			"and dv.version = pg.version "+
			"and pg.dataset_id = ? "+
			"and pg.version in "+
			"	(select version "+
			"	from dataset_versions dv2 "+
			"	where dv2.grouping_id = dv.grouping_id) "+
			"and exists "+
			"        (select 'x' "+
			"        from parameter_values pv2 "+
			"        where pv2.parameter_group_id = pv.parameter_group_id "+
			"        and pv2.category = 'Phenotype Data' "+
			"        and pv2.parameter = 'User ID' "+
			"        and pv2.value = ?) ";

		log.debug("in checkPhenotypeNameExists");
		//log.debug("query = "+query);

		boolean alreadyExists = false;

                Results myResults = new Results(query, new Object[] {name, thisVersion.getDataset().getDataset_id(), Integer.toString(userID)}, conn); 

        	if (myResults.getNumRows() != 0) {
			alreadyExists = true;
		}
		myResults.close();

        	return alreadyExists;
	}

	/**
	 * Creates a new ParameterValue object and sets the data values to those retrieved from the database.
	 * @param dataRow     the row of data corresponding to one ParameterValue
	 * @return            A ParameterValue object with its values setup
	 */

	public ParameterValue setupParameterValue(String dataRow[]) {
  	
        	//log.debug("in setupParameterValue");
        	//log.debug("dataRow= "); new Debugger().print(dataRow);

		ParameterValue newParameterValue = new ParameterValue();
                newParameterValue.setParameter_value_id(Integer.parseInt(dataRow[0]));
                newParameterValue.setParameter_group_id(Integer.parseInt(dataRow[1]));
                newParameterValue.setCategory(dataRow[2]);
                newParameterValue.setParameter(dataRow[3]);
                newParameterValue.setValue(dataRow[4]);
                newParameterValue.setCreate_date_as_string(dataRow[5]);
                newParameterValue.setCreate_date((dataRow[5] != null && !dataRow[5].equals("") ? 
				new ObjectHandler().getDisplayDateAsTimestamp(dataRow[5]) : null));
		if (dataRow[6] != null && !dataRow[6].equals("")) {
                	newParameterValue.setDataset_id(Integer.parseInt(dataRow[6]));
                	newParameterValue.setVersion(Integer.parseInt(dataRow[7]));
		}
                return newParameterValue;
	}

	/**
	 * Gets the ParameterValue object that contains the hybrid_id from myParameterValues.
	 * @param myParameterValues	an array of ParameterValue objects
	 * @param parameter	the hybrid_id to find
	 * @return            the ParameterValue object for the hybrid_id
	 */
	public ParameterValue getParameterValueFromMyParameterValues(ParameterValue[] myParameterValues, String parameter) {

		//log.debug("in getParameterValueFromMyParameterValues.  Now sorting by parameter");
        	myParameterValues = sortParameterValues(myParameterValues, "parameter", "A");

        	int hybridToFindIndex = Arrays.binarySearch(myParameterValues, new ParameterValue(parameter), new ParameterValueSortComparator());
	
		//log.debug(" in getParameterValueFromMyParameterValues.  parameter = "+parameter+
		//	", numParameterValues = "+myParameterValues.length+", hybridToFindIndex = "+hybridToFindIndex);

        	ParameterValue thisParameterValue = (hybridToFindIndex < 0 ? null : myParameterValues[hybridToFindIndex]);

		//log.debug("thisParameterValue = "); myDebugger.print(thisParameterValue);
        	return thisParameterValue;
  	}

	public int compareTo(Object myParameterValueObject) {
		if (!(myParameterValueObject instanceof ParameterValue)) return -1;
        	ParameterValue myParameterValue = (ParameterValue) myParameterValueObject;

		return this.value.compareTo(myParameterValue.value); 

	}

        public String toString() {
		return ("PV id = " + parameter_value_id + "--" + " PG id = " + parameter_group_id + 
			" dataset_id = " + dataset_id + " version = " + version + ":  " + 
			category + "--" + parameter + "--"+ value);
        }

/*
	public boolean equals(Object obj) {
		if (!(obj instanceof ParameterValue)) return false;
		return (this.parameter == ((ParameterValue)obj).parameter &&
			this.category == ((ParameterValue)obj).category && 
			this.value == ((ParameterValue)obj).value);
	}
*/

        public void print() {
		log.debug(toString());
        }

	private String sortOrder;
	public void setSortOrder(String inString) {
	        this.sortOrder = inString;
	}

	public String getSortOrder() {
	        return sortOrder;
	}

	private String sortColumn;

	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}
	public String getSortColumn() {
		return sortColumn;
	}

	public ParameterValue[] sortParameterValues (ParameterValue[] myParameterValues, String sortColumn, String sortOrder) {
        	setSortColumn(sortColumn);
        	setSortOrder(sortOrder);
        	Arrays.sort(myParameterValues, new ParameterValueSortComparator());
        	return myParameterValues;
	}

	public class ParameterValueSortComparator implements Comparator<ParameterValue> {
        	int compare;
		ParameterValue parameterValue1, parameterValue2;

        	public int compare(ParameterValue pv1, ParameterValue pv2) {
			//log.debug("in ParameterValueSortComparator. sortOrder = "+getSortOrder() + ", sortColumn = "+getSortColumn());
			if (sortOrder.equals("A")) {
                		parameterValue1 = pv1;
                		parameterValue2 = pv2;
				// default for null columns for ascending order
				compare = 1;
			} else {
                		parameterValue1 = pv2;
                		parameterValue2 = pv1;
				// default for null columns for descending order
				compare = -1;
			}
			//log.debug("parameterValue1 value = "+parameterValue1.getValue()+ ", parameterValue2 Value = "+parameterValue2.getValue());

                	if (getSortColumn().equals("value")) {
                        	compare = parameterValue1.getValue().compareTo(parameterValue2.getValue());
                	} else if (getSortColumn().equals("parameterValueID")) {
                        	compare = new Integer(parameterValue1.getParameter_value_id()).compareTo(new Integer(parameterValue2.getParameter_value_id()));
                	} else if (getSortColumn().equals("parameter")) {
                        	compare = parameterValue1.getParameter().compareTo(parameterValue2.getParameter());
                	} else if (getSortColumn().equals("dateCreated")) {
                        	compare = parameterValue1.getCreate_date().compareTo(parameterValue2.getCreate_date());
                	} else if (getSortColumn().equals("parameter_group_id")) {
                        	compare = new Integer(parameterValue1.getParameter_group_id()).compareTo(new Integer(parameterValue2.getParameter_group_id()));
			}
                	return compare;
        	}

	}

	/**
	 * Class for handling information related to a particular set of phenotype values
	 */
	public class Phenotype {
		private int parameter_group_id;
		private int grouping_id;
		private int dataset_id;
		private String name;
		private String description;
		private int user_id;
		private int groupsWithExpressionData;
		private int groupsWithGenotypeData;
		private Hashtable<Dataset.Group, Double> means;
		private Hashtable<Dataset.Group, Double> variances;

		public Phenotype() {
			log = Logger.getRootLogger();
		}

		public Phenotype(int parameter_group_id) {
			log = Logger.getRootLogger();
			setParameter_group_id(parameter_group_id);
		}

		public void setParameter_group_id(int inInt) {
			parameter_group_id = inInt;
		}

		public int getParameter_group_id() {
			return parameter_group_id;
		}

		public void setGrouping_id(int inInt) {
			grouping_id = inInt;
		}

		public int getGrouping_id() {
			return grouping_id;
		}

		public void setDataset_id(int inInt) {
			dataset_id = inInt;
		}

		public int getDataset_id() {
			return dataset_id;
		}

  		public String getName() {
    			return name; 
  		}

  		public void setName(String inString) {
    			this.name = inString;
  		}

  		public String getDescription() {
    			return description; 
  		}

  		public void setDescription(String inString) {
    			this.description = inString;
  		}

		public void setUser_id(int inInt) {
			user_id = inInt;
		}

		public int getUser_id() {
			return user_id;
		}

		public void setGroupsWithExpressionData(int inInt) {
			groupsWithExpressionData = inInt;
		}

		public int getGroupsWithExpressionData() {
			return groupsWithExpressionData;
		}

		public void setGroupsWithGenotypeData(int inInt) {
			groupsWithGenotypeData = inInt;
		}

		public int getGroupsWithGenotypeData() {
			return groupsWithGenotypeData;
		}

  		public Hashtable<Dataset.Group, Double> getMeans() {
    			return means; 
  		}

  		public void setMeans(Hashtable<Dataset.Group, Double> inHashtable) {
    			this.means = inHashtable;
  		}

  		public Hashtable<Dataset.Group, Double> getVariances() {
    			return variances; 
  		}

  		public void setVariances(Hashtable<Dataset.Group, Double> inHashtable) {
    			this.variances = inHashtable;
  		}


		/** Count the number of groups that have phenotype values for groups that have expression data and genotype data.
	 	 * @param myPhenotypes	an array of Phenotype objects
	 	 * @return            an array of Phenotype objects with the group counts set
	 	 */
		public Phenotype[] countGroups(Phenotype[] myPhenotypes) {
			log.debug("in countGroups");
			for (Phenotype thisPhenotype : myPhenotypes) {
                		int myGroupsWithExpressionData = 0;
                		int myGroupsWithGenotypeData = 0;
                		for (Dataset.Group thisGroup : thisPhenotype.getMeans().keySet()) {
                        		if (thisGroup.getHas_expression_data().equals("Y")) {
                                		myGroupsWithExpressionData++;
                        		} 
					if (thisGroup.getHas_genotype_data().equals("Y")) {
                                		myGroupsWithGenotypeData++;
                        		}
                		}
                		thisPhenotype.setGroupsWithExpressionData(myGroupsWithExpressionData);
                		thisPhenotype.setGroupsWithGenotypeData(myGroupsWithGenotypeData);
                		//log.debug("groups with expression data for " + thisPhenotype.getName() + ": " + thisPhenotype.getGroupsWithExpressionData() );
                		//log.debug("groups with genotype data for " + thisPhenotype.getName() + ": " + thisPhenotype.getGroupsWithGenotypeData() );
        		}
			return myPhenotypes;
		}

		/**
		 * Copy all the files to a new name so that multiple files can be downloaded and each will have a unique name
		 * @param fileList	a list of file names
		 * @return	an array of file names
		 * @throws IOException
		 */
		public String [] renamePhenotypeFiles(String [] fileList) throws IOException{
			for (int i=0; i<fileList.length; i++) {
				if (fileList[i].matches(".*henotype.*\\.txt")) {
					File oldFile = new File(fileList[i]);    	            
					File phenotypeFileNewName = new FileHandler().copyFile(oldFile,
							new File(oldFile.getParent() + "/" + new File(oldFile.getParent()).getName() + "_" + oldFile.getName()));
					fileList[i] = phenotypeFileNewName.getPath(); 
					//log.debug("oldFile = "+oldFile + ", and new File = "+fileList[i]);
				}
			}
			return fileList;
		}
    
        	public String toString() {
			return ("PG id = " + parameter_group_id + 
				" name = " + name + " numGroups = " + (means != null && means.size() > 0 ? means.size() : 0));
        	}

        	public void print() {
			log.debug(toString());
        	}

		public boolean equals(Object obj) {
			if (!(obj instanceof Phenotype)) return false;
			return (this.parameter_group_id == ((Phenotype)obj).parameter_group_id); 
		}

		private String sortOrder;

		public void setSortOrder(String inString) {
	        	this.sortOrder = inString;
		}

		public String getSortOrder() {
	        	return sortOrder;
		}

		private String sortColumn;

		public void setSortColumn(String inString) {
			this.sortColumn = inString;
		}

		public String getSortColumn() {
			return sortColumn;
		}

		public Phenotype[] sortPhenotypes (Phenotype[] myPhenotypes, String sortColumn, String sortOrder) {
        		setSortColumn(sortColumn);
        		setSortOrder(sortOrder);
        		Arrays.sort(myPhenotypes, new PhenotypeSortComparator());
        		return myPhenotypes;
		}

		public class PhenotypeSortComparator implements Comparator<Phenotype> {
        		int compare;
			Phenotype phenotype1, phenotype2;

        		public int compare(Phenotype pv1, Phenotype pv2) {
				//log.debug("in PhenotypeSortComparator. sortOrder = "+getSortOrder() + ", sortColumn = "+getSortColumn());
				if (sortOrder.equals("A")) {
                			phenotype1 = pv1;
                			phenotype2 = pv2;
					// default for null columns for ascending order
					compare = 1;
				} else {
                			phenotype1 = pv2;
                			phenotype2 = pv1;
					// default for null columns for descending order
					compare = -1;
				}
				//log.debug("phenotype1 name = "+phenotype1.getName()+ ", phenotype2 name = "+phenotype2.getName());

                		if (getSortColumn().equals("name")) {
                        		compare = phenotype1.getName().toUpperCase().compareTo(phenotype2.getName().toUpperCase());
                		} else if (getSortColumn().equals("parameter_group_id")) {
                        		compare = new Integer(phenotype1.getParameter_group_id()).compareTo(new Integer(phenotype2.getParameter_group_id()));
				}
                		return compare;
        		}

		}
	}
	
}

