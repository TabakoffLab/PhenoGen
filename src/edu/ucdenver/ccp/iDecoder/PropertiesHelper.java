package edu.ucdenver.ccp.iDecoder;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

/**
 * Provides consistent access to the file, organism, unigene, and exon properties files.
 * All methods are <code>static</code>, so this class is never instantiated.
 */
public class PropertiesHelper {

    private static final String PROPERTIES_DIR = "/srv/www/tomcat/webapps/PhenoGen/src/edu/ucdenver/ccp/iDecoder/";
    private static final String ORGANISM_PROPERTIES_FILENAME = PROPERTIES_DIR + "organism.properties";
    private static final String UNIGENE_PROPERTIES_FILENAME = PROPERTIES_DIR + "unigene.properties";
    private static final String EXON_PROPERTIES_FILENAME = PROPERTIES_DIR + "exon.properties";
    private static final String FILE_PROPERTIES_FILENAME = PROPERTIES_DIR + "file.properties";

    private static Map<String, String> taxonIDToOrganismMap = null;
    private static Map<String, String> organismToTaxonIDMap = null;
    private static Map<String, String> uniGenePrefixToOrganismMap = null;
    private static Map<String, String> exonPrefixToOrganismMap = null;
    private static Map<String, String> organismToUniGenePrefixMap = null;
    private static Map<String, String> uniGenePrefixToTaxonIDMap = null;
    private static Map fileMap = null;
    
    // private constructor because this class is not to be instantiated
    private PropertiesHelper() { }
    
    /**
     * Creates a Map containing Taxonomy ID as the key and organism name as the
     * value based on the contents of the organism.properties file. Only
     * organisms useful to PhenoGen are contained in the Map, so the key Set can be
     * used to filter irrelevant organisms from input files.
     * 
     * @return the Taxonomy ID to organism name Map
     */
    public static Map getTaxonIDToOrganismMap() {
        if (taxonIDToOrganismMap == null) {
            Properties props;
            try {
                props = new Properties();
                props.load(new FileInputStream(ORGANISM_PROPERTIES_FILENAME));
            } catch (IOException e) {
                throw new PropertiesFileException(ORGANISM_PROPERTIES_FILENAME, e);
            }
            taxonIDToOrganismMap = (Map) props;
        }
        return taxonIDToOrganismMap;
    }

    /**
     * Creates a Map containing organism as the key and Taxonomy ID as the value
     * based on the contents of the organism.properties file. Only organisms
     * useful to PhenoGen are contained in the Map. The primary use of this map is
     * to provide the Taxonomy ID given an organism name.
     * 
     * @return the organism name to Taxonomy ID Map
     */
    public static Map getOrganismToTaxonIDMap() {
        if (organismToTaxonIDMap == null) {
            Properties props;
            try {
                props = new Properties();
                props.load(new FileInputStream(ORGANISM_PROPERTIES_FILENAME));
            } catch (IOException e) {
                throw new PropertiesFileException(ORGANISM_PROPERTIES_FILENAME, e);
            }
            // The properties file has taxon id in the first column and organism
            // name in the second. So, after loading into Properties, create a new
            // Map with the keys and values swapped, and return that.
            Set entrySet = props.entrySet();
            organismToTaxonIDMap = new HashMap<String,String>();
            for (Iterator iter = entrySet.iterator(); iter.hasNext();) {
                Map.Entry entry = (Map.Entry) iter.next();
                organismToTaxonIDMap.put((String) entry.getValue(), (String) entry.getKey());
            }
        }
        return organismToTaxonIDMap;
    }

    /**
     * Creates a Map containing the Affy Exon file prefix as the key and organism name
     * as the value based on the contents of the exon.properties file. Only
     * organisms useful to PhenoGen are contained in the Map, so the key Set can be
     * used to filter out irrelevant organisms in input files.
     * 
     * @return the exon file prefix to organism name Map
     */
    public static Map getExonPrefixToOrganismMap() {
        if (exonPrefixToOrganismMap == null) {
            Properties props;
            try {
                props = new Properties();
                props.load(new FileInputStream(EXON_PROPERTIES_FILENAME));
            } catch (IOException e) {
                throw new PropertiesFileException(EXON_PROPERTIES_FILENAME, e);
            }
            exonPrefixToOrganismMap = (Map) props;
        }
        return exonPrefixToOrganismMap;
    }
    
    /**
     * Creates a Map containing the UniGene prefix as the key and organism name
     * as the value based on the contents of the unigene.properties file. Only
     * organisms useful to PhenoGen are contained in the Map, so the key Set can be
     * used to filter out irrelevant organisms in input files.
     * 
     * @return the UniGene prefix to organism name Map
     */
    public static Map getUniGenePrefixToOrganismMap() {
        if (uniGenePrefixToOrganismMap == null) {
            Properties props;
            try {
                props = new Properties();
                props.load(new FileInputStream(UNIGENE_PROPERTIES_FILENAME));
            } catch (IOException e) {
                throw new PropertiesFileException(UNIGENE_PROPERTIES_FILENAME, e);
            }
            uniGenePrefixToOrganismMap = (Map) props;
        }
        return uniGenePrefixToOrganismMap;
    }
    
    /** 
     * Creates a Map containing organism name as the key and UniGene prefix as
     * the value based on the contents of the unigene.properties file. Only organisms
     * useful to PhenoGen are contained in the Map. The primary use of this Map is to fetch
     * the UniGene prefix given an organism name.
     *  
     * @return the organism name to UniGene prefix Map
     */
    public static Map getOrganismToUniGenePrefixMap() {
        if (organismToUniGenePrefixMap == null){
            Properties props;
            try {
                props = new Properties();
                props.load(new FileInputStream(UNIGENE_PROPERTIES_FILENAME));
            } catch (IOException e) {
                throw new PropertiesFileException(UNIGENE_PROPERTIES_FILENAME, e);
            }
            // The properties file has UniGene prefix in the first column and organism
            // name in the second. So, after loading into Properties, create a new
            // Map with the keys and values swapped, and return that.
            Set entrySet = props.entrySet();
            organismToUniGenePrefixMap = new HashMap<String, String>();
            for (Iterator iter = entrySet.iterator(); iter.hasNext();) {
                Map.Entry entry = (Map.Entry) iter.next();
                organismToUniGenePrefixMap.put((String)entry.getValue(), (String)entry.getKey());
            }
        }
        return organismToUniGenePrefixMap;        
    }

    /** 
     * Creates a Map containing UniGene prefix as the key and Taxonomy ID as the value
     * based on the contents of the unigene.properties and organism.properties files. Only organisms
     * useful to PhenoGen are contained in the Map. The primary use of this Map is to fetch the Taxonomy ID
     * given a UniGene prefix.
     * 
     * @return the UniGene prefix to Taxonomy ID Map
     */
    public static Map getUniGenePrefixToTaxonIDMap() {
        if (uniGenePrefixToTaxonIDMap == null) {
            Set unigenePrefixSet = getUniGenePrefixToOrganismMap().entrySet();
            uniGenePrefixToTaxonIDMap = new HashMap<String, String>();
            for (Iterator unigeneIter = unigenePrefixSet.iterator(); unigeneIter
                    .hasNext();) {
                Map.Entry entry = (Map.Entry) unigeneIter.next();
                uniGenePrefixToTaxonIDMap.put((String)entry.getKey(),(String)getOrganismToTaxonIDMap().get(entry.getValue()));
            }
        }
        return uniGenePrefixToTaxonIDMap;
    }
    
    /**
     * Creates a Map containing a file alias as the key and the actual file name
     * (or list of file names) as the value based on the contents of the
     * file.properties file. This Map is used by subclasses of InputFileParser,
     * which refer to input files by aliases, to get the actual file name (or
     * file names) where input data resides.
     * 
     * @return the file alias to file name Map
     */
    public static Map getFileMap() {
        if (fileMap == null) {
            Properties props;
            try {
                props = new Properties();
                props.load(new FileInputStream(FILE_PROPERTIES_FILENAME));
            } catch (IOException e) {
                throw new PropertiesFileException(FILE_PROPERTIES_FILENAME, e);
            }
            fileMap = (Map) props;
        }
        return fileMap;
    }
    
    /**
     * Instance of <code>RuntimeException</code> used to indicate a problem
     * accessing a properties file.
     */
    public static class PropertiesFileException extends RuntimeException {
        private static final long serialVersionUID = 8486826338929505189L;

        PropertiesFileException(String filename, Exception rootCause) {
            super("Unable to load properties file " + filename, rootCause);
        }
    }

}
