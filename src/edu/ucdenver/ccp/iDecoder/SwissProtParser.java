package edu.ucdenver.ccp.iDecoder;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Extends InputFileParser to handle SwissProt input files.
 *
 */
public class SwissProtParser extends InputFileParser {   
    private static final String INPUT_SOURCE = "SwissProt";
    
    // key names for file properties entries
    private static final String SPROT_INPUT_DIRECTORY_PROP_NM = "swissprotInputDirectory";
    private static final String SPROT_FILENAME_PROP_NM = "swissprotFilename";

    public SwissProtParser(String outputDirectory) {
        super(outputDirectory);
    }
    
    // javadoc in superclass
	public String getInputSource() {
        return INPUT_SOURCE;
    }
    
    // javadoc in superclass
    public void processAllInputFiles() throws IOException {
        final Set taxonIDSet = PropertiesHelper.getTaxonIDToOrganismMap().keySet();
        final Map fileMap = PropertiesHelper.getFileMap();
        
        //SwissProt has only one (very large) input file
        String inputDirectory = createFileSpec((String) fileMap.get(INPUT_DIRECTORY),
                                (String) fileMap.get(SPROT_INPUT_DIRECTORY_PROP_NM));
        String inputFilename = (String) fileMap.get(SPROT_FILENAME_PROP_NM);
        
        initializeOutputFiles();
        
        long startTime = System.currentTimeMillis();
        String fileSpec = createFileSpec(inputDirectory,inputFilename);
        processInputFile(fileSpec,taxonIDSet);
        System.out.println("processed " + fileSpec + "\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
        
        finalizeOutputFiles();
    }

    /*
     * Each SwissProt entry is spread over multiple lines, with the type of data
     * on a line denoted by a two-letter code. For example, the line starting
     * with "ID" contains the identification information for the entry. Note
     * that every entry starts with an ID line, so the appearance of an ID line
     * also signals the end of the prior entry. The ID line contains the
     * SwissProt Name for this entry.
     * 
     * Other lines of interest in a SwissProt entry are:
     * 
     * AC - Accession Number (a.k.a., SwissProt ID) 
     * GN - Gene Name (used for Gene Symbol and Synonyms) 
     * OX - Organism Taxonomy Xref (the Taxonomy ID; may have multiple items)
     * DR - Database Xref (links to other DBs: NCBI (EMBL), Ensembl, FlyBase,
     * MGI, and RGD)
     * 
     * SwissProt Names, SwissProt IDs, Gene Symbols, Synonyms, and Ensembl IDs
     * are written to the Info file. Links between SwissProt IDs and its
     * associated Name and Symbols are written to the Links files, as are links
     * to external databases (e.g., NCBI, Ensembl, etc.). Note that no link is
     * created from the SwissProt ID to the Synonyms. Rather, the Synonyms are
     * associated with a particular Gene Symbol, so links are created from
     * Gene Symbols to their associated Synonyms.
     * 
     * Only relevant organisms are included; determination of relevance is
     * based on the passed-in taxonomy ID Set.
     * 
     * See http://us.expasy.org/sprot/userman.html for more information about
     * the input file format.
     */
	private void processInputFile(String inputFilename, Set relevantTaxonIDSet) throws IOException {
        BufferedReader reader = createInputFileReader(inputFilename);
		
		String line;

        // entryName == SwissProt Name, and accNum == SwissProt ID
        String entryName = null, accNum = null;
        
        // An entry may have multiples of most fields
		List taxonIDList = new ArrayList(0), ncbiRNAList = null, 
			ncbiProteinList = null, ensemblList = null, flyBaseList = null, mgiList = null, 
			rgdList = null; 
        
        // The Map contains Gene Symbols as keys and the associated Synonyms as values
        Map geneSymbolMap = null;
        
        // Used to identify entries that contain links to other relevant DBs vs.
        // those that don't. If an entry has no links to relevant DBs, it is
        // ignored.
		boolean hasLink = false;
        
        // A new entry is detected when a new "ID" line is encountered. So, the
        // first entry is output when the second ID line is detected, the second
        // entry is output when the third "ID" line is seen, and so on. Since the 
        // last entry sits at the end of the file, with no subsequent "ID" lines
        // to trigger output, the last entry is handled after the loop.
		while (reader.ready()) {
			line = reader.readLine();
                        
			if (line.startsWith("ID")) {
				// ID marks the beginning of a new entry. So, first output the
                // contents of the prior entry *if* the taxon ID List is not
                // empty and hasLink is true. The taxon ID List is empty if the
                // prior entry contained no relevant organisms. hasLink is false
                // if the prior entry had no links or if the links are only to
                // irrelevant databases.
				if (taxonIDList.size() > 0 && hasLink) {
					writeToOutputFiles(entryName, accNum, taxonIDList, ncbiRNAList, ncbiProteinList, ensemblList, flyBaseList, mgiList, rgdList, geneSymbolMap);
				}
				
                // The entry name is the first bit of text on the ID line. Start
                // at the 6th character (line starts with "ID   ") and grab
                // everything up to the first space after the 6th char.
				int ndx = line.indexOf(" ", 5);
				entryName = line.substring(5, ndx);
                
				// Now clear all of the entry variables since this is a new entry
				accNum = ""; 
				taxonIDList = new ArrayList(4);
                geneSymbolMap = new LinkedHashMap();
				ncbiRNAList = new ArrayList();
				ncbiProteinList = new ArrayList();
				ensemblList = new ArrayList();
				flyBaseList = new ArrayList();
				mgiList = new ArrayList();
				rgdList = new ArrayList();
				hasLink = false;
			} else if (line.startsWith("AC")) {
                            // This line contains accession numbers (a.k.a., SwissProt IDs)
                            // for this entry. Only the first (primary) ID from the first
                            // line is used. Once accNum is populated, the subsequent AC
                            // lines in the entry are ignored since they contain only 
                            // secondary IDs.
                            if (accNum.equals("")) {
                                // Grab everything from the 6th char (line starts with 
                                // "AC   ") up to the 1st semicolon.
                                int ndx = line.indexOf(";");
                                accNum = line.substring(5, ndx);
                            }
			} else if (line.startsWith("GN")) {
                            // This line contains both gene name (referred to here as
                            // "geneSymbol") and related synonyms. A GN line with both Name
                            // and Synonyms looks like:
                            //   GN   Name=GRF6; Synonyms=AFT1, RCI2;
                            // Not every gene name has associated synonyms. In these cases, 
                            // the Synonyms keyword is missing. Note that synonyms can't
                            // exist without an associated gene name.
                            // 
                            // An entry may contain Multiple GN lines, reflecting multiple
                            // gene names for a protein. It's also possible for a GN line 
                            // to contain no Name (nor Synonyms).
                            int start = line.indexOf("Name=");
				if (start > -1) {
                                    int end = line.indexOf(";", start);
                                    if(end<0){
                                        end = line.indexOf(" {", start);
                                    }
                    
                                    // "start+5" because "Name=" is 5 chars long
                                    String geneSymbol = line.substring(start+5,end);

                                    // get synonyms (if any)
                                    List synonymList;
                                    start = line.indexOf("Synonyms=");
                                    if (start > -1) {
                                            end = line.indexOf(";", start);

                                            // "start+9" because "Synonyms=" is 9 chars long;
                                            // ",\\s?" splits the entries at the commas, ignoring
                                            // the spaces.
                                            String[] synonyms = line.substring(start+9,end).split(",\\s?");

                                            synonymList = Arrays.asList(synonyms);
                                    } else{
                                        // If no synonyms exist, use an emtpy List to avoid nulls
                                        synonymList = new ArrayList();
                                    }

                                    // Each gene symbol has an associated synonym List, and there
                                    // may be multiple gene symbols; so, for each symbol, create 
                                    // a Map entry with symbol as key and List of synonyms as the
                                    // entry value. 
                                    geneSymbolMap.put(geneSymbol,synonymList);
                            }
			} else if (line.startsWith("OX")) {
                // This line contains NCBI taxonomy IDs. The line looks like:
                //   OX   NCBI_TaxID=9606;
				// This line generally contains one taxonomy ID, but some entries
                // include multiple taxonomy IDs (comma-delimited):
                //   OX   NCBI_TaxID=9606, 10090;
				int start = line.indexOf("NCBI_TaxID=");
				int end = line.indexOf(";");
                
                // "start+11" because "NCBI_TaxID=" is 11 chars long; split at
                // commas, ignoring the spaces, with ",\\s?"
				String[] taxonIDs = line.substring(start+11,end).split(",\\s?");
				
				for (int i = 0; i < taxonIDs.length; i++) {
					String taxonID = taxonIDs[i];
					// Only include taxonomy IDs for organisms of interest
                    // (i.e., those contained in the passed-in
                    // relevantTaxonIDSet)
					if (relevantTaxonIDSet.contains(taxonID)) {
						taxonIDList.add(taxonID);
					}
				}
			} else if (line.startsWith("DR")) {
                // The DR line contains a database links. The first field on the
                // line designates the database. The formats of the relevant 5
                // databases follow:
                //
				// EMBL; Accession Number; Protein ID.version; Status Identifier; Molecule Type.
				//   Molecule Type is ignored
			    //   Lines with Status Identifiers starting with "ALT_*" are excluded
                //   Note: these IDs are equivalent to NCBI IDs
				// Ensembl; Unique Identifier; Species of Origin.
				//   Species of Origin is ignored
				// FlyBase; First Accession Number; Gene Designation. 
				//   Gene Designation is ignored
				// MGI; First Accession Number; Gene Designation.
				//   Gene Designation is ignored
				// RGD; First Accession Number; Gene Designation.
				//   Gene Designation is ignored
                
                // Start at the 6th char (line starts with "DR   "); fields on the
                // DR line are separated by a semicolon.
				String[] drs = line.substring(5).split(";");
                
				String linkDBName = (String) drs[0];
				String linkID = (String) drs[1];
                
				if (linkDBName.equals("EMBL")) {
					// ignore ALT_FRAME, ALT_INIT, ALT_SEQ, and ALT_TERM 
					if (drs[3].indexOf("ALT_") == -1) {
						hasLink = true;
                        ncbiRNAList.add(linkID.trim());
                        
						// If an RNA id doesn't have a related protein, the protein
						// id will be "-", which should be ignored
						String proteinID = drs[2].trim();
						if (! proteinID.equals("-")) {
							// suppress version number (the period and everything after)
							int ndx = proteinID.indexOf(".");
							if (ndx != -1) {
							    ncbiProteinList.add(proteinID.substring(0,ndx));
							} else {
							    ncbiProteinList.add(proteinID);
							}
						}
					}
				} else if (linkDBName.equals("Ensembl")) {
					hasLink = true;
					ensemblList.add(linkID.trim());
				} else if (linkDBName.equals("FlyBase")) {
					hasLink = true;
					flyBaseList.add(linkID.trim());
				} else if (linkDBName.equals("MGI")) {
					hasLink = true;
					mgiList.add(linkID.trim());
				} else if (linkDBName.equals("RGD")) {
					hasLink = true;
					rgdList.add(linkID.trim());
				}
			}
		}
		reader.close();
        
        // handle the last record from the input file
        if (taxonIDList.size() > 0 && hasLink) {
            writeToOutputFiles(entryName, accNum, taxonIDList, ncbiRNAList, ncbiProteinList, ensemblList, flyBaseList, mgiList, rgdList, geneSymbolMap);
        }
        
	}

    
    // Handle output to the Info and Links files.
    private void writeToOutputFiles(String entryName, String accNum,
            List taxonIDList, List ncbiRNAList, List ncbiProteinList,
            List ensemblList, List flyBaseList, List mgiList, List rgdList,
            Map geneSymbolMap) throws IOException {
        
        // Since an entry may pertain to multiple organisms, iterate over
        // the taxonomy List, producing a set of rows for each organism.
        for (Iterator iter = taxonIDList.iterator(); iter.hasNext();) {
        	String taxonID = (String) iter.next();
            
            // Write accNum (a.k.a., SwissProt ID) to Info file
            writeToInfoFile(taxonID,SWISS_PROT_ID_TYPE,accNum);
            
            // Write entryName (a.k.a., SwissProt Name) to both the Info
            // and Links files
            writeToInfoFile(taxonID,SWISS_PROT_NAME_TYPE,entryName);
            writeToLinksFile(SWISS_PROT_ID_TYPE,accNum,SWISS_PROT_NAME_TYPE,entryName);

            // Each SwissProt ID record may have multiple Symbols, and each
            // Symbol may have an associated List of Synonyms. So, create links
            // between the SwissProtID and its Symbols, and links between each
            // Symbol and its Synonyms. And create Info file entries for all
            // Symbols and Synonyms.
            for (Iterator geneSymbolIterator = geneSymbolMap.entrySet()
                    .iterator(); geneSymbolIterator.hasNext();) {
                Map.Entry entry = (Map.Entry) geneSymbolIterator.next();
                
                // First, write the Symbol to the Info and Links files 
                // (linking the SwissProt ID to the Symbol)
                String geneSymbol = (String) entry.getKey();
                writeToInfoFile(taxonID,GENE_SYMBOL_TYPE,geneSymbol);
                writeToLinksFile(SWISS_PROT_ID_TYPE, accNum, GENE_SYMBOL_TYPE, geneSymbol);
                
                // Now, write the Synonyms associated with this Symbol to the
                // Info and Links files (linking the Symbol to each Synonym)
                List synonymList = (List) entry.getValue();
                for (Iterator synonymIterator = synonymList.iterator(); synonymIterator.hasNext();) {
                    String synonym = (String) synonymIterator.next();
                    writeToInfoFile(taxonID,SYNONYM_TYPE,synonym);
                    writeToLinksFile(GENE_SYMBOL_TYPE,geneSymbol,SYNONYM_TYPE,synonym);
                }
            }
            
            // Write Ensembl IDs to the Info and Links files
            for (Iterator ensemblIterator = ensemblList.iterator(); ensemblIterator
                    .hasNext();) {
                String ensemblID = (String) ensemblIterator.next();
                writeToInfoFile(taxonID,ENSEMBL_ID_TYPE,ensemblID);
                writeToLinksFile(SWISS_PROT_ID_TYPE,accNum,ENSEMBL_ID_TYPE,ensemblID);
            }
            
            // Write the external database links to the Links file
            writeCollectionToLinksFile(SWISS_PROT_ID_TYPE,accNum,NCBI_RNA_ID_TYPE,ncbiRNAList);
            writeCollectionToLinksFile(SWISS_PROT_ID_TYPE,accNum,NCBI_PROTEIN_ID_TYPE,ncbiProteinList);
            writeCollectionToLinksFile(SWISS_PROT_ID_TYPE,accNum,FLY_BASE_ID_TYPE,flyBaseList);
            writeCollectionToLinksFile(SWISS_PROT_ID_TYPE,accNum,MGI_ID_TYPE,mgiList);
            writeCollectionToLinksFile(SWISS_PROT_ID_TYPE,accNum,RGD_ID_TYPE,rgdList);
        }
    }

}
