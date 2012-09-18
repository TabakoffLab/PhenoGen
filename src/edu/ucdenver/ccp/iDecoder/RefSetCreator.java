package edu.ucdenver.ccp.iDecoder;

/* for logging messages */
import org.apache.log4j.Logger;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.PropertiesConnection;
import edu.ucdenver.ccp.util.sql.Results;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier;
import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

/*
import java.lang.reflect.*;
import edu.ucdenver.ccp.util.sql.*;
import edu.ucdenver.ccp.util.*;
import edu.ucdenver.ccp.PhenoGen.data.*;

import java.awt.Graphics;
import javax.swing.JApplet;
import javax.servlet.*;
import javax.servlet.http.*;
*/

public class RefSetCreator {

	private Logger log;
	private Connection dbConn;
	private String[] myChips;
	private Debugger myDebugger = new Debugger();
	private FileHandler myFileHandler = new FileHandler();
	private String referenceFilesDir = "/Users/smahaffey/Desktop/ReferenceFiles/"; 

	public RefSetCreator() {
		//log = Logger.getRootLogger();
		log = Logger.getLogger("ReleaseLogger");
		log.debug("just instantiated RefSetCreator");
		System.out.println("just instantiated RefSetCreator");
	}
    
	public void setConnection(Connection conn) {
		dbConn = conn;
	}

	public Connection getConnection(File propertiesFile) {
        	Connection dbConn = null;
		try {
        		dbConn = new PropertiesConnection().getConnection(propertiesFile);
  			System.out.println("Got database Connection");
		} catch (Exception e) {
  			System.out.println("Can't get Connection");
		}
		return dbConn;

	} 

	private void getChips() throws SQLException {

		log.debug("in getChips");

		String query = 
			"select distinct array_name "+
			"from identifier_arrays "+
			//"where array_name in ('Affymetrix GeneChip Mouse Exon 1.0 ST Array.probeset', "+
			//"'Affymetrix GeneChip Mouse Exon 1.0 ST Array.transcript') "+
			"order by array_name";

		myChips = new ObjectHandler().getResultsAsStringArray(new Results(query, dbConn), 0);
		log.debug("myChips is this long: "+myChips.length);

	}	

	private String getOrganism (String chipName) {
		return (chipName.indexOf("Rat") > -1 ? "Rn" : 
			(chipName.indexOf("Human") > -1 ? "Hs" : 
			(chipName.indexOf("Drosophila") > -1 ? "Dm" :
			"Mm")));
	}

	public void createEntrezFiles() throws IOException, SQLException {
		log.debug("in createEntrezFiles");
		log.debug("instantiating IDecoderClient");
		IDecoderClient myIDecoderClient = new IDecoderClient();
		Identifier myIdentifier = new Identifier();

		String query = 
			"insert into gene_lists "+
			"(gene_list_id, gene_list_name, created_by_user_id, organism, create_date, gene_list_source) "+
			"values "+
			"(?, 'Temporary '||?||' Gene List', "+
//WARNING -- THIS CREATES AS CKH USER
			"1, ?, sysdate, 'Temp')";

		String query2 = 
			"insert into genes "+
			"(gene_list_id, gene_id) "+
			"select ?, id.identifier "+
			"from identifiers id, identifier_arrays ia "+
			"where id.id_number = ia.id_number "+
			//"and rownum < 1000 "+
			//"and id.identifier = '4304927' "+
			"and ia.array_name = ? ";

		//log.debug("query = "+query);
		//log.debug("query2 = "+query2);

		String [] targets = {
				"Entrez Gene ID", 
				//"Gene Symbol" 
				};

		myIDecoderClient.setNum_iterations(1);
		for (String thisChip : myChips) {
                	int geneListID = new DbUtils().getUniqueID("gene_lists_seq", dbConn);

			String organism = getOrganism(thisChip);
			log.debug("chip = "+thisChip + ", organism = "+organism);

			PreparedStatement pstmt = dbConn.prepareStatement(query);
			// Create a gene list and corresponding genes for the set of probeset IDs
			pstmt.setInt(1, geneListID);
			pstmt.setString(2, thisChip);
			pstmt.setString(3, organism);
                	pstmt.executeQuery();

			pstmt = dbConn.prepareStatement(query2);
			pstmt.setInt(1, geneListID);
			pstmt.setString(2, thisChip);
                	pstmt.executeQuery();

                	pstmt.close();

			Set<Identifier> iDecoderSet = myIDecoderClient.getIdentifiersByInputIDAndTarget(geneListID, targets, dbConn);
			log.debug("there are this many Identifiers in the Set: "+iDecoderSet.size());
			//log.debug("here they are: "); myDebugger.print(iDecoderSet);

			// Create a file containing the Entrez Gene IDs -- this needs to be uploaded manually next 
			myIDecoderClient.writeRefSetFile(iDecoderSet, "Entrez Gene ID", 
					getEntrezFileName(thisChip));
			Set<Identifier> entrezSet = myIDecoderClient.getIdentifiersForTarget(iDecoderSet, targets);
			myFileHandler.writeFile(myIDecoderClient.getValues(entrezSet), 
					getEntrezOnlyFileName(thisChip));
			log.debug("right before committing.  This should clear genelistgraph");
			// Have to commit in order to clear out genelistgraph temporary table
			dbConn.commit();
		}
	}

	public String getEntrezFileName(String chipName) {
		return referenceFilesDir + chipName + "_EntrezGeneIDs.txt";
	}
	public String getEntrezOnlyFileName(String chipName) {
		return referenceFilesDir + chipName + "_EntrezGeneIDs_ONLY.txt";
	}

	public void deleteGeneLists() throws SQLException, IOException {
		log.debug("in deleteGeneLists");
		Results myResults = getGeneLists();
		int[] myGeneListIDs = new ObjectHandler().getResultsAsIntArray(myResults, 0);
		for (int geneListID : myGeneListIDs) {
			log.debug("deleting gene_list_id = "+geneListID);
			new GeneList(geneListID).deleteGeneList(dbConn);
			dbConn.commit();
		}
	}

	public void createGeneLists() throws SQLException, IOException {
		log.debug("in createGeneLists");
		for (String thisChip : myChips) {
			GeneList thisGeneList = new GeneList();
			thisGeneList.setGene_list_name(thisChip + " Temporary Gene List");	
			thisGeneList.setDescription(thisChip);	
			//THIS CREATES GENELISTS AS THE CKH USER
			thisGeneList.setCreated_by_user_id(1);
			thisGeneList.setOrganism(getOrganism(thisChip));	
			thisGeneList.setGene_list_source("Uploaded File");	
			log.debug("about to call load from file for this chip " + thisChip);
			thisGeneList.loadFromFile(0, getEntrezOnlyFileName(thisChip), dbConn); 
		}
		dbConn.commit();
	}

	private Results getGeneLists() throws SQLException {
		log.debug("in getGeneLists");

		String query = 
			"select gene_list_id, description "+
			"from gene_lists "+ 
			"where gene_list_name like '%Temporary%Gene List' "+
			"order by gene_list_id";

		//log.debug("query = "+query);

		Results myResults = new Results(query, dbConn);
		return myResults;
	}

	public void createGeneSymbolFiles() throws IOException, SQLException {
		log.debug("in createGeneSymbolFiles");
		IDecoderClient myIDecoderClient = new IDecoderClient();

		String [] targets = {
				//"Entrez Gene ID", 
				"Gene Symbol" 
				};

		myIDecoderClient.setNum_iterations(1);

		Results myResults = getGeneLists();
		int[] myGeneListIDs = new ObjectHandler().getResultsAsIntArray(myResults, 0);
		String[] myChipNames = new ObjectHandler().getResultsAsStringArray(myResults, 1);
		int i=0;
		for (int geneListID : myGeneListIDs) {

			log.debug("gene_list_id = "+geneListID);

			Set<Identifier> iDecoderSet = myIDecoderClient.getIdentifiersByInputIDAndTarget(geneListID, targets, dbConn);
			log.debug("there are this many Identifiers in the Set: "+iDecoderSet.size());
			//log.debug("here they are: "); myDebugger.print(iDecoderSet);

			// Create a file mapping the Entrez Gene IDs to Gene Symbols 
			myIDecoderClient.writeRefSetFile(iDecoderSet, "Gene Symbol", 
					referenceFilesDir + myChipNames[i] + "_EntrezGeneIDs_GeneSymbols.txt");
			log.debug("right before committing.  This should clear genelistgraph");
			// Have to commit in order to clear out genelistgraph temporary table
			dbConn.commit();
			i++;
		}
                myResults.close();
	}

	public void createFinalFiles() throws IOException, SQLException {
		log.debug("in createFinalFiles");

		for (String thisChip : myChips) {
			Hashtable<String, List<String>> entrezHashtable = myFileHandler.getFileAsHashtablePlusList( 
					new File(getEntrezFileName(thisChip)));
			Hashtable<String, List<String>> geneSymbolHashtable = myFileHandler.getFileAsHashtablePlusList( 
					new File(referenceFilesDir + thisChip + "_EntrezGeneIDs_GeneSymbols.txt"));
			//log.debug("entrezHashtable has this many entries: " +entrezHashtable.size());
			//log.debug("geneSymbolHashtable has this many entries: " +geneSymbolHashtable.size());
			List<String> abc = new ArrayList<String>();
			
                	Iterator probeItr = entrezHashtable.keySet().iterator();

			int j=0;
                	while (probeItr.hasNext()) {
                        	String thisProbeID = (String) probeItr.next(); 
				if (j<5) {
					//log.debug("thisProbeID = "+thisProbeID);
				}
				List<String> entrezList = entrezHashtable.get(thisProbeID);
				if (entrezList != null) {
                			Iterator entrezItr = entrezList.iterator();
                			while (entrezItr.hasNext()) {
                        			String thisEntrez = (String) entrezItr.next(); 
						List<String> gsList = geneSymbolHashtable.get(thisEntrez);
						if (gsList != null) {
							if (j<5) {
								//log.debug("gsList is not null. it contains " + gsList.size() + " entries.");
							}
							// Create a new line for each gene symbol
                					Iterator gsItr = gsList.iterator();
                					while (gsItr.hasNext()) {
                        					String thisGs = (String) gsItr.next(); 
                        					abc.add(thisProbeID + "\t" + thisEntrez + "\t" + thisGs);
							}
						} else {
							// if no gene symbols are found for this Entrez ID, then just repeat the Entrez ID
                        				abc.add(thisProbeID + "\t" + thisEntrez + "\t" + thisEntrez);
						}
					}
				} else {
					// if no Entrez IDs are found for this probeset ID, then just repeat the probeset ID
                        		abc.add(thisProbeID + "\t" + thisProbeID + "\t" + thisProbeID);
				}
				j++;
			}
	                String[] lineArray = (String[]) abc.toArray(new String [abc.size()] );
			myFileHandler.writeFile(abc, referenceFilesDir + thisChip + "_Final.txt");
		}
	}


	public static void main(String[] args) throws Exception {
  		System.out.println("In RefSetCreator");
	
		RefSetCreator myRefSetCreator = new RefSetCreator();

		File propertiesFile = new File("/usr/share/tomcat/webapps/PhenoGen/web/common/dbProperties/stan_halDev.properties");
		myRefSetCreator.setConnection(myRefSetCreator.getConnection(propertiesFile));
		myRefSetCreator.getChips();

		// Run these one at a time.
		myRefSetCreator.createEntrezFiles();
		myRefSetCreator.createGeneLists();
		myRefSetCreator.createGeneSymbolFiles();
		myRefSetCreator.createFinalFiles();
		myRefSetCreator.deleteGeneLists();
	} 
}
