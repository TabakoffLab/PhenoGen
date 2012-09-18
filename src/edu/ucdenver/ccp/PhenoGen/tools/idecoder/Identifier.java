package edu.ucdenver.ccp.PhenoGen.tools.idecoder;

import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import edu.ucdenver.ccp.PhenoGen.data.QTL;
import edu.ucdenver.ccp.PhenoGen.data.Array;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to gene and protein identifiers. 
 *  @author  Cheryl Hornbaker
 */

public class Identifier implements Comparable {
        private Logger log = null;

        private int idType;
        private String identifierTypeName;
        private long idNumber = 0;
        private String identifier;
        private String chromosome;
        private String mapLocation;
        private String cM;
        private String bp;
        private String idTypeCategory;
        private String organism;
        private String gene_chip_name;
	private String qualifiedLocation;
	private String currentIdentifier;
	private String originalIdentifier;
	//
	// The originating Identifier is the Identifier that was passed to IDecoder
	// from which this Identifier was discovered.  This is set when a resulting 
	// Identifier wants to know where it came from.
	//
	private Identifier originatingIdentifier;
	private String jacksonSearchString = "";
	private String iniaWestSearchString = "";
	private String iniaPreferenceSearchString = "";
	private String eQTLString;
	private String chromosomeMapGeneAnnotation;
	private String chromosomeMapTransAnnotation;
	private boolean useForEQTLMatch = false;
	private List eQTLGeneSymbols;
	private List transcripts;
	private Set<Identifier> relatedIdentifiers;
	private Set<Identifier> locationIdentifiers;
	private HashMap<String, Set<Identifier>> targetHashMap;
        
	public Identifier() {
             log = Logger.getRootLogger();
	}

	/** Creates a new Identifier object using only the id number 
	 */
        public Identifier(int idNumber) {
            log = Logger.getRootLogger();
            this.idNumber = idNumber;
	}
	/** Creates a new Identifier object using only the identifier String
	 */
        public Identifier(String identifier) {
            log = Logger.getRootLogger();
            this.identifier = identifier;
	}
	/** Creates a new Identifier object using the id number and the identifier String
	 */
        public Identifier(int idNumber, String identifier) {
            log = Logger.getRootLogger();
            this.idNumber = idNumber;
            this.identifier = identifier;
	}
	/** Creates a new Identifier object using the identifier String and the idType
	 */
        public Identifier(String identifier, String identifierTypeName, String organism, String gene_chip_name) {
            log = Logger.getRootLogger();
            this.identifier = identifier;
            this.identifierTypeName = identifierTypeName;
            this.organism = organism;
            this.gene_chip_name = gene_chip_name;
	}

        public Identifier(int idType, String identifierTypeName, long idNumber, 
				String identifier, String chromosome, String mapLocation, 
				String cM, String bp, String idTypeCategory, 
				String organism, String gene_chip_name) {
            log = Logger.getRootLogger();

            this.idType = idType;
            this.identifierTypeName = identifierTypeName;
            this.idNumber = idNumber;
            this.identifier = identifier;
            this.chromosome = chromosome;
            this.mapLocation = mapLocation;
            this.cM = cM;
            this.bp = bp;
            this.idTypeCategory = idTypeCategory;
            this.organism = organism;
            this.gene_chip_name = gene_chip_name;
        }

        public long getIdNumber() {
            return idNumber;
        }

        public String getIdentifier() {
            return identifier;
        }

        public void setIdentifierTypeName(String inString) {
            identifierTypeName = inString;
        }

        public String getIdentifierTypeName() {
            return identifierTypeName;
        }

        public String getGene_chip_name() {
            return gene_chip_name;
        }

        public String getOrganism() {
            return organism;
        }

        public String getChromosome() {
            return chromosome;
        }

        public String getMapLocation() {
            return mapLocation;
        }

        public String getCM() {
            return cM;
        }

        public String getBP() {
            return bp;
        }

	public void setOriginatingIdentifier(Identifier inIdentifier) {
		this.originatingIdentifier = inIdentifier;
	}

	public Identifier getOriginatingIdentifier() {
		return originatingIdentifier;
	} 

	public void setOriginalIdentifier(String inString) {
		this.originalIdentifier = inString;
	}

	public String getOriginalIdentifier() {
		return originalIdentifier;
	} 

	public void setCurrentIdentifier(String inString) {
		this.currentIdentifier = inString;
	}

	public String getCurrentIdentifier() {
		return currentIdentifier;
	} 

	public void setJacksonSearchString(String inString) {
		this.jacksonSearchString = inString;
	}

	public String getJacksonSearchString() {
		return jacksonSearchString;
	} 

	public void setIniaWestSearchString(String inString) {
		this.iniaWestSearchString = inString;
	}

	public String getIniaWestSearchString() {
		return iniaWestSearchString;
	} 

	public void setIniaPreferenceSearchString(String inString) {
		this.iniaPreferenceSearchString = inString;
	}

	public String getIniaPreferenceSearchString() {
		return iniaPreferenceSearchString;
	} 

	public void setTranscripts(List inList) {
		this.transcripts = inList;
	}

	public List getTranscripts() {
		return transcripts;
	} 

	public void setChromosomeMapGeneAnnotation(String inString) {
		this.chromosomeMapGeneAnnotation = inString;
	}

	public String getChromosomeMapGeneAnnotation() {
		return chromosomeMapGeneAnnotation;
	} 

	public void setChromosomeMapTransAnnotation(String inString) {
		this.chromosomeMapTransAnnotation = inString;
	}

	public String getChromosomeMapTransAnnotation() {
		return chromosomeMapTransAnnotation;
	} 

	public void setEQTLString(String inString) {
		this.eQTLString = inString;
	}

	public String getEQTLString() {
		return eQTLString;
	} 

	public void setLocationIdentifiers(Set<Identifier> inSet) {
		this.locationIdentifiers = inSet;
	}

	public Set<Identifier> getLocationIdentifiers() {
		return locationIdentifiers;
	} 

	public void setRelatedIdentifiers(Set<Identifier> inSet) {
		this.relatedIdentifiers = inSet;
	}

	public Set<Identifier> getRelatedIdentifiers() {
		return relatedIdentifiers;
	} 

	public void setTargetHashMap(HashMap<String, Set<Identifier>> inHashMap) {
		this.targetHashMap = inHashMap;
	}

	public HashMap<String, Set<Identifier>> getTargetHashMap() {
		return targetHashMap;
	} 

        public String getIdTypeCategory() {
            return idTypeCategory;
        }

        public String getIdentifierTypeNameNoSpaces() {
            return identifierTypeName.replaceAll("[\\s\r']","_");
        }

        public boolean getUseForEQTLMatch() {
            return useForEQTLMatch;
        }

	public void setUseForEQTLMatch(boolean inBoolean) {
		this.useForEQTLMatch = inBoolean;
	}

	public void setEQTLGeneSymbols(List inList) {
		this.eQTLGeneSymbols = inList;
	}

	public List getEQTLGeneSymbols() {
		return eQTLGeneSymbols;
	} 

	/**
	 * Gets an Identifier from a set of Identifiers.
	 * @param identifier a String that is the id
	 * @param identifierSet a Set of Identifier objects
	 * @return	An Identifier object
	*/
        public Identifier getIdentifierFromSet(String identifier, Set identifierSet) {
            if(identifierSet!=null){
		if (identifierSet.contains(new Identifier(identifier))) {
			for (Iterator itr = identifierSet.iterator(); itr.hasNext();) { 
				Identifier thisIdentifier = (Identifier) itr.next();
				if (thisIdentifier.getIdentifier().equals(identifier)) {
					return thisIdentifier;
				}
			}
		}
            }
            return null;
        }

	/** Determines whether Identifier has a related Identifier on the MOE430_v2 Array, CodeLink Rat Whole Genome Array, or Gene Symbol.
	 * @param eQTL	eQTL object
	 * @param organism	organism
	 * @return	true if it does have a related Identifier, false otherwise
	 */
	public boolean mapsToEQTLChip(QTL.EQTL eQTL, String organism) {
		String probesetID = eQTL.getIdentifier();
		String geneName = eQTL.getGene_name();
                edu.ucdenver.ccp.PhenoGen.data.Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();
        	if (this.getRelatedIdentifiers().contains(new Identifier(probesetID, "Affymetrix ID", organism, myArray.MOUSE430V2_ARRAY_TYPE_SHORT)) ||
			this.getRelatedIdentifiers().contains(new Identifier(probesetID, "CodeLink ID", organism, myArray.CODELINK_RAT_ARRAY_TYPE_SHORT)) ||
			this.getRelatedIdentifiers().contains(new Identifier(probesetID, "Affymetrix ID", organism, myArray.MOUSE_EXON_ARRAY_TYPE_SHORT)) ||
			this.getRelatedIdentifiers().contains(new Identifier(probesetID, "Affymetrix ID", organism, myArray.RAT_EXON_ARRAY_TYPE_SHORT)) ||
			this.getRelatedIdentifiers().contains(new Identifier(geneName, "Gene Symbol", organism, ""))) {   
			/*
                        log.debug("got into here.  Does the Affy ID match?" + 
				this.getRelatedIdentifiers().contains(new Identifier(probesetID, "Affymetrix ID", organism, myArray.MOUSE430V2_ARRAY_TYPE_SHORT))); 
			log.debug("Does the CodeLink ID match?" + 
				this.getRelatedIdentifiers().contains(new Identifier(probesetID, "CodeLink ID", organism, myArray.CODELINK_RAT_ARRAY_TYPE_SHORT))); 
			log.debug("Does the Gene Symbol match?" + 
				this.getRelatedIdentifiers().contains(new Identifier(geneName, "Gene Symbol", organism, ""))); 
			*/
			return true;
		} else {
			return false;
		}
	}
			
	/**
	 * Gets the chromosome and location information.  
	 * @return	The chromosome and the location (e.g., 1:20788124-20805411) or "" if either are null.
	*/
        public String getChromosomeLocation() {
            return (this.getChromosome() != null && !this.getChromosome().equals("") && 
			this.getMapLocation() != null && !this.getMapLocation().equals("") ? 
            		this.getChromosome() +
			":" + 
			this.getMapLocation().replaceAll(" \\([-+]\\)", ""):"");
        }

	/**
	 * Gets the fully qualified location.
	 * @return	The type of identifier concatenated with the identifier itself, the chromosome, and the location<BR>
			e.g., From Ensembl ID ENSMUSG00000041859 - chromosome 1, location: 20788124-20805411 (-)	
	*/
        public String getQualifiedLocation() {
            return "From " + this.getIdentifierTypeName() + 
			" " +
			this.getIdentifier() + 
			" - chr " +
			this.getChromosome() +
			", loc:  " + 
			this.getMapLocation();
        }

        
	/**
	 * Determines equality of Identifier objects.  An Identifier object is equal to another
	 * if (1) the idNumber is the same or 
	 * (2) if identifierTypeName and organism are null and identifier is the same, or 
	 * (3) the combination of identifierTypeName, identifier, organism, and gene_chip_name are the same.
	 * @param myIdentifierObject	the Identifier object being tested for equality
	 * @return	true if the objects are equal, otherwise false			
	 */
        public boolean equals(Object myIdentifierObject) {
		//log.debug("in equals");
		if (!(myIdentifierObject instanceof Identifier)) return false;
        	Identifier myIdentifier = (Identifier) myIdentifierObject;

/*
		if (myIdentifier.identifier.equals("Gnb1") ||
			myIdentifier.identifier.equals("1417432_a_at") || 
			myIdentifier.identifier.equals("1425908_at")) {
			
			//log.debug("thisId = "+this+", and myId = "+myIdentifier);
			//log.debug("4 condition = " + (this.identifierTypeName != null &&
			//myIdentifier.identifierTypeName != null &&
			//this.identifierTypeName.equals(myIdentifier.identifierTypeName) &&
                	//this.identifier.equals(myIdentifier.identifier))); 
		}
		log.debug("thisId = "+this+", and myId = "+myIdentifier);
		log.debug("1 condition = " + (this.idNumber != 0 && myIdentifier.idNumber != 0 &&
			this.gene_chip_name != null &&
			myIdentifier.gene_chip_name != null &&
                	this.gene_chip_name.equals(myIdentifier.gene_chip_name) &&
			this.idNumber == myIdentifier.idNumber)); 
		log.debug("2 condition = "+ (this.identifierTypeName == null &&
        			myIdentifier.identifierTypeName == null &&
                		this.organism == null && 
                		myIdentifier.organism == null && 
				this.identifier.equals(myIdentifier.identifier))); 
		log.debug("3 condition = "+ (this.identifierTypeName != null &&
			this.organism != null &&
			this.gene_chip_name != null &&
			myIdentifier.identifierTypeName != null &&
			myIdentifier.organism != null &&
			myIdentifier.gene_chip_name != null &&
			this.identifierTypeName.equals(myIdentifier.identifierTypeName) &&
                	this.identifier.equals(myIdentifier.identifier) &&
                	this.gene_chip_name.equals(myIdentifier.gene_chip_name) &&
                	this.organism.equals(myIdentifier.organism))); 
*/
		if ((this.idNumber != 0 && myIdentifier.idNumber != 0 &&
			this.gene_chip_name == null &&
			myIdentifier.gene_chip_name == null &&
                	this.idNumber == myIdentifier.idNumber) 
			|| 
			(this.idNumber != 0 && myIdentifier.idNumber != 0 &&
			this.gene_chip_name != null &&
			myIdentifier.gene_chip_name != null &&
                	this.gene_chip_name.equals(myIdentifier.gene_chip_name) &&
			this.idNumber == myIdentifier.idNumber) 
			|| 
        		(this.identifierTypeName == null &&
        			myIdentifier.identifierTypeName == null &&
                		this.organism == null && 
                		myIdentifier.organism == null && 
				this.identifier.equals(myIdentifier.identifier)) 
			||
        		(this.identifierTypeName != null &&
			myIdentifier.identifierTypeName != null &&
			this.identifierTypeName.equals(myIdentifier.identifierTypeName) &&
                	this.identifier.equals(myIdentifier.identifier)) 
			||  
        		(this.identifierTypeName != null &&
			this.organism != null &&
			this.gene_chip_name != null &&
			myIdentifier.identifierTypeName != null &&
			myIdentifier.organism != null &&
			myIdentifier.gene_chip_name != null &&
			this.identifierTypeName.equals(myIdentifier.identifierTypeName) &&
                	this.identifier.equals(myIdentifier.identifier) &&
                	this.gene_chip_name.equals(myIdentifier.gene_chip_name) &&
                	this.organism.equals(myIdentifier.organism))) { 
                	return true;
        	} else {
                	return false;
        	}
        }

	public int compareTo(Object myIdentifierObject) {
		//log.debug("in compareTo");
		if (!(myIdentifierObject instanceof Identifier)) return -1;
        	Identifier myIdentifier = (Identifier) myIdentifierObject;

		if (!myIdentifier.equals(this.identifier)) {
			return this.identifier.compareTo(myIdentifier.identifier); 
		}

		return 0;
	}
        
        public int hashCode() {
		if (identifier != null) {
			if (identifierTypeName != null) {
				if (organism != null) {
					if (gene_chip_name != null) {
						//log.debug("2 hash for identifier " + identifier +  " = " + 
						//		(identifier + identifierTypeName + organism + gene_chip_name).hashCode()); 
						return (identifier + identifierTypeName + organism + gene_chip_name).hashCode(); 
					} else {
						//log.debug("3 hash for identifier " + identifier + " = " + 
						//		(identifier + identifierTypeName + organism).hashCode()); 
						return (identifier + identifierTypeName + organism).hashCode(); 
					}
				} else { 
					//log.debug("4 hash for identifier " + identifier + 
					//	" = " + (identifier + identifierTypeName).hashCode()); 
					return (identifier + identifierTypeName).hashCode(); 
				}
			} else {
				//log.debug("5 hash for identifier " + identifier + " = " + (identifier).hashCode()); 
				return (identifier).hashCode(); 
			}
		}
		return (Long.toString(idNumber)).hashCode(); 
        }
        
        public String toString() {
		String chrom = (chromosome != null ? ",chromosome=" + chromosome : ""); 
		String map = (mapLocation != null ? ",location=" + mapLocation : "");
		String chip = (gene_chip_name != null ? "(" + gene_chip_name + ")" : "");
		//return (idNumber + "--" + identifierTypeName + ":" + gene_chip_name + ":  " + 
		//	identifier + "(" + organism +" "+ chrom +" "+ map + ")");
		//return (identifierTypeName + ":" + identifier);  
		return (identifierTypeName + chip + ": " + identifier);  
        }


        public void print() {
		log.debug("Identifier = " + this.toString()); 
		//+ " and geneAannotation = " + this.getChromosomeMapGeneAnnotation() +
		//"transAnnotation = "+this.getChromosomeMapTransAnnotation());
		/*

		if (this.getLocationIdentifiers() != null) {
			log.debug("Location Identifiers = ");
			Iterator itr=this.getLocationIdentifiers().iterator();
			int i=0;
			while (itr.hasNext()) {
				log.debug("["+i+"]"+((Identifier) itr.next()).toString());
				i++;
			}
		}
		*/
		if (this.getRelatedIdentifiers() != null) {
			log.debug("Related Identifiers = ");
			Iterator itr=this.getRelatedIdentifiers().iterator();
			int i=0;
			while (itr.hasNext()) {
				log.debug("["+i+"]"+((Identifier) itr.next()).toString());
				i++;
			}
		}
        }


	public List<Identifier> sortIdentifiers(List<Identifier> myIdentifiers, String sortColumn) {
	        setSortColumn(sortColumn);
	        Collections.sort(myIdentifiers, new IdentifierSortComparator());
        	return myIdentifiers;
	}

	public List<Identifier> sortIdentifiers(List<Identifier> myIdentifiers, String sortColumn, String sortOrder) {
	        setSortColumn(sortColumn);
	        setSortOrder(sortOrder);
	        Collections.sort(myIdentifiers, new IdentifierSortComparator());
        	return myIdentifiers;
	}

	private String sortColumn;
	private String sortOrder = "A";

	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}

	public String getSortColumn() {
		return sortColumn;
	}

	public void setSortOrder(String inString) {
		this.sortOrder = inString;
	}

	public String getSortOrder() {
		return sortOrder;
	}

	public class IdentifierSortComparator implements Comparator<Identifier> {
	        int compare;
		Identifier identifier1, identifier2;

	        public int compare(Identifier id1, Identifier id2) {
			if (getSortOrder().equals("A")) {
                		identifier1 = id1;
                		identifier2 = id2;
				compare = 1;
			} else {
                		identifier1 = id2;
                		identifier2 = id1;
				compare = -1;
			}

                	if (getSortColumn().equals("organism")) {
                        	compare = identifier1.getOrganism().compareTo(identifier2.getOrganism());
                	} else if (getSortColumn().equals("idType")) {
                        	compare = new Integer(identifier1.getIdentifierTypeName()).compareTo(new Integer(identifier2.getIdentifierTypeName()));
                	} else if (getSortColumn().equals("mutant")) {
				// sort those that have mutants first, so use "A" and "B" rather 
				// than "true" and "false", which would sort in the opposite direction
				String identifier1HasMutant = "B";
				String identifier2HasMutant = "B";
                        	if (!identifier1.getJacksonSearchString().equals("") || 
                        		!identifier1.getIniaWestSearchString().equals("") || 
                        		!identifier1.getIniaPreferenceSearchString().equals("")) {
					identifier1HasMutant = "A";
				} 
                        	if (!identifier2.getJacksonSearchString().equals("") || 
                        		!identifier2.getIniaWestSearchString().equals("") || 
                        		!identifier2.getIniaPreferenceSearchString().equals("")) {
					identifier2HasMutant = "A";
				} 
                        	compare = identifier1HasMutant.compareTo(identifier2HasMutant);
                	} else if (getSortColumn().equals("currentIdentifier")) {
                        	compare = identifier1.getCurrentIdentifier().compareTo(identifier2.getCurrentIdentifier());
                	} else if (getSortColumn().equals("originalIdentifier")) {
                        	compare = identifier1.getOriginalIdentifier().compareTo(identifier2.getOriginalIdentifier());
                	} else if (getSortColumn().equals("identifier")) {
                        	compare = identifier1.getIdentifier().compareTo(identifier2.getIdentifier());
        		}
                	return compare;
		}
	}
}
