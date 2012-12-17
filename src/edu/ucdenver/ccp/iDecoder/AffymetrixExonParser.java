package edu.ucdenver.ccp.iDecoder;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

/**
 * Extends InputFileParser to handle Affymetrix exon input files.
 * 
 */
public class AffymetrixExonParser extends InputFileParser {
    private static final String INPUT_SOURCE = "AffymetrixExon";

    // key names for file properties entries
    private static final String AFFY_INPUT_DIRECTORY_PROP_NM = "affyInputDirectory";
    private static final String AFFY_PROBESET_FILENAMES= "affyExonProbesetFilenameList";
    private static final String AFFY_TRANSCRIPT_FILENAMES= "affyExonTranscriptFilenameList";

    // Columns are comma-separated, but values are surrounded by quotes; so the
    // real delimiter is: ","
    private static final String INPUT_COLUMN_DELIM = "\",\"";

    // Some columns pertain to more than one value (e.g., gene ID), and are
    // separated by a space followed by three slashes followed by a space
    private static final String INPUT_LIST_DELIM = " /// ";

    // Within the list, values are 
    // separated by a space followed by two slashes followed by a space
    private static final String WITHIN_GENE_DELIM = " // ";

    // "Blank" cells are represented in the input file by three hyphens
    private static final String BLANK_CELL = "---";

    public AffymetrixExonParser(String outputDirectory) {
        super(outputDirectory);
    }

    // javadoc in superclass
    public String getInputSource() {
        return INPUT_SOURCE;
    }

    // javadoc in superclass
    public void processAllInputFiles() throws IOException {
        final Map fileMap = PropertiesHelper.getFileMap();

        String inputDirectory = createFileSpec((String) fileMap.get(INPUT_DIRECTORY), 
        			(String) fileMap.get(AFFY_INPUT_DIRECTORY_PROP_NM));

        // There are multiple Affy exon input files of each type -- probeset and transcript
        // Each type has a separate format.  Filenames are separated by a comma.
        String[] probesetFilenames = ((String) fileMap.get(AFFY_PROBESET_FILENAMES)).split(",");
        String[] transcriptFilenames = ((String) fileMap.get(AFFY_TRANSCRIPT_FILENAMES)).split(",");
        
        initializeOutputFiles();
        
        long startTime; 

        String organismShort = "";
        for (int i = 0; i < probesetFilenames.length; i++) {
		organismShort = probesetFilenames[i].substring(0,2); 
            	String chipName = (organismShort.equals("Mo") ? "Affymetrix GeneChip Mouse Exon 1.0 ST Array.probeset" : 
						(organismShort.equals("Ra") ? "Affymetrix GeneChip Rat Exon 1.0 ST Array.probeset" : "Unknown")); 
		String organism = (String) PropertiesHelper.getExonPrefixToOrganismMap().get(organismShort);
		String taxonID = (String) PropertiesHelper.getOrganismToTaxonIDMap().get(organism);

		startTime = System.currentTimeMillis();
	        String fileSpec = createFileSpec(inputDirectory,probesetFilenames[i].trim());
		processProbesetFile(fileSpec, taxonID, chipName);
		System.out.println("processed " + fileSpec + "\t"
			+ (System.currentTimeMillis() - startTime) / 1000 + " seconds");
	}
        
        for (int i = 0; i < transcriptFilenames.length; i++) {
		organismShort = transcriptFilenames[i].substring(0,2); 
            	String chipName = (organismShort.equals("Mo") ? "Affymetrix GeneChip Mouse Exon 1.0 ST Array.transcript" : 
						(organismShort.equals("Ra") ? "Affymetrix GeneChip Rat Exon 1.0 ST Array.transcript" : "Unknown")); 
		String organism = (String) PropertiesHelper.getExonPrefixToOrganismMap().get(organismShort);
		String taxonID = (String) PropertiesHelper.getOrganismToTaxonIDMap().get(organism);

		startTime = System.currentTimeMillis();
	        String fileSpec = createFileSpec(inputDirectory,transcriptFilenames[i].trim());
		processTranscriptFile(fileSpec, taxonID, chipName); 
		System.out.println("processed " + fileSpec + "\t"
			+ (System.currentTimeMillis() - startTime) / 1000 + " seconds");
	}
        
        finalizeOutputFiles();
    }

    /*
     * The Affymetrix exon probeset file contains one entry type per
     * column, as specified in the first row in the file.
     * 
     * A column may contain more than one entry. For instance, a probe set ID
     * may pertain to more than one gene, so the column for gene_assignment will
     * contain more than one ID, each separated by 3 slashes "///". Empty cells
     * contains three hyphens "---".
     * 
     * The only primary ID derived from this file is the Probe Set IDs (a.k.a., Affymetrix
     * ID). All other relevant columns contain link IDs to other databases.
     * 
     */
    private void processProbesetFile(String inputFilename, String taxonID, String chipName)
            throws IOException {
        BufferedReader reader = createInputFileReader(inputFilename);
        String line;
        String[] columns;

        while (reader.ready()) {
            line = reader.readLine();
            //System.out.println(line);
		if (line.substring(0,1).equals("#")) {
            		writeToErrorFile(line, "Comment");
			continue;
		}
            columns = line.split(INPUT_COLUMN_DELIM);

            // TEMP: There are some spurious carriage-returns in the middle of
            // cells in the input data, which look to the parser like a new row;
            // for now, dump the line to stderr and ignore the row
            if (columns.length < 39) {
            	writeToErrorFile(line, "Too few columns");
                continue;
            }

            // column[38] describes the design category of the probe set.  
            // Only use the 'main' probesets
            // this column will have residual quotes at the end (from the
            // split()), so use substring() to ignore them
            String probeset_type = columns[38].trim().replaceAll("\"", "");
            
            //System.out.println("Type:"+probeset_type);

            // If the probeset_type does not equal 'main', ignore it because it is a 
            // control probeset
            if (probeset_type.contains("control")||probeset_type.equals("probeset_type")) {
            	writeToErrorFile(line, "Affy control probe:");
                continue;
            }
            //old method of removing controls but removes additional genes that are not controls
            /*if (!probeset_type.equals("main")) {
            	writeToErrorFile(line, "Affy control probe:");
                continue;
            }*/

            // column[0] will have residual quotes at the beginning (from the
            // split()), so use substring() to ignore them
            String affyID = columns[0].trim().substring(1);

		// The chromosome column starts with 'chr'
		String chr = columns[1].substring(3);
		String strand = columns[2];
		String start = columns[3];
		String end = columns[4];

		String mapLocation = getMapLocation(start, end, strand);

            // columns may have a list of items, hence
            // the use of splitListColumns()
            String[] geneAssignments = splitListColumns(columns[9]);

            writeToInfoFile(taxonID, AFFY_ID_TYPE, affyID, chr, mapLocation, chipName);

		if (geneAssignments != null && geneAssignments.length > 0) {
			// Each of the items between the triple slashes ("///") contains 2 items delimited by double slashes ("//").
			// The first is either a Ref Seq ID, a Genbank ID, or an Ensembl ID, and the second is a gene symbol.
			Set<String> refSeqIDs = new TreeSet<String>();
			Set<String> geneSymbols = new TreeSet<String>();
			Set<String> ensemblIDs = new TreeSet<String>();
			Set<String> genbankIDs = new TreeSet<String>();
			for (int i = 0; i < geneAssignments.length; i++) {
        			String[] subItems = geneAssignments[i].split(WITHIN_GENE_DELIM);
				String id = subItems[0];
				String idType = (isRefSeq(id) ? REF_SEQ_RNA_ID_TYPE : (isEnsembl(id) ? ENSEMBL_ID_TYPE : NCBI_RNA_ID_TYPE));
				String geneSymbol = subItems[1];
				if (idType.equals(REF_SEQ_RNA_ID_TYPE)) {
					refSeqIDs.add(id);
				} else if (idType.equals(ENSEMBL_ID_TYPE)) {
					ensemblIDs.add(id);
				} else if (idType.equals(NCBI_RNA_ID_TYPE)) {
					genbankIDs.add(id);
				}
				geneSymbols.add(geneSymbol);
			}
            		writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, REF_SEQ_RNA_ID_TYPE, refSeqIDs);
			writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, NCBI_RNA_ID_TYPE, genbankIDs);
			writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, ENSEMBL_ID_TYPE, ensemblIDs);
			writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, GENE_SYMBOL_TYPE, geneSymbols);
		}
        }

        reader.close();
    }
    /*
     * The Affymetrix exon transcript file contains one entry type per
     * column, as specified in the first row in the file.
     * 
     * A column may contain more than one entry. For instance, a transcript ID
     * may pertain to more than one gene, so the column for gene_assignment will
     * contain more than one ID, each separated by 3 slashes "///". Empty cells
     * contains three hyphens "---".
     * 
     * The only primary ID derived from this file is the Probe Set IDs (a.k.a., Affymetrix
     * ID). All other relevant columns contain link IDs to other databases.
     * 
     */
    private void processTranscriptFile(String inputFilename, String taxonID, String chipName)
            throws IOException {
        BufferedReader reader = createInputFileReader(inputFilename);
        String line;
        String[] columns;

        while (reader.ready()) {
            line = reader.readLine();
            //System.out.println(line);
            //writeToDebugFile(line);
		if (line.substring(0,1).equals("#")) {
            		writeToErrorFile(line, "Comment");
			continue;
		}
            columns = line.split(INPUT_COLUMN_DELIM);

            // TEMP: There are some spurious carriage-returns in the middle of
            // cells in the input data, which look to the parser like a new row;
            // for now, dump the line to stderr and ignore the row
            if (columns.length < 17) {
            	writeToErrorFile(line, "Too few columns");
                continue;
            }

            // column[16] describes the design category of the probe set.  
            // Only use the 'main' probesets
            // this column will have residual quotes at the end (from the
            // split()), so use substring() to ignore them
            String transcript_type = columns[16].trim().replaceAll("\"", "");
            //System.out.println("type"+transcript_type);
            // If the transcript_type does not equal 'main', ignore it because it is a 
            // control probeset
            
            if (transcript_type.contains("control")||transcript_type.equals("category")) {
            	writeToErrorFile(line, "Affy control probe:");
                continue;
            }/*else if(!transcript_type.equals("main")){
                System.out.println("NOT MAIN:"+line);
            }*/
            
            if(columns[2].length()==0){
                writeToErrorFile(line, "NO LOCATION:");
                continue;
            }
            /*if (!transcript_type.equals("main")) {
            	writeToErrorFile(line, "Affy control probe:");
                continue;
            }*/

            // column[0] will have residual quotes at the beginning (from the
            // split()), so use substring() to ignore them
            String affyID = columns[0].trim().substring(1);

		// The chromosome column starts with 'chr'
		String chr = columns[2].substring(3);
		String strand = columns[3];
		String start = columns[4];
		String end = columns[5];

		String mapLocation = getMapLocation(start, end, strand);

            // columns may have a list of items, hence
            // the use of splitListColumns()
            String[] geneAssignments = splitListColumns(columns[7]);

            writeToInfoFile(taxonID, AFFY_ID_TYPE, affyID, chr, mapLocation, chipName);

		if (geneAssignments != null && geneAssignments.length > 0) {
			// Each of the items between the triple slashes ("///") contains 5 items delimited by double slashes ("//").
			// The first is either a Ref Seq ID, a Genbank ID, or an Ensembl ID, the second is a gene symbol, and the fifth is 
			// an Entrez gene ID.
			Set<String> refSeqIDs = new TreeSet<String>();
			Set<String> ensemblIDs = new TreeSet<String>();
			Set<String> genbankIDs = new TreeSet<String>();
			Set<String> geneSymbols = new TreeSet<String>();
			Set<String> entrezGeneIDs = new TreeSet<String>();
			for (int i = 0; i < geneAssignments.length; i++) {
        			String[] subItems = geneAssignments[i].split(WITHIN_GENE_DELIM);
				String id = subItems[0];
				String idType = (isRefSeq(id) ? REF_SEQ_RNA_ID_TYPE : (isEnsembl(id) ? ENSEMBL_ID_TYPE : NCBI_RNA_ID_TYPE));
				String geneSymbol = subItems[1];
				String entrezGeneID = subItems[4];
				if (idType.equals(REF_SEQ_RNA_ID_TYPE)) {
					refSeqIDs.add(id);
				} else if (idType.equals(ENSEMBL_ID_TYPE)) {
					ensemblIDs.add(id);
				} else if (idType.equals(NCBI_RNA_ID_TYPE)) {
					genbankIDs.add(id);
				}
				geneSymbols.add(geneSymbol);
				entrezGeneIDs.add(entrezGeneID);
			}
            		writeCollectionToInfoFile(taxonID, REF_SEQ_RNA_ID_TYPE, refSeqIDs, chr, mapLocation);
            		writeCollectionToInfoFile(taxonID, NCBI_RNA_ID_TYPE, genbankIDs, chr, mapLocation);
            		writeCollectionToInfoFile(taxonID, ENSEMBL_ID_TYPE, ensemblIDs, chr, mapLocation);
            		writeCollectionToInfoFile(taxonID, GENE_SYMBOL_TYPE, geneSymbols, chr, mapLocation);
            		writeCollectionToInfoFile(taxonID, ENTREZ_GENE_ID_TYPE, entrezGeneIDs, chr, mapLocation);

            		writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, REF_SEQ_RNA_ID_TYPE, refSeqIDs);
			writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, NCBI_RNA_ID_TYPE, genbankIDs);
			writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, ENSEMBL_ID_TYPE, ensemblIDs);
			writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, GENE_SYMBOL_TYPE, geneSymbols);
			writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, ENTREZ_GENE_ID_TYPE, entrezGeneIDs);
		}
        }

        reader.close();
    }

    // Most columns can contain a list of values; split the list into an array
    // of items, suppressing blank values.
    private String[] splitListColumns(String column) {
        String[] items = column.split(INPUT_LIST_DELIM);

        List<String> returnList = new ArrayList<String>();
        for (int i = 0; i < items.length; i++) {
            if (!items[i].trim().equals(BLANK_CELL)) {
                returnList.add(items[i].trim());
            }
        }

        return (String[]) returnList.toArray(new String[returnList.size()]);
    }

}
