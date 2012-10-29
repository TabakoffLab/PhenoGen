package edu.ucdenver.ccp.iDecoder;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

/**
 * Extends InputFileParser to handle NCBI input files.
 *
 */
public class NCBIParser extends InputFileParser {

    private static final String INPUT_SOURCE = "NCBI";
    
    // Input columns are tab-delimited
    private static final String INPUT_COLUMN_DELIM = "\t";

    // List (multi-item) columns have pipes delimiting the items
    private static final String INPUT_LIST_DELIM = "\\|";
    
    // see handleBlankListColumn() below
    private static final String[] EMPTY_STRING_ARRAY = new String[0];

    // key names for file properties entries
    private static final String NCBI_INPUT_DIRECTORY_PROP_NM = "ncbiInputDirectory";
    private static final String NCBI_UNI_GENE_FILENAME_PROP_NM = "ncbiUniGeneFilename";
    private static final String NCBI_GENE_INFO_FILENAME_PROP_NM = "ncbiGeneInfoFilename";
    private static final String NCBI_ACC_NUM_FILENAME_PROP_NM = "ncbiAccNumFilename";
    private static final String NCBI_HOMOLOGENE_FILENAME_PROP_NM = "ncbiHomologeneFilename";
    private static final String NOT_APPLICABLE_TAXON_ID = "9999";
    
    public NCBIParser(String outputDirectory) {
        super(outputDirectory);
    }
    
    // javadoc in superclass
    public String getInputSource() {
        return INPUT_SOURCE;
    }
    
    // javadoc in superclass
    public void processAllInputFiles() throws IOException {
        final Set unigenePrefixSet = PropertiesHelper.getUniGenePrefixToOrganismMap().keySet();
        final Set taxonIDSet = PropertiesHelper.getTaxonIDToOrganismMap().keySet();
        final Map fileMap = PropertiesHelper.getFileMap();
        
        String inputDirectory = createFileSpec((String) fileMap.get(INPUT_DIRECTORY), 
        			(String) fileMap.get(NCBI_INPUT_DIRECTORY_PROP_NM));
        
        // there are 4 input files, each with a different format
        String unigeneFilename = (String) fileMap.get(NCBI_UNI_GENE_FILENAME_PROP_NM);
        String geneInfoFilename = (String) fileMap.get(NCBI_GENE_INFO_FILENAME_PROP_NM);
        String accNumFilename = (String) fileMap.get(NCBI_ACC_NUM_FILENAME_PROP_NM);
        String homologeneFilename = (String) fileMap.get(NCBI_HOMOLOGENE_FILENAME_PROP_NM);
        
        initializeOutputFiles();
        
        long startTime = System.currentTimeMillis();
        String fileSpec = createFileSpec(inputDirectory,geneInfoFilename);
        HashMap egLocation=processGeneInfoInputFile(fileSpec,taxonIDSet);
        System.out.println("processed " + fileSpec + "\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
        
        startTime = System.currentTimeMillis();
        fileSpec = createFileSpec(inputDirectory,unigeneFilename);
        processUnigeneInputFile(fileSpec, unigenePrefixSet, 
            PropertiesHelper.getUniGenePrefixToTaxonIDMap(),egLocation);
        System.out.println("processed " + fileSpec + "\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");

        startTime = System.currentTimeMillis();
        fileSpec = createFileSpec(inputDirectory,accNumFilename);
        processAccessionNumInputFile(fileSpec,taxonIDSet, egLocation);
        System.out.println("processed " + fileSpec + "\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
        
        startTime = System.currentTimeMillis();
        fileSpec = createFileSpec(inputDirectory, homologeneFilename);
        processHomologeneInputFile(fileSpec,taxonIDSet);
        System.out.println("processed " + fileSpec + "\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
        
        finalizeOutputFiles();
    }    
    
    /*
     * The Gene to UniGene file contains links between Entrez Gene IDs and
     * UniGene IDs in the following format:
     * 
     * Entrez Gene ID<tab>UniGene ID
     * 
     * There is one link per line, each resulting in one line in the Links
     * output file. Also, while each line's UniGene ID is written to the Info
     * file, the Entrez Gene ID is not. Entrez Gene IDs are written to the Info
     * file in another method, based on input from another file.
     * 
     * Only relevant organisms are included based upon the UniGene prefix, which
     * is organism specific (e.g., Mm.12345 is related to Mus musculus, Hs.98765
     * is related to Homo sapiens). A Set of relevant prefixes is passed as an
     * argument to this method.
     */
    private void processUnigeneInputFile(String inputFilename, Set relevantPrefixSet, Map unigene2TaxonIDMap, HashMap egLocation)
            throws IOException {
        
        BufferedReader reader = createInputFileReader(inputFilename);

        String line;
        String[] columns;
	// skip first line
        line = reader.readLine();
        while (reader.ready()) {
            line = reader.readLine();
            columns = line.split(INPUT_COLUMN_DELIM);
            
            String entrezGeneID = columns[0].trim();
            String unigeneID = columns[1].trim();
            
            // The UniGene prefix consists of the characters up to the "period" (exclusive)
            String unigenePrefix = unigeneID.substring(0,unigeneID.indexOf("."));
            
            // Only handle lines containing relevant organisms, as identified by
            // their UniGene prefix, by checking against the relevant prefix Set
            if (relevantPrefixSet.contains(unigenePrefix)) {
                // The Map contains entries relating UniGene prefixes to Taxonomy IDs
                String[] location=(String[])egLocation.get(entrezGeneID);
                if(location!=null&&location.length==2){
                    writeToInfoFile((String) unigene2TaxonIDMap.get(unigenePrefix),UNIGENE_ID_TYPE,unigeneID,location[0],location[1]);
                }else{
                    writeToInfoFile((String) unigene2TaxonIDMap.get(unigenePrefix),UNIGENE_ID_TYPE,unigeneID);
                }
                writeToLinksFile(ENTREZ_GENE_ID_TYPE,entrezGeneID,UNIGENE_ID_TYPE,unigeneID);
            }
        }

        reader.close();
    }

    /*
     * The Gene to Accession Number file relates Entrez Gene IDs to RNA and
     * Protein accession numbers. The first 6 columns are as follows:
     * 
     * taxon ID<tab>Entrez Gene ID<tab>RefSeq status<tab>RNA acc num<tab>RNA gi<tab>Protein acc num
     * 
     * The remaining columns in the input file are ignored, as is the RNA gi
     * number column (the 5th column). Each link between an Entrez Gene ID and
     * an RNA accession number and/or a Protein accession number is written to
     * the Links file. In addition, each RNA or Protein accession number is
     * written to the Info file. Entrez Gene IDs are written to the Info file in
     * another method (based on another input file), not this one.
     * 
     * Only relevant organisms are included in output, as determined by the
     * passed-in Set of taxonomy IDs.
     * 
     * Note that the accession number columns may contain RefSeq and non-RefSeq
     * IDs. Determination if an ID is a RefSeq or not is made based upon the
     * value contained in the 3rd column. Also note that RefSeq IDs are named
     * differently than non-RefSeq IDs here (and in iDecoder).
     */
    private void processAccessionNumInputFile(String inputFilename, Set relevantTaxonIDSet, HashMap egLocation)
            throws IOException {

        BufferedReader reader = createInputFileReader(inputFilename);

        String line;
        String[] columns;
	// skip first line
        line = reader.readLine();
        while (reader.ready()) {
            line = reader.readLine();
            columns = line.split(INPUT_COLUMN_DELIM);
            
            String taxonID = columns[0].trim();
            
            // Only include organisms contained in the passed-in relevant Set
            if (relevantTaxonIDSet.contains(taxonID)) {
                String entrezGeneID = columns[1].trim();
                
                // if a row contains RefSeq IDs, columns[2] contains the status
                // of the RefSeq ("Provisional", "Reviewed", etc.); it contains
                // "-" if the IDs are non-RefSeq.
                boolean isRefSeq = (! columns[2].trim().equals("-"));
                String rnaID = removeVersionNumber(handleBlankColumn(columns[3]));
                String proteinID = removeVersionNumber(handleBlankColumn(columns[5]));
                
                String loc="",chr="";
                String[] location=(String[])egLocation.get(entrezGeneID);
                if(location!=null&&location.length==2){
                    loc=location[1];
                    chr=location[0];
                }

                if (isRefSeq) {
                    if (! rnaID.equals("")) {
                        writeToInfoFile(taxonID,REF_SEQ_RNA_ID_TYPE,rnaID,chr,loc);
                        writeToLinksFile(ENTREZ_GENE_ID_TYPE,entrezGeneID,REF_SEQ_RNA_ID_TYPE,rnaID);
                    }
                    if (! proteinID.equals("")) {
                        writeToInfoFile(taxonID,REF_SEQ_PROTEIN_ID_TYPE,proteinID,chr,loc);
                        writeToLinksFile(ENTREZ_GENE_ID_TYPE,entrezGeneID,REF_SEQ_PROTEIN_ID_TYPE,proteinID);
                    }
                } else {
                    if (! rnaID.equals("")) {
                        writeToInfoFile(taxonID,NCBI_RNA_ID_TYPE,rnaID,chr,loc);
                        writeToLinksFile(ENTREZ_GENE_ID_TYPE,entrezGeneID,NCBI_RNA_ID_TYPE,rnaID);
                    }
                    if (! proteinID.equals("")) {
                        writeToInfoFile(taxonID,NCBI_PROTEIN_ID_TYPE,proteinID,chr,loc);
                        writeToLinksFile(ENTREZ_GENE_ID_TYPE,entrezGeneID,NCBI_PROTEIN_ID_TYPE,proteinID);
                    }                    
                }
            }
        }

        reader.close();
    }
    
    /*
     * The Homologene file relates Homologene IDs to Entrez Gene IDs and
     * Gene Symbols. The first 4 columns are as follows:
     * 
     * homologene ID<tab>taxon ID<tab>Entrez Gene ID<tab>Gene Symbol
     * 
     * The remaining columns in the input file are ignored.
     * Each link between a homologene ID and Entrez Gene ID and
     * homologene ID and Gene Symbol is written to
     * the Links file. In addition, each homologene ID is
     * written to the Info file. Entrez Gene IDs and Gene Symbols are written to the Info file in
     * another method (based on another input file), not this one.
     * 
     * Only relevant organisms are included in output, as determined by the
     * passed-in Set of taxonomy IDs.
     * 
     */
    private void processHomologeneInputFile(String inputFilename, Set relevantTaxonIDSet)
            throws IOException {

        BufferedReader reader = createInputFileReader(inputFilename);

        String line;
        String[] columns;
	// skip first line
        //line = reader.readLine();
        while (reader.ready()) {
            line = reader.readLine();
            columns = line.split(INPUT_COLUMN_DELIM);
            
            String homologeneID = columns[0].trim();
            String taxonID = columns[1].trim();
            
            // Only include organisms contained in the passed-in relevant Set
            if (relevantTaxonIDSet.contains(taxonID)) {
                String entrezGeneID = columns[2].trim();
                String geneSymbol = columns[3].trim();

                if (!homologeneID.equals("")) {
                        writeToInfoFile(NOT_APPLICABLE_TAXON_ID,HOMOLOGENE_ID_TYPE,homologeneID);
                	if (!entrezGeneID.equals("")) {
                        	writeToLinksFile(HOMOLOGENE_ID_TYPE, homologeneID, ENTREZ_GENE_ID_TYPE,entrezGeneID);
                	}
                	if (!geneSymbol.equals("")) {
                        	writeToLinksFile(HOMOLOGENE_ID_TYPE, homologeneID, GENE_SYMBOL_TYPE,geneSymbol);
                	}
                }
            }
        }

        reader.close();
    }
    
    /*
     * The Gene Info file contains information about each Entrez Gene ID as well
     * as links to some other databases. The format of the first 12 columns of
     * the file is as follows:
     * 
     * taxon ID<tab>Entrez Gene ID<tab>symbol<tab>LocusTag<tab>Synonyms<tab>DBXrefs<tab>chromosome<tab>map location<tab>column9<tab>column10<tab>column11<tab>full name
     * 
     * The remaining columns in the input file are ignored.
     * 
     * An Info file entry is generated for each Entrez Gene ID, Gene Symbol, and
     * Synonym, and Links are created between the Entrez Gene IDs and its
     * Symbols and Synonyms. Further, Links file entries are created for each
     * link between the Entrez Gene ID and another database IDs (currently
     * FlyBase, MGI, and RGD). Each line may contain multiple external database
     * links, and these links make appear in either the LocusTag column (which
     * will contain only one) or the DBXrefs column (which can contain more than
     * one).
     * 
     * Only relevant organisms are included, as determined by the passed-in Set
     * of taxonomy IDs.
     */
    private HashMap processGeneInfoInputFile(String inputFilename,
            Set relevantTaxonIDSet) throws IOException {
        HashMap egLocations=new HashMap();
        BufferedReader reader = createInputFileReader(inputFilename);

        String line;
        String[] columns;
        
	// skip first line
        line = reader.readLine();
        while (reader.ready()) {
            line = reader.readLine();
            columns = line.split(INPUT_COLUMN_DELIM);
            String taxonID = columns[0].trim();
            
            // Only include organisms contained in the passed-in relevant Set
            if (relevantTaxonIDSet.contains(taxonID)) {
                String entrezGeneID = columns[1].trim();
                String geneSymbol = handleBlankColumn(columns[2]);
                String chromosome = handleBlankColumn(columns[6]);

                // A gene may have multiple synonyms
                String[] synonyms = handleBlankListColumn(columns[4]);
                
                // There may be multiple map locations for a gene
                String[] mapLocations = handleBlankListColumn(columns[7]);
                
                String fullName = handleBlankColumn(columns[11].substring(0,Math.min(columns[11].length(), 250)));
                Set flybaseSet = new LinkedHashSet(); 
                Set mgiSet = new LinkedHashSet(); 
                Set rgdSet = new LinkedHashSet(); 
                
                // External database refs are spread across next two input columns:
                //   LocusLink (columns[3]) contains 0 or 1 of: MGI, RGD
                if (columns[3].indexOf(":") != -1) {
                    String[] link = columns[3].split(":"); 
                    populateDBLinkSets(link, flybaseSet, mgiSet, rgdSet);
                }
                
                //   dbXref (columns[5]) contains 0 or more of: FLYBASE/FlyBase, MGD/MGI, RGD
                if (columns[5].indexOf(":") != -1) {
                    // If there are multiple, they're pipe-delimited
                    String[] entries = columns[5].split(INPUT_LIST_DELIM);
                    for (int i = 0; i < entries.length; i++) {
                        String[] link = entries[i].split(":");
                        populateDBLinkSets(link, flybaseSet, mgiSet, rgdSet);
                    }
                }

                // Write gene info to Info file
                writeToInfoFile(taxonID, ENTREZ_GENE_ID_TYPE, entrezGeneID,chromosome, insertListDelim(mapLocations));
                String[] loc=new String[2];
                loc[0]=chromosome;
                loc[1]=insertListDelim(mapLocations);
                egLocations.put(entrezGeneID,loc);
                
                // Full Names, Gene Symbols and Synomyms are written to both the Info and Links files
                if (!fullName.equals("")) {
                    writeToInfoFile(taxonID,FULL_NAME_TYPE,fullName,chromosome, insertListDelim(mapLocations));
                    writeToLinksFile(ENTREZ_GENE_ID_TYPE,entrezGeneID,FULL_NAME_TYPE,fullName);
                }
                if (! geneSymbol.equals("")) {
                    writeToInfoFile(taxonID,GENE_SYMBOL_TYPE,geneSymbol,chromosome, insertListDelim(mapLocations));
                    writeToLinksFile(ENTREZ_GENE_ID_TYPE,entrezGeneID,GENE_SYMBOL_TYPE,geneSymbol);
                }
                
                for (int i = 0; i < synonyms.length; i++) {
                    String synonym = synonyms[i].trim();
                    writeToInfoFile(taxonID, SYNONYM_TYPE, synonym,chromosome, insertListDelim(mapLocations));
                    writeToLinksFile(ENTREZ_GENE_ID_TYPE, entrezGeneID,
                            SYNONYM_TYPE, synonym);
                }
                
                // The external database links and fullName are written to only the Links file
                writeCollectionToLinksFile(ENTREZ_GENE_ID_TYPE,entrezGeneID,FLY_BASE_ID_TYPE,flybaseSet);
                writeCollectionToLinksFile(ENTREZ_GENE_ID_TYPE,entrezGeneID,MGI_ID_TYPE,mgiSet);
                writeCollectionToLinksFile(ENTREZ_GENE_ID_TYPE,entrezGeneID,RGD_ID_TYPE,rgdSet);
            }            
        }

        reader.close();
        return egLocations;
    }

    /*
     * Each link consists of a database name and ID, formatted as "DB:ID". Based
     * on the "DB" portion of the link, the ID is added to the appropriate set
     * (FlyBase, MGI, or RGD). Note that MGI IDs sometimes have the database
     * name given as "MGD" (not "MGI"). Also note that MGI database requires the
     * "MGI:" prefix, which is added back to the ID before adding it to the MGI
     * ID Set.
     */
    private void populateDBLinkSets(String[] link, Set flybaseSet, Set mgiSet, Set rgdSet) {
        String dbName = link[0].trim();
        String dbID = link[1].trim();
        if (dbName.equalsIgnoreCase("FlyBase")) {
            flybaseSet.add(dbID);
        } else if (dbName.equalsIgnoreCase("MGI") || dbName.equalsIgnoreCase("MGD")) {
            // Note: MGD ID's should always start with "MGI:"
            mgiSet.add("MGI:" + dbID);
        } else if (dbName.equalsIgnoreCase("RGD")) {
            rgdSet.add(dbID);
        }
    }

    // "-" in the input file means the column is empty, but the output format
    // requires that an empty column actually be empty
    private String handleBlankColumn(String field) {
        String retField = field.trim();
        if (retField.equals("-")) {
            return "";
        } else {
            return retField;
        }
    }
    
    // List (or multi-item) input columns may also contain "-", indicating
    // emptiness; in these cases return an empty array; for all other cases,
    // split the list into an Array of Strings
    private String[] handleBlankListColumn(String field) {
        String[] items = field.split(INPUT_LIST_DELIM);
        if (items.length == 1 && items[0].trim().equals("-")) {
            return EMPTY_STRING_ARRAY;
        } else {
            return items;
        }
    }
    
    // NCBI accession numbers may contain a version number, looking something
    // like "accnum.version". Version numbers are removed, if present.
    private String removeVersionNumber(String id) {
        int ndx = id.indexOf(".");
        if (ndx != -1) {
            return id.substring(0,ndx);
        } else {
            return id;
        }
    }

    // Convert a String array into a single String with a comma delimiting each value
    private String insertListDelim(String[] array) {
        StringBuffer returnBuf = new StringBuffer();
        if (array.length > 0) {
            returnBuf.append(array[0].trim());
        }
        
        for (int i = 1; i < array.length; i++) {
            returnBuf.append(",").append(array[i].trim());
        }
        
        return returnBuf.toString();
    }

    
}
