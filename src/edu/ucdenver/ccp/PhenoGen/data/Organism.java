package edu.ucdenver.ccp.PhenoGen.data;
                                                                                                                       
import java.sql.*;
import java.util.*;
import edu.ucdenver.ccp.util.sql.*;
import edu.ucdenver.ccp.util.*;
import edu.ucdenver.ccp.PhenoGen.web.*;
import javax.sql.DataSource;
                                                                                                                       
/* for logging messages */
import org.apache.log4j.Logger;
                                                                                                                       
/**
 * Class for handling data about organisms.
 *  @author  Cheryl Hornbaker
 */

public class Organism{
	
  private Logger log=null;
                                                                                                                       
  public Organism () {
        log = Logger.getRootLogger();
  }

        /**
	 * Gets the list of valid organisms.
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return		a Hashtable mapping the 2-character abbreviation to the scientific name
	 */
	public LinkedHashMap getOrganismsAsSelectOptions(DataSource pool) throws SQLException {
		//log.debug("in getOrganismsAsSelectOptions");

		String query =
			"select organism, organism_name "+
			"from organisms "+
			"where organism != 'NA' "+
			"order by organism";
                Connection conn=null;
                LinkedHashMap<String, String> optionHash = new LinkedHashMap<String, String>();
                try{      
                    conn=pool.getConnection();
                    Results myResults = new Results(query, conn);
                    
                    String dataRow[] = null;

                    while ((dataRow = myResults.getNextRow()) != null) {
                            optionHash.put(dataRow[0], dataRow[1]);
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
                                                                                                                       
		return optionHash;
	}
  
	/**
	 * Gets the list of valid organisms.
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return		a Hashtable mapping the 2-character abbreviation to the scientific name
	 */
	public LinkedHashMap getOrganismsAsSelectOptions(Connection conn) throws SQLException {
		//log.debug("in getOrganismsAsSelectOptions");

		String query =
			"select organism, organism_name "+
			"from organisms "+
			"where organism != 'NA' "+
			"order by organism";
                                                                                                                       
		Results myResults = new Results(query, conn);
		LinkedHashMap<String, String> optionHash = new LinkedHashMap<String, String>();
		String dataRow[] = null;
	
		while ((dataRow = myResults.getNextRow()) != null) {
			optionHash.put(dataRow[0], dataRow[1]);
		}

		myResults.close();
                                                                                                                       
		return optionHash;
	}

  /**
   * Gets the 2-character abbreviation for an organism
   * @param organism_name	the scientific name of the organism	
   * @param conn	the database connection
   * @throws            SQLException if a database error occurs
   * @return            the 2-character abbreviation
   */
  public String getOrganism(String organism_name, Connection conn) throws SQLException {
	//log.debug("in getOrganism for name = " + organism_name);

	String query =
		"select organism "+
		"from organisms "+
		"where organism_name = ?";
                                                                                                                       
	Results myResults = new Results(query, organism_name, conn);
	myResults.getResultSet().next();
	String organism = myResults.getResultSet().getString(1);
	myResults.close();
                                                                                                                       
	return organism;
  }

  /**
   * Gets the scientific name for an organism
   * @param organism	the 2-character abbreviation of the organism	
   * @param conn	the database connection
   * @throws            SQLException if a database error occurs
   * @return            the scientific name
   */
  public String getOrganism_name(String organism, Connection conn) throws SQLException {
	log.debug("in getOrganism_name for organism = " + organism);

	String query =
		"select organism_name "+
		"from organisms "+
		"where organism = ?";
                                                                                                                       
	Results myResults = new Results(query, organism, conn);
	myResults.getResultSet().next();
	String organism_name = myResults.getResultSet().getString(1);
	myResults.close();
                                                                                                                       
	return organism_name;
  }

  /**
   * Gets the common name for an organism
   * @param organism_name	the scientific name of the organism	
   * @param conn	the database connection
   * @throws            SQLException if a database error occurs
   * @return            the common name
   */
  public String getCommon_name(String organism_name, Connection conn) throws SQLException {
	//log.debug("in getCommon_name");

	String query =
		"select common_name "+
		"from organisms "+
		"where organism_name = ?";
                                                                                                                       
	Results myResults = new Results(query, organism_name, conn);
	myResults.getResultSet().next();
	String common_name = myResults.getResultSet().getString(1);
	myResults.close();
                                                                                                                       
	return common_name;
  }

  /**
   * Gets the common name for an organism abbreviation
   * @param organism	the 2-character abbreviation of the organism	
   * @param conn	the database connection
   * @throws            SQLException if a database error occurs
   * @return            the common name
   */
  public String getCommon_name_for_abbreviation(String organism, Connection conn) throws SQLException {
	//log.debug("in getCommon_name_for_abbreviation");

	String query =
		"select common_name "+
		"from organisms "+
		"where organism = ?";
                                                                                                                       
	Results myResults = new Results(query, organism, conn);
	myResults.getResultSet().next();
	String common_name = myResults.getResultSet().getString(1);
	myResults.close();
                                                                                                                       
	return common_name;
  }

  /**
   * Gets the taxon_id for an organism abbreviation
   * @param organism	the 2-character abbreviation of the organism	
   * @param conn	the database connection
   * @throws            SQLException if a database error occurs
   * @return            the taxon_id
   */
  public String getTaxon_id(String organism, Connection conn) throws SQLException {
	//log.debug("in getCommon_name_for_abbreviation");

	String query =
		"select taxon_id "+
		"from organisms "+
		"where organism = ?";
                                                                                                                       
	Results myResults = new Results(query, organism, conn);
	myResults.getResultSet().next();
	String taxon_id = myResults.getResultSet().getString(1);
	myResults.close();
                                                                                                                       
	return taxon_id;
  }
	/**
	 * Retrieves the Chromosome objects for this organism.
	 * @param organism	the two-character abbreviation for the organism
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of Chromosome objects 
	 */
	public Chromosome[] getChromosomes(String organism, Connection conn) throws SQLException {

        	//log.debug("in getChromosomes. organism = " +organism);

        	String query =
			"select chr.chromosome_id, "+
			"chr.name,  "+
			"chr.length, "+
			"chr.display_order, "+
			"chr.organism, "+
			"cyt.band_id, "+
			"cyt.bp_start, "+
			"cyt.bp_end, "+
			"cyt.label, "+
			"cyt.color "+
			"from chromosomes chr, cytobands cyt "+
			"where chr.organism = ? "+
			"and chr.chromosome_id = cyt.chromosome_id "+
			"order by chr.display_order, cyt.bp_start";

		//log.debug("query = "+query);

        	Results myResults = new Results(query, organism, conn);

        	Chromosome[] myChromosomes = setupChromosomeValues(myResults);

		myResults.close();

        	return myChromosomes;
  	}

	/**
	 * Creates a new array of Chromosome objects and sets the data values to those retrieved from the database.
   	 * @param myResults	the Results object
	 * @return            an array of Chromosome objects with their values setup 
   	 */
	private Chromosome[] setupChromosomeValues(Results myResults) {

        	//log.debug("in setupChromosomeValues");

		String [] dataRow = null;
		List<Chromosome> chromosomeList = new ArrayList<Chromosome>();
		List<Cytoband> cytobandList = null;
		String prevChromoID = "";
		String thisChromoID = "";
        	Chromosome thisChromosome = null;

        	while ((dataRow = myResults.getNextRow()) != null) {
			thisChromoID = dataRow[0];

			if (!thisChromoID.equals(prevChromoID)) {
				if (cytobandList != null) {
					Cytoband[] myCytobands = (Cytoband[]) cytobandList.toArray(
							new Cytoband[cytobandList.size()]);
					thisChromosome.setCytobands(myCytobands);
					chromosomeList.add(thisChromosome);
				}
        			thisChromosome = new Chromosome();
        			thisChromosome.setChromosome_id(Integer.parseInt(thisChromoID));
        			thisChromosome.setName(dataRow[1]);
        			thisChromosome.setLength(Integer.parseInt(dataRow[2]));
        			thisChromosome.setDisplay_order(Integer.parseInt(dataRow[3]));
        			thisChromosome.setOrganism(dataRow[4]);

				cytobandList = new ArrayList<Cytoband>();
			}
			Cytoband newCytoband = new Cytoband();
			newCytoband.setBand_id(Integer.parseInt(dataRow[5]));
			newCytoband.setBp_start(Integer.parseInt(dataRow[6]));
			newCytoband.setBp_end(Integer.parseInt(dataRow[7]));
			newCytoband.setLabel(dataRow[8]);
			newCytoband.setColor(dataRow[9]);
			cytobandList.add(newCytoband);

			prevChromoID = thisChromoID;
		}
		if (cytobandList != null) {
			//log.debug("adding last cytobandList and chromosome ");
			Cytoband[] myCytobands = (Cytoband[]) cytobandList.toArray(
					new Cytoband[cytobandList.size()]);
			thisChromosome.setCytobands(myCytobands);
			chromosomeList.add(thisChromosome);
		} else {
			log.debug("cytobandList IS null, setting up new chromosome and cytobandList");
		}

		Chromosome[] chromosomeArray = (Chromosome[]) chromosomeList.toArray(
				new Chromosome[chromosomeList.size()]);

        	return chromosomeArray;
	} 

	/**
	 * Class for handling information related to the chromosomes of an organism.
	 */
	public class Chromosome {
		private int chromosome_id;
		private int length;
		private int display_order;
		private Cytoband[] cytobands;
		private String name;
		private String organism;

		public Chromosome() {
			log = Logger.getRootLogger();
		}

		public void setChromosome_id(int inInt) {
			chromosome_id = inInt;
		}

		public int getChromosome_id() {
			return chromosome_id;
		}

		public void setLength(int inInt) {
			length = inInt;
		}

		public int getLength() {
			return length;
		}

		public void setDisplay_order(int inInt) {
			display_order = inInt;
		}

		public int getDisplay_order() {
			return display_order;
		}

		public void setCytobands(Cytoband[] inArray) {
			cytobands = inArray;
		}

		public Cytoband[] getCytobands() {
			return cytobands;
		}

		public void setName(String inString) {
			name = inString;
		}

		public String getName() {
			return name;
		}

		public void setOrganism(String inString) {
			organism = inString;
		}

		public String getOrganism() {
			return organism;
		}

		public String toString() {
			String chromoInfo = "This Chromosome object has name = " + name + 
				" and these cytobands: ";
				if (this.getCytobands() != null) {
					for (int i=0; i<this.getCytobands().length; i++) {
						chromoInfo = chromoInfo + this.getCytobands()[i].toString();
					}
				} else {
					chromoInfo = chromoInfo + " None ";
				}
			return chromoInfo;
		}

		public void print() {
			log.debug(toString());
		}

	}

	/**
	 * Class for handling information related to the cytobands for the chromosomes of an organism.
	 */
	public class Cytoband {
		private int band_id;
		private int bp_start;
		private int bp_end;
		private String label;
		private String color;

		public Cytoband() {
			log = Logger.getRootLogger();
		}

		public void setBand_id(int inInt) {
			band_id = inInt;
		}

		public int getBand_id() {
			return band_id;
		}

		public void setBp_start(int inInt) {
			bp_start = inInt;
		}

		public int getBp_start() {
			return bp_start;
		}

		public void setBp_end(int inInt) {
			bp_end = inInt;
		}

		public int getBp_end() {
			return bp_end;
		}

		public void setLabel(String inString) {
			label = inString;
		}

		public String getLabel() {
			return label;
		}

		public void setColor(String inString) {
			color = inString;
		}

		public String getColor() {
			return color;
		}

		public String toString() {
			String cytoInfo = "This Cytoband object has label = " + label + ", start = " + bp_start + 
				" and end = " + bp_end ;
			return cytoInfo;
		}

		public void print() {
			log.debug(toString());
		}
	}
}

