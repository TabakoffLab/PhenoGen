/*
 * Created on Mar 25, 2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package edu.ucdenver.ccp.PhenoGen.tools.literature;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;

import edu.ucdenver.ccp.util.Debugger;
/* for logging messages */
import org.apache.log4j.Logger;

/**
 * @author Andrew E. Dolbey
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class PubMedCollection {

	private Logger log=null;

	HashMap<Integer, PubMedEntry> entries;  // base collection of PubMedEntry objects
	                  			// mapping:  PMID <==> PubMedEntry --> {PMID, queryCats, entities}
	int count;
	

	/**
	 * @param collection
	 */
	public PubMedCollection(PubMedCollection collection) {
		entries = collection.getEntries();
		count = collection.getCount();
	        log = Logger.getRootLogger();

	}
		
	
	/**
	 * @param entries
	 */
	public PubMedCollection(HashMap<Integer, PubMedEntry> entries) {
		this.entries = entries;
		count = entries.size();
	        log = Logger.getRootLogger();
	}
		
	
	/**
	 * 
	 */
	public PubMedCollection() {
		entries = new HashMap<Integer, PubMedEntry>();
		count = 0;
	        log = Logger.getRootLogger();
	}
	
	
	PubMedCollection cloneCollection() {

		PubMedCollection copy = new PubMedCollection();

		copy.setEntries( (HashMap<Integer, PubMedEntry>)entries.clone() );
		copy.count = copy.entries.size();
		
		return (copy);
	}
	
	
	/**
	 * @return Returns the count.
	 */
	public int getCount() {
		return count;
	}


	boolean isEmpty() {
		if (entries.isEmpty()) {
			return true;
		}
		return false;
	}

	
	/**
	 * @return Returns the entries.
	 */
	public HashMap<Integer, PubMedEntry> getEntries() {
		return entries;
	}


	/**
	 * @param cat
	 * @return Returns the entries for a specific cat
	 */
	public PubMedCollection getCategorySubCollection(String cat) {
		PubMedCollection categoryEntries = new PubMedCollection();

		Iterator it = entries.keySet().iterator();
		PubMedEntry entry;
		
		while(it.hasNext()) {
			entry = (PubMedEntry) it.next();
			if (entry.getQueryCats().contains(cat)) {
				categoryEntries.addEntry(entry);
			}
			
		}
		
		return categoryEntries;
	}
	

	/**
	 * @param entity
	 * @return Returns the entries for a specific cat
	 */
	public PubMedCollection getEntitySubCollection(String entity) {
		PubMedCollection entityEntries = new PubMedCollection();

		Iterator it = entries.keySet().iterator();
		PubMedEntry entry;
		
		while(it.hasNext()) {
			entry = (PubMedEntry) it.next();
			if (entry.getGenes().contains(entity)) {
				entityEntries.addEntry(entry);
			}
			
		}
		
		return entityEntries;
	}
	

	/**
	 * @param cat
	 * @param entity
	 * @return Returns the entries for a specific cat and gene id
	 */
	public PubMedCollection getSubCollection(String cat, String entity) {
		PubMedCollection catAndIdEntries = new PubMedCollection();

		Iterator it = entries.values().iterator();
		PubMedEntry entry;
		
		while(it.hasNext()) {
			entry = (PubMedEntry) it.next();
			if (entry.getQueryCats().contains(cat) && 
					entry.getGenes().contains(entity)) {
				catAndIdEntries.addEntry(entry);
			}
			
		}
		
		return catAndIdEntries;
	}
	

	/**
	 * @param collection The entries to set.
	 */
	public void setEntries(PubMedCollection collection) {
		entries = collection.getEntries();
		count = entries.size();
	}

	
	/**
	 * @param entries The entries to set.
	 */
	public void setEntries(HashMap<Integer, PubMedEntry> entries) {
		this.entries = entries;
		count = entries.size();
	}

	
	boolean hasEntry(PubMedEntry entry) {
		// deep check; current sets must have at least what target's have
		if (entries.containsKey(entry.getPmid())) {
			return true;
		}
		return false;
	}

	
	boolean hasEntries(PubMedCollection collection) {
		if (this.entries.values().containsAll(collection.getEntries().values()) &&
				this.entries.keySet().containsAll(collection.getEntries().keySet())) {
			return true;
		}
		return false;
	}
	

	boolean hasEntries(HashMap entries) {
		if (this.entries.values().containsAll(entries.values()) &&
				this.entries.keySet().containsAll(entries.keySet())) {
			return true;
		}
		return false;
	}
	

	PubMedEntry getEntry(Integer pmid) {
		return (PubMedEntry) entries.get(pmid);
	}

	
	void addEntry(PubMedEntry entry) {
		if(hasEntry(entry)) {
			((PubMedEntry)getEntry(entry.getPmid())).updateInfo(entry);
		} else {
			entries.put(entry.getPmid(), entry);
			count++;
		}
	}

	
	void addEntries(PubMedCollection collection) {
		Iterator cIt = collection.getEntries().keySet().iterator();
		
		PubMedEntry entry;
		Integer pmid;
		
		while(cIt.hasNext()) {
			pmid = (Integer) cIt.next();
			addEntry((PubMedEntry)collection.getEntry(pmid));
		}
	}
	
	
	void addEntries(HashMap entries) {
		Iterator it = entries.keySet().iterator();

		while(it.hasNext()) {
			addEntry((PubMedEntry)it.next());
		}
	}
	
	
	void removeEntry(PubMedEntry entry) {
		// nothing will be flagged if entry is not in collection
		if (hasEntry(entry)) {
			entries.remove(entry);
			count--;
		}
	}
	
	
	void removeEntries(PubMedCollection collection) {
		Iterator cIt = collection.getEntries().keySet().iterator();
		PubMedEntry entry;
		while(cIt.hasNext()) {
			entry = (PubMedEntry) entries.get(cIt.next());
			removeEntry(entry);
		}
	}
	
	
	void removeEntries(HashMap entries) {
		Iterator it = entries.keySet().iterator();
		PubMedEntry entry;
		while(it.hasNext()) {
			entry = (PubMedEntry) entries.get(it.next());
			removeEntry(entry);
		}
	}
	
	
	PubMedCollection missingEntries(PubMedCollection collection) {
		
		PubMedCollection missing = new PubMedCollection();
		Iterator it = collection.getEntries().keySet().iterator();
		PubMedEntry entry;
		while(it.hasNext()) {
			entry = (PubMedEntry) it.next();
			if (! hasEntry(entry)) {
				missing.addEntry(entry);
			}
		}
		if (! missing.isEmpty()) {
			return missing;
		} else {
			return null;
		}
	}
	
	
	HashSet<Integer> missingPMIDs(HashSet pmids) {
		
		HashSet<Integer> missing = new HashSet<Integer>();
		Iterator it = pmids.iterator();
		Integer pmid;
		while(it.hasNext()) {
			pmid = (Integer) it.next();
			if (! entries.containsKey(pmid)) {
				missing.add(pmid);
			}
		}
		if (! missing.isEmpty()) {
			return missing;
		} else {
			return null;
		}
	}
	
	
	HashSet getPiecesFromCollection(String piece) {
		// piece will be either "genes" or "queryCats"

		Iterator it = entries.values().iterator();
		PubMedEntry entry;
		
		HashSet<Object> pieces = new HashSet<Object>();
		Iterator pIt;
		while(it.hasNext()) {
			entry = (PubMedEntry) it.next();
			if (piece.equals("genes")) {
				pIt = entry.getGenes().iterator();
			} else {
				pIt = entry.getQueryCats().iterator();
			}
			while(pIt.hasNext()) {
				Object p = pIt.next();
				pieces.add(p);
			}
		}
		
		return pieces;
	}
	

	public interface Tuple {
		String getIdentifier();
		int getCardinality();
		String[] getGenes();
		String getTupleString(String concatenator);
	}
	
	
	public interface CoReferences {
		int getTotal();
		int getTotalTuples();
		int getMaxCardinality();

		HashSet getTuples(int cardinality);
		HashSet getCorefs(Tuple tuple);
		HashMap getCorefCollection();
		
	}
	
	
	public CoReferences getCoReferences() {
		
		class PTuple implements Tuple {
			String identifier;
			String[] genes;
			int cardinality;
			
			public PTuple(String[] genes) {
				identifier = uniqueId(genes);
				this.genes = genes;
				cardinality = this.genes.length;
			}
			
			String uniqueId(String[] genes) {
				String id = new String();
				for(int i=0; i<genes.length; i++) {
					id += genes[i] + "+";
				}
				id = id.substring(0,id.length()-1);
				return id;
			}
			
			public int getCardinality() {
				return cardinality;
			}
			
			public String getIdentifier() {
				return identifier;
			}
			
			public String[] getGenes() {
				return genes;
			}
			
			public String getTupleString(String concatenator) {
				
				String tupleStr = new String();
				for(int i=0; i<genes.length; i++) {
					tupleStr += genes[i] + concatenator;
				}
				
				tupleStr = tupleStr.substring(0, tupleStr.length() - concatenator.length());
				return tupleStr;
			}
		}

		
		class PCoReferences implements CoReferences {
	
			HashMap tuples;
			HashSet genes;

			String[] toArray(HashSet h) {
				String[] arr = new String[h.size()];
				Iterator hIt = h.iterator();
				int i = 0;
				while(hIt.hasNext()) {
					arr[i] = (String) hIt.next();
					i++;
				}
				return arr;
			}


			PCoReferences() {
				tuples = gatherTuples();
				genes = getPiecesFromCollection("genes");
			}
			

			HashMap gatherTuples() {
				
				Iterator it = getEntries().keySet().iterator();
				PubMedEntry entry;
				HashMap<String, Tuple> tups = new HashMap<String, Tuple>();

				while(it.hasNext()) {
					entry = (PubMedEntry) getEntry((Integer)it.next());
					if (entry.getGenes().size() > 1) {
						Tuple t = new PTuple (toArray(entry.getGenes()));
						tups.put(t.getIdentifier(), t);
					}
				}

				it = tups.keySet().iterator();
				return tups;
			}
			

			public int getMaxCardinality() {
				
				int card, max = 0;
				
				Iterator tupIt = tuples.keySet().iterator();
				Tuple t;

				while(tupIt.hasNext()) {
					t = (Tuple) tuples.get(tupIt.next());
					card = t.getCardinality();
					if (card > max) {
						max = card;
					}
				}
				return max;
			}

			
			/* (non-Javadoc)
			 * @see edu.ucdenver.ccp.PhenoGen.tools.literature.PubMedCollection.CoReferences#getTotal()
			 */
			public int getTotal() {
				return tuples.size();
			}


			/* (non-Javadoc)
			 * @see edu.ucdenver.ccp.PhenoGen.tools.literature.PubMedCollection.CoReferences#getTotal()
			 */
			public int getTotalTuples() {
				return tuples.size();
			}


			/* (non-Javadoc)
			 * @see edu.ucdenver.ccp.PhenoGen.tools.literature.PubMedCollection.CoReferences#getTuples(int)
			 */
			/* tups is a HashSet of Tuples, which looks like: 
			 *
			 */
			public HashSet<Tuple> getTuples(int cardinality) {

				HashSet<Tuple> tups = new HashSet<Tuple>();
				Iterator tupIt = tuples.keySet().iterator();
				Tuple t;
				while(tupIt.hasNext()) {
					t = (Tuple) tuples.get(tupIt.next());
					if (t.getCardinality() == cardinality) {
						tups.add(t);
					}
				}
	
				return tups;
			}

			
			/* (non-Javadoc)
			 * @see edu.ucdenver.ccp.PhenoGen.tools.literature.PubMedCollection.CoReferences#getCorefs(java.lang.String)
			 */
			public HashSet<PubMedEntry> getCorefs(Tuple tuple) {

				Iterator it = getEntries().keySet().iterator();
				PubMedEntry entry;
				
				String[] genes = tuple.getGenes();
				HashSet<PubMedEntry> entries = new HashSet<PubMedEntry>();
				
				
				HashSet<String> tupHs = new HashSet<String>();
				for(int i =0; i<genes.length; i++) {
					tupHs.add(genes[i]);
				}
				
				while(it.hasNext()) {
					entry = (PubMedEntry) getEntry((Integer) it.next());
					if (tupHs.equals(entry.getGenes())) {
						entries.add(entry);
					}
				}
				
				return entries;
			}


			/* (non-Javadoc)
			 * @see edu.ucdenver.ccp.PhenoGen.tools.literature.PubMedCollection.CoReferences#getCorefCollection()
			 */
			/* corefCollection is a HashMap between tuples and coreferences
			 * It looks like:
			*/
			public HashMap getCorefCollection() {
				HashMap<Integer, HashMap<PubMedCollection.Tuple, HashSet<PubMedEntry>>> corefCollection = 
							new HashMap<Integer, HashMap<PubMedCollection.Tuple, HashSet<PubMedEntry>>>();
				
				HashSet tuples;
				Iterator tupIt, corefIt;
				PubMedCollection.Tuple tup;
				PubMedEntry corefEnt;
				
				for (int i=getMaxCardinality(); i>1; i--) {
					tuples = getTuples(i);
					tupIt = tuples.iterator();

					HashMap<PubMedCollection.Tuple, HashSet<PubMedEntry>>  corefTuples = new HashMap<PubMedCollection.Tuple, HashSet<PubMedEntry>>();
					while(tupIt.hasNext()) {
						tup = (PubMedCollection.Tuple) tupIt.next();
						corefTuples.put(tup, getCorefs(tup));
					}
					corefCollection.put(new Integer(i), corefTuples);
				}

				return corefCollection;
			}

			
			
		}
		
		CoReferences corefs = new PCoReferences();
		return corefs;	
	}

	
	
	public static void main(String[] args) {
	}

}
