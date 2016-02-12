package edu.ucdenver.ccp.PhenoGen.data;

import java.io.File;
import java.io.IOException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.text.DecimalFormat;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.Results;

import edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;
import edu.ucdenver.ccp.PhenoGen.web.SessionHandler; 
import javax.sql.DataSource;

/* for logging messages */
import org.apache.log4j.Logger;

//Had to change this when moving to 11g;
//import oracle.jdbc.driver.OraclePreparedStatement;
import oracle.jdbc.*;


/**
 * Class for handling gene list data.
 * @author Cheryl Hornbaker
 */

public class GeneList{

  private Debugger myDebugger = new Debugger();
  private ObjectHandler myObjectHandler = new ObjectHandler();

  private int gene_list_id;
  private String gene_list_name;
  private String gene_list_name_no_spaces;
  private String description;
  private java.sql.Timestamp create_date;
  private int created_by_user_id;
  private int parameter_group_id;
  private int dataset_id;
  private int version;
  private int number_of_genes;
  private String path;
  private String gene_list_source;
  private String gene_list_owner;
  private String organism;
  private String userIsOwner;
  private String alternateIdentifierSource;
  private int alternateIdentifierSourceID;
  private String alternateIdentifierSourceLinkColumn;
  private String create_date_as_string;
  private String anovaPValue;
  private String statisticalMethod;
  private Dataset.DatasetVersion datasetVersion;
  private String[] columnHeadings;

  private List gene_list_users;
  private String[] genes;
  private String sortColumn;
  private String sortOrder;
  private String geneListSelectClause =
  		"select "+
		"gl.gene_list_id, "+
		"o.title||' '||o.first_name||' '||o.last_name owner, "+ 
		"gl.path, "+
        	"gl.gene_list_name, "+
        	"nvl(gl.description, 'No Description Entered') Description, "+
                "case when max(gene_id) is not null then count(*) else 0 end, "+
        	"gl.organism Organism, "+
		"case when gl.gene_list_source != 'Statistical Analysis' then gl.gene_list_source "+                 
		"	else ds.name||'_v'||dv.version end as Source, "+
		"to_char(gl.create_date, 'mm/dd/yyyy hh12:mi AM') \"Date Created\", "+
		"to_char(gl.create_date, 'mmddyyyy_hh24miss'), "+
		"nvl(gl.dataset_id, -99), "+
		"nvl(gl.parameter_group_id, -99), "+
		"gl.created_by_user_id, "+
		"nvl(gl.version, -99), "+
		"gl.create_date ";

  private String geneListFromClause = 
        	"from gene_lists gl left join "+
		"	(dataset_versions dv inner join "+
		"	datasets ds on "+
		"	ds.dataset_id = dv.dataset_id) on "+
        	"dv.dataset_id = gl.dataset_id "+                 
		"and dv.version = gl.version "+
		"left join genes g on g.gene_list_id = gl.gene_list_id "+
		"join users o on gl.created_by_user_id = o.user_id ";

  private String geneListGroupByClause = 
		"group by gl.created_by_user_id, "+
		"gl.path, "+
		"gl.gene_list_name, "+
		"gl.description, "+
		"gl.organism, "+
		"gl.gene_list_source, "+
		"ds.name, "+
		"dv.version, "+
		"gl.gene_list_id, "+
		"o.title, o.first_name, o.last_name, "+
		"gl.create_date, "+
		"gl.dataset_id, "+
		"gl.version, "+
		"gl.parameter_group_id ";

  //
  // genesHash contains the original id pointing to the currently selected id
  //
  private Hashtable<String,String> genesHash;

  //
  // genesHashMap contains the original id pointing to an array of ids returned from iDecoder
  //
  private HashMap genesHashMap;


  private Logger log=null;

  public DbUtils myDbUtils = new DbUtils(); 

  public GeneList () {
	log = Logger.getRootLogger();
  }

  public GeneList (int gene_list_id) {
	log = Logger.getRootLogger();
	this.gene_list_id = gene_list_id;
  }

  public GeneList (int gene_list_id, String gene_list_name) {
	log = Logger.getRootLogger();
	this.gene_list_id = gene_list_id;
	this.gene_list_name = gene_list_name;
  }

  public int getGene_list_id() {
    return gene_list_id; 
  }

  public void setGene_list_id(int inInt) {
    this.gene_list_id = inInt;
  }

  public void setGene_list_name(String inString) {
    this.gene_list_name = inString;
  }

  public String getGene_list_name() {
    return gene_list_name; 
  }

  public void setGene_list_name_no_spaces(String inString) {
    this.gene_list_name_no_spaces = inString;
  }

  public String getGene_list_name_no_spaces() {
    return gene_list_name_no_spaces; 
  }

  public void setDescription(String inString) {
    this.description = inString;
  }

  public String getDescription() {
    return description; 
  }

  public void setCreate_date_as_string(String inString) {
    this.create_date_as_string = inString;
  }

  public String getCreate_date_as_string() {
    return create_date_as_string; 
  }

  public void setCreate_date(java.sql.Timestamp inTimestamp) {
    this.create_date = inTimestamp;
  }

  public java.sql.Timestamp getCreate_date() {
    return create_date;
  }

  public void setCreated_by_user_id(int inInt) {
    this.created_by_user_id = inInt;
  }

  public int getCreated_by_user_id() {
    return created_by_user_id; 
  }

  public void setGene_list_source(String inString) {
    this.gene_list_source = inString;
  }

  public String getGene_list_source() {
    return gene_list_source; 
  }

  /** 
   * Contains the first and last name of the gene list creator or 'Y' or 'N' if name isn't known.  
   */
  public void setGene_list_owner(String inString) {
    this.gene_list_owner = inString;
  }

  public String getGene_list_owner() {
    return gene_list_owner; 
  }
  
  public void setParameter_group_id(int inInt) {
    this.parameter_group_id = inInt;
  }

  public int getParameter_group_id() {
    return parameter_group_id; 
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

  public void setDatasetVersion(Dataset.DatasetVersion inDatasetVersion) {
    this.datasetVersion = inDatasetVersion;
  }

  public Dataset.DatasetVersion getDatasetVersion() {
    return datasetVersion; 
  }

  public void setNumber_of_genes(int inInt) {
    this.number_of_genes = inInt;
  }

  public int getNumber_of_genes() {
    return number_of_genes; 
  }

  public void setPath(String inString) {
    this.path = inString;
  }

  public String getPath() {
    return path;
  }

  public void setOrganism(String inString) {
    this.organism = inString;
  }

  public String getOrganism() {
    return organism;
  }

  public void setAlternateIdentifierSource(String inString) {
    this.alternateIdentifierSource = inString;
  }

  public String getAlternateIdentifierSource() {
    return alternateIdentifierSource;
  }

  public void setAlternateIdentifierSourceLinkColumn(String inString) {
    this.alternateIdentifierSourceLinkColumn = inString;
  }

  public String getAlternateIdentifierSourceLinkColumn() {
    return alternateIdentifierSourceLinkColumn;
  }

  public void setAlternateIdentifierSourceID(int inInt) {
    this.alternateIdentifierSourceID = inInt;
  }

  public int getAlternateIdentifierSourceID() {
    return alternateIdentifierSourceID; 
  }

  public void setGene_list_users(List gene_list_users) {
    this.gene_list_users = gene_list_users;
  }

  public List getGene_list_users() {
    return (gene_list_users != null ? gene_list_users : new ArrayList());
  }

  public void setColumnHeadings(String[] inStringArray) {
    this.columnHeadings = inStringArray;
  }

  public String[] getColumnHeadings() {
    return columnHeadings;
  }

  public void setGenes(String[] inStringArray) {
    this.genes = inStringArray;
  }

  public String[] getGenes() {
    return genes;
  }

  public void setGenesHash(Hashtable<String,String> genesHash) {
    this.genesHash = genesHash;
  }

  public Hashtable getGenesHash() {
    return genesHash;
  }

  public void setGenesHashMap(HashMap genesHashMap) {
    this.genesHashMap = genesHashMap;
  }

  public HashMap getGenesHashMap() {
    return genesHashMap;
  }

  /** 
   * 'Y' if the user logged in created this genelist, otherwise 'N'.
   */
  public void setUserIsOwner(String inString) {
    this.userIsOwner = inString;
  }

  public String getUserIsOwner() {
    return userIsOwner;
  }

  public void setAnovaPValue(String inString) {
    this.anovaPValue = inString;
  }

  public String getAnovaPValue() {
    return anovaPValue;
  }

  public void setStatisticalMethod(String inString) {
    this.statisticalMethod = inString;
  }

  public String getStatisticalMethod() {
    return statisticalMethod;
  }

  public String getSortColumn() {
    return sortColumn; 
  }

  public void setSortColumn(String inString) {
    this.sortColumn = inString;
  }

  public String getSortOrder() {
    return sortOrder; 
  }

  public void setSortOrder(String inString) {
    this.sortOrder = inString;
  }

  
        public GeneList getGeneList(int geneListID,DataSource pool)throws SQLException {
            Connection conn=null;
            GeneList myGeneList=null;
            try{
                conn=pool.getConnection();
                log.info("in getGeneList as a GeneList object. geneListID = " + geneListID);

  		String query = 
			geneListSelectClause + 
			geneListFromClause + 
			"where gl.gene_list_id = ? "+
			geneListGroupByClause; 
                log.debug(query);
        	Results myResults = new Results(query, geneListID, conn);
                log.debug("before first call");
        	String[] dataRow = myResults.getNextRow();
		log.debug("calling setupGeneListValues");
        	myGeneList = setupGeneListValues(dataRow);
                log.debug("after calling setupGeneListValues");
		if (myGeneList.getParameter_group_id() != -99) {
                    log.debug("before parameter group calls");
			myGeneList.setAnovaPValue(
				new ParameterValue().getAnovaPValue(
				myGeneList.getParameter_group_id(), pool));
	        	myGeneList.setStatisticalMethod(
				new ParameterValue().getStatisticalMethod(
				myGeneList.getParameter_group_id(), pool));
		}
		log.debug("before column heading call");
		myGeneList.setColumnHeadings(getColumnHeadings(geneListID, pool));	
                log.debug("after all calls before closing");
        	myResults.close();
                log.debug("after closing results.");
                conn.close();
                log.debug("after closing connection");
            }catch(SQLException e){
                log.debug("getGeneList ERROR:",e);
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
            return myGeneList;
        }

  	/** 
	 * Retrieves a GeneList object, including it's associated Dataset object if applicable
	 * 	and the parameters used to derive it, if applicable.
	 * @param geneListID	the identifier of the gene list
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 * @return	the GeneList object
	 */
	public GeneList getGeneList(int geneListID, Connection conn) throws SQLException {

		log.info("in getGeneList as a GeneList object. geneListID = " + geneListID);

  		String query = 
			geneListSelectClause + 
			geneListFromClause + 
			"where gl.gene_list_id = ? "+
			geneListGroupByClause; 

        	Results myResults = new Results(query, geneListID, conn);

        	String[] dataRow = myResults.getNextRow();
		//log.debug("calling setupGeneListValues");
        	GeneList myGeneList = setupGeneListValues(dataRow);

		if (myGeneList.getParameter_group_id() != -99) {
			myGeneList.setAnovaPValue(
				new ParameterValue().getAnovaPValue(
				myGeneList.getParameter_group_id(), conn));
	        	myGeneList.setStatisticalMethod(
				new ParameterValue().getStatisticalMethod(
				myGeneList.getParameter_group_id(), conn));
		}
		
		myGeneList.setColumnHeadings(getColumnHeadings(geneListID, conn));	

        	myResults.close();
        	return myGeneList;
	}

	/**
	 * Constructs the path where the files for the public GeneLists are stored
	 * @param userFilesRoot	the location of the userFiles directory for storing files.  
	 * @return            a String containing the root path for public gene lists
	 */
	public String getPublicGeneListsPath(String userFilesRoot) {
		return userFilesRoot + "public/" + "GeneLists/"; 
	}

        
        /** 
	 * Retrieves the gene lists associated with a phenotype
	 * @param parameterGroupID	the identifier of the parameter group that contains the phenotype data
	 * @param pool		the database connection pool
	 * @throws	SQLException if a database error occurs
	 * @return	an array of gene lists that are associated with the phenotype
	 */
        public GeneList[] getGeneListsForPhenotype(int geneListID,DataSource pool)throws SQLException {
            Connection conn=null;
            GeneList[] tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGeneListsForPhenotype(geneListID,conn);
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
	 * Retrieves the gene lists associated with a phenotype
	 * @param parameterGroupID	the identifier of the parameter group that contains the phenotype data
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 * @return	an array of gene lists that are associated with the phenotype
	 */
	public GeneList[] getGeneListsForPhenotype (int parameterGroupID, Connection conn) throws SQLException {
  	
  		String query = 
			geneListSelectClause + 
			geneListFromClause + 
			", "+
			"parameter_groups phenotypePG, "+
			"parameter_groups pg, "+
			"parameter_values pv "+
			"where pg.parameter_group_id = pv.parameter_group_id "+
			"and pg.parameter_group_id = gl.parameter_group_id "+
			"and pv.parameter = 'Parameter Group ID' "+
			"and pv.category = 'Phenotype Data' "+
			"and to_char(phenotypePG.parameter_group_id) = pv.value "+
			"and phenotypePG.parameter_group_id = ? "+
			geneListGroupByClause;

		log.debug("In getGeneListsForPhenotype");
		//log.debug("query = "+ query);

		Results myResults = new Results(query, parameterGroupID, conn);
		String dataRow[] = null;

		List<GeneList> geneLists = new ArrayList<GeneList>();
		while ((dataRow = myResults.getNextRow()) != null) {
			GeneList thisGeneList = setupGeneListValues(dataRow);
                	geneLists.add(thisGeneList);
        	}
        	myResults.close();

		GeneList[] geneListArray = (GeneList[]) myObjectHandler.getAsArray(geneLists, GeneList.class);

		return geneListArray;

  	}

        /** 
	 * Creates a file containing gene identifiers to use for filtering.
	 * @param fieldValues		mapping of keys to values from data entered by the user
	 * @param selectedDataset		the Dataset being analyzed
	 * @param pool		the database connection
	 * @throws	SQLException if a database error occurs
	 * @throws	IOException if an IO error occurs
	 * @return	an array of gene lists that are associated with the phenotype
	 */
        public File writeGeneListToFile(Dataset selectedDataset, Hashtable<String, String> fieldValues, DataSource pool)throws SQLException, IOException {
            Connection conn=null;
            File tmp=null;
            try{
                conn=pool.getConnection();
                tmp=writeGeneListToFile(selectedDataset,fieldValues,conn);
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
	 * Creates a file containing gene identifiers to use for filtering.
	 * @param fieldValues		mapping of keys to values from data entered by the user
	 * @param selectedDataset		the Dataset being analyzed
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 * @throws	IOException if an IO error occurs
	 * @return	an array of gene lists that are associated with the phenotype
	 */
	public File writeGeneListToFile (Dataset selectedDataset, Hashtable<String, String> fieldValues, Connection conn) throws SQLException, IOException {
		log.debug("in writeGeneListToFile. geneListID = " + this.getGene_list_id());
		Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();
		IDecoderClient myIDecoderClient = new IDecoderClient();
		ObjectHandler myObjectHandler = new ObjectHandler();
		FileHandler myFileHandler = new FileHandler();
		String geneListFileName = (String) fieldValues.get("geneListFileName");
		log.debug("geneListFileName = "+geneListFileName);

		if (this.getGene_list_id() != -99) {
                	String[] geneListArray = getGenesAsArray("Original", conn);
                        //log.debug("geneListArray = "); myDebugger.print(geneListArray);
                        if (((String) fieldValues.get("translateGeneList")).equals("Y")) {
                        	log.debug("user chose to translate identifiers, so calling iDecoder");

                                String geneChipName = myArray.getManufactureArrayName(selectedDataset.getArray_type(), conn);
                                log.debug("geneChipName = "+geneChipName);
                                String[] targets = new String[] {(selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM) ? "Affymetrix ID" : "CodeLink ID")};

                                // Reduced to 1 iteration so that user can map from one Affy chip to another, but also
                                // keeps the running time down
                                myIDecoderClient.setNum_iterations(1);
                                Set<Identifier> identifiers = myIDecoderClient.getIdentifiers(this.getGene_list_id(), targets, geneChipName, conn);
                                //log.debug("identifiers = "); myDebugger.print(identifiers);
                                Set<String> identifierValues = myIDecoderClient.getValues(identifiers);
                                //log.debug("identifierValues = "); myDebugger.print(identifierValues);

                                if (identifierValues.size() > 0) {
                                	myFileHandler.writeFile(myObjectHandler.getAsSeparatedString(identifierValues, "\n") + "\n", geneListFileName);
				}
			} else {
                        	log.debug("user chose not to translate identifiers");
                                myFileHandler.writeFile(myObjectHandler.getAsSeparatedString(geneListArray, "\n") + "\n", geneListFileName);
			}
        	}
		return new File(geneListFileName);
	}

  	/** 
	 * Gets a hashtable indicating where in the array each type of column exists
	 * @return	a Hashtable with the type of column mapped to the location in the array
	 */
  	public Hashtable<String, Integer> getSortingColumnIdxHash() {
		//log.debug("in getSortingColumnIdxHash");
        	Hashtable<String, Integer> indexHash = new Hashtable<String, Integer>();
                // Have to do this also in order to get the statistics values. 
                String[] columnHeadings = this.getColumnHeadings();
                for (int i=0; i<columnHeadings.length; i++) {
                        if (columnHeadings[i].equals("raw.p.value") ||
                                columnHeadings[i].equals("Raw P-value") || 
                                columnHeadings[i].equals("pvalue.threshold") || 
                                columnHeadings[i].equals("F.statistic") ||
                        	columnHeadings[i].equals("F-statistic") ||
                        	columnHeadings[i].equals("t.statistic") ||
                                columnHeadings[i].equals("T-statistic") ||
                        	columnHeadings[i].equals("t.stat1") ||
                                columnHeadings[i].equals("t.stat2") ||
                        	columnHeadings[i].equals("correlation.coefficient") ||
                        	columnHeadings[i].equals("Correlation Coefficient") ||
                                columnHeadings[i].equals("Coefficient") || 
                        	columnHeadings[i].equals("adjusted.p.value") ||
                                columnHeadings[i].equals("Adjusted P-value")) {
        			indexHash.put(columnHeadings[i], new Integer(i));
                        }
                }
		return indexHash;
	}

  	/** 
	 * Gets a hashtable indicating where in the array each type of column exists
	 * @return	a Hashtable with the type of column mapped to the location in the array
	 */
  	public Hashtable<String, Integer> getColumnIdxHash() {
		log.debug("in getColumnIdxHash");
        	int coefficientIdx = -99;
        	int rawPValueIdx = -99;
        	int adjPValueIdx = -99;
                // Have to do this also in order to get the statistics values. 
                String[] columnHeadings = this.getColumnHeadings();
                for (int i=0; i<columnHeadings.length; i++) {
                        if (columnHeadings[i].equals("raw.p.value") ||
                                columnHeadings[i].equals("Raw P-value")) {
                                rawPValueIdx = i;
                        } else if (columnHeadings[i].equals("correlation.coefficient") ||
                        	columnHeadings[i].equals("Correlation Coefficient") ||
                                columnHeadings[i].equals("Coefficient")) {
                                coefficientIdx = i;
                        } else if (columnHeadings[i].equals("adjusted.p.value") ||
                                columnHeadings[i].equals("Adjusted P-value")) {
                                adjPValueIdx = i;
                        }
                }
        	Hashtable<String, Integer> indexHash = new Hashtable<String, Integer>();
        	indexHash.put("coefficientIdx", new Integer(coefficientIdx));
        	indexHash.put("rawPValueIdx", new Integer(rawPValueIdx));
        	indexHash.put("adjPValueIdx", new Integer(adjPValueIdx));
        	//log.debug("coefficientIdx = "+coefficientIdx);
        	//log.debug("rawPValueIdx = "+rawPValueIdx);
        	//log.debug("adjPValueIdx = "+adjPValueIdx);
		return indexHash;
	}

        public String[] getColumnHeadings(int geneListID,DataSource pool)throws SQLException {
            Connection conn=null;
            String[] tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getColumnHeadings(geneListID,conn);
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
	 * Gets the values used as headings for a statistical analysis.
	 * @param geneListID	the identifier of the gene list 
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 * @return	an array of column headings
	 */
	public String[] getColumnHeadings(int geneListID, Connection conn) throws SQLException {

		//log.debug("in getColumnHeadings. geneListID = " + geneListID);

  		String query = 
                	"select distinct sc.description, "+
			"sc.sort_order, "+
			"gv.group_number "+
                	"from genes g left join gene_values gv "+
			"on gv.gene_list_id = g.gene_list_id "+
			"and gv.gene_id = g.gene_id "+
                	"left join statistic_codes sc "+
			"on gv.statistic_code = sc.statistic_code "+
                	"where g.gene_list_id = ? "+
			// 
			// since this is left-joined, we only want the rows that actually have gene_values
			//
			"and sc.description is not null "+
                	"order by sc.sort_order, decode(gv.group_number, 'NA', 0, to_number(gv.group_number))";

		//log.debug("query = "+query);
	
		Results myResults = new Results(query, geneListID, conn);
		String[] dataRow;

		String[] columnHeadings = null;
		columnHeadings = new String[myResults.getNumRows()];
		int i=0;
                while ((dataRow = myResults.getNextRow()) != null) {
			columnHeadings[i] = dataRow[0];
                        if (columnHeadings[i].equals("Group Mean")) {
                                // dataRow[2] contains the group number
                                columnHeadings[i] = "Group "+dataRow[2] + " Mean";
                        }
			i++;
                }
		myResults.close();

        	return columnHeadings;
	}

        
        public int createGeneList(DataSource pool)throws SQLException {
            Connection conn=null;
            int tmp=-99;
            try{
                conn=pool.getConnection();
                tmp=createGeneList(conn);
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
	 * Creates a record in the gene_lists table.  Also creates records in the gene_list_users table.
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 * @return	the identifier of the gene list
	 */
	public int createGeneList(Connection conn) throws SQLException {

		gene_list_id = myDbUtils.getUniqueID("gene_lists_seq", conn);

		log.debug("in createGeneList");
		log.debug("gene_list_id = "+gene_list_id + ", and path = "+this.getPath());

		String query = 
			"insert into gene_lists "+
			"(gene_list_id, gene_list_name, description, create_date, "+
			"created_by_user_id, path, gene_list_source, "+
			"parameter_group_id, dataset_id, version, "+
			"organism) values "+
			"(?, ?, ?, ?, "+
			"?, ?, ?, "+
			"?, ?, ?, "+
			"?)";

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
  		PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, gene_list_id); 
		pstmt.setString(2, this.getGene_list_name());	
		pstmt.setString(3, this.getDescription());	
		// This is the create_date
		pstmt.setTimestamp(4, now);	
		myDbUtils.setToNullIfZero(pstmt, 5, this.getCreated_by_user_id());
		pstmt.setString(6, this.getPath());	
		pstmt.setString(7, this.getGene_list_source());	
		myDbUtils.setToNullIfZero(pstmt, 8, this.getParameter_group_id());	
		myDbUtils.setToNullIfZero(pstmt, 9, this.getDataset_id());	
		myDbUtils.setToNullIfZero(pstmt, 10, this.getVersion());	
		pstmt.setString(11, this.getOrganism());	

		pstmt.executeUpdate();
		pstmt.close();

		this.setGene_list_id(gene_list_id);

		log.debug("here this.gene_list_users = "); myDebugger.print(this.getGene_list_users());
		createGeneListUsers(conn);

		if (this.getCreated_by_user_id() > 0) {
			Set<Integer> geneListUsersList = new HashSet<Integer>();
			geneListUsersList.add(new Integer(this.getCreated_by_user_id()));
			List<Integer> geneListUsers = new ArrayList<Integer>(geneListUsersList);
			this.setGene_list_users(geneListUsers);
			//log.debug("here2 this.gene_list_users = "); myDebugger.print(this.getGene_list_users());
			createGeneListUsers(conn);
		}

  		return gene_list_id;
	}

        
        public void deleteGeneListsForDatasetVersion(Dataset.DatasetVersion datasetVersion,DataSource pool)throws SQLException, Exception {
            Connection conn=null;
            try{
                conn=pool.getConnection();
                deleteGeneListsForDatasetVersion(datasetVersion,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
        }
        
  	/** 
	 * Deletes the gene lists for a dataset version.
	 * @param datasetVersion the DatasetVersion object 
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 */

	public void deleteGeneListsForDatasetVersion (Dataset.DatasetVersion datasetVersion, Connection conn) throws SQLException, Exception {

		log.debug("in deleteGeneListsForDatasetVersion");

		GeneList[] myGeneLists = getGeneListsForDatasetVersion(datasetVersion, conn);

		for (int i=0; i<myGeneLists.length; i++) {
			log.debug("genelist id is " + 
				myGeneLists[i].getGene_list_id() + 
				" and name is " + 
				myGeneLists[i].getGene_list_name() + 
				", and path is "+myGeneLists[i].getPath());

			String geneListPath = myGeneLists[i].getPath();

			myGeneLists[i].deleteGeneList(conn);

			if (geneListPath != null) {
				log.debug("now deleting files here "+geneListPath);
				new FileHandler().deleteAllFilesPlusDirectory(new File(geneListPath));
			}
        	}

  	}

  public String[] getUserGeneListsForUserStatements(String typeOfQuery) {

        String[] query = new String[1];

        String selectClause = myDbUtils.getSelectClause(typeOfQuery);
        String rownumClause = myDbUtils.getRownumClause(typeOfQuery);

        query[0] =
                selectClause +
		"from user_gene_lists "+
		"where user_id = ?"+
                rownumClause;

	return query;
  }


  public List<List<String[]>> getUserGeneListsForUser(int userID,DataSource pool)throws SQLException {
            Connection conn=null;
            List<List<String[]>> tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getUserGeneListsForUser(userID,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
            return tmp;
        }
  
  
  public List<List<String[]>> getUserGeneListsForUser(int userID, Connection conn) throws SQLException {

	log.debug("in getUserGeneListsForUser");
	String[] query = getUserGeneListsForUserStatements("SELECT10");

	List<List<String[]>> allResults = null;

	try {
                allResults = new Results().getAllResults(query, userID, conn);

	} catch (SQLException e) {
		log.error("In exception of getUserGeneListsForUser", e);
		throw e;
	}
        log.debug("returning allResults for getUserGeneListsForUser.length = "+allResults.size());
        return allResults;

  }

  public void deleteUserGeneListsForUser(int userID,DataSource pool)throws SQLException {
            Connection conn=null;
            try{
                conn=pool.getConnection();
                deleteUserGeneListsForUser(userID,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
        }
  
  public void deleteUserGeneListsForUser(int userID, Connection conn) throws SQLException {

	log.debug("in deleteUserGeneListsForUser");

	String[] query = getUserGeneListsForUserStatements("DELETE");

	PreparedStatement pstmt = null;

	try {
                for (int i=0; i<query.length; i++) {
                        pstmt = conn.prepareStatement(query[i],
                                	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                	ResultSet.CONCUR_UPDATABLE);
			pstmt.setInt(1, userID);

			pstmt.executeUpdate();
			pstmt.close();
		}

	} catch (SQLException e) {
		log.error("In exception of deleteUserGeneListsForUser", e);
		throw e;
	}
  }

        public void deleteGeneListUsers(DataSource pool)throws SQLException {
            Connection conn=null;
            try{
                conn=pool.getConnection();
                deleteGeneListUsers(conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
        }
  
  	/** 
	 * Deletes records in the user_gene_lists table for a specific gene list.
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 */
	public void deleteGeneListUsers(Connection conn) throws SQLException {

		log.debug("in deleteGeneListUsers");
		String query =
			"delete from user_gene_lists "+
			"where gene_list_id = ?";

		PreparedStatement pstmt = conn.prepareStatement(query,
                                	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                	ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, this.getGene_list_id());

		pstmt.executeUpdate();
		pstmt.close();

	}

        
        public void deleteGeneList(int gene_list_id,DataSource pool)throws SQLException {
            Connection conn=null;
            try{
                conn=pool.getConnection();
                deleteGeneList(gene_list_id,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
        }
        
  	/** 
	 * Deletes a gene list and its associated records.
	 * @param gene_list_id	the identifier of the gene list
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 */

	public void deleteGeneList(int gene_list_id, Connection conn) throws SQLException {
  	
		log.debug("in deleteGeneList");
		GeneList thisGeneList = getGeneList(gene_list_id, conn);
		thisGeneList.deleteGeneList(conn);

	}

        
        public void deleteGeneList(DataSource pool)throws SQLException {
            Connection conn=null;
            try{
                conn=pool.getConnection();
                deleteGeneList(conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
        }
        
  	/** 
	 * Deletes a gene list and its associated records.
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 */

	public void deleteGeneList(Connection conn) throws SQLException {
  	
		log.debug("in GeneList.delete. gene_list_id = " + this.getGene_list_id());
		conn.setAutoCommit(false);
		int gene_list_id = this.getGene_list_id();

		try {
			deleteGeneListUsers(conn);
			new SessionHandler().deleteSessionActivitiesForGeneList(gene_list_id, conn);
			new LitSearch().deleteAllLitSearchesForGeneList(gene_list_id, conn);
			new Promoter().deleteAllPromoterResultsForGeneList(gene_list_id, conn);
			new GeneListAnalysis().deleteAllGeneListAnalysisResultsForGeneList(gene_list_id, conn);
			new ParameterValue().deleteParameterValues(this.getParameter_group_id(), conn);

			this.setAlternateIdentifierSource("All");
			deleteGenesForGeneList(gene_list_id, conn);
	
  			String query =
  				"delete from gene_lists "+
				"where gene_list_id = ?";

  			PreparedStatement pstmt = conn.prepareStatement(query, 
        					ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
			pstmt.setInt(1, gene_list_id);

        		pstmt.executeUpdate();
			log.debug("just deleted gene list");
        		pstmt.close();
			conn.commit();

			/*
			// Need to figure this out -- delete files when deleting a gene list.  But right now don't have setUserMainDir for Gene Lists -- AAGH!
				boolean success = new FileHandler().deleteAllFilesPlusDirectory(new File(dsPath + "v" + version));
				if (!success) {
					Email myEmail = new Email();
					myEmail.setSubject("Error deleting files for dataset version");
					myEmail.setContent("Path is "+dsPath + "v" + version);
					try {
						myEmail.sendEmailToAdministrator();
					} catch (Exception e) {
						log.error("error sending message to administrator");
					}
				}
			*/

		} catch (SQLException e) {
			log.error("in exception of GeneList.deleteGeneList()", e);
			conn.rollback();
			throw e;
		}
		conn.setAutoCommit(true);
	}

        
        public void deleteGene_values(int gene_list_id,DataSource pool)throws SQLException {
            Connection conn=null;
            try{
                conn=pool.getConnection();
                deleteGene_values(gene_list_id,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
        }
        
  	/** 
	 * Deletes gene_values for a gene list.
	 * @param gene_list_id	the identifier of the gene list
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 */

	public void deleteGene_values(int gene_list_id, Connection conn) throws SQLException {

		log.debug("in deleteGene_values");
		String query =
			"delete from gene_values "+
			"where gene_list_id = ?";

		PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, gene_list_id);

		pstmt.executeUpdate();
		pstmt.close();
	}


        
        public void deleteAlternateIdentifiers(int gene_list_id,DataSource pool)throws SQLException {
            Connection conn=null;
            try{
                conn=pool.getConnection();
                deleteAlternateIdentifiers(gene_list_id,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
        }
        
  	/** 
	 * Deletes alternate_identifiers for a gene list.
	 * @param gene_list_id	the identifier of the gene list
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 */

	public void deleteAlternateIdentifiers(int gene_list_id, Connection conn) throws SQLException {

		log.debug("in deleteAlternateIdentifiers.source = " + this.getAlternateIdentifierSource());
		String query =
			"delete from alternate_identifiers "+
			"where gene_list_id = ? "+
			"and source like ? ";

		PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, gene_list_id);
                pstmt.setString(2, (this.getAlternateIdentifierSource().equals("All") ? "%" : this.getAlternateIdentifierSource()));

		pstmt.executeUpdate();
		pstmt.close();
	}


        public void deleteGenesForGeneList(int gene_list_id,DataSource pool)throws SQLException {
            Connection conn=null;
            try{
                conn=pool.getConnection();
                deleteGenesForGeneList(gene_list_id,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
        }
        
  	/** 
	 * Deletes genes, alternate_identifiers, and gene_values for a gene list.
	 * @param gene_list_id	the identifier of the gene list
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 */

	public void deleteGenesForGeneList(int gene_list_id, Connection conn) throws SQLException {

		log.debug("in deleteGenesForGeneList");

		deleteAlternateIdentifiers(gene_list_id, conn);
		deleteGene_values(gene_list_id, conn);
 	
		String query =
			"delete from genes "+
			"where gene_list_id = ?";

        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, gene_list_id);

                pstmt.executeUpdate();
		pstmt.close();

	}

        
        public void createAlternateIdentifiers(GeneList myGeneList,DataSource pool)throws SQLException {
            Connection conn=null;
            try{
                conn=pool.getConnection();
                createAlternateIdentifiers(myGeneList,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
        }
        
  	/** 
	 * Creates alternate_identifiers for a gene list.
	 * @param myGeneList	the GeneList object
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 */
  
	public void createAlternateIdentifiers(GeneList myGeneList, Connection conn) throws SQLException {

		String query = "";
		//
		// if the AlternateIdentifierSource has not been set, it will be defaulted to 'Current', but that
		// column cannot be included in the insert statement
		// 
		if (myGeneList.getAlternateIdentifierSource() != null && 
			!myGeneList.getAlternateIdentifierSource().equals("")) {

			//log.debug("alternate identifier source is not null");
        		query =
                	"insert into alternate_identifiers "+
			"(gene_list_id, gene_id, alternate_id, source_id, source_link_column, source) "+
                	"values "+
                	"(?, ?, ?, ?, ?, ?)";
		} else {
			//log.debug("alternate identifier source is null");
        		query =
                	"insert into alternate_identifiers "+
			"(gene_list_id, gene_id, alternate_id, source_id, source_link_column) "+
                	"values "+
                	"(?, ?, ?, ?, ?)";
		}

	
		//log.debug("in createAlternateIdentifiers");
		//log.debug("query = "+query);

        	PreparedStatement pstmt = null;
        	try {
                	pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
                	pstmt.setInt(1, myGeneList.getGene_list_id());

			if (myGeneList.getAlternateIdentifierSource() != null) {
				pstmt.setString(6, myGeneList.getAlternateIdentifierSource());
			} 
                	pstmt.setInt(4, myGeneList.getAlternateIdentifierSourceID());
                	pstmt.setString(5, myGeneList.getAlternateIdentifierSourceLinkColumn());

                	// insert each of the genes 
                	if (myGeneList.getGenesHash() != null) {

				log.debug("getGenesHash is not null.  it contains " + 
					myGeneList.getGenesHash().size() + " elements");

//				myDebugger.print(myGeneList.getGenesHash());
				Enumeration genesOriginal = myGeneList.getGenesHash().keys();
				while (genesOriginal.hasMoreElements()) {
					String originalID = (String) genesOriginal.nextElement();
					String alternateID = (String) myGeneList.getGenesHash().get(originalID);
					//log.debug("originalID = "+originalID + 
					//	", alternateID = "+alternateID + 
					//	", gene_list_id = "+myGeneList.getGene_list_id());

                                	pstmt.setString(2, originalID);
                                	pstmt.setString(3, alternateID);
                                	pstmt.executeUpdate();
                        	}
                	} else if (myGeneList.getGenesHashMap() != null) {
				//log.debug("getGenesHashMap is not null.  it contains " + 
				//	myGeneList.getGenesHashMap().size() + " elements");

				Set genesOriginal = myGeneList.getGenesHashMap().keySet();
				Iterator genesOriginalItr = genesOriginal.iterator();
				while (genesOriginalItr.hasNext()) {
					String originalID = (String) genesOriginalItr.next();
					String[] alternateIDs = (String[]) myGeneList.getGenesHashMap().get(originalID);
					//log.debug("orginial ID = " + originalID);
					//log.debug("alternatIDs = "); myDebugger.print(alternateIDs);
	                        	pstmt.setString(2, originalID);
					for (int i=0; i<alternateIDs.length; i++) {
						if (!alternateIDs[i].equals(originalID)) {
							pstmt.setString(3, alternateIDs[i]);
       	                         			pstmt.executeUpdate();
						}
					}
                        	}
			} else {
				//log.debug("getGenesHash and getGenesHashMap are both null");
			}
			pstmt.close();

        	} catch (SQLException e) {
                	log.error("In exception of createAlternateIdentifiers", e);
			throw e;
        	}
	}

        public void createGeneListUsers(DataSource pool)throws SQLException {
            Connection conn=null;
            try{
                conn=pool.getConnection();
                createGeneListUsers(conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
        }
        
  	/** 
	 * Creates a record in the gene_list_users table for every user who has access to this genelist.
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 */
	public void createGeneListUsers(Connection conn) throws SQLException {

		log.debug("in createGeneListUsers.  gene_list_id = "+this.getGene_list_id());
        	String query =
                	"insert into user_gene_lists "+
			"(gene_list_id, user_id) "+
                	"values "+
                	"(?, ?)";

        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, this.getGene_list_id());

		//
                // insert each of the users 
		//
                if (this.getGene_list_users() != null) {
			log.debug("are there any users? YES");
			Iterator iterator = this.getGene_list_users().iterator();
                	while (iterator.hasNext()) {
                        	pstmt.setInt(2, Integer.parseInt(iterator.next().toString()));
                                pstmt.executeUpdate();
                        }
                } else {
			log.debug("are there any users? NO");
		}
		pstmt.close();

	}

	/**
	 * Constructs the path where the files for analyses performed on this GeneList will be held.
	 * @param userMainDir	the user's top directory
	 * @return            a String containing the path for analyses performed on this GeneList
	 */
  	public String getGeneListAnalysisDir(String userMainDir) {
        	String geneListAnalysisDir = userMainDir + "GeneLists" + "/" +
                        	// replace all spaces and apostrophes with blanks
                        	new ObjectHandler().removeBadCharacters(this.getGene_list_name()) + "/"; 
		return geneListAnalysisDir;
  	}

	/**
	 * Constructs the path where the files for oPOSSUM analyses performed on this GeneList will be held.
	 * @param geneListAnalysisDir	the directory where all analyses for this GeneList will be held 
	 * @return            a String containing the path for this oPOSSUM analysis
	 */
  	public String getOPOSSUMDir(String geneListAnalysisDir) {
		return geneListAnalysisDir + "oPOSSUM" + "/"; 
  	}

	/**
	 * Constructs the path where the files for a MEME analyses performed on this GeneList will be held.
	 * @param geneListAnalysisDir	the directory where all analyses for this GeneList will be held 
	 * @return            a String containing the path for this MEME analysis
	 */
  	public String getMemeDir(String geneListAnalysisDir,String now) {
		return geneListAnalysisDir + "MEME" + "/"+now+"/"; 
  	}
        
        /**
	 * Constructs the path where the files for a MEME analyses performed on this GeneList will be held.
	 * @param geneListAnalysisDir	the directory where all analyses for this GeneList will be held 
	 * @return            a String containing the path for this MEME analysis
	 */
  	public String getMemeDir(String geneListAnalysisDir) {
		return geneListAnalysisDir + "MEME" + "/"; 
  	}

	/**
	 * Constructs the path where the files for an upstream extraction performed on this GeneList will be held.
	 * @param geneListAnalysisDir	the directory where all analyses for this GeneList will be held 
	 * @return            a String containing the path for this upstream extraction
	 */

  	public String getUpstreamDir(String geneListAnalysisDir) {
		return geneListAnalysisDir + "UpstreamExtraction" + "/"; 
  	}

	/**
	 * Constructs the path where the files for a pathway analysis performed on this GeneList will be held.
	 * @param geneListAnalysisDir	the directory where all analyses for this GeneList will be held 
	 * @return            a String containing the path for this pathway analysis
	 */

  	public String getPathwayDir(String geneListAnalysisDir) {
		return geneListAnalysisDir + "Pathway" + "/"; 
  	}
        
        /**
	 * Constructs the path where the files for a pathway analysis performed on this GeneList will be held.
	 * @param geneListAnalysisDir	the directory where all analyses for this GeneList will be held 
	 * @return            a String containing the path for this pathway analysis
	 */

  	public String getMultiMiRDir(String geneListAnalysisDir) {
		return geneListAnalysisDir + "multiMir" + "/"; 
  	}
        
        public String getGODir(String geneListAnalysisDir) {
		return geneListAnalysisDir + "GO" + "/"; 
  	}

  	/** Retrieves the prefix for the files created during a MEME execution.  The prefix is the location of the userFiles directory +
	 * the gene list name + "_" + the createDate + "_" + "MEME". 
	 * @param memeDir	The directory where the file will be located.
	 * @param createDate	The current date and time
	 * @return	A prefix for the file name.  For example, 
	 * 	"/data/userFiles/ckh/GeneLists/1-wayANOVAwithcontrast/MEME/1-wayANOVAwithcontrast_07112007_160839_MEME"
	 */
	public String getMemeFileName(String memeDir, String createDate) {
		return memeDir + 
			new ObjectHandler().removeBadCharacters(this.getGene_list_name()) +
			"_" + createDate + "_" + 
			"MEME";
	}

  	/** Constructs the name of the file created during an upstream extraction.  
	 * The prefix is the location of the upstream extraction directory +
	 * the gene list name + "_" + the create date and time + "_" + the upstream length + "bp.fasta.txt". 
	 * @param upstreamDir	The directory where the file will be located.
	 * @param upstreamLength	The length of the sequence to be extracted.
	 * @param createDate	The date and time of the upstream extraction
	 * @return	the file name.  For example,
	 * 	"/data/userFiles/ckh/GeneLists/1-wayANOVAwithcontrast/UpstreamExtraction/1-wayANOVAwithcontrast_02122008_110210_2000bp.fasta.txt"
	 */
	public String getUpstreamFileName(String upstreamDir, int upstreamLength, String createDate) {
		return upstreamDir + 
			new ObjectHandler().removeBadCharacters(this.getGene_list_name()) + 
			"_" + createDate + "_" + upstreamLength + "bp.fasta.txt";
	}


        
          public GeneList[] getGeneListsForDatasetVersion(Dataset.DatasetVersion datasetVersion,DataSource pool)throws SQLException {
            Connection conn=null;
            GeneList[] tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGeneListsForDatasetVersion(datasetVersion,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
            return tmp;
        }
        
  	/** Retrieves the gene lists for a particular dataset version.
	 * @param datasetVersion	the DatasetVersion object
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 * @return	An array of GeneList objects           
	 */
  	public GeneList[] getGeneListsForDatasetVersion(Dataset.DatasetVersion datasetVersion, Connection conn) throws SQLException {

		//log.debug("in getGeneListsforDatasetVersion. dataset_id = " + datasetVersion.getDataset().getDataset_id() + "version = "+datasetVersion.getVersion());

		String query = 
			geneListSelectClause + 
			geneListFromClause + 
                	"where gl.dataset_id = ? "+
                	"and gl.version = ? "+
			geneListGroupByClause + 
                	"order by gl.gene_list_name";

		//log.debug("query = "+query);

		Results myResults = new Results(query, new Object[] {datasetVersion.getDataset().getDataset_id(), datasetVersion.getVersion()}, conn);
		String dataRow[] = null;

		List<GeneList> geneLists = new ArrayList<GeneList>();
		while ((dataRow = myResults.getNextRow()) != null) {
			GeneList thisGeneList = setupGeneListValues(dataRow);
                	geneLists.add(thisGeneList);
        	}
        	myResults.close();

		GeneList[] geneListArray = (GeneList[]) myObjectHandler.getAsArray(geneLists, GeneList.class);

		return geneListArray;

  	}

        
        public GeneList[] getGeneListsForAllDatasetsForUser(int user_id,DataSource pool)throws SQLException {
            Connection conn=null;
            GeneList[] tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGeneListsForAllDatasetsForUser(user_id,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
            return tmp;
        }
        
  	/** Retrieves the gene lists for all datasets created by a user or public 
	 * @param user_id	The ID of the user
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 * @return	An array of GeneList objects           
	 */
  	public GeneList[] getGeneListsForAllDatasetsForUser(int user_id, Connection conn) throws SQLException {
		//log.debug("in getGeneListsForAllDatasetsForUser. user_id = " + user_id); 

		String query = 
  			"select "+
			"gl.gene_list_id, "+
			"'', "+
			"gl.path, "+
        		"gl.gene_list_name, "+
        		"nvl(gl.description, 'No Description Entered') Description, "+
                	"0, "+
        		"gl.organism Organism, "+
			"'', "+
			"to_char(gl.create_date, 'mm/dd/yyyy hh12:mi AM') \"Date Created\", "+
			"to_char(gl.create_date, 'mmddyyyy_hh24miss'), "+
			"nvl(gl.dataset_id, -99), "+
			"nvl(gl.parameter_group_id, -99), "+
			"gl.created_by_user_id, "+
			"nvl(gl.version, -99), "+
			"gl.create_date "+
        		"from gene_lists gl, datasets ds "+
                	"where gl.dataset_id = ds.dataset_id "+
			"and gl.created_by_user_id = ? "+
			"and (ds.created_by_user_id = ? "+
			"or ds.created_by_user_id = "+
			"	(select user_id "+
			"	from users "+
			"	where user_name = 'public')) ";

		//log.debug("query = "+query);
		String[] dataRow;
		Results myResults = new Results(query, new Object[] {user_id, user_id}, conn);

		List<GeneList> geneLists = new ArrayList<GeneList>();
		while ((dataRow = myResults.getNextRow()) != null) {
			GeneList thisGeneList = setupGeneListValues(dataRow);
                	geneLists.add(thisGeneList);
        	}
        	myResults.close();

		GeneList[] geneListArray = (GeneList[]) myObjectHandler.getAsArray(geneLists, GeneList.class);

		return geneListArray;
	
  	}

        
        public GeneList[] getGeneListsForDataset(int user_id, int dataset_id, int version,DataSource pool)throws SQLException {
            Connection conn=null;
            GeneList[] tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGeneListsForDataset(user_id,dataset_id,version,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
            return tmp;
        }
        
  	/** Retrieves the gene lists for a particular dataset version that are viewable by this user 
	 * (including from public datasets).  Sorts by create_date descending.
	 * @param user_id	The ID of the user
	 * @param dataset_id	The ID of the dataset 
	 * @param version	The version number of the dataset or -99 to retrieve for all versions
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 * @return	An array of GeneList objects           
	 */
  	public GeneList[] getGeneListsForDataset(int user_id, 
						int dataset_id, 
						int version, 
						Connection conn) throws SQLException {
		log.debug("in getGeneListsForDataset. user_id = " + user_id + ", dataset_id = "+dataset_id + ", version = "+version);

		String query = 
			geneListSelectClause + 
			geneListFromClause + 
                	"where gl.created_by_user_id = ? "+
			"and (ds.created_by_user_id = ? "+
			"or ds.created_by_user_id = "+
			"	(select user_id "+
			"	from users "+
			"	where user_name = 'public')) "+
			"and dv.dataset_id = ? ";

			if (version != -99) {
				query = query + "and dv.version = ? ";
			} 

			query = query + 
			geneListGroupByClause +  
                	"order by gl.create_date desc";

		//log.debug("query = "+query);
		String[] dataRow;
		List<Integer> parameterList = new ArrayList<Integer>();

		parameterList.add(user_id);
		parameterList.add(user_id);
		parameterList.add(dataset_id);
		if (version != -99) {
			parameterList.add(version);
		}
		Object[] parameters = (Object[]) new ObjectHandler().getAsArray(parameterList, Integer.class); 
		Results myResults = new Results(query, parameters, conn);

		List<GeneList> geneLists = new ArrayList<GeneList>();
		while ((dataRow = myResults.getNextRow()) != null) {
			GeneList thisGeneList = setupGeneListValues(dataRow);
                	geneLists.add(thisGeneList);
        	}
        	myResults.close();

		GeneList[] geneListArray = (GeneList[]) myObjectHandler.getAsArray(geneLists, GeneList.class);

		return geneListArray;
	
  	}

        
        public User[] getGeneListUsers(int gene_list_id,DataSource pool)throws SQLException {
            Connection conn=null;
            User[] tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGeneListUsers(gene_list_id,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
            return tmp;
        }
        
  	/** Retrieves all the users, and checks the ones to which the uploaded gene list has been published.
	 * @param gene_list_id	The ID of the gene list 
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 * @return	a PreparedStatement
	 */
	public User[] getGeneListUsers(int gene_list_id, Connection conn) throws SQLException {

        	log.debug("In getGeneListUsers");

        	String query =
                	"select u.user_id, "+
                	"u.title||' '||u.first_name||' '||u.last_name \"User \", "+
                	"decode(ugl.user_id, null, 0, 1) "+
                	"from users u left join user_gene_lists ugl "+
                	"on u.user_id = ugl.user_id "+
                	"and ugl.gene_list_id = ? "+
			"and last_name != 'Guest' "+
			"and first_name != 'Public' "+
			"and u.approved = 'Y' "+
                	"order by upper(u.last_name)";

		//log.debug("query = "+query);

        	Results myResults = new Results(query, gene_list_id, conn);
		List<User> userList = new ArrayList<User>();
        	String[] dataRow;

        	while ((dataRow = myResults.getNextRow()) != null) {
        		User thisUser = new User().getUser(Integer.parseInt(dataRow[0]), conn); 
			thisUser.setChecked(Integer.parseInt(dataRow[2]));
			userList.add(thisUser);
		}

                User[] myUsers = (User[]) myObjectHandler.getAsArray(userList, User.class);

		myResults.close();

		return myUsers;
	}

        
        public GeneList[] getGeneLists(int user_id, String organism, String geneListTypes,DataSource pool)throws SQLException {
            Connection conn=null;
            GeneList[] tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGeneLists(user_id,organism,geneListTypes,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
            return tmp;
        }
        
  	/** Retrieves the set of gene lists available to this user.
 	 * It contains gene lists that were derived from the datasets viewable by this user 
	 * (including from public datasets)  
	 * PLUS the gene lists created by another user that have been granted to this user
	 * PLUS the gene lists uploaded by this user or created by this user for 
	 * literature search, QTL analysis, or promoter analysis.  It is sorted by create_date descending.
	 * @param user_id	The ID of the user who has access to the gene lists or -99 for all users
	 * @param organism	The organism of the gene lists requested or "All" or "MmOrRn" or "MmOrHs"
	 * @param geneListTypes	Types of genelists to include or "All"
	 * @param conn		the database connection
	 * @throws	SQLException if a database error occurs
	 * @return	An array of GeneList objects           
	 */
	public GeneList[] getGeneLists(int user_id, String organism, String geneListTypes, Connection conn) throws SQLException {

		String userSpecific1 = "";
		String userSpecific2 = "";
		String userSpecific3 = "";
		String orgSpecific = "";
		String typeSpecific = "";
		if (user_id != -99) {
			userSpecific1 = "and gl.created_by_user_id = ? ";
			userSpecific2 = "and gl.created_by_user_id != ? ";
			userSpecific3 = "and ugl.user_id = ? ";
		}
		if (organism.equals("All")) {
			orgSpecific = "%";
		} else if (organism.equals("MmOrRn")) {
			orgSpecific = "Mm' or gl.organism like 'Rn";
		} else if (organism.equals("MmOrHs")) {
			orgSpecific = "Mm' or gl.organism like 'Hs";
		} else {
			orgSpecific = organism; 
		}

		if (geneListTypes.equals("WithResults")) {
			typeSpecific = 
				"and (exists "+
				"	(select 'x' "+
				"	from gene_list_analyses gla "+
				"	where gla.gene_list_id = gl.gene_list_id)) ";
		}

  		String query = 
			geneListSelectClause + 
			geneListFromClause + 
        		"where gl.organism like '" + orgSpecific + "' "+
			userSpecific1 +
			typeSpecific + 
			geneListGroupByClause +  
        		"union "+ 
			geneListSelectClause + 
			geneListFromClause + 
			", user_gene_lists ugl "+
			"where ugl.gene_list_id = gl.gene_list_id "+
			"and (gl.organism like '" + orgSpecific + "') "+
			userSpecific2+
			userSpecific3+
			typeSpecific + 
			geneListGroupByClause +  
			"union "+
			geneListSelectClause + 
			geneListFromClause + 
			"where gl.gene_list_source != 'Statistical Analysis' "+
			"and (gl.organism like '" + orgSpecific + "') "+
			userSpecific1+
			typeSpecific + 
			geneListGroupByClause +  
			"order by 15 desc";
  		
		log.debug("in getGeneLists.");
		//log.debug("query = "+query);
	
		String[] dataRow;
		List<GeneList> geneLists = new ArrayList<GeneList>();

		Object[] parameters = new Object[4];
		if (user_id != -99) {
	        	parameters[0] = user_id;
        	    	parameters[1] = user_id;
            		parameters[2] = user_id;
	            	parameters[3] = user_id;
		}
		Results myResults = new Results(query, parameters, conn);

		while ((dataRow = myResults.getNextRow()) != null) {
			GeneList thisGeneList = setupGeneListValues(dataRow);

                	geneLists.add(thisGeneList);
        	}
        	myResults.close();

		GeneList[] geneListArray = (GeneList[]) myObjectHandler.getAsArray(geneLists, GeneList.class);

		return geneListArray;
  	}

	/**
   	 * Creates a new GeneList object and sets the data values to those retrieved from the database.
   	 * @param dataRow     the row of data corresponding to one GeneList
   	 * @return            a GeneList object with its values setup
   	 */
  	private GeneList setupGeneListValues(String[] dataRow) {

        	log.debug("in general setupGeneListValues");
        	log.debug("general dataRow= "); new Debugger().print(dataRow);

        	GeneList myGeneList = new GeneList();

        	myGeneList.setGene_list_id(Integer.parseInt(dataRow[0]));
        	myGeneList.setGene_list_owner(dataRow[1]);
        	myGeneList.setPath(dataRow[2] + "/");
        	myGeneList.setGene_list_name(dataRow[3]);
        	myGeneList.setGene_list_name_no_spaces(new ObjectHandler().removeBadCharacters(dataRow[3]));
        	myGeneList.setDescription(dataRow[4]);
        	myGeneList.setNumber_of_genes(Integer.parseInt(dataRow[5]));
        	myGeneList.setOrganism(dataRow[6]);
        	myGeneList.setGene_list_source(dataRow[7]);
        	myGeneList.setCreate_date_as_string(dataRow[8]);
		try {
        		myGeneList.setCreate_date(new ObjectHandler().getDisplayDateAsTimestamp(dataRow[8]));
		} catch (Exception e) {
			log.error("Couldn't parse date", e);
		}
		//log.debug("dataset_id = "+dataRow[10]);

        	myGeneList.setDataset_id(Integer.parseInt(dataRow[10]));
        	myGeneList.setParameter_group_id(Integer.parseInt(dataRow[11]));
        	myGeneList.setCreated_by_user_id(Integer.parseInt(dataRow[12]));
        	myGeneList.setVersion(Integer.parseInt(dataRow[13]));

        	return myGeneList;
  	}


        public String checkGenes(int geneListID,DataSource pool)throws SQLException {
            Connection conn=null;
            String tmp=null;
            try{
                conn=pool.getConnection();
                tmp=checkGenes(geneListID,conn);
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
   	* Gets the gene identifiers not found by iDecoder. 
   	* @param geneListID	id of the gene list to be checked
   	* @param conn	the database connection
   	* @throws            SQLException if a database error occurs
   	* @return            the set of identifiers in a single-column list separated by line feeds
   	*/
  	public String checkGenes(int geneListID, Connection conn) throws SQLException {

  		String query = 
                	"select gene_id "+
                	"from genes g, gene_lists gl "+
                	"where gl.gene_list_id = ? "+
			"and g.gene_list_id = gl.gene_list_id "+
			"and not exists "+
			"	(select 'x' "+
			"	from identifiers i "+
			"	where i.identifier = g.gene_id "+
			"	and gl.organism = i.organism)";

		//log.debug("in checkGenes.  query = "+query);
        	String[] dataRow;

		Results myResults = new Results(query, geneListID, conn);
		String listOfGenes = new ObjectHandler().getResultsAsSeparatedString(myResults, "\n", "", 0);

		myResults.close();
	
        	return listOfGenes;
  	}

        
        public int getStatisticCode(String columnHeading,DataSource pool)throws SQLException {
            Connection conn=null;
            int tmp=-99;
            try{
                conn=pool.getConnection();
                tmp=getStatisticCode(columnHeading,conn);
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
   	* Gets the numeric identifier for the statistic option passed in.
   	* @param columnHeading	name of the statistic 
   	* @param conn	the database connection
   	* @throws            SQLException if a database error occurs
   	* @return            the id number for the particular statistic or -99 if it does not exist
   	*/
  	public int getStatisticCode(String columnHeading, Connection conn) throws SQLException {

		//
		// Change the headings from what 'R' uses to what is displayed on the website
		//
		if (columnHeading.equals("F.statistic")) {
			columnHeading = "F-statistic";
		} else if (columnHeading.equals("correlation.coefficient")) {
			columnHeading = "Correlation Coefficient";
		} else if (columnHeading.equals("raw.p.value")) {
			columnHeading = "Raw P-value";
		} else if (columnHeading.equals("adjusted.p.value")) {
			columnHeading = "Adjusted P-value";
		}

  		String query = 
                	"select statistic_code "+
                	"from statistic_codes "+
                	"where description = ?";

		//log.debug("query = "+query);
		int statisticCode = -99;
        	String[] dataRow;

		Results myResults = new Results(query, columnHeading, conn);

        	while ((dataRow = myResults.getNextRow()) != null) {
			statisticCode = Integer.parseInt(dataRow[0]);
		}

		myResults.close();
	
        	return statisticCode;
  	}

        
        public int createStatisticCode(String columnHeading, int sortOrder, String statisticType,DataSource pool)throws SQLException {
            Connection conn=null;
            int tmp=-99;
            try{
                conn=pool.getConnection();
                tmp=createStatisticCode(columnHeading,sortOrder,statisticType,conn);
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
   	* Creates a record in the statistic_codes table for those gene lists that have dynamically-created column names, such
   	* as the 2-WAY ANOVA.
   	* @param columnHeading	name of the statistic 
   	* @param sortOrder	the order in which this column is to appear
   	* @param statisticType	either '2-Way ANOVA' or 'Correlation'
   	* @param conn	the database connection
   	* @throws            SQLException if a database error occurs
   	* @return            the id number for the particular statistic code 
   	*/
  	public int createStatisticCode(String columnHeading, int sortOrder, String statisticType, Connection conn) throws SQLException {

		//log.info("in createStatisticCode.");

  		String query = 
                	"insert into statistic_codes "+
			"(statistic_code, description, sort_order, experiment_type) "+
			"values "+
                	"(?, ?, ?, ?)";

		PreparedStatement pstmt = null;
		//log.debug("query = "+query);
		int statisticCode = -99;
	
		try {
			statisticCode = myDbUtils.getUniqueID("statistic_codes_seq", conn);
        		pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
            		pstmt.setInt(1, statisticCode);
            		pstmt.setString(2, columnHeading);
            		pstmt.setInt(3, sortOrder);
            		pstmt.setString(4, statisticType);
			pstmt.executeUpdate();

		} catch (SQLException e) {
			log.error("in exception of createStatisticCode", e);
			throw e;
		}

		pstmt.close();
        	return statisticCode;
  	}

        
        public int loadFromFile(int numGroups, String filename,DataSource pool)throws SQLException, IOException {
            Connection conn=null;
            int tmp=-99;
            try{
                conn=pool.getConnection();
                tmp=loadFromFile(numGroups,filename,conn);
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
   	* Loads genes from a flatfile.
   	* @param numGroups	the number of groups that have group means in the flat file
   	* @param filename	the full name of the file
   	* @param conn	the database connection
   	* @throws            SQLException if a database error occurs
   	* @throws            IOException if the file cannot be accessed
   	* @return            the id of the gene list that was created
   	*/
  	public int loadFromFile(int numGroups, String filename, Connection conn) throws SQLException, IOException {

		log.debug("in loadFromFile");
		conn.setAutoCommit(false);
		int gene_list_id = createGeneList(conn);
		log.info("just created gene list.  the ID is " + gene_list_id);

		//
		// This will retrieve all the fields not set in createGeneList, like anovaPValue
		//
		GeneList thisGeneList = getGeneList(gene_list_id, conn);

		FileHandler fileReader = new FileHandler();
		String[] fileContents = fileReader.getFileContents(new File(filename), "spaces");

		log.debug("file contains "+ fileContents.length + " genes.");

		boolean geneListFromOtherAnalysis = (filename.indexOf("genetext.output.txt") > -1 ? true : false); 
		boolean geneListFromClusterAnalysis = (filename.indexOf("ClusterSummary") > -1 ? true : false); 
		boolean geneListFromAnalysis = (geneListFromOtherAnalysis || geneListFromClusterAnalysis);
		
		log.debug("geneListFromOtherAnalysis = "+geneListFromOtherAnalysis);
		log.debug("geneListFromClusterAnalysis = "+geneListFromClusterAnalysis);
		log.debug("geneListFromAnalysis = "+geneListFromAnalysis);
		String gv_query = ""; 
		String query = "insert into genes "+
			"(gene_list_id, gene_id) "+
			"values (?, ?)";
		if (geneListFromAnalysis) {
			gv_query = "insert into gene_values "+
			"(gene_list_id, gene_id, statistic_code, group_number, value) "+
			"values (?, ?, ?, ?, ?)";
			//log.debug("gv_query = " + gv_query);
		}

		PreparedStatement pstmt = null; 
		OraclePreparedStatement gv_pstmt = null; 
		log.debug("filename = " + filename);
		//log.debug("query = " + query);
		String gene_id = "";
		try {
			String statisticalMethod = "";
			String [] fields = null;
			String [] headers = null;
			int [] headerCodes = null;
			int startLine = 0;
			this.genesHash = new Hashtable<String,String>();

                	pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
			if (geneListFromAnalysis) {
                		gv_pstmt = (OraclePreparedStatement) conn.prepareStatement(gv_query, 
							ResultSet.TYPE_SCROLL_INSENSITIVE,
							ResultSet.CONCUR_UPDATABLE);
				statisticalMethod = thisGeneList.getStatisticalMethod();
			}
			//
			// Strip off the column headers for gene lists created from analysis 
			//
			if (geneListFromAnalysis) {
				// 
				// this creates valid statistics codes to use as column headings
				//
				headers = fileContents[0].split("[\\s]+");
				// 
				// headerCodes contains the statistic_codes values for all but the first column
				//
				headerCodes = new int[headers.length-1];
				// 
				// Starting from the 2nd column, load the column headers
				//
				for (int j=1; j<headers.length; j++) {
					int i=j-1;
					if ((headerCodes[i] = getStatisticCode(headers[j], conn)) == -99) {
						String statisticType = statisticalMethod;
						if (statisticalMethod.equals("pearson") || 
							statisticalMethod.equals("spearman")) {
							statisticType = "Correlation";
						}
						if (statisticalMethod.equals("kmeans") || 
							statisticalMethod.equals("hierarch")) {
							statisticType = "Cluster";
						}
						headerCodes[i] = createStatisticCode(headers[j], 50, statisticType, conn);
					}
					//log.debug("headerCodes ["+i+"] for header " + headers[j] + " = "+headerCodes[i]);
				}
				// 
				// files created from cluster analysis have the cluster number in the second line, so start 
				// loading after that line
				// 
				if (geneListFromClusterAnalysis) {
					startLine = 2;
				} else {
					startLine = 1;
				}	
			}
			for (int i=startLine; i<fileContents.length; i++) {
				if (!fileContents[i].equals("")) {
                                        //
					// files generated by statistical analysis will have more fields
					//	
					if (geneListFromAnalysis) {
						//log.debug("uploading a genelist created by statistical analysis.  fileContents = ");
						// myDebugger.print(fileContents[i]);
						//
						// set the gene id, which is the first field in the line
						//
						fields = fileContents[i].split("[\\s]+");
						//log.debug("number of fields = "+fields.length);
						//log.debug("fields = "); myDebugger.print(fields);

						gene_id = fields[0];
					//
					// uploaded files should have just one field on each line,
					//
					} else {
						//log.debug("uploading a file.  fileContents[i]  = "+fileContents[i]);
						gene_id = fileContents[i].replaceAll("[\\s]","");
					}
                                        if(!genesHash.containsKey(gene_id)){
                                            pstmt.setInt(1, gene_list_id);
                                            pstmt.setString(2, gene_id);
                                            pstmt.execute();
                                            this.genesHash.put(gene_id, gene_id);
                                            if (geneListFromAnalysis) {
                                                    gv_pstmt.setInt(1, gene_list_id);
                                                    gv_pstmt.setString(2, gene_id);
                                                    if (thisGeneList.getDataset_id() != -99) { 
                                                            String anovaPValue = thisGeneList.getAnovaPValue();
                                                            //
                                                            // this uses the previously defined statistics codes as column headings
                                                            // Note that this already takes care of the rawp, adjp, etc columns
                                                            //
                                                            for (int j=0; j<headerCodes.length; j++) {
                                                                    //log.debug("creating a record for headerCodes = "+headerCodes[j]+
                                                                    //	", the value is "+fields[j+1]);
                                                                    gv_pstmt.setInt(3, headerCodes[j]);
                                                                    gv_pstmt.setString(4, Integer.toString(j+1));
                                                                    gv_pstmt.setBinaryDouble(5, Double.parseDouble(fields[j+1]));
                                                                    gv_pstmt.addBatch();
                                                            }
                                                    }
                                                    gv_pstmt.executeBatch();
                                                    gv_pstmt.clearBatch();
                                            }
                                        }
				}
			}
			log.debug("just uploaded last gene and ready to close pstmt.  Then will create Alternate Identifiers");
			pstmt.close();
			if (geneListFromAnalysis) {
				gv_pstmt.close();
			}
			log.debug("creating alternate identifiers");
			createAlternateIdentifiers(this, conn);
			conn.commit();

		} catch (SQLException e) {
			if (e.getErrorCode() == 1) {
                		log.error("Got a duplicate key SQLException while in loadFromFile for gene_id = " + gene_id);
			}
			log.error("in exception of loadFromFile", e);
			conn.rollback();
			throw e;
		}
		conn.setAutoCommit(true);
		return gene_list_id;
  	}
  
        
        public void loadGeneListFromList(List geneList, int gene_list_id,DataSource pool)throws SQLException, IOException {
            Connection conn=null;
            try{
                conn=pool.getConnection();
                loadGeneListFromList(geneList,gene_list_id,conn);
                conn.close();
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
        }
        
  	/**
   	* Loads genes from a List.
   	* @param geneList	the List of gene identifiers
   	* @param gene_list_id	the id of the genelist 
   	* @param conn	the database connection
   	* @throws            SQLException if a database error occurs
   	*/
  	public void loadGeneListFromList(List geneList, int gene_list_id, Connection conn) throws SQLException {

		conn.setAutoCommit(false);
  		log.debug("List contains "+ geneList.size() + " genes.");

		String query = 
			"insert into genes "+
			"(gene_list_id, gene_id) "+
			"values (?, ?)";

		log.info("in loadGeneListFromList");
		//log.info("query = "+query);
		try {
			PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
			String gene_id = "";
			this.genesHash = new Hashtable<String,String>();
			for (int i=0; i<geneList.size(); i++) {
				gene_id = (String)geneList.get(i);

				pstmt.setInt(1, gene_list_id);
				pstmt.setString(2, gene_id);

				//
				// create a hash with the gene_id as the currentID and the alternateID to
				// insert into alternate_identifiers table
				// 
				this.genesHash.put(gene_id, gene_id);

				pstmt.executeUpdate();
			}
			//log.debug("this.genesHash = "); myDebugger.print(this.genesHash);
			this.setGene_list_id(gene_list_id);
			createAlternateIdentifiers(this, conn);
			conn.commit();
			pstmt.close();

		} catch (SQLException e) {
			log.error("in exception of loadGeneListFromList", e);
			conn.rollback();
			throw e;
		}
		conn.setAutoCommit(true);
  	}
        
        
        public Set<String> getProbeIDsWithNoGeneSymbols(DataSource pool)throws SQLException {
            Connection conn=null;
            Set<String> tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getProbeIDsWithNoGeneSymbols(conn);
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
	 * Gets the probeIDs for genes that are Affy Mouse MOE430 v2 or CodeLink Whole Genome probeset IDs that do not have gene symbols.
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a Set of Strings containing gene symbols
	 */

	public Set<String> getProbeIDsWithNoGeneSymbols(Connection conn) throws SQLException {

		log.debug("in getProbeIDsWithNoGeneSymbols");
		Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();
		String chip_names = "(" + myObjectHandler.getAsSeparatedString(myArray.EQTL_ARRAY_TYPES, ",", "'") + ")";
        	String query =
			"select g.gene_id "+
			"from genes g left join gene_symbols gs "+
			"        on g.gene_id = gs.identifier, "+
			"probesets p, "+
			"identifiers id left join identifier_arrays array "+ 
			"        on id.id_number = array.id_number "+
			"where g.gene_id = id.identifier "+
			"and p.identifier = g.gene_id "+
			"and g.gene_list_id = ? "+
			"and gs.gene_name is null "+
			"and p.chromosome is not null "+
			"and array.array_name in  "+
			chip_names + 
/*
			"('Mouse Genome 430 2.0 Array', "+
			"'CodeLink Mouse Whole Genome Array') "+
*/
			" order by 1";

        	//log.debug("in getProbeIDsWithNoGeneSymbols. gene_list_id = "+this.getGene_list_id());
        	//log.debug("query = "+query);

                Results myResults = new Results(query, this.getGene_list_id(), conn);

		Set<String> setOfIDs = new ObjectHandler().getResultsAsSet(myResults, 0);
		myResults.close();

        	return setOfIDs;
	}

        
        public Hashtable<String, List<String>> getGeneSymbolsForProbeIDs(DataSource pool)throws SQLException {
            Connection conn=null;
            Hashtable<String, List<String>> tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGeneSymbolsForProbeIDs(conn);
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
	 * Gets the gene symbols for genes that are Affy Mouse MOE430 v2 or CodeLink Whole Genome probeset IDs
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a Hashtable mapping probeset IDs to gene symbols from the eQTL data
	 */

	public Hashtable<String, List<String>> getGeneSymbolsForProbeIDs(Connection conn) throws SQLException {

		log.debug("in getGeneSymbolsForProbeIDs");
		Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();
		String chip_names = "(" + myObjectHandler.getAsSeparatedString(myArray.EQTL_ARRAY_TYPES, ",", "'") + ")";

        	String query =
			"select gs.identifier, gs.gene_name "+
			"from genes g left join gene_symbols gs  "+
			"        on g.gene_id = gs.identifier, "+
			"identifiers id left join identifier_arrays array  "+
			"        on id.id_number = array.id_number "+
			"where g.gene_id = id.identifier "+
			"and g.gene_list_id = ? "+
			"and gs.gene_name is not null "+
			"and array.array_name in "+
			chip_names + 
/*
			"('Mouse Genome 430 2.0 Array', "+
			"'CodeLink Mouse Whole Genome Array') "+
*/
			" order by 1";

        	//log.debug("in getGeneSymbolsForProbeIDs. gene_list_id = "+this.getGene_list_id());
        	//log.debug("query = "+query);

                Results myResults = new Results(query, this.getGene_list_id(), conn);

		Hashtable<String, List<String>> hashOfProbeIDs = new ObjectHandler().getResultsAsHashtablePlusList(myResults);

                myResults.close();

        	return hashOfProbeIDs;
	}

        
        public Set<String> getProbeIDsWithNoGeneSymbolsOrPhysicalLocation(DataSource pool)throws SQLException {
            Connection conn=null;
            Set<String> tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getProbeIDsWithNoGeneSymbolsOrPhysicalLocation(conn);
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
	 * Gets the probeIDs for genes that are Affy Mouse MOE430 v2 or CodeLink Whole Genome probeset IDs that do not have gene symbols
	 * or physical location.
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a Set of Strings containing gene symbols
	 */

	public Set<String> getProbeIDsWithNoGeneSymbolsOrPhysicalLocation(Connection conn) throws SQLException {

		log.debug("in getProbeIDsWithNoGeneSymbolsOrPhysicalLocation");
		Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();
		String chip_names = "(" + myObjectHandler.getAsSeparatedString(myArray.EQTL_ARRAY_TYPES, ",", "'") + ")";

        	String query =
			"select g.gene_id "+
			"from genes g left join gene_symbols gs "+
			"        on g.gene_id = gs.identifier, "+
			"probesets p, "+
			"identifiers id left join identifier_arrays array "+ 
			"        on id.id_number = array.id_number "+
			"where g.gene_id = id.identifier "+
			"and p.identifier = g.gene_id "+
			"and g.gene_list_id = ? "+
			"and gs.gene_name is null "+
			"and p.chromosome is null "+
			"and array.array_name in  "+
			chip_names + 
/*
			"('Mouse Genome 430 2.0 Array', "+
			"'CodeLink Mouse Whole Genome Array') "+
*/
			" order by 1";

        	//log.debug("in getProbeIDsWithNoGeneSymbolsOrPhysicalLocation. gene_list_id = "+this.getGene_list_id());
        	log.debug("query = "+query);

                Results myResults = new Results(query, this.getGene_list_id(), conn);

		Set<String> setOfIDs = new ObjectHandler().getResultsAsSet(myResults, 0);
		myResults.close();

        	return setOfIDs;
	}
  
        
        public Set<String> getNonProbeIDs(DataSource pool)throws SQLException {
            Connection conn=null;
            Set<String> tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getNonProbeIDs(conn);
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
	 * Gets genes that are not Affy Mouse MOE430 v2 or CodeLink Whole Genome identifiers
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a Set of Strings containing gene identifiers
	 */

	public Set<String> getNonProbeIDs(Connection conn) throws SQLException {

		log.debug("in getNonProbeIDs");
		Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();
		String chip_names = "(" + myObjectHandler.getAsSeparatedString(myArray.EQTL_ARRAY_TYPES, ",", "'") + ")";

        	String query =
			"select g.gene_id "+
			"from genes g "+
			"where g.gene_list_id = ? "+
			"minus "+
			"select g.gene_id "+
			"from genes g, "+
			"identifiers id left join identifier_arrays array "+
			"	on id.id_number = array.id_number "+
			"where g.gene_id = id.identifier "+
			"and g.gene_list_id = ? "+
			"and array.array_name in "+
			chip_names + 
/*
			"('Mouse Genome 430 2.0 Array', "+
			"'CodeLink Mouse Whole Genome Array') "+
*/
			" order by 1";

        	//log.debug("in getNonProbeIDs. gene_list_id = "+this.getGene_list_id());
        	//log.debug("query = "+query);

                Results myResults = new Results(query, new Object[] {this.getGene_list_id(), this.getGene_list_id()}, conn);

		Set<String> setOfIDs = new ObjectHandler().getResultsAsSet(myResults, 0);
		myResults.close();

        	return setOfIDs;
	}

        
        public Gene[] findContainingGeneLists(int user_id,DataSource pool)throws SQLException {
            Connection conn=null;
            Gene[] tmp=null;
            try{
                conn=pool.getConnection();
                tmp=findContainingGeneLists(user_id,conn);
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
	 * Gets gene lists that contain the identifiers in this gene list
	 * @param user_id	the id of the user logged in
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of Gene objects from this gene list, with the Set of containing GeneLists attached
	 */

	public Gene[] findContainingGeneLists(int user_id, Connection conn) throws SQLException {

        	String query =
			"select a.gene_id, "+
			"b.gene_list_id, "+
			"gl.gene_list_name, "+
			"b.gene_id "+
			"from genes a "+
			"left join genes b "+
			"	on a.gene_id = b.gene_id "+
			"	and b.gene_list_id != a.gene_list_id "+
			"left join gene_lists gl "+
			"	on b.gene_list_id = gl.gene_list_id "+
			"left join user_gene_lists ugl "+
			"	on ugl.gene_list_id = gl.gene_list_id "+
			"	and ugl.user_id = ? "+
			"where a.gene_list_id = ? "+
			// if b.gene_list_id is null, then this id is not in any other gene lists
			// if ugl.user_id is not null, then this person has access to this gene list
			"and (b.gene_list_id is null or ugl.user_id is not null) "+
			"order by a.gene_id, gl.gene_list_name";

        	log.debug("in findContainingGeneLists. gene_list_id = "+this.getGene_list_id());
        	//log.debug("query = "+query);

                Results myResults = new Results(query, new Object[] {user_id, this.getGene_list_id()}, conn);

		Gene latestGene = new Gene();
        	List<Gene> myGenes = new ArrayList<Gene>();

		String thisGeneID = "";
        	//
        	// initialize this to 'X' so that the first iteration will work correctly
        	//
        	String lastGeneID = "X";
        	Set<GeneList> theSet = null;
		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {
			thisGeneID = dataRow[0];
			int containingGeneListID = (dataRow[1] != null ? Integer.parseInt(dataRow[1]) : -99);
			//log.debug("thisGeneID = "+thisGeneID + ", and containingGeneListID = "+containingGeneListID);

			GeneList thisGeneList = new GeneList(containingGeneListID, dataRow[2]);
                	//
                	// If the value in first column is the same as the value in the
                	// first column of the previous record and the gene_list_id column is not null,
			// add another GeneList to the list of containing gene lists 
                	// Otherwise, close out this list
                	// and set the containing gene lists for the Gene.
                	//
                	if (thisGeneID.equals(lastGeneID) && containingGeneListID != -99) {
				//log.debug("geneIDs are the same");
				latestGene.getContainingGeneLists().add(thisGeneList);
                	} else {
				//log.debug("geneIDs are not the same");
				Gene newGene = new Gene(this.getGene_list_id(), thisGeneID);
				if (containingGeneListID != -99) {
					theSet = new LinkedHashSet<GeneList>();
					theSet.add(thisGeneList);
					//log.debug("just created the Set and now adding to it");
					newGene.setContainingGeneLists(theSet);
				}
				latestGene = newGene;
				myGenes.add(latestGene);
                	}
			//log.debug("this Gene = "); myDebugger.print(latestGene);
			//if (latestGene.getContainingGeneLists() != null) 
			//	log.debug("containingGeneLists= "); myDebugger.print(latestGene.getContainingGeneLists());
                	lastGeneID = thisGeneID;
		}
		myResults.close();

        	Gene[] myGeneArray = (Gene[]) myObjectHandler.getAsArray(myGenes, Gene.class);
		//log.debug("done with findContainingGeneLists. myGeneArray contains this many entries: "+myGeneArray.length);

        	return myGeneArray;
	}

        
        public Gene[] getGenesAsGeneArray(DataSource pool)throws SQLException {
            Connection conn=null;
            Gene[] tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGenesAsGeneArray(conn);
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
	 * Gets genes that are part of the gene_list.  
	 * Queries the 'Current' alternate identifiers plus the p-values obtained 
	 * by statistical analyis of a dataset. 
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of Gene objects in the gene list 
	 */
	public Gene[] getGenesAsGeneArray(Connection conn) throws SQLException {

        	String query =
                	"select g.gene_list_id, "+
                	"g.gene_id \"Original Accession ID\", "+
                	"ai.alternate_id \"Current Selection\", "+
                	"to_char(gv.value, '9.9999EEEE') "+
                	"from genes g left join gene_values gv "+
			"	on gv.gene_list_id = g.gene_list_id and gv.gene_id = g.gene_id "+
			"left join statistic_codes sc on gv.statistic_code = sc.statistic_code "+
			"left join alternate_identifiers ai on ai.gene_list_id = g.gene_list_id "+
                	"and ai.gene_id = g.gene_id "+
                	"and ai.source = 'Current' "+
                	"where g.gene_list_id = ? "+
                	"order by g.gene_list_id, "+
			"g.gene_id, "+
			"sc.sort_order, "+
			"decode(gv.group_number, 'NA', 0, to_number(gv.group_number))";

        	//log.debug("in getGenesAsGeneArray. gene_list_id = "+this.getGene_list_id());
        	//log.debug("query = "+query);
		Gene latestGene = new Gene();

		Results myResults = new Results(query, this.getGene_list_id(), conn);
        	List<Gene> myGenes = new ArrayList<Gene>();

		String thisGeneID = "";
        	//
        	// initialize this to 'X' so that the first iteration will work correctly
        	//
        	String lastGeneID = "X";
        	List<Double> theList = null;
		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {
			int geneListID = Integer.parseInt(dataRow[0]);
			String geneID = dataRow[1];
			String currentIdentifier = dataRow[2];
			Double statisticsValue = null;
			if (dataRow[3] != null && !dataRow[3].equals("")) {
				statisticsValue = new Double(dataRow[3]);
			}

                	thisGeneID = geneListID +" "+geneID;

                	//
                	// If the value in first 2 columns is the same as the value in the
                	// first 2 columns of the previous record, add the value in the third
                	// column to the list of statistics values.  Otherwise, close out this list
                	// and set the statisticsValues list for the Gene.
                	//
                	if (thisGeneID.equals(lastGeneID) && statisticsValue != null) {
				((List<Double>) latestGene.getStatisticsValues()).add(statisticsValue);
				String[] sameGeneRow = null;
				while ((sameGeneRow = myResults.getNextRow()) != null && 
					thisGeneID.equals(Integer.parseInt(sameGeneRow[0]) + " "+ sameGeneRow[1]) &&
					sameGeneRow[3] != null &&
					!sameGeneRow[3].equals("")) {

					//int i = myGenes.indexOf(new Gene(geneListID, geneID));
					//Collections.sort(myGenes);
					//int i = Collections.binarySearch(myGenes, new Gene(geneListID, geneID));
					//log.debug("addings statisticsValue to existingList");

					((List<Double>) latestGene.getStatisticsValues()).add(new Double(sameGeneRow[3]));
				}
				// Go back one row
				myResults.getPreviousRow();
				// Not sure why this was here -- should only need to be added once
				//myGenes.add(latestGene);
                	} else {
				Gene newGene = new Gene();
				newGene.setGene_list_id(geneListID);
				newGene.setGene_id(geneID);
				newGene.setCurrent_identifier(currentIdentifier);
				//log.debug("just set currentIdentifier to "+currentIdentifier +" for gene "+geneID);
				if (statisticsValue != null) {
					theList = new ArrayList<Double>();
					theList.add(statisticsValue);
					newGene.setStatisticsValues(theList);
				}
				latestGene = newGene;
				myGenes.add(latestGene);
				//newGene.print();
                	}
                	lastGeneID = geneListID +" "+geneID;
		}
		myResults.close();

        	Gene[] myGeneArray = (Gene[]) myObjectHandler.getAsArray(myGenes, Gene.class);
		//log.debug("done with getGenesAsGeneArray. myGeneArray contains this many entries: "+myGeneArray.length);

        	return myGeneArray;
	}

        
        public Set<String> getGenesAsSet(String whichIdentifier,DataSource pool)throws SQLException {
            Connection conn=null;
            TreeSet<String> geneSet = new TreeSet<String>();
            try{
                Gene[] myGeneArray = getGenesAsGeneArray(pool);
                for (int i=0; i<myGeneArray.length; i++) {
			if (whichIdentifier.equals("Original")) {
				geneSet.add(myGeneArray[i].getGene_id());
                	} else if (whichIdentifier.equals("Current")) {
				geneSet.add(myGeneArray[i].getCurrent_identifier());
                	} else {
                        	log.error("wrong whichIidentifier sent to getGenesAsSet");
                	}
		}
            }catch(SQLException e){
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
                throw new SQLException();
            }
            return geneSet;
        }
        
	/**
	 * Gets genes that are part of the gene_list and returns them as a Set of String objects.  
	 * @param whichIdentifier	either "Original" or "Current"
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a Set of Strings containing the gene identifiers in the gene list 
	 */
	public Set<String> getGenesAsSet(String whichIdentifier, Connection conn) throws SQLException {
        	log.debug("in getGenesAsSet");

        	Gene[] myGeneArray = getGenesAsGeneArray(conn);

        	TreeSet<String> geneSet = new TreeSet<String>();

		for (int i=0; i<myGeneArray.length; i++) {
			if (whichIdentifier.equals("Original")) {
				geneSet.add(myGeneArray[i].getGene_id());
                	} else if (whichIdentifier.equals("Current")) {
				geneSet.add(myGeneArray[i].getCurrent_identifier());
                	} else {
                        	log.error("wrong whichIidentifier sent to getGenesAsSet");
                	}
		}
		//log.debug("size of Set = "+geneSet.size());
        	return geneSet;
	}

        
        public String getGenesAsString(String delimiter,String whichIdentifier,DataSource pool)throws SQLException {
            Connection conn=null;
            String tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGenesAsString(delimiter,whichIdentifier,conn);
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
	 * Gets genes that are part of the gene_list and returns them as a String object.  
	 * @param delimiter	a String used to delimit the different values
	 * @param whichIdentifier	either "Original" or "Current"
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a String containing the gene identifiers in the gene list delimited by the delimiter
	 */
	public String getGenesAsString(String delimiter, String whichIdentifier, Connection conn) throws SQLException {

        	log.debug("in getGenesAsString");

        	Set geneSet = getGenesAsSet(whichIdentifier, conn);
                String header="GeneIdentifier\tGene Symbol\n";

        	String geneString = new ObjectHandler().getAsSeparatedString(geneSet, delimiter);

        	return header+geneString;
	}

        
        public List<String> getGenesAsListOfStrings(String delimiter,String whichIdentifier,DataSource pool)throws SQLException {
            Connection conn=null;
            List<String> tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGenesAsListOfStrings(delimiter,whichIdentifier,conn);
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
	 * Gets genes that are part of the gene_list and returns them as a List of String objects, broken down into 1000 gene chunks.  
	 * @param delimiter	a String used to delimit the different values
	 * @param whichIdentifier	either "Original" or "Current"
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a List of Strings containing the gene identifiers in the gene list delimited by the delimiter
	 */
	public List<String> getGenesAsListOfStrings(String delimiter, String whichIdentifier, Connection conn) throws SQLException {

        	log.debug("in getGenesAsListOfStrings");
                String header="GeneIdentifier\tGene Symbol\n";
        	Set<String> geneSet = getGenesAsSet(whichIdentifier, conn);

        	List<String> geneStrings = new ObjectHandler().getAsSeparatedStrings(geneSet, delimiter, "", 1000);
                geneStrings.add(0, header);
        	return geneStrings;
	}

        public String[] getGenesAsArray(String whichIdentifier,DataSource pool)throws SQLException {
            log.debug("in getGenesAsArray");

        	Set<String> geneSet = getGenesAsSet(whichIdentifier, pool);

        	String[] geneArray = (String[]) myObjectHandler.getAsArray(geneSet, String.class);

		//log.debug("size of Array = "+geneArray.length);
        	return geneArray;
        }
        
	/**
	 * Gets genes that are part of the gene_list.  
	 * @param whichIdentifier	either "Original" or "Current"
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of Strings containing the gene identifiers in the gene list 
	 */

	public String[] getGenesAsArray(String whichIdentifier, Connection conn) throws SQLException {

        	log.debug("in getGenesAsArray");

        	Set<String> geneSet = getGenesAsSet(whichIdentifier, conn);

        	String[] geneArray = (String[]) myObjectHandler.getAsArray(geneSet, String.class);

		//log.debug("size of Array = "+geneArray.length);
        	return geneArray;
	}

        
        public String getGenesPlusValuesAsString(String delimiter, String whichIdentifier, DataSource pool)throws SQLException {
            Connection conn=null;
            String tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGenesPlusValuesAsString(delimiter,whichIdentifier,conn);
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
	 * Gets genes that are part of a gene list plus the statistical values associated with them. 
	 * @param delimiter	a String used to delimit the different values
	 * @param whichIdentifier	either "Original" or "Current"
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a String containing the gene identifiers plus their statistical values 
	 */

	public String getGenesPlusValuesAsString(String delimiter, String whichIdentifier, Connection conn) throws SQLException {

        	log.debug("in getGenesPlusValuesAsString");

        	Gene[] myGeneArray = getGenesAsGeneArray(conn);

        	TreeSet<String> geneSet = new TreeSet<String>();
		String geneRow = "";

		for (int i=0; i<myGeneArray.length; i++) {
			if (whichIdentifier.equals("Original")) {
                		geneRow = myGeneArray[i].getGene_id() + "\t";
                	} else if (whichIdentifier.equals("Current")) {
                		geneRow = myGeneArray[i].getCurrent_identifier() + "\t";
                	} else {
                		log.error("wrong whichIdentifier sent to getGenesAsArray");
                	}
                        geneRow=geneRow+myGeneArray[i].getMainGeneSymbol() +"\t";
			if (myGeneArray[i].getStatisticsValues() != null &&
				myGeneArray[i].getStatisticsValues().size() > 0) {
				for (int j=0; j<myGeneArray[i].getStatisticsValues().size(); j++) {
					geneRow = geneRow + 
                				myGeneArray[i].getStatisticsValues().get(j);
					if (j<myGeneArray[i].getStatisticsValues().size()-1) {
						geneRow = geneRow + "\t";
					}
				}
			}
			geneSet.add(geneRow);
		}

		String[] columnHeadings = this.getColumnHeadings();

        	String headerLine = "Gene Identifier\tGene Symbol\t";
		for (int i=0; i<columnHeadings.length; i++) {
                	headerLine = headerLine + columnHeadings[i];
			if (i<columnHeadings.length-1) {
				headerLine = headerLine + "\t";
			} else {
				headerLine = headerLine + "\n";
			}
		}
			
        	String geneString = headerLine + new ObjectHandler().getAsSeparatedString(geneSet, delimiter);

        	return geneString;
	}

        
        
        public List<String> getGenesPlusValuesAsListOfStrings(String delimiter, String whichIdentifier, DataSource pool)throws SQLException {
            Connection conn=null;
            List<String> tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGenesPlusValuesAsListOfStrings(delimiter,whichIdentifier,conn);
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
	 * Gets genes that are part of a gene list plus the statistical values associated with them.  Returns
	 * a List of Strings, so this can be used with large gene lists 
	 * @param delimiter	a String used to delimit the different values
	 * @param whichIdentifier	either "Original" or "Current"
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a List of Strings containing the gene identifiers plus their statistical values 
	 */

	public List<String> getGenesPlusValuesAsListOfStrings(String delimiter, String whichIdentifier, Connection conn) throws SQLException {

        	log.debug("in getGenesPlusValuesAsListOfStrings");

        	Gene[] myGeneArray = getGenesAsGeneArray(conn);

        	Set<String> geneSet = new LinkedHashSet<String>();
		String geneRow = "";

		for (int i=0; i<myGeneArray.length; i++) {
			if (whichIdentifier.equals("Original")) {
                		geneRow = myGeneArray[i].getGene_id() + "\t";
                	} else if (whichIdentifier.equals("Current")) {
                		geneRow = myGeneArray[i].getCurrent_identifier() + "\t";
                	} else {
                		log.error("wrong whichIdentifier sent to getGenesAsArray");
                	}
                        geneRow=geneRow+myGeneArray[i].getMainGeneSymbol() +"\t";
			if (myGeneArray[i].getStatisticsValues() != null &&
				myGeneArray[i].getStatisticsValues().size() > 0) {
				for (int j=0; j<myGeneArray[i].getStatisticsValues().size(); j++) {
					geneRow = geneRow + 
                				myGeneArray[i].getStatisticsValues().get(j);
					if (j<myGeneArray[i].getStatisticsValues().size()-1) {
						geneRow = geneRow + "\t";
					}
				}
			}
			geneSet.add(geneRow);
		}

		String[] columnHeadings = this.getColumnHeadings();

        	String headerLine = "Gene Identifier\tGene Symbol\t";
		for (int i=0; i<columnHeadings.length; i++) {
                	headerLine = headerLine + columnHeadings[i];
			if (i<columnHeadings.length-1) {
				headerLine = headerLine + "\t";
			} else {
				headerLine = headerLine + "\n";
			}
		}
			
        	List<String> geneStrings =  new ObjectHandler().getAsSeparatedStrings(geneSet, delimiter, "", 1000);
		geneStrings.add(0, headerLine);

        	return geneStrings;
	}
        
        
        
        public String getGenesPlusStatsAsString(String delimiter, String whichIdentifier, DataSource pool)throws SQLException {
            Connection conn=null;
            String tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGenesPlusStatsAsString(delimiter,whichIdentifier,conn);
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
	 * Gets genes that are part of a gene list plus the statistical values associated with them. 
	 * @param delimiter	a String used to delimit the different values
	 * @param whichIdentifier	either "Original" or "Current"
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a String containing the gene identifiers plus their statistical values without Group Means
	 */

	public String getGenesPlusStatsAsString(String delimiter, String whichIdentifier, Connection conn) throws SQLException {

        	log.debug("in getGenesPlusValuesAsString");
                
                String[] columnHeadings = this.getColumnHeadings();
                java.util.ArrayList<Integer> meanIndex=new ArrayList<Integer>();
        	String headerLine = "Gene Identifier\tGene Symbol\t";
		for (int i=0; i<columnHeadings.length; i++) {
                        if(columnHeadings[i].indexOf("Mean")>-1){
                            meanIndex.add(new Integer(i));
                        }else{
                            headerLine = headerLine + columnHeadings[i];
                        }
			if (i<columnHeadings.length-1) {
				headerLine = headerLine + "\t";
			} else {
				headerLine = headerLine + "\n";
			}
		}

        	Gene[] myGeneArray = getGenesAsGeneArray(conn);

        	TreeSet<String> geneSet = new TreeSet<String>();
		String geneRow = "";

		for (int i=0; i<myGeneArray.length; i++) {
			if (whichIdentifier.equals("Original")) {
                		geneRow = myGeneArray[i].getGene_id() + "\t";
                	} else if (whichIdentifier.equals("Current")) {
                		geneRow = myGeneArray[i].getCurrent_identifier() + "\t";
                	} else {
                		log.error("wrong whichIdentifier sent to getGenesAsArray");
                	}
                        geneRow=geneRow+myGeneArray[i].getMainGeneSymbol() +"\t";
			if (myGeneArray[i].getStatisticsValues() != null &&
				myGeneArray[i].getStatisticsValues().size() > 0) {
				for (int j=0; j<myGeneArray[i].getStatisticsValues().size(); j++) {
                                        if(meanIndex.indexOf(j)>-1){
                                            
                                        }else{
                                            geneRow = geneRow + 
                				myGeneArray[i].getStatisticsValues().get(j);
                                            if (j<myGeneArray[i].getStatisticsValues().size()-1) {
                                                    geneRow = geneRow + "\t";
                                            }
                                        }
				}
			}
			geneSet.add(geneRow);
		}

		
			
        	String geneString = headerLine + new ObjectHandler().getAsSeparatedString(geneSet, delimiter);

        	return geneString;
	}

        public List<String> getGenesPlusStatsAsListOfStrings(String delimiter, String whichIdentifier, DataSource pool)throws SQLException {
            Connection conn=null;
            List<String> tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGenesPlusStatsAsListOfStrings(delimiter,whichIdentifier,conn);
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
	 * Gets genes that are part of a gene list plus the statistical values associated with them.  Returns
	 * a List of Strings, so this can be used with large gene lists 
	 * @param delimiter	a String used to delimit the different values
	 * @param whichIdentifier	either "Original" or "Current"
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a List of Strings containing the gene identifiers plus their statistical values without Group Means
	 */

	public List<String> getGenesPlusStatsAsListOfStrings(String delimiter, String whichIdentifier, Connection conn) throws SQLException {

        	log.debug("in getGenesPlusValuesAsListOfStrings");
                
                String[] columnHeadings = this.getColumnHeadings();
                java.util.ArrayList<Integer> meanIndex=new ArrayList<Integer>();
        	String headerLine = "Gene Identifier\tGene Symbol\t";
		for (int i=0; i<columnHeadings.length; i++) {
                        if(columnHeadings[i].indexOf("Mean")>-1){
                            meanIndex.add(new Integer(i));
                        }else{
                            headerLine = headerLine + columnHeadings[i];
                        }
                        
                        if (i<columnHeadings.length-1) {
				headerLine = headerLine + "\t";
			} else {
				headerLine = headerLine + "\n";
			}
		}
                
        	Gene[] myGeneArray = getGenesAsGeneArray(conn);

        	Set<String> geneSet = new LinkedHashSet<String>();
		String geneRow = "";

		for (int i=0; i<myGeneArray.length; i++) {
			if (whichIdentifier.equals("Original")) {
                		geneRow = myGeneArray[i].getGene_id() + "\t";
                	} else if (whichIdentifier.equals("Current")) {
                		geneRow = myGeneArray[i].getCurrent_identifier() + "\t";
                	} else {
                		log.error("wrong whichIdentifier sent to getGenesAsArray");
                	}
                        geneRow=geneRow+myGeneArray[i].getMainGeneSymbol() +"\t";
			if (myGeneArray[i].getStatisticsValues() != null &&
				myGeneArray[i].getStatisticsValues().size() > 0) {
				for (int j=0; j<myGeneArray[i].getStatisticsValues().size(); j++) {
                                        if(meanIndex.indexOf(j)>-1){
                                            
                                        }else{
                                            geneRow = geneRow + 
                				myGeneArray[i].getStatisticsValues().get(j);
                                            if (j<myGeneArray[i].getStatisticsValues().size()-1) {
                                                geneRow = geneRow + "\t";
                                            }
                                        }
				}
			}
			geneSet.add(geneRow);
		}

		
			
        	List<String> geneStrings =  new ObjectHandler().getAsSeparatedStrings(geneSet, delimiter, "", 1000);
		geneStrings.add(0, headerLine);

        	return geneStrings;
	}
        
        public String getGenesPlusFoldChange( DataSource pool)throws SQLException {
            Connection conn=null;
            String tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getGenesPlusFoldChange(conn);
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
	 * Gets genes that are part of a gene list plus the difference in group means or the correlation coefficient.
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a String containing the gene identifiers plus the fold change or correlation coefficient 
	 */
	public String getGenesPlusFoldChange(Connection conn) throws SQLException {

        	log.debug("in getGenesPlusFoldChange");

        	Gene[] myGeneArray = getGenesAsGeneArray(conn);
                Hashtable<String, Integer> indexHash = this.getSortingColumnIdxHash();

		log.debug("statMethod = " + this.getStatisticalMethod());
		log.debug("indexHash = "); myDebugger.print(indexHash);

        	TreeSet<String> geneSet = new TreeSet<String>();
		String geneRow = "";

		for (int i=0; i<myGeneArray.length; i++) {
                	geneRow = myGeneArray[i].getGene_id();
                        if (myGeneArray[i].getStatisticsValues() != null && myGeneArray[i].getStatisticsValues().size() > 0) {
                        	String foldChangeValue = "";
				if (this.getStatisticalMethod().equals("pearson") || this.getStatisticalMethod().equals("spearman")) {
					int correlationCoefficientIdx = indexHash.get("correlation.coefficient");
                        		foldChangeValue = new DecimalFormat("####.####").format(myGeneArray[i].getStatisticsValues().get(correlationCoefficientIdx));
				} else if (this.getStatisticalMethod().equals("parametric") || this.getStatisticalMethod().equals("nonparametric")) {
					int group1Idx = 1;
					int group2Idx = 0;
                        		foldChangeValue = new DecimalFormat("####.####").format(myGeneArray[i].getStatisticsValues().get(group1Idx) - myGeneArray[i].getStatisticsValues().get(group2Idx));
				}
				geneRow = geneRow + "\t" + foldChangeValue;
                        }
			geneSet.add(geneRow);
		}

        	String geneString = new ObjectHandler().getAsSeparatedString(geneSet, "\r\n");

        	return geneString;
	}

        
        public boolean geneListNameExists(String geneListName, int userID, DataSource pool)throws SQLException {
            Connection conn=null;
             boolean tmp=false;
            try{
                conn=pool.getConnection();
                tmp=geneListNameExists(geneListName,userID,conn);
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
   	* Checks to see whether a gene list with the same name already exists for this user.
   	* @param geneListName	the name to check
   	* @param userID	the id of the user
   	* @param conn	the database connection
   	* @throws            SQLException if a database error occurs
   	* @return            TRUE if this name already exists, FALSE otherwise
   	*/
  	public boolean geneListNameExists(String geneListName, int userID, Connection conn) throws SQLException {

		log.debug("in geneListNameExists");
	
        	String query =
                	"select 'x' "+
                	"from gene_lists gl "+
                	"where gl.gene_list_name = ? "+
			"and created_by_user_id = ?";

		boolean itExists = false;

	        Results myResults = new Results(query, new Object[] {geneListName, userID}, conn);
		if (myResults.getNumRows() >= 1) {
			itExists = true;
		}

		myResults.close();

        	return itExists;
  	}

	/** 
	 * A GeneList object is equal if gene_list_ids are the same.
	 * @param obj	a GeneList object
	 * @return true if the objects are equal, false otherwise
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof GeneList)) return false;
		return (this.gene_list_id == ((GeneList)obj).gene_list_id);
	}
        
	public void print(GeneList myGeneList) {
		myGeneList.print();
	}

	public String toString() {
		return "This GeneList object has gene_list_id = " + gene_list_id + " and name = "+ gene_list_name;
	}

	public void print() {
		log.debug(toString());
	}

	public GeneList[] sortGeneLists (GeneList[] myGeneLists, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myGeneLists, new GeneListSortComparator());
		return myGeneLists;
	}
	
	public class GeneListSortComparator implements Comparator<GeneList> {
        	int compare;
        	GeneList geneList1, geneList2;

        	public int compare(GeneList gl1, GeneList gl2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
	                	geneList1 = gl1;
                		geneList2 = gl2;
				// default for null columns for ascending order
				compare = 1;
			} else {
	                	geneList1 = gl2;
                		geneList2 = gl1;
				// default for null columns for descending order
				compare = -1;
			}

			if (sortColumn.equals("owner")) {
				compare = geneList1.getGene_list_owner().compareTo(geneList2.getGene_list_owner());
			} else if (sortColumn.equals("geneListName")) {
				compare = geneList1.getGene_list_name().toUpperCase().compareTo(geneList2.getGene_list_name().toUpperCase());
			} else if (sortColumn.equals("numberOfGenes")) {
				compare = new Integer(geneList1.getNumber_of_genes()).compareTo(new Integer(geneList2.getNumber_of_genes()));
			} else if (sortColumn.equals("organism")) {
				compare = geneList1.getOrganism().compareTo(geneList2.getOrganism());
			} else if (sortColumn.equals("geneListSource")) {
				compare = geneList1.getGene_list_source().compareTo(geneList2.getGene_list_source());
			}
                	return compare;
        	}
	}

	public class Gene implements Comparable{

  		private Debugger myDebugger = new Debugger();

  		private int gene_list_id;
  		private String gene_id;
  		private String current_identifier;
  		private List<Double> statisticsValues;
  		private String sortColumn = "0";
  		private String sortOrder;
  		private Set geneSymbols;
  		private Set<GeneList> containingGeneLists;
  		private String mainGeneSymbol = "";

  		private Logger log=null;

  		private DbUtils myDbUtils = new DbUtils(); 

  		public Gene (int gene_list_id, String gene_id) {
			log = Logger.getRootLogger();
			this.gene_list_id = gene_list_id;
			this.gene_id = gene_id;
  		}

  		public Gene (String gene_id) {
			log = Logger.getRootLogger();
			this.gene_id = gene_id;
  		}

  		public Gene () {
			log = Logger.getRootLogger();
  		}

  		public String getGene_id() {
    			return gene_id; 
  		}

  		public void setGene_id(String inString) {
    			this.gene_id = inString;
  		}

  		public String getCurrent_identifier() {
    			return current_identifier; 
  		}

  		public void setCurrent_identifier(String inString) {
    			this.current_identifier = inString;
  		}

  		public String getSortColumn() {
    			return sortColumn; 
  		}

  		public void setSortColumn(String inString) {
    			this.sortColumn = inString;
  		}

  		public String getSortOrder() {
    			return sortOrder; 
  		}

  		public void setSortOrder(String inString) {
    			this.sortOrder = inString;
  		}

  		public int getGene_list_id() {
    			return gene_list_id; 
  		}

  		public void setGene_list_id(int inInt) {
    			this.gene_list_id = inInt;
  		}

  		public void setStatisticsValues(List<Double> inList) {
    			this.statisticsValues = inList;
  		}

  		public List<Double> getStatisticsValues() {
    			return statisticsValues;
  		}

  		public String getMainGeneSymbol() {
    			return mainGeneSymbol; 
  		}

  		public void setMainGeneSymbol(String inString) {
    			this.mainGeneSymbol = inString;
  		}

  		public void setGeneSymbols(Set inSet) {
    			this.geneSymbols = inSet;
  		}

  		public Set getGeneSymbols() {
    			return geneSymbols;
  		}
                
                /*public String getGeneSymbolsString() {
                        String ret="";
                        Iterator i=geneSymbols.iterator();
                        if(i.hasNext()){
                            Identifier ident=(Identifier)i.next();
                            if(ident!=null){
                                ret=ident.getIdentifier();
                            }
                        }
                        while(i.hasNext()){
                            Identifier ident=(Identifier)i.next();
                            if(ident!=null){
                                ret=ret+","+ident.getIdentifier();
                            }
                        }
                        
    			return ret;
  		}*/

  		public void setContainingGeneLists(Set<GeneList> inSet) {
    			this.containingGeneLists = inSet;
  		}

  		public Set<GeneList> getContainingGeneLists() {
    			return containingGeneLists;
  		}

		/**
	 	* Gets the statistic value for a gene
	 	* @param myGeneArray	an array of Gene objects
	 	* @param thisIdentifier	the gene id to look for
	 	* @param idx	the index of the column that holds the statistics value your looking for
	 	* @return	the statistics value
	 	*/
		public String getStatisticValue (Gene[] myGeneArray, String thisIdentifier, int idx) {
			//log.debug("in getStatisticValue");
			String statisticsValue = "";

                	for (int i=0; i<myGeneArray.length; i++) {
			//log.debug("current_id = "+myGeneArray[i].getCurrent_identifier() + ", orig id = "+myGeneArray[i].getGene_id() + ", this = "+thisIdentifier);
                		if (myGeneArray[i].getCurrent_identifier().equals(thisIdentifier)) {
                			if (myGeneArray[i].getStatisticsValues() != null &&
                				myGeneArray[i].getStatisticsValues().size() > 0 && idx != -99) {
                				statisticsValue = Double.toString(myGeneArray[i].getStatisticsValues().get(idx));
                			}
                			break;
                		}
                	}
			return statisticsValue;
		}
	
                

		/** 
	 	* A Gene object is equal if both the gene_list_id and the gene_id are the same.
	 	* @param obj	a Gene object
	 	* @return true if the objects are equal, false otherwise
	 	*/
		public boolean equals(Object obj) {
			if (!(obj instanceof Gene)) return false;
			return (this.gene_id.equals(((Gene)obj).gene_id) && this.gene_list_id == ((Gene)obj).gene_list_id);
		}
        
		public void print(Gene myGene) {
			myGene.print();
		}

		public String toString() {
			return "This Gene object has gene_list_id = " + gene_list_id + " and gene_id = "+ gene_id;
			// + myDebugger.print(getStatisticsValues());
		}

		public void print() {
			log.debug(toString());
		}

		/* Not used right now 
		public Gene[] sortGenes (Gene[] myGenes, String sortColumn, String sortOrder) {
			setSortColumn(sortColumn);
			setSortOrder(sortOrder);
			Arrays.sort(myGenes, new GeneSortComparator());
			return myGenes;
		}
		*/

	
		public int compareTo(Object myGeneObject) {
			if (!(myGeneObject instanceof Gene)) return -1;
			return this.getGene_id().compareTo(((Gene) myGeneObject).getGene_id());
		}
	
		/* Not used right now
		public class GeneSortComparator implements Comparator<Gene> {
        		int compare;
        		Gene gene1, gene2;

        		public int compare(Gene object1, Gene object2) {
				String sortColumn = getSortColumn();
				String sortOrder = getSortOrder();
				int i = Integer.parseInt(sortColumn);

				if (sortOrder.equals("A")) {
	                		gene1 = object1;
                			gene2 = object2;
					// default for null columns for ascending order
					compare = 1;
				} else {
	                		gene1 = object2;
                			gene2 = object1;
					// default for null columns for descending order
					compare = -1;
				}

				if (i==0 || i==1) {
					String thisString = gene1.getGene_id();
					String thatString = gene2.getGene_id();
					compare = thisString.compareTo(thatString);
				} else if (i==2) {
					String thisString = gene1.getCurrent_identifier();
					String thatString = gene2.getCurrent_identifier();
					compare = thisString.compareTo(thatString);
				} else if (i==3) {
					// the third column is the gene symbol column.  
					if (gene1.getMainGeneSymbol() != null &&
						gene2.getMainGeneSymbol() != null) {
						String thisString = gene1.getMainGeneSymbol();
						String thatString = gene2.getMainGeneSymbol();
						compare = thisString.compareTo(thatString);
					}
				} else if (gene1.getStatisticsValues() != null && gene2.getStatisticsValues() != null) {
					Double thisDouble = (Double) ((List) gene1.getStatisticsValues()).get(i-4);
					Double thatDouble = (Double) ((List) gene2.getStatisticsValues()).get(i-4);
					compare = thisDouble.compareTo(thatDouble);
				}
                		return compare;
        		}
		}
		*/
	}
	

}

