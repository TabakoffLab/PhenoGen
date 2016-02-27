package edu.ucdenver.ccp.PhenoGen.tools.idecoder;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.FileWriter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.sql.DataSource;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.sql.Results;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;
import edu.ucdenver.ccp.PhenoGen.data.AnonGeneList;

import org.apache.log4j.Logger;

/**
 * Class for finding related Identifiers.  When first called, does a breadth-first-search through a 
 * graph whose nodes are Identifiers and edges are IdentifierLinks.
 * @author Created by Eric Ellington in Dec, 2005
 * @author Modified by Cheryl Hornbaker Mar, 2006 and re-written (practically!) in Feb, 2007
 *
 */
 
public class IDecoderClient {
	private Logger log = null;

	private Connection connection = null;
	private Debugger myDebugger = new Debugger();

	private String[] idvalues = null;
	// this must be initialized to a null String so that to avoid a NullPointer
	private String[] targets = {""};
	List targetsList = Arrays.asList(targets);
	private String organism; 
	private String gene_chip_name; 
	
	private static final long NOT_APPLICABLE_TAXON_ID = 9999; 
	private static final long RAT_TAXON_ID = 10116; 
	private static final long HUMAN_TAXON_ID = 9606; 
	private static final long MOUSE_TAXON_ID = 10090; 
	private static final long FLY_TAXON_ID = 7227; 

	private int num_iterations = 1;

	private HashMap<Identifier, Set<IdentifierLink>> linkGraph = new HashMap<Identifier, Set<IdentifierLink>>(); 

	public IDecoderClient() {
		log = Logger.getRootLogger();
	}

	public void setIdvalues(String[] inArray) {
		this.idvalues = inArray;
	}

	public void setOrganism(String inString) {
		this.organism = inString;
	}

	public void setGene_chip_name(String inString) {
		//log.debug("setting gene_chip_name to "+inString);
		this.gene_chip_name =  inString;
	}
	
	public void setNum_iterations(int inInt) {
		this.num_iterations =  inInt;
	}

	public HashMap<Identifier, Set<IdentifierLink>> getLinkGraph() {
		return this.linkGraph;
	}

	public void setTargets(String[] inArray) {
		this.targets = inArray;
		this.targetsList = Arrays.asList(targets);
	}
	private HashMap<Identifier, Set<Identifier>> doSearch(int geneListID, DataSource pool) throws SQLException {
            log.debug("in doSearch passing gene list ID");
            HashMap<Identifier, Set<Identifier>> resultsHashMap = new HashMap<Identifier, Set<Identifier>>();
            //GeneList thisGL = new GeneList().getGeneList(geneListID, conn);
            GeneList thisGL = null;
            try{
                thisGL=new GeneList().getGeneList(geneListID, pool);
            }catch(NullPointerException e){
                thisGL=new AnonGeneList().getGeneList(geneListID, pool);
            }
            String organism = thisGL.getOrganism();
            log.debug("geneList = "+thisGL.getGene_list_name());
            String countQuery2 = 
			"select count(*) from geneListGraph";
            //
		// Insert the identifiers from the original gene list 
		//
		String query = 
			"insert into geneListGraph "+
			"(start_id_number, "+
			"start_identifier, "+
			"ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, "+
			"start_bp, "+
			"category, "+
			"organism, "+
			"array_name, "+
			"from_id_number, "+
			"from_identifier, "+
			"link_source_name) "+
			"select "+
			"id.id_number, "+
			"id.identifier, "+
			"id.ident_type_id, "+
			"type.name, "+
			"id.id_number, "+
			"id.identifier, "+
			"id.chromosome, "+
			"id.map_location, "+
			"id.cM, "+
			"id.start_bp, "+
			"type.category, "+
			"id.organism, "+
			"'', "+
			"id.id_number, "+
			"id.identifier, "+
			"'Start' "+
			"from identifiers id, "+
			"identifier_types type, "+ 
			"genes g, "+ 
			"gene_lists gl "+
			"where id.identifier = g.gene_id "+
			"and id.ident_type_id = type.ident_type_id  "+
			"and id.organism = gl.organism  "+
			"and g.gene_list_id = gl.gene_list_id "+
			"and g.gene_list_id = ?";
                Connection conn=null;
                try{
                    conn=pool.getConnection();
                    conn.setAutoCommit(false);
                    PreparedStatement pstmt = conn.prepareStatement(query);
                    pstmt.setInt(1, geneListID);
                    pstmt.executeQuery();
                    pstmt.close();
                    resultsHashMap = doSearch(organism,conn);
                    conn.close();
                }catch(SQLException e){
                    log.error("Error:",e);
                }finally{
                    if(conn!=null && !conn.isClosed()){
                        try{
                            conn.close();
                            conn=null;
                        }catch(SQLException e){}
                    }
                }
		//Results myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 1 = "+ myResults.getIntValueFromFirstRow());
		
                //myResults.close();
            
            return resultsHashMap;
        }	
        private HashMap<Identifier, Set<Identifier>> doSearch(int geneListID, Connection conn) throws SQLException {
            log.debug("in doSearch passing gene list ID");
            GeneList thisGL = new GeneList().getGeneList(geneListID, conn);
            String organism = thisGL.getOrganism();
            log.debug("geneList = "+thisGL.getGene_list_name());
            String countQuery2 = 
			"select count(*) from geneListGraph";
            //
		// Insert the identifiers from the original gene list 
		//
		String query = 
			"insert into geneListGraph "+
			"(start_id_number, "+
			"start_identifier, "+
			"ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, "+
			"start_bp, "+
			"category, "+
			"organism, "+
			"array_name, "+
			"from_id_number, "+
			"from_identifier, "+
			"link_source_name) "+
			"select "+
			"id.id_number, "+
			"id.identifier, "+
			"id.ident_type_id, "+
			"type.name, "+
			"id.id_number, "+
			"id.identifier, "+
			"id.chromosome, "+
			"id.map_location, "+
			"id.cM, "+
			"id.start_bp, "+
			"type.category, "+
			"id.organism, "+
			"'', "+
			"id.id_number, "+
			"id.identifier, "+
			"'Start' "+
			"from identifiers id, "+
			"identifier_types type, "+ 
			"genes g, "+ 
			"gene_lists gl "+
			"where id.identifier = g.gene_id "+
			"and id.ident_type_id = type.ident_type_id  "+
			"and id.organism = gl.organism  "+
			"and g.gene_list_id = gl.gene_list_id "+
			"and g.gene_list_id = ?";
                
                conn.setAutoCommit(false);
                PreparedStatement pstmt = conn.prepareStatement(query);
		pstmt.setInt(1, geneListID);
		pstmt.executeQuery();
		pstmt.close();

		//Results myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 1 = "+ myResults.getIntValueFromFirstRow());
		
                //myResults.close();
            
            return doSearch(organism,conn);
        }
        
        private HashMap<Identifier, Set<Identifier>> doSearchCaseInsensitive(int geneListID, DataSource pool) throws SQLException {
            log.debug("in doSearch passing gene list ID");
            
            //GeneList thisGL = new GeneList().getGeneList(geneListID, pool);
            GeneList thisGL = null;
            try{
                thisGL=new GeneList().getGeneList(geneListID, pool);
            }catch(NullPointerException e){
                thisGL=new AnonGeneList().getGeneList(geneListID, pool);
            }
            String organism = thisGL.getOrganism();
            log.debug("geneList = "+thisGL.getGene_list_name());
            String countQuery2 = 
			"select count(*) from geneListGraph";
            //
		// Insert the identifiers from the original gene list 
		//
		String query = 
			"insert into geneListGraph "+
			"(start_id_number, "+
			"start_identifier, "+
			"ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, "+
			"start_bp, "+
			"category, "+
			"organism, "+
			"array_name, "+
			"from_id_number, "+
			"from_identifier, "+
			"link_source_name) "+
			"select "+
			"id.id_number, "+
			"id.identifier, "+
			"id.ident_type_id, "+
			"type.name, "+
			"id.id_number, "+
			"id.identifier, "+
			"id.chromosome, "+
			"id.map_location, "+
			"id.cM, "+
			"id.start_bp, "+
			"type.category, "+
			"id.organism, "+
			"'', "+
			"id.id_number, "+
			"id.identifier, "+
			"'Start' "+
			"from identifiers id, "+
			"identifier_types type, "+ 
			"genes g, "+ 
			"gene_lists gl "+
			"where LOWER(id.identifier) = LOWER(g.gene_id) "+
			"and id.ident_type_id = type.ident_type_id  "+
			"and id.organism = gl.organism  "+
			"and g.gene_list_id = gl.gene_list_id "+
			"and g.gene_list_id = ?";
                Connection conn=pool.getConnection();
                conn.setAutoCommit(false);
                PreparedStatement pstmt = conn.prepareStatement(query);
		pstmt.setInt(1, geneListID);
		pstmt.executeQuery();
		pstmt.close();

		//Results myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 1 = "+ myResults.getIntValueFromFirstRow());
		
                //myResults.close();
                HashMap<Identifier, Set<Identifier>> ret=doSearch(organism,conn);
                conn.close();
            return ret;
        }
        
        private HashMap<Identifier, Set<Identifier>> doSearch(String gene,String organism, Connection conn) throws SQLException {
            log.debug("in doSearch passing gene ID");
            log.debug("geneID = "+gene);
            String countQuery2 = 
			"select count(*) from geneListGraph";
            //
		// Insert the identifiers from the original gene list 
		//
		String query = 
			"insert into geneListGraph "+
			"(start_id_number, "+
			"start_identifier, "+
			"ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, "+
			"start_bp, "+
			"category, "+
			"organism, "+
			"array_name, "+
			"from_id_number, "+
			"from_identifier, "+
			"link_source_name) "+
			"select "+
			"id.id_number, "+
			"id.identifier, "+
			"id.ident_type_id, "+
			"type.name, "+
			"id.id_number, "+
			"id.identifier, "+
			"id.chromosome, "+
			"id.map_location, "+
			"id.cM, "+
			"id.start_bp, "+
			"type.category, "+
			"id.organism, "+
			"'', "+
			"id.id_number, "+
			"id.identifier, "+
			"'Start' "+
			"from identifiers id, "+
			"identifier_types type "+ 
			"where LOWER(id.identifier) = LOWER(?) "+
			"and id.ident_type_id = type.ident_type_id  "+
			"and id.organism = ?";
                
                conn.setAutoCommit(false);
                //log.debug("query = "+query);
                PreparedStatement pstmt = conn.prepareStatement(query);
		pstmt.setString(1, gene);
                pstmt.setString(2, organism);
		pstmt.executeQuery();
		pstmt.close();

		//Results myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 1 = "+ myResults.getIntValueFromFirstRow());
		
                //myResults.close();
            return doSearchAll(organism, conn);
        }
        
        private HashMap<Identifier, Set<Identifier>> doSearch(String gene,String organism, DataSource pool) throws SQLException {
            log.debug("in doSearch passing gene ID");
            log.debug("geneID = "+gene);
            String countQuery2 = 
			"select count(*) from geneListGraph";
            //
		// Insert the identifiers from the original gene list 
		//
		String query = 
			"insert into geneListGraph "+
			"(start_id_number, "+
			"start_identifier, "+
			"ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, "+
			"start_bp, "+
			"category, "+
			"organism, "+
			"array_name, "+
			"from_id_number, "+
			"from_identifier, "+
			"link_source_name) "+
			"select "+
			"id.id_number, "+
			"id.identifier, "+
			"id.ident_type_id, "+
			"type.name, "+
			"id.id_number, "+
			"id.identifier, "+
			"id.chromosome, "+
			"id.map_location, "+
			"id.cM, "+
			"id.start_bp, "+
			"type.category, "+
			"id.organism, "+
			"'', "+
			"id.id_number, "+
			"id.identifier, "+
			"'Start' "+
			"from identifiers id, "+
			"identifier_types type "+ 
			"where LOWER(id.identifier) = LOWER(?) "+
			"and id.ident_type_id = type.ident_type_id  "+
			"and id.organism = ?";
                Connection conn=pool.getConnection();
                conn.setAutoCommit(false);
                //log.debug("query = "+query);
                PreparedStatement pstmt = conn.prepareStatement(query);
		pstmt.setString(1, gene);
                pstmt.setString(2, organism);
		pstmt.executeQuery();
		pstmt.close();
                HashMap<Identifier, Set<Identifier>> results=doSearchAll(organism, conn);
		//Results myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 1 = "+ myResults.getIntValueFromFirstRow());
		
                //myResults.close();
                try{
                    conn.close();
                }catch(Exception e){}
            return results;
        }
        
        /**
         * Returns the main HashMap that is used by other methods
         *
         * @param conn          database connection
         *
         * @return              HashMap of results that contains the original Identifier and points to a Set of Identifiers.
         *                      The set of Identifiers contains ALL the Identifiers that were discovered during breadth-first-search
         *                      of graph.  Modified to follow links from Affy IDs as they can be needed to link Ensembl IDs
         *                      To obtain the subset of Identifiers for a list of particular targets, see
	 *			{@link #getIdentifiersByInputIDAndTarget(int geneListID, String[] targets, Connection conn) getIdentifiersByInputIDAndTarget}
         * <br><pre>
         *
         *      ------------------       -------------------------------------------------------------------
         *      | Identifier CDX4 | -------->  | Affy Identifier 15112_at | Entrez Gene Identifier 10329  |...    |
         *      ------------------|       -------------------------------------------------------------------
         *      | Identifier CDX3 | ...|     
         *      ------------------    
         * </pre>
         * @throws Exception    from any other method calls
         */
        private HashMap<Identifier, Set<Identifier>> doSearchAll(String organism, Connection conn) throws SQLException {
                
		HashMap<Identifier, Set<Identifier>> resultsHashMap = new HashMap<Identifier, Set<Identifier>>();
		log.debug("in doSearchAll");
		String targetString = "(" + new ObjectHandler().getAsSeparatedString(targetsList, ",", "'") + ")";
		//
		// Match on organism if the target is not 'Homologene ID'
		//
		String organismString = "and 1=1 ";

		if (!targetsList.contains("Homologene ID")) {
			organismString = "and id.organism = '"+organism + "' ";
		} 
		

		String countQuery2 = 
			"select count(*) from geneListGraph";
		String glgContents = 
			"select * from geneListGraph";
		

		conn.setAutoCommit(false);
                //conn.setAutoCommit(true);
		//log.debug("query1 = "+query);

		

		//Results myGLGResults = new Results(glgContents, conn);
		//myGLGResults.print();

		//
		// Then insert the identifiers that have a row in the identifier_arrays table
		// but don't have any links from them
		//
		String query  ="insert into geneListGraph "+ 
			"(start_id_number, "+
			"start_identifier, "+
			"ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, "+
			"start_bp, "+
			"category, "+
			"organism, "+
			"array_name, "+
			"from_id_number, "+
			"from_identifier, "+
			"link_source_name) "+
			"select distinct /*+ index (id identifiers_pk) */ glg.id_number start_id_number, "+
 			"glg.start_identifier, "+
			"id.ident_type_id, "+
 			"type.name, "+
 			"id.id_number, "+
 			"id.identifier, "+
 			"id.chromosome, "+
 			"id.map_location, "+
 			"id.cM, "+
 			"id.start_bp, "+
 			"type.category, "+
 			"id.organism, "+
 			"ia.array_name, "+
			"glg.id_number, "+
			"glg.identifier, "+
 			"decode(type.name, 'CodeLink ID', 'CodeLink', 'Affymetrix ID', 'Affymetrix', '') "+
			"from identifiers id, "+
 			"identifier_arrays ia, "+
 			"identifier_types type, "+
			"geneListGraph glg "+
			"where glg.id_number = id.id_number "+ 
			"and ia.id_number = id.id_number "+ 
			"and id.ident_type_id = type.ident_type_id "+ 
			"and exists "+
			"	(select 'x' "+ 
			"	from identifier_types it2 "+  
			"	where it2.name in ('Affymetrix ID', 'CodeLink ID') "+ 
			"	and type.ident_type_id = it2.ident_type_id) "+ 
			organismString + 
			//"and id.organism = ?";
			"and not exists "+
			"	(select 'x' "+
			"	from identifier_links3 il3 "+
			"	where il3.id_number1 = id.id_number)";

		log.debug("These are identifiers that have a row in the identifier_arrays table but don't have any links from them");
		//log.debug("query1.5 = "+query);
		PreparedStatement pstmt = conn.prepareStatement(query);
		pstmt.executeQuery();
		pstmt.close();

		//Results myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 2 = "+ myResults.getIntValueFromFirstRow());
                //myResults.close();

		//myGLGResults = new Results(glgContents, conn);
		//myGLGResults.print();
		//
		// Then insert the identifiers that are one link from the original list
		//
		query  ="insert into geneListGraph "+ 
			"(start_id_number, "+
			"start_identifier, "+
			"ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, "+
			"start_bp, "+
			"category, "+
			"organism, "+
			"array_name, "+
			"from_id_number, "+
			"from_identifier, "+
			"link_source_name) "+
			"select distinct /*+ index (id identifiers_pk) */ glg.id_number start_id_number, "+
 			"glg.start_identifier, "+
			"id.ident_type_id, "+
	 		"type.name, "+
	 		"id.id_number, "+
 			"id.identifier, "+
 			"id.chromosome, "+
 			"id.map_location, "+
 			"id.cM, "+
 			"id.start_bp, "+
 			"type.category, "+
 			"id.organism, "+
 			"'' array_name, "+
			"glg.id_number, "+
			"glg.identifier, "+
 			"link.link_source_name "+
			"from identifier_links3 link, "+
 			"identifiers id, "+
 			"identifier_types type, "+
			"geneListGraph glg "+
			"where glg.id_number = link.id_number1  "+
			"and link.id_number2 = id.id_number  "+
			"and id.ident_type_id = type.ident_type_id  "+
			//"and exists "+
			//"	(select 'x' "+
			//"	from identifier_types it2 "+
			//"	where it2.name not in ('Affymetrix ID', 'CodeLink ID') "+
			//"	and type.ident_type_id = it2.ident_type_id) "+ 
			organismString + 
			//"and id.organism = ? "+ 
			"union "+ 
			"select distinct /*+ index (id identifiers_pk) */ glg.id_number start_id_number, "+
 			"glg.start_identifier, "+
			"id.ident_type_id, "+
 			"type.name, "+
 			"id.id_number, "+
 			"id.identifier, "+
 			"id.chromosome, "+
 			"id.map_location, "+
 			"id.cM, "+
 			"id.start_bp, "+
 			"type.category, "+
 			"id.organism, "+
 			"ia.array_name, "+
			"glg.id_number, "+
			"glg.identifier, "+
 			"link.link_source_name "+
			"from identifier_links3 link, "+
 			"identifiers id, "+
 			"identifier_arrays ia, "+
 			"identifier_types type, "+
			"geneListGraph glg "+
			"where glg.id_number = link.id_number1 "+ 
			"and link.id_number2 = id.id_number "+   
			"and ia.id_number = id.id_number "+ 
			"and id.ident_type_id = type.ident_type_id "+ 
			//"and exists "+
			//"	(select 'x' "+ 
			//"	from identifier_types it2 "+  
			//"	where it2.name in ('Affymetrix ID', 'CodeLink ID') "+ 
			//"	and type.ident_type_id = it2.ident_type_id) "+ 
			organismString; 
			//"and id.organism = ?";

		log.debug("These are identifiers that are one link from the original list");
		//log.debug("query2 = "+query);
		pstmt = conn.prepareStatement(query);
		//pstmt.setString(1, organism);
		//pstmt.setString(2, organism);
		pstmt.executeQuery();
		pstmt.close();

		//myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 3 = "+ myResults.getIntValueFromFirstRow());
                //myResults.close();
		//myGLGResults = new Results(glgContents, conn);
		//myGLGResults.print();

		for (int i=0; i<num_iterations; i++) {	
			//
			// Then insert the identifiers that are 2 or more links from the original list
			//
			query = "insert into geneListGraph "+
				"(start_id_number, "+
				"start_identifier, "+
				"ident_type_id, "+
				"name, "+
				"id_number, "+
				"identifier, "+
				"chromosome, "+
				"map_location, "+
				"cM, "+
				"start_bp, "+
				"category, "+
				"organism, "+
				"array_name, "+
				"from_id_number, "+
				"from_identifier, "+
				"link_source_name) "+
				"select distinct "+ 
/// * + index (id identifiers_pk) * / "+
				"glg.start_id_number start_id_number, "+
 				"glg.start_identifier, "+
				"id.ident_type_id, "+
 				"type.name, "+
 				"id.id_number, "+
 				"id.identifier, "+
 				"id.chromosome, "+
 				"id.map_location, "+
 				"id.cM, "+
 				"id.start_bp, "+
 				"type.category, "+
 				"id.organism, "+
 				"'' array_name, "+
				"glg.id_number, "+
				"glg.identifier, "+
 				"link.link_source_name "+
				"from identifier_links3 link, "+
 				"identifiers id, "+
 				"identifier_types type, "+
 				"identifier_types type2, "+
				"geneListGraph glg "+
				"where glg.id_number = link.id_number1  "+
				"and glg.ident_type_id = type2.ident_type_id "+
				// don't follow links from probe set
				//"and type2.category != 'Probe Set' "+
				"and link.id_number2 = id.id_number  "+
				"and id.ident_type_id = type.ident_type_id  "+
				//"and exists "+
				//"	(select 'x' "+
				//"	from identifier_types it2    "+
				//"	where it2.name not in ('Affymetrix ID', 'CodeLink ID') "+
				//"	and type.ident_type_id = it2.ident_type_id) "+
				organismString +
				//"and id.organism = ? "+
				"and not exists "+
				"	(select 'x' "+
				"	from geneListGraph glg2 "+
				"	where glg2.id_number = id.id_number "+
				"	and glg2.start_id_number = glg.start_id_number) "+
				"union  "+
				"select distinct "+
// + index (id identifiers_pk)  "+
				"glg.start_id_number start_id_number, "+
 				"glg.start_identifier, "+
				"id.ident_type_id, "+
 				"type.name, "+
 				"id.id_number, "+
 				"id.identifier, "+
 				"id.chromosome, "+
 				"id.map_location, "+
 				"id.cM, "+
 				"id.start_bp, "+
 				"type.category, "+
 				"id.organism, "+
 				"ia.array_name, "+
				"glg.id_number, "+
				"glg.identifier, "+
 				"link.link_source_name "+
				"from identifier_links3 link, "+
 				"identifiers id, "+
 				"identifier_arrays ia, "+
 				"identifier_types type, "+
 				"identifier_types type2, "+
				"geneListGraph glg "+
				"where glg.id_number = link.id_number1  "+
				"and glg.ident_type_id = type2.ident_type_id "+
				// don't follow links from probe set
				//"and type2.category != 'Probe Set' "+
				"and link.id_number2 = id.id_number    "+
				"and ia.id_number = id.id_number  "+
				"and id.ident_type_id = type.ident_type_id  "+
				//"and exists "+
				//"	(select 'x'  "+
				//"	from identifier_types it2 "+
				//"	where it2.name in ('Affymetrix ID', 'CodeLink ID') "+
				//"	and type.ident_type_id = it2.ident_type_id) "+
				organismString + 
				//"and id.organism = ? "+
				"and not exists "+
				"	(select 'x' "+
				"	from geneListGraph glg2 "+
				"	where glg2.id_number = id.id_number "+
				"	and nvl(glg2.array_name, 'None') = nvl(ia.array_name, 'None') "+
				"	and glg2.start_id_number = glg.start_id_number)";

			log.debug("These are 2 or more links from the original list");
			//log.debug("query3 = "+query);

			pstmt = conn.prepareStatement(query);
			//pstmt.setString(1, organism);
			//pstmt.setString(2, organism);
			pstmt.executeQuery();

			//myResults = new Results(countQuery2, conn);
			//log.debug("count of geneListGraph in iteration [" + i + "] = " + myResults.getIntValueFromFirstRow());

			//myGLGResults = new Results(glgContents, conn);
			//myGLGResults.print();

			pstmt.close();
		}

		//myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 4 = " + myResults.getIntValueFromFirstRow());
		//myResults.close();

       		query =  
                	"select ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, " +
			"start_bp, " +
			"category, "+
			"organism, " +
			"'' "+
                	"from geneListGraph "+ 
			"where start_id_number = id_number "+
			"and array_name is null "+
			"order by id_number";

       		String query2 =  
                	"select glg.ident_type_id, "+
			"glg.name, "+
			"glg.id_number, "+
			"glg.identifier, "+
			"glg.chromosome, "+
			"glg.map_location, "+
			"glg.cM, " +
			"glg.start_bp, " +
			"glg.category, "+
			"glg.organism, " +
			"glg.array_name, "+
			"glg.from_id_number, "+
			"glg.from_identifier, "+
			"glg.link_source_name, "+
			"glg.start_id_number, "+
			"glg.start_identifier "+
                	"from geneListGraph glg "; 
			//
			// Only include the identifier if it's type is in the targetList
			// targetsList is set in setTargets prior to calling this method
			//
			if (targetsList != null && !targetsList.contains("Location")) { 
				query2 = query2 + "where glg.name in " + targetString + " ";
			}
			query2 = query2 + "order by glg.start_id_number, glg.ident_type_id, glg.identifier";
/*
			", id.identifier, "+
			"idtype.name "+
			", identifiers id, "+
			"identifier_types idtype "+
			"where glg.start_id_number = id.id_number "+
			"and id.ident_type_id = idtype.ident_type_id "+
*/

       		/*String query3 =  
                	"select start_id_number, "+
			"start_identifier, "+
			"fromID.ident_type_id, "+
			"from_types.name, "+
			"fromID.id_number, "+
			"fromID.identifier, "+
			"fromID.chromosome, "+
			"fromID.map_location, "+
			"fromID.cM, " +
			"fromID.start_bp, " +
			"from_types.category, " +
			"fromID.organism, " +
			"from_arrays.array_name, "+
                	"toID.ident_type_id, "+
			"to_types.name, "+
			"toID.id_number, "+
			"toID.identifier, "+
			"toID.chromosome, "+
			"toID.map_location, "+
			"toID.cM, " +
			"toID.start_bp, " +
			"to_types.category, " +
			"toID.organism, " +
			"to_arrays.array_name, "+
			"link_source_name "+
                	"from geneListGraph glg, "+ 
                	"identifiers fromID left join identifier_arrays from_arrays on fromID.id_number = from_arrays.id_number, "+
                	"identifiers toID left join identifier_arrays to_arrays on toID.id_number = to_arrays.id_number, "+
                	"identifier_types from_types, "+ 
                	"identifier_types to_types "+ 
			"where glg.from_id_number = fromID.id_number "+
			"and glg.id_number = toID.id_number "+
			"and fromID.ident_type_id = from_types.ident_type_id "+
			"and toID.ident_type_id = to_types.ident_type_id "+
			"order by start_id_number, fromID.ident_type_id, fromID.identifier, toID.ident_type_id, toID.identifier";
                */
		log.debug("in getRecords");
		//log.debug("getTab1 query = "+query);
		//log.debug("getTab2 query = "+query2);
		//log.debug("getTab3 query = "+query3);

		pstmt.close();
		pstmt = conn.prepareStatement(query);
		//PreparedStatement pstmt2 = null;
		ResultSet rs = pstmt.executeQuery();

        	while (rs.next()){
            		Identifier foundID = new Identifier(rs.getString(4)); 
                        //log.debug("query1: org:"+foundID.getIdentifier()+":"+foundID.getIdentifierTypeName()+":"+foundID.getOrganism());
            		//Identifier foundID = new Identifier(rs.getInt(1), rs.getString(2), 
			//	rs.getLong(3), rs.getString(4), rs.getString(5),
			//	rs.getString(6), rs.getString(7), rs.getString(8), rs.getString(9), rs.getString(10), "");
			resultsHashMap.put(foundID, new LinkedHashSet<Identifier>());
			//linkGraph.put(foundID, new LinkedHashSet<IdentifierLink>());
		}
		//log.debug("linkGraph contains "+linkGraph.size() + " entries");
                pstmt.close();
		pstmt = conn.prepareStatement(query2);
		rs = pstmt.executeQuery();
        	while (rs.next()){
            		//Identifier foundID = new Identifier(rs.getString(16), rs.getString(17), rs.getString(10), ""); 
            		Identifier foundID = new Identifier(rs.getString(16)); 
                        //log.debug("query2: org:"+foundID.getIdentifier()+":"+foundID.getIdentifierTypeName()+":"+foundID.getOrganism());
			LinkedHashSet<Identifier> resultIDSet = (LinkedHashSet<Identifier>) resultsHashMap.get(foundID);

            		Identifier relatedID = new Identifier(rs.getInt(1), rs.getString(2), 
				rs.getLong(3), rs.getString(4), rs.getString(5),
				rs.getString(6), rs.getString(7), rs.getString(8), rs.getString(9), rs.getString(10),
				rs.getString(11));
			resultIDSet.add(relatedID);
			resultsHashMap.put(foundID, resultIDSet);

			/*
			LinkedHashSet<IdentifierLink> identifierLinkSet = (LinkedHashSet) linkGraph.get(foundID);
			Identifier fromID = new Identifier(rs.getInt(12), rs.getString(13));
			Identifier toID = new Identifier(rs.getInt(3), rs.getString(4));
			String linkSource = (rs.getString(14) != null ? rs.getString(14) : "Unknown");
		
			IdentifierLink thisIdentifierLink = new IdentifierLink(fromID, toID, linkSource); 	
			identifierLinkSet.add(thisIdentifierLink);
			linkGraph.put(foundID, identifierLinkSet);
			*/
        	}
                
		log.debug("resultsHashMap contains "+resultsHashMap.size() + " entries");
		/*
		//
		// This is commented out because it takes too much memory.  Only place linkGraph is used is in DrawGraph
		//
		pstmt = conn.prepareStatement(query3);
		rs = pstmt.executeQuery();
        	while (rs.next()){
            		Identifier foundID = new Identifier(rs.getString(2)); 
			LinkedHashSet<IdentifierLink> identifierLinkSet = (LinkedHashSet<IdentifierLink>) linkGraph.get(foundID);
            		Identifier fromID = new Identifier(rs.getInt(3), rs.getString(4), 
				rs.getLong(5), rs.getString(6), rs.getString(7),
				rs.getString(8), rs.getString(9), rs.getString(10), rs.getString(11), rs.getString(12),
				rs.getString(13));
            		Identifier toID = new Identifier(rs.getInt(14), rs.getString(15), 
				rs.getLong(16), rs.getString(17), rs.getString(18),
				rs.getString(19), rs.getString(20), rs.getString(21), rs.getString(22), rs.getString(23),
				rs.getString(24));

			//Identifier fromID = new Identifier(rs.getInt(12), rs.getString(13));
			//Identifier toID = new Identifier(rs.getInt(3), rs.getString(4));
			String linkSource = (rs.getString(25) != null ? rs.getString(25) : "Unknown");
		
			IdentifierLink thisIdentifierLink = new IdentifierLink(fromID, toID, linkSource); 	
			identifierLinkSet.add(thisIdentifierLink);
			linkGraph.put(foundID, identifierLinkSet);
        	}
		
		log.debug("Now 2 linkGraph contains "+linkGraph.size() + " entries");
		*/
		pstmt.close();

		conn.commit();
		conn.setAutoCommit(true);
                
		//myGLGResults.close();
		//log.debug("linkGraph = "); myDebugger.print(linkGraph);
		return resultsHashMap;
	}
        
        
        
        /**
         * Returns the main HashMap that is used by other methods
         *
         * @param conn          database connection
         *
         * @return              HashMap of results that contains the original Identifier and points to a Set of Identifiers.
         *                      The set of Identifiers contains ALL the Identifiers that were discovered during breadth-first-search
         *                      of graph.
         *                      To obtain the subset of Identifiers for a list of particular targets, see
	 *			{@link #getIdentifiersByInputIDAndTarget(int geneListID, String[] targets, Connection conn) getIdentifiersByInputIDAndTarget}
         * <br><pre>
         *
         *      ------------------       -------------------------------------------------------------------
         *      | Identifier CDX4 | -------->  | Affy Identifier 15112_at | Entrez Gene Identifier 10329  |...    |
         *      ------------------|       -------------------------------------------------------------------
         *      | Identifier CDX3 | ...|     
         *      ------------------    
         * </pre>
         * @throws Exception    from any other method calls
         */
        private HashMap<Identifier, Set<Identifier>> doSearch(String organism, Connection conn) throws SQLException {
                
		HashMap<Identifier, Set<Identifier>> resultsHashMap = new HashMap<Identifier, Set<Identifier>>();
		log.debug("in doSearch");
		String targetString = "(" + new ObjectHandler().getAsSeparatedString(targetsList, ",", "'") + ")";
		//
		// Match on organism if the target is not 'Homologene ID'
		//
		String organismString = "and 1=1 ";

		if (!targetsList.contains("Homologene ID")) {
			organismString = "and id.organism = '"+organism + "' ";
		} 
		

		String countQuery2 = 
			"select count(*) from geneListGraph";
		String glgContents = 
			"select * from geneListGraph";
		

		conn.setAutoCommit(false);
                //conn.setAutoCommit(true);
		//log.debug("query1 = "+query);

		

		//Results myGLGResults = new Results(glgContents, conn);
		//myGLGResults.print();

		//
		// Then insert the identifiers that have a row in the identifier_arrays table
		// but don't have any links from them
		//
		String query  ="insert into geneListGraph "+ 
			"(start_id_number, "+
			"start_identifier, "+
			"ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, "+
			"start_bp, "+
			"category, "+
			"organism, "+
			"array_name, "+
			"from_id_number, "+
			"from_identifier, "+
			"link_source_name) "+
			"select distinct /*+ index (id identifiers_pk) */ glg.id_number start_id_number, "+
 			"glg.start_identifier, "+
			"id.ident_type_id, "+
 			"type.name, "+
 			"id.id_number, "+
 			"id.identifier, "+
 			"id.chromosome, "+
 			"id.map_location, "+
 			"id.cM, "+
 			"id.start_bp, "+
 			"type.category, "+
 			"id.organism, "+
 			"ia.array_name, "+
			"glg.id_number, "+
			"glg.identifier, "+
 			"decode(type.name, 'CodeLink ID', 'CodeLink', 'Affymetrix ID', 'Affymetrix', '') "+
			"from identifiers id, "+
 			"identifier_arrays ia, "+
 			"identifier_types type, "+
			"geneListGraph glg "+
			"where glg.id_number = id.id_number "+ 
			"and ia.id_number = id.id_number "+ 
			"and id.ident_type_id = type.ident_type_id "+ 
			"and exists "+
			"	(select 'x' "+ 
			"	from identifier_types it2 "+  
			"	where it2.name in ('Affymetrix ID', 'CodeLink ID') "+ 
			"	and type.ident_type_id = it2.ident_type_id) "+ 
			organismString + 
			//"and id.organism = ?";
			"and not exists "+
			"	(select 'x' "+
			"	from identifier_links3 il3 "+
			"	where il3.id_number1 = id.id_number)";

		log.debug("These are identifiers that have a row in the identifier_arrays table but don't have any links from them");
		//log.debug("query1.5 = "+query);
		PreparedStatement pstmt = conn.prepareStatement(query);
		pstmt.executeQuery();
		pstmt.close();

		//Results myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 2 = "+ myResults.getIntValueFromFirstRow());

		//myGLGResults = new Results(glgContents, conn);
		//myGLGResults.print();
		//
		// Then insert the identifiers that are one link from the original list
		//
		query  ="insert into geneListGraph "+ 
			"(start_id_number, "+
			"start_identifier, "+
			"ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, "+
			"start_bp, "+
			"category, "+
			"organism, "+
			"array_name, "+
			"from_id_number, "+
			"from_identifier, "+
			"link_source_name) "+
			"select distinct /*+ index (id identifiers_pk) */ glg.id_number start_id_number, "+
 			"glg.start_identifier, "+
			"id.ident_type_id, "+
	 		"type.name, "+
	 		"id.id_number, "+
 			"id.identifier, "+
 			"id.chromosome, "+
 			"id.map_location, "+
 			"id.cM, "+
 			"id.start_bp, "+
 			"type.category, "+
 			"id.organism, "+
 			"'' array_name, "+
			"glg.id_number, "+
			"glg.identifier, "+
 			"link.link_source_name "+
			"from identifier_links3 link, "+
 			"identifiers id, "+
 			"identifier_types type, "+
			"geneListGraph glg "+
			"where glg.id_number = link.id_number1  "+
			"and link.id_number2 = id.id_number  "+
			"and id.ident_type_id = type.ident_type_id  "+
			"and exists "+
			"	(select 'x' "+
			"	from identifier_types it2 "+
			"	where it2.name not in ('Affymetrix ID', 'CodeLink ID') "+
			"	and type.ident_type_id = it2.ident_type_id) "+ 
			organismString + 
			//"and id.organism = ? "+ 
			"union "+ 
			"select distinct /*+ index (id identifiers_pk) */ glg.id_number start_id_number, "+
 			"glg.start_identifier, "+
			"id.ident_type_id, "+
 			"type.name, "+
 			"id.id_number, "+
 			"id.identifier, "+
 			"id.chromosome, "+
 			"id.map_location, "+
 			"id.cM, "+
 			"id.start_bp, "+
 			"type.category, "+
 			"id.organism, "+
 			"ia.array_name, "+
			"glg.id_number, "+
			"glg.identifier, "+
 			"link.link_source_name "+
			"from identifier_links3 link, "+
 			"identifiers id, "+
 			"identifier_arrays ia, "+
 			"identifier_types type, "+
			"geneListGraph glg "+
			"where glg.id_number = link.id_number1 "+ 
			"and link.id_number2 = id.id_number "+   
			"and ia.id_number = id.id_number "+ 
			"and id.ident_type_id = type.ident_type_id "+ 
			"and exists "+
			"	(select 'x' "+ 
			"	from identifier_types it2 "+  
			"	where it2.name in ('Affymetrix ID', 'CodeLink ID') "+ 
			"	and type.ident_type_id = it2.ident_type_id) "+ 
			organismString; 
			//"and id.organism = ?";

		log.debug("These are identifiers that are one link from the original list");
		//log.debug("query2 = "+query);
		pstmt = conn.prepareStatement(query);
		//pstmt.setString(1, organism);
		//pstmt.setString(2, organism);
		pstmt.executeQuery();
		pstmt.close();

		//myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 3 = "+ myResults.getIntValueFromFirstRow());

		//myGLGResults = new Results(glgContents, conn);
		//myGLGResults.print();

		for (int i=0; i<num_iterations; i++) {	
			//
			// Then insert the identifiers that are 2 or more links from the original list
			//
			query = "insert into geneListGraph "+
				"(start_id_number, "+
				"start_identifier, "+
				"ident_type_id, "+
				"name, "+
				"id_number, "+
				"identifier, "+
				"chromosome, "+
				"map_location, "+
				"cM, "+
				"start_bp, "+
				"category, "+
				"organism, "+
				"array_name, "+
				"from_id_number, "+
				"from_identifier, "+
				"link_source_name) "+
				"select distinct "+ 
/// * + index (id identifiers_pk) * / "+
				"glg.start_id_number start_id_number, "+
 				"glg.start_identifier, "+
				"id.ident_type_id, "+
 				"type.name, "+
 				"id.id_number, "+
 				"id.identifier, "+
 				"id.chromosome, "+
 				"id.map_location, "+
 				"id.cM, "+
 				"id.start_bp, "+
 				"type.category, "+
 				"id.organism, "+
 				"'' array_name, "+
				"glg.id_number, "+
				"glg.identifier, "+
 				"link.link_source_name "+
				"from identifier_links3 link, "+
 				"identifiers id, "+
 				"identifier_types type, "+
 				"identifier_types type2, "+
				"geneListGraph glg "+
				"where glg.id_number = link.id_number1  "+
				"and glg.ident_type_id = type2.ident_type_id "+
				// don't follow links from probe set
				"and type2.category != 'Probe Set' "+
				"and link.id_number2 = id.id_number  "+
				"and id.ident_type_id = type.ident_type_id  "+
				"and exists "+
				"	(select 'x' "+
				"	from identifier_types it2    "+
				"	where it2.name not in ('Affymetrix ID', 'CodeLink ID') "+
				"	and type.ident_type_id = it2.ident_type_id) "+
				organismString +
				//"and id.organism = ? "+
				"and not exists "+
				"	(select 'x' "+
				"	from geneListGraph glg2 "+
				"	where glg2.id_number = id.id_number "+
				"	and glg2.start_id_number = glg.start_id_number) "+
				"union  "+
				"select distinct "+
/// * + index (id identifiers_pk) * / "+
				"glg.start_id_number start_id_number, "+
 				"glg.start_identifier, "+
				"id.ident_type_id, "+
 				"type.name, "+
 				"id.id_number, "+
 				"id.identifier, "+
 				"id.chromosome, "+
 				"id.map_location, "+
 				"id.cM, "+
 				"id.start_bp, "+
 				"type.category, "+
 				"id.organism, "+
 				"ia.array_name, "+
				"glg.id_number, "+
				"glg.identifier, "+
 				"link.link_source_name "+
				"from identifier_links3 link, "+
 				"identifiers id, "+
 				"identifier_arrays ia, "+
 				"identifier_types type, "+
 				"identifier_types type2, "+
				"geneListGraph glg "+
				"where glg.id_number = link.id_number1  "+
				"and glg.ident_type_id = type2.ident_type_id "+
				// don't follow links from probe set
				"and type2.category != 'Probe Set' "+
				"and link.id_number2 = id.id_number    "+
				"and ia.id_number = id.id_number  "+
				"and id.ident_type_id = type.ident_type_id  "+
				"and exists "+
				"	(select 'x'  "+
				"	from identifier_types it2 "+
				"	where it2.name in ('Affymetrix ID', 'CodeLink ID') "+
				"	and type.ident_type_id = it2.ident_type_id) "+
				organismString + 
				//"and id.organism = ? "+
				"and not exists "+
				"	(select 'x' "+
				"	from geneListGraph glg2 "+
				"	where glg2.id_number = id.id_number "+
				"	and nvl(glg2.array_name, 'None') = nvl(ia.array_name, 'None') "+
				"	and glg2.start_id_number = glg.start_id_number)";

			log.debug("These are 2 or more links from the original list");
			//log.debug("query3 = "+query);

			pstmt = conn.prepareStatement(query);
			//pstmt.setString(1, organism);
			//pstmt.setString(2, organism);
			pstmt.executeQuery();

			//myResults = new Results(countQuery2, conn);
			//log.debug("count of geneListGraph in iteration [" + i + "] = " + myResults.getIntValueFromFirstRow());

			//myGLGResults = new Results(glgContents, conn);
			//myGLGResults.print();

			pstmt.close();
		}

		//myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 4 = " + myResults.getIntValueFromFirstRow());

		//myResults.close();

       		query =  
                	"select ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, " +
			"start_bp, " +
			"category, "+
			"organism, " +
			"'' "+
                	"from geneListGraph "+ 
			"where start_id_number = id_number "+
			"and array_name is null "+
			"order by id_number";

       		String query2 =  
                	"select glg.ident_type_id, "+
			"glg.name, "+
			"glg.id_number, "+
			"glg.identifier, "+
			"glg.chromosome, "+
			"glg.map_location, "+
			"glg.cM, " +
			"glg.start_bp, " +
			"glg.category, "+
			"glg.organism, " +
			"glg.array_name, "+
			"glg.from_id_number, "+
			"glg.from_identifier, "+
			"glg.link_source_name, "+
			"glg.start_id_number, "+
			"glg.start_identifier "+
                	"from geneListGraph glg "; 
			//
			// Only include the identifier if it's type is in the targetList
			// targetsList is set in setTargets prior to calling this method
			//
			if (targetsList != null && !targetsList.contains("Location")) { 
				query2 = query2 + "where glg.name in " + targetString + " ";
			}
			query2 = query2 + "order by glg.start_id_number, glg.ident_type_id, glg.identifier";
/*
			", id.identifier, "+
			"idtype.name "+
			", identifiers id, "+
			"identifier_types idtype "+
			"where glg.start_id_number = id.id_number "+
			"and id.ident_type_id = idtype.ident_type_id "+
*/

       		/*String query3 =  
                	"select start_id_number, "+
			"start_identifier, "+
			"fromID.ident_type_id, "+
			"from_types.name, "+
			"fromID.id_number, "+
			"fromID.identifier, "+
			"fromID.chromosome, "+
			"fromID.map_location, "+
			"fromID.cM, " +
			"fromID.start_bp, " +
			"from_types.category, " +
			"fromID.organism, " +
			"from_arrays.array_name, "+
                	"toID.ident_type_id, "+
			"to_types.name, "+
			"toID.id_number, "+
			"toID.identifier, "+
			"toID.chromosome, "+
			"toID.map_location, "+
			"toID.cM, " +
			"toID.start_bp, " +
			"to_types.category, " +
			"toID.organism, " +
			"to_arrays.array_name, "+
			"link_source_name "+
                	"from geneListGraph glg, "+ 
                	"identifiers fromID left join identifier_arrays from_arrays on fromID.id_number = from_arrays.id_number, "+
                	"identifiers toID left join identifier_arrays to_arrays on toID.id_number = to_arrays.id_number, "+
                	"identifier_types from_types, "+ 
                	"identifier_types to_types "+ 
			"where glg.from_id_number = fromID.id_number "+
			"and glg.id_number = toID.id_number "+
			"and fromID.ident_type_id = from_types.ident_type_id "+
			"and toID.ident_type_id = to_types.ident_type_id "+
			"order by start_id_number, fromID.ident_type_id, fromID.identifier, toID.ident_type_id, toID.identifier";
                */
		log.debug("in getRecords");
		//log.debug("getTab1 query = "+query);
		//log.debug("getTab2 query = "+query2);
		//log.debug("getTab3 query = "+query3);

		pstmt.close();
		pstmt = conn.prepareStatement(query);
		//PreparedStatement pstmt2 = null;
		ResultSet rs = pstmt.executeQuery();

        	while (rs.next()){
            		Identifier foundID = new Identifier(rs.getString(4)); 
                        //log.debug("query1: org:"+foundID.getIdentifier()+":"+foundID.getIdentifierTypeName()+":"+foundID.getOrganism());
            		//Identifier foundID = new Identifier(rs.getInt(1), rs.getString(2), 
			//	rs.getLong(3), rs.getString(4), rs.getString(5),
			//	rs.getString(6), rs.getString(7), rs.getString(8), rs.getString(9), rs.getString(10), "");
			resultsHashMap.put(foundID, new LinkedHashSet<Identifier>());
			//linkGraph.put(foundID, new LinkedHashSet<IdentifierLink>());
		}
		//log.debug("linkGraph contains "+linkGraph.size() + " entries");
                //pstmt.close();
		pstmt = conn.prepareStatement(query2);
		rs = pstmt.executeQuery();
        	while (rs.next()){
            		//Identifier foundID = new Identifier(rs.getString(16), rs.getString(17), rs.getString(10), ""); 
            		Identifier foundID = new Identifier(rs.getString(16)); 
                        //log.debug("query2: org:"+foundID.getIdentifier()+":"+foundID.getIdentifierTypeName()+":"+foundID.getOrganism());
			LinkedHashSet<Identifier> resultIDSet = (LinkedHashSet<Identifier>) resultsHashMap.get(foundID);

            		Identifier relatedID = new Identifier(rs.getInt(1), rs.getString(2), 
				rs.getLong(3), rs.getString(4), rs.getString(5),
				rs.getString(6), rs.getString(7), rs.getString(8), rs.getString(9), rs.getString(10),
				rs.getString(11));
			resultIDSet.add(relatedID);
			resultsHashMap.put(foundID, resultIDSet);

			/*
			LinkedHashSet<IdentifierLink> identifierLinkSet = (LinkedHashSet) linkGraph.get(foundID);
			Identifier fromID = new Identifier(rs.getInt(12), rs.getString(13));
			Identifier toID = new Identifier(rs.getInt(3), rs.getString(4));
			String linkSource = (rs.getString(14) != null ? rs.getString(14) : "Unknown");
		
			IdentifierLink thisIdentifierLink = new IdentifierLink(fromID, toID, linkSource); 	
			identifierLinkSet.add(thisIdentifierLink);
			linkGraph.put(foundID, identifierLinkSet);
			*/
        	}
                
		log.debug("resultsHashMap contains "+resultsHashMap.size() + " entries");
		/*
		//
		// This is commented out because it takes too much memory.  Only place linkGraph is used is in DrawGraph
		//
		pstmt = conn.prepareStatement(query3);
		rs = pstmt.executeQuery();
        	while (rs.next()){
            		Identifier foundID = new Identifier(rs.getString(2)); 
			LinkedHashSet<IdentifierLink> identifierLinkSet = (LinkedHashSet<IdentifierLink>) linkGraph.get(foundID);
            		Identifier fromID = new Identifier(rs.getInt(3), rs.getString(4), 
				rs.getLong(5), rs.getString(6), rs.getString(7),
				rs.getString(8), rs.getString(9), rs.getString(10), rs.getString(11), rs.getString(12),
				rs.getString(13));
            		Identifier toID = new Identifier(rs.getInt(14), rs.getString(15), 
				rs.getLong(16), rs.getString(17), rs.getString(18),
				rs.getString(19), rs.getString(20), rs.getString(21), rs.getString(22), rs.getString(23),
				rs.getString(24));

			//Identifier fromID = new Identifier(rs.getInt(12), rs.getString(13));
			//Identifier toID = new Identifier(rs.getInt(3), rs.getString(4));
			String linkSource = (rs.getString(25) != null ? rs.getString(25) : "Unknown");
		
			IdentifierLink thisIdentifierLink = new IdentifierLink(fromID, toID, linkSource); 	
			identifierLinkSet.add(thisIdentifierLink);
			linkGraph.put(foundID, identifierLinkSet);
        	}
		
		log.debug("Now 2 linkGraph contains "+linkGraph.size() + " entries");
		*/
		pstmt.close();

		conn.commit();
		conn.setAutoCommit(true);
                
		//myGLGResults.close();
		//log.debug("linkGraph = "); myDebugger.print(linkGraph);
		return resultsHashMap;
	}

        /**
         * Returns the main HashMap that is used by other methods
         *
         * @param conn          database connection
         *
         * @return              HashMap of results that contains the original Identifier and points to a Set of Identifiers.
         *                      The set of Identifiers contains ALL the Identifiers that were discovered during breadth-first-search
         *                      of graph.
         *                      To obtain the subset of Identifiers for a list of particular targets, see
	 *			{@link #getIdentifiersByInputIDAndTarget(int geneListID, String[] targets, Connection conn) getIdentifiersByInputIDAndTarget}
         * <br><pre>
         *
         *      ------------------       -------------------------------------------------------------------
         *      | Identifier CDX4 | -------->  | Affy Identifier 15112_at | Entrez Gene Identifier 10329  |...    |
         *      ------------------|       -------------------------------------------------------------------
         *      | Identifier CDX3 | ...|     
         *      ------------------    
         * </pre>
         * @throws Exception    from any other method calls
         */
        private HashMap<Identifier, Set<Identifier>> doSearchCaseInsensitive(String organism, Connection conn) throws SQLException {
                
		HashMap<Identifier, Set<Identifier>> resultsHashMap = new HashMap<Identifier, Set<Identifier>>();
		log.debug("in doSearchCI");
		String targetString = "(" + new ObjectHandler().getAsSeparatedString(targetsList, ",", "'") + ")";
		//
		// Match on organism if the target is not 'Homologene ID'
		//
		String organismString = "and 1=1 ";

		if (!targetsList.contains("Homologene ID")) {
			organismString = "and id.organism = '"+organism + "' ";
		} 
		

		String countQuery2 = 
			"select count(*) from geneListGraph";
		String glgContents = 
			"select * from geneListGraph";
		

		conn.setAutoCommit(false);
                //conn.setAutoCommit(true);
		//log.debug("query1 = "+query);

		

		//Results myGLGResults = new Results(glgContents, conn);
		//myGLGResults.print();

		//
		// Then insert the identifiers that have a row in the identifier_arrays table
		// but don't have any links from them
		//
		String query  ="insert into geneListGraph "+ 
			"(start_id_number, "+
			"start_identifier, "+
			"ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, "+
			"start_bp, "+
			"category, "+
			"organism, "+
			"array_name, "+
			"from_id_number, "+
			"from_identifier, "+
			"link_source_name) "+
			"select distinct /*+ index (id identifiers_pk) */ glg.id_number start_id_number, "+
 			"glg.start_identifier, "+
			"id.ident_type_id, "+
 			"type.name, "+
 			"id.id_number, "+
 			"id.identifier, "+
 			"id.chromosome, "+
 			"id.map_location, "+
 			"id.cM, "+
 			"id.start_bp, "+
 			"type.category, "+
 			"id.organism, "+
 			"ia.array_name, "+
			"glg.id_number, "+
			"glg.identifier, "+
 			"decode(type.name, 'CodeLink ID', 'CodeLink', 'Affymetrix ID', 'Affymetrix', '') "+
			"from identifiers id, "+
 			"identifier_arrays ia, "+
 			"identifier_types type, "+
			"geneListGraph glg "+
			"where glg.id_number = id.id_number "+ 
			"and ia.id_number = id.id_number "+ 
			"and id.ident_type_id = type.ident_type_id "+ 
			"and exists "+
			"	(select 'x' "+ 
			"	from identifier_types it2 "+  
			"	where it2.name in ('Affymetrix ID', 'CodeLink ID') "+ 
			"	and type.ident_type_id = it2.ident_type_id) "+ 
			organismString + 
			//"and id.organism = ?";
			"and not exists "+
			"	(select 'x' "+
			"	from identifier_links3 il3 "+
			"	where il3.id_number1 = id.id_number)";

		log.debug("These are identifiers that have a row in the identifier_arrays table but don't have any links from them");
		//log.debug("query1.5 = "+query);
		PreparedStatement pstmt = conn.prepareStatement(query);
		pstmt.executeQuery();
		pstmt.close();

		//Results myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 2 = "+ myResults.getIntValueFromFirstRow());

		//myGLGResults = new Results(glgContents, conn);
		//myGLGResults.print();
		//
		// Then insert the identifiers that are one link from the original list
		//
		query  ="insert into geneListGraph "+ 
			"(start_id_number, "+
			"start_identifier, "+
			"ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, "+
			"start_bp, "+
			"category, "+
			"organism, "+
			"array_name, "+
			"from_id_number, "+
			"from_identifier, "+
			"link_source_name) "+
			"select distinct /*+ index (id identifiers_pk) */ glg.id_number start_id_number, "+
 			"glg.start_identifier, "+
			"id.ident_type_id, "+
	 		"type.name, "+
	 		"id.id_number, "+
 			"id.identifier, "+
 			"id.chromosome, "+
 			"id.map_location, "+
 			"id.cM, "+
 			"id.start_bp, "+
 			"type.category, "+
 			"id.organism, "+
 			"'' array_name, "+
			"glg.id_number, "+
			"glg.identifier, "+
 			"link.link_source_name "+
			"from identifier_links3 link, "+
 			"identifiers id, "+
 			"identifier_types type, "+
			"geneListGraph glg "+
			"where glg.id_number = link.id_number1  "+
			"and link.id_number2 = id.id_number  "+
			"and id.ident_type_id = type.ident_type_id  "+
			"and exists "+
			"	(select 'x' "+
			"	from identifier_types it2 "+
			"	where it2.name not in ('Affymetrix ID', 'CodeLink ID') "+
			"	and type.ident_type_id = it2.ident_type_id) "+ 
			organismString + 
			//"and id.organism = ? "+ 
			"union "+ 
			"select distinct /*+ index (id identifiers_pk) */ glg.id_number start_id_number, "+
 			"glg.start_identifier, "+
			"id.ident_type_id, "+
 			"type.name, "+
 			"id.id_number, "+
 			"id.identifier, "+
 			"id.chromosome, "+
 			"id.map_location, "+
 			"id.cM, "+
 			"id.start_bp, "+
 			"type.category, "+
 			"id.organism, "+
 			"ia.array_name, "+
			"glg.id_number, "+
			"glg.identifier, "+
 			"link.link_source_name "+
			"from identifier_links3 link, "+
 			"identifiers id, "+
 			"identifier_arrays ia, "+
 			"identifier_types type, "+
			"geneListGraph glg "+
			"where glg.id_number = link.id_number1 "+ 
			"and link.id_number2 = id.id_number "+   
			"and ia.id_number = id.id_number "+ 
			"and id.ident_type_id = type.ident_type_id "+ 
			"and exists "+
			"	(select 'x' "+ 
			"	from identifier_types it2 "+  
			"	where it2.name in ('Affymetrix ID', 'CodeLink ID') "+ 
			"	and type.ident_type_id = it2.ident_type_id) "+ 
			organismString; 
			//"and id.organism = ?";

		log.debug("These are identifiers that are one link from the original list");
		//log.debug("query2 = "+query);
		pstmt = conn.prepareStatement(query);
		//pstmt.setString(1, organism);
		//pstmt.setString(2, organism);
		pstmt.executeQuery();
		pstmt.close();

		//myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 3 = "+ myResults.getIntValueFromFirstRow());

		//myGLGResults = new Results(glgContents, conn);
		//myGLGResults.print();

		for (int i=0; i<num_iterations; i++) {	
			//
			// Then insert the identifiers that are 2 or more links from the original list
			//
			query = "insert into geneListGraph "+
				"(start_id_number, "+
				"start_identifier, "+
				"ident_type_id, "+
				"name, "+
				"id_number, "+
				"identifier, "+
				"chromosome, "+
				"map_location, "+
				"cM, "+
				"start_bp, "+
				"category, "+
				"organism, "+
				"array_name, "+
				"from_id_number, "+
				"from_identifier, "+
				"link_source_name) "+
				"select distinct "+ 
/// * + index (id identifiers_pk) * / "+
				"glg.start_id_number start_id_number, "+
 				"glg.start_identifier, "+
				"id.ident_type_id, "+
 				"type.name, "+
 				"id.id_number, "+
 				"id.identifier, "+
 				"id.chromosome, "+
 				"id.map_location, "+
 				"id.cM, "+
 				"id.start_bp, "+
 				"type.category, "+
 				"id.organism, "+
 				"'' array_name, "+
				"glg.id_number, "+
				"glg.identifier, "+
 				"link.link_source_name "+
				"from identifier_links3 link, "+
 				"identifiers id, "+
 				"identifier_types type, "+
 				"identifier_types type2, "+
				"geneListGraph glg "+
				"where glg.id_number = link.id_number1  "+
				"and glg.ident_type_id = type2.ident_type_id "+
				// don't follow links from probe set
				"and type2.category != 'Probe Set' "+
				"and link.id_number2 = id.id_number  "+
				"and id.ident_type_id = type.ident_type_id  "+
				"and exists "+
				"	(select 'x' "+
				"	from identifier_types it2    "+
				"	where it2.name not in ('Affymetrix ID', 'CodeLink ID') "+
				"	and type.ident_type_id = it2.ident_type_id) "+
				organismString +
				//"and id.organism = ? "+
				"and not exists "+
				"	(select 'x' "+
				"	from geneListGraph glg2 "+
				"	where glg2.id_number = id.id_number "+
				"	and glg2.start_id_number = glg.start_id_number) "+
				"union  "+
				"select distinct "+
/// * + index (id identifiers_pk) * / "+
				"glg.start_id_number start_id_number, "+
 				"glg.start_identifier, "+
				"id.ident_type_id, "+
 				"type.name, "+
 				"id.id_number, "+
 				"id.identifier, "+
 				"id.chromosome, "+
 				"id.map_location, "+
 				"id.cM, "+
 				"id.start_bp, "+
 				"type.category, "+
 				"id.organism, "+
 				"ia.array_name, "+
				"glg.id_number, "+
				"glg.identifier, "+
 				"link.link_source_name "+
				"from identifier_links3 link, "+
 				"identifiers id, "+
 				"identifier_arrays ia, "+
 				"identifier_types type, "+
 				"identifier_types type2, "+
				"geneListGraph glg "+
				"where glg.id_number = link.id_number1  "+
				"and glg.ident_type_id = type2.ident_type_id "+
				// don't follow links from probe set
				"and type2.category != 'Probe Set' "+
				"and link.id_number2 = id.id_number    "+
				"and ia.id_number = id.id_number  "+
				"and id.ident_type_id = type.ident_type_id  "+
				"and exists "+
				"	(select 'x'  "+
				"	from identifier_types it2 "+
				"	where it2.name in ('Affymetrix ID', 'CodeLink ID') "+
				"	and type.ident_type_id = it2.ident_type_id) "+
				organismString + 
				//"and id.organism = ? "+
				"and not exists "+
				"	(select 'x' "+
				"	from geneListGraph glg2 "+
				"	where glg2.id_number = id.id_number "+
				"	and nvl(glg2.array_name, 'None') = nvl(ia.array_name, 'None') "+
				"	and glg2.start_id_number = glg.start_id_number)";

			log.debug("These are 2 or more links from the original list");
			//log.debug("query3 = "+query);

			pstmt = conn.prepareStatement(query);
			//pstmt.setString(1, organism);
			//pstmt.setString(2, organism);
			pstmt.executeQuery();

			//myResults = new Results(countQuery2, conn);
			//log.debug("count of geneListGraph in iteration [" + i + "] = " + myResults.getIntValueFromFirstRow());

			//myGLGResults = new Results(glgContents, conn);
			//myGLGResults.print();

			pstmt.close();
		}

		//myResults = new Results(countQuery2, conn);
		//log.debug("count of geneListGraph at point 4 = " + myResults.getIntValueFromFirstRow());

		//myResults.close();

       		query =  
                	"select ident_type_id, "+
			"name, "+
			"id_number, "+
			"identifier, "+
			"chromosome, "+
			"map_location, "+
			"cM, " +
			"start_bp, " +
			"category, "+
			"organism, " +
			"'' "+
                	"from geneListGraph "+ 
			"where start_id_number = id_number "+
			"and array_name is null "+
			"order by id_number";

       		String query2 =  
                	"select glg.ident_type_id, "+
			"glg.name, "+
			"glg.id_number, "+
			"glg.identifier, "+
			"glg.chromosome, "+
			"glg.map_location, "+
			"glg.cM, " +
			"glg.start_bp, " +
			"glg.category, "+
			"glg.organism, " +
			"glg.array_name, "+
			"glg.from_id_number, "+
			"glg.from_identifier, "+
			"glg.link_source_name, "+
			"glg.start_id_number, "+
			"glg.start_identifier "+
                	"from geneListGraph glg "; 
			//
			// Only include the identifier if it's type is in the targetList
			// targetsList is set in setTargets prior to calling this method
			//
			if (targetsList != null && !targetsList.contains("Location")) { 
				query2 = query2 + "where glg.name in " + targetString + " ";
			}
			query2 = query2 + "order by glg.start_id_number, glg.ident_type_id, glg.identifier";
/*
			", id.identifier, "+
			"idtype.name "+
			", identifiers id, "+
			"identifier_types idtype "+
			"where glg.start_id_number = id.id_number "+
			"and id.ident_type_id = idtype.ident_type_id "+
*/

       		/*String query3 =  
                	"select start_id_number, "+
			"start_identifier, "+
			"fromID.ident_type_id, "+
			"from_types.name, "+
			"fromID.id_number, "+
			"fromID.identifier, "+
			"fromID.chromosome, "+
			"fromID.map_location, "+
			"fromID.cM, " +
			"fromID.start_bp, " +
			"from_types.category, " +
			"fromID.organism, " +
			"from_arrays.array_name, "+
                	"toID.ident_type_id, "+
			"to_types.name, "+
			"toID.id_number, "+
			"toID.identifier, "+
			"toID.chromosome, "+
			"toID.map_location, "+
			"toID.cM, " +
			"toID.start_bp, " +
			"to_types.category, " +
			"toID.organism, " +
			"to_arrays.array_name, "+
			"link_source_name "+
                	"from geneListGraph glg, "+ 
                	"identifiers fromID left join identifier_arrays from_arrays on fromID.id_number = from_arrays.id_number, "+
                	"identifiers toID left join identifier_arrays to_arrays on toID.id_number = to_arrays.id_number, "+
                	"identifier_types from_types, "+ 
                	"identifier_types to_types "+ 
			"where glg.from_id_number = fromID.id_number "+
			"and glg.id_number = toID.id_number "+
			"and fromID.ident_type_id = from_types.ident_type_id "+
			"and toID.ident_type_id = to_types.ident_type_id "+
			"order by start_id_number, fromID.ident_type_id, fromID.identifier, toID.ident_type_id, toID.identifier";
                */
		log.debug("in getRecords");
		//log.debug("getTab1 query = "+query);
		//log.debug("getTab2 query = "+query2);
		//log.debug("getTab3 query = "+query3);

		pstmt.close();
		pstmt = conn.prepareStatement(query);
		//PreparedStatement pstmt2 = null;
		ResultSet rs = pstmt.executeQuery();

        	while (rs.next()){
            		Identifier foundID = new Identifier(rs.getString(4)); 
                        //log.debug("query1: org:"+foundID.getIdentifier()+":"+foundID.getIdentifierTypeName()+":"+foundID.getOrganism());
            		//Identifier foundID = new Identifier(rs.getInt(1), rs.getString(2), 
			//	rs.getLong(3), rs.getString(4), rs.getString(5),
			//	rs.getString(6), rs.getString(7), rs.getString(8), rs.getString(9), rs.getString(10), "");
			resultsHashMap.put(foundID, new LinkedHashSet<Identifier>());
			//linkGraph.put(foundID, new LinkedHashSet<IdentifierLink>());
		}
		//log.debug("linkGraph contains "+linkGraph.size() + " entries");
                //pstmt.close();
		pstmt = conn.prepareStatement(query2);
		rs = pstmt.executeQuery();
        	while (rs.next()){
            		//Identifier foundID = new Identifier(rs.getString(16), rs.getString(17), rs.getString(10), ""); 
            		Identifier foundID = new Identifier(rs.getString(16)); 
                        //log.debug("query2: org:"+foundID.getIdentifier()+":"+foundID.getIdentifierTypeName()+":"+foundID.getOrganism());
			LinkedHashSet<Identifier> resultIDSet = (LinkedHashSet<Identifier>) resultsHashMap.get(foundID);

            		Identifier relatedID = new Identifier(rs.getInt(1), rs.getString(2), 
				rs.getLong(3), rs.getString(4), rs.getString(5),
				rs.getString(6), rs.getString(7), rs.getString(8), rs.getString(9), rs.getString(10),
				rs.getString(11));
			resultIDSet.add(relatedID);
			resultsHashMap.put(foundID, resultIDSet);

			/*
			LinkedHashSet<IdentifierLink> identifierLinkSet = (LinkedHashSet) linkGraph.get(foundID);
			Identifier fromID = new Identifier(rs.getInt(12), rs.getString(13));
			Identifier toID = new Identifier(rs.getInt(3), rs.getString(4));
			String linkSource = (rs.getString(14) != null ? rs.getString(14) : "Unknown");
		
			IdentifierLink thisIdentifierLink = new IdentifierLink(fromID, toID, linkSource); 	
			identifierLinkSet.add(thisIdentifierLink);
			linkGraph.put(foundID, identifierLinkSet);
			*/
        	}
                
		log.debug("resultsHashMap contains "+resultsHashMap.size() + " entries");
		/*
		//
		// This is commented out because it takes too much memory.  Only place linkGraph is used is in DrawGraph
		//
		pstmt = conn.prepareStatement(query3);
		rs = pstmt.executeQuery();
        	while (rs.next()){
            		Identifier foundID = new Identifier(rs.getString(2)); 
			LinkedHashSet<IdentifierLink> identifierLinkSet = (LinkedHashSet<IdentifierLink>) linkGraph.get(foundID);
            		Identifier fromID = new Identifier(rs.getInt(3), rs.getString(4), 
				rs.getLong(5), rs.getString(6), rs.getString(7),
				rs.getString(8), rs.getString(9), rs.getString(10), rs.getString(11), rs.getString(12),
				rs.getString(13));
            		Identifier toID = new Identifier(rs.getInt(14), rs.getString(15), 
				rs.getLong(16), rs.getString(17), rs.getString(18),
				rs.getString(19), rs.getString(20), rs.getString(21), rs.getString(22), rs.getString(23),
				rs.getString(24));

			//Identifier fromID = new Identifier(rs.getInt(12), rs.getString(13));
			//Identifier toID = new Identifier(rs.getInt(3), rs.getString(4));
			String linkSource = (rs.getString(25) != null ? rs.getString(25) : "Unknown");
		
			IdentifierLink thisIdentifierLink = new IdentifierLink(fromID, toID, linkSource); 	
			identifierLinkSet.add(thisIdentifierLink);
			linkGraph.put(foundID, identifierLinkSet);
        	}
		
		log.debug("Now 2 linkGraph contains "+linkGraph.size() + " entries");
		*/
		pstmt.close();

		conn.commit();
		conn.setAutoCommit(true);
                
		//myGLGResults.close();
		//log.debug("linkGraph = "); myDebugger.print(linkGraph);
		return resultsHashMap;
	}
        
	/** 
	 * Get a Set of Identifiers for a particular list of targets, although it is not organized by target.
	 * Useful if you want a list of all possible target values by gene ID, as is needed
	 * when calling the Literature module.
	 * <p>
	 * This starts by calling doSearch() 
	 * which returns a HashMap of ALL Identifiers found in the search.  This method then
	 * restricts the Identifiers to those in a list of targets.
	 * </p>
	 *
	 * @param geneListID	the identifier of the gene list
	 * @param targets	names of databases to which the values should be translated
	 * @param conn		database connection
	 * @return		a Set of Identifier objects, each containing a Set of Identifiers for a particular list of targets
	 *<br><pre>
	 *      ------------------     ------------------------------------------------------------------------------------------------|
	 *      | Identifier CDX4 |--> | Gene Symbol Identifier CDX4 |SwissProt Identifier P18111 | SwissProt Identifier Q8VCF7 |...   |
	 *      ------------------|    ------------------------------------------------------------------------------------------------|
	 *      | Identifier CDX3 | ...|      
	 *      ------------------      
	 * </pre>
	 * @throws	SQLException if there is a problem accessing the database
	 *                      
	 */
	public Set<Identifier> getIdentifiersByInputID(int geneListID, String[] targets, Connection conn) throws SQLException {

		log.debug("in getIdentifiersByInputID passing in geneListID");

		setTargets(targets);
		//log.debug("targetsList = "+targetsList);

		HashMap<Identifier, Set<Identifier>> startHashMap = doSearch(geneListID, conn);
		//log.debug("startHashMap = "); myDebugger.print(startHashMap);
		Set<Identifier> setOfInputIdentifiers = new HashSet<Identifier>();
		for (Iterator inputIDitr = startHashMap.keySet().iterator(); inputIDitr.hasNext();) {
			Identifier inputID = (Identifier) inputIDitr.next();
			Set<Identifier> allRelatedIdentifiers = (Set<Identifier>) startHashMap.get(inputID);
			//log.debug("allRelatedIdentifiers = "); myDebugger.print(allRelatedIdentifiers);

			//Identifier thisInputIdentifier = new Identifier(inputID);
			Set<Identifier> setOfRelatedIdentifiers = new LinkedHashSet<Identifier>();
			Set<Identifier> setOfLocationIdentifiers = new LinkedHashSet<Identifier>();

			for (Iterator identifierItr = allRelatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier nextIdentifier = (Identifier) identifierItr.next();
				String identifierType = nextIdentifier.getIdentifierTypeName();

				if (targetsList.contains(identifierType)) { 
					setOfRelatedIdentifiers.add(nextIdentifier);
				} 
				if (targetsList.contains("Location") && 
						((nextIdentifier.getChromosome() != null &&
						!nextIdentifier.getChromosome().equals("")) ||
					(nextIdentifier.getMapLocation() != null && 
					!nextIdentifier.getMapLocation().equals("")))) {
					setOfLocationIdentifiers.add(nextIdentifier);
				} 
			}
			inputID.setRelatedIdentifiers(setOfRelatedIdentifiers);
			inputID.setLocationIdentifiers(setOfLocationIdentifiers);
			setOfInputIdentifiers.add(inputID);
		}
		return setOfInputIdentifiers;
	}
        /** 
	 * Get a Set of Identifiers for a particular list of targets, although it is not organized by target.
	 * Useful if you want a list of all possible target values by gene ID, as is needed
	 * when calling the Literature module.
	 * <p>
	 * This starts by calling doSearch() 
	 * which returns a HashMap of ALL Identifiers found in the search.  This method then
	 * restricts the Identifiers to those in a list of targets.
	 * </p>
	 *
	 * @param geneListID	the identifier of the gene list
	 * @param targets	names of databases to which the values should be translated
	 * @param conn		database connection
	 * @return		a Set of Identifier objects, each containing a Set of Identifiers for a particular list of targets
	 *<br><pre>
	 *      ------------------     ------------------------------------------------------------------------------------------------|
	 *      | Identifier CDX4 |--> | Gene Symbol Identifier CDX4 |SwissProt Identifier P18111 | SwissProt Identifier Q8VCF7 |...   |
	 *      ------------------|    ------------------------------------------------------------------------------------------------|
	 *      | Identifier CDX3 | ...|      
	 *      ------------------      
	 * </pre>
	 * @throws	SQLException if there is a problem accessing the database
	 *                      
	 */
	public Set<Identifier> getIdentifiersByInputID(int geneListID, String[] targets, DataSource pool) throws SQLException {

		log.debug("in getIdentifiersByInputID passing in geneListID");

		setTargets(targets);
		//log.debug("targetsList = "+targetsList);

		HashMap<Identifier, Set<Identifier>> startHashMap = doSearchCaseInsensitive(geneListID, pool);
		//log.debug("startHashMap = "); myDebugger.print(startHashMap);
		Set<Identifier> setOfInputIdentifiers = new HashSet<Identifier>();
		for (Iterator inputIDitr = startHashMap.keySet().iterator(); inputIDitr.hasNext();) {
			Identifier inputID = (Identifier) inputIDitr.next();
			Set<Identifier> allRelatedIdentifiers = (Set<Identifier>) startHashMap.get(inputID);
			//log.debug("allRelatedIdentifiers = "); myDebugger.print(allRelatedIdentifiers);

			//Identifier thisInputIdentifier = new Identifier(inputID);
			Set<Identifier> setOfRelatedIdentifiers = new LinkedHashSet<Identifier>();
			Set<Identifier> setOfLocationIdentifiers = new LinkedHashSet<Identifier>();

			for (Iterator identifierItr = allRelatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier nextIdentifier = (Identifier) identifierItr.next();
				String identifierType = nextIdentifier.getIdentifierTypeName();

				if (targetsList.contains(identifierType)) { 
					setOfRelatedIdentifiers.add(nextIdentifier);
				} 
				if (targetsList.contains("Location") && 
						((nextIdentifier.getChromosome() != null &&
						!nextIdentifier.getChromosome().equals("")) ||
					(nextIdentifier.getMapLocation() != null && 
					!nextIdentifier.getMapLocation().equals("")))) {
					setOfLocationIdentifiers.add(nextIdentifier);
				} 
			}
			inputID.setRelatedIdentifiers(setOfRelatedIdentifiers);
			inputID.setLocationIdentifiers(setOfLocationIdentifiers);
			setOfInputIdentifiers.add(inputID);
		}
		return setOfInputIdentifiers;
	}
        
        
        public Set<Identifier> getIdentifiersByInputID(String geneID,String organism, String[] targets, DataSource pool) throws SQLException {
            log.debug("in getIdentifiersByInputID passing in gene ID");

		setTargets(targets);
		log.debug("targetsList = "+targetsList);
                Connection conn=pool.getConnection();
		HashMap<Identifier, Set<Identifier>> startHashMap = doSearch(geneID,organism, pool);
		log.debug("startHashMap = "); myDebugger.print(startHashMap);
		Set<Identifier> setOfInputIdentifiers = new HashSet<Identifier>();
		for (Iterator inputIDitr = startHashMap.keySet().iterator(); inputIDitr.hasNext();) {
			Identifier inputID = (Identifier) inputIDitr.next();
			Set<Identifier> allRelatedIdentifiers = (Set<Identifier>) startHashMap.get(inputID);
			log.debug("allRelatedIdentifiers = "); myDebugger.print(allRelatedIdentifiers);

			//Identifier thisInputIdentifier = new Identifier(inputID);
			Set<Identifier> setOfRelatedIdentifiers = new LinkedHashSet<Identifier>();
			Set<Identifier> setOfLocationIdentifiers = new LinkedHashSet<Identifier>();

			for (Iterator identifierItr = allRelatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier nextIdentifier = (Identifier) identifierItr.next();
				String identifierType = nextIdentifier.getIdentifierTypeName();

				if (targetsList.contains(identifierType)) { 
					setOfRelatedIdentifiers.add(nextIdentifier);
				} 
				if (targetsList.contains("Location") && 
						((nextIdentifier.getChromosome() != null &&
						!nextIdentifier.getChromosome().equals("")) ||
					(nextIdentifier.getMapLocation() != null && 
					!nextIdentifier.getMapLocation().equals("")))) {
					setOfLocationIdentifiers.add(nextIdentifier);
				} 
			}
			inputID.setRelatedIdentifiers(setOfRelatedIdentifiers);
			inputID.setLocationIdentifiers(setOfLocationIdentifiers);
			setOfInputIdentifiers.add(inputID);
		}
                try{
                    conn.close();
                }catch(Exception e){}
		return setOfInputIdentifiers;
        }
        /** 
	 * Get a Set of Identifiers for a particular list of targets, although it is not organized by target.
	 * Useful if you want a list of all possible target values by gene ID, as is needed
	 * when calling the Literature module.
	 * <p>
	 * This starts by calling doSearch() 
	 * which returns a HashMap of ALL Identifiers found in the search.  This method then
	 * restricts the Identifiers to those in a list of targets.
	 * </p>
	 *
	 * @param geneListID	the identifier of the gene list
	 * @param targets	names of databases to which the values should be translated
	 * @param conn		database connection
	 * @return		a Set of Identifier objects, each containing a Set of Identifiers for a particular list of targets
	 *<br><pre>
	 *      ------------------     ------------------------------------------------------------------------------------------------|
	 *      | Identifier CDX4 |--> | Gene Symbol Identifier CDX4 |SwissProt Identifier P18111 | SwissProt Identifier Q8VCF7 |...   |
	 *      ------------------|    ------------------------------------------------------------------------------------------------|
	 *      | Identifier CDX3 | ...|      
	 *      ------------------      
	 * </pre>
	 * @throws	SQLException if there is a problem accessing the database
	 *                      
	 */

	public Set<Identifier> getIdentifiersByInputID(String geneID,String organism, String[] targets, Connection conn) throws SQLException {

		log.debug("in getIdentifiersByInputID passing in gene ID");

		setTargets(targets);
		log.debug("targetsList = "+targetsList);

		HashMap<Identifier, Set<Identifier>> startHashMap = doSearch(geneID,organism, conn);
		log.debug("startHashMap = "); myDebugger.print(startHashMap);
		Set<Identifier> setOfInputIdentifiers = new HashSet<Identifier>();
		for (Iterator inputIDitr = startHashMap.keySet().iterator(); inputIDitr.hasNext();) {
			Identifier inputID = (Identifier) inputIDitr.next();
			Set<Identifier> allRelatedIdentifiers = (Set<Identifier>) startHashMap.get(inputID);
			log.debug("allRelatedIdentifiers = "); myDebugger.print(allRelatedIdentifiers);

			//Identifier thisInputIdentifier = new Identifier(inputID);
			Set<Identifier> setOfRelatedIdentifiers = new LinkedHashSet<Identifier>();
			Set<Identifier> setOfLocationIdentifiers = new LinkedHashSet<Identifier>();

			for (Iterator identifierItr = allRelatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier nextIdentifier = (Identifier) identifierItr.next();
				String identifierType = nextIdentifier.getIdentifierTypeName();

				if (targetsList.contains(identifierType)) { 
					setOfRelatedIdentifiers.add(nextIdentifier);
				} 
				if (targetsList.contains("Location") && 
						((nextIdentifier.getChromosome() != null &&
						!nextIdentifier.getChromosome().equals("")) ||
					(nextIdentifier.getMapLocation() != null && 
					!nextIdentifier.getMapLocation().equals("")))) {
					setOfLocationIdentifiers.add(nextIdentifier);
				} 
			}
			inputID.setRelatedIdentifiers(setOfRelatedIdentifiers);
			inputID.setLocationIdentifiers(setOfLocationIdentifiers);
			setOfInputIdentifiers.add(inputID);
		}
		return setOfInputIdentifiers;
	}

        
        /** 
	 * Get a Set of Identifiers for a particular list of targets, although it is not organized by target.  Also restrict the
	 * list by geneChipName.
	 * <p>
	 * This starts by calling {@link #getIdentifiersByInputID(int geneListID, String[] targets, Connection conn) getIdentifiersByInputID} which returns 
	 * a Set of Identifiers for the given list of targets.
	 * This then further restricts the Identifiers by geneChipName. 
	 * </p>
	 *
	 * @param geneListID	identifier of the gene list
	 * @param targets	names of databases to which the values should be translated
	 * @param geneChipName	name of the array from which this Identifier comes
	 * @param conn		database connection
	 * @return		a Set of Identifiers which maps to a Set of related Identifiers for a particular list of targets and gene_chip
	 *<br><pre>
	 *      ------------------       ------------------------------------------------------------------------------------------------|
	 *      |Identifier CDX4 |---->  | Affy MOE430v2 Identifier 154_at |Affy MOE430v2 Identifier 15592_at | ...                      |
	 *      -----------------|       ------------------------------------------------------------------------------------------------|
	 *      |Identifier CDX3 | ...|      
	 *      ------------------      
	 * </pre>
	 * @throws	SQLException if there is a problem accessing the database
	 *                      
	 */
	public Set<Identifier> getIdentifiersByInputID(int geneListID, String[] targets, String geneChipName, Connection conn) throws SQLException {

		log.debug("in getIdentifiersByInputID passing in geneChipName also");
		//log.debug("geneChipName = "+geneChipName);

		Set<Identifier> startSet = getIdentifiersByInputID(geneListID, targets, conn);
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier inputID = (Identifier) inputIDitr.next();
			Set<Identifier> allRelatedIdentifiers = inputID.getRelatedIdentifiers();
			//log.debug("here are all the RelatedIDs for "+inputID.getIdentifier()+": "); myDebugger.print(allRelatedIdentifiers);
			//log.debug("before parsing out identifiers by genechip, there are "+inputID.getRelatedIdentifiers().size()+" related identifiers for "+inputID.getIdentifier()); 

			Set<Identifier> setOfRelatedIdentifiers = new LinkedHashSet<Identifier>();

			for (Iterator identifierItr = allRelatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier relatedIdentifier = (Identifier) identifierItr.next();
				//
				// If there is an Affy or CodeLink related identifier, only return it if 
				// it's from the desired chip.  If the related identifier is not Affy 
				// or CodeLink, return it anyway. 
				//
				if (relatedIdentifier.getIdentifierTypeName().equals("Affymetrix ID") ||
					relatedIdentifier.getIdentifierTypeName().equals("CodeLink ID")) {
					//log.debug("here related identifier type IS affy or cl, so gene chip= "+relatedIdentifier.getGene_chip_name());
					// For Exon arrays, the relatedIdentifier.getGene_chip_name() will end in either .probeset or .transcript,
					// and the geneChipName will not
					//log.debug("inputID = "+inputID.getIdentifier());
					//log.debug("relatedId = "+relatedIdentifier.getIdentifier());
					
					if (relatedIdentifier.getGene_chip_name() == null) {
						//log.debug("geneChipName is null ");
					} else {
						//log.debug("geneChipName is not null. it is " + relatedIdentifier.getGene_chip_name());
						if (relatedIdentifier.getGene_chip_name().startsWith(geneChipName)) {
							setOfRelatedIdentifiers.add(relatedIdentifier);
						}
					}
				} else {
					//log.debug("here related identifier type is NOT affy or cl, so type = "+relatedIdentifier.getIdentifierTypeName());
					setOfRelatedIdentifiers.add(relatedIdentifier);
				}
			}
			inputID.setRelatedIdentifiers(setOfRelatedIdentifiers);
			//log.debug("after parsing out identifiers by genechip, there are "+(inputID.getRelatedIdentifiers() != null ? inputID.getRelatedIdentifiers().size() : "0")+" related identifiers for "+inputID.getIdentifier()); 
		}
		return startSet;
	}
        
	/** 
	 * Get a Set of Identifiers for a particular list of targets, although it is not organized by target.  Also restrict the
	 * list by geneChipName.
	 * <p>
	 * This starts by calling {@link #getIdentifiersByInputID(int geneListID, String[] targets, Connection conn) getIdentifiersByInputID} which returns 
	 * a Set of Identifiers for the given list of targets.
	 * This then further restricts the Identifiers by geneChipName. 
	 * </p>
	 *
	 * @param geneListID	identifier of the gene list
	 * @param targets	names of databases to which the values should be translated
	 * @param geneChipName	name of the array from which this Identifier comes
	 * @param conn		database connection
	 * @return		a Set of Identifiers which maps to a Set of related Identifiers for a particular list of targets and gene_chip
	 *<br><pre>
	 *      ------------------       ------------------------------------------------------------------------------------------------|
	 *      |Identifier CDX4 |---->  | Affy MOE430v2 Identifier 154_at |Affy MOE430v2 Identifier 15592_at | ...                      |
	 *      -----------------|       ------------------------------------------------------------------------------------------------|
	 *      |Identifier CDX3 | ...|      
	 *      ------------------      
	 * </pre>
	 * @throws	SQLException if there is a problem accessing the database
	 *                      
	 */
	public Set<Identifier> getIdentifiersByInputID(int geneListID, String[] targets, String geneChipName, DataSource pool) throws SQLException {

		log.debug("in getIdentifiersByInputID passing in geneChipName also");
		//log.debug("geneChipName = "+geneChipName);

		Set<Identifier> startSet = getIdentifiersByInputID(geneListID, targets, pool);
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier inputID = (Identifier) inputIDitr.next();
			Set<Identifier> allRelatedIdentifiers = inputID.getRelatedIdentifiers();
			//log.debug("here are all the RelatedIDs for "+inputID.getIdentifier()+": "); myDebugger.print(allRelatedIdentifiers);
			//log.debug("before parsing out identifiers by genechip, there are "+inputID.getRelatedIdentifiers().size()+" related identifiers for "+inputID.getIdentifier()); 

			Set<Identifier> setOfRelatedIdentifiers = new LinkedHashSet<Identifier>();

			for (Iterator identifierItr = allRelatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier relatedIdentifier = (Identifier) identifierItr.next();
				//
				// If there is an Affy or CodeLink related identifier, only return it if 
				// it's from the desired chip.  If the related identifier is not Affy 
				// or CodeLink, return it anyway. 
				//
				if (relatedIdentifier.getIdentifierTypeName().equals("Affymetrix ID") ||
					relatedIdentifier.getIdentifierTypeName().equals("CodeLink ID")) {
					//log.debug("here related identifier type IS affy or cl, so gene chip= "+relatedIdentifier.getGene_chip_name());
					// For Exon arrays, the relatedIdentifier.getGene_chip_name() will end in either .probeset or .transcript,
					// and the geneChipName will not
					//log.debug("inputID = "+inputID.getIdentifier());
					//log.debug("relatedId = "+relatedIdentifier.getIdentifier());
					
					if (relatedIdentifier.getGene_chip_name() == null) {
						//log.debug("geneChipName is null ");
					} else {
						//log.debug("geneChipName is not null. it is " + relatedIdentifier.getGene_chip_name());
						if (relatedIdentifier.getGene_chip_name().startsWith(geneChipName)) {
							setOfRelatedIdentifiers.add(relatedIdentifier);
						}
					}
				} else {
					//log.debug("here related identifier type is NOT affy or cl, so type = "+relatedIdentifier.getIdentifierTypeName());
					setOfRelatedIdentifiers.add(relatedIdentifier);
				}
			}
			inputID.setRelatedIdentifiers(setOfRelatedIdentifiers);
			//log.debug("after parsing out identifiers by genechip, there are "+(inputID.getRelatedIdentifiers() != null ? inputID.getRelatedIdentifiers().size() : "0")+" related identifiers for "+inputID.getIdentifier()); 
		}
		return startSet;
	}

	/** 
	 * Get Set of geneChipNames that exist in a set of Identifiers for a given platform.
	 * @param identifiers	set of Identifiers 
	 * @param platform	Affymetrix ID or CodeLink ID
	 * @return		a Set of geneChipNames 
	 */

	public Set getSetOfGeneChipNames (Set identifiers, String platform) {

		log.debug("in getSetOfGeneChipNames");

		Set<String> endSet = new TreeSet<String>();
		for (Iterator identifierItr = identifiers.iterator(); identifierItr.hasNext();) {
			Identifier nextIdentifier = (Identifier) identifierItr.next();
			HashMap<String, Set<Identifier>> linksHash = nextIdentifier.getTargetHashMap();
			if (linksHash != null && linksHash.size() > 0) {
				for (Iterator linksItr = linksHash.keySet().iterator(); linksItr.hasNext();) {
					String linkType = (String) linksItr.next();
					if (linkType.equals(platform)) {
						TreeMap<String, Set<Identifier>> chips = getIdentifiersByGeneChip((Set<Identifier>)linksHash.get(linkType));
						endSet.addAll(chips.keySet());
					} else {
					}
				}
			}
		}
		return endSet;
	}

	/** 
	 * Go through a Set of Identifiers and return only those that match a set of geneChipNames
	 *
	 * @param identifiers	set of Identifiers 
	 *<br><pre>
	 *      ----------------------------------------------------------------------------------|
	 *      | Affy MOE430 Identifier 15026_at | Affy Whole Genome Identifier 1296_at  |...    |
	 *      ----------------------------------------------------------------------------------|
	 * </pre>
	 * @param geneChipNames	the names of the type of arrays 	
	 * @return		a Set of Identifiers that are for a set of geneChipNames ordered by identifier
	 *<br><pre>
	 *      ----------------------------------------------------------------------------------|
	 *      | Affy MOE430 Identifier 15026_at | Affy MOE430 Identifier 15027_at |...    |
	 *      ----------------------------------------------------------------------------------|
	 * </pre>
	 */

	public Set<Identifier> getIdentifiersByGeneChip(Set identifiers, String[] geneChipNames) {

		//log.debug("in getIdentifiersByGeneChip");

		List<String> geneChipList = Arrays.asList(geneChipNames);
		//log.debug("geneChipList = "); myDebugger.print(geneChipList);
		Set<Identifier> endSet = new TreeSet<Identifier>();
		for (Iterator identifierItr = identifiers.iterator(); identifierItr.hasNext();) {
			Identifier nextIdentifier = (Identifier) identifierItr.next();
			//log.debug("checking for affy or codeLink ids for "+nextIdentifier.getIdentifier());

			if (nextIdentifier.getIdentifierTypeName().equals("Affymetrix ID") || 
				nextIdentifier.getIdentifierTypeName().equals("CodeLink ID")) {
				//log.debug("here gene_chip = "+nextIdentifier.getGene_chip_name());
				if (geneChipList.contains(nextIdentifier.getGene_chip_name())) {
					endSet.add(nextIdentifier);
				}
			} else {
				//log.debug("Type is not Affy or CodeLink, so adding this identifier");
				endSet.add(nextIdentifier);
			}
			//log.debug("now there are "+endSet.size()+" elements in endSet");
		}
		//log.debug("returning this endSet:"); myDebugger.print(endSet);
		return endSet;
	}

	/** 
	 * Go through a Set of Identifiers and return a TreeMap of geneChipName mapped to a Set of Identifiers.
	 *
	 * @param identifiers	Set of Identifiers 
	 *<br><pre>
	 *      ----------------------------------------------------------------------------------|
	 *      | Affy MOE430 Identifier 15026_at | Affy Whole Genome Identifier 1296_at  |...    |
	 *      ----------------------------------------------------------------------------------|
	 * </pre>
	 * @return		a TreeMap of geneChipNames mapped to a Set of Identifiers for that geneChipName
	 *<br><pre>
	 *      -------------------       ------------------------------------------------|
	 *      |Affy MOE430      |---->  | Identifier 15026_at |...                      |
	 *      ------------------|       ------------------------------------------------|
	 *      |Affy Whole Genome| ...|      
	 *      ------------------      
	 * </pre>
	 */

	public TreeMap<String, Set<Identifier>> getIdentifiersByGeneChip(Set<Identifier> identifiers) {

		//log.debug("in getIdentifiersByGeneChip passing back a TreeMap");

		TreeMap<String, Set<Identifier>> endTreeMap = new TreeMap<String, Set<Identifier>>();
		for (Iterator identifierItr = identifiers.iterator(); identifierItr.hasNext();) {
			Identifier nextIdentifier = (Identifier) identifierItr.next();
			if (endTreeMap != null && nextIdentifier.getGene_chip_name() != null &&
				endTreeMap.containsKey(nextIdentifier.getGene_chip_name())) {
				((Set<Identifier>) endTreeMap.get(nextIdentifier.getGene_chip_name())).add(nextIdentifier);
			} else {
				if (nextIdentifier.getGene_chip_name() != null) {
					Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
					newIdentifierSet.add(nextIdentifier);
					endTreeMap.put(nextIdentifier.getGene_chip_name(), newIdentifierSet);
				}
			}
		}
		return endTreeMap;
	}

	/** 
	 * Get a Set of Identifiers for all input IDs for a particular list of targets and gene chip, 
	 * although it is not organized by target.
	 * Useful if you want a list of all possible target values, as is needed
	 * when translating an entire gene list into a particular identifier type.
	 * <p>
	 * This starts by calling {@link #getIdentifiersByInputID(int geneListID, String[] targets, Connection conn) getIdentifiersByInputID()} which returns a 
	 * which returns a Set of input Identifiers pointing to 
	 * a Set of Identifiers for a list of 
	 * targets.  This method then creates the middle HashMap and organizes the Identifiers by target.
	 * During this process, it also restricts by geneChipName
	 * </p>
	 *
	 * @param geneListID	the identifier of the list
	 * @param targets	names of databases to which the values should be translated
	 * @param geneChipName	name of gene_chip that should be matched 
	 * @param conn		database connection
	 *
	 * @return		a Set of Identifiers for a particular list of targets
	 *<br><pre>
	 *      ------------------------------------------------------------------------------------------------|
	 *      | Gene Symbol Identifier CDX4 |SwissProt Identifier P18111 | SwissProt Identifier Q8VCF7 |...   |
	 *      ------------------------------------------------------------------------------------------------|
	 * </pre>
	 * @throws	SQLException if there is a problem accessing the database
	 *                      
	 */
	public Set<Identifier> getIdentifiers(int geneListID, String[] targets, String geneChipName, Connection conn) throws SQLException {

		log.debug("in getIdentifiers passing in geneListID, targets, geneChipName, and conn");

		Set<Identifier> startSet = getIdentifiersByInputID(geneListID, targets, geneChipName, conn);
		//log.debug("startSet = "); myDebugger.print(startSet);
		Set<Identifier> endSet = new LinkedHashSet<Identifier>();
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier inputID = (Identifier) inputIDitr.next();
			Set<Identifier> identifierSet = inputID.getRelatedIdentifiers();
			for (Iterator itr = identifierSet.iterator(); itr.hasNext();) {
                        	((Identifier) itr.next()).setOriginatingIdentifier(inputID);
			}
			endSet.addAll(identifierSet);
		}
		return endSet;
	}
        
        /** 
	 * Get a Set of Identifiers for all input IDs for a particular list of targets and gene chip, 
	 * although it is not organized by target.
	 * Useful if you want a list of all possible target values, as is needed
	 * when translating an entire gene list into a particular identifier type.
	 * <p>
	 * This starts by calling {@link #getIdentifiersByInputID(int geneListID, String[] targets, Connection conn) getIdentifiersByInputID()} which returns a 
	 * which returns a Set of input Identifiers pointing to 
	 * a Set of Identifiers for a list of 
	 * targets.  This method then creates the middle HashMap and organizes the Identifiers by target.
	 * During this process, it also restricts by geneChipName
	 * </p>
	 *
	 * @param geneListID	the identifier of the list
	 * @param targets	names of databases to which the values should be translated
	 * @param geneChipName	name of gene_chip that should be matched 
	 * @param pool		database connection
	 *
	 * @return		a Set of Identifiers for a particular list of targets
	 *<br><pre>
	 *      ------------------------------------------------------------------------------------------------|
	 *      | Gene Symbol Identifier CDX4 |SwissProt Identifier P18111 | SwissProt Identifier Q8VCF7 |...   |
	 *      ------------------------------------------------------------------------------------------------|
	 * </pre>
	 * @throws	SQLException if there is a problem accessing the database
	 *                      
	 */
	public Set<Identifier> getIdentifiersIgnoreCase(int geneListID, String[] targets, String geneChipName, DataSource pool) throws SQLException {

		log.debug("in getIdentifiers passing in geneListID, targets, geneChipName, and conn");

		Set<Identifier> startSet = getIdentifiersByInputID(geneListID, targets, geneChipName, pool);
		//log.debug("startSet = "); myDebugger.print(startSet);
		Set<Identifier> endSet = new LinkedHashSet<Identifier>();
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier inputID = (Identifier) inputIDitr.next();
			Set<Identifier> identifierSet = inputID.getRelatedIdentifiers();
			for (Iterator itr = identifierSet.iterator(); itr.hasNext();) {
                        	((Identifier) itr.next()).setOriginatingIdentifier(inputID);
			}
			endSet.addAll(identifierSet);
		}
		return endSet;
	}
        
        public Set<Identifier> getIdentifiersByInputIDAndTarget(int geneListID, String[] targets, String[] geneChipNames,DataSource pool)throws SQLException {
           log.debug("in getIdentifiersByInputIDAndTarget passing in array of geneChipNames");
		List<String> geneChipsList = new ArrayList<String>();
		if (geneChipNames != null) {
			geneChipsList = Arrays.asList(geneChipNames);
		}
		//log.debug("geneChipsList = "); myDebugger.print(geneChipsList);
		//log.debug("targets = "); myDebugger.print(targets);

		Set<Identifier> startSet = getIdentifiersByInputID(geneListID, targets, pool);
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier thisIdentifier = (Identifier) inputIDitr.next();
			Set<Identifier> relatedIdentifiers = thisIdentifier.getRelatedIdentifiers();
			Set<Identifier> locationIdentifiers = thisIdentifier.getLocationIdentifiers();
			thisIdentifier.setTargetHashMap(new HashMap<String, Set<Identifier>>());
			for (Iterator identifierItr = relatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier relatedIdentifier = (Identifier) identifierItr.next();
				String identifierType = relatedIdentifier.getIdentifierTypeName();
				if (targetsList.contains(identifierType)) {
					if (thisIdentifier.getTargetHashMap().containsKey(identifierType)) {
						((Set<Identifier>) thisIdentifier.getTargetHashMap().get(identifierType)).add(relatedIdentifier);
					} else {
						Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
						newIdentifierSet.add(relatedIdentifier);
						thisIdentifier.getTargetHashMap().put(identifierType, newIdentifierSet);
					}
				}
			}
			for (Iterator identifierItr = locationIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier locationIdentifier = (Identifier) identifierItr.next();
				if (thisIdentifier.getTargetHashMap().containsKey("Location")) {
					((Set<Identifier>) thisIdentifier.getTargetHashMap().get("Location")).add(locationIdentifier);
				} else {
					Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
					newIdentifierSet.add(locationIdentifier);
					thisIdentifier.getTargetHashMap().put("Location", newIdentifierSet);
				}
			}
			// Restrict the identifiers by geneChipNames
			//log.debug("working on " +thisIdentifier.getIdentifier());
			if (targetsList.contains("Affymetrix ID") && geneChipsList.size() > 0 
					&& thisIdentifier.getTargetHashMap().containsKey("Affymetrix ID")) {
				Set<Identifier> affymetrixIdentifiers = getIdentifiersByGeneChip(
								(Set<Identifier>) thisIdentifier.getTargetHashMap().get("Affymetrix ID"),
								geneChipNames);
				//log.debug("now there are this many affy ids = "+ affymetrixIdentifiers.size());
				thisIdentifier.getTargetHashMap().remove("Affymetrix ID");
				thisIdentifier.getTargetHashMap().put("Affymetrix ID", affymetrixIdentifiers);
				
			}
 			if (targetsList.contains("CodeLink ID") && geneChipsList.size() > 0
					&& thisIdentifier.getTargetHashMap().containsKey("CodeLink ID")) {
				Set<Identifier> codeLinkIdentifiers = getIdentifiersByGeneChip(
								(Set<Identifier>) thisIdentifier.getTargetHashMap().get("CodeLink ID"),
								geneChipNames);
				thisIdentifier.getTargetHashMap().remove("CodeLink ID");
				//log.debug("now there are this many codeLink ids = "+ codeLinkIdentifiers.size());
				thisIdentifier.getTargetHashMap().put("CodeLink ID", codeLinkIdentifiers);
			}
		}
		return startSet;
        }
        
	/**
	 * Get a Set of Identifiers for all input IDs for a particular list of targets and set of geneChips, 
	 * organized by input ID and target.
	 * <p>
	 * This starts by calling {@link #getIdentifiersByInputID(int geneListID, String[] targets, Connection conn) getIdentifiersByInputID()} which returns a 
	 * which returns a Set of input Identifiers pointing to 
	 * a Set of Identifiers for a list of 
	 * targets.  This method then creates the middle HashMap and organizes the Identifiers by target.
	 * During this process, it also restricts by geneChipName
	 * </p>
	 * @param geneListID	the identifier of the list
	 * @param targets	names of databases to which the values should be translated
	 * @param geneChipNames	names of gene_chips that should be matched 
	 * @param conn		database connection
	 *
	 * @return		a Set of Identifiers, each having a defined Hashtable of identifier types which 
	 *			point to a Set of Identifiers 
	 *<br><pre>
	 *      ------------------       -----------------------|            ----------------------------------------------------|
	 *      | Identifier CDX4 |--->  | Affymetrix ID        | ----->     | Identifier 15026_at | Identifier 15296_at |...    |
	 *      ------------------|       -----------------------|            ----------------------------------------------------|
	 *      | Identifier CDX3 | ...| | SwissProt ID         | ----\      ----------------------------------------------------|
	 *      ------------------       -----------------------|      \-->  | Identifier P18111 | Identifier Q8VCF7 | ...  |    |
	 *                               |  ...                 |            ----------------------------------------------------|
	 *                               -----------------------|
	 * </pre>
	 * @throws	SQLException if there is a problem accessing the database
	 */ 
	public Set<Identifier> getIdentifiersByInputIDAndTarget(int geneListID, String[] targets, String[] geneChipNames, Connection conn) throws SQLException {

		log.debug("in getIdentifiersByInputIDAndTarget passing in array of geneChipNames");
		List<String> geneChipsList = new ArrayList<String>();
		if (geneChipNames != null) {
			geneChipsList = Arrays.asList(geneChipNames);
		}
		//log.debug("geneChipsList = "); myDebugger.print(geneChipsList);
		//log.debug("targets = "); myDebugger.print(targets);

		Set<Identifier> startSet = getIdentifiersByInputID(geneListID, targets, conn);
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier thisIdentifier = (Identifier) inputIDitr.next();
			Set<Identifier> relatedIdentifiers = thisIdentifier.getRelatedIdentifiers();
			Set<Identifier> locationIdentifiers = thisIdentifier.getLocationIdentifiers();
			thisIdentifier.setTargetHashMap(new HashMap<String, Set<Identifier>>());
			for (Iterator identifierItr = relatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier relatedIdentifier = (Identifier) identifierItr.next();
				String identifierType = relatedIdentifier.getIdentifierTypeName();
				if (targetsList.contains(identifierType)) {
					if (thisIdentifier.getTargetHashMap().containsKey(identifierType)) {
						((Set<Identifier>) thisIdentifier.getTargetHashMap().get(identifierType)).add(relatedIdentifier);
					} else {
						Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
						newIdentifierSet.add(relatedIdentifier);
						thisIdentifier.getTargetHashMap().put(identifierType, newIdentifierSet);
					}
				}
			}
			for (Iterator identifierItr = locationIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier locationIdentifier = (Identifier) identifierItr.next();
				if (thisIdentifier.getTargetHashMap().containsKey("Location")) {
					((Set<Identifier>) thisIdentifier.getTargetHashMap().get("Location")).add(locationIdentifier);
				} else {
					Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
					newIdentifierSet.add(locationIdentifier);
					thisIdentifier.getTargetHashMap().put("Location", newIdentifierSet);
				}
			}
			// Restrict the identifiers by geneChipNames
			//log.debug("working on " +thisIdentifier.getIdentifier());
			if (targetsList.contains("Affymetrix ID") && geneChipsList.size() > 0 
					&& thisIdentifier.getTargetHashMap().containsKey("Affymetrix ID")) {
				Set<Identifier> affymetrixIdentifiers = getIdentifiersByGeneChip(
								(Set<Identifier>) thisIdentifier.getTargetHashMap().get("Affymetrix ID"),
								geneChipNames);
				//log.debug("now there are this many affy ids = "+ affymetrixIdentifiers.size());
				thisIdentifier.getTargetHashMap().remove("Affymetrix ID");
				thisIdentifier.getTargetHashMap().put("Affymetrix ID", affymetrixIdentifiers);
				
			}
 			if (targetsList.contains("CodeLink ID") && geneChipsList.size() > 0
					&& thisIdentifier.getTargetHashMap().containsKey("CodeLink ID")) {
				Set<Identifier> codeLinkIdentifiers = getIdentifiersByGeneChip(
								(Set<Identifier>) thisIdentifier.getTargetHashMap().get("CodeLink ID"),
								geneChipNames);
				thisIdentifier.getTargetHashMap().remove("CodeLink ID");
				//log.debug("now there are this many codeLink ids = "+ codeLinkIdentifiers.size());
				thisIdentifier.getTargetHashMap().put("CodeLink ID", codeLinkIdentifiers);
			}
		}
		return startSet;
	}

        public Set<Identifier> getIdentifiersByInputIDAndTarget(int geneListID, String[] targets, DataSource pool) throws SQLException {
                log.debug("in getIdentifiersByInputIDAndTarget passing in geneListID");

		Set<Identifier> startSet = getIdentifiersByInputID(geneListID, targets, pool);
		//log.debug("startSet here = "); myDebugger.print(startSet);
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier thisIdentifier = (Identifier) inputIDitr.next();
			Set<Identifier> relatedIdentifiers = thisIdentifier.getRelatedIdentifiers();
			Set<Identifier> locationIdentifiers = thisIdentifier.getLocationIdentifiers();
			thisIdentifier.setTargetHashMap(new HashMap<String, Set<Identifier>>());
			for (Iterator identifierItr = relatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier relatedIdentifier = (Identifier) identifierItr.next();
				String identifierType = relatedIdentifier.getIdentifierTypeName();
                                //log.debug("looking for targets = "+identifierType +"::"+targetsList.contains(identifierType)+":::"+thisIdentifier.getTargetHashMap().containsKey(identifierType));
				if (targetsList.contains(identifierType)) {
					if (thisIdentifier.getTargetHashMap().containsKey(identifierType)) {
                                                //log.debug("Added Target to Existing:");myDebugger.print(relatedIdentifier);
						((Set<Identifier>) thisIdentifier.getTargetHashMap().get(identifierType)).add(relatedIdentifier);
					} else {
                                            //log.debug("Added Target:");myDebugger.print(relatedIdentifier);
						Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
						newIdentifierSet.add(relatedIdentifier);
						thisIdentifier.getTargetHashMap().put(identifierType, newIdentifierSet);
                                                //log.debug("print related");myDebugger.print(relatedIdentifier.getRelatedIdentifiers());
					}
				}
			}
			for (Iterator identifierItr = locationIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier locationIdentifier = (Identifier) identifierItr.next();
				if (thisIdentifier.getTargetHashMap().containsKey("Location")) {
					((Set<Identifier>) thisIdentifier.getTargetHashMap().get("Location")).add(locationIdentifier);
				} else {
					Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
					newIdentifierSet.add(locationIdentifier);
					thisIdentifier.getTargetHashMap().put("Location", newIdentifierSet);
				}
			}
		}
		//log.debug("startSet now = "); myDebugger.print(startSet);
		return startSet;
        }
        
	/** Get a Set of Identifiers for all input IDs for a particular list of targets, organized by input ID and target.

        /**
	 * Get a Set of Identifiers for all input IDs for a particular list of targets, organized by input ID and target.
	 * <p>
	 * This starts by calling {@link #getIdentifiersByInputID(int geneListID, String[] targets, Connection conn) getIdentifiersByInputID()} which returns a * a Set of Identifiers pointing to
	 * targets.  This method then creates the middle HashMap and organizes the Identifiers by target.
	 * </p>
	 * @param geneListID	the identifier of the list
	 * @param targets	names of databases to which the values should be translated
	 * @param conn		database connection
	 *
	 * @return		a Set of Identifiers, each having a defined Hashtable of identifier types which 
	 *			point to a Set of Identifiers 
	 *<br><pre>
	 *      ------------------       -----------------------|            ----------------------------------------------------|
	 *      | Identifier CDX4 |--->  | Affymetrix ID        | ----->     | Identifier 15026_at | Identifier 15296_at |...    |
	 *      ------------------|       -----------------------|            ----------------------------------------------------|
	 *      | Identifier CDX3 | ...| | SwissProt ID         | ----\      ----------------------------------------------------|
	 *      ------------------       -----------------------|      \-->  | Identifier P18111 | Identifier Q8VCF7 | ...  |    |
	 *                               |  ...                 |            ----------------------------------------------------|
	 *                               -----------------------|
	 * </pre>
	 * @throws	SQLException if there is a problem accessing the database
	 */ 
	public Set<Identifier> getIdentifiersByInputIDAndTarget(int geneListID, String[] targets, Connection conn) throws SQLException {

		log.debug("in getIdentifiersByInputIDAndTarget passing in geneListID");

		Set<Identifier> startSet = getIdentifiersByInputID(geneListID, targets, conn);
		//log.debug("startSet here = "); myDebugger.print(startSet);
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier thisIdentifier = (Identifier) inputIDitr.next();
			Set<Identifier> relatedIdentifiers = thisIdentifier.getRelatedIdentifiers();
			Set<Identifier> locationIdentifiers = thisIdentifier.getLocationIdentifiers();
			thisIdentifier.setTargetHashMap(new HashMap<String, Set<Identifier>>());
			for (Iterator identifierItr = relatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier relatedIdentifier = (Identifier) identifierItr.next();
				String identifierType = relatedIdentifier.getIdentifierTypeName();
                                //log.debug("looking for targets = "+identifierType +"::"+targetsList.contains(identifierType)+":::"+thisIdentifier.getTargetHashMap().containsKey(identifierType));
				if (targetsList.contains(identifierType)) {
					if (thisIdentifier.getTargetHashMap().containsKey(identifierType)) {
                                                //log.debug("Added Target to Existing:");myDebugger.print(relatedIdentifier);
						((Set<Identifier>) thisIdentifier.getTargetHashMap().get(identifierType)).add(relatedIdentifier);
					} else {
                                            //log.debug("Added Target:");myDebugger.print(relatedIdentifier);
						Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
						newIdentifierSet.add(relatedIdentifier);
						thisIdentifier.getTargetHashMap().put(identifierType, newIdentifierSet);
                                                //log.debug("print related");myDebugger.print(relatedIdentifier.getRelatedIdentifiers());
					}
				}
			}
			for (Iterator identifierItr = locationIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier locationIdentifier = (Identifier) identifierItr.next();
				if (thisIdentifier.getTargetHashMap().containsKey("Location")) {
					((Set<Identifier>) thisIdentifier.getTargetHashMap().get("Location")).add(locationIdentifier);
				} else {
					Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
					newIdentifierSet.add(locationIdentifier);
					thisIdentifier.getTargetHashMap().put("Location", newIdentifierSet);
				}
			}
		}
		//log.debug("startSet now = "); myDebugger.print(startSet);
		return startSet;
	}
        /** Get a Set of Identifiers for all input IDs for a particular list of targets, organized by input ID and target.

        /**
	 * Get a Set of Identifiers for all input IDs for a particular list of targets, organized by input ID and target.
	 * <p>
	 * This starts by calling {@link #getIdentifiersByInputID(int geneListID, String[] targets, Connection conn) getIdentifiersByInputID()} which returns a * a Set of Identifiers pointing to
	 * targets.  This method then creates the middle HashMap and organizes the Identifiers by target.
	 * </p>
	 * @param geneListID	the identifier of the list
	 * @param targets	names of databases to which the values should be translated
	 * @param conn		database connection
	 *
	 * @return		a Set of Identifiers, each having a defined Hashtable of identifier types which 
	 *			point to a Set of Identifiers 
	 *<br><pre>
	 *      ------------------       -----------------------|            ----------------------------------------------------|
	 *      | Identifier CDX4 |--->  | Affymetrix ID        | ----->     | Identifier 15026_at | Identifier 15296_at |...    |
	 *      ------------------|       -----------------------|            ----------------------------------------------------|
	 *      | Identifier CDX3 | ...| | SwissProt ID         | ----\      ----------------------------------------------------|
	 *      ------------------       -----------------------|      \-->  | Identifier P18111 | Identifier Q8VCF7 | ...  |    |
	 *                               |  ...                 |            ----------------------------------------------------|
	 *                               -----------------------|
	 * </pre>
	 * @throws	SQLException if there is a problem accessing the database
	 */ 
	public Set<Identifier> getIdentifiersByInputIDAndTargetCaseInsensitive(int geneListID, String[] targets, DataSource pool) throws SQLException {

		log.debug("in getIdentifiersByInputIDAndTarget passing in geneListID");

		Set<Identifier> startSet = getIdentifiersByInputID(geneListID, targets, pool);
		//log.debug("startSet here = "); myDebugger.print(startSet);
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier thisIdentifier = (Identifier) inputIDitr.next();
			Set<Identifier> relatedIdentifiers = thisIdentifier.getRelatedIdentifiers();
			Set<Identifier> locationIdentifiers = thisIdentifier.getLocationIdentifiers();
			thisIdentifier.setTargetHashMap(new HashMap<String, Set<Identifier>>());
			for (Iterator identifierItr = relatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier relatedIdentifier = (Identifier) identifierItr.next();
				String identifierType = relatedIdentifier.getIdentifierTypeName();
                                //log.debug("looking for targets = "+identifierType +"::"+targetsList.contains(identifierType)+":::"+thisIdentifier.getTargetHashMap().containsKey(identifierType));
				if (targetsList.contains(identifierType)) {
					if (thisIdentifier.getTargetHashMap().containsKey(identifierType)) {
                                                //log.debug("Added Target to Existing:");myDebugger.print(relatedIdentifier);
						((Set<Identifier>) thisIdentifier.getTargetHashMap().get(identifierType)).add(relatedIdentifier);
					} else {
                                            //log.debug("Added Target:");myDebugger.print(relatedIdentifier);
						Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
						newIdentifierSet.add(relatedIdentifier);
						thisIdentifier.getTargetHashMap().put(identifierType, newIdentifierSet);
                                                //log.debug("print related");myDebugger.print(relatedIdentifier.getRelatedIdentifiers());
					}
				}
			}
			for (Iterator identifierItr = locationIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier locationIdentifier = (Identifier) identifierItr.next();
				if (thisIdentifier.getTargetHashMap().containsKey("Location")) {
					((Set<Identifier>) thisIdentifier.getTargetHashMap().get("Location")).add(locationIdentifier);
				} else {
					Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
					newIdentifierSet.add(locationIdentifier);
					thisIdentifier.getTargetHashMap().put("Location", newIdentifierSet);
				}
			}
		}
		//log.debug("startSet now = "); myDebugger.print(startSet);
		return startSet;
	}
        /**
	 * Get a Set of Identifiers for all input IDs for a particular list of targets, organized by input ID and target.
	 * <p>
	 * This starts by calling {@link #getIdentifiersByInputID(int geneListID, String[] targets, Connection conn) getIdentifiersByInputID()} which returns a * a Set of Identifiers pointing to
	 * targets.  This method then creates the middle HashMap and organizes the Identifiers by target.
	 * </p>
	 * @param geneListID	the identifier of the list
	 * @param targets	names of databases to which the values should be translated
	 * @param conn		database connection
	 *
	 * @return		a Set of Identifiers, each having a defined Hashtable of identifier types which 
	 *			point to a Set of Identifiers 
	 *<br><pre>
	 *      ------------------       -----------------------|            ----------------------------------------------------|
	 *      | Identifier CDX4 |--->  | Affymetrix ID        | ----->     | Identifier 15026_at | Identifier 15296_at |...    |
	 *      ------------------|       -----------------------|            ----------------------------------------------------|
	 *      | Identifier CDX3 | ...| | SwissProt ID         | ----\      ----------------------------------------------------|
	 *      ------------------       -----------------------|      \-->  | Identifier P18111 | Identifier Q8VCF7 | ...  |    |
	 *                               |  ...                 |            ----------------------------------------------------|
	 *                               -----------------------|
	 * </pre>
	 * @throws	SQLException if there is a problem accessing the database
	 */ 
	public Set<Identifier> getIdentifiersByInputIDAndTarget(String geneID,String organism, String[] targets, Connection conn) throws SQLException {

		log.debug("in getIdentifiersByInputIDAndTarget passing in geneID");

		Set<Identifier> startSet = getIdentifiersByInputID(geneID,organism, targets, conn);
		log.debug("startSet here = "); myDebugger.print(startSet);
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier thisIdentifier = (Identifier) inputIDitr.next();
			Set<Identifier> relatedIdentifiers = thisIdentifier.getRelatedIdentifiers();
			Set<Identifier> locationIdentifiers = thisIdentifier.getLocationIdentifiers();
			thisIdentifier.setTargetHashMap(new HashMap<String, Set<Identifier>>());
			for (Iterator identifierItr = relatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier relatedIdentifier = (Identifier) identifierItr.next();
				String identifierType = relatedIdentifier.getIdentifierTypeName();
                                //log.debug("looking for targets = "+identifierType +"::"+targetsList.contains(identifierType)+":::"+thisIdentifier.getTargetHashMap().containsKey(identifierType));
				if (targetsList.contains(identifierType)) {
					if (thisIdentifier.getTargetHashMap().containsKey(identifierType)) {
                                                //log.debug("Added Target to Existing:");myDebugger.print(relatedIdentifier);
						((Set<Identifier>) thisIdentifier.getTargetHashMap().get(identifierType)).add(relatedIdentifier);
					} else {
                                            //log.debug("Added Target:");myDebugger.print(relatedIdentifier);
						Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
						newIdentifierSet.add(relatedIdentifier);
						thisIdentifier.getTargetHashMap().put(identifierType, newIdentifierSet);
                                                //log.debug("print related");myDebugger.print(relatedIdentifier.getRelatedIdentifiers());
					}
				}
			}
			for (Iterator identifierItr = locationIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier locationIdentifier = (Identifier) identifierItr.next();
				if (thisIdentifier.getTargetHashMap().containsKey("Location")) {
					((Set<Identifier>) thisIdentifier.getTargetHashMap().get("Location")).add(locationIdentifier);
				} else {
					Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
					newIdentifierSet.add(locationIdentifier);
					thisIdentifier.getTargetHashMap().put("Location", newIdentifierSet);
				}
			}
		}
		//log.debug("startSet now = "); myDebugger.print(startSet);
		return startSet;
	}
        public Set<Identifier> getIdentifiersByInputIDAndTarget(String geneID,String organism, String[] targets, DataSource pool) throws SQLException {
               log.debug("in getIdentifiersByInputIDAndTarget passing in geneID");

		Set<Identifier> startSet = getIdentifiersByInputID(geneID,organism, targets, pool);
		log.debug("startSet here = "); myDebugger.print(startSet);
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier thisIdentifier = (Identifier) inputIDitr.next();
			Set<Identifier> relatedIdentifiers = thisIdentifier.getRelatedIdentifiers();
			Set<Identifier> locationIdentifiers = thisIdentifier.getLocationIdentifiers();
			thisIdentifier.setTargetHashMap(new HashMap<String, Set<Identifier>>());
			for (Iterator identifierItr = relatedIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier relatedIdentifier = (Identifier) identifierItr.next();
				String identifierType = relatedIdentifier.getIdentifierTypeName();
                                //log.debug("looking for targets = "+identifierType +"::"+targetsList.contains(identifierType)+":::"+thisIdentifier.getTargetHashMap().containsKey(identifierType));
				if (targetsList.contains(identifierType)) {
					if (thisIdentifier.getTargetHashMap().containsKey(identifierType)) {
                                                //log.debug("Added Target to Existing:");myDebugger.print(relatedIdentifier);
						((Set<Identifier>) thisIdentifier.getTargetHashMap().get(identifierType)).add(relatedIdentifier);
					} else {
                                            //log.debug("Added Target:");myDebugger.print(relatedIdentifier);
						Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
						newIdentifierSet.add(relatedIdentifier);
						thisIdentifier.getTargetHashMap().put(identifierType, newIdentifierSet);
                                                //log.debug("print related");myDebugger.print(relatedIdentifier.getRelatedIdentifiers());
					}
				}
			}
			for (Iterator identifierItr = locationIdentifiers.iterator(); identifierItr.hasNext();) {
				Identifier locationIdentifier = (Identifier) identifierItr.next();
				if (thisIdentifier.getTargetHashMap().containsKey("Location")) {
					((Set<Identifier>) thisIdentifier.getTargetHashMap().get("Location")).add(locationIdentifier);
				} else {
					Set<Identifier> newIdentifierSet = new LinkedHashSet<Identifier>();
					newIdentifierSet.add(locationIdentifier);
					thisIdentifier.getTargetHashMap().put("Location", newIdentifierSet);
				}
			}
		}
		//log.debug("startSet now = "); myDebugger.print(startSet);
		return startSet;
	}
        
	/**
	 * Get a Set of Identifiers for a particular list of targets.
	 *
	 * @param linksHash	hash containing target name pointing to a Set of Identifiers
	 *<br><pre>
	 *      -----------------------|            ----------------------------------------------------|
	 *      | Affymetrix ID        | ----->     | Identifier 15026_at | Identifier 15296_at |...    |
	 *      -----------------------|            ----------------------------------------------------|
	 *      | SwissProt ID         | ----\      ----------------------------------------------------|
	 *      -----------------------|      \-->  | Identifier P18111 | Identifier Q8VCF7 | ...  |    |
	 *      |  ...                 |            ----------------------------------------------------|
	 *      -----------------------|
	 * </pre>
	 * @param targets	names of databases for which Identifiers are requested
	 *
	 * @return		a Set of Identifiers 
	 *<br><pre>
	 *      ----------------------------------------------------|
	 *      | Identifier 15026_at | Identifier 15296_at |...    |
	 *      ----------------------------------------------------|
	 * </pre>
	 */ 
	public Set<Identifier> getIdentifiersForTargetForOneID(HashMap<String,Set<Identifier>> linksHash, String[] targets) {

		Set<Identifier> returnSet = new LinkedHashSet<Identifier>();

		for (int i=0; i<targets.length; i++) {
			Set<Identifier> thisSet = (Set<Identifier>) linksHash.get(targets[i]);
			if (thisSet != null) {
				returnSet.addAll(thisSet);
			}
		}
		return returnSet;
	}

	/**
	 * Get a Set of Identifiers for a particular list of prioritized targets.  Go through
	 * the prioritized list, and as soon as values are found for a particular target,
	 * return all of those values.  Do not finish going through the list of targets.
	 *
	 * @param linksHash	hash containing target name pointing to a Set of Identifiers
	 *<br><pre>
	 *      -----------------------|            ----------------------------------------------------|
	 *      | Affymetrix ID        | ----->     | Identifier 15026_at | Identifier 15296_at |...    |
	 *      -----------------------|            ----------------------------------------------------|
	 *      | SwissProt ID         | ----\      ----------------------------------------------------|
	 *      -----------------------|      \-->  | Identifier P18111 | Identifier Q8VCF7 | ...  |    |
	 *      |  ...                 |            ----------------------------------------------------|
	 *      -----------------------|
	 * </pre>
	 * @param targets	names of databases for which Identifiers are requested
	 *
	 * @return		a Set of Identifiers 
	 *<br><pre>
	 *      ----------------------------------------------------|
	 *      | Identifier 15026_at | Identifier 15296_at |...    |
	 *      ----------------------------------------------------|
	 * </pre>
	 */ 
	public Set<Identifier> getIdentifiersForPrioritizedTargetForOneID(HashMap<String, Set<Identifier>> linksHash, String[] targets) {

		Set<Identifier> returnSet = new LinkedHashSet<Identifier>();

		int i=0;
		while (returnSet.size() == 0 && i<targets.length) {
			Set<Identifier> thisSet = (Set<Identifier>) linksHash.get(targets[i]);
			if (thisSet != null) {
				returnSet.addAll(thisSet);
			}
			i++;
		}
		return returnSet;
	}

	/**
	 * Get a Set of Identifiers for all input IDs for a particular list of targets.
	 * <p>
	 * This iterates through a Set of Identifiers by InputID and Target and combines all the Identifiers for 
	 * a list of targets into one big Set. 
	 * </p>
	 *
	 * @param startSet	Set of Identifiers returned by {@link #getIdentifiersByInputIDAndTarget(int geneListID, String[] targets, Connection conn) getIdentifiersByInputIDAndTarget()}
	 *<br><pre>
	 *      ------------------       -----------------------|            ----------------------------------------------------|
	 *      | Identifier CDX4 | ->  | Affymetrix ID         | ----->     | Identifier 15026_at | Identifier 15296_at |...    |
	 *      ------------------|      -----------------------|            ----------------------------------------------------|
	 *      | Identifier CDX3 | |   | SwissProt ID          | ----\      ----------------------------------------------------|
	 *      ------------------       -----------------------|      \-->  | Identifier P18111 | Identifier Q8VCF7 | ...  |    |
	 *                              |  ...                  |            ----------------------------------------------------|
	 *                              ------ -----------------|
	 * </pre>
	 * @return		a Set of Identifiers for a particular target
	 *<br><pre>
	 *      ----------------------------------------------------|
	 *      | Identifier 15026_at | Identifier 15296_at |...    |
	 *      ----------------------------------------------------|
	 * </pre>
	 */ 
	public Set<Identifier> getIdentifiersForTarget(Set startSet, String[] targets) {

		Set<Identifier> returnSet = new TreeSet<Identifier>();
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier thisIdentifier = (Identifier) inputIDitr.next();
			HashMap<String, Set<Identifier>> linksHash = (HashMap<String, Set<Identifier>>) thisIdentifier.getTargetHashMap();
			for (int i=0; i<targets.length; i++) {
				if (linksHash.containsKey(targets[i])) {
					returnSet.addAll((Set<Identifier>) linksHash.get(targets[i]));
				}
			}
		}
		return returnSet;
	}

	/** 
	 * Return the entire Set of Identifiers for all Input IDs.  It starts with a Set of Identifiers that is returned by 
	 * {@link #getIdentifiersByInputID(int geneListID, String[] targets, Connection conn) getIdentifiersByInputID()} 
	 * and iterates through it and combines all the Identifiers into one big Set. 
	 * Useful if you've already called getIdentifiersByInputID and just want the entire list to pass to another program.
	 *
	 * @param startSet	Set of Identifiers returned by getIdentifiersByInputID	
	 *<br><pre>
	 *      ------------------       ------------------------------------------------------------------------------------------------|
	 *      | Identifier CDX4 | -->  | Gene Symbol Identifier CDX4  |SwissProt Identifier P18111| ...                      |
	 *      ------------------|       ------------------------------------------------------------------------------------------------|
	 *      | Identifier CDX3 | -->  |SwissProt Identifier Q8VCF7 | ...|      
	 *      ------------------       ------------------------------------------------------------------------------------------------|      
	 * </pre>
	 * @return		a Set of Identifiers for a particular list of targets.  This also sets the originating Identifier.
	 *<br><pre>
	 *      ------------------------------------------------------------------------------------------------|
	 *      | Gene Symbol Identifier CDX4 |SwissProt Identifier P18111 | SwissProt Identifier Q8VCF7 |...   |
	 *      ------------------------------------------------------------------------------------------------|
	 * </pre>
	 *                      
	 */
	public Set<Identifier> getIdentifiers(Set startSet) {//throws Exception {

		//log.debug("in getIdentifiers passing in startSet");

		Set<Identifier> endSet = new LinkedHashSet<Identifier>();
		for (Iterator inputIDitr = startSet.iterator(); inputIDitr.hasNext();) {
			Identifier inputID = (Identifier) inputIDitr.next();
			Set<Identifier> identifierSet = inputID.getRelatedIdentifiers(); 
			for (Iterator itr = identifierSet.iterator(); itr.hasNext();) {
                        	((Identifier) itr.next()).setOriginatingIdentifier(inputID);
			}
			//log.debug("inputID = "+inputID + ", size of identifierSet = "+identifierSet.size());
			endSet.addAll(identifierSet);
		}
		//log.debug("size of endSet = "+endSet.size());
		return endSet;
	}

	/** 
	 * Get a Set of QualifiedLocation Strings for a Set of Identifiers.  
	 * Useful if you want the location values rather than Identifier objects.
	 *
	 * @param identifierSet	Set of Identifiers
	 * @return		Set of identifier values
	 *                      
	 */
	public Set<String> getQualifiedLocationValues(Set<Identifier> identifierSet) {

		Set<String> returnSet = new TreeSet<String>();

		if (identifierSet != null) {
			for (Iterator itr = identifierSet.iterator(); itr.hasNext();) {
                        	Identifier thisIdentifier = (Identifier) itr.next();
				returnSet.add(thisIdentifier.getQualifiedLocation());
                	}
		}
		return returnSet;
	}

	/** 
	 * Get a Set of id_numbers for a Set of Identifiers.  
	 * Useful if you want the id_numbers of the Identifier objects.
	 *
	 * @param identifierSet	Set of Identifiers
	 * @return		Set of identifier id_numbers
	 *                      
	 */
	public Set getIdNumbers(Set identifierSet) {

		Set<String> returnSet = new TreeSet<String>();

		if (identifierSet != null) {
			for (Iterator itr = identifierSet.iterator(); itr.hasNext();) {
                        	Identifier thisIdentifier = (Identifier) itr.next();
				returnSet.add(Long.toString(thisIdentifier.getIdNumber()));
                	}
		}
		return returnSet;
	}
	/** 
	 * Get a Set of Strings for a Set of Identifiers.  The strings contain the value of the identifier. 
	 * Useful if you want values rather than Identifier objects.
	 *
	 * @param identifierSet	Set of Identifiers
	 * @return		Set of identifier values
	 *                      
	 */
	public Set<String> getValues(Set<Identifier> identifierSet) {

		Set<String> returnSet = new TreeSet<String>();

		if (identifierSet != null) {
			for (Iterator itr = identifierSet.iterator(); itr.hasNext();) {
                        	Identifier thisIdentifier = (Identifier) itr.next();
				returnSet.add(thisIdentifier.getIdentifier());
                	}
		}
		return returnSet;
	}

	/**
	 * Writes the input IDs and their related target to a file
	 *
	 * @param results	results in the format as a call from 
	 *			{@link #getIdentifiersByInputIDAndTarget(int geneListID, String[] targets, 
	 *			Connection conn) getIdentifiersByInputIDAndTarget()}
	 * @param identifierType	either 'Entrez ID' or 'Gene Symbol'
	 * @param fileName	name of the file to be written		
	 * @throws IOException	if there is a problem writing to the file
	 */ 
	public void writeRefSetFile(Set<Identifier> results, String identifierType, String fileName) throws IOException {

		log.debug("in writeRefSetFile");
		BufferedWriter writer = new FileHandler().getBufferedWriter(fileName);
		ObjectHandler myObjectHandler = new ObjectHandler();

		// First sort the Set of Identifiers
		List<Identifier> myIdentifierList = Arrays.asList(results.toArray((Identifier[]) new Identifier[results.size()]));
		log.debug("myIdentifierList contains "+myIdentifierList.size() + " entries");
		myIdentifierList = new Identifier().sortIdentifiers(myIdentifierList, "identifier");
		Iterator originalIDItr = myIdentifierList.iterator();

                while (originalIDItr.hasNext()) {
                	Identifier originalID = (Identifier) originalIDItr.next();
			String originalIDPlusTab = originalID.getIdentifier() + "\t"; 
				
			Set<String> linksSet = (originalID.getTargetHashMap() != null && originalID.getTargetHashMap().size() > 0 ? 
							getValues((Set<Identifier>) originalID.getTargetHashMap().get(identifierType)) : 
							null);  

			if (linksSet != null && linksSet.size() > 0) {
				Iterator itr2 = linksSet.iterator();
				while (itr2.hasNext()) {
					writer.write(originalIDPlusTab + (String) itr2.next());
					writer.newLine();
				}
			}
		}
		log.debug("after iterating through myIdentifierList");
		writer.close();
	}

	/**
	/**
	 * Writes all the input IDs and their related identifiers to a file
	 *
	 * @param results	results in the format as a call from 
	 *			{@link #getIdentifiersByInputIDAndTarget(int geneListID, String[] targets, 
	 *			Connection conn) getIdentifiersByInputIDAndTarget()}
	 * @param targetList	List of Strings containing the names of databases whose values should be included in the output
	 * @param fileName	name of the file to be written		
	 * @param fileFormat	either 'oneRow', meaning all target identifiers are delimited by '///' 
	 *			and placed in a single column by target,  or 'separateRows', meaning the target name and 
	 *			identifier are placed on separate lines with the original identifier
	 * @throws IOException	if there is a problem writing to the file
	 */ 
	public void writeToFileByTarget(Set<Identifier> results, List<String> targetList, String fileName, String fileFormat) throws IOException {

		log.debug("in writeToFileByTarget");
		BufferedWriter writer = new FileHandler().getBufferedWriter(fileName);
		ObjectHandler myObjectHandler = new ObjectHandler();
		ArrayList<String> headerList = new ArrayList<String>(targetList);
		
		// This is commented out -- need to add logic to make sure the column headings are in
		// the same order as the identifiers getGeneChipName 
		/*
		String[] platforms = {"Affymetrix ID", "CodeLink ID"};
		for (int i=0; i<platforms.length; i++) {
			if (targetList.contains(platforms[i])) {
				int idxToRemove = headerList.indexOf(platforms[i]);
				headerList.remove(idxToRemove);
				List chipNames = new ArrayList(getSetOfGeneChipNames(results, platforms[i]));
				headerList.addAll(idxToRemove, chipNames);
			}
		}
		*/

		String headerLine = (fileFormat.equals("oneRow") ? 
					"Original Identifier\t" + myObjectHandler.getAsSeparatedString(headerList, "\t")
					: "Original Identifier\t" + "Target Name\t" + "Target Identifier");
		writer.write(headerLine); writer.newLine();

		// First sort the Set of Identifiers
		List<Identifier> myIdentifierList = Arrays.asList(results.toArray((Identifier[]) new Identifier[results.size()]));
		myIdentifierList = new Identifier().sortIdentifiers(myIdentifierList, "identifier");
		Iterator originalIDItr = myIdentifierList.iterator();

                while (originalIDItr.hasNext()) {
                	Identifier originalID = (Identifier) originalIDItr.next();
			String originalIDPlusTab = originalID.getIdentifier() + "\t"; 
			String line = "";
			if (fileFormat.equals("oneRow")) {
				line = originalIDPlusTab;
			}
				
			for (int i=0; i<targetList.size(); i++) {
				String target = (String) targetList.get(i);

				Set<String> linksSet = new TreeSet<String>(); 
				if (target.equals("Location")) { 
					linksSet = getQualifiedLocationValues((Set<Identifier>) originalID.getTargetHashMap().get(target)); 
				} else {
					//
					// If Affy or CodeLink IDs are requested, then create a new HashMap off of the Affy/CodeLink target
					// expanded by chip name; otherwise use the existing TargetHashMap
					//
					if ((target.equals("Affymetrix ID") || target.equals("CodeLink ID")) &&
						originalID.getTargetHashMap() != null && 
						originalID.getTargetHashMap().containsKey(target) && 
						fileFormat.equals("separateRows")) {

						HashMap<String, Set<Identifier>> hashMapByGeneChip = new HashMap<String, Set<Identifier>>(getIdentifiersByGeneChip(
										(Set<Identifier>) originalID.getTargetHashMap().get(target))
										);
						if (hashMapByGeneChip != null && hashMapByGeneChip.size() > 0) {
							// Get the list of identifiers by chip name
							Set chipNames = (Set) hashMapByGeneChip.keySet(); 
							Iterator chipNameItr = chipNames.iterator();
							while (chipNameItr.hasNext()) {
								String chipName = (String) chipNameItr.next(); 
								Set<Identifier> identifierSet = (Set<Identifier>) hashMapByGeneChip.get(chipName); 

								linksSet = getValues(identifierSet);

								
								// This is commented out -- need to add logic to make sure the column headings are in
								// the same order as the identifiers getGeneChipName 
								/*
								if (fileFormat.equals("oneRow")) {
									String linkValues = (linksSet.size() == 0 ? 
											"": 
											myObjectHandler.getAsSeparatedString(linksSet, "///"));  
									line = line + linkValues; 
									if (i != targetList.size() - 1) {
										line = line + "\t";
									}
								} else {
								*/
									Iterator itr2 = linksSet.iterator();
			                				while (itr2.hasNext()) {
										line = originalIDPlusTab + target + "--" + chipName + "\t" + (String) itr2.next();
										writer.write(line); writer.newLine();
									}
								//}
							}
							/*
							if (fileFormat.equals("oneRow")) {
								writer.write(line); writer.newLine();
							}
							*/
						}
					} else {  
						linksSet = getValues((Set<Identifier>) originalID.getTargetHashMap().get(target));  

						if (fileFormat.equals("oneRow")) {
							String linkValues = (linksSet == null ? "": myObjectHandler.getAsSeparatedString(linksSet, "///"));  
							line = line + linkValues; 
							if (i != targetList.size() - 1) {
								line = line + "\t";
							}
						} else {
							Iterator itr2 = linksSet.iterator();
			                		while (itr2.hasNext()) {
								line = originalIDPlusTab + target + "\t" + (String) itr2.next();
								writer.write(line); writer.newLine();
							}
						}
					}
				}
			}
			if (fileFormat.equals("oneRow")) {
				writer.write(line); writer.newLine();
			}
		}
		writer.close();
	}

	/**
	/**
	 * Writes all the input IDs and their related identifiers by prioritized target to a file
	 *
	 * @param results	results in the format as a call 
	 * 	from {@link #getIdentifiersByInputIDAndTarget(int geneListID, String[] targets, Connection conn) getIdentifiersByInputIDAndTarget()}
	 * @param targetList	List of String[], each of which contains a prioritized list of the names of databases 
	 *			whose values should be included in the output
	 * @param fileName	name of the file to be written		
	 * @throws IOException	if there is a problem writing to the file
	 * <p>
	 * For each Identifier, this calls {@link #getIdentifiersForPrioritizedTargetForOneID(HashMap linksHash, String[] targets) getIdentifiersForPrioritizedTarget()} to get the Set of Identifiers.
	 */ 
	public void writeToFileByPrioritizedTarget(Set<Identifier> results, List<String[]> targetList, String fileName) throws IOException {

		log.debug("in writeToFileByPrioritizedTarget");
		BufferedWriter writer = new FileHandler().getBufferedWriter(fileName);
		ObjectHandler myObjectHandler = new ObjectHandler();
		String headerLine = "Original Identifier\tOfficial Symbol\tRefSeq\tMGI/RGD/FlyBase\tUniProt\tUC Santa Cruz"; 
		log.debug("headerLine = "+headerLine);
		writer.write(headerLine); writer.newLine();

		// First sort the Set of Identifiers
		List<Identifier> myIdentifierList = Arrays.asList(results.toArray((Identifier[]) new Identifier[results.size()]));
		myIdentifierList = new Identifier().sortIdentifiers(myIdentifierList, "identifier");
		Iterator itr = myIdentifierList.iterator();

                while (itr.hasNext()) {
                        Identifier originalID = (Identifier) itr.next();
			String line = originalID.getIdentifier() + "\t"; 
			HashMap<String, Set<Identifier>> linksHash = originalID.getTargetHashMap();
			for (int i=0; i<targetList.size(); i++) {
				Set<String> linksSet = getValues(getIdentifiersForPrioritizedTargetForOneID(linksHash, (String[]) targetList.get(i)));
				String linkValues = (linksSet == null ? "": myObjectHandler.getAsSeparatedString(linksSet, "///"));  
				line = line + linkValues; 
				if (i != targetList.size() - 1) {
					line = line + "\t";
				} 
					
			}
			writer.write(line); writer.newLine();
		}
		writer.close();
	}

        /**
	 * Get all of the possible iDecoder Identifier Types in a String array. 
	 * @param conn	the database connection
	 * @return an array of identifier types
	 * @throws	SQLException if there is a problem accessing the database
	 */
	public String[] getIdentifierTypes(DataSource pool) throws SQLException {
            Connection conn=null;
            conn=pool.getConnection();
		log.debug("in getIdentifierTypes");
        	String query =
                	"select distinct name "+
                	"from identifier_types "+ 
			"union "+
			"select 'Location' "+
			"from dual "+
			"union "+
			"select 'Genetic Variations' "+
			"from dual "+
			"order by 1";

		Results myResults = new Results(query, conn);
		String[] strings = new String[myResults.getNumRows()];
		
                String [] dataRow;
		int i=0;
                while ((dataRow = myResults.getNextRow()) != null) {
			strings[i] = dataRow[0];
			i++;
                }
		myResults.close();
                if(conn!=null && !conn.isClosed()){
                    try{
                        conn.close();
                        conn=null;
                    }catch(SQLException e){}
                }
        	return strings;
  	}
        
	/**
	 * Get all of the possible iDecoder Identifier Types in a String array. 
	 * @param conn	the database connection
	 * @return an array of identifier types
	 * @throws	SQLException if there is a problem accessing the database
	 */
	public String[] getIdentifierTypes(Connection conn) throws SQLException {

		log.debug("in getIdentifierTypes");
        	String query =
                	"select distinct name "+
                	"from identifier_types "+ 
			"union "+
			"select 'Location' "+
			"from dual "+
			"union "+
			"select 'Genetic Variations' "+
			"from dual "+
			"order by 1";

		Results myResults = new Results(query, conn);
		String[] strings = new String[myResults.getNumRows()];
		
                String [] dataRow;
		int i=0;
                while ((dataRow = myResults.getNextRow()) != null) {
			strings[i] = dataRow[0];
			i++;
                }
		myResults.close();

        	return strings;
  	}

        
        public String[] getArraysForPlatform(String platform,DataSource pool)throws SQLException {
            Connection conn=null;
            String[] tmp=null;
            try{
                conn=pool.getConnection();
                tmp=getArraysForPlatform( platform,conn);
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
	 * Get all of the possible arrays for a particular platform in a String array. 
	 * @param platform	either 'Affymetrix' or 'CodeLink'
	 * @param conn	the database connection
	 * @return an array of possible array names 
	 * @throws	SQLException if there is a problem accessing the database
	 */
	public String[] getArraysForPlatform(String platform, Connection conn) throws SQLException {

		log.debug("in getArraysForPlatform");
        	String query =
                	"select distinct manufacture_array_name "+
                	"from array_types "+ 
			"where platform = ? "+
			"and manufacture_array_name not like '%Exon%'" +
			"and manufacture_array_name is not null "+
			"order by manufacture_array_name";

		Results myResults = new Results(query, platform, conn);
		ObjectHandler myObjectHandler = new ObjectHandler();
		List<String> arraysList = myObjectHandler.getResultsAsList(myResults, 0);
		log.debug("here arrayslist contains "+arraysList.size() + " arrays");
        	query =
                	"select distinct manufacture_array_name||'.probeset' "+
                	"from array_types "+ 
			"where platform = ? "+
			"and manufacture_array_name like '%Exon%' "+
			"union "+
                	"select distinct manufacture_array_name||'.transcript' "+
                	"from array_types "+ 
			"where platform = ? "+
			"and manufacture_array_name like '%Exon%' "+
			"order by 1";

		myResults = new Results(query, new Object[] {platform, platform}, conn);
		arraysList.addAll(myObjectHandler.getResultsAsList(myResults, 0));
		log.debug("here arrayslist contains "+arraysList.size() + " arrays");

		myResults.close();

		String[] arrays = myObjectHandler.getAsArray(arraysList, String.class);
        	return arrays;
  	}

}
