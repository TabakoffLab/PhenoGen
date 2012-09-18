/*
 * Created on Mar 15, 2005
 *
 */
package edu.ucdenver.ccp.PhenoGen.tools.literature;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;

import org.apache.log4j.Logger;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.Searcher;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

/**
 * @author Andrew E. Dolbey
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class Literature implements LitModule {

	/**
	 * Limits the number of PubMed IDs returned from a search of the Lucene Medline index.
	 */
	private final int MAX_RESULT_COUNT = 10000;
	
	HashMap ids;
	HashMap searchCats;  // hash map for categories (keys) and keywords (values)
	boolean autoAlcohol;

	  private Logger log=null;

	  private DbUtils myDbUtils = new DbUtils();
	  private Debugger myDebugger = new Debugger();

	
	
	PubMedCollection results;

	String searchIndexLocation = "/net/gomez.ucdenver.pvt/data/medline/medline-2011/indexes/medline-2011/";

	String KEYWORD_CONSTANT = "(alcohol OR ethanol) AND ";
	
	
	/**
	 * Constructor with no args
	 */
	public Literature() {
		ids = new HashMap();
		searchCats = new HashMap();
		autoAlcohol = false;
		
		results = new PubMedCollection();

	        log = Logger.getRootLogger();
	}
	
	
	/**
	 * @param searchCats
	 * @param autoAlcohol
	 * @param ids
	 */
	public Literature(HashMap searchCats, boolean autoAlcohol, HashMap ids) {
		this.searchCats = searchCats;
		this.autoAlcohol = autoAlcohol;
		this.ids = ids;

		results = new PubMedCollection();

	        log = Logger.getRootLogger();
	}
	
	
	public boolean getAutoAlcohol() {
		return autoAlcohol;
	}
	public void setAutoAlcohol(boolean autoAlcohol) {
		this.autoAlcohol = autoAlcohol;
	}
	public HashMap getIds() {
		return ids;
	}
	public void setIds(HashMap ids) {
		this.ids = ids;
	}
	String getKEYWORD_CONSTANT() {
		return KEYWORD_CONSTANT;
	}
	void setKEYWORD_CONSTANT(String keyword_constant) {
		KEYWORD_CONSTANT = keyword_constant;
	}
	public PubMedCollection getResults() {
		return results;
	}
	public void setResults(PubMedCollection resultSet) {
		this.results = resultSet;
	}
	public HashMap getSearchCats() {
		return searchCats;
	}
	public void setSearchCats(HashMap searchCats) {
		this.searchCats = searchCats;
	}
	public String getSearchIndexLocation() {
		return searchIndexLocation;
	}
	public void setSearchIndexLocation(String searchIndexLocation) {
		this.searchIndexLocation = searchIndexLocation;
	}

	
	// iterate through cats 
	  // iterate through genes
	     // do searches
	
	
	public void searchTheCats() throws Exception {
	
		log.debug("in Literature.searchTheCats");
		
		Iterator searchCatIt = searchCats.keySet().iterator();
		String cat;
		
		while(searchCatIt.hasNext()) {
			cat = (String) searchCatIt.next();
			searchTheIds(cat);
		}
	
	}

	
	public void searchTheIds(String cat) throws Exception {
		
		log.debug("in Literature.searchTheIds");
		//log.debug("ids = ");myDebugger.print(ids);
		String[] keywordsSet = (String[]) searchCats.get(cat);
		String queryCatStr = makeQueryString(keywordsSet);

		String id, idsForQuery = new String();
		String[] aliases;

		String queryStr;
		Iterator idItr = ids.keySet().iterator();

		int hitTotal = 0;
		Date cStart = new Date();
			
		while (idItr.hasNext()) {
			id = (String) idItr.next();

			aliases = (String[]) ids.get(id);
			idsForQuery = id + " OR ";
			
			for (int i=0; i<aliases.length; i++) {
				idsForQuery += aliases[i] + " OR ";
			}
			idsForQuery = "(" + idsForQuery.substring(0, idsForQuery.length() - 4) + ")";

			queryStr = queryCatStr + " AND " + idsForQuery;
			if (autoAlcohol) {
				queryStr = queryStr + KEYWORD_CONSTANT;
			}
			
			if (keywordsSet.length == 0) {
			    queryStr = idsForQuery;
			}

			HashSet hits = search(queryStr);
			
			//log.debug("id = " + id + ", query string: " + queryStr + ", number hits: " + hits.size() +"\n");
			hitTotal += hits.size();

			String pmid;
			Iterator hitsIt = hits.iterator();
			while (hitsIt.hasNext()) {
				pmid = (String) hitsIt.next();
				Integer pmidI = new Integer(pmid);
				results.addEntry(new PubMedEntry(pmidI, id, cat));
			}
		}
		Date cEnd = new Date();

	}
	
	
	public String makeQueryString(String[] keywordSet) {

	    if (keywordSet.length == 0) {
	    	return "";
	    }
	    
		String queryStr = new String();
		for(int i=0;i<keywordSet.length; i++) {
			queryStr += keywordSet[i] + " OR ";
		}
		queryStr = "(" + queryStr.substring(0, queryStr.length() - 4) + ")";
		
		return(queryStr);
	}
	
	

	/**
	 * Searches the text field in the Lucene index for the query string. The text field is comprised
	 * of both the title and abstract from each Medline record. Results are limited by the
	 * MAX_RECORD_COUNT parameter which is currently set to 10000.
	 * 
	 * @param queryStr
	 * @return Set of PubMed IDs
	 * @throws IOException
	 */
	public HashSet<String> search(String queryStr) throws IOException {
		HashSet<String> hits = new HashSet<String>();

		Searcher searcher = null;
		try {
			Directory searchIndexDirectory = FSDirectory.open(new File(searchIndexLocation));
			searcher = new IndexSearcher(searchIndexDirectory);
			Analyzer analyzer = new StandardAnalyzer(Version.LUCENE_30);
			QueryParser parser = new QueryParser(Version.LUCENE_30, "text", analyzer);
			Query query = parser.parse(queryStr);

			TopDocs searchResults = searcher.search(query, MAX_RESULT_COUNT);
			for (ScoreDoc scoreDoc : searchResults.scoreDocs) {
				Document doc = searcher.doc(scoreDoc.doc);
				hits.add(doc.getField("pmid").stringValue());
			}
                        //searchIndexDirectory.close();
		} catch (IOException ioe) {
			log.error("in Literature.search exception", ioe);
			throw new RuntimeException(ioe);
		} catch (ParseException pe) {
			log.error("in Literature.search exception", pe);
			throw new RuntimeException(pe);
		} finally {
			if (searcher != null)
				searcher.close();
		}

		return hits;
	}
	
	public PubMedCollection search(HashMap searchCats, HashMap ids) throws Exception {
		setSearchCats(searchCats);
		setIds(ids);
		
		searchTheCats();
		
		return results;
	}
	

	public PubMedCollection search(HashMap searchCats, HashMap ids, 
			boolean autoAlcohol) throws Exception {

		log.debug("in Literature.search with cats, ids, and autoAlcohol");

		setSearchCats(searchCats);
		setIds(ids);
		setAutoAlcohol(autoAlcohol);
		searchTheCats();
		
		return results;
		
	}

	
	
	public static void main(String[] args) throws Exception {

		HashMap<String, String[]> ids = new HashMap<String, String[]>();
/*
		ids.put("Birc5", new String[] {"Birc5", "AP14" });
 		ids.put("BRCA1", new String[] {"BRCA1", "BRCAI", "IRIS", "PSCP"});
 		ids.put("Sparc", new String[] {"Sparc", "BM-40"});
 		ids.put("Alcam", new String[] {"Alcam", "BEN", "SC1", "MuSC", "CD166", "DM-GRASP", "MGC27910"});
 		ids.put("Hdh", new String[] {"Hdh", "HD", "htt", "IT15", "huntingtin"});
 		ids.put("Coq7", new String[] {"Coq7", "clk-1"});
 		ids.put("Fcna", new String[] {"Fcna", "Fcn1"});
 		ids.put("Rgds", new String[] {"Rgds", "RalGDS"});
 		ids.put("Scl25a5", new String[] {"Scl25a5", "Ant2"});
 		ids.put("Sptlc2", new String[] {"Sptlc2", "LCB2"});
 		ids.put("Tnfaip1", new String[] {"Tnfaip1", "Edp1"});
 		ids.put("Cdc25c", new String[] {"Cdc25c", "Cdc25"});
 		ids.put("Crry", new String[] {"Crry", "Cr1"});
 		ids.put("Drg1", new String[] {"Drg1", "Nedd3"});
 		ids.put("Bnip3", new String[] {"Bnip3", "Nip3"});
 		ids.put("Ccnf", new String[] {"Ccnf"});
 		ids.put("Cdkn1c", new String[] {"Cdkn1c", "CDKI", "Kip2", "p57Kip2", "p57(kip2)"});
 		ids.put("Rad23b", new String[] {"Rad23b", "p58", "mHR23B", "0610007D13Rik"});
 		ids.put("Fen1", new String[] {"Fen1"});
 		ids.put("Timp3", new String[] {"Timp3", "Timp-3"});
 		ids.put("Timp2", new String[] {"Timp2", "Timp-2", "D11Bwg1104e"});
 		ids.put("Vim", new String[] {"Vim"});
 		ids.put("S100a10", new String[] {"S100a10", "p11", "Cal1l"});
*/
 		ids.put("Gabrd", new String[] {"Gabrd"});
 		ids.put("Gabrb3", new String[] {"Gabrb3"});
 		ids.put("NM_023456", new String[] {"0710005A05Rik", "Npy"});

		
		HashMap<String, String[]> cats = new HashMap<String, String[]>();
		cats.put("Neuron", new String[] {"brain", "cerebellum", "hippocampus", "cortex"});
		cats.put("Behavior", new String[] {"tolerance", "learning", "memory", "motor learning"});
		cats.put("Ion Channels", new String[] {"glutamate", "NMDA", "PDZ", "anchoring"});
		cats.put("Protein Kinase", new String[] {"phosphorylation", "phosphatase", "tyrosine", "serine"});
		cats.put("QTL", new String[] {"selective breeding", "mutants", "mouse", "candidate genes"});
		
//		cats.put("JustGenes", new String[0]);
		
//		Literature myObj = new Literature(cats, ids);
		
		Literature myObj0 = new Literature();
		myObj0.setIds(ids);
//		myObj0.setSearchCats(cats);
		
//		myObj.searchTheCats();
		
		String cat, id;

		Literature myObj1 = new Literature();
		PubMedCollection hitset;

		hitset = myObj1.search(cats, ids, false);
		
		Iterator catIt = cats.keySet().iterator(); //myObj.getSearchCats().keySet().iterator();

		PubMedCollection hits;
		
		while(catIt.hasNext()) {
			cat = (String) catIt.next();
			System.out.println(cat);

			Iterator idItr  = ids.keySet().iterator(); //myObj.getIds().keySet().iterator();

			while(idItr.hasNext()) {
				id = (String) idItr.next();	
				System.out.println("For " + id);
			
				hits = (PubMedCollection) hitset.getSubCollection(cat, id);
			
				Iterator hitSetIt = hits.getEntries().values().iterator();

				while(hitSetIt.hasNext()) {
					PubMedEntry entry = (PubMedEntry) hitSetIt.next();
					System.out.println("\t" + entry.getPmid());
				}
			}
		}
		
		PubMedCollection.CoReferences corefs = hitset.getCoReferences();

		System.out.println("\n\nCoreferences:\n\n");
		
		int cardinal = corefs.getMaxCardinality();
		HashSet tuples;
		Iterator tupIt, corefIt;
		PubMedCollection.Tuple tup;
		PubMedEntry corefEnt;
		
/*
		while (cardinal > 1) {
			System.out.println("Cardinality " + cardinal + "\n");
			tuples = corefs.getTuples(cardinal);
			tupIt = tuples.iterator();

			HashSet corefsEntries;
			while(tupIt.hasNext()) {
				tup = (PubMedCollection.Tuple) tupIt.next();
				String tupleStr = tup.getTupleString(", ");
				corefsEntries = corefs.getCorefs(tup);
				
				System.out.println(tupleStr);
				corefIt = corefsEntries.iterator();
				while(corefIt.hasNext()) {
					corefEnt = (PubMedEntry) corefIt.next();
					System.out.println("\t" + corefEnt.getPmid());
				}
				System.out.println("\n");
			}
			cardinal--;
			
		}
*/

		HashMap corefsCollection = corefs.getCorefCollection();
		Iterator itr = corefsCollection.keySet().iterator();
		Integer i;
		HashMap tupleGroup;
		Iterator tupsItr, corefsItr;
		PubMedCollection.Tuple t;
		String tupId;
		HashSet tupCorefs;
		
		while (itr.hasNext()) {
			i = (Integer)itr.next();
			tupleGroup = (HashMap) corefsCollection.get(i);
			tupsItr = tupleGroup.keySet().iterator();
			
			while(tupsItr.hasNext()) {
				t = (PubMedCollection.Tuple) tupsItr.next();
				tupId = t.getIdentifier();
			}
		}


	}
}
