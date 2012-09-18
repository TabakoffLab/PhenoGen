package edu.ucdenver.ccp.iDecoder;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Extends InputFileParser to specifically handle FlyBase annotation data.
 */
public class FlyBaseParser extends InputFileParser {
    private static final String INPUT_SOURCE = "FlyBase";
    private static final String ORGANISM_NAME = "Drosophila melanogaster";
    
    // Regex representing the "tab" character
    private static final String INPUT_COLUMN_DELIM = "\t"; 
    
    // key names for file properties entries
    private static final String FLY_BASE_INPUT_DIRECTORY_PROP_NM = "flybaseInputDirectory";
    private static final String FLY_BASE_UNIPROT_FILENAME_LIST_PROP_NM = "flybaseUniprotFilename";
    private static final String FLY_BASE_GENEMAP_FILENAME_LIST_PROP_NM = "flybaseGeneMapFilename";

    // javadoc in superclass
    public String getInputSource() {
        return INPUT_SOURCE;
    }
    
    public FlyBaseParser(String outputDirectory) {
        super(outputDirectory);
    }

    // javadoc in superclass
    public void processAllInputFiles() throws IOException {
        final String taxonID = (String) PropertiesHelper.getOrganismToTaxonIDMap().get(ORGANISM_NAME);
        final Map fileMap = PropertiesHelper.getFileMap();
        
        String inputDirectory = createFileSpec((String) fileMap.get(INPUT_DIRECTORY), 
        			(String) fileMap.get(FLY_BASE_INPUT_DIRECTORY_PROP_NM));
        // there are 2 input files, each with a different format
        String uniprotFilename = (String) fileMap.get(FLY_BASE_UNIPROT_FILENAME_LIST_PROP_NM);
        String geneMapFilename = (String) fileMap.get(FLY_BASE_GENEMAP_FILENAME_LIST_PROP_NM);

        initializeOutputFiles();
        
        long startTime = System.currentTimeMillis();
        String fileSpec = createFileSpec(inputDirectory,uniprotFilename);
        processUniprotInputFile(fileSpec,taxonID); 
        System.out.println("processed " + fileSpec + "\t" + (System.currentTimeMillis() - startTime)/1000 + " seconds");        
        
        startTime = System.currentTimeMillis();
        fileSpec = createFileSpec(inputDirectory,geneMapFilename);
        processGeneMapInputFile(fileSpec,taxonID);
        System.out.println("processed " + fileSpec + "\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");

        finalizeOutputFiles();
    }
    
    /*
     * The FlyBase Uniprot input file puts the gene symbol 
     * first on the line followed by the FlyBase ID and other external IDs. Each FlyBase ID (and it's
     * information) may appear on multiple rows. The format is:
     * 
     * Gene Symbol <tab> FlyBase ID <tab> nucleotide_accession <tab> na_based_protein_accession <tab> UniprotKB/Swiss-Prot/TrEMBL_accession
     * 
     * columns 3 (nucleotide_accession) is ignored for all rows.
     */    
    private void processUniprotInputFile(String inputFilename, String taxonID) throws IOException {
        BufferedReader reader = createInputFileReader(inputFilename);
        String line;
        String[] columns;
        
        // This Set is used to keep track of FlyBase ID's already encountered so
        // that they are not emitted repeatedly in the info file.
        Set processedFlybaseIDSet = new HashSet();
        
        while (reader.ready()) {
            line = reader.readLine();
            columns = line.split(INPUT_COLUMN_DELIM);
            
	// if a column begins with "#", it is a comment.  
            if (columns[0].equals("") || columns[0].startsWith("#")) {
                continue;
            }

            String geneSymbol = excludeAllele(columns[0]);
            
            // A backslash "\" in the gene symbol means that this gene
            // pertains to a species other than Drosophila melanogaster
            // and should be skipped.
            if (geneSymbol.indexOf("\\") != -1) {
                continue;
            }
            
            String flybaseID = excludeAllele(columns[1]);
            
            // If this FlyBase ID hasn't already been encountered, write its
            // info to the Info file (and add it to the processed ID Set)
            if (! processedFlybaseIDSet.contains(flybaseID)) {
                writeToInfoFile(taxonID,FLY_BASE_ID_TYPE,flybaseID);
                writeToInfoFile(taxonID,GENE_SYMBOL_TYPE,geneSymbol);
                writeToLinksFile(FLY_BASE_ID_TYPE,flybaseID,GENE_SYMBOL_TYPE,geneSymbol);
                processedFlybaseIDSet.add(flybaseID);
            } 
            
	if (columns.length >3) {
		String ncbiProteinID = columns[3];
		if (!ncbiProteinID.equals("")) {
			writeToLinksFile(FLY_BASE_ID_TYPE,flybaseID,NCBI_PROTEIN_ID_TYPE,ncbiProteinID);
		}
		if (columns.length >4) {
            		String swissProtID = columns[4];
			if (!swissProtID.equals("")) {
				writeToLinksFile(FLY_BASE_ID_TYPE,flybaseID,SWISS_PROT_ID_TYPE,swissProtID);
			}
		}
	}
    	}
        
        reader.close();
    }

    /*
     * The FlyBase GeneMap input file puts the gene symbol 
     * first on the line, not the FlyBase ID. 
     * The format is:
     * 
     * Gene Symbol <tab> FlyBase ID <tab> chromosome <tab> recombination loc <tab> cytogenetic_loc <tab> sequence_loc
     * 
     * Note: if the gene symbol contains a
     * backslash ("\"), the row pertains to a species other than Drosophila
     * melanogaster (e.g., "Dana\btl", which is gene symbol "btl" for
     * "Drosophila ananassae"); these entries are ignored. 
     * column 1 (Gene Symbol) is not written from this file
     * columns 3 (chromosome), columns 4 (recombination loc) and 5 (cytogenic loc) are ignored for all rows.
     */    
    private void processGeneMapInputFile(String inputFilename, String taxonID) throws IOException {
        BufferedReader reader = createInputFileReader(inputFilename);
        String line;
        String[] columns;
        
        // This Set is used to keep track of FlyBase ID's already encountered so
        // that they are not emitted repeatedly in the info file.
        Set processedFlybaseIDSet = new HashSet();
        
        while (reader.ready()) {
            line = reader.readLine();
            columns = line.split(INPUT_COLUMN_DELIM);

	// if a column begins with "#", it is a comment
            if (columns[0].equals("") || columns[0].startsWith("#")) {
                continue;
            }
            
            String geneSymbol = excludeAllele(columns[0]);
            
            // A backslash "\" in the gene symbol means that this gene
            // pertains to a species other than Drosophila melanogaster
            // and should be skipped.
            if (geneSymbol.indexOf("\\") != -1) {
                continue;
            }
            
            // No chromosome column exists in the input file, but it may
            // be derived from the genetic map column for some entries
            String chromosome = "";
            String geneticMap;
            
            // If genetic mapping information is included, the number of
            // columns returned by split() will be at least 5.
            if (columns.length >= 6) {
                geneticMap = columns[5].trim();

                // If the geneticMap string
                //   - starts with 1 or 2 alphanumeric characters
                //   - is followed immediately by a colon
                //   - contains zero or more characters after the colon
                // it fits the chromosone or chromosone + location pattern, and it should be split
                // between the chromosome and geneticMap variables. Otherwise,
                // it falls into the "other" category, and geneticMap should be
                // left as is, with chromosome left empty.
                if (Pattern.matches("\\w{1,2}:.*", geneticMap)) {
                    int ndx = geneticMap.indexOf(":");
                    chromosome = geneticMap.substring(0, ndx);
                    geneticMap = geneticMap.substring(ndx + 1);

			// concat base pairs and strand into "start-end (+/-)"
                	int strandIdx = geneticMap.indexOf("(");
			String strand = "";
			if (geneticMap.substring(strandIdx+1,strandIdx+3).equals("1)")) {
				strand = "+";
			} else {
				strand = "-";
			}
                    	geneticMap = geneticMap.substring(0,strandIdx) + " (" + strand + ")";
			
			geneticMap = geneticMap.replaceAll("\\.\\.", "-"); 
                } 
            } else {
                // no genetic map info for this row (5 or fewer columns)
                geneticMap = "";
            }
            
            String flybaseID = excludeAllele(columns[1]);
            
            // If this FlyBase ID hasn't already been encountered, write its
            // info to the Info file (and add it to the processed ID Set)
            if (! processedFlybaseIDSet.contains(flybaseID)) {
                writeToInfoFile(taxonID,FLY_BASE_ID_TYPE,flybaseID, chromosome, geneticMap);
                processedFlybaseIDSet.add(flybaseID);
            } 
            
        }
        reader.close();
    }

    // A FlyBase ID or gene symbol may also include an allele, which is set off
    // with "square brackets", for example:
    //     FBgn0011236[FBal0008011] | ken[02970]
    // The allele should be excluded by removing the bracketed text (including
    // the brackets).
    private String excludeAllele(String gene) {
        int ndx = gene.indexOf("[");
        if (ndx != -1) {
            return gene.substring(0,gene.indexOf("[")).trim();
        } else {
            return gene.trim();
        }
    }
    
}
