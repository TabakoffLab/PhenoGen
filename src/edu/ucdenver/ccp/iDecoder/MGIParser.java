package edu.ucdenver.ccp.iDecoder;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.Map;

/**
 * Extends InputFileParser to handle MGI input files.
 *
 */
public class MGIParser extends InputFileParser {
    private static final String INPUT_SOURCE = "MGI";
    private static final String ORGANISM_NAME = "Mus musculus";
    
    // Columns are tab-delimited
    private static final String INPUT_COLUMN_DELIM = "\t";
    
    // key names for file properties entries
    private static final String MGI_INPUT_DIRECTORY_PROP_NM = "mgiInputDirectory";
    private static final String MGI_COORDINATE_FILENAME_PROP_NM = "mgiCoordinateFilename";
    private static final String MGI_LINKS_FILENAME_PROP_NM = "mgiLinksFilename";

    public MGIParser(String outputDirectory) {
        super(outputDirectory);
    }
    
    // javadoc in superclass
    public String getInputSource() {
        return INPUT_SOURCE;
    }

    // javadoc in superclass
    public void processAllInputFiles() throws IOException {
        final String taxonID = (String) PropertiesHelper.getOrganismToTaxonIDMap().get(ORGANISM_NAME);
        final String unigenePrefix = (String) PropertiesHelper.getOrganismToUniGenePrefixMap().get(ORGANISM_NAME);
        final Map fileMap = PropertiesHelper.getFileMap();

        String inputDirectory = createFileSpec((String) fileMap.get(INPUT_DIRECTORY), 
        			(String) fileMap.get(MGI_INPUT_DIRECTORY_PROP_NM));
        
        // There are two input files, each with a different format
        String coordinateFilename = (String) fileMap.get(MGI_COORDINATE_FILENAME_PROP_NM);
        String linksFilename = (String) fileMap.get(MGI_LINKS_FILENAME_PROP_NM);
        
        initializeOutputFiles();
        
        long startTime = System.currentTimeMillis();
        String fileSpec = createFileSpec(inputDirectory,coordinateFilename);
        processMGICoordinateFile(fileSpec, taxonID);
        System.out.println("processed " + fileSpec + "\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
        
        startTime = System.currentTimeMillis();
        fileSpec = createFileSpec(inputDirectory,linksFilename);
        processMGILinksFile(fileSpec, taxonID, unigenePrefix); 
        System.out.println("processed " + fileSpec + "\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
        
        finalizeOutputFiles();
        
    }
    
    /*
     * The coordinate file is a tab-delimited file containing primary ID
     * information, including mapping info. Primary IDs derived from this file
     * include the MGI ID and gene symbol. The format of the first 9 columns is:
     * 
     * MGI ID<tab>type<tab>gene symbol<tab>name<tab>genomeID<tab>chromosome<tab>start bp<tab>end bp<tab>strand<tab>
     * 
     * The remaining columns are ignored. Note that the chromosome and base pair
     * info in columns 6-9 are termed "representative" in the file (as opposed
     * to "NCBI" and "Ensembl", which the file also contains).
     */
    private void processMGICoordinateFile(String inputFilename, String taxonID) throws IOException {
        BufferedReader reader = createInputFileReader(inputFilename);
        
        String line;
        String[] columns;
        
        while (reader.ready()) {
            line = reader.readLine();
            columns = line.split(INPUT_COLUMN_DELIM);
            
            // Row types include "Gene", "DNA Segment", "QTL", and others. All
            // but "Gene" are ignored.
            if (! columns[1].trim().equals("Gene")) continue;
            
            String mgiID = columns[0].trim();
            String geneSymbol = columns[2].trim();
            
            String chromosome = "", mapLocation = "";

            // If columns[5] is not "null", mapping information exists:
            //   columns[5] == chromosome
            //   columns[6] == start base pair
            //   columns[7] == end base pair
            //   columns[8] == strand (plus or minus)
            if (! columns[5].trim().equals("null")) {
                chromosome = columns[5].trim();
                // concat base pairs and strand into "start-end (+/-)"
                mapLocation = getMapLocation(columns[6], columns[7], columns[8]);
            }
            
            writeToInfoFile(taxonID,MGI_ID_TYPE,mgiID,chromosome,mapLocation);
            
            // Since gene symbol is a primary ID, as well as a link ID, write to
            // both info and links files
            if (! geneSymbol.equals("")) {
                writeToInfoFile(taxonID,GENE_SYMBOL_TYPE,geneSymbol);
                writeToLinksFile(MGI_ID_TYPE,mgiID,GENE_SYMBOL_TYPE,geneSymbol);
            }
        }
        
        reader.close();
    }

    /*
     * The MGI links file is a tab-delimited file containing links between MGI
     * IDs and external database IDs. There is one link per row in the input
     * file, resulting in one row in the output Links file. The format is
     * something like the following:
     * 
     * MGI ID<tab>Link ID<tab>Link DB name<tab>
     * 
     * Note that MGI DB names generally vary from those being used by the
     * parsers (and the iDecoder database).
     */
    private void processMGILinksFile(String inputFilename, String taxonID,
            String unigenePrefix) throws IOException {

        BufferedReader reader = createInputFileReader(inputFilename);

        String line;
        String[] columns;

        while (reader.ready()) {
            line = reader.readLine();
            columns = line.split(INPUT_COLUMN_DELIM);

            String mgiID = columns[0].trim();
            String linkID = columns[1].trim();
            String dbName = columns[2].trim();

            if (dbName.equals("Ensembl Gene Model")) {
                writeToInfoFile(taxonID, ENSEMBL_ID_TYPE, linkID);
                writeToLinksFile(MGI_ID_TYPE,mgiID,ENSEMBL_ID_TYPE,linkID);
            } else if (dbName.equals("Entrez Gene")) {
                writeToLinksFile(MGI_ID_TYPE,mgiID,ENTREZ_GENE_ID_TYPE,linkID);
            } else if (dbName.equals("HomoloGene")) {
                writeToLinksFile(MGI_ID_TYPE,mgiID,HOMOLOGENE_ID_TYPE,linkID);
            } else if (dbName.equals("RefSeq")) {
                // The MGI input file does not discriminate between RNA and
                // Protein RefSeq IDs. However, Protein IDs start with "NP",
                // "XP", and "ZP"; mRNA IDs start with "NM" and "XM"; and
                // RNA IDs start with "NR" or "XR". So, if the 2nd char is 'P',
                // it's a Protein ID, and if the 2nd char is 'M' or 'R', it's an
                // RNA ID.
                switch (linkID.charAt(1)) {
                case 'P':
                    // Protein Acc Num
                    writeToLinksFile(MGI_ID_TYPE,mgiID,REF_SEQ_PROTEIN_ID_TYPE,linkID);
                    break;
                case 'M':
                    // mRNA Acc Num
                    // just fall through to the next case since both are the same ID type
                case 'R':
                    // other RNA Acc Num
                    writeToLinksFile(MGI_ID_TYPE,mgiID,REF_SEQ_RNA_ID_TYPE,linkID);
                    break;
                }
            } else if (dbName.equals("Sequence DB")) {
                // "Sequence DB" == NCBI RNA ID type
                writeToLinksFile(MGI_ID_TYPE,mgiID,NCBI_RNA_ID_TYPE,linkID);
            } else if (dbName.equals("SWISS-PROT")) {
                writeToLinksFile(MGI_ID_TYPE,mgiID,SWISS_PROT_ID_TYPE,linkID);
            } else if (dbName.equals("UniGene")) {
                // The MGI input file does not contain the UniGene prefix, but
                // the prefix is necessary to find info in Entrez. So, prepend
                // the passed-in UniGene prefix before adding to list.
                writeToLinksFile(MGI_ID_TYPE,mgiID,UNIGENE_ID_TYPE,unigenePrefix + "." + linkID);
            }
        }
        
        reader.close();
    }

}
