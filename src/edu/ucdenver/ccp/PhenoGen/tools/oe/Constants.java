package edu.ucdenver.ccp.PhenoGen.tools.oe;

import java.awt.Color;

/**
 * @author Purvesh Khatri
 */

public interface Constants
{
  /**
   * These are the constants used by Standalone application.
   * They should actually be used by the entire OntoTools system.
   */
  public static final int ACCESSION = 0;
  public static final int CLUSTER = 1;
  public static final int PROBE = 2;
  public static final int LOCUS = 3;
  public static final int WB_LOCI = 4;
  public static final int WB_ACCESSION = 5;
  public static final int WB_GENE = 6;
   
  public static final int WB_ID = 7;  //added by pratik bhavsar

  public static final String ACCESSION_STR = "accession";
  public static final String CLUSTER_STR = "cluster";
  public static final String PROBE_STR = "probe";
  public static final String LOCUS_STR = "locus";
  public static final String WB_LOCI_STR = "wormbase locus";
  public static final String WB_ACCESSION_STR = "wormbase accession";
  public static final String BOUNDARY = "--------123456789";
  public static final String DISPOSITION_STR = "content-disposition: form-data; name=";
  public static final String CONTENT_TYPE = "content-type ASCII";
  public static final String BLANK_LINE = "\r\n";    
  public static final String VERSION_1 = "1";  
  public static final String VERSION_2 = "1.1"; //added by pratik bhavsar
  public static final String FILE = "file";
  public static final String LIST = "list";
  
  /**
   * 
   *
   * This constants are used by OEResultsPanel to decide which view to display.
   */
  public static final String BIOLOGICAL_PROCESS = "P";
  public static final String CELLULAR_COMPONENT = "C";
  public static final String MOLECULAR_FUNCTION = "F";
  public static final String CHROMOSOMAL_INFORMATION = "I";
    
  /**
   * There are some entries in GO association files
   * which have the aspect column with a value of "ND"
   */
  public static final String NOT_DETERMINED = "ND";
  public static final java.awt.Color UNSELECTED_COLOR = new java.awt.Color(0,114,188);
  public static final java.awt.Color SELECTED_COLOR = java.awt.Color.red;
  public static final java.awt.Color MARKED_COLOR = new java.awt.Color(198,156,109);
  public static final java.awt.Color GREEN_COLOR = new java.awt.Color(0,166,81);
  public static final java.awt.Color BACKGROUND_COLOR = new java.awt.Color(254,255,215);
  public static final java.awt.Color UP_REGULATED_COLOR = new java.awt.Color(153,51,153);
  public static final int UNIT_BAR_WIDTH = 5;
  public static final int UNIT_BAR_HEIGHT = 30;
  public static final int SORT_BY_NAME = 0;
  public static final int SORT_BY_TOTAL = 1;
  public static final int SORT_BY_PVALUE = 2;
  
  //added by pratik bhavsar
  public static final int Y_AXIS =180;
  public static final String UNKNOWN="unknown";
  public static final int PVALUE_MARGIN=5;
  public static final int CPVALUE_MARGIN=65;
  public static final int TOTAL_MARGIN=140;
  public static final int UNIT_CHROMOSOME_WIDTH=5;
  
  //Added by Purvesh for TreeDisplay.
  public static final String GO_ID_GENE_ONTOLOGY = "GO:0003673";
  public static final String GO_ID_BIOLOGICAL_PROCESS = "GO:0008150";
  public static final String GO_ID_CELLULAR_COMPONENT = "GO:0005575";
  public static final String GO_ID_MOLECULAR_FUNCTION = "GO:0003674";

  public static final String GO_GENE_ONTOLOGY = "Gene_Ontology";
  public static final String GO_BIOLOGICAL_PROCESS = "biological_process";
  public static final String GO_CELLULAR_COMPONENT = "cellular_component";
  public static final String GO_MOLECULAR_FUNCTION = "molecular_function";
  
  //Added by Purvesh for synchronizing Tree and Bar view.
  public static final int TREE_VIEW = 0;
  public static final int SYNC_VIEW = 1;
  public static final int SYNC_PIE_VIEW = 2;// Added by Shoaib
  public static final int GENE_VIEW = 3;
  public static final int BAR_VIEW = 4;
  public static final int PIE_VIEW = 5; //Added by sharun 
  
  
  //Added by pratik bhavsar to show functional regulation level
  public static final int UNCHANGED = 0;
  public static final int UP_REGULATED = 1;
  public static final int DOWN_REGULATED = 2;
  
  //Added by Valmik for Progress Bar to specify the Threads runing for a particular request
  public static final int SERVLET_INSTANCE = 0;
  public static final int STATUS_THREAD_INSTANCE = 1;
  

  //Added by Shoaib for pie charts
  public static final Color pieColor[]={new Color(0, 0, 255), new Color(255, 255, 153), new Color(255, 153, 204), new Color(255, 204, 153), new Color(0, 204, 255), new Color(204, 255, 204), new Color(204, 153, 255), new Color(204, 255, 255), new Color(102, 204, 153), new Color(51, 102, 255), new Color(51, 204, 204), new Color(153, 204, 0), new Color(255, 204, 0), new Color(255, 102, 0), new Color(102, 102, 153), new Color(153, 51, 102), new Color(51, 51, 153), new Color(51, 51, 153), new Color(255, 0, 0), new Color(0, 255, 0), new Color(0, 0, 255), new Color(255, 255, 0), new Color(255, 0, 255), new Color(0, 255, 255), new Color(128, 0, 0), new Color(153, 153, 255), new Color(255, 128, 128), new Color(0, 102, 204), new Color(204, 204, 255), new Color(0, 0, 128), new Color(255, 0, 255), new Color(230, 230, 100), new Color(128, 0, 128) };
  public static final int NUM_PIE_COLORS = 32;

  //Added by Pratik bhavsar for url parameter name for integration  
  public static final String ONTOEXPRESS_URL="ontoexpress_url";
  public static final String OESERVEOBJECTS_URL="serveobjects_url";
  public static final String OEEMAIL_URL="oeemail_url";
  public static final String GOTREE_URL="gotree_url";
  public static final String ONTODESIGN_URL="ontodesign_url";
  public static final String ODSERVEOBJECTS_URL="odserveobjects_url";
  public static final String ODEMAIL_URL="odemail_url";
  public static final String ODDETAILS_URL="oddetails_url";
  public static final String OCTREE_URL="octree_url";
  public static final String ONTOCOMPARE_URL="ontocompare2_url";
  public static final String OCSERVEOBJECTS_URL="ocserveobjects_url";
  public static final String OCEMAIL_URL="ocemail_url";
  public static final String ONTOTRANSLATE_URL="ontotranslate_url";
  public static final String OTSERVEOBJECTS_URL="otserveobjects_url";
  public static final String OTEMAIL_URL="otemail_url";
  
  //Added by Pratik Bhavsar to remove default organism
  public static final String NO_ORGANISM="None";
  
  //Added by Pratik Bhavsar: setting application Ids

  /*
     1 = OntoExpress
     2 = OntoCompare
     3 = OntoDesign
     4 = OntoConvert
     5 = ComparativeOE
     6 = OntoMiner
   */
  public static final int APP_ONTOEXPRESS = 1 ;
  public static final int APP_ONTOCOMPARE = 2 ;
  public static final int APP_ONTODESIGN = 3 ;
  public static final int APP_ONTOCONVERT = 4 ;
  public static final int APP_COMPARATIVEOE = 5 ;
  public static final int APP_ONTOMINER = 6 ;
  
  public static final String URL_ENCODING = "UTF-8";
  public static final int SESSION_TIMEOUT = 2 * 60 * 60;
}

