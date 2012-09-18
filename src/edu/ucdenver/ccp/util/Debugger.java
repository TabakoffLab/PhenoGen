package edu.ucdenver.ccp.util;

/**
 * This class contains utilities for printing stuff.
 * @author Cheryl Hornbaker 
 *      
 */

/* for logging messages */
import org.apache.log4j.Logger;
import java.util.*;
import java.io.*;
import edu.ucdenver.ccp.PhenoGen.data.*;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.*;

public class Debugger {

  private Logger log=null;

  public Debugger() {
		log = Logger.getRootLogger();
  }
    
  public void print(String[][] inStuff) {
	if (inStuff != null) {
		for (int i=0; i<inStuff.length; i++) {
			for (int j=0; j<inStuff[i].length; j++) {
				log.debug("array[" + i + ", " + j + "] = " + inStuff[i][j]);
			}
		}
	} else {
		log.debug("array is null");
	}
  }

  public void print(LinkedHashSet inStuff) {
	if (inStuff != null && inStuff.size() != 0) {
		Iterator iterator = inStuff.iterator();
		while (iterator.hasNext()) {
			Object nextObject = iterator.next();
			String objectClassName = nextObject.getClass().getName();
			//log.debug("Set object is of type:  "+ objectClassName);
			choosePrintMethod(objectClassName, nextObject);
		}
	} else {
		log.debug("LinkedHashSet is null");
	}
  }

  public void print(Set inStuff) {
	if (inStuff != null && inStuff.size() != 0) {
		Iterator iterator = inStuff.iterator();
		while (iterator.hasNext()) {
			Object nextObject = iterator.next();
			String objectClassName = nextObject.getClass().getName();
			//log.debug("Set object is of type:  "+ objectClassName);
			choosePrintMethod(objectClassName, nextObject);
		}
	} else {
		log.debug("Set is null");
	}
  }

  public void print(TreeSet inStuff) {
	Set newSet = (Set) inStuff;
	print(newSet);
  } 

  public void print(HashSet inStuff) {
	if (inStuff != null) {
		Iterator iterator = inStuff.iterator();
		int i = 0;
		while (iterator.hasNext()) {
			log.debug("HashSet[" + i + "] = " + (String) iterator.next());
			i++;
		}
	} else {
		log.debug("HashSet is null");
	}
  }
  public void print(Collection inStuff) {
	if (inStuff != null) {
		Iterator iterator = inStuff.iterator();
		while (iterator.hasNext()) {
			Object nextObject = iterator.next();
			String objectClassName = nextObject.getClass().getName();
			if (objectClassName.equals("java.lang.String")) {
				log.debug("Set object is a String");
			} else if (objectClassName.equals("edu.ucdenver.ccp.PhenoGen.tools.idecoder.IdentifierLink")) {
				log.debug("Set object is an Identifier");
			} else if (objectClassName.equals("edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier")) {
				log.debug("Set object is an Identifier");
			} else {
				log.debug("Set object is of type:  "+ objectClassName);
			}
			choosePrintMethod(objectClassName, nextObject);
		}
	} else {
		log.debug("Collection is null");
	}
  }

  public void print(HashMap inStuff) {
		print((Map) inStuff);
  }
  public void print(TreeMap inStuff) {
		print((Map) inStuff);
  }
  public void print(Map inStuff) {
	if (inStuff != null) {
		Iterator it = inStuff.keySet().iterator();
                while (it.hasNext()) {
			Object nextKey = it.next();
			String keyClassName = nextKey.getClass().getName();
			String className = "";
			Object values = "";
			if (keyClassName.equals("java.lang.String")) {
	                	String key = (String) nextKey;
				log.debug("Map key is a String = "+ key + ", Map value = ");
				values = inStuff.get(key);
			} else if (keyClassName.equals("java.lang.Integer")) {
	                	int key = ((Integer) nextKey).intValue();
				log.debug("Map key is an Integer = "+ key + ", Map value = ");
				values = inStuff.get(new Integer(key));
			} else if (keyClassName.equals("java.lang.Thread")) {
	                	String key = ((Thread) nextKey).getName();
				log.debug("Map key is a Thread = "+ key + ", Map value = ");
				values = inStuff.get(key);
			} else if (keyClassName.equals("edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier")) {
	                	Identifier key = (Identifier) nextKey;
				log.debug("Map key is an Identifier:");
				className = key.getClass().getName();
				choosePrintMethod(className, key);
				values = inStuff.get(key);
			} else if (keyClassName.equals("edu.ucdenver.ccp.PhenoGen.tools.idecoder.IdentifierLink")) {
	                	IdentifierLink key = (IdentifierLink) nextKey;
				log.debug("Map key is an IdentifierLink:");
				className = key.getClass().getName();
				choosePrintMethod(className, key);
				values = inStuff.get(key);
			} else if (keyClassName.equals("edu.ucdenver.ccp.PhenoGen.data.Array")) {
	                	Array key = (Array) nextKey;
				log.debug("Map key is a Array:");
				className = key.getClass().getName();
				choosePrintMethod(className, key);
				values = inStuff.get(key);
			} else if (keyClassName.equals("edu.ucdenver.ccp.PhenoGen.data.User")) {
	                	User key = (User) nextKey;
				log.debug("Map key is a User:");
				className = key.getClass().getName();
				choosePrintMethod(className, key);
				log.debug("Map value = ");
				values = inStuff.get(key);
			} else if (keyClassName.equals("edu.ucdenver.ccp.PhenoGen.data.GeneList$Gene")) {
	                	GeneList.Gene key = (GeneList.Gene) nextKey;
				log.debug("Map key is a Gene:");
				className = key.getClass().getName();
				choosePrintMethod(className, key);
				log.debug("Map value = ");
				values = inStuff.get(key);
			} else {
				log.debug("class of key is not handled. It is = " + keyClassName);
			}
			className = values.getClass().getName();
			choosePrintMethod(className, values);
                }
	} else {
		log.debug("hashmap is null");
	}
  }


  private void choosePrintMethod(String className, Object inStuff) {
	if (className.equals("[Ljava.lang.String;")) {
		print((String[]) inStuff);
	} else if (className.equals("java.util.LinkedHashSet")) {
		print((Set) inStuff);
	} else if (className.equals("java.util.TreeSet")) {
		print((Set) inStuff);
	} else if (className.equals("java.util.Set")) {
		print((Set) inStuff);
	} else if (className.equals("java.lang.String")) {
		log.debug(inStuff);
	} else if (className.equals("java.util.TreeMap")) {
		print((Map) inStuff);
	} else if (className.equals("java.util.HashMap")) {
		print((Map) inStuff);
	} else if (className.equals("java.util.Hashtable")) {
		print((Hashtable) inStuff);
	} else if (className.equals("java.util.ArrayList")) {
		print((ArrayList) inStuff);
	} else if (className.equals("java.util.Vector")) {
		print((Vector) inStuff);
	} else if (className.equals("java.lang.Throwable")) {
		print((Throwable) inStuff);
	} else if (className.equals("java.lang.Double")) {
		print((Double) inStuff);
	} else if (className.equals("java.lang.Integer")) {
		print((Integer) inStuff);
	} else if (className.equals("java.io.File")) {
		print((File) inStuff);
	} else if (className.equals("[I")) {
		print((int[]) inStuff);
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.Array")) {
		((Array) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier")) {
		((Identifier) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.tools.idecoder.IdentifierLink")) {
		((IdentifierLink) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.User")) {
		((User) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.User$UserChip")) {
		((User.UserChip) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.GeneList")) {
		((GeneList) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.GeneList$Gene")) {
		((GeneList.Gene) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.Texprtyp")) {
		((Texprtyp) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.ParameterValue")) {
		((ParameterValue) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.QTL")) {
		((QTL) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.Dataset")) {
		((Dataset) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.Dataset$DatasetVersion")) {
		((Dataset.DatasetVersion) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.Dataset$Group")) {
		((Dataset.Group) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.Organism$Chromosome")) {
		((Organism.Chromosome) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.Organism$Cytoband")) {
		((Organism.Cytoband) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.QTL$EQTL")) {
		((QTL.EQTL) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.QTL$Locus")) {
		((QTL.Locus) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.util.CodeGenerator$Column")) {
		((CodeGenerator.Column) inStuff).print();
	} else if (className.equals("edu.ucdenver.ccp.PhenoGen.data.Protocol")) {
		((Protocol) inStuff).print();
	} else {
		log.debug("In choosePrintMethod. can't find class of element. classname = " + className);
	}
	
  }

  public void print(GeneList.Gene inStuff) {
	if (inStuff != null) {
		String className = inStuff.getClass().getName();
		choosePrintMethod(className, inStuff);
	} else {
		log.debug("Gene is null");
	}
  }

  public void print(User inStuff) {
	if (inStuff != null) {
		String className = inStuff.getClass().getName();
		choosePrintMethod(className, inStuff);
	} else {
		log.debug("User is null");
	}
  }

  public void print(Array inStuff) {
	if (inStuff != null) {
		String className = inStuff.getClass().getName();
		choosePrintMethod(className, inStuff);
	} else {
		log.debug("Array is null");
	}
  }

  public void print(Texprtyp[] inStuff) {
	if (inStuff != null) {
		for (int i=0; i<inStuff.length; i++) {
			String className = inStuff[i].getClass().getName();
			choosePrintMethod(className, inStuff[i]);
		}
	} else {
		log.debug("Texprtype array is null");
	}
  }
  public void print(ParameterValue[] inStuff) {
	if (inStuff != null) {
		for (int i=0; i<inStuff.length; i++) {
			String className = inStuff[i].getClass().getName();
			choosePrintMethod(className, inStuff[i]);
		}
	} else {
		log.debug("ParameterValue array is null");
	}
  }
  public void print(Dataset[] inStuff) {
	if (inStuff != null) {
		for (int i=0; i<inStuff.length; i++) {
			String className = inStuff[i].getClass().getName();
			choosePrintMethod(className, inStuff[i]);
		}
	} else {
		log.debug("Dataset array is null");
	}
  }

  public void print(Dataset.DatasetVersion[] inStuff) {
	if (inStuff != null) {
		for (int i=0; i<inStuff.length; i++) {
			String className = inStuff[i].getClass().getName();
			choosePrintMethod(className, inStuff[i]);
		}
	} else {
		log.debug("DatasetVersion array is null");
	}
  }

  public void print(Object[] inStuff) {
	if (inStuff != null) {
		for (int i=0; i<inStuff.length; i++) {
			String className = inStuff[i].getClass().getName();
			choosePrintMethod(className, inStuff[i]);
		}
	} else {
		log.debug("Object array is null");
	}
  }

  public void print(File inStuff) {
	if (inStuff != null) {
		log.debug("File name plus Path = " + inStuff.getPath());
	} else {
		log.debug("Object is null");
	}
  }
  public void print(Object inStuff) {
	if (inStuff != null) {
		String className = inStuff.getClass().getName();
		choosePrintMethod(className, inStuff);
	} else {
		log.debug("Object is null");
	}
  }

  public void print(Enumeration inStuff) {
	log.debug("printing Enumeration");
	if (inStuff != null) {
		log.debug("inStuff is not null ");
                while (inStuff.hasMoreElements()) {
			log.debug("inStuff has more elements ");
                	Object key = (Object) inStuff.nextElement();
			log.debug("class is " + key.getClass().getName());
			log.debug("key = "+key);
		}
	} else {
		log.debug("Enumeration is null");
	}
  }

  public void print(Hashtable inStuff) {
	if (inStuff != null) {
		Enumeration keys = inStuff.keys();
                while (keys.hasMoreElements()) {
                	String key = (String) keys.nextElement();
			String className = inStuff.get(key).getClass().getName();
			if (className.equals("java.lang.Integer")) {
				className = "java.lang.String";
			}

			log.debug("key = "+key);

			choosePrintMethod(className, inStuff.get(key));
                }
	} else {
		log.debug("hashtable is null");
	}
  }

  public void print(Throwable inStuff) {
	if (inStuff != null) {
		log.debug("value = " + inStuff.getMessage());
	} else {
		log.debug("throwable value is null");
	}
  }

  public void print(Double inStuff) {
	if (inStuff != null) {
		log.debug("value = " + inStuff.doubleValue());
	} else {
		log.debug("double value is null");
	}
  }

  public void print(Integer inStuff) {
	if (inStuff != null) {
		log.debug("value = " + inStuff.intValue());
	} else {
		log.debug("integer value is null");
	}
  }

  public void print(Vector inStuff) {
	if (inStuff != null) {
		for (int i=0; i<inStuff.size(); i++) {
			log.debug("vector[" + i + "] = " + inStuff.get(i));
		}
	} else {
		log.debug("vector is null");
	}
  }

  public void print(List inStuff) {
	if (inStuff != null) {
		for (int i=0; i<inStuff.size(); i++) {
			String thisClassName = inStuff.get(i).getClass().getName();
			String className = "";
			Object values = "";
			if (thisClassName.equals("java.lang.String")) {
				log.debug("List element is a String, value = ");
			} else if (thisClassName.equals("java.lang.Double")) {
				log.debug("List element is an Double, value = ");
			} else if (thisClassName.equals("java.lang.Integer")) {
				log.debug("List element is an Integer, value = ");
			} else if (thisClassName.equals("edu.ucdenver.ccp.PhenoGen.data.Array")) {
				log.debug("List element is a Array, value = ");
			} else if (thisClassName.equals("edu.ucdenver.ccp.PhenoGen.data.User")) {
				log.debug("List element is a User, value = ");
			} else if (thisClassName.equals("edu.ucdenver.ccp.PhenoGen.data.GeneList$Gene")) {
				log.debug("List element is a Gene, value = ");
			} else if (thisClassName.equals("edu.ucdenver.ccp.PhenoGen.data.Dataset")) {
				log.debug("List element is a Dataset, value = ");
			} else if (thisClassName.equals("edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier")) {
				log.debug("List element is an Identifier, value = ");
			} else if (thisClassName.equals("edu.ucdenver.ccp.PhenoGen.tools.idecoder.IdentifierLink")) {
			} else if (thisClassName.equals("edu.ucdenver.ccp.PhenoGen.data.QTL")) {
				log.debug("List element is QTL, value = ");
			} else if (thisClassName.equals("edu.ucdenver.ccp.PhenoGen.data.QTL$EQTL")) {
				log.debug("List element is EQTL, value = ");
			} else if (thisClassName.equals("edu.ucdenver.ccp.PhenoGen.data.QTL$Locus")) {
				log.debug("List element is Locus, value = ");
			} else if (thisClassName.equals("edu.ucdenver.ccp.PhenoGen.data.Texprtyp")) {
				log.debug("List element is Texprtyp, value = ");
			} else if (thisClassName.equals("edu.ucdenver.ccp.PhenoGen.data.ParameterValue")) {
				log.debug("List element is ParameterValue, value = ");
			} else if (thisClassName.equals("[Ledu.ucdenver.ccp.PhenoGen.data.ParameterValue")) {
				log.debug("List element is ParameterValue[], value = ");
			} else if (thisClassName.equals("java.io.File")) {
				log.debug("List element is a File, value = ");
			} else if (thisClassName.equals("edu.ucdenver.ccp.util.CodeGenerator$Column")) {
				//log.debug("List element is a Column, value = ");
			} else {
				log.debug("class of List element is ... handled. It is = " + thisClassName);
			}
			values = inStuff.get(i);
			className = values.getClass().getName();
			choosePrintMethod(className, values);
		}
	} else {
		log.debug("List is null");
	}
  }

  public void print(ArrayList inStuff) {
	if (inStuff != null) {
		print((List) inStuff);
	} else {
		log.debug("ArrayList is null");
	}
  }

  public void print(int[] inStuff) {
	if (inStuff != null) {
		for (int i=0; i<inStuff.length; i++) {
			log.debug("int array[" + i + "] = " + inStuff[i]);
		}
	} else {
		log.debug("int array is null");
	}
  }

  public void print(String[] inStuff) {
	if (inStuff != null) {
		for (int i=0; i<inStuff.length; i++) {
			log.debug("array[" + i + "] = " + inStuff[i]);
		}
	} else {
		log.debug("array is null");
	}
  }
}
