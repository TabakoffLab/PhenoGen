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
public class PhenoGenParser extends InputFileParser {

    private static final String INPUT_SOURCE = "PhenoGen";
    
    // Input columns are tab-delimited
    private static final String INPUT_COLUMN_DELIM = "\t";

    // List (multi-item) columns have pipes delimiting the items
    private static final String INPUT_LIST_DELIM = ",";
    
    // see handleBlankListColumn() below
    private static final String[] EMPTY_STRING_ARRAY = new String[0];

    // key names for file properties entries
    private static final String PHENOGEN_INPUT_DIRECTORY_PROP_NM = "phenogenInputDirectory";
    private static final String PHENOGEN_FILENAME_PROP_NM = "phenogenFilename";
    
    private static final String TAXON_ID="10116";

    
    public PhenoGenParser(String outputDirectory) {
        super(outputDirectory);
    }
    
    // javadoc in superclass
    public String getInputSource() {
        return INPUT_SOURCE;
    }
    
    // javadoc in superclass
    public void processAllInputFiles() throws IOException {
        //final Set unigenePrefixSet = PropertiesHelper.getUniGenePrefixToOrganismMap().keySet();
        final Set taxonIDSet = PropertiesHelper.getTaxonIDToOrganismMap().keySet();
        final Map fileMap = PropertiesHelper.getFileMap();
        
        String inputDirectory = createFileSpec((String) fileMap.get(INPUT_DIRECTORY), 
        			(String) fileMap.get(PHENOGEN_INPUT_DIRECTORY_PROP_NM));
        
        // there are 4 input files, each with a different format
        String phenogenFilename = (String) fileMap.get(PHENOGEN_FILENAME_PROP_NM);
        
        initializeOutputFiles();
        
        long startTime = System.currentTimeMillis();
        String fileSpec = createFileSpec(inputDirectory,phenogenFilename);
        processMergedIdInputFile(fileSpec);
        System.out.println("processed " + fileSpec + "\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
        
        
        finalizeOutputFiles();
    }    
    
    /*
     * 
     *
     *
     */
    private void processMergedIdInputFile(String inputFilename) throws IOException {
        HashMap egLocations=new HashMap();
        BufferedReader reader = createInputFileReader(inputFilename);
        String line;
        String[] columns;
        
        while (reader.ready()) {
            line = reader.readLine();
            columns = line.split(INPUT_COLUMN_DELIM);
            String id=columns[0].trim();
            String chr=columns[1].trim();
            int start=Integer.parseInt(columns[2].trim());
            int stop=Integer.parseInt(columns[3].trim());
            int strand=Integer.parseInt(columns[4].trim());
            String strStrand="";
            if(strand>0){
                strStrand="+";
            }else if(strand<0){
                strStrand="-";
            }
            String mapLocation=start+"-"+stop+" ("+strStrand+")";
            String[] annotation=columns[5].trim().split(INPUT_LIST_DELIM);
            

            writeToInfoFile(TAXON_ID, PHENOGEN_TYPE, id,chr, mapLocation);
            
            for(int i=0;i<annotation.length;i++){
                if(annotation[i].startsWith("PRN6") || annotation[i].startsWith("PRN5")
                        || annotation[i].startsWith("PMM10")){ //Linked Phenogen ID
                    writeToLinksFile(PHENOGEN_TYPE, id,PHENOGEN_TYPE,annotation[i]);
                }else if(annotation[i].startsWith("ENS")){ //linked Ensembl ID
                    writeToLinksFile(PHENOGEN_TYPE, id,ENSEMBL_ID_TYPE,annotation[i]);
                }else{//Gene Symbol
                    writeToLinksFile(PHENOGEN_TYPE, id,GENE_SYMBOL_TYPE,annotation[i]);
                }
            }
            //Write links to other annotation ids
            
                
                
                
                
                
                

                      
        }

        reader.close();
    }

    
}
