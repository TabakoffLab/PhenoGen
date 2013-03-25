package edu.ucdenver.ccp.iDecoder;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * Extends InputFileParser to handle Affymetrix input files.
 * 
 */
public class AffymetrixParser extends InputFileParser {
    private static final String INPUT_SOURCE = "Affymetrix";

    // key names for file properties entries
    private static final String AFFY_INPUT_DIRECTORY_PROP_NM = "affyInputDirectory";
    private static final String AFFY_FILENAME_LIST_PROP_NM = "affyFilenameList";

    // Columns are comma-separated, but values are surrounded by quotes; so the
    // real delimiter is: ","
    private static final String INPUT_COLUMN_DELIM = "\",\"";

    // Some columns pertain to more than one value (e.g., gene ID), and are
    // separated by three slashes
    private static final String INPUT_LIST_DELIM = "///";

    // "Blank" cells are represented in the input file by three hyphens
    private static final String BLANK_CELL = "---";

    public AffymetrixParser(String outputDirectory) {
        super(outputDirectory);
    }

    // javadoc in superclass
    public String getInputSource() {
        return INPUT_SOURCE;
    }

    // javadoc in superclass
    public void processAllInputFiles() throws IOException {
        final Map taxonIDMap = PropertiesHelper.getOrganismToTaxonIDMap();
        final Map fileMap = PropertiesHelper.getFileMap();

        String inputDirectory = createFileSpec((String) fileMap.get(INPUT_DIRECTORY), 
        			(String) fileMap.get(AFFY_INPUT_DIRECTORY_PROP_NM));

        // There are multiple Affymetrix input files, with each filename
        // separated by a comma; all have the same format
        String[] inputFiles = ((String) fileMap.get(AFFY_FILENAME_LIST_PROP_NM))
                .split(",");

        initializeOutputFiles();

        long startTime;
        for (int i = 0; i < inputFiles.length; i++) {
            startTime = System.currentTimeMillis();
            String fileSpec = createFileSpec(inputDirectory, inputFiles[i].trim());
            processInputFile(fileSpec, taxonIDMap);
            System.out.println("processed " + fileSpec + "\t"
                    + (System.currentTimeMillis() - startTime) / 1000
                    + " seconds");
        }

        finalizeOutputFiles();

    }

    /*
     * Affymetrix CSV (comma-separated value) files contain one entry type per
     * column, and that entry type's name is specified in the first row of each
     * column. For example, according to the first row in the file, the first
     * column is named "Probe Set ID" (referred to here as "Affymetrix ID"), the
     * third column is "Species Scientific Name" (referred to here as
     * "Organism"), etc.
     * 
     * A column may contain more than one entry. For instance, a probe set ID
     * may pertain to more than one gene, so the column for Entrez Gene ID will
     * contain more than one ID, each separated by 3 slashes "///". Empty cells
     * contains three hyphens "---".
     * 
     * Primary IDs derived from these files are Probe Set ID (a.k.a., Affymetrix
     * ID), Gene Symbol, and Ensembl ID. All other relevant columns contain link
     * IDs to other databases.
     * 
     * Even though the files are supposed to be organism-specific, some rows
     * pertain to other organisms. Rows that do not contain a relevant organism
     * in the 3rd column are skipped. A Map containing relevant organisms is
     * passed as an argument.
     */
    private void processInputFile(String inputFilename, Map relevantTaxonIDMap)
            throws IOException {
        BufferedReader reader = createInputFileReader(inputFilename);
        String line;
        String[] columns;

        while (reader.ready()) {
            line = reader.readLine();
		if (line.substring(0,1).equals("#")) {
            		writeToErrorFile(line, "Comment");
			continue;
		}
            columns = line.split(INPUT_COLUMN_DELIM);

            // TEMP: There are some spurious carriage-returns in the middle of
            // cells in the input data, which look to the parser like a new row;
            // for now, dump the line to stderr and ignore the row
            if (columns.length < 29) {
            	writeToErrorFile(line, "Too few columns");
                continue;
            }

            // Get the organism name from columns[2], and see if it exists in the
            // passed-in relevant taxonomy Map by trying to get its taxonomy
            // ID; if not found, skip the row (irrelevant organism)
            String taxonID = (String) relevantTaxonIDMap.get(columns[2].trim());
            if (taxonID == null) continue;

            // column[0] will have residual quotes at the beginning (from the
            // split()), so use substring() to ignore them
            String affyID = columns[0].trim().substring(1);

            // If the affyID starts with 'AFFX-', ignore it because it is a 
            // control probeset
            if (affyID.substring(0,5).equals("AFFX-")) {
            	writeToErrorFile(line, "Affy control probe:");
                continue;
            }
            String geneChipArray = columns[1].trim();

            // remainder of columns may have a list of items, hence
            // the use of splitListColumns()
            String[] unigeneIDs = splitListColumns(columns[10]);
            String[] geneSymbols = splitListColumns(columns[14]);
            String[] ensemblIDs = splitListColumns(columns[17]);
            String[] entrezGeneIDs = splitListColumns(columns[18]);
            String[] swissProtIDs = splitListColumns(columns[19]);
            String[] refSeqProteinIDs = removeVersionNumbers(splitListColumns(columns[22]));
            String[] refSeqRNAIDs = removeVersionNumbers(splitListColumns(columns[23]));
            String[] flybaseIDs = splitListColumns(columns[24]);
            String[] mgiIDs = addMGIPrefix(splitListColumns(columns[27]));
            String[] rgdIDs = splitListColumns(columns[28]);
            
            
            
            //10/4/2012-SBM- Probesets need a location they do correspond to a location in the genome.
            String chr="",loc="";
            if(columns[12].startsWith("chr")){
                String orig=columns[12].substring(0,columns[12].indexOf("//"));
                chr=orig.substring(3,orig.indexOf(":"));
                loc=orig.substring(orig.indexOf(":")+1);
            }
            
            
            // OLD COMMENT FROM CHERYL
            // Note that chromosome and map location do not make sense for Affy
            // IDs (probe sets don't have a location)
            writeToInfoFile(taxonID, AFFY_ID_TYPE, affyID, chr, loc, geneChipArray);

            // Since gene symbol and Ensembl IDs are primary IDs, as well as
            // being link IDs, write them to both the info and links files.
            /*for (int i = 0; i < geneSymbols.length; i++) {
                String geneSymbol = geneSymbols[i];
                //writeToInfoFile(taxonID, GENE_SYMBOL_TYPE, geneSymbol,chr,loc);
                writeToLinksFile(AFFY_ID_TYPE, affyID, GENE_SYMBOL_TYPE, geneSymbol);
            }*/

            /*for (int i = 0; i < ensemblIDs.length; i++) {
                String ensemblID = ensemblIDs[i];
                //writeToInfoFile(taxonID, ENSEMBL_ID_TYPE, ensemblID,chr,loc);
                //writeToLinksFile(AFFY_ID_TYPE, affyID, ENSEMBL_ID_TYPE, ensemblID);
            }*/

            // The rest are link IDs only
            writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, UNIGENE_ID_TYPE,
                    Arrays.asList(unigeneIDs));
            writeCollectionToLinksFile(AFFY_ID_TYPE, affyID,
                    ENTREZ_GENE_ID_TYPE, Arrays.asList(entrezGeneIDs));
            writeCollectionToLinksFile(AFFY_ID_TYPE, affyID,
                    SWISS_PROT_ID_TYPE, Arrays.asList(swissProtIDs));
            writeCollectionToLinksFile(AFFY_ID_TYPE, affyID,
                    REF_SEQ_PROTEIN_ID_TYPE, Arrays.asList(refSeqProteinIDs));
            writeCollectionToLinksFile(AFFY_ID_TYPE, affyID,
                    REF_SEQ_RNA_ID_TYPE, Arrays.asList(refSeqRNAIDs));
            writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, FLY_BASE_ID_TYPE,
                    Arrays.asList(flybaseIDs));
            writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, MGI_ID_TYPE,
                    Arrays.asList(mgiIDs));
            writeCollectionToLinksFile(AFFY_ID_TYPE, affyID, RGD_ID_TYPE,
                    Arrays.asList(rgdIDs));
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

    // In the Affy input files, MGI ID's lack the necessary "MGI:" prefix, so
    // add them here.
    private String[] addMGIPrefix(String[] mgiIDs) {
        for (int i = 0; i < mgiIDs.length; i++) {
            mgiIDs[i] = "MGI:" + mgiIDs[i];
        }
        return mgiIDs;
    }

    // RefSeq accession numbers may contain a version number, looking something
    // like "accnum.version". Version numbers should be removed, if present.
    private String[] removeVersionNumbers(String[] ids) {
        for (int i = 0; i < ids.length; i++) {
            int ndx = ids[i].indexOf(".");

            if (ndx != -1) {
                ids[i] = ids[i].substring(0, ndx);
            }
        }
        return ids;
    }

}
