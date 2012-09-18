package edu.ucdenver.ccp.iDecoder;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Map;

/**
 * Extends InputFileParser to handle Ensembl input files.
 *
 */
public class EnsemblParser extends InputFileParser {
    private static final String INPUT_SOURCE = "Ensembl";
    
    // Columns are comma-delimited
    private static final String INPUT_COLUMN_DELIM = ",";
    
    // key names for file properties entries

    private static final String ENSEMBL_INPUT_DIRECTORY_PROP_NM = "ensemblInputDirectory";
    private static final String ENSEMBL_FILENAME_LIST_PROP_NM = "ensemblFilenameList";

    public EnsemblParser(String outputDirectory) {
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
                                (String) fileMap.get(ENSEMBL_INPUT_DIRECTORY_PROP_NM));

        // There are multiple Ensembl input files, with each filename
        // separated by a comma; all have the same format
        String[] inputFiles = ((String) fileMap.get(ENSEMBL_FILENAME_LIST_PROP_NM))
                .split(",");

        initializeOutputFiles();
        
        long startTime; 
        String organismShort = "";
        for (int i = 0; i < inputFiles.length; i++) {
		System.out.println("processing this file "+inputFiles[i]+"::");
            organismShort = inputFiles[i].substring(0,2);
		System.out.println("organismShort = "+organismShort);
            String organism = (String) PropertiesHelper.getUniGenePrefixToOrganismMap().get(organismShort);
            String taxonID = (String) PropertiesHelper.getOrganismToTaxonIDMap().get(organism);

            startTime = System.currentTimeMillis();
            String fileSpec = createFileSpec(inputDirectory, inputFiles[i].trim());
            if(fileSpec.indexOf("link")>-1){//link only file just get links
                processLinkInputFile(fileSpec, taxonID);
            }else{//just get IDs
                processInputFile(fileSpec, taxonID);
            }
            System.out.println("processed " + fileSpec + "\t"
                    + (System.currentTimeMillis() - startTime) / 1000
                    + " seconds");
        }

        finalizeOutputFiles();
        
    }
    
    /*
     * The ensembl files are comma-delimited files containing primary ID
     * information, including mapping info. The only primary ID derived from these files
     * is the Ensembl ID. The format of the first 5 columns is:
     * 
     * Ensembl ID<,>chromosome<,>start_bp<,>end_bp<,>strand<,>Ensembl ID
     */
    private void processInputFile(String inputFilename, String taxonID) throws IOException {
	BufferedReader reader = createInputFileReader(inputFilename);
        
	String line;
	String[] columns;
        
        // Skip the first line
        line = reader.readLine();

	while (reader.ready()) {
		line = reader.readLine();
		columns = line.split(INPUT_COLUMN_DELIM);
            
		String chromosome = columns[1].trim();
		//
		// For some reason, there are chromosome values like 'NT_999...'.  Ignore records containing these
		if (chromosome.length() > 2) {
			continue;
		}
		String ensemblID = columns[0].trim();
		String strand = "";
	
		// columns[1] == chromosome
		// columns[2] == start base pair
		// columns[3] == end base pair
		// columns[4] == strand (1 or -1)
		// concat base pairs and strand into "start-end (+/-)"
		if (columns[4].trim().equals("1")) {
			strand = "+";
		} else if (columns[4].trim().equals("-1")) {
			strand = "-";
		}
		String mapLocation = getMapLocation(columns[2], columns[3], strand);
            
		writeToInfoFile(taxonID,ENSEMBL_ID_TYPE,ensemblID,chromosome,mapLocation);
	}
        
	reader.close();
    }
    /*
     * The ensembl link files are comma-delimited files containing link
     * information, including mapping info. The only links provided are for
     * linking Ensembl genes to Ensembl Transcripts.  This is needed by iDecoder
     * to translate Affy Probeset IDs to Ensembl Gene IDs.
     * The format of the first 2 columns is:
     * 
     * Ensembl Gene ID<,>Ensembl Transcript ID
     */
    private void processLinkInputFile(String inputFilename, String taxonID) throws IOException {
	BufferedReader reader = createInputFileReader(inputFilename);
        
	String line;
	String[] columns;
        
        // Skip the first line
        line = reader.readLine();

	while (reader.ready()) {
		line = reader.readLine();
		columns = line.split(INPUT_COLUMN_DELIM);
		String ensemblGeneID = columns[0].trim();
		String ensemblTransID = columns[1].trim();            
		writeToLinksFile(ENSEMBL_ID_TYPE,ensemblGeneID,ENSEMBL_ID_TYPE,ensemblTransID);
	}
        
	reader.close();
    }
}
