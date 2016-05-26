package edu.ucdenver.ccp.PhenoGen.data;

/*
import java.util.*;
import edu.ucdenver.ccp.PhenoGen.web.*;
*/
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Set;

import edu.ucdenver.ccp.util.sql.Results;

import edu.ucdenver.ccp.PhenoGen.tools.literature.Literature;
import edu.ucdenver.ccp.PhenoGen.tools.literature.PubMedCollection;
import edu.ucdenver.ccp.PhenoGen.tools.literature.PubMedEntry;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

//import oracle.jdbc.driver.OraclePreparedStatement;
import oracle.jdbc.*;

import edu.ucdenver.ccp.util.Debugger;
/* for logging messages */
import org.apache.log4j.Logger;
import javax.sql.DataSource;

/**
 * Class for handling data related to managing literature searches for interpreting gene lists.
 * 
 * @author Cheryl Hornbaker
 */


public class LitSearch{
  private int search_id;
  private int gene_list_id;
  private GeneList litSearchGeneList;
  private int user_id;
  private int numDocuments;
  private int visible;
  private java.sql.Timestamp create_date;
  private String create_date_as_string;
  private String description;
  private String include_alcohol;

  private LinkedHashMap<String, String[]> categories;
  private HashMap ids;
  private String[] keywords;
  private int[] searchResults;
  private String[] pubMedResults;
  private PubMedCollection hitset;
  private PubMedCollection.CoReferences corefs;
  private Logger log=null;

  private DbUtils myDbUtils = new DbUtils();
  private Debugger myDebugger = new Debugger();

  public LitSearch () {
	log = Logger.getRootLogger();
  }

  public int getSearch_id() {
    return search_id; 
  }

  public void setSearch_id(int inInt) {
    this.search_id = inInt;
  }

  public GeneList getLitSearchGeneList() {
    return litSearchGeneList; 
  }

  public void setLitSearchGeneList(GeneList inGeneList) {
    this.litSearchGeneList = inGeneList;
  }

  public int getGene_list_id() {
    return gene_list_id; 
  }

  public void setGene_list_id(int inInt) {
    this.gene_list_id = inInt;
  }

  public void setNumDocuments(int inInt) {
    this.numDocuments = inInt;
  }

  public int getNumDocuments() {
    return numDocuments; 
  }

  public void setVisible(int inInt) {
    this.visible = inInt;
  }

  public int getVisible() {
    return visible; 
  }

  public void setUser_id(int inInt) {
    this.user_id = inInt;
  }

  public int getUser_id() {
    return user_id; 
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

  public void setDescription(String inString) {
    this.description = inString;
  }

  public String getDescription() {
    return description; 
  }

  public void setInclude_alcohol(String inString) {
    this.include_alcohol = inString;
  }

  public String getInclude_alcohol() {
    return include_alcohol; 
  }

  public void setCategories(LinkedHashMap<String, String[]> inHash) {
    this.categories = inHash;
  }

  public LinkedHashMap<String, String[]> getCategories() {
    return categories;
  }

  public void setIds(HashMap inHashMap) {
    this.ids = inHashMap;
  }

  public HashMap getIds() {
    return ids;
  }

  public void setKeywords(String[] inArray) {
    this.keywords = inArray;
  }

  public String[] getKeywords() {
    return keywords;
  }

  public void setSearchResults(int[] inArray) {
    this.searchResults = inArray;
  }

  public int[] getSearchResults() {
    return searchResults;
  }

  public void setPubMedResults(String[] inArray) {
    this.pubMedResults = inArray;
  }

  public String[] getPubMedResults() {
    return pubMedResults;
  }

  public void createCategories(LitSearch myLitSearch, Connection conn) throws SQLException {

	log.debug("in LitSearch.createCategories");
        String insertCategories =
                "insert into categories "+
                "(search_id, category) "+
                "values "+
                "(?, ?)";

	String insertKeywords =
                "insert into keywords "+
                "(search_id, category, keyword) "+
                "values "+
                "(?, ?, ?)";

        PreparedStatement pstmtCategories = null;
        PreparedStatement pstmtKeywords = null;
	log.debug("# of categories = " +myLitSearch.getCategories().size());

        try {
                pstmtCategories = conn.prepareStatement(insertCategories, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
                pstmtKeywords = conn.prepareStatement(insertKeywords, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
                pstmtCategories.setInt(1, myLitSearch.getSearch_id());
                pstmtKeywords.setInt(1, myLitSearch.getSearch_id());

                // insert each of the categories used in the search 
                if (myLitSearch.getCategories() != null) {
			Set<String> categoriesKeys = myLitSearch.getCategories().keySet();
			Iterator catKeysIterator = categoriesKeys.iterator();
			while (catKeysIterator.hasNext()) {
				String category = (String) catKeysIterator.next();
                                pstmtCategories.setString(2, category);
                                pstmtCategories.executeUpdate();

				String[] keywordList = (String[]) myLitSearch.getCategories().get(category); 
				log.debug("# of keywords = " +keywordList.length);
				for (int i=0; i< keywordList.length; i++) {
                                	pstmtKeywords.setString(2, category);
	                                pstmtKeywords.setString(3, keywordList[i]);
                                	pstmtKeywords.executeUpdate();
				}
                        }
                }
		pstmtCategories.close();
		pstmtKeywords.close();

        } catch (SQLException e) {
		log.error("In exception of createCategories", e);
		throw e;
        }
  }



	/**
	 * Retrieves the set of alternate identifiers used in the coreference list.
	 * @param gene_id	the identifier of the gene used in the co-reference
	 * @param coref_id	the identifier for the set of co_references
	 * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
	 * @return          an array of String objects containing the identifiers
	 */

	public String[] getAlternateIdentifiersUsedInCoReference(String gene_id, int coref_id, Connection conn) throws SQLException {

        	String query =
                	"select distinct ai.alternate_id "+
                	"from alternate_identifiers ai, "+
			"lit_search_results lsr "+
			"left join co_reference_results crr "+
			"on crr.search_id = lsr.search_id "+
                	"where ai.source_id = lsr.result_id "+
                	"and ai.gene_id = ? "+
			"and crr.coref_id = ? "+
                	"and ai.gene_list_id = lsr.gene_list_id "+
                	"and ai.gene_id = lsr.gene_id "+
			"union "+
			"select '"+
			gene_id +
			"' from dual";

		log.debug("in getAlternateIDs used in Coref");

		String[] dataRow;
		Results myResults = new Results(query, new Object[] {gene_id, coref_id}, conn);
		String[] myIdentifiers = new String[myResults.getNumRows()];

		int i=0;
		while ((dataRow = myResults.getNextRow()) != null) {
			myIdentifiers[i] = dataRow[0];
			i++;
		}
		myResults.close();

		return myIdentifiers;
	}

	/**
	 * Retrieves the set of alternate identifiers used in the literature search.
	 * @param gene_id	the identifier of the gene used in the search
	 * @param search_id	the identifier for the literature search
	 * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
	 * @return          an array of String objects containing the identifiers
	 */

	public String[] getAlternateIdentifiersUsedInLitSearch(String gene_id, int search_id, Connection conn) throws SQLException {

        	String query =
                	"select distinct ai.alternate_id "+
                	"from alternate_identifiers ai, "+
			"lit_search_results lsr "+
                	"where ai.source_id = lsr.result_id "+
                	"and lsr.search_id = ? "+
                	"and ai.gene_id = ? "+
                	"and ai.gene_list_id = lsr.gene_list_id "+
                	"and ai.gene_id = lsr.gene_id "+
			"union "+
			"select '"+
			gene_id +
			"' from dual";

		log.debug("in getAlternateIDs used in litsearch");

		String[] dataRow;
		Results myResults = new Results(query, new Object[] {search_id, gene_id}, conn);
		String[] myIdentifiers = new String[myResults.getNumRows()];

		int i=0;
		while ((dataRow = myResults.getNextRow()) != null) {
			myIdentifiers[i] = dataRow[0];
			i++;
		}
		myResults.close();

		return myIdentifiers;
	}

	/**
	 * Retrieves the set of keywords used in the literature search.
	 * @param search_id	the identifier for the literature search
	 * @param category	the category
	 * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
	 * @return          an array of String objects containing the keywords
	 */
  
	public String[] getKeywordsUsedInLitSearch(int search_id, String category, Connection conn) throws SQLException {

    		String query =
            		"select distinct k.keyword "+
            		"from keywords k, "+
			"lit_search_results lsr "+
            		"where k.search_id = lsr.search_id "+
            		"and k.search_id = ? "+
			"and k.category like '"+
			category +
			"%'";
            
    		log.debug("in getKeywordsUsedInLitSearch");
    		//log.debug("query = " + query);

		String[] dataRow;
		Results myResults = new Results(query, new Object[] {search_id}, conn);
		String[] myKeywords = new String[myResults.getNumRows()];

		int i=0;
		while ((dataRow = myResults.getNextRow()) != null) {
			myKeywords[i] = dataRow[0];
			i++;
		}
		myResults.close();

		return myKeywords;
	}

	/**
	 * Retrieves the set of categories and the number of pubmed articles retrieved for that category.
	 * @param search_id	the identifier for the literature search
	 * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
	 * @return          a LinkedHashMap of categories mapped to the number of articles
	 */
	public LinkedHashMap getCategories(int search_id, Connection conn) throws SQLException {

        	String query =
			"select cat.category, count(distinct lsr.category) "+  
			"from categories cat "+
			"left join lit_search_results lsr "+
			"on cat.search_id = lsr.search_id "+
			"and cat.category = lsr.category "+
			"where cat.search_id = ? "+  
			"group by cat.category "+ 
			"order by category "; 

		log.debug("in getCategories");

		String[] dataRow;
		Results myResults = new Results(query, new Object[] {search_id}, conn);
		LinkedHashMap<String, String> myCategories = new LinkedHashMap<String, String>();

		while ((dataRow = myResults.getNextRow()) != null) {
			myCategories.put(dataRow[0], dataRow[1]);
		}
		myResults.close();

		return myCategories;
	}

	/**
	 * Retrieves abstracts from the mdlnProd database.
	 * @param coref_id	the identifier for the set of co_references
	 * @param databaseLink	the database SID (either dev, test, or prod)
	 * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
	 * @return          a Results object
	 */
	public Results getCoRefAbstracts(int coref_id, String databaseLink, Connection conn) throws SQLException {
        	String query =
			"select 'Articles co-referencing these genes:  '||'|||'||coref.name column1, "+ 
			"pmr.pubmed_id, "+
			"mc.article_title||' ('||pub_date_month||', '||pub_date_year||')' article_title, "+ 
			"mc.abstract_text "+ 
			"from mdln_citation mc, "+ 
			"co_reference_pubmed_results@" + databaseLink + " pmr, "+ 
			"co_reference_results@" + databaseLink + " coref "+ 
			"where mc.pmid = pmr.pubmed_id "+ 
			"and coref.coref_id = ? "+ 
			"and coref.coref_id = pmr.coref_id";

		log.debug("in getCoRefAbstracts");
		//log.debug("query = " + query);

		Results myResults = new Results(query, coref_id, conn);

        	return myResults;
	}

	/**
	 * Retrieves abstracts from the mdlnProd database.
	 * @param search_id	the identifier for the literature search
	 * @param gene	the identifier for the gene
	 * @param category	the name of the category
	 * @param databaseLink	the database SID (either dev, test, or prod)
	 * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
	 * @return          a Results object
	 */
	public Results getAbstracts(int search_id, String gene, String category, String databaseLink, Connection conn) throws SQLException {

		String whereClauses = "";
		if (!gene.equals("")) {
			whereClauses = "and lsr.gene_id = ? "; 
		}
		if (!category.equals("")) {
			whereClauses = whereClauses + "and lsr.category = ? "; 
		}
		
        	String query =
			"select lsr.gene_id||'|||'||lsr.category column1, "+ 
			"pmr.pubmed_id, "+
			"mc.article_title||' ('|| "+
			"	nvl(journal_title, medline_ta)||' -- '||"+
			"	pub_date_month||', '||pub_date_year||')' article_title, "+
			"mc.abstract_text "+ 
			"from mdln_citation mc, "+ 
			"pubmed_results@" + databaseLink + " pmr, "+ 
			"lit_search_results@" + databaseLink + " lsr "+ 
			"where mc.pmid = pmr.pubmed_id "+ 
			"and lsr.search_id = ? "+ 
			"and lsr.result_id = pmr.result_id "+
			whereClauses +
			"order by lsr.gene_id, lsr.category, pub_date_year desc"; 

		log.debug("in getAbstracts. gene = " + gene + ", category = " + category + ", databaseLink = "+databaseLink);
		//log.debug("query = " + query);

                List<Object> parameterList = new ArrayList<Object>();

		parameterList.add(search_id);
		if (!gene.equals("")) {
                	parameterList.add(gene);
			if (!category.equals("")) {
                		parameterList.add(category);
			}
		} else if (gene.equals("") && !category.equals("")) {
                	parameterList.add(category);
		}

                Object[] parameters = (Object[]) parameterList.toArray(new Object[parameterList.size()]);

                Results myResults = new Results(query, parameters, conn);

        	return myResults;
	}


	/**
	 * Retrieves co-reference records.
	 * @param search_id	the identifier for the literature search
	 * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
	 * @return          a Results object
	 */
	public Results getCoReferences(int search_id, Connection conn) throws SQLException {

        	String query =
			"select crr.coref_id, "+
			"crr.name, "+ 
			"count(*) "+
			"from co_reference_results crr, "+ 
			"co_reference_pubmed_results crpr "+ 
			"where search_id = ? "+ 
			"and crr.coref_id = crpr.coref_id "+
			"group by crr.coref_id, "+
			"crr.name, "+
			"crr.number_of_genes "+
			"order by crr.number_of_genes desc, 3 desc"; 

		log.debug("in getCoReferences");
		//log.debug("query = "+ query);
		Results myResults = new Results(query, search_id, conn);

        	return myResults;
	}

  public Results getPubMedCountsByCategory(int search_id, Connection conn) throws SQLException {

	//
	// gets the genes, all of the alternate identifiers retrieved for that gene, 
	// and the pubmed counts by category for the gene
	// join(cursor(xxx)) joins multiple alternate identifiers into one field 
	// delimited by a comma plus a space
	// The first select before the union gets those categories that had results
	// after the union gets those that did not have any results
	//
        String query =
		"select lsr.gene_id, "+
		"nvl(to_char(join(cursor(select ai.alternate_id "+
		"from alternate_identifiers ai "+
		"where ai.source_id = lsr.result_id "+
                "and ai.gene_list_id = lsr.gene_list_id "+
                "and ai.gene_id = lsr.gene_id "+
		"and ai.source = 'LitSearch' order by ai.alternate_id), ', ')), 'None') alternate_id, "+
		"cat.category, "+ 
		"decode(lsr.category, cat.category, count(distinct pmr.pubmed_id), 0) pubmed_count "+
		"from categories cat, "+
		"lit_search_results lsr "+ 
		"left join pubmed_results pmr on lsr.result_id = pmr.result_id "+ 
		"where cat.search_id = ? "+ 
		"and cat.search_id = lsr.search_id "+ 
		"and cat.category = lsr.category "+ 
		"group by lsr.gene_id, "+ 
		"lsr.gene_list_id, "+
		"lsr.category, "+ 
		"cat.category, "+ 
		"lsr.result_id "+ 
		"union "+
		"(select lsr.gene_id, "+
		"nvl(to_char(join(cursor(select ai.alternate_id "+
		"from alternate_identifiers ai "+
		"where ai.source_id = lsr.result_id "+
                "and ai.gene_list_id = lsr.gene_list_id "+
                "and ai.gene_id = lsr.gene_id "+
		"and ai.source = 'LitSearch' order by ai.alternate_id), ', ')), 'None') alternate_id, "+
		"cat.category, "+
		"0 "+
		"from categories cat, "+
		"lit_search_results lsr "+
		"where cat.search_id = lsr.search_id "+
		"and lsr.search_id = ? "+
		"minus "+
		"select lsr.gene_id, "+
		"nvl(to_char(join(cursor(select ai.alternate_id "+
		"from alternate_identifiers ai "+
		"where ai.source_id = lsr.result_id "+
                "and ai.gene_list_id = lsr.gene_list_id "+
                "and ai.gene_id = lsr.gene_id "+
		"and ai.source = 'LitSearch' order by ai.alternate_id), ', ')), 'None') alternate_id, "+
		"cat.category, "+
		"0 "+
		"from categories cat, "+
		"lit_search_results lsr "+
		"where cat.search_id = lsr.search_id "+
		"and cat.category = lsr.category "+
		"and lsr.search_id = ?) "+
		"order by 1,3";

	log.debug("in getPubMedCountsByCategory");
	//log.debug("query = "+ query);

	Results myResults = new Results(query, new Object[] {search_id, search_id, search_id}, conn);

        return myResults;
  }

  public Results getCategoriesAndKeywords(int search_id, Connection conn) throws SQLException {

        String query =
             "select c.category, k.keyword "+ 
             "from categories c, keywords k "+ 
             "where c.category = k.category "+ 
             "and c.search_id = ? "+ 
             "and k.search_id = ? "+ 
             "order by c.category, k.keyword "; 

	log.debug("in getCategoriesAndKeywords ");

	Results myResults = new Results(query, new Object[] {search_id, search_id}, conn);

        return myResults;
  }

  public int createLitSearch (LitSearch myLitSearch, Connection conn) throws SQLException {

	search_id = myDbUtils.getUniqueID("gene_list_analyses_seq", conn);

        String query =
                "insert into gene_list_analyses "+
                "(analysis_id, gene_list_id, user_id, create_date, description, visible, analysis_type) values "+
                "(?, ?, ?, ?, ?, 0, 'LitSearch')";

        PreparedStatement pstmt= null;

	log.debug("in LitSearch.createLitSearch. search_id = " + search_id);
        try {

                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

                pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, search_id); 
                pstmt.setInt(2, myLitSearch.getGene_list_id());
                pstmt.setInt(3, myLitSearch.getUser_id());
                pstmt.setTimestamp(4, now);
                pstmt.setString(5, myLitSearch.getDescription());   

                pstmt.executeUpdate();

		myLitSearch.setSearch_id(search_id);
		createCategories(myLitSearch, conn);

		pstmt.close();
        } catch (SQLException e) {
		log.error("In exception of createLitSearch", e);
		throw e;
        }
  	return search_id;
  }

  public int createCoReferenceResult (String coref_name, int cardinality, Connection conn) throws SQLException {

	int coref_id = myDbUtils.getUniqueID("co_reference_results_seq", conn);

        String query =
                "insert into co_reference_results "+
                "(coref_id, search_id, number_of_genes, name) values "+
                "(?, ?, ?, ?)";

        PreparedStatement pstmt= null;

	//log.debug("in LitSearch.createCoReferenceResult");
        try {

                pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, coref_id); 
                pstmt.setInt(2, this.getSearch_id()); 
                pstmt.setInt(3, cardinality); 
                pstmt.setString(4, coref_name);

                pstmt.executeUpdate();
		pstmt.close();

        } catch (SQLException e) {
		log.error("In exception of createCoReferenceResult", e);
		throw e;
        }
	return coref_id;
  }

  public int createLitSearchResult (String category, String gene_id, Connection conn) throws SQLException {

	int result_id = myDbUtils.getUniqueID("lit_search_results_seq", conn);

        String query =
                "insert into lit_search_results "+
                "(result_id, search_id, category, gene_id, gene_list_id) "+
		"values "+
                "(?, ?, ?, ?, ?)";

        PreparedStatement pstmt= null;

	//log.debug("in LitSearch.createLitSearchResult");
        try {

                pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, result_id); 
                pstmt.setInt(2, this.getSearch_id()); 
                pstmt.setString(3, category);
                pstmt.setString(4, gene_id);
                pstmt.setInt(5, this.getGene_list_id());

                pstmt.executeUpdate();
		pstmt.close();

        } catch (SQLException e) {
		log.error("In exception of createLitSearchResult", e);
		throw e;
        }
  return result_id;
  }

  public void createCoReferencePubMedResults (int coref_id, List pubMedResults, Connection conn) throws SQLException {

        String query =
                "insert into co_reference_pubmed_results "+
                "(coref_id, pubmed_id) values "+
                "(?, ?)";

        PreparedStatement pstmt= null;

	log.debug("in LitSearch.createCoReferencePubMedResults");
        try {

                pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
		//
		// batch the insert statements sent to Oracle
		//
		((OraclePreparedStatement) pstmt).setExecuteBatch(50);
                pstmt.setInt(1, coref_id); 
		for (int i=0; i<pubMedResults.size(); i++) {
	                pstmt.setString(2, pubMedResults.get(i).toString()); 
                	pstmt.executeUpdate();
		}
		pstmt.close();

        } catch (SQLException e) {
		log.error("In exception of createCoReferencePubMedResult", e);
		throw e;
        }
  }

  public void createPubMedResults (int result_id, List pubMedResults, Connection conn) throws SQLException {

        String query =
                "insert into pubmed_results "+
                "(result_id, pubmed_id) values "+
                "(?, ?)";

        PreparedStatement pstmt= null;

	//log.debug("in LitSearch.createPubMedResults");
        try {

                pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
		//
		// batch the insert statements sent to Oracle
		//
		((OraclePreparedStatement) pstmt).setExecuteBatch(50);
                pstmt.setInt(1, result_id); 
		for (int i=0; i<pubMedResults.size(); i++) {
	                pstmt.setString(2, pubMedResults.get(i).toString()); 
                	pstmt.executeUpdate();
		}
		pstmt.close();


        } catch (SQLException e) {
		log.error("In exception of createPubMedResult", e);
		throw e;
        }
  }

  public void deleteLitSearch(int search_id, DataSource pool) throws SQLException {
  	
	log.info("in deleteLitSearch");

	String[] query = new String[8];

  	query[0] =
		"delete from pubmed_results pr "+
		"where exists "+
			"(select 'x' "+
			"from lit_search_results lsr "+
			"where search_id = ? "+
			"and pr.result_id = lsr.result_id)";
    
  	query[1] =
                "delete from keywords k "+
                "where search_id = ?";

  	query[2] =
                "delete from co_reference_pubmed_results crpr "+
                "where exists "+
                        "(select 'x' "+
                        "from co_reference_results crr "+
			"where search_id = ? "+
			"and crpr.coref_id = crr.coref_id)";

  	query[3] =
                "delete from co_reference_results crr "+
                "where search_id = ?";

  	query[4] =
                "delete from alternate_identifiers ai  "+
                "where exists "+
                        "(select 'x' "+
                        "from lit_search_results lsr "+
			"where search_id = ? "+
                        "and ai.source_id = lsr.result_id "+
			"and ai.source = 'LitSearch')";

  	query[5] =
	        "delete from lit_search_results "+
		"where search_id = ?";

  	query[6] =
                "delete from categories c "+
                "where search_id = ?";

  	query[7] = 
		"delete from gene_list_analyses "+
		"where analysis_id = ?";

  	
  	PreparedStatement pstmt = null;
        Connection conn=null;
	try {
            conn=pool.getConnection();
            for (int i=0; i<query.length; i++) {
                    log.debug("i = " + i + ", query = " + query[i]);
                    pstmt = conn.prepareStatement(query[i],
                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                        ResultSet.CONCUR_UPDATABLE);
                    pstmt.setInt(1, search_id);

                    pstmt.executeUpdate();
                    pstmt.close();
            }
            conn.close();
            conn=null;
	} catch (SQLException e) {
		log.error("In exception of deleteLitSearch", e);
		throw e;
	}finally{
                    if(conn!=null && !conn.isClosed()){
                        try{
                            conn.close();
                            conn=null;
                        }catch(SQLException e){}
                    }
                }	

  }
  
  public void deleteAllLitSearchesForGeneList(int gene_list_id, Connection conn) throws SQLException {
  	
	log.debug("in deleteAllLitSearchesForGeneList");

	String[] query = new String[8];

  	query[0] =
		"delete from pubmed_results pr "+
		"where exists "+
			"(select 'x' "+
			"from lit_search_results lsr "+
			"where gene_list_id = ? "+
			"and pr.result_id = lsr.result_id)";
    
  	query[1] =
                "delete from keywords k "+
                "where exists "+
                        "(select 'x' "+
                        "from gene_list_analyses ls "+
			"where gene_list_id = ? "+
                        "and k.search_id = ls.analysis_id)";

  	query[2] =
                "delete from co_reference_pubmed_results crpr "+
                "where exists "+
                        "(select 'x' "+
                        "from co_reference_results crr "+
			"where exists "+
                        	"(select 'x' "+
	                        "from gene_list_analyses ls "+
				"where gene_list_id = ? "+
				"and crr.search_id = ls.analysis_id) "+
			"and crr.coref_id = crpr.coref_id)";

  	query[3] =
                "delete from co_reference_results crr "+
                "where exists "+
                        "(select 'x' "+
                        "from gene_list_analyses ls "+
			"where gene_list_id = ? "+
                        "and crr.search_id = ls.analysis_id)";

  	query[4] =
                "delete from alternate_identifiers ai  "+
                "where exists "+
                        "(select 'x' "+
                        "from lit_search_results lsr "+
			"where gene_list_id = ? "+
                        "and ai.source_id = lsr.result_id "+
			"and ai.source = 'LitSearch')";

  	query[5] =
	        "delete from lit_search_results "+
		"where gene_list_id = ?";

  	query[6] =
                "delete from categories c "+
                "where exists "+
                        "(select 'x' "+
                        "from gene_list_analyses ls "+
			"where gene_list_id = ? "+
                        "and c.search_id = ls.analysis_id)";


  	query[7] = 
		"delete from gene_list_analyses "+
		"where gene_list_id = ? "+
		"and analysis_type = 'LitSearch'";
  	
  	PreparedStatement pstmt = null;

	conn.setAutoCommit(false);
	try {
                for (int i=0; i<query.length; i++) {
                        //log.debug("i = " + i + ", query = " + query[i]);
                        pstmt = conn.prepareStatement(query[i],
                            		ResultSet.TYPE_SCROLL_INSENSITIVE,
                            		ResultSet.CONCUR_UPDATABLE);
                        pstmt.setInt(1, gene_list_id);

                        pstmt.executeUpdate();
                        pstmt.close();
                }
		conn.commit();
	} catch (SQLException e) {
		log.error("In exception of deleteAllLitSearchesForGeneList", e);
		conn.rollback();
		throw e;
	}	

	conn.setAutoCommit(true);
  }
  
  public String[] getAllLitSearchesForUserStatements(String typeOfQuery) {

	String[] query = new String[8];

        String selectClause = myDbUtils.getSelectClause(typeOfQuery);
        String rownumClause = myDbUtils.getRownumClause(typeOfQuery);

  	query[0] =
		selectClause +
		"from pubmed_results pr "+
		"where exists "+
			"(select 'x' "+
			"from lit_search_results lsr "+
			"where exists "+
                        	"(select 'x' "+
	                        "from gene_list_analyses ls "+
				"where user_id = ? "+
				"and lsr.search_id = ls.analysis_id) "+
			"and pr.result_id = lsr.result_id)"+
		rownumClause;

    
  	query[1] =
                selectClause +
		"from keywords k "+
                "where exists "+
                        "(select 'x' "+
                        "from gene_list_analyses ls "+
			"where user_id = ? "+
                        "and k.search_id = ls.analysis_id)"+
		rownumClause;

  	query[2] =
                selectClause +
		"from co_reference_pubmed_results crpr "+
                "where exists "+
                        "(select 'x' "+
                        "from co_reference_results crr "+
			"where exists "+
                        	"(select 'x' "+
	                        "from gene_list_analyses ls "+
				"where user_id = ? "+
				"and crr.search_id = ls.analysis_id) "+
			"and crr.coref_id = crpr.coref_id)"+
		rownumClause;

  	query[3] =
                selectClause +
		"from co_reference_results crr "+
                "where exists "+
                        "(select 'x' "+
                        "from gene_list_analyses ls "+
			"where user_id = ? "+
                        "and crr.search_id = ls.analysis_id)"+
		rownumClause;

  	query[4] =
                selectClause +
		"from alternate_identifiers ai  "+
                "where exists "+
                        "(select 'x' "+
                        "from lit_search_results lsr "+
			"where exists  "+
                        	"(select 'x' "+
	                        "from gene_list_analyses ls "+
				"where user_id = ? "+
				"and lsr.search_id = ls.analysis_id) "+
                        "and ai.source_id = lsr.result_id "+
			"and ai.source = 'LitSearch')"+
		rownumClause;

  	query[5] =
	        selectClause +
		"from lit_search_results lsr "+
                "where exists "+
                        "(select 'x' "+
                        "from gene_list_analyses ls "+
			"where user_id = ? "+
                        "and lsr.search_id = ls.analysis_id)"+
		rownumClause;

  	query[6] =
                selectClause +
		"from categories c "+
                "where exists "+
                        "(select 'x' "+
                        "from gene_list_analyses ls "+
			"where user_id = ? "+
                        "and c.search_id = ls.analysis_id)"+
		rownumClause;


  	query[7] = 
		selectClause +
		"from gene_list_analyses "+
		"where user_id = ? "+
		"and analysis_type = 'LitSearch' "+
		rownumClause;
  	
        //for (int i=0; i<query.length; i++) {
         //     log.debug("i = " + i + ", query = " + query[i]);
        //}
        return query;
  }

  public List<List<String[]>> getAllLitSearchesForUser(int userID, Connection conn) throws SQLException {

	log.debug("in getAllLitSearchesForUser. userID = "+userID);

        //
        // Return the results of 2 queries as a List of a List of String[]
        // The outer list contains all the queries, the inner List is all the rows
        // from one query.
        //

	String[] query = getAllLitSearchesForUserStatements("SELECT10");

        List<List<String[]>> allResults = null;

        try {
                allResults = new Results().getAllResults(query, userID, conn);

	} catch (SQLException e) {
		log.error("In exception of getAllLitSearchesForUser", e);
		throw e;
	}	
        log.debug("returning allResults.length = "+allResults.size());
        return allResults;

  }

  public void deleteAllLitSearchesForUser(int userID, Connection conn) throws SQLException {

	log.debug("in deleteAllLitSearchesForUser. userID = "+userID);

	String[] query = getAllLitSearchesForUserStatements("DELETE");

  	PreparedStatement pstmt = null;

	try {
                for (int i=0; i<query.length; i++) {
                        log.debug("i = " + i + ", query = " + query[i]);
                        pstmt = conn.prepareStatement(query[i],
                            ResultSet.TYPE_SCROLL_INSENSITIVE,
                            ResultSet.CONCUR_UPDATABLE);
                        pstmt.setInt(1, userID);

                        pstmt.executeUpdate();
                }
	} catch (SQLException e) {
		log.error("In exception of deleteAllLitSearchesForUser", e);
		throw e;
	}	
	pstmt.close();
  }

  public void callLiterature() throws Exception{
	log.debug("calling Literature");
	boolean autoAlcohol;

	if (include_alcohol != null && include_alcohol.equals("Y")) {
		autoAlcohol = true;
	} else {
		autoAlcohol = false;
	}
	Literature myLiterature = new Literature();
	log.debug("before doing search");

	hitset = myLiterature.search(categories, ids, autoAlcohol);
	log.debug("after doing search");

	corefs = hitset.getCoReferences();

  }


  public void processResults(Connection conn) throws SQLException {
	log.debug("in LitSearch.processResults. genelistID = " + this.getGene_list_id());
	GeneList myGeneList = new GeneList();
	
	conn.setAutoCommit(false);
	Iterator categoryIterator = categories.keySet().iterator();

        PubMedCollection hits;

        while(categoryIterator.hasNext()) {
		String cat = (String) categoryIterator.next();

                Iterator idIterator  = ids.keySet().iterator();

                while(idIterator.hasNext()) {
                	String id = (String) idIterator.next();

                        hits = (PubMedCollection) hitset.getSubCollection(cat, id);
                        //log.debug("category = " + cat + ", id = " + id + ", hits = "+ hits.getCount());

			if (hits.getCount() != 0) {

	                       	int resultID = createLitSearchResult(cat, id, conn);
				
				//log.debug("just created LitSearchResult.  Now creating alternate_identifiers");
				myGeneList.setGene_list_id(this.gene_list_id);
				myGeneList.setAlternateIdentifierSource("LitSearch");
				myGeneList.setAlternateIdentifierSourceLinkColumn("LITSEARCH_RESULTS.RESULT_ID");
				myGeneList.setAlternateIdentifierSourceID(resultID);
				myGeneList.setGenesHashMap(ids);
				myGeneList.createAlternateIdentifiers(myGeneList, conn);

				//log.debug("resultID = "+resultID);

                        	Iterator hitsIterator = hits.getEntries().values().iterator();

				List<Integer> pubMedResults = new ArrayList<Integer>(); 
	                        while(hitsIterator.hasNext()) {
       	                 		PubMedEntry entry = (PubMedEntry) hitsIterator.next();
					pubMedResults.add(entry.getPmid());
                        	}
				createPubMedResults(resultID, pubMedResults, conn);
			}
                }
        }

	int cardinal = corefs.getMaxCardinality();
        HashSet tuples;
        Iterator tupIt, corefIt;
        PubMedCollection.Tuple tup;
        HashSet corefsEntries;
        Iterator tupsItr;
        PubMedEntry corefEnt;

        HashMap corefsCollection = corefs.getCorefCollection();
        Iterator itr = corefsCollection.keySet().iterator();
        Integer i;
        HashMap tupleGroup;
        String tupId;
        HashSet tupCorefs;
	int cardinality;
	String tupleString = "";

	while (itr.hasNext()) {
        	i = (Integer)itr.next();
                tupleGroup = (HashMap) corefsCollection.get(i);
                tupsItr = tupleGroup.keySet().iterator();

                while(tupsItr.hasNext()) {
                	tup = (PubMedCollection.Tuple) tupsItr.next();
                        tupId = tup.getIdentifier();
			cardinality = tup.getCardinality();
                        tupleString = tup.getTupleString(", ");

			log.debug("tupID = " + tupId + ", cardinality = " + cardinality + ", tupleString = " + tupleString);

			int coref_id = createCoReferenceResult(tupId, cardinality, conn);

                        corefsEntries = corefs.getCorefs(tup);

			List<Integer> pubMedResults = new ArrayList<Integer>(); 
                        corefIt = corefsEntries.iterator();
			//log.debug("PMIDs = ");
                        while(corefIt.hasNext()) {
                        	corefEnt = (PubMedEntry) corefIt.next();
				pubMedResults.add(corefEnt.getPmid());
                                //log.debug("\t" + corefEnt.getPmid());
                        }
                        log.debug("\n");
			createCoReferencePubMedResults(coref_id, pubMedResults, conn);
		}
	}

	conn.commit();
	conn.setAutoCommit(true);
  }

  public void updateVisible (Connection conn) throws SQLException {

        String query =
                "update gene_list_analyses "+
                "set visible = 1 "+
                "where analysis_id = ?";

        log.debug("in updateVisible for LitSearch");
        PreparedStatement pstmt = null;

        try {

                pstmt = conn.prepareStatement(query,
                                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                                        ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, this.getSearch_id());

                pstmt.executeUpdate();

        } catch (SQLException e) {
                log.error("In exception of updateVisible for LitSearch", e);
                throw e;
        }
  }


}

