package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.*;
import java.util.*;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;
import edu.ucdenver.ccp.util.sql.*;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;
import edu.ucdenver.ccp.PhenoGen.data.ParameterValue;

import edu.ucdenver.ccp.util.Debugger;
import javax.sql.DataSource;
/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to managing promoter processes. 
 *  @author  Cheryl Hornbaker
 */

public class Promoter{
  private int promoter_id;
  private int gene_list_id;
  private int user_id;
  private String search_region_level;
  private String conservation_level;
  private String threshold_level;
  private String description;
  private String create_date_as_string;
  private String analyzed_ids;
  private String excluded_ids;
  private GeneList promoterGeneList;
  private HashMap ids;
  private java.sql.Timestamp create_date;

  private Logger log=null;

  private DbUtils myDbUtils = new DbUtils();
  private Debugger myDebugger = new Debugger();

  public Promoter () {
	log = Logger.getRootLogger();
  }

  public int getPromoter_id() {
    return promoter_id; 
  }

  public void setPromoter_id(int inInt) {
    this.promoter_id = inInt;
  }

  public int getGene_list_id() {
    return gene_list_id; 
  }

  public void setGene_list_id(int inInt) {
    this.gene_list_id = inInt;
  }
  
  public void setUser_id(int inInt) {
    this.user_id = inInt;
  }

  public int getUser_id() {
    return user_id; 
  }
  
  public String getSearchRegionLevel() {
  	return search_region_level;
  }
  
  public void setSearchRegionLevel(String inString) {
  	this.search_region_level = inString;
  }
  
  public String getConservationLevel() {
  	return conservation_level;
  }
  
  public void setConservationLevel(String inString) {
  	this.conservation_level = inString;
  }
  
  public String getThresholdLevel() {
  	return threshold_level;
  }
  
  public void setThresholdLevel(String inString) {
  	this.threshold_level = inString;
  }
  
  public String getDescription() {
  	return description;
  }
  
  public void setDescription(String inString) {
  	this.description = inString;
  }
  
  public HashMap getIds() {
  	return ids;
  }
  
  public void setIds(HashMap inHashMap) {
  	this.ids = inHashMap;
  }
  
  public void setCreate_date(java.sql.Timestamp inTimestamp) {
    this.create_date = inTimestamp;
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

  public void setAnalyzed_ids(String inString) {
    this.analyzed_ids = inString;
  }

  public String getAnalyzed_ids() {
    return analyzed_ids;
  }

  public void setExcluded_ids(String inString) {
    this.excluded_ids = inString;
  }

  public String getExcluded_ids() {
    return excluded_ids;
  }

  public GeneList getPromoterGeneList() {
    return promoterGeneList;
  }

  public void setPromoterGeneList(GeneList inGeneList) {
    this.promoterGeneList = inGeneList;
  }


   
	/**
	 * Create a record in the gene_list_analyses table with an analysis_type of 'oPOSSUM'.
	 * oPOSSUM data was originally stored in a separate table.  
	 * This table was combined with gene_list_analyses in March, 2007.
	 * @param conn	the database connection
         * @throws      SQLException if a database error occurs
	 * @return            the id of the gene_list_analyses record that was created
	 */

	public int createPromoterResult (DataSource pool) throws SQLException {
	
		GeneListAnalysis myGeneListAnalysis = new GeneListAnalysis();

		int parameter_group_id = new ParameterValue().createParameterGroup(pool);

		myGeneListAnalysis.setGene_list_id(this.getGene_list_id());
		myGeneListAnalysis.setUser_id(this.getUser_id());
		myGeneListAnalysis.setParameter_group_id(parameter_group_id);
		myGeneListAnalysis.setAnalysis_type("oPOSSUM");
		myGeneListAnalysis.setCreate_date(this.getCreate_date());
		myGeneListAnalysis.setDescription(this.getDescription());
                myGeneListAnalysis.setStatus("Running");
                myGeneListAnalysis.setVisible(1);
		ParameterValue[] myParameterValues = new ParameterValue[3];
	
		for (int i=0; i<myParameterValues.length; i++) {
			myParameterValues[i] = new ParameterValue();
			myParameterValues[i].setParameter_group_id(parameter_group_id);
			myParameterValues[i].setCategory("oPOSSUM");
			myParameterValues[i].setCreate_date();
		}
		myParameterValues[0].setParameter("Search Region Level");
		myParameterValues[0].setValue(this.getSearchRegionLevel());
		myParameterValues[1].setParameter("Conservation Level");
		myParameterValues[1].setValue(this.getConservationLevel());
		myParameterValues[2].setParameter("Threshold Level");
		myParameterValues[2].setValue(this.getThresholdLevel());
		myGeneListAnalysis.setParameterValues(myParameterValues);

		promoter_id = myGeneListAnalysis.createGeneListAnalysis(pool);

		log.debug("in Promoter.createPromoterResult.");
        
		String query = 
			"insert into promoter_result_genes "+
			"(promoter_id, gene_list_id, gene_id) values "+
			"(?, ?, ?)";
                Connection conn=null;
                try{
                    conn=pool.getConnection();
                
                    PreparedStatement pstmt = conn.prepareStatement(query,
                                                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                                                    ResultSet.CONCUR_UPDATABLE);
                    pstmt.setInt(1, promoter_id);
                    pstmt.setInt(2, this.getGene_list_id());
                    log.debug("gene_list_id = " + this.getGene_list_id());
                    log.debug("promoter_id = " + promoter_id);

                    Iterator idIterator  = ids.keySet().iterator();
                    while (idIterator.hasNext()) {
                            String geneID = (String) idIterator.next();
                            pstmt.setString(3, geneID);
                            pstmt.executeUpdate();
                    }

                    pstmt.close();
                    conn.close();
                }catch(SQLException e){
                    throw e;
                }finally{
                    if(conn!=null && !conn.isClosed()){
                        try{
                            conn.close();
                            conn=null;
                        }catch(SQLException e){}
                    }
                }
		
		log.debug("just created PromoterResult.  Now creating alternate_identifiers");

  		GeneList myGeneList = new GeneList();

		myGeneList.setGene_list_id(this.getGene_list_id());
		myGeneList.setAlternateIdentifierSource("Promoter");
		myGeneList.setAlternateIdentifierSourceLinkColumn("PROMOTER_RESULT_GENES.PROMOTER_ID");
		myGeneList.setAlternateIdentifierSourceID(promoter_id);
		myGeneList.setGenesHashMap(ids);
                
		myGeneList.createAlternateIdentifiers(myGeneList,pool);

		log.debug("gene_list = " + myGeneList.getGene_list_id());
		log.debug("alternate_id_source = " + myGeneList.getAlternateIdentifierSource());
		log.debug("alternate_id_source_link = " + myGeneList.getAlternateIdentifierSourceLinkColumn());
		log.debug("alternate_id_source_id = " + myGeneList.getAlternateIdentifierSourceID());
        
		return promoter_id;
	}

  
        
        private Promoter setupPromoterValues(String[] dataRow, DataSource pool) throws SQLException {

                //log.debug("in setupPromoterValues");
                //log.debug("dataRow= "); new Debugger().print(dataRow);
		Promoter myPromoter = new Promoter();
                myPromoter.setPromoter_id(Integer.parseInt(dataRow[0]));
                myPromoter.setDescription(dataRow[1]);
                GeneList gl=null;
                if(Integer.parseInt(dataRow[4])==-20){
                    gl=(new AnonGeneList()).getGeneList(Integer.parseInt(dataRow[2]), pool);
                }else{
                    gl=(new GeneList()).getGeneList(Integer.parseInt(dataRow[2]), pool);
                }
                myPromoter.setPromoterGeneList(gl);
                myPromoter.setCreate_date_as_string(dataRow[3]);
                myPromoter.setUser_id(Integer.parseInt(dataRow[4]));
		if (dataRow.length > 5) {
                	myPromoter.setAnalyzed_ids(dataRow[5]);
                	myPromoter.setExcluded_ids(dataRow[6]);
		}

                return myPromoter;

        }
        
        /**
         * Creates a new Promoter object and sets the data values to those retrieved from the database.
         * @param dataRow       the row of data corresponding to one Promoter
	 * @param conn	the database connection
         * @throws      SQLException if a database error occurs
         * @return            A Promoter object with its values setup
         */
        private Promoter setupPromoterValues(String[] dataRow, Connection conn) throws SQLException {

                //log.debug("in setupPromoterValues");
                //log.debug("dataRow= "); new Debugger().print(dataRow);
		Promoter myPromoter = new Promoter();
                myPromoter.setPromoter_id(Integer.parseInt(dataRow[0]));
                myPromoter.setDescription(dataRow[1]);
                
                myPromoter.setPromoterGeneList(new GeneList().getGeneList(Integer.parseInt(dataRow[2]), conn));
                myPromoter.setCreate_date_as_string(dataRow[3]);
                myPromoter.setUser_id(Integer.parseInt(dataRow[4]));
		if (dataRow.length > 5) {
                	myPromoter.setAnalyzed_ids(dataRow[5]);
                	myPromoter.setExcluded_ids(dataRow[6]);
		}

                return myPromoter;

        }
        
        
        public Promoter getPromoterResult(int promoter_id, DataSource pool) throws SQLException {

        	String query =
                	"select pr.analysis_id, "+
			"pr.description, "+
			"gl.gene_list_id, "+
			"to_char(pr.create_date, 'MMddyyyy_hh24miss'), "+
			"pr.user_id "+
			//
			// This join gets all the gene_ids that were actually sent to oPOSSUM.
			// It starts by retrieving those gene_ids that did NOT have alternate identifiers
			// and then unions the results with the gene_ids that DID have alternate identifiers.
			// Another join is used when retrieving the alternate identifiers so that all alternate 
			// identifiers are displayed in case more than one was found.
			//
			/*
			// Commented this out because it's creating too big of a CLOB
                	"to_char(join(cursor(select prg.gene_id "+
                                	"from promoter_result_genes prg "+
                                	"where prg.promoter_id = pr.analysis_id "+
                                	"and not exists (select 'x' "+
                                        	"from alternate_identifiers ai "+
                                        	"where ai.source = 'Promoter' "+
                                        	"and ai.source_id = prg.promoter_id "+
                                        	"and ai.gene_id = prg.gene_id) "+
                                	"union "+
                                	"select to_char(prg.gene_id||' ('|| "+
                                        	"join(cursor(select ai.alternate_id "+
                                                        	"from alternate_identifiers ai, "+
                                                        	"promoter_result_genes prg2 "+
                                                        	"where ai.gene_list_id = prg2.gene_list_id "+
                                                        	"and ai.gene_id = prg2.gene_id "+
                                                        	"and prg2.promoter_id = prg.promoter_id "+
                                                        	"and prg2.promoter_id = ai.source_id "+
                                                        	"and prg2.gene_id = prg.gene_id "+
                                                        	"and ai.source = 'Promoter'), ', ')|| "+
                                        	"')') "+
                                	"from promoter_result_genes prg "+
                                	"where prg.promoter_id = pr.analysis_id "+
                                	"and exists (select 'x' "+
                                        	"from alternate_identifiers ai "+
                                        	"where ai.source = 'Promoter' "+
                                        	"and ai.source_id = prg.promoter_id "+
                                        	"and ai.gene_id = prg.gene_id) "+
                                	"order by 1), ', ')) analyzed_gene_ids, "+
			//
			// This join gets all the gene_ids that were not sent to oPOSSUM
			// It selects those genes from the gene list minus those found in 
			// promoter_result_genes, which contains the genes sent to oPOSSUM
			//
                	"to_char(join(cursor(select gene_id "+
                                	"from genes "+
                                	"where gene_list_id = pr.gene_list_id "+
                                	"minus "+
                                	"select gene_id "+
                                	"from promoter_result_genes prg "+
                                	//"where prg.promoter_id = pr.promoter_id), ', ')) excluded_gene_ids "+
                                	"where prg.promoter_id = pr.analysis_id), ', ')) excluded_gene_ids "+
			*/
                	"from gene_list_analyses pr, "+
                	"gene_lists gl, "+
                	//"users u "+
                	"where pr.analysis_id = ? "+
			"and pr.analysis_type = 'oPOSSUM' "+
                	"and pr.gene_list_id = gl.gene_list_id ";
                	//"and pr.user_id = u.user_id";
		log.debug("in getPromoterResult");
		//log.debug("query = " + query);
                Connection conn=null;
                Promoter newPromoter = null;
                try{
                    conn=pool.getConnection();
                    Results myResults = new Results(query, promoter_id, conn);
                    String[] dataRow;
                    while ((dataRow = myResults.getNextRow()) != null) {
                            newPromoter = setupPromoterValues(dataRow, pool);
                    }
                    myResults.close();
                }catch(SQLException e){
                    throw e;
                }finally{
                    if(conn!=null && !conn.isClosed()){
                        try{
                            conn.close();
                            conn=null;
                        }catch(SQLException e){}
                    }
                }

		

        	return newPromoter;
	}

	/**
	 * Retrieves the information about a particular promoter result.
	 * Retrieve the gene_list_name, the user who performed the analysis and the time
	 * it was performed, and then select all of the gene_ids that were passed to oPOSSUM, including
	 * the alternate identifiers found by iDecoder.  Also select the gene_ids that were not 
	 * found by iDecoder.
	 * @param promoter_id	the id of the promoter run
	 * @param conn	the database connection
         * @throws      SQLException if a database error occurs
	 * @return            a Promoter object
	 */

	public Promoter getPromoterResult(int promoter_id, Connection conn) throws SQLException {

        	String query =
                	"select pr.analysis_id, "+
			"pr.description, "+
			"gl.gene_list_id, "+
			"to_char(pr.create_date, 'MMddyyyy_hh24miss'), "+
			"pr.user_id "+
			//
			// This join gets all the gene_ids that were actually sent to oPOSSUM.
			// It starts by retrieving those gene_ids that did NOT have alternate identifiers
			// and then unions the results with the gene_ids that DID have alternate identifiers.
			// Another join is used when retrieving the alternate identifiers so that all alternate 
			// identifiers are displayed in case more than one was found.
			//
			/*
			// Commented this out because it's creating too big of a CLOB
                	"to_char(join(cursor(select prg.gene_id "+
                                	"from promoter_result_genes prg "+
                                	"where prg.promoter_id = pr.analysis_id "+
                                	"and not exists (select 'x' "+
                                        	"from alternate_identifiers ai "+
                                        	"where ai.source = 'Promoter' "+
                                        	"and ai.source_id = prg.promoter_id "+
                                        	"and ai.gene_id = prg.gene_id) "+
                                	"union "+
                                	"select to_char(prg.gene_id||' ('|| "+
                                        	"join(cursor(select ai.alternate_id "+
                                                        	"from alternate_identifiers ai, "+
                                                        	"promoter_result_genes prg2 "+
                                                        	"where ai.gene_list_id = prg2.gene_list_id "+
                                                        	"and ai.gene_id = prg2.gene_id "+
                                                        	"and prg2.promoter_id = prg.promoter_id "+
                                                        	"and prg2.promoter_id = ai.source_id "+
                                                        	"and prg2.gene_id = prg.gene_id "+
                                                        	"and ai.source = 'Promoter'), ', ')|| "+
                                        	"')') "+
                                	"from promoter_result_genes prg "+
                                	"where prg.promoter_id = pr.analysis_id "+
                                	"and exists (select 'x' "+
                                        	"from alternate_identifiers ai "+
                                        	"where ai.source = 'Promoter' "+
                                        	"and ai.source_id = prg.promoter_id "+
                                        	"and ai.gene_id = prg.gene_id) "+
                                	"order by 1), ', ')) analyzed_gene_ids, "+
			//
			// This join gets all the gene_ids that were not sent to oPOSSUM
			// It selects those genes from the gene list minus those found in 
			// promoter_result_genes, which contains the genes sent to oPOSSUM
			//
                	"to_char(join(cursor(select gene_id "+
                                	"from genes "+
                                	"where gene_list_id = pr.gene_list_id "+
                                	"minus "+
                                	"select gene_id "+
                                	"from promoter_result_genes prg "+
                                	//"where prg.promoter_id = pr.promoter_id), ', ')) excluded_gene_ids "+
                                	"where prg.promoter_id = pr.analysis_id), ', ')) excluded_gene_ids "+
			*/
                	"from gene_list_analyses pr, "+
                	"gene_lists gl, "+
                	//"users u "+
                	"where pr.analysis_id = ? "+
			"and pr.analysis_type = 'oPOSSUM' "+
                	"and pr.gene_list_id = gl.gene_list_id ";
                	//"and pr.user_id = u.user_id";
		log.debug("in getPromoterResult");
		//log.debug("query = " + query);

                Results myResults = new Results(query, promoter_id, conn);
                String[] dataRow;

		Promoter newPromoter = null;
                while ((dataRow = myResults.getNextRow()) != null) {
                        newPromoter = setupPromoterValues(dataRow, conn);
                }

		myResults.close();

        	return newPromoter;
	}
  
	/** Removes an oPOSSUM record from the gene_list_analyses table, and associated 
	  * records from promoter_result_genes and alternate_identifiers. 
	  * @param promoterID	the analysis_id of the promoter run
	  * @param conn	the database connection
          * @throws      SQLException if a database error occurs
	  */
	public void deletePromoterResult(int promoterID, Connection conn) throws SQLException {

		log.info("in deletePromoterResult");

        	String[] query = new String[2];

		query[0] =
                	"delete from alternate_identifiers ai  "+
                	"where exists "+
                        	"(select 'x' "+
                        	"from promoter_result_genes prg "+
				"where promoter_id = ? "+
                        	"and ai.source_id = prg.promoter_id "+
				"and ai.source = 'Promoter')";

		query[1] = 
                	"delete from promoter_result_genes prg  "+
                	"where promoter_id = ?"; 

		for (int i=0; i<query.length; i++) {
                        //log.debug("i = " + i + ", query = " + query[i]);
  			PreparedStatement pstmt = conn.prepareStatement(query[i],
                            	ResultSet.TYPE_SCROLL_INSENSITIVE,
                            	ResultSet.CONCUR_UPDATABLE);
                        pstmt.setInt(1, promoterID);

                        pstmt.executeUpdate();
                        pstmt.close();
                }

		new GeneListAnalysis().deleteGeneListAnalysisResult(promoterID, conn);

	}

  public String[] getAllPromoterResultsForUserStatements(String typeOfQuery) {

        String[] query = new String[3];

        String selectClause = myDbUtils.getSelectClause(typeOfQuery);
        String rownumClause = myDbUtils.getRownumClause(typeOfQuery);

	query[0] =
                selectClause +
		"from alternate_identifiers ai  "+
                "where exists "+
                        "(select 'x' "+
                        "from promoter_result_genes prg "+
			"where exists  "+
                        	"(select 'x' "+
	                        "from gene_list_analyses pr "+
				"where user_id = ? "+
				"and pr.analysis_type = 'oPOSSUM' "+
				"and prg.promoter_id = pr.analysis_id) "+
                        "and ai.source_id = prg.promoter_id "+
			"and ai.source = 'Promoter')"+
		rownumClause;

	query[1] = 
                selectClause +
		"from promoter_result_genes prg  "+
                "where exists "+
                        "(select 'x' "+
	                "from gene_list_analyses pr "+
			"where user_id = ? "+
			"and pr.analysis_type = 'oPOSSUM' "+
			"and prg.promoter_id = pr.analysis_id) "+
		rownumClause;

  	query[2] =
		selectClause +
		"from gene_list_analyses "+
		"where analysis_type = 'oPOSSUM' "+
		"and user_id = ? ";

        //for (int i=0; i<query.length; i++) {
        //      log.debug("i = " + i + ", query = " + query[i]);
        //}
        return query;

  }

  public List<List<String[]>> getAllPromoterResultsForUser(int userID, Connection conn) throws SQLException {

	log.info("in getAllPromoterResultsForUser");

        String[] query = getAllPromoterResultsForUserStatements("SELECT10");

        List<List<String[]>> allResults = null;
  	
	try {
                allResults = new Results().getAllResults(query, userID, conn);

	} catch (SQLException e) {
		log.error("In exception of getAllPromoterResultsForUser", e);
		throw e;
	}
        log.debug("returning allResults.length = "+allResults.size());
        return allResults;

  }

  public void deleteAllPromoterResultsForUser(int userID, Connection conn) throws SQLException {

	log.debug("in deleteAllPromoterResultsForUser");

        String[] query = getAllPromoterResultsForUserStatements("DELETE");

  	PreparedStatement pstmt = null;
  	
	try {
		for (int i=0; i<query.length; i++) {
                        log.debug("i = " + i + ", query = " + query[i]);
                        pstmt = conn.prepareStatement(query[i],
                            ResultSet.TYPE_SCROLL_INSENSITIVE,
                            ResultSet.CONCUR_UPDATABLE);
                        pstmt.setInt(1, userID);

                        pstmt.executeUpdate();
                        pstmt.close();
                }

	} catch (SQLException e) {
		log.error("In exception of deleteAllPromoterResultsForUser", e);
		throw e;
	}
  }
  
  /**
   * Deletes all the promoter result records plus the records in associated tables for a particular gene list.
   * @param gene_list_id	the identifier of the gene list
   * @param conn	the database connection
   * @throws      SQLException if a database error occurs
   */

  public void deleteAllPromoterResultsForGeneList(int gene_list_id, Connection conn) throws SQLException {

	log.debug("in deleteAllPromoterResultsForGeneList");

        String[] query = new String[3];

	query[0] =
                "delete from alternate_identifiers ai  "+
                "where exists "+
                        "(select 'x' "+
                        "from promoter_result_genes prg "+
			"where exists  "+
                        	"(select 'x' "+
	                        "from gene_list_analyses pr "+
				"where gene_list_id = ? "+
				"and pr.analysis_type = 'oPOSSUM' "+
				"and prg.promoter_id = pr.analysis_id) "+
                        "and ai.source_id = prg.promoter_id "+
			"and ai.source = 'Promoter')";

	query[1] = 
                "delete from promoter_result_genes prg  "+
                "where exists "+
                        "(select 'x' "+
                        "from gene_list_analyses pr "+
			"where gene_list_id = ? "+
			"and pr.analysis_type = 'oPOSSUM' "+
                        "and pr.analysis_id = prg.promoter_id)";

  	query[2] =
		"delete from gene_list_analyses "+
		"where analysis_type = 'oPOSSUM' "+
		"and gene_list_id = ? ";
  	

	for (int i=0; i<query.length; i++) {
        	//log.debug("i = " + i + ", query = " + query[i]);
		PreparedStatement pstmt = conn.prepareStatement(query[i],
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, gene_list_id);

                pstmt.executeUpdate();
                pstmt.close();
	}
  }
}

