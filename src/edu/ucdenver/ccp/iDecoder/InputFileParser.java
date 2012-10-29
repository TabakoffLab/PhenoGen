package edu.ucdenver.ccp.iDecoder;
import java.io.*;
import java.util.Collection;
import java.util.Iterator;
import java.util.regex.Pattern;

/**
 * Abstract class representing a file parser that converts annotation data files
 * in various formats to iDecoder-compatible output files. The number and format
 * of input files will vary depending on the data source, but there are always
 * only two output files per source: XXXInfo.out and XXXLinks.out (where XXX is
 * replaced by the data source name). The actual handling of the input files is
 * defined in the individual parser, but each parser must implement the
 * <code>processAllInputFiles</code> method, which kicks the process off.
 */
public abstract class InputFileParser {
    // output files are in the form XXXInfo.out and XXXLinks.out where XXX
    // represents the input source name (see also getInputSource() )
    private static final String LINKS_FILE_SUFFIX = "Links";
    private static final String INFO_FILE_SUFFIX = "Info";
    private static final String ERROR_FILE_SUFFIX = "Bad";
    private static final String DEBUG_FILE_SUFFIX = "Debug";
    
    // This RegEx will catch RefSeq identifiers used for RNA sequences and
    // Proteins in NCBI/EMBL/DDBJ. It is not intended to catch all types of
    // RefSeq Seq identifiers (e.g., Genomic IDs are not caught). As written it
    // could catch non-existent ones (e.g., "ZM_"), though that pattern is an
    // invalid non-RefSeq ID name pattern and won't appear in a field containing
    // NCBI IDs. See Ch. 18 of the NCBI Handbook for more details.
    private static final String REF_SEQ_ID_REGEX = "[NXZ][MRP]_.*";

    // This RegEx will catch Ensembl identifiers 
    private static final String ENSEMBL_ID_REGEX = "ENS.*";

    // column terminator, not delimiter; character sequence should not appear in data
    private static final String OUTPUT_COLUMN_TERM = "<->";

    // location of input files
    protected static final String INPUT_DIRECTORY = "inputDirectory";
    
    // Note: these names must match exactly those used in the database
    protected static final String AFFY_ID_TYPE = "Affymetrix ID";
    protected static final String CODELINK_ID_TYPE = "CodeLink ID";
    protected static final String RGD_ID_TYPE = "RGD ID";
    protected static final String MGI_ID_TYPE = "MGI ID";
    protected static final String FLY_BASE_ID_TYPE = "FlyBase ID";
    protected static final String NCBI_PROTEIN_ID_TYPE = "NCBI Protein ID";
    protected static final String NCBI_RNA_ID_TYPE = "NCBI RNA ID";
    protected static final String REF_SEQ_RNA_ID_TYPE = "RefSeq RNA ID";
    protected static final String REF_SEQ_PROTEIN_ID_TYPE = "RefSeq Protein ID";
    protected static final String ENSEMBL_ID_TYPE = "Ensembl ID";
    protected static final String ENTREZ_GENE_ID_TYPE = "Entrez Gene ID";
    protected static final String HOMOLOGENE_ID_TYPE = "Homologene ID";
    protected static final String SYNONYM_TYPE = "Synonym";
    protected static final String GENE_SYMBOL_TYPE = "Gene Symbol";
    protected static final String SWISS_PROT_NAME_TYPE = "SwissProt Name";
    protected static final String SWISS_PROT_ID_TYPE = "SwissProt ID";
    protected static final String UNIGENE_ID_TYPE = "UniGene ID";
    protected static final String FULL_NAME_TYPE = "Full Name";
    

    // infoWriter writes annotation information about the primary IDs,
    // and linkWriter writes links between primary IDs (i.e., those from the
    // data provider) and IDs from other databases
    // errorWriter writes any records that were skipped
    protected BufferedWriter infoWriter;
    protected BufferedWriter linkWriter;
    protected BufferedWriter errorWriter;
    protected BufferedWriter debugWriter;
    
    // holds the Regex pattern for RefSeq NCBI IDs; see the REF_SEQ_ID_REGEX
    // constant above for more details
    private Pattern refSeqPattern;

    // holds the Regex pattern for EnsemblIDs; see the ENSEMBL_ID_REGEX
    // constant above for more details
    private Pattern ensemblPattern;
    
    // holds the output directory to contain the info and links files output by the parsers
    private String outputDirectory;

    // constructor is protected because this class is abstract (and
    // uninstantiable), but subclass constructors call it
    protected InputFileParser(String outputDirectory) {
        this.outputDirectory = outputDirectory;
    }
    
    /**
     * Returns the input source (NCBI, SwissProt, RGD, etc.) for this parser.
     * 
     * @return a String containing the input source name.
     */
    public abstract String getInputSource(); 
    
    /**
     * Parse all input files from a single source and output the relevant
     * information to the Info and Links output files. The method is implemented
     * by each parser to handle the number and type of input files relevant to
     * its data source.
     * 
     * @throws IOException
     *             if any file-related problems are encountered
     */
    public abstract void processAllInputFiles() throws IOException;

    /**
     * Creates the info and links files in the directory provided in the
     * Parser's constructor and then initializes the infoWriter and linkWriter
     * attributes.
     * Also creates the error and debug files
     * 
     * @throws IOException
     *             if there is a problem creating the files or the Writers
     */
    protected void initializeOutputFiles() throws IOException {
        infoWriter = createOutputFileWriter(createOutputFileSpec(this.outputDirectory,INFO_FILE_SUFFIX));
        linkWriter = createOutputFileWriter(createOutputFileSpec(this.outputDirectory,LINKS_FILE_SUFFIX));
        errorWriter = createOutputFileWriter(createOutputFileSpec(this.outputDirectory,ERROR_FILE_SUFFIX));
        debugWriter = createOutputFileWriter(createOutputFileSpec(this.outputDirectory,DEBUG_FILE_SUFFIX));
    }
    
    // Creates a fully-qualified output file name in the form "XXXInfo.out" or "XXXLinks.out"
    // where "XXX" represents the input source name (e.g., NCBI or SwissProt).
    private String createOutputFileSpec(String outputDirectory, String fileSuffix) {
        return createFileSpec(outputDirectory,getInputSource() + fileSuffix + ".out");
    }
    
    /**
     * Creates a String containing a fully-qualified file name (in
     * system-independent form) constructed from the <code>directory</code>
     * and <code>filename</code> parameters.
     * 
     * @param directory
     *            the fully-qualified directory, relative to root
     * @param filename
     *            the file name only (no directory information)
     * @return the fully-qualified file name, with the correct number and type
     *         of slashes
     */
    protected String createFileSpec(String directory, String filename) {
        switch (directory.charAt(directory.length()-1)) {
        case '/':
            // slash is already there, so just append filename
            return directory + filename;
        case '\\':
            // with a backslash at the end, assume the whole path is in DOS format and correct it
            return directory.replace('\\','/') + filename;
        default:
            // slash is missing, so add it before appending filename
            return directory + "/" + filename;
        }
    }

    // Creates a BufferedWriter with default buffer size given a fully-qualified output file name.
    private BufferedWriter createOutputFileWriter(String outputFilename) throws IOException {
        BufferedWriter writer = new BufferedWriter(new FileWriter(outputFilename));
        return writer;
    }
    
    /**
     * Closes the info and links files and their associated Writers.
     * 
     * @throws IOException if there is a problem closing the Files or Writers
     */
    protected void finalizeOutputFiles() throws IOException {
        infoWriter.close();
        linkWriter.close();
        errorWriter.close();
        debugWriter.close();
    }
    
    /**
     * Creates a BufferedReader with default buffer size given a fully-qualified
     * input file name.
     * 
     * @param inputFilename
     *            the fully-qualified file name
     * @return a BufferedReader to access the file referred to in the
     *         inputFilenam param
     */
    protected BufferedReader createInputFileReader(String inputFilename) throws FileNotFoundException {
        BufferedReader reader = new BufferedReader(new FileReader(inputFilename));
        return reader;
    }

    /**
     * Writes records to the debug file as they appear in the input file 
     * 
     * @param record
     */
    protected void writeToDebugFile(String record) throws IOException {
        debugWriter.write(record);
        debugWriter.newLine();
    }

    /**
     * Writes records to the Error file as they appear in the input file 
     * 
     * @param badRecord
     * @param reason
     */
    protected void writeToErrorFile(String badRecord, String reason) throws IOException {
        errorWriter.write(reason + ":  " + badRecord);
        errorWriter.newLine();
    }

    /**
     * Writes links to the Links file in the following format:
     * <br><tt>
     * getInputSource() + sourceIdenType + sourceID + destIdenType + destID +
     * </tt><br>
     * Note that the "plus sign" is replaced by the appropriate column
     * terminator.
     * 
     * @see #getInputSource()
     */
    protected void writeToLinksFile(String sourceIdenType, String sourceID, String destIdenType, String destID) throws IOException {
        if(destID!=null&&!destID.equals("null")){
            linkWriter.write(getInputSource() + OUTPUT_COLUMN_TERM + sourceIdenType + OUTPUT_COLUMN_TERM + 
			sourceID + OUTPUT_COLUMN_TERM + destIdenType + OUTPUT_COLUMN_TERM + destID + OUTPUT_COLUMN_TERM);
            linkWriter.newLine();
        }
    }

    /**
     * Returns <code>true</code> for RefSeq NCBI IDs (NM_12345) and
     * <code>false</code> for non-RefSeq NCBI IDs (e.g., U12345).
     */
    protected boolean isRefSeq(String ncbiID) {
        if (refSeqPattern == null) {
            refSeqPattern = Pattern.compile(REF_SEQ_ID_REGEX);
        }
        return refSeqPattern.matcher(ncbiID).matches();
    }

    /**
     * Returns <code>true</code> for Ensembl IDs (ENS***) and
     * <code>false</code> for non Ensembl IDs (e.g., U12345).
     */
    protected boolean isEnsembl(String thisID) {
        if (ensemblPattern == null) {
            ensemblPattern = Pattern.compile(ENSEMBL_ID_REGEX);
        }
        return ensemblPattern.matcher(thisID).matches();
    }

	/**
	 * Creates a string containing the location of the identifier in the form "start-stop(strand)"
	 *
	 * @param start	start location
	 * @param end	end location
	 * @param strand	"+" or "-"
	 * @return string containing the location
	 */
	protected String getMapLocation(String start, String end, String strand) {
		String mapLocation = start.trim() + "-" + end.trim() + " (" + strand.trim() + ")";
		if (mapLocation.equals("- ()")) {
			mapLocation = "";
		}
		return mapLocation;
	}

    /**
     * Writes links to a file given one source ID and multiple destination IDs contained in a Collection.
     * Output format is identical to the <code>writeToLinksFile</code> method.
     * 
     * @see #writeToLinksFile(String, String, String, String)
     */
    protected void writeCollectionToLinksFile(String sourceIdenType, String sourceID, String destIdenType, Collection destIDCollection) throws IOException {
        for (Iterator iter = destIDCollection.iterator(); iter.hasNext();) {
            String destID = (String) iter.next();
            // It's possible that a few blank values made it into the
            // Collection; simply skip them
            if (destID.equals("")) continue;
            writeToLinksFile(sourceIdenType,sourceID,destIdenType,destID);
        }
    }
    
    /**
     * Writes identifiers to the Info file.
     * Output format is identical to the <code>writeToInfoFile</code> method.
     * 
     * @see #writeToInfoFile(String, String, String, String, String, String)
     */
    protected void writeCollectionToInfoFile(String taxonID, String idenType, Collection idCollection) throws IOException {
        this.writeCollectionToInfoFile(taxonID, idenType, idCollection, "", "");
    }
    
    /**
     * Writes identifiers to the Info file.
     * Output format is identical to the <code>writeToInfoFile</code> method.
     * 
     * @see #writeToInfoFile(String, String, String, String, String, String)
     */
    protected void writeCollectionToInfoFile(String taxonID, String idenType, Collection idCollection,String chromosome,String mapLocation) throws IOException {
        for (Iterator iter = idCollection.iterator(); iter.hasNext();) {
            String thisID = (String) iter.next();
            // It's possible that a few blank values made it into the
            // Collection; simply skip them
            if (thisID.equals("")) continue;
            writeToInfoFile(taxonID, idenType, thisID,chromosome,mapLocation);
        }
    }

    /**
     * Writes identifier info to the Info file. To be used when chromosome,
     * map location, and gene chip name are always unspecified (e.g., protein IDs).
     * 
     * @see #writeToInfoFile(String, String, String, String, String, String)
     */    
    protected void writeToInfoFile(String taxonID, String idenType, String identifier) throws IOException {
        writeToInfoFile(taxonID,idenType,identifier,"","","");
    }
    
    /**
     * Writes identifier info to the Info file. To be used when chromosome and map location
     * may be specified, but not gene chip name (e.g., gene IDs).
     * 
     * @see #writeToInfoFile(String, String, String, String, String, String)
     */
    protected void writeToInfoFile(String taxonID, String idenType, String identifier, String chromosome, String mapLocation) throws IOException {
        writeToInfoFile(taxonID,idenType,identifier,chromosome,mapLocation,"");
    }    
    
    /**
     * Writes identifier info to the Info file using the following format:
     * <br>
     * <tt>
     * taxonID + getInputSource() + idenType + identifier + chromosome + mapLocation + geneChipName 
     * </tt>
     * <br>
     * Note that the "plus sign" is replaced by the appropriate column
     * terminator.
     * 
     * To be used when chromosome, map location and gene chip name may all be
     * specified (e.g., Affymetrix IDs)
     * 
     * @see #getInputSource()
     */
    protected void writeToInfoFile(String taxonID, String idenType, String identifier, String chromosome, String mapLocation, String geneChipName) throws IOException {
        infoWriter.write(taxonID + OUTPUT_COLUMN_TERM + getInputSource()
                + OUTPUT_COLUMN_TERM + idenType + OUTPUT_COLUMN_TERM
                + identifier + OUTPUT_COLUMN_TERM + chromosome
                + OUTPUT_COLUMN_TERM + mapLocation + OUTPUT_COLUMN_TERM
                + geneChipName + OUTPUT_COLUMN_TERM);
        infoWriter.newLine();
    }
    
}
