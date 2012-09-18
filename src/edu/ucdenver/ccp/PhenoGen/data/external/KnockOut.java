package edu.ucdenver.ccp.PhenoGen.data.external;

import java.sql.*;
import java.util.*;
import edu.ucdenver.ccp.util.sql.*;

/* for logging messages */
import org.apache.log4j.Logger;       

/**
 * Class for handling data related to managing information about genetically modified animals.
 *  @author  Cheryl Hornbaker
 */

public class KnockOut{

  private Logger log=null;

  public KnockOut () {
	log = Logger.getRootLogger();
  }

	/**
	 * Gets the alleles from the MGI website that are mutations.
	 * @param symbolList	an array of official symbols     
	 * @param conn        the database connection (it is a Sybase database)
	 * @throws            SQLException if a database error occurs
	 * @return            a Results object
	 */
	public Results getPhenotypicAlleles(String[] symbolList, Connection conn) throws SQLException {
		//
		// NOTICE THERE IS NO ';' at the end -- because this is querying a Sybase db 
		//
		// This builds a statement for each official symbol passed in the symbolList
		// e.g., and (al.symbol = 'Cdx1' or al.symbol = 'CDX1')
		//

		String likeStatement = null;
		if (symbolList.length > 0) {
			likeStatement = "and (al.symbol like '" + symbolList[0] + "%' ";
			for (int i=1; i<symbolList.length; i++) {
				likeStatement = likeStatement + 
						"or al.symbol like '" + 
						symbolList[i] + "%' ";
			}
			likeStatement = likeStatement + ") ";
		} else {
			likeStatement = "and al.symbol like 'NoSymbolsPassed%' ";
		}

		/*String query = 
			"select (case when charindex('<', al.symbol) = 0 then "+
			"al.symbol else "+
			"substring(al.symbol, 1, charindex('<', al.symbol) - 1) + "+ 
			"	'<SUP>' + "+
			"	substring(al.symbol, charindex('<', al.symbol) + 1, "+
			"	charindex('>', al.symbol) - charindex('<', al.symbol) -1) + "+
			"	'</SUP>' end) as Allele, "+
			"term.term 'Allele Type', "+
			"al.name 'Allele Name', "+
			"n.note 'Allele Definition', "+
			"al._Allele_key DoNotPrint "+
			"from ALL_Allele al, "+
			"VOC_Term term, "+
			"MGI_Note_Allele_View n "+
			"where term._Term_key = al._Allele_Type_key "+
			"and al._Allele_key = n._Object_key "+
			"and n.noteType = 'Molecular' "+
			"and term.term not in ('Not Applicable', 'Not Specified', 'QTL') "+
			likeStatement + 
			"order by al.symbol, "+
			"n.sequenceNum ";
                        */
                String query = 
			"select (case when strpos(al.symbol,'<') = 0 then "+
			"al.symbol else "+
			"substring(al.symbol, 1, strpos(al.symbol,'<') - 1) || "+ 
			"	CAST('<SUP>' as text) || "+
			"	substring(al.symbol, strpos(al.symbol,'<') + 1 , "+
			"	strpos( al.symbol,'>') - strpos(al.symbol,'<') -1) || "+
			"	CAST('</SUP>' as text) end) as \"Allele\", "+
			"vt.term as \"Allele Type\", "+
			"al.name as \"Allele Name\", "+
			"nc.note as \"Allele Definition\", "+
			"al._Allele_key as \"DoNotPrint\" "+
			"from ALL_Allele as al, "+
			"VOC_Term as vt, "+
			"MGI_Note as n, "+
                        "MGI_Notetype as nt, "+
                        "ACC_mgitype as an, "+
                        "MGI_notechunk as nc "+
			"where vt._Term_key = al._Allele_Type_key "+
			"and al._Allele_key = n._Object_key "+
			"and nt.noteType = 'Molecular' "+
                        "and nt._mgitype_key = n._mgitype_key "+
                        "and nt._notetype_key = n._notetype_key "+
                        "and an._mgitype_key = nt._mgitype_key "+
                        "and n._note_key = nc._note_key "+
			"and vt.term not in ('Not Applicable', 'Not Specified', 'QTL') "+
			likeStatement + 
			"order by nc.sequenceNum ";
                
		log.debug("in getPhenotypicAlleles");
                Results myResults=null;
                //try{
                    myResults = new Results(query, conn);
                //}catch(Exception e){
                //    e.printStackTrace();
                //}
		return myResults;
	}

	/**
	 * Gets the allele, and the number of records available for that mutation, from the MGI database.
	 * @param symbolList	an array of official symbols     
	 * @param conn        the database connection (it is a Sybase database)
	 * @throws            SQLException if a database error occurs
	 * @return            a String array of alleles for the mutants found that correspond to the official symbols passed in.
	 */
	public String[] getPhenotypicAlleleCount(String[] symbolList, Connection conn) throws SQLException {

		//
		// NOTICE THERE IS NO ';' at the end -- because this is querying a Sybase db 
		//
		//
		// This builds a statement for each official symbol passed in the symbolList
		// e.g., and (al.symbol = 'Cdx1' or al.symbol = 'CDX1')
		//

		log.debug("in getPhenotypicAlleleCount.  Number of symbols passed = "+symbolList.length);

		String likeStatement = null;
		if (symbolList.length > 0) {
			likeStatement = "and (al.symbol like '" + symbolList[0] + "%' ";
			for (int i=1; i<symbolList.length; i++) {
				likeStatement = likeStatement + 
						"or al.symbol like '" + 
						symbolList[i] + "%' ";
			}
			likeStatement = likeStatement + ") ";
		} else {
			likeStatement = "and al.symbol like 'NoSymbolsPassed%' ";
		}

		//log.debug("likeStatement = " + likeStatement);

		/*String query = 
			"select "+
			"(case when charindex('<', al.symbol) = 0 then "+
			"al.symbol else "+
			"substring(al.symbol, 1, charindex('<', al.symbol) - 1) end) as symbol, "+ 
			"count(*) "+
			"from ALL_Allele al, "+
			"VOC_term term, "+
			"MGI_Note_Allele_View n "+
			"where term. _Term_key = al._Allele_Type_key "+
			"and al._Allele_key = n._Object_key "+
			"and n.noteType = 'Molecular' "+
			"and term.term not in ('Not Applicable', 'Not Specified', 'QTL') "+
			likeStatement +
			"group by (case when charindex('<', al.symbol) = 0 then "+
			"al.symbol else "+
			"substring(al.symbol, 1, charindex('<', al.symbol) - 1) end) "+ 
			"order by al.symbol ";*/
                
                String query = 
			"select "+
			"(case when strpos(al.symbol,'<') = 0 then "+
			"al.symbol else "+
			"substring(al.symbol, 1, strpos( al.symbol,'<') - 1) end) as symbol, "+ 
			"count(*) "+
			"from ALL_Allele al, "+
			"VOC_term vt, "+
			"MGI_Note n, "+
                        "MGI_Notetype nt "+                        
			"where vt._Term_key = al._Allele_Type_key "+
			"and al._Allele_key = n._Object_key "+
			"and nt.noteType = 'Molecular' "+
                        "and nt._mgitype_key=n._mgitype_key "+
                        "and nt._notetype_key=n._notetype_key "+
			"and vt.term not in ('Not Applicable', 'Not Specified', 'QTL') "+
			likeStatement +
			"group by (case when strpos( al.symbol, '<') = 0 then "+
			"al.symbol else "+
			"substring(al.symbol, 1, strpos(al.symbol, '<') - 1) end) ";//+ 
			//"order by al.symbol ";
                
		String[] dataRow;
		List<String> jacksonMutants = new ArrayList<String>();

		// Set the timeout length
		log.debug("instantiating a new Results object and setting the timeout to 5 seconds");
		Results myResults = new Results();
		myResults.setQuery(query);
		myResults.setConnection(conn);
		//myResults.setTimeout(5);
		myResults.execute();
        	while((dataRow = myResults.getNextRow()) != null) {
			jacksonMutants.add(dataRow[0]);
        	}
		myResults.close();

        	String[] jacksonMutantsArray = (String[]) jacksonMutants.toArray(new String[jacksonMutants.size()]);
		Arrays.sort(jacksonMutantsArray);

		return jacksonMutantsArray;
	}


	/**
	 * Gets the knock outs that have been identified by a member of the INIA consortium.
	 * @param symbolList	an array of official symbols     
	 * @param conn        the database connection (it is a Sybase database)
	 * @throws            SQLException if a database error occurs
	 * @return            a Results object
	 */
	public Results getIniaKnockOuts(String[] symbolList, Connection conn) throws SQLException {
		//
		// This builds a statement for each official symbol passed in the symbolList
		// e.g., and (g.official_symbol = 'Cdx1' or g.official_symbol = 'CDX1')
		//

		String likeStatement = null;
		if (symbolList.length > 0) {
			likeStatement = "and (g.official_symbol like '" + symbolList[0] + "%' ";
			for (int i=1; i<symbolList.length; i++) {
				likeStatement = likeStatement + 
						"or g.official_symbol like '" + 
						symbolList[i] + "%' ";
			}
			likeStatement = likeStatement + ") ";
		} else {
			likeStatement = "and g.official_symbol like 'NoSymbolsPassed%' ";
		}

		String query = 
			"select g.official_symbol \"Gene Official Symbol\", "+ 
			"a.description \"Assay Description\", "+ 
			"ga.pubmed_id \"Pubmed ID\" "+ 
			"from inia_genes g, "+ 
			"assays a, "+ 
			"gene_assays ga "+ 
			"where ga.official_symbol = g.official_symbol "+ 
			"and ga.assay_id = a.assay_id "+ 
			likeStatement + 
			"order by g.official_symbol, a.description"; 

		log.debug("in getIniaKnockOuts");
		Results myResults = new Results(query, conn);
		return myResults;
	}

	/**
	 * Gets the official symbol, and the number of knockouts for that symbol, 
	 * that have been identified by a member of the INIA consortium.
	 * @param symbolList	an array of official symbols     
	 * @param conn        the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a String array of official symbols that have knockouts 
	 */   

	public String[] getIniaKnockOutCount(String[] symbolList, Connection conn) throws SQLException {
		//
		// This builds a statement for each official symbol passed in the symbolList
		// e.g., and (g.official_symbol = 'Cdx1' or g.official_symbol = 'CDX1')
		//

		String likeStatement = null;
		if (symbolList.length > 0) {
			likeStatement = "and (g.official_symbol like '" + symbolList[0] + "%' ";
			for (int i=1; i<symbolList.length; i++) {
				likeStatement = likeStatement + 
						"or g.official_symbol like '" + 
						symbolList[i] + "%' ";
			}
			likeStatement = likeStatement + ") ";
		} else {
			likeStatement = "and g.official_symbol like 'NoSymbolsPassed%' ";
		}

		String query = 
			"select g.official_symbol \"Gene Official Symbol\", "+ 
			"count(*) "+ 
			"from inia_genes g, "+ 
			"assays a, "+ 
			"gene_assays ga "+ 
			"where ga.official_symbol = g.official_symbol "+ 
			"and ga.assay_id = a.assay_id "+ 
			likeStatement + 
			"group by g.official_symbol "+
			"order by g.official_symbol"; 

		log.debug("in getIniaKnockOutCount");

		List<String> iniaKnockouts = new ArrayList<String>();

		String[] dataRow;
		Results myResults = new Results(query, conn);
        	while((dataRow = myResults.getNextRow()) != null) {
			iniaKnockouts.add(dataRow[0]);
        	}
		myResults.close();

        	String[] iniaKnockoutArray = (String[]) iniaKnockouts.toArray(new String[iniaKnockouts.size()]);
		Arrays.sort(iniaKnockoutArray);

		return iniaKnockoutArray;
	}

	/**
	 * Gets the official symbol, and the number of records.
	 * @param symbolList	an array of official symbols     
	 * @param conn        the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a String array of official symbols that have preference 
	 */

	public String[] getIniaAlcoholPreferenceCount(String[] symbolList, Connection conn) throws SQLException {
		//
		// This builds a statement for each official symbol passed in the symbolList
		// e.g., and (ap.official_symbol = 'Cdx1' or ap.official_symbol = 'CDX1')
		//

		String likeStatement = null;
		if (symbolList.length > 0) {
			likeStatement = "ap.official_symbol like '" + symbolList[0] + "%' ";
			for (int i=1; i<symbolList.length; i++) {
				likeStatement = likeStatement + 
						"or ap.official_symbol like '" + 
						symbolList[i] + "%' ";
			}
			likeStatement = likeStatement + " ";
		} else {
			likeStatement = "ap.official_symbol like 'NoSymbolsPassed%' ";
		}

		String query = 
			"select official_symbol \"Gene Official Symbol\", "+ 
			"count(*) "+
			"from alcohol_preferences ap "+ 
			"where "+ 
			likeStatement + 
			"group by official_symbol "+
			"order by official_symbol"; 

		log.debug("in getIniaAlcoholPreferenceCount");
		List<String> iniaPreferenceMutants = new ArrayList<String>();

		String[] dataRow;
		Results myResults = new Results(query, conn);
        	while((dataRow = myResults.getNextRow()) != null) {
			iniaPreferenceMutants.add(dataRow[0]);
        	}
		myResults.close();

        	String[] iniaPreferenceMutantsArray = 
			(String[]) iniaPreferenceMutants.toArray(new String[iniaPreferenceMutants.size()]);
		Arrays.sort(iniaPreferenceMutantsArray);

		return iniaPreferenceMutantsArray;
	}

	/**
	 * Gets the alcohol preference information collected by a member of the INIA consortium.
	 * @param symbolList	an array of official symbols     
	 * @param conn        the database connection (it is a Sybase database)
	 * @throws            SQLException if a database error occurs
	 * @return            a Results object
	 */
  	public Results getIniaAlcoholPreferences(String[] symbolList, Connection conn) throws SQLException {
		//
		// This builds a statement for each official symbol passed in the symbolList
		// e.g., and (ap.official_symbol = 'Cdx1' or ap.official_symbol = 'CDX1')
		//

		String likeStatement = null;
		if (symbolList.length > 0) {
			likeStatement = "ap.official_symbol like '" + symbolList[0] + "%' ";
			for (int i=1; i<symbolList.length; i++) {
				likeStatement = likeStatement + 
						"or ap.official_symbol like '" + 
						symbolList[i] + "%' ";
			}
			likeStatement = likeStatement + " ";
		} else {
			likeStatement = "ap.official_symbol like 'NoSymbolsPassed%' ";
		}

		String query = 
			"select official_symbol \"Gene Official Symbol\", "+ 
			"mutant Animal, "+ 
			"gender Gender, "+ 
			"type \"Wild Type or Mutant\", "+ 
			"three_percent \"3% ethanol\", "+ 
			"six_percent \"6% ethanol\", "+ 
			"nine_percent \"9% ethanol\", "+ 
			"twelve_percent \"12% ethanol\" "+ 
			"from alcohol_preferences ap "+ 
			"where "+ 
			likeStatement + 
			"order by mutant, gender, type"; 

		log.debug("in getIniaAlcoholPreferences");
		Results myResults = new Results(query, conn);
		return myResults;
	}

	
}
	
