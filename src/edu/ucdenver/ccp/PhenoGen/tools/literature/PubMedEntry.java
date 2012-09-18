/*
 * Created on Mar 25, 2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package edu.ucdenver.ccp.PhenoGen.tools.literature;

import java.util.HashSet;
import java.util.Iterator;

/**
 * @author Andrew E. Dolbey
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class PubMedEntry {

	Integer pmid;
	HashSet genes, queryCats;
	
	
	/**
	 * @param pmid
	 * @param genes
	 * @param queryCats
	 */
	public PubMedEntry(Integer pmid, HashSet genes, HashSet queryCats) {
		this.pmid = pmid;
		this.genes = genes;
		this.queryCats = queryCats;
	}

	
	/**
	 * @param pmid
	 */
	public PubMedEntry(Integer pmid) {
		this.pmid = pmid;
		genes = new HashSet();
		queryCats = new HashSet();
	}

	
	/**
	 * @param pmid
	 */
	public PubMedEntry(Integer pmid, String gene, String queryCat) {
		this(pmid);
		genes.add(gene);
		queryCats.add(queryCat);
	}

	
	
	
	/**
	 * @return Returns the genes.
	 */
	public HashSet getGenes() {
		return genes;
	}
	/**
	 * @param genes The genes to set.
	 */
	public void setGenes(HashSet genes) {
		this.genes = genes;
	}
	/**
	 * @return Returns the queryCats.
	 */
	public HashSet getQueryCats() {
		return queryCats;
	}
	/**
	 * @param queryCats The queryCats to set.
	 */
	public void setQueryCats(HashSet queryCats) {
		this.queryCats = queryCats;
	}
	/**
	 * @return Returns the pmid.
	 */
	public Integer getPmid() {
		return pmid;
	}
	/**
	 * @param pmid The pmid to set.
	 */
	public void setPmid(Integer pmid) {
		this.pmid = pmid;
	}


	
	
	public void addGene(String gene) {
		genes.add(gene);
	}
	
	
	public void removeGene(String gene) {
		genes.remove(gene);
	}

	
	public void addQueryCat(String cat) {
		queryCats.add(cat);
	}
	
	
	public void removeQueryCat(String cat) {
		queryCats.remove(cat);
	}

	
	int getGeneCount() {
		return genes.size();
	}
	

	int getQueryCatCount() {
		return queryCats.size();
	}
	
	
	boolean hasGene(String gene) {
		return(genes.contains(gene));
	}

	
	boolean hasQueryCat(String queryCat) {
		return(queryCats.contains(queryCat));
	}
	
	
	boolean equals (PubMedEntry entry) {
		if (
			pmid == entry.pmid &&
			genes.containsAll(entry.genes) &&
			queryCats.containsAll(entry.queryCats)
		) {
			return true;
		}
		return false;
	}

	
	PubMedEntry clone (PubMedEntry entry) {
		return (new PubMedEntry(entry.getPmid(), (HashSet)entry.genes.clone(),
				(HashSet)entry.queryCats.clone()));
	}
	
	
	void updateInfo(PubMedEntry entry) {
//		System.out.println(this.toString());
		genes.addAll(entry.genes);
		queryCats.addAll(entry.queryCats);
//		System.out.println(this.toString());
	}
	
	
	public String toString() {
		String cats, entities, info = new String();
		info = "" + pmid + "\n";
		Iterator it = queryCats.iterator();
		while(it.hasNext()) {
			info += (String) it.next() + ", ";
		}
		info = info.substring(0, info.length()-2);
		info += "\n";
		it = genes.iterator();
		while(it.hasNext()) {
			info += (String) it.next() + ", ";
		}
		info = info.substring(0, info.length()-2);
		info += "\n";
		return info;
	}
	
	public static void main(String[] args) {
		PubMedEntry e = new PubMedEntry(new Integer(111869));
	}
}
