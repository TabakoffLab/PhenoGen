package edu.ucdenver.ccp.PhenoGen.data; 

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.sql.DataSource;

import java.text.NumberFormat;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.ObjectHandler;

import edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier;
import edu.ucdenver.ccp.PhenoGen.util.DbUtils;
import edu.ucdenver.ccp.util.sql.Results;

// Had to change this when going to 11g.
// import oracle.jdbc.driver.OraclePreparedStatement;
import oracle.jdbc.*;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data required by the QTL tools.
 * This class handles Quantitative Trait Loci, which is one or more Quantitative Trait Locus(es)!  QTL here refers
 * to a list of regions in a genome.  Each region is called a locus.
 * @author Created by Cheryl Hornbaker 2006
 *
 */

public class QTL {

	private int qtl_list_id;
	private int created_by_user_id;
	private String qtl_list_name;
	private String organism;
	private Locus[] loci;
	private NumberFormat numberFormat = NumberFormat.getNumberInstance();
	private String sortColumn = "qtl_list_name";
	private String sortOrder = "A";

	private Logger log=null;
  
	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();

	public QTL () {
		log = Logger.getRootLogger();
	}

	public QTL (int qtl_list_id) {
		this.setQtl_list_id(qtl_list_id);
		log = Logger.getRootLogger();
	}

	public int getQtl_list_id() {
		return qtl_list_id; 
	}

	public void setQtl_list_id(int inInt) {
		this.qtl_list_id = inInt;
	}
  
	public int getCreated_by_user_id() {
		return created_by_user_id; 
	}

	public void setCreated_by_user_id(int inInt) {
		this.created_by_user_id = inInt;
	}
  
	public String getOrganism() {
		return organism; 
	}
  
	public void setOrganism(String inString) {
		this.organism = inString;
	}
  
	public String getQtl_list_name() {
		return qtl_list_name; 
	}
  
	public void setQtl_list_name(String inString) {
		this.qtl_list_name = inString;
	}
  
	public Locus[] getLoci() {
  		return loci;
	}
  
	public void setLoci(Locus[] inArray) {
  		this.loci = inArray;
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


        public String getQtl_list_name(int qtl_list_id, DataSource pool) throws SQLException {

        	//log.debug("in getQtl_list_name");

        	String query =
                	"select qtl_list_name "+
			"from qtl_lists "+
                	"where qtl_list_id = ?";
                Results myResults = null;
                Connection conn=null;
                String qtl_list_name ="";
                try{
                    conn=pool.getConnection();
                    myResults = new Results(query, qtl_list_id, conn);
                    qtl_list_name = myResults.getStringValueFromFirstRow();
                    myResults.close();
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

        	return qtl_list_name;
	}
        
        /**
         * Gets the name of a QTL list.
         * @param qtl_list_id	the identifier of the QTL list
         * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
         * @return              an array of QTL objects 
         */
	public String getQtl_list_name(int qtl_list_id, Connection conn) throws SQLException {

        	//log.debug("in getQtl_list_name");

        	String query =
                	"select qtl_list_name "+
			"from qtl_lists "+
                	"where qtl_list_id = ?";

                Results myResults = new Results(query, qtl_list_id, conn);

                String qtl_list_name = myResults.getStringValueFromFirstRow();

                myResults.close();

        	return qtl_list_name;
	}

        
        public QTL[] getQTLLists(int user_id, String organism, DataSource pool) throws SQLException {

        	//log.debug("in getQTLLists");

        	String query =
                	"select qtl_list_id, qtl_list_name, organism, created_by_user_id "+
			"from qtl_lists "+
                	"where created_by_user_id = ? ";

		if (!organism.equals("All")) {
			query = query + 
			"and organism = ?";
		}
		query = query + " order by qtl_list_name ";
                Results myResults=null;
                Connection conn=null;
                try{
                    conn=pool.getConnection();
                    myResults = (!organism.equals("All") ?  new Results(query, new Object[] {user_id, organism}, conn) : 
                						new Results(query, user_id, conn));
                    myResults.close();
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
		QTL[] myQTLArray = setupQTLValues (myResults);

		
   		return myQTLArray;
	}
        
        /**
         * Gets an array of QTL objects created by a user.
         * @param user_id	the identifier of the user
         * @param organism	the two-character abbreviation for an organism
         * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
         * @return              an array of QTL objects 
         */

	public QTL[] getQTLLists(int user_id, String organism, Connection conn) throws SQLException {

        	//log.debug("in getQTLLists");

        	String query =
                	"select qtl_list_id, qtl_list_name, organism, created_by_user_id "+
			"from qtl_lists "+
                	"where created_by_user_id = ? ";

		if (!organism.equals("All")) {
			query = query + 
			"and organism = ?";
		}
		query = query + " order by qtl_list_name ";

                Results myResults = (!organism.equals("All") ?  new Results(query, new Object[] {user_id, organism}, conn) : 
                						new Results(query, user_id, conn));

		QTL[] myQTLArray = setupQTLValues (myResults);

		myResults.close();
   		return myQTLArray;
	}

        
        public QTL getQTLList(int qtl_list_id, DataSource pool) throws SQLException {

        	//log.debug("in getQTLList");

        	String query =
                	"select qtl_list_id, qtl_list_name, organism, created_by_user_id "+
			"from qtl_lists ql "+
                	"where ql.qtl_list_id = ? ";

		//log.debug("query = "+query);
                Results myResults =null;
                Connection conn=null;
                QTL myQTL =null;
                try{
                    conn=pool.getConnection();
                    myResults = new Results(query, qtl_list_id, conn);
                    myQTL = setupQTLValues (myResults)[0];
                    myResults.close();
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
		myQTL.setLoci(getLociForQTLList(myQTL.getQtl_list_id(), pool));

		return myQTL;
	}
        
        /**
         * Gets the details for a specific QTL list
         * @param qtl_list_id	the identifier of the QTL list
         * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
         * @return a QTL object 
         */

	public QTL getQTLList(int qtl_list_id, Connection conn) throws SQLException {

        	//log.debug("in getQTLList");

        	String query =
                	"select qtl_list_id, qtl_list_name, organism, created_by_user_id "+
			"from qtl_lists ql "+
                	"where ql.qtl_list_id = ? ";

		//log.debug("query = "+query);

                Results myResults = new Results(query, qtl_list_id, conn);

		QTL myQTL = setupQTLValues (myResults)[0];

                myResults.close();

		myQTL.setLoci(getLociForQTLList(myQTL.getQtl_list_id(), conn));

		return myQTL;
	}

        /**
         * Sets up the values for QTL array.
         * @param myResults	a Results object
         * @return              an array of QTL objects 
         */

	public QTL[] setupQTLValues (Results myResults) {
		List<QTL> myQTLList = new ArrayList<QTL>();

                String[] dataRow;
                if(myResults!=null){
                    while ((dataRow = myResults.getNextRow()) != null) {
                            QTL thisQtl = new QTL();
                            thisQtl.setQtl_list_id(Integer.parseInt(dataRow[0]));
                            thisQtl.setQtl_list_name(dataRow[1]);
                            thisQtl.setOrganism(dataRow[2]);
                            thisQtl.setCreated_by_user_id(Integer.parseInt(dataRow[3]));
                            myQTLList.add(thisQtl);
                    }
                }
		QTL[] myQTLArray = (QTL[]) myObjectHandler.getAsArray(myQTLList, QTL.class);

   		return myQTLArray;
	}

        /**
         * Sets up the values for an array of Loci.
         * @param myResults	a Results object
         * @return              an array of Locus objects 
         */

	public Locus[] setupLocusValues (Results myResults) {
		List<Locus> myLocusList = new ArrayList<Locus>();

                String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {
			Locus thisLocus = this.new Locus();
			thisLocus.setLocus_name(dataRow[0]);
			thisLocus.setChromosome(dataRow[1]);
			thisLocus.setRange_start(Double.parseDouble(dataRow[2]));
			thisLocus.setRange_end(Double.parseDouble(dataRow[3]));
			myLocusList.add(thisLocus);
		}

		Locus[] myLocusArray = (Locus[]) myObjectHandler.getAsArray(myLocusList, Locus.class);

   		return myLocusArray;
	}

        
        public QTL[] getQTLListsForUser(int user_id, DataSource pool) throws SQLException {

        	log.debug("in getQTLListsForUser");

        	String query =
                	"select qtl_list_id, qtl_list_name, organism, created_by_user_id "+
			"from qtl_lists "+
			"where created_by_user_id = ? "+
			"order by qtl_list_id";

		//log.debug("query = "+query);
                Results myResults=null;
                Connection conn=null;
                QTL[] myQTLArray =new QTL[0];
                try{
                    conn=pool.getConnection();
                    myResults = new Results(query, user_id, conn);
                    myQTLArray = setupQTLValues(myResults);
                    //log.debug("there are = " + myQTLArray.length + " QTLLists");
                    //log.debug("myQTLArray = " + myQTLArray[0]);
                    myResults.close();
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
		for (QTL thisQTL : myQTLArray) {
			thisQTL.setLoci(getLociForQTLList(thisQTL.getQtl_list_id(), pool));
		}
		//log.debug("myLoci = " + myQTLArray[0].getLoci()[0]);

		return myQTLArray;
	}
        
        /**
         * Gets an array of QTL objects created by a user.
         * @param user_id	the identifier of the user
         * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
         * @return              an array of QTL objects 
         */

	public QTL[] getQTLListsForUser(int user_id, Connection conn) throws SQLException {

        	log.debug("in getQTLListsForUser");

        	String query =
                	"select qtl_list_id, qtl_list_name, organism, created_by_user_id "+
			"from qtl_lists "+
			"where created_by_user_id = ? "+
			"order by qtl_list_id";

		//log.debug("query = "+query);

                Results myResults = new Results(query, user_id, conn);
		QTL[] myQTLArray = setupQTLValues(myResults);
		log.debug("there are = " + myQTLArray.length + " QTLLists");
		//log.debug("myQTLArray = " + myQTLArray[0]);
                myResults.close();

		for (QTL thisQTL : myQTLArray) {
			thisQTL.setLoci(getLociForQTLList(thisQTL.getQtl_list_id(), conn));
		}
		//log.debug("myLoci = " + myQTLArray[0].getLoci()[0]);

		return myQTLArray;
	}

        
        public Locus[] getLociForQTLList(int qtl_list_id, DataSource pool) throws SQLException {

        	//log.debug("in getLociForQTLList");

        	String query =
                	"select qtl_name, chromosome, range_start, range_end "+
			"from qtls q "+
			"where qtl_list_id = ? "+
			"order by qtl_name";

		//log.debug("query = "+query);
                Results myResults = null;
                Connection conn=null;
                Locus[] myLocusArray = new Locus[0];
                try{
                    conn=pool.getConnection();
                    myResults = new Results(query, qtl_list_id, conn);
                    myLocusArray = setupLocusValues(myResults);

                    myResults.close();
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
		return myLocusArray;
	}
        
        /**
         * Gets the loci for this qtl_list
         * @param qtl_list_id	the identifier of the qtl_list
         * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
         * @return              an array of QTL objects 
         */

	public Locus[] getLociForQTLList(int qtl_list_id, Connection conn) throws SQLException {

        	//log.debug("in getLociForQTLList");

        	String query =
                	"select qtl_name, chromosome, range_start, range_end "+
			"from qtls q "+
			"where qtl_list_id = ? "+
			"order by qtl_name";

		//log.debug("query = "+query);

 		Results myResults = new Results(query, qtl_list_id, conn);
		Locus[] myLocusArray = setupLocusValues(myResults);

		myResults.close();
		return myLocusArray;
	}

        /**
         * Creates a record in the qtl_lists table.
         * @param myQTL	the QTL object containing the values
         * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
         * @return	the identifier of the QTL list that was created
         */
	public int createQTLList (QTL myQTL, Connection conn) throws SQLException {

        	log.debug("in createQTLList");

        	qtl_list_id = myDbUtils.getUniqueID("qtl_lists_seq", conn);

        	log.debug("qtl_list_id = "+qtl_list_id);

        	String query =
                	"insert into qtl_lists "+
                	"(qtl_list_id, qtl_list_name, created_by_user_id, organism) values "+
                	"(?, ?, ?, ?)";

        	PreparedStatement pstmt = null;
		conn.setAutoCommit(false);
        	try {
                	pstmt = conn.prepareStatement(query,
                                        	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                        	ResultSet.CONCUR_UPDATABLE);
                	pstmt.setInt(1, qtl_list_id);
                	pstmt.setString(2, myQTL.getQtl_list_name());
                	pstmt.setInt(3, myQTL.getCreated_by_user_id());
                	pstmt.setString(4, myQTL.getOrganism());

                	pstmt.executeUpdate();
                	myQTL.setQtl_list_id(qtl_list_id);

                	createLoci(myQTL, conn);
			conn.commit();

        	} catch (SQLException e) {
                	log.error("in exception of createQTLList", e);
			conn.rollback();
                	throw e;
        	} finally {
                	pstmt.close();
			conn.setAutoCommit(true);
		}
        	return qtl_list_id;
	}

        /**
         * Creates records in the QTLs table.  Each record is a locus on the genome.
         * @param myQTL	the QTL object containing the values
         * @param conn	the database connection
	 * @throws	SQLException if a database error occurs
         */

	public void createLoci(QTL myQTL, Connection conn) throws SQLException {

        	log.debug("in createLoci");
        	String query =
                	"insert into qtls "+
                	"(qtl_list_id, qtl_name, chromosome, range_start, range_end) "+
                	"values "+
                	"(?, ?, ?, ?, ?)";

        	PreparedStatement pstmt = conn.prepareStatement(query,
                                        	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                        	ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, myQTL.getQtl_list_id());

                //
                // insert each of the QTLs
                //
                if (myQTL.getLoci() != null) {
			for (QTL.Locus thisLocus : myQTL.getLoci()) {
                                pstmt.setString(2, thisLocus.getLocus_name());
                                pstmt.setString(3, thisLocus.getChromosome());
                                pstmt.setDouble(4, thisLocus.getRange_start());
                                pstmt.setDouble(5, thisLocus.getRange_end());
                                pstmt.executeUpdate();
                        }
                }
                pstmt.close();
	}

	/** 
	 * Gets the columns containing the correlation values 
	 * @param thisEQTL	an EQTL object
	 * @return            a List of Strings containing the correlation information
         */
	public List<String> getCommonEndColumns(QTL.EQTL thisEQTL) {
		List<String> commonEnd = new ArrayList<String>();
		String gene_mb = (new Double(thisEQTL.getGene_mb()).isNaN() ? 
					"" : new Double(thisEQTL.getGene_mb()).toString());
		commonEnd.add(thisEQTL.getTissue());
		commonEnd.add(thisEQTL.getGene_chromosome());
                commonEnd.add(gene_mb);
                commonEnd.add(Double.toString(thisEQTL.getLod_score()));
                commonEnd.add(thisEQTL.getP_value());
                commonEnd.add(thisEQTL.getFdr());
                commonEnd.add(thisEQTL.getMarker());
                commonEnd.add(thisEQTL.getMarker_chromosome());
                commonEnd.add(Double.toString(thisEQTL.getMarker_mb()));
		return commonEnd;
	}

	/** 
	 * Gets the columns containing the correlation values 
	 * @param indexHash	contains name of the column and the location of that column in the geneArray
         * @param identifier	the gene identifier 
         * @param myGeneArray	the array of gene identifiers that don't have eQTL records, but do have statistics values
	 * @return            a List of Strings containing the correlation information
         */
	public List<String> getCorrelationValues(Hashtable indexHash, String identifier, GeneList.Gene[] myGeneArray) {
		GeneList.Gene myGene = new GeneList().new Gene();
		List<String> correlationList = new ArrayList<String>();

		String coefficientValue = myGene.getStatisticValue(myGeneArray,
                				identifier, ((Integer) indexHash.get("coefficientIdx")).intValue());
		String rawPValue = myGene.getStatisticValue(myGeneArray,
                				identifier, ((Integer) indexHash.get("rawPValueIdx")).intValue());
		String adjPValue = myGene.getStatisticValue(myGeneArray,
                				identifier, ((Integer) indexHash.get("adjPValueIdx")).intValue());
		correlationList.add(coefficientValue);
		correlationList.add(rawPValue);
                correlationList.add(adjPValue);
		return correlationList;
	}

	public void deleteQtlList(int qtlListID, Connection conn) throws SQLException {
  	
		log.info("in deleteQtlList");

		String[] query = new String[2];
  		query[0] =
			"delete from qtls "+
			"where qtl_list_id = ?";
    
  		query[1] =
                	"delete from qtl_lists "+
                	"where qtl_list_id = ?";

  		PreparedStatement pstmt = null;

                for (int i=0; i<query.length; i++) {
			log.debug("i = " + i + ", query = " + query[i]);
  			pstmt = conn.prepareStatement(query[i],
                            	ResultSet.TYPE_SCROLL_INSENSITIVE,
                            	ResultSet.CONCUR_UPDATABLE);

                        pstmt.setInt(1, qtlListID);

                        pstmt.executeUpdate();
                }
		pstmt.close();
	}


	public boolean equals(Object myQTLObject) {
		QTL myQTL = (QTL) myQTLObject; 
/*
		if (myQTL.getLocus_name() != null && 
			myQTL.getLocus_name().equals(this.getLocus_name())) {
			return true;
		} else 
*/
		if ((myQTL.getQtl_list_id() != 0 && 
			myQTL.getQtl_list_id() != -99) && 
			(myQTL.getQtl_list_id() == this.getQtl_list_id())) {
			return true;
		} else {
			return false;
		}	
	}
	/*
	public int hashCode(List list) {
  		int hashCode = 1;
		Iterator i = list.iterator();
  		while (i.hasNext()) {
      			Object obj = i.next();
      			hashCode = 31*hashCode + (obj==null ? 0 : obj.hashCode());
  		}
		return hashCode;
	}
	*/

	public String toString() {
		String qtlInfo = "Qtl List Name = " + this.qtl_list_name;
		return qtlInfo;
	}

        public void print() {
                log.debug(toString());
        }

	/**
	 * Compares QTLs based on different fields.
	 */
	public class QTLSortComparator implements Comparator<QTL> {
		int compare;
        	QTL qtl1, qtl2;

        	public int compare(QTL object1, QTL object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				qtl1 = object1;
	                	qtl2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				qtl2 = object1;
	                	qtl1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

                	//log.debug("qtl1 = "+qtl1+ ", qtl2 = "+qtl2);

			if (sortColumn.equals("qtlListName")) {
                		compare = qtl1.getQtl_list_name().compareTo(qtl2.getQtl_list_name());
			} else if (sortColumn.equals("organism")) {
				compare = qtl1.getOrganism().compareTo(qtl2.getOrganism());
			}
                	return compare;
		}
	}

	public QTL[] sortQTLs (QTL[] myQTLs, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myQTLs, new QTLSortComparator());
		return myQTLs;
	}

	public class Locus {
		private String locus_name;
		private String chromosome;
		private double range_start;
		private double range_end;

		public Locus() {
			log = Logger.getRootLogger();
		}

		public Locus(String locus_name) {
			this.setLocus_name(locus_name);
			log = Logger.getRootLogger();
			//log.debug("just created Locus object with locus_name = "+this.getLocus_name());
		}

		public String getLocus_name() {
			return locus_name;
		}

		public void setLocus_name(String inString) {
			this.locus_name = inString;
		}

		public String getChromosome() {
			return chromosome;
		}
  
		public void setChromosome(String inString) {
			this.chromosome = inString;
		}
  
		public String getRange_startFormatted() {
			return numberFormat.format(getRange_start());
		}

		public double getRange_start() {
  			return range_start;
		}
  
		public void setRange_start(double inDouble) {
  			this.range_start = inDouble;
		}
  
		public String getRange_endFormatted() {
  			return numberFormat.format(getRange_end());
		}

		public double getRange_end() {
  			return range_end;
		}
  
		public void setRange_end(double inDouble) {
  			this.range_end = inDouble;
		}

		public String toString() {
			String locusInfo = "Locus = " + this.getLocus_name() + ", chromosome = " + 
				this.getChromosome();
			return locusInfo;
		}

        	public void print() {
                	log.debug(toString());
        	}

  
	}
  

	/**
	 * Class for handling information related to a particular expression QTL. 
	 */
	public class EQTL implements Comparable {
		private String identifier;
		private String gene_name;
		private String gene_chromosome;
		private double gene_mb;
		private double lod_score;
		private String p_value;
		private String fdr;
		private String marker;
		private String marker_chromosome;
		private double marker_mb;
		private double upper_limit;
		private double lower_limit;
		private int num_gene_symbols;
		private String tissue;
		private String organism;
	
		public EQTL() {
			log = Logger.getRootLogger();
		}

		public EQTL (String identifier) {
			this.setIdentifier(identifier);
			log = Logger.getRootLogger();
		}

		public void setIdentifier(String inString) {
			identifier = inString;
		}

		public String getIdentifier() {
			return identifier;
		}
	
		public void setGene_name(String inString) {
			gene_name = inString;
		}

		public String getGene_name() {
			return gene_name;
		}
	
		public void setGene_chromosome(String inString) {
			gene_chromosome = inString;
		}

		public String getGene_chromosome() {
			return gene_chromosome;
		}
	
		public void setGene_mb(double inDouble) {
			gene_mb = inDouble;
		}

		public double getGene_mb() {
			return gene_mb;
		}
	
		public void setLod_score(double inDouble) {
			lod_score = inDouble;
		}

		public double getLod_score() {
			return lod_score;
		}
	
		public void setP_value(String inString) {
			p_value = inString;
		}

		public String getP_value() {
			return p_value;
		}
	
		public void setFdr(String inString) {
			fdr = inString;
		}

		public String getFdr() {
			return fdr;
		}
	
		public void setMarker(String inString) {
			marker = inString;
		}

		public String getMarker() {
			return marker;
		}
	
		public void setMarker_chromosome(String inString) {
			marker_chromosome = inString;
		}

		public String getMarker_chromosome() {
			return marker_chromosome;
		}
	
		public void setMarker_mb(double inDouble) {
			marker_mb = inDouble;
		}

		public double getMarker_mb() {
			return marker_mb;
		}
	
		public void setUpper_limit(double inDouble) {
			upper_limit = inDouble;
		}

		public double getUpper_limit() {
			return upper_limit;
		}
	
		public void setLower_limit(double inDouble) {
			lower_limit = inDouble;
		}

		public double getLower_limit() {
			return lower_limit;
		}
	
		public void setNum_gene_symbols(int inInt) {
			num_gene_symbols = inInt;
		}

		public int getNum_gene_symbols() {
			return num_gene_symbols;
		}

		public void setTissue(String inString) {
			tissue = inString;
		}

		public String getTissue() {
			return tissue;
		}
	
		public void setOrganism(String inString) {
			organism = inString;
		}

		public String getOrganism() {
			return organism;
		}

        	/**
         	* Returns the genesToDisplay
         	* @param arrayOfEQTLs	an array of eQTL objects 
         	* @param setOfIdentifiers	a Set of Identifiers that have relatedIdentifers already populated
         	* @param organism	the organism
         	* @return              a Set of Identifiers representing genes to display on the chromosome graph
         	*/

		public LinkedHashSet<Identifier> getGenesToDisplay(QTL.EQTL[] arrayOfEQTLs,
								//LinkedHashSet<Identifier> setOfGenes,
								LinkedHashSet<Identifier> setOfIdentifiers,
								String organism) {	
			log.debug("in getGenesToDisplay");
			//log.debug("in getGenesToDisplay. setOfIdentifiers = "); myDebugger.print(setOfIdentifiers);
			//log.debug("arrayOfEQTLs = "); myDebugger.print(arrayOfEQTLs);
			LinkedHashSet<Identifier> genesToDisplay = new LinkedHashSet<Identifier>();
			// Iterate through the set of eQTL objects
			// and find their Affy Mouse 430 2.0 and CodeLink Rat array identifiers
			// and gene symbol
			// and match them to the eQTL identifier
			if (arrayOfEQTLs != null && arrayOfEQTLs.length > 0) {
				for (int i=0; i<arrayOfEQTLs.length; i++) {
					QTL.EQTL eQTL = arrayOfEQTLs[i];
					// Go through the setOfIdentifiers to match the chip ID to the original ID
					for (Iterator itr=setOfIdentifiers.iterator(); itr.hasNext();) {
						Identifier id = (Identifier) itr.next();
						//log.debug("id here = "+id.getIdentifier() + ", and useForEQTLMatch = " + id.getUseForEQTLMatch()); 
						//log.debug("id maps to EQTLChip = " +id.mapsToEQTLChip(eQTL, organism));
						//log.debug("eQTL.getIdentifier() = "+eQTL.getIdentifier());
						//if (id.mapsToEQTLChip(eQTL, organism)) {
                                		if ((id.getUseForEQTLMatch() && id.getIdentifier().equals(eQTL.getIdentifier())) || 
							(!id.getUseForEQTLMatch() && id.mapsToEQTLChip(eQTL, organism))) {
								/*
								log.debug("setting geneAnnotation.  id = "+id.getIdentifier() +
									", eQTL = "+eQTL.getIdentifier() +
									", eQTL Gene Name = "+eQTL.getGene_name() +
									", geneChromosome = "+eQTL.getGene_chromosome() +
									", genemb = "+eQTL.getGene_mb() + 
									", genemb * 1million = "+eQTL.getGene_mb() * 1000000);
								*/
							String geneAnnotation = eQTL.getGene_name() +
										"(" + id.getIdentifier() + ")" +
										" -- " +
										eQTL.getGene_chromosome() + "|||" + 
										eQTL.getGene_mb() * 1000000;
									id.setChromosomeMapGeneAnnotation(geneAnnotation);
							//log.debug("1 id here = "+id.getIdentifier() + ", and useForEQTLMatch = " + id.getUseForEQTLMatch() + " just set geneAnnotation to "+id.getChromosomeMapGeneAnnotation());
							genesToDisplay.add(id);
						}
					}
				}
			}
			return genesToDisplay;
		}

        	/**
         	* Returns the transToDisplay
         	* @param arrayOfEQTLs	an array of eQTL objects 
         	* @param setOfIdentifiers	a Set of Identifiers that have relatedIdentifers already populated
         	* @param organism	the organism
         	* @param pValue	the p-value threshold
         	* @param constraint	the region constraint
         	* @return              a Set of Identifiers representing transcription controls to display on the chromosome graph
         	*/

		public LinkedHashSet<Identifier> getTransToDisplay(QTL.EQTL[] arrayOfEQTLs, 
								LinkedHashSet setOfIdentifiers, 
								String organism, 
								double pValue,
								String constraint) {	
			log.debug("in getTransToDisplay. pValue = " + pValue);
			log.debug("in getTransToDisplay. constraint = " + constraint);
			log.debug("in getTransToDisplay. organism = " + organism);
			log.debug("here");
			//log.debug("in getTransToDisplay. pValue = " + pValue + ", and setOfIdentifiers = "); myDebugger.print(setOfIdentifiers);
			LinkedHashSet<Identifier> transToDisplay = new LinkedHashSet<Identifier>();
			// Iterate through the set of eQTL objects
			// and find their Affy Mouse 430 2.0 and CodeLink Rat array identifiers
			// and gene symbol
			// and match them to the eQTL identifier
			if (arrayOfEQTLs != null && arrayOfEQTLs.length > 0) {
				//log.debug("arrayOfEQTLs is not null.  It's length is "+arrayOfEQTLs.length);
				for (int i=0; i<arrayOfEQTLs.length; i++) {
					QTL.EQTL eQTL = arrayOfEQTLs[i];
					// Go through the setOfIdentifiers to match the chip ID to the original ID
					for (Iterator itr=setOfIdentifiers.iterator(); itr.hasNext();) {
						Identifier id = (Identifier) itr.next();
						/*
                                		log.debug("mapsToEQTL? = " + id.mapsToEQTLChip(eQTL, organism)); 
                                		log.debug("userForEQTLMatch? = " + id.getUseForEQTLMatch()); 
                                		log.debug("eQTL.identifier  = " + eQTL.getIdentifier()); 
						*/
                                		if ((id.getUseForEQTLMatch() && id.getIdentifier().equals(eQTL.getIdentifier())) || 
							(!id.getUseForEQTLMatch() && id.mapsToEQTLChip(eQTL, organism))) {
							if (eQTL.getP_value() != null) {
                                				log.debug("eQTL.getP_value()  = " + eQTL.getP_value()); 
								double thisPValue = (eQTL.getP_value().equals("<0.000001") ?
										Double.parseDouble("1.E-100") :
										Double.parseDouble(eQTL.getP_value()));
								if (thisPValue < pValue) { 
									/*
									log.debug("setting TransAnnotation.  id = "+id.getIdentifier() +
										", eQTL = "+eQTL.getIdentifier() +
										", eQTL Gene Name = "+eQTL.getGene_name() +
										", markerChromosome = "+eQTL.getMarker_chromosome() +
										", mb = "+eQTL.getMarker_mb());
									*/
									if (constraint.equals("none")) {
										String transAnnotation = id.getIdentifier() + " -- " +
												eQTL.getMarker_chromosome() + "|||" + 
												eQTL.getMarker_mb() * 1000000;
										if (id.getChromosomeMapTransAnnotation()==null) {
											id.setChromosomeMapTransAnnotation(transAnnotation);
										} else if (id.getChromosomeMapTransAnnotation().indexOf(transAnnotation) < 0) {
											id.setChromosomeMapTransAnnotation(id.getChromosomeMapTransAnnotation() + 
												", "+ 
												transAnnotation);
										}
									}
									transToDisplay.add(id);
								}
							}
						}
					}
				}
			} else {
				log.debug("arrayOfEQTLs is null");
			}
			return transToDisplay;
		}

        	/**
         	* Returns the genesInRegion
         	* @param eQTLs	an array of eQTL objects 
         	* @param setOfIdentifiers	a Set of Identifiers that have relatedIdentifers already populated
         	* @param locus	a locus object
         	* @param organism	the organism
         	* @return              a Set of Identifiers representing genes within the selected region
         	*/
		public LinkedHashSet<Identifier> getGenesInRegion(QTL.EQTL[] eQTLs, 
								LinkedHashSet setOfIdentifiers, 
								QTL.Locus locus,
								String organism) {
			//log.debug("in getGenesInRegion. setOfIdentifiers = "); myDebugger.print(setOfIdentifiers);
			LinkedHashSet<Identifier> genesInRegion = new LinkedHashSet<Identifier>();
			// Iterate through the set of eQTL objects
			// and find their Affy Mouse 430 2.0 and CodeLink Rat array identifiers
			// and gene symbol
			// and match them to the eQTL identifier
			for (int i=0; i<eQTLs.length; i++) {
				QTL.EQTL eQTL = eQTLs[i];

				/*
				log.debug("eQTL.gene_chromo = "+eQTL.getGene_chromosome() + "and gene_mb = "+eQTL.getGene_mb() +
						"times 1 million = " + eQTL.getGene_mb() * 1000000 +
                                        	", and locus.chromo = "+ locus.getChromosome() +
                                        	", and start = "+locus.getRange_start() +
                                        	", and end = "+locus.getRange_end()); 
				*/

				if (eQTL.isInRegion(locus)) {
                        		for (Iterator itr=setOfIdentifiers.iterator(); itr.hasNext();) {
                                		Identifier id = (Identifier) itr.next();
                                        	//if (id.mapsToEQTLChip(eQTL, organism)) {
                                		if ((id.getUseForEQTLMatch() && id.getIdentifier().equals(eQTL.getIdentifier())) || 
							(!id.getUseForEQTLMatch() && id.mapsToEQTLChip(eQTL, organism))) {
                                        		id.setChromosomeMapGeneAnnotation(eQTL.getGene_name() + 
                                                					"(" + id.getIdentifier() + ")" +
                                                                                	" -- " + eQTL.getGene_chromosome() +
                                                                                	"|||" +
                                                                                	eQTL.getGene_mb() * 1000000);
							//log.debug("adding this guy to genesInRegion");
                                                	genesInRegion.add(id);
						}
					}
				}
			}
			return genesInRegion;
		}

        	/**
         	* Returns the transInRegion
         	* @param eQTLs	an array of eQTL objects 
         	* @param setOfIdentifiers	a Set of Identifiers that have relatedIdentifers already populated
         	* @param locus	a Locus object
         	* @param organism	the organism
         	* @param eQTLPValue	the p-value threshold
         	* @return              a Set of Identifiers representing transcription controls within the selected region
         	*/
		public LinkedHashSet<Identifier> getTransInRegion(QTL.EQTL[] eQTLs, 
								LinkedHashSet setOfIdentifiers, 
								QTL.Locus locus,
								String organism, 
								double eQTLPValue) {	
			//log.debug("in getTransInRegion eQTLPValue = " + eQTLPValue);
			//log.debug("eQTLs =  "); myDebugger.print(eQTLs);
			//log.debug("setOfIdentifiers =  "); myDebugger.print(setOfIdentifiers);
			LinkedHashSet<Identifier> transInRegion = new LinkedHashSet<Identifier>();
			// Iterate through the set of eQTL objects
			// and find their Affy Mouse 430 2.0 and CodeLink Rat array identifiers
			// and gene symbol
			// and match them to the eQTL identifier
			for (int i=0; i<eQTLs.length; i++) {
				QTL.EQTL eQTL = eQTLs[i];

				/*
				log.debug("eQTL identifier = "+eQTL.getIdentifier() +
					" and gene name = "+eQTL.getGene_name());
				log.debug("eQTL marker chrom = "+eQTL.getMarker_chromosome() +
					" and locus chrom = "+locus.getChromosome());
				*/
				if (eQTL.isInRegion(locus, eQTLPValue)) {
                                	// If the transcription control is within the region, then
                                	// Go through the setOfIdentifiers to match the chip ID to the original ID
                                	for (Iterator itr=setOfIdentifiers.iterator(); itr.hasNext();) {
                                		Identifier id = (Identifier) itr.next();
						//if (id.mapsToEQTLChip(eQTL, organism)) {
                                		if ((id.getUseForEQTLMatch() && id.getIdentifier().equals(eQTL.getIdentifier())) || 
							(!id.getUseForEQTLMatch() && id.mapsToEQTLChip(eQTL, organism))) {
							String transAnnotation = eQTL.getGene_name() + 
                                                				"(" + id.getIdentifier() + ")" + 
                                                                        	" -- " + eQTL.getMarker_chromosome() + 
                                                                        	"|||" + 
                                                                        	eQTL.getMarker_mb() * 1000000;
							id.setChromosomeMapTransAnnotation(transAnnotation);
                                                	log.debug("adding this guy to transInRegion");
							transInRegion.add(id);
						}
					}
				}
			}
			return transInRegion;
		}

		/** 
	 	* Gets the rows for the EQTL Results page that have eQTL records and meet all the criteria.
         	* @param correlation	Whether the correlation columns are being displayed
	 	* @param myEQTLs	Array of EQTL objects for this gene list 
	 	* @param inGeneList	true if the row should exist in the gene list
	 	* @param meetPValue	true if the row should meet the eQTL p-value criteria
	 	* @param inRegion	true if the row is in the selected region 
	 	* @param eQTLPValue	the eQTL p-value selected
	 	* @param constraint	the constraint chosen for displaying the rows
         	* @param myGeneArray	the array of gene identifiers from a gene list
         	* @param selectedLoci	an array of Locus objects 
	 	* @param indexHash	contains name of the column and the location of that column in the geneArray
	 	* @return            a List of String arrays containing the rows for the table 
         	*/

		public List<String[]> getRowsWithEQTL(boolean correlation, QTL.EQTL[] myEQTLs, 
							boolean inGeneList, boolean meetPValue, boolean inRegion, 
							Double eQTLPValue, String constraint, GeneList.Gene[] myGeneArray,
							QTL.Locus[] selectedLoci, Hashtable indexHash) {

			log.debug("in getRowsWithEQTL");
			List<String[]> rowList = new ArrayList<String[]>();

			//log.debug("correlation = "+correlation); 
			//log.debug("constraint = "+constraint); 
			//log.debug("myGeneArray = "); myDebugger.print(myGeneArray);
			//log.debug("myEQTLs = "); myDebugger.print(myEQTLs);
			//log.debug("indexHash = "); myDebugger.print(indexHash);

			Arrays.sort(myGeneArray);

			myEQTLs = sortEQTLs(myEQTLs, "gene_name", "A");

			for (QTL.EQTL thisEQTL : myEQTLs) {
				//log.debug("myEQTLs.id = "+thisEQTL.getIdentifier());
				List<String> commonStart = new ArrayList<String>();
				List<String> finalList = new ArrayList<String>();

				String identifierToPrint = thisEQTL.getIdentifier() + (thisEQTL.getNum_gene_symbols() > 1 ? " (1)" : "");
				if (thisEQTL.getP_value() != null) {
                			Double thisPValue = (thisEQTL.getP_value().equals("<0.000001") ?
                                                                	.0000001 :
                                                                	Double.parseDouble(thisEQTL.getP_value()));
                        		if (inGeneList) {
						//log.debug("inGeneList");
                        			if (!meetPValue || (meetPValue && thisPValue < eQTLPValue)) {
                                			if (!inRegion || inRegion && thisEQTL.isInRegion(selectedLoci, eQTLPValue, constraint)) {
                                        			if (Arrays.binarySearch(myGeneArray,new GeneList().new Gene(thisEQTL.getIdentifier())) >= 0) {
									log.debug("1");
									commonStart.add("*");
									commonStart.add(identifierToPrint);
									commonStart.add(thisEQTL.getGene_name());
									finalList.addAll(commonStart);
									if (correlation) { 
										finalList.addAll(getCorrelationValues(
												indexHash, thisEQTL.getIdentifier(), myGeneArray));
									}
									finalList.addAll(getCommonEndColumns(thisEQTL));
								} //else log.debug("2"); 
							} //else log.debug("3");
						} //else log.debug("4");
					} else {
						//log.debug("not inGeneList");
                        			if (!meetPValue || (meetPValue && thisPValue < eQTLPValue)) {
                                			if (!inRegion || inRegion && thisEQTL.isInRegion(selectedLoci, eQTLPValue, constraint)) {
                                        			if (Arrays.binarySearch(myGeneArray,new GeneList().new Gene(thisEQTL.getIdentifier())) >= 0) {
									commonStart.add("*");
                                                		} else {
									commonStart.add("");
                                                		}
								commonStart.add(identifierToPrint);
								commonStart.add(thisEQTL.getGene_name());
								finalList.addAll(commonStart);
								if (correlation) { 
									finalList.addAll(getCorrelationValues(indexHash, thisEQTL.getIdentifier(), myGeneArray));
								}
								finalList.addAll(getCommonEndColumns(thisEQTL));
							} //else log.debug("5");
						} //else log.debug("6");
					}
					if (finalList.size() > 0) {
						String[] row = (String[]) finalList.toArray(new String[finalList.size()]);
						//log.debug("row = "); myDebugger.print(row);
						rowList.add(row);
					}
				}
			}

			return rowList;
		}

		/** 
	 	* Gets the rows for the EQTL Results page that do not have eQTL records.
         	* @param correlation	Whether the correlation columns are being displayed
	 	* @param indexHash	contains name of the column and the location of that column in the geneArray
         	* @param badEQTLs	an array of EQTL records that are not displayed on the graph
         	* @param myGeneArray	the array of gene identifiers that don't have eQTL records, but do have statistics values
	 	* @return            a List of String arrays containing the rows for the table 
         	*/

		public List<String[]> getRowsWithoutEQTL(boolean correlation, Hashtable indexHash, QTL.EQTL[] badEQTLs, GeneList.Gene[] myGeneArray) {

			log.debug("in getRowsWithoutEQTL");
			List<String[]> rowList = new ArrayList<String[]>();
			//log.debug("badEQTLs = "); myDebugger.print(badEQTLs);
			/*
			log.debug("correlation = "+correlation); 
			log.debug("indexHash = "); myDebugger.print(indexHash);
			*/

			//if (badEQTLs.size() > 0) {
			if (badEQTLs.length > 0) {
                	//	for (Iterator itr = badEQTLs.iterator(); itr.hasNext();) {
                		for (int i=0; i<badEQTLs.length; i++) {
					List<String> commonStart = new ArrayList<String>();
					List<String> finalList = new ArrayList<String>();

                        		String identifier = badEQTLs[i].getIdentifier();
					log.debug("identifier = "+identifier);
					commonStart.add("*");
					commonStart.add(identifier);
					commonStart.add("");
					finalList.addAll(commonStart);
					if (correlation) { 
						finalList.addAll(getCorrelationValues(indexHash, identifier, myGeneArray));
					}
					finalList.add(badEQTLs[i].getGene_chromosome());
		
					String[] row = (String[]) finalList.toArray(new String[finalList.size()]);
					//log.debug("row = "); myDebugger.print(row);
					rowList.add(row);
				}
			}

			return rowList;
		}

		/** 
	 	* Gets the column headers for the EQTL Results page.
         	* @param correlation	Whether the correlation columns are being displayed
	 	* @return            an array of Strings 
         	*/

		public String[] getTableHeaders(boolean correlation) {

			List<String> commonStart = new ArrayList<String>();
			List<String> correlationList = new ArrayList<String>();
			List<String> commonEnd = new ArrayList<String>();
			List<String> finalList = new ArrayList<String>();

			commonStart.add("In Probeset List");
			commonStart.add("Probeset Identifier");
			commonStart.add("Official Gene Symbol");
			finalList.addAll(commonStart);
			if (correlation) { 
				correlationList.add("Correlation coefficient");
				correlationList.add("Correlation raw p-value");
				correlationList.add("Correlation adjusted p-value");
				finalList.addAll(correlationList);
			}
			commonEnd.add("Tissue");
			commonEnd.add("Probeset Chromosome");
			commonEnd.add("Probeset Location in Mbp");
			commonEnd.add("Max LOD score");
			commonEnd.add("p-value");
			commonEnd.add("FDR");
			commonEnd.add("Best Marker");
			commonEnd.add("Marker Chromosome");
			commonEnd.add("Marker Location in Mbp");
			commonEnd.add("LOD Plot");
			finalList.addAll(commonEnd);
		
			String[] headers = (String[]) finalList.toArray(new String[finalList.size()]);

			return headers;
		}

        	/**
         	* Retrieves the expression QTLs that fall within the regions.
         	* @param organism	two-character code for the organism
		* @param qtlListID	the identifier of the QTL list
		* @param tissue	the eQTL tissue to use -- 'Heart', 'Whole Brain', 'Liver', 'Brown Adipose' or 'All'
		* @param pValue	the p-value threshold
	 	* @param conn	the database connection
	 	* @throws	SQLException if a database error occurs
	 	* @return            an array of EQTL objects
         	*/
		public QTL.EQTL[] getExpressionQTLsInList(String organism, int qtlListID, String tissue, Double pValue, Connection conn) throws SQLException {
        		log.debug ("in QTL.getExpressionQTLsInList");

			List<EQTL> myEQTLList = new ArrayList<EQTL>();

        		String query =
                		"select distinct p.identifier, "+
				"gs.gene_name, "+
                		"p.chromosome, "+
                		"p.mb, "+
                		"eq.lod_score, "+
                		"eq.p_value, "+
				"eq.fdr, "+
                		"eq.marker, "+
                		"eq.marker_chromosome, "+
                		"eq.marker_mb, "+
                		"nvl(eq.upper_limit, eq.marker_mb), "+
                		"nvl(eq.lower_limit, eq.marker_mb), "+
				"0, "+
				"eq.tissue "+
                		"from probesets p "+
				"left join expression_qtls eq "+
				"	on eq.identifier = p.identifier "+
				"left join gene_symbols gs "+
				"	on p.identifier = gs.identifier, "+
				"qtl_lists ql, "+
				"qtls q "+
                		"where eq.marker_chromosome = q.chromosome "+
				"and eq.marker_mb * 1000000 > q.range_start "+
				"and eq.marker_mb * 1000000 < q.range_end "+
				"and eq.organism = ql.organism "+
				"and ql.organism = ? "+
				"and ql.qtl_list_id = q.qtl_list_id "+
				"and ql.qtl_list_id = ? "+
				"and to_number(decode(eq.p_value, '<0.000001', '1.E-100', eq.p_value)) < ? ";
				if (!tissue.equals("All")) {
					query = query + " and eq.tissue = ? ";
				} 
				query = query + "order by gs.gene_name";

			log.debug("query = "+query);

			Results myResults = (tissue.equals("All") ? 
							new Results(query, new Object[] {organism, qtlListID, pValue}, conn) :
							new Results(query, new Object[] {organism, qtlListID, pValue, tissue}, conn));

			myEQTLList.addAll(setupEQTLValues(myResults));

			myResults.close();

			EQTL[] myEQTLArray =  (EQTL []) myObjectHandler.getAsArray(myEQTLList, EQTL.class);

   			return myEQTLArray;
		}
		
		/** 
		 * Gets the probeset_ids for an array of EQTL objects.
	 	 * @param	myEQTLs	an array of EQTL objects
		 * @return	a Set of Strings containing the probeset IDs
		 */
		public Set<String> getProbesetIDs(EQTL[] myEQTLs) {
			log.debug("in getProbesetIDs");
			Set<String> probesetIDs = new TreeSet<String>();
			for (EQTL thisEQTL : myEQTLs) {
				probesetIDs.add(thisEQTL.getIdentifier());
			}
			return probesetIDs;
		}

                
                
                public QTL.EQTL[] getExpressionQTLInfo(List<String> identifiers, String typeOfIdentifier, String organism, String tissue, DataSource pool) throws SQLException {
        		log.debug ("in QTL.getExpressionQTLInfo. tissue = " + tissue + ", typeOfIdentifier = "+typeOfIdentifier);
			log.debug("identifiers = "); myDebugger.print(identifiers);
			Iterator itr = identifiers.iterator();
			List<EQTL> myEQTLList = new ArrayList<EQTL>();

                	while (itr.hasNext()) {

				// nextIdentifier is a comma-delimited string of ids
				String nextIdentifier = (String) itr.next();
				log.debug("nextIdentifier = "+nextIdentifier);
				if (nextIdentifier != null && !nextIdentifier.equals("")) {
					String thisIdentifierString = "(" + nextIdentifier + ")";

					String typeClause = (typeOfIdentifier.equals("ProbesetID") ?
                					"p.identifier in " + thisIdentifierString :
							(typeOfIdentifier.equals("GeneName") ?
								"gs.gene_name in "+ thisIdentifierString :  
                							"(p.identifier in " + thisIdentifierString + " or "+
									"gs.gene_name in "+ thisIdentifierString + ") "));  

        				String query =
                				"select distinct p.identifier, "+
						"gs.gene_name, "+
                				"p.chromosome, "+
                				"p.mb, "+
                				"eq.lod_score, "+
                				"eq.p_value, "+
						"eq.fdr, "+
                				"eq.marker, "+
                				"eq.marker_chromosome, "+
                				"eq.marker_mb, "+
                				"nvl(eq.upper_limit, eq.marker_mb), "+
                				"nvl(eq.lower_limit, eq.marker_mb), "+
						"cnt.num_gene_symbols, "+
						"eq.tissue "+
                				"from probesets p "+
						"left join gene_symbols gs "+
						"	on p.identifier = gs.identifier "+
						"left join expression_qtls eq "+
						"	on eq.identifier = p.identifier, "+
						"gene_symbol_count cnt "+
                				"where "+
						typeClause + 
						"and p.identifier = cnt.identifier "+
						"and eq.organism = ? ";
						if (!tissue.equals("All")) {
							query = query + " and eq.tissue = ? ";
						} 
						query = query +
						"order by gs.gene_name";

					log.debug("query = "+query);
                                        Connection conn=null;
                                        try{
                                            conn=pool.getConnection();
                                            Results myResults = (!tissue.equals("All") ? 
                                                                    new Results(query, new Object[] {organism, tissue}, conn) : 
                                                                    new Results(query, new Object[] {organism}, conn));
                                                                 
                                            myEQTLList.addAll(setupEQTLValues(myResults));
                                            
                                            log.debug("There are "+myEQTLList.size() + " records returned");

                                            myResults.close();
                                            conn.close();
                                        }catch(SQLException e){
                                            throw(e);
                                        }finally{
                                            if(conn!=null && !conn.isClosed()){
                                                try{
                                                    conn.close();
                                                    conn=null;
                                                }catch(SQLException e){}
                                            }
                                        }
				} else {
					log.debug("nextIdentifier is null");
				}
				log.debug("itr has next");
			}
			log.debug("before turning into array");
			log.debug("List contains "+myEQTLList.size() + " objects");
			EQTL[] myEQTLArray =  (EQTL []) myObjectHandler.getAsArray(myEQTLList, EQTL.class);
			log.debug("after turning into array");

   			return myEQTLArray;
		}
                
                
                
        	/**
         	* Retrieves the expression QTL information for the identifier passed in.
         	* @param identifiers	List of Strings containing Affy IDs and/or Gene Symbols broken into comma-delimited strings of 1000 
	 	*				location IDs each
         	* @param typeOfIdentifier	either 'ProbesetID' or 'GeneName' or 'Both'
         	* @param organism	two-character code for the organism
         	* @param tissue		'Heart', 'Whole Brain', 'Liver', 'Brown Adipose' or 'All'
	 	* @param conn	the database connection
	 	* @throws	SQLException if a database error occurs
	 	* @return            an array of EQTL objects
         	*/
		public QTL.EQTL[] getExpressionQTLInfo(List<String> identifiers, String typeOfIdentifier, String organism, String tissue, Connection conn) throws SQLException {
        		log.debug ("in QTL.getExpressionQTLInfo. tissue = " + tissue + ", typeOfIdentifier = "+typeOfIdentifier);
			log.debug("identifiers = "); myDebugger.print(identifiers);
			Iterator itr = identifiers.iterator();
			List<EQTL> myEQTLList = new ArrayList<EQTL>();

                	while (itr.hasNext()) {

				// nextIdentifier is a comma-delimited string of ids
				String nextIdentifier = (String) itr.next();
				log.debug("nextIdentifier = "+nextIdentifier);
				if (nextIdentifier != null && !nextIdentifier.equals("")) {
					String thisIdentifierString = "(" + nextIdentifier + ")";

					String typeClause = (typeOfIdentifier.equals("ProbesetID") ?
                					"p.identifier in " + thisIdentifierString :
							(typeOfIdentifier.equals("GeneName") ?
								"gs.gene_name in "+ thisIdentifierString :  
                							"(p.identifier in " + thisIdentifierString + " or "+
									"gs.gene_name in "+ thisIdentifierString + ") "));  

        				String query =
                				"select distinct p.identifier, "+
						"gs.gene_name, "+
                				"p.chromosome, "+
                				"p.mb, "+
                				"eq.lod_score, "+
                				"eq.p_value, "+
						"eq.fdr, "+
                				"eq.marker, "+
                				"eq.marker_chromosome, "+
                				"eq.marker_mb, "+
                				"nvl(eq.upper_limit, eq.marker_mb), "+
                				"nvl(eq.lower_limit, eq.marker_mb), "+
						"cnt.num_gene_symbols, "+
						"eq.tissue "+
                				"from probesets p "+
						"left join gene_symbols gs "+
						"	on p.identifier = gs.identifier "+
						"left join expression_qtls eq "+
						"	on eq.identifier = p.identifier, "+
						"gene_symbol_count cnt "+
                				"where "+
						typeClause + 
						"and p.identifier = cnt.identifier "+
						"and eq.organism = ? ";
						if (!tissue.equals("All")) {
							query = query + " and eq.tissue = ? ";
						} 
						query = query +
						"order by gs.gene_name";

					log.debug("query = "+query);

					Results myResults = (!tissue.equals("All") ? 
								new Results(query, new Object[] {organism, tissue}, conn) : 
								new Results(query, new Object[] {organism}, conn));

					myEQTLList.addAll(setupEQTLValues(myResults));
					log.debug("There are "+myEQTLList.size() + " records returned");

					myResults.close();
				} else {
					log.debug("nextIdentifier is null");
				}
				log.debug("itr has next");
			}
			log.debug("before turning into array");
			log.debug("List contains "+myEQTLList.size() + " objects");
			EQTL[] myEQTLArray =  (EQTL []) myObjectHandler.getAsArray(myEQTLList, EQTL.class);
			log.debug("after turning into array");

   			return myEQTLArray;
		}

        	/**
         	* Sets up the values for an EQTL array.
         	* @param myResults	a Results object
         	* @return              a List of EQTL objects 
         	*/

		public List<EQTL> setupEQTLValues (Results myResults) {
			List<EQTL> myEQTLList = new ArrayList<EQTL>();

                	String[] dataRow;
			while ((dataRow = myResults.getNextRow()) != null) {
				EQTL thisEQtl = new EQTL();
				thisEQtl.setIdentifier(dataRow[0]);
				thisEQtl.setGene_name(myDbUtils.setToEmptyIfNull(dataRow[1]));
				thisEQtl.setGene_chromosome(myDbUtils.setToEmptyIfNull(dataRow[2]));
				thisEQtl.setGene_mb(dataRow[3] != null ? 
							Double.parseDouble(dataRow[3]) : 
							new Double(Double.NaN).doubleValue());
				thisEQtl.setLod_score(dataRow[4] != null ? 
							Double.parseDouble(dataRow[4]) : 
							new Double(Double.NaN).doubleValue());
				thisEQtl.setP_value(dataRow[5]);
				thisEQtl.setFdr(dataRow[6]);
				thisEQtl.setMarker(dataRow[7]);
				thisEQtl.setMarker_chromosome(dataRow[8]);
				thisEQtl.setMarker_mb(dataRow[9] != null ? 
							Double.parseDouble(dataRow[9]) : 
							new Double(Double.NaN).doubleValue());
				thisEQtl.setUpper_limit(dataRow[10] != null ? 
							Double.parseDouble(dataRow[10]) : 
							new Double(Double.NaN).doubleValue());
				thisEQtl.setLower_limit(dataRow[11] != null ? 
							Double.parseDouble(dataRow[11]) : 
							new Double(Double.NaN).doubleValue());
				thisEQtl.setNum_gene_symbols(dataRow[12] != null ? 
							Integer.parseInt(dataRow[12]) : 1);
				thisEQtl.setTissue(dataRow[13]); 
				thisEQtl.setOrganism(organism);
				myEQTLList.add(thisEQtl);
			}


   			return myEQTLList;
		}

		/**
	 	* Returns whether the probeset is in the locus region
	 	* @param locus	the Locus object
	 	* @param type	either 'Marker' or 'Physical'
	 	* @return	true if the physical location or the marker location is in the locus region
	 	*/
		public boolean isInRegion(QTL.Locus locus, String type) { 
			String chromosome = (type.equals("Physical") ? this.getGene_chromosome() : this.getMarker_chromosome());
			double upper = (type.equals("Physical") ? this.getGene_mb() : this.getUpper_limit());
			double lower = (type.equals("Physical") ? this.getGene_mb() : this.getLower_limit());
			//log.debug("in isInRegion. type = "+type);
			//log.debug("chromosome = "+chromosome + ", upper = " + upper + ", lower = "+ lower);

        		if (chromosome != null &&
                		chromosome.equals(locus.getChromosome()) &&
                        	upper * 1000000 > locus.getRange_start() &&
                        	lower * 1000000 < locus.getRange_end()) {
				return true;
			} else {
				return false;
			} 
		}

		/**
	 	* Returns whether the probeset is in any of the loci and meets the constraint
	 	* @param loci	an array of Locus objects
	 	* @param eQTLPValue	the p-value
	 	* @return	true if the eQTL is in any of the the loci regions and meets the constraint
	 	*/
		public boolean isInRegion(QTL.Locus[] loci, Double eQTLPValue, String constraint) { 

			//log.debug("here constraint= "+constraint);
			if (constraint.equals("none")) {
				return true;
			} else if (constraint.equals("phys") && isInRegion(loci)) { 
				return true;
			} else if (constraint.equals("eQTL") && isInRegion(loci, eQTLPValue)) { 
				return true;
			} else if (constraint.equals("either") && (isInRegion(loci) || isInRegion(loci, eQTLPValue))) { 
				return true;
			} else if (constraint.equals("both") && isInRegion(loci) && isInRegion(loci, eQTLPValue)) { 
				return true;
			} 
			return false;
		}

		/**
	 	* Returns whether the physical location of the probeset is in the locus region
	 	* @param locus	the Locus object
	 	* @return	true if the physical location of the probeset is in the locus region
	 	*/
		public boolean isInRegion(QTL.Locus locus) { 
			if (isInRegion(locus, "Physical")) {
				return true;
			} else {
				return false;
			}
		}

		/**
	 	* Returns whether the physical location of the probeset is in any of the loci
	 	* @param loci	an array of Locus objects
	 	* @return	true if the physical location is in any of the the locus regions
	 	*/
		public boolean isInRegion(QTL.Locus[] loci) { 
			for (QTL.Locus thisLocus : loci){
				if (isInRegion(thisLocus)) {
					return true;
				}
			} 
			return false;
		}

		/**
	 	* Returns whether the eQTL of the probeset is in any of the loci
	 	* @param loci	an array of Locus objects
	 	* @param eQTLPValue	the p-value
	 	* @return	true if the eQTL is in any of the the locus regions
	 	*/
		public boolean isInRegion(QTL.Locus[] loci, Double eQTLPValue) { 
			for (QTL.Locus thisLocus : loci){
				if (isInRegion(thisLocus, eQTLPValue)) {
					return true;
				}
			} 
			return false;
		}

		/**
	 	* Returns whether the eQTL of the probeset is in the locus region
	 	* @param locus	the Locus object
	 	* @param eQTLPValue	the p-value
	 	* @return	true if the eQTL is in the locus region
	 	*/
		public boolean isInRegion(QTL.Locus locus, Double eQTLPValue) { 
			double pValue = (this.getP_value().equals("<0.000001") ?
                        			Double.parseDouble("1.E-100") :
                                        	Double.parseDouble(this.getP_value()));
			//log.debug("in isInRegion. eQTLPValue = "+eQTLPValue + ", pValue = "+pValue);
			if (isInRegion(locus, "Marker") && pValue < eQTLPValue) {
				return true;
			} else {
				return false;
			}
		}

  		public String toString() {
        		return ("This EQTL object has identifier " + identifier +
				" and gene name = "+gene_name + 
				" and gene_chromosome = "+gene_chromosome +
				" and marker_chromosome = "+marker_chromosome);
  		}

		public boolean equals(EQTL eQTL) {
			return identifier.equals(eQTL.getIdentifier());
		}

                public int hashCode() {
                    return identifier.hashCode();
                }

		public int compareTo(Object myEQTLObject) {
			if (!(myEQTLObject instanceof EQTL)) return -1;
			return this.getIdentifier().compareTo(((EQTL) myEQTLObject).getIdentifier());
		}

		public void print() {
			log.debug(toString());
		}
		/**
	 	* Compares EQTLs based on different fields.
	 	*/
		public class EQTLSortComparator implements Comparator<EQTL> {
			int compare;
        		EQTL eqtl1, eqtl2;

        		public int compare(EQTL object1, EQTL object2) {
				String sortColumn = getSortColumn();
				String sortOrder = getSortOrder();

				if (sortOrder.equals("A")) {
					eqtl1 = object1;
	                		eqtl2 = object2;
					// default for null columns for ascending order
					compare = 1;
				} else {
					eqtl2 = object1;
	                		eqtl1 = object2;
					// default for null columns for ascending order
					compare = -1;
				}

                		//log.debug("qtl1 = "+qtl1+ ", qtl2 = "+qtl2);

				if (sortColumn.equals("gene_name")) {
                			compare = eqtl1.getGene_name().compareTo(eqtl2.getGene_name());
				} else if (sortColumn.equals("identifier")) {
                			compare = eqtl1.getIdentifier().compareTo(eqtl2.getIdentifier());
				}
                		return compare;
			}
		}

		public EQTL[] sortEQTLs (EQTL[] myEQTLs, String sortColumn, String sortOrder) {
			setSortColumn(sortColumn);
			setSortOrder(sortOrder);
			Arrays.sort(myEQTLs, new EQTLSortComparator());
			return myEQTLs;
		}
	}
}
