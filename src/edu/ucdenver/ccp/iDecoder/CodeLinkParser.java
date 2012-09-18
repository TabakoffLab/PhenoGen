package edu.ucdenver.ccp.iDecoder;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * Extends InputFileParser to handle CodeLink input files.
 * 
 */
public class CodeLinkParser extends InputFileParser {
    private static final String INPUT_SOURCE = "CodeLink";

    // key names for file properties entries
    private static final String CODELINK_INPUT_DIRECTORY_PROP_NM = "codeLinkInputDirectory";
    private static final String CODELINK_FILENAME_LIST_PROP_NM = "codeLinkFilenameList";

    // Columns are comma-separated, but values are surrounded by quotes; so the
    // real delimiter is: ","
    private static final String INPUT_COLUMN_DELIM = "\",\"";

    // Some columns pertain to more than one value (e.g., gene ID), and are
    // separated by three slashes
    private static final String INPUT_LIST_DELIM = "///";

    // "Blank" cells are represented in the input file by three hyphens
    private static final String BLANK_CELL = "";

    public CodeLinkParser(String outputDirectory) {
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
        			(String) fileMap.get(CODELINK_INPUT_DIRECTORY_PROP_NM));


        // There are multiple CodeLink input files, with each filename
        // separated by a comma; all have the same format
        String[] inputFiles = ((String) fileMap.get(CODELINK_FILENAME_LIST_PROP_NM))
                .split(",");

        initializeOutputFiles();

        long startTime;
        String organismShort = "";
        for (int i = 0; i < inputFiles.length; i++) {
            organismShort = inputFiles[i].substring(0,2); 
            String organism = (String) PropertiesHelper.getUniGenePrefixToOrganismMap().get(organismShort);
            String taxonID = (String) PropertiesHelper.getOrganismToTaxonIDMap().get(organism);

            startTime = System.currentTimeMillis();
            String fileSpec = createFileSpec(inputDirectory, inputFiles[i].trim());
            processInputFile(fileSpec, taxonID);
            System.out.println("processed " + fileSpec + "\t"
                    + (System.currentTimeMillis() - startTime) / 1000
                    + " seconds");
        }

        finalizeOutputFiles();

    }

    /*
     * CodeLink CSV (comma-separated value) files contain one entry type per
     * column, and that entry type's name is specified in the first row of each
     * column. For example, according to the first row in the file, the first
     * column is named "Probe Set ID" (referred to here as "CodeLink ID"), the
     * second column is "NCBIAcc", etc.
     * 
     * A column may contain more than one entry. For instance, a probe set ID
     * may pertain to more than one gene, so the column for Entrez Gene ID will
     * contain more than one ID, each separated by 3 slashes "///". Empty cells
     * contains three hyphens "---".
     * 
     * Primary IDs derived from these files are Probe Set ID (a.k.a., CodeLink
     * ID), Gene Symbol, and Ensembl ID. All other relevant columns contain link
     * IDs to other databases.
     * 
     * Some rows contain "CODELINK UNIQUE" identifers.  These are skipped. 
     */
    private void processInputFile(String inputFilename, String taxonID)
            throws IOException {
        BufferedReader reader = createInputFileReader(inputFilename);
	String geneChipName = "";
	if (inputFilename.endsWith("MmUnisetI.csv")) {
		geneChipName = "CodeLink UniSet Mouse I Array";
	} else if (inputFilename.endsWith("MmWholeGenome.csv")) {
		geneChipName = "CodeLink Mouse Whole Genome Array";
	} else if (inputFilename.endsWith("RnWholeGenome.csv")) {
		geneChipName = "CodeLink Rat Whole Genome Array";
	}
        String organism = (String) PropertiesHelper.getTaxonIDToOrganismMap().get(taxonID);
        String line;
        String[] columns;

	// Skip the first line
        line = reader.readLine();
        while (reader.ready()) {
            line = reader.readLine();
            columns = line.split(INPUT_COLUMN_DELIM);


            // TEMP: There are some spurious carriage-returns in the middle of
            // cells in the input data, which look to the parser like a new row;
            // for now, dump the line to stderr and ignore the row
            if (columns.length < 20) {
            	writeToErrorFile(line, "Too few columns");
                continue;
            }

/*
            String codeLinkUnique = columns[1].trim();
            if (codeLinkUnique.equals("CODELINK UNIQUE")) { 
            	writeToErrorFile(line, "CodeLink Unique Record");
		continue;
	    }

*/
            // column[0] will have residual quotes at the beginning (from the
            // split()), so use substring() to ignore them
            String codeLinkID = columns[0].trim().substring(1);
            String chromosome = columns[7].trim();
		if (chromosome.length() > 9) {
			chromosome = "";
		}
            String mapLocation = getMapLocation(columns[13], columns[14], columns[15]);

            // Get the NCBIAcc name from columns[1], and see if it is "CODELINK UNIQUE".
            // If it is, skip the row 
		String [] ncbiRNAIDs = null;
		if (!columns[1].trim().equals("CODELINK UNIQUE")) {
	            ncbiRNAIDs = splitListColumns(columns[1]);
		}
            // remainder of columns may have a list of items, hence
            // the use of splitListColumns()
            String[] unigeneIDs = splitListColumns(columns[2]);
            String[] geneSymbols = splitListColumns(columns[4]);
            String[] swissProtIDs = splitListColumns(columns[11]);
            String[] mgiIDs_or_rgdIDs = splitListColumns(columns[16]);
            //String[] rgdIDs = addRGDPrefix(splitListColumns(columns[16]));
            String[] refSeqRNAIDs = removeVersionNumbers(splitListColumns(columns[17]));
            String[] refSeqProteinIDs = removeVersionNumbers(splitListColumns(columns[18]));
	    // The last column will have a trailing double-quote ("), so remove it first
            String[] ensemblIDs = splitListColumns(columns[19].substring(0, columns[19].length()-1));

            // Note that chromosome and map location do not make sense for CodeLink
            // IDs (probe sets don't have a location)
            writeToInfoFile(taxonID, CODELINK_ID_TYPE, codeLinkID, chromosome, mapLocation, geneChipName);

            // Write all ids to both the info and links files
		if (ncbiRNAIDs != null) {
            		for (int i = 0; i < ncbiRNAIDs.length; i++) {
                		String ncbiRNAID = ncbiRNAIDs[i];
                		writeToInfoFile(taxonID, NCBI_RNA_ID_TYPE, ncbiRNAID);
                		writeToLinksFile(CODELINK_ID_TYPE, codeLinkID, NCBI_RNA_ID_TYPE, ncbiRNAID);
            		}
		}

            for (int i = 0; i < unigeneIDs.length; i++) {
                String unigeneID = unigeneIDs[i];
                writeToInfoFile(taxonID, UNIGENE_ID_TYPE, unigeneID);
                writeToLinksFile(CODELINK_ID_TYPE, codeLinkID, UNIGENE_ID_TYPE, unigeneID);
            }

            for (int i = 0; i < geneSymbols.length; i++) {
                String geneSymbol = geneSymbols[i];
                writeToInfoFile(taxonID, GENE_SYMBOL_TYPE, geneSymbol);
                writeToLinksFile(CODELINK_ID_TYPE, codeLinkID, GENE_SYMBOL_TYPE, geneSymbol);
            }

            for (int i = 0; i < swissProtIDs.length; i++) {
                String swissProtID = swissProtIDs[i];
                writeToInfoFile(taxonID, SWISS_PROT_ID_TYPE, swissProtID);
                writeToLinksFile(CODELINK_ID_TYPE, codeLinkID, SWISS_PROT_ID_TYPE, swissProtID);
            }

            for (int i = 0; i < mgiIDs_or_rgdIDs.length; i++) {
                String mgiID_or_rgdID = mgiIDs_or_rgdIDs[i];
		if (organism.equals("Mus musculus")) {
                	writeToInfoFile(taxonID, MGI_ID_TYPE, mgiID_or_rgdID);
                	writeToLinksFile(CODELINK_ID_TYPE, codeLinkID, MGI_ID_TYPE, mgiID_or_rgdID);
		} else {
                	writeToInfoFile(taxonID, RGD_ID_TYPE, mgiID_or_rgdID);
                	writeToLinksFile(CODELINK_ID_TYPE, codeLinkID, RGD_ID_TYPE, mgiID_or_rgdID);
		}
            }

            for (int i = 0; i < refSeqRNAIDs.length; i++) {
                String refSeqRNAID = refSeqRNAIDs[i];
                writeToInfoFile(taxonID, REF_SEQ_RNA_ID_TYPE, refSeqRNAID);
                writeToLinksFile(CODELINK_ID_TYPE, codeLinkID, REF_SEQ_RNA_ID_TYPE, refSeqRNAID);
            }

            for (int i = 0; i < refSeqProteinIDs.length; i++) {
                String refSeqProteinID = refSeqProteinIDs[i];
                writeToInfoFile(taxonID, REF_SEQ_PROTEIN_ID_TYPE, refSeqProteinID);
                writeToLinksFile(CODELINK_ID_TYPE, codeLinkID, REF_SEQ_PROTEIN_ID_TYPE, refSeqProteinID);
            }

            for (int i = 0; i < ensemblIDs.length; i++) {
                String ensemblID = ensemblIDs[i];
                writeToInfoFile(taxonID, ENSEMBL_ID_TYPE, ensemblID);
                writeToLinksFile(CODELINK_ID_TYPE, codeLinkID, ENSEMBL_ID_TYPE, ensemblID);
            }

/*
            // The rest are link IDs only
            writeCollectionToLinksFile(CODELINK_ID_TYPE, codeLinkID, NCBI_RNA_ID_TYPE,
                    Arrays.asList(ncbiRNAIDs));
            writeCollectionToLinksFile(CODELINK_ID_TYPE, codeLinkID, UNIGENE_ID_TYPE,
                    Arrays.asList(unigeneIDs));
            writeCollectionToLinksFile(CODELINK_ID_TYPE, codeLinkID,
                    SWISS_PROT_ID_TYPE, Arrays.asList(swissProtIDs));
            writeCollectionToLinksFile(CODELINK_ID_TYPE, codeLinkID, RGD_ID_TYPE,
                    Arrays.asList(rgdIDs));
            writeCollectionToLinksFile(CODELINK_ID_TYPE, codeLinkID,
                    REF_SEQ_RNA_ID_TYPE, Arrays.asList(refSeqRNAIDs));
            writeCollectionToLinksFile(CODELINK_ID_TYPE, codeLinkID,
                    REF_SEQ_PROTEIN_ID_TYPE, Arrays.asList(refSeqProteinIDs));
*/
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

    // In the CodeLink input files, RGD ID's lack the necessary "RGD:" prefix, so
    // add them here.
    private String[] addRGDPrefix(String[] rgdIDs) {
        for (int i = 0; i < rgdIDs.length; i++) {
            rgdIDs[i] = "RGD:" + rgdIDs[i];
        }
        return rgdIDs;
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
