package edu.ucdenver.ccp.util;

/* for logging messages */
import org.apache.log4j.Logger;

import java.lang.reflect.Array;
import java.lang.reflect.Method;

import java.sql.Timestamp;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.Collections;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import edu.ucdenver.ccp.util.sql.Results;

/**
 * Class for returning objects as different data structures.
 *  <br> Authors:  Cheryl Hornbaker
 */

public class ObjectHandler {

  private Logger log=null;

  public ObjectHandler() {
	log = Logger.getRootLogger();
  }

	/**
	* Returns the current time as MMddyyyy.
	* @return	the current time as MMddyyyy
	*/
	public String getNowAsMMddyyyy() {
        	java.util.Date rightNow = Calendar.getInstance().getTime();
        	SimpleDateFormat dateFormat = new SimpleDateFormat("MMddyyyy");
        	return dateFormat.format(rightNow);
	} 

	/**
	* Returns the current time as Hmmss.  H is the hour in the day (0-23) (not zero-padded?), 
	* mm is minutes (zero-padded) and ss is seconds (zero-padded)
	* @return	the current time as Hmmss
	*/
	public String getNowAsHmmss() {
        	java.util.Date rightNow = Calendar.getInstance().getTime();
        	SimpleDateFormat dateFormat = new SimpleDateFormat("Hmmss");
        	return dateFormat.format(rightNow);
	} 

	/**
	* Returns the current time as MMM dd, yyyy.  MMM is a 3-character string abbreviation for the month.
	* dd is the day of the month (zero-padded).
	* @return	the current time as MMM dd, yyyy
	*/
	public String getNowAsMMMddyyyy() {
        	java.util.Date rightNow = Calendar.getInstance().getTime();
        	SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
        	return dateFormat.format(rightNow);
	} 

	/**
	* Returns the current time as MMddyyyy_HHmmss.  MM is a 2-character number for the month.
	* dd is the day of the month (zero-padded).
	* @return	the current time as MMddyyyy_HHmmss
	*/
	public String getNowAsMMddyyyy_HHmmss() {
        	java.util.Date rightNow = Calendar.getInstance().getTime();
        	SimpleDateFormat dateFormat = new SimpleDateFormat("MMddyyyy_HHmmss");
        	return dateFormat.format(rightNow);
	} 

	/**
	* Returns a long as MMddyyyy_HHmmss.  MM is a 2-character number for the month.
	* dd is the day of the month (zero-padded).
	* @return	the time as MMddyyyy_HHmmss
	*/
	public String getLongAsMMddyyyy_HHmmss(long inTime) {
        	SimpleDateFormat dateFormat = new SimpleDateFormat("MMddyyyy_HHmmss");
        	return dateFormat.format(new java.util.Date(inTime));
	} 

	/**
	* Returns a string in the format dd-MMM-yy as a Timestamp.  
	* @return	a Timestamp object 
	*/
	public Timestamp getOracleDateAsTimestamp(String inDate) {
		Timestamp ts = null; 
		//log.debug("inDate = "+inDate);
		try {
			if (inDate != null && !inDate.equals("")) {
        			SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MMM-yyyy HH:mm:ss");
        			ts = new Timestamp(dateFormat.parse(inDate).getTime());
			}
		} catch (Exception e) {
			log.debug("exception thrown in getOracleDateAsTimestamp", e);
		}
        	return ts;
	} 

	/**
	* Returns a string in the format mmddyyyy_hh24miss as a Timestamp.  mm is a 2-character number for the month.
	* dd is the day of the month (zero-padded).  see {@link SimpleDateFormat} for different formats
	* @return	a Timestamp object 
	*/
	public Timestamp getDateAsTimestamp(String inDate) {
		Timestamp ts = null; 
		try {
        		SimpleDateFormat dateFormat = new SimpleDateFormat("MMddyyyy_HHmmss");
        		ts = new Timestamp(dateFormat.parse(inDate).getTime());
		} catch (Exception e) {
			log.debug("exception thrown in getDateAsTimestamp", e);
		}
        	return ts;
	} 

	/**
	* Returns a string in the format 'mm/dd/yyyy hh12:mi AM' as a Timestamp.  mm is a 2-character number for the month.
	* dd is the day of the month (zero-padded).  see {@link SimpleDateFormat} for different formats
	* @return	a Timestamp object 
	*/
	public Timestamp getDisplayDateAsTimestamp(String inDate) {
		Timestamp ts = null; 
		try {
        		SimpleDateFormat dateFormat = new SimpleDateFormat("MM/dd/yyyy hh:mm a");
        		ts = new Timestamp(dateFormat.parse(inDate).getTime());
		} catch (Exception e) {
			log.debug("exception thrown in getDisplayDateAsTimestamp", e);
		}
        	return ts;
	} 

	/**
	* Returns a string in the format 'mm/dd/yyyy' as a Timestamp.  mm is a 2-character number for the month.
	* dd is the day of the month (zero-padded).  see {@link SimpleDateFormat} for different formats
	* @return	a Timestamp object 
	*/
	public Timestamp getScreenDateAsTimestamp(String inDate) {
		Timestamp ts = null; 
		try {
                        SimpleDateFormat dateFormat = new SimpleDateFormat("MM/dd/yyyy");
        		ts = new Timestamp(dateFormat.parse(inDate).getTime());
		} catch (Exception e) {
			log.debug("exception thrown in getDisplayDateAsTimestamp", e);
		}
        	return ts;
	}

	/**
	* Returns the current time as a java.sql.Timestamp object.
	* @return	the current time as a Timestamp
	*/
	public java.sql.Timestamp getNowAsTimestamp() {
        	java.util.Date rightNow = Calendar.getInstance().getTime();
        	return new Timestamp(rightNow.getTime());
	} 

	/**
	* Subtracts one day from a java.sql.Timestamp object.
	* @param thisTimestamp	starting Timestamp 
	* @return	the Timestamp minus one day
	*/
	public java.sql.Timestamp subtractOneDay(java.sql.Timestamp thisTimestamp) {
		final long ONE_DAY_MILLISECONDS = 24 * 60 * 60 * 1000;
		java.util.Date start = new java.util.Date(thisTimestamp.getTime());
		//log.debug( "Original Date: " + start );
		start.setTime(start.getTime() - ONE_DAY_MILLISECONDS);
		//log.debug( "New Date: " + start );
        	return new Timestamp(start.getTime());
	} 

  public String getAsHighlightedString(String inString, String[] highlightAlternateIDS, String[] highlightKeywords) {
	//
	// replace all occurrences of every string in highlightWords with HTML-tagged strings
	// look for the highlightWords as well as upper case highlightWords
	//

	  if (highlightAlternateIDS != null && highlightAlternateIDS.length > 0) {
			for (int j=0; j<highlightAlternateIDS.length; j++) {
				inString = inString.replaceAll(
						highlightAlternateIDS[j],
					"<SPAN class='highlightAlternateIDS'>" + highlightAlternateIDS[j] + "</SPAN>");
				inString = inString.replaceAll(
						highlightAlternateIDS[j].toUpperCase(),
					"<SPAN class='highlightAlternateIDS'>" + highlightAlternateIDS[j].toUpperCase() + "</SPAN>");
			}
		} 
		if (highlightKeywords != null && highlightKeywords.length > 0) {
			for (int j=0; j<highlightKeywords.length; j++) {
				inString = inString.replaceAll(
						highlightKeywords[j],
					"<SPAN class='highlightKeywords'>" + highlightKeywords[j] + "</SPAN>");
				inString = inString.replaceAll(
						highlightKeywords[j].toUpperCase(),
					"<SPAN class='highlightKeywords'>" + highlightKeywords[j].toUpperCase() + "</SPAN>");
			}
		} 
		return inString;

  }

	/**
	* Replaces all spaces and apostrophes with nothing, all slashes with underscores, and all ampersands with 'And'.
	* @param inString	the String
	* @return		a String object with spaces and apostrophes removed, slashes turned into underscores, 
	*			and ampersands turned into 'And'
	*/
	public String removeBadCharacters(String inString) {
		return (inString.replaceAll("[\\s']","")).replaceAll("[/]","_").replaceAll("\\&","And");
	}

	/**
	 * Determines whether the string is either null or empty or contains only spaces
	 * @param inString	the String
	 * @return		true if the String is either null or empty
	 */
	public boolean isEmpty(String inString) {
		//log.debug("in ObjectHandler.isEmpty. String = XXX" + inString + "YYY");
		//return (inString == null || (inString != null && inString.replaceAll("[\\s]", "").equals("")));
		return (inString == null || (inString != null && inString.trim().equals("")));
	}

	/**
	 * Determines whether the string is either all integers (no decimals) or a range of integers (no decimals)
	 * @param inString	the String
	 * @return		true if the String matches, false otherwise
	 */
	public boolean isValidRange(String inString) {
		boolean isValid = false;
		//System.out.println("in isValidRange.  inString = "+inString);

		/*Value will have following format: xx, xx-xx
			[0-9]+: Starts with one or more digits.
			\\.? : May contain an optional "." (decimal point) character.
			[0-9]*: May contain zero or more digits
			[-]? : May contain an optional "-" character.
			[0-9]*: May contain zero or more digits
			\\.? : May contain an optional "." (decimal point) character.
			[0-9]*$ : Ends with zero or more digits
		*/

		//Initialize reg ex for pattern
		String expression = "^[0-9]+\\.?[0-9]*[-]?[0-9]*\\.?[0-9]*$";
		CharSequence inputStr = inString;
		Pattern pattern = Pattern.compile(expression);
		Matcher matcher = pattern.matcher(inputStr);
		if(matcher.matches()){
			log.debug("string matches");
			isValid = true;
		}
		return isValid;
	}

	/**
	 * Replaces all spaces with underscores.
	 * @param inString	the String
	 * @return		a String object with spaces turned into underscores
	 */
	public String replaceBlanksWithUnderscores(String inString) {
		return (inString.replaceAll("[\\s]","_"));
	}

	/**
	 * Turn a set of objects into a list of objects
	 * @param inSet	a set of Objects
	 * @return		a List of Objects
	 */
	public List getAsList(Set inSet) {

		List outList = new ArrayList();
		if (inSet != null && inSet.size() > 0) {
			for (Iterator itr = inSet.iterator(); itr.hasNext();) {
				outList.add(itr.next());
			}
			Collections.sort(outList);
		}
        	return outList;
	}

	/**
	 * Break a string into a list, broken by whitespace
	 * @param inString	a string broken by whitespace
	 * @return		a List of Strings
	 */
	public List<String> getAsList(String inString) {

		String[] idArray = inString.split("[\\s]");
		List<String> outList = Arrays.asList((String[]) idArray); 
		Set<String> outSet = new TreeSet<String>(outList);
		outSet.remove((String) "");
		outList = new ArrayList<String>(outSet);

        	return outList;
	}

  public int[] getAsIntArray(String[] inArray) {
	int[] outArray = new int[inArray.length];

        for (int i=0; i<inArray.length; i++) {
        	outArray[i] = Integer.parseInt(inArray[i]);
        }
        return outArray;
  }

  public int[] getAsIntArray(Object[] inArray) {
	int[] outArray = new int[inArray.length];

        for (int i=0; i<inArray.length; i++) {
        	outArray[i] = ((Integer) inArray[i]).intValue();
        }
        return outArray;
  }

  public String getAsSeparatedString(String inStuff, int substringLength, String separator) {
	StringBuilder sb=new StringBuilder();
	String newString = inStuff;
	if (inStuff != null && inStuff.length() > substringLength) {
		while (newString.length() > substringLength) {
			sb.append( separator + newString.substring(0, substringLength));	
			newString = newString.substring(substringLength, newString.length());	
		}
	} 
	if (newString.length() > 0) {
		sb.append( separator + newString);
	}
	sb.append(separator);
	return sb.toString();
  }

	/**
	 * Turn an array of int objects into a String object separated by the separator.  
	 * @param inStuff	any array of ints 
	 * @param separator	a String used to separate the individual String
	 * @return		a String object separated by separator
	 */
	public String getAsSeparatedString(int[] inStuff, String separator) {
		//log.debug("inStuff = "); new Debugger().print(inStuff); 
		StringBuilder sb=new StringBuilder();
		if (inStuff != null && inStuff.length > 0) {
			sb.append( Integer.toString(inStuff[0]));
			for (int i=1; i<inStuff.length; i++) {
				sb.append( separator + Integer.toString(inStuff[i]));	
			}
		} 
		return sb.toString();
	}

	/**
	 * Turn an array of String objects into a String object separated by the separator.  
	 * For example, in order to view the contents of a file, read the file into a String array and then 
	 * use this method to turn the array of lines read from a file into an HTML string separated by HTML line break tags. 
	 * @param inStuff	any array of String objects
	 * @param separator	a String used to separate the individual String
	 * @return		a String object separated by separator
	 */
	public String getAsSeparatedString(String[] inStuff, String separator) {
		StringBuilder sb=new StringBuilder();
		if (inStuff != null && inStuff.length > 0) {
			sb.append((String) inStuff[0]);
			for (int i=1; i<inStuff.length; i++) {
				sb.append( separator + (String) inStuff[i]);	
			}
		} 
		return sb.toString();
	}

	/**
	 * Turn a Collection of String objects into a String object separated by the separator.  
	 * @param inStuff	a Collection of String objects
	 * @param separator	a String used to separate the individual String objects
	 * @return		a String object separated by separator
	 */
	public String getAsSeparatedString(Collection inStuff, String separator) {
		StringBuilder sb=new StringBuilder();
		int objectNum = 0;
		if (inStuff != null && inStuff.size() > 0) {
			Iterator itr = inStuff.iterator();
			while (itr.hasNext()) {
				if (objectNum == 0) {
					sb.append( (String) itr.next());
				} else {
					sb.append( separator + (String) itr.next());	
				}
				objectNum++;
			}
		} 
		return sb.toString();
	}

	/**
	 * Turn a Set of String objects into a String object separated by the separator.  
	 * @param inStuff	a Set of String objects
	 * @param separator	a String used to separate the individual String objects
	 * @return		a String object separated by separator
	 */
	public String getAsSeparatedString(Set inStuff, String separator) {
		StringBuilder sb=new StringBuilder();
		int objectNum = 0;
		if (inStuff != null && inStuff.size() > 0) {
			Iterator itr = inStuff.iterator();
			while (itr.hasNext()) {
				if (objectNum == 0) {
					sb.append( (String) itr.next());
				} else {
					sb.append( separator + (String) itr.next());	
				}
				objectNum++;
			}
		} 
		return sb.toString();
	}
        
        /**
	 * Turn an ArrayList<String>  into a String object separated by the separator.  
	 * @param inStuff	an ArrayList of String objects
	 * @param separator	a String used to separate the individual String objects
	 * @return		a String object separated by separator
	 */
	public String getAsSeparatedString(ArrayList<String> inStuff, String separator) {
		StringBuilder sb=new StringBuilder();
		for(int i=0;i<inStuff.size();i++){
                    if(i==0){
                        sb.append(inStuff.get(i));
                    }else{
                        sb.append(separator+inStuff.get(i));
                    }
                }
		return sb.toString();
	}
        

	/**
	 * Turn a Set of String objects into a String object separated by the separator.  
	 * Limit the returned string to the first 'n' elements where n is passed as the 'limit' parameter
	 * @param inStuff	a Set of String objects
	 * @param separator	a String used to separate the individual String objects
	 * @param encloser	a String to place around each instance of the separated Strings
	 * @param limit	the number of objects to include	
	 * @return		a String object separated by separator
	*/
	public String getAsSeparatedString(Set inStuff, String separator, String encloser, int limit) {
                StringBuilder sb=new StringBuilder();
		int objectNum = 0;
		if (inStuff != null && inStuff.size() > 0) {
			Iterator itr = inStuff.iterator();
			while (itr.hasNext() && objectNum < limit) {
				if (objectNum == 0) {
					sb.append(encloser + (String) itr.next() + encloser );
				} else {
					sb.append( separator + encloser + (String) itr.next() + encloser );
				}
				objectNum++;
			}
		} 
		return sb.toString();
	}

	/**
	 * Turn a Set of String objects into Lists of String delimited objects that are of length 'limit'.  
	 * For example, turn
	 * 2400 Strings into a List containing 2-1000 length and 1-400 length String objects delimited by the separator. 
	 * Limit each returned String to the first 'n' elements where n is passed as the 'limit' parameter
	 * @param inStuff	a Set of String objects
	 * @param separator	a String used to separate the individual String objects
	 * @param encloser	a String to place around each instance of the separated Strings
	 * @param limit	the number of objects to include in each returned String	
	 * @return		a List of String objects, separated by separator and limited to the number of elements
	*/
	public List<String> getAsSeparatedStrings(Set inStuff, String separator, String encloser, int limit) {
		String returnString = "";
		int objectNum = 0;
		List<String> returnList = new ArrayList<String>();
		if (inStuff != null && inStuff.size() > 0) {
			Iterator itr = inStuff.iterator();
			while (itr.hasNext()) {
				while (itr.hasNext() && objectNum < limit) {
					returnString = (objectNum != 0 ? returnString + separator : "") +
							encloser + (String) itr.next() + encloser;
					objectNum++;
				}
				returnList.add(returnString);
				returnString = "";
				objectNum = 0;
			}
		} 
		return returnList;
	}

  public String getAsSeparatedString(Set inStuff, String separator, String encloser) {
	StringBuilder sb=new StringBuilder();
	int objectNum = 0;
	if (inStuff != null && inStuff.size() > 0) {
		Iterator itr = inStuff.iterator();
		while (itr.hasNext()) {
			if (objectNum == 0) {
				sb.append(encloser + (String) itr.next() + encloser);
			} else {
				sb.append( separator + encloser + (String) itr.next() + encloser);
			}
			objectNum++;
		}
	} 
	return sb.toString();
  }

  /**
   * Turn a List of String objects into a String object separated by the separator.  
   * @param inStuff	a List of String objects
   * @param separator	a String used to separate the individual String objects
   * @return		a String object separated by separator
   */
  public String getAsSeparatedString(List inStuff, String separator) {
	StringBuilder sb=new StringBuilder();
	if (inStuff != null && inStuff.size() > 0) {
		sb.append( (String)inStuff.get(0));
		for (int i=1; i<inStuff.size(); i++) {
			sb.append( separator + (String) inStuff.get(i));	
		}
	} 
	return sb.toString();
  }

  public String getAsSeparatedString(String[] inStuff, String separator, String encloser) {
	StringBuilder sb=new StringBuilder();
	if (inStuff != null && inStuff.length > 0) {
		sb.append( encloser + (String) inStuff[0] + encloser);
		for (int i=1; i<inStuff.length; i++) {
			sb.append( separator + 
					encloser + 
					(String) inStuff[i] + 
					encloser);	
		}
	} 
	return sb.toString();
  }

  public String getAsSeparatedString(List inStuff, String separator, String encloser) {
	StringBuilder sb=new StringBuilder();

	if (inStuff != null && inStuff.size() > 0) {
		sb.append( encloser + (String) inStuff.get(0) + encloser);
		for (int i=1; i<inStuff.size(); i++) {
			sb.append( separator + 
					encloser + 
					(String) inStuff.get(i) + 
					encloser);	
		}
	} 
	return sb.toString();
  }


	/**
	 * Turn the first two fields of a Results object into a LinkedHashMap.
	 * @param inStuff	a Results object
	 * @return		the first two fields as a LinkedHashMap with the first field pointing to the second 
	 */
	public LinkedHashMap<String, String> getResultsAsLinkedHashMap(Results inStuff) {

		LinkedHashMap<String, String> resultsLinkedHashMap = new LinkedHashMap<String, String>();

		String [] dataRow;

        	if (inStuff.getNumRows() > 0) {
                	while ((dataRow = inStuff.getNextRow()) != null) {
        			resultsLinkedHashMap.put(dataRow[0], dataRow[1]); 
			}
		} else {
			log.debug("in getResultsAsLinkedHashMap.  inStuff is null");
		}

		return resultsLinkedHashMap;
	}

	/**
	 * Turn the first two fields of a Results object into a Hashtable.
	 * @param inStuff	a Results object
	 * @return		the first two fields as a Hashtable with the first field pointing to the second 
	 */
	public Hashtable<String, String> getResultsAsHashtable(Results inStuff) {

		Hashtable<String, String> resultsHashtable = new Hashtable<String, String>();

		String [] dataRow;

        	if (inStuff.getNumRows() > 0) {
                	while ((dataRow = inStuff.getNextRow()) != null) {
        			resultsHashtable.put(dataRow[0], dataRow[1]); 
			}
		} else {
			log.debug("in getResultsAsHashtable.  inStuff is null");
		}

		return resultsHashtable;
	}

	/**
	 * Make a Hashtable with the first field from a Results object pointing to a list
	 * of values from the second field. 
	 * @param inStuff	a Results object
	 * @return		a Hashtable with the first field pointing to a list of values from the second field
	 */
	public Hashtable<String, List<String>> getResultsAsHashtablePlusList(Results inStuff) {

		Hashtable<String, List<String>> resultsHashtable = new Hashtable<String, List<String>>();

		String [] dataRow;
		String thisDataRow0 = "";
		//
		// initialize this to 'X' so that the first iteration will work correctly
		//
		String lastDataRow0 = "X";
		List<String> theList = null;

        	if (inStuff.getNumRows() > 0) {
                	while ((dataRow = inStuff.getNextRow()) != null) {
				thisDataRow0 = dataRow[0];
				//
				// If the value in first column is the same as the value in the 
				// first column of the previous record, add the value in the second 
				// column to the list of values.  Otherwise, close out this list
				// and put it in the hashtable.
				// 
				if (thisDataRow0.equals(lastDataRow0)) {
					List<String> existingList = (List<String>) resultsHashtable.get(thisDataRow0);
					existingList.add(dataRow[1]);
				} else {
					theList = new ArrayList<String>();
					theList.add(dataRow[1]);
					resultsHashtable.put(thisDataRow0, theList);
				}
				lastDataRow0 = dataRow[0];
			}
		} else {
			log.debug("in getResultsAsHashtablePlusList.  inStuff is null");
		}
		//log.debug("resultsAsHashtablePlusList = "); new Debugger().print(resultsHashtable);

		return resultsHashtable;
	}

	/**
	 * Gets a Set of Strings using one of the fields passed in as a Results object.
	 * @param inStuff	the Results of a query 
	 * @param whichField	the index of the column containing the data that should be returned   
	 * @return		Set of Strings containing the data from the specified column
	 */
	 public Set<String> getResultsAsSet(Results inStuff, int whichField) {
        	Set<String> returnSet = new LinkedHashSet<String>(getResultsAsList(inStuff, whichField));
		return returnSet;
	}

	/**
	 * Gets a List of Strings using one of the fields passed in as a Results object.
	 * @param inStuff	the Results of a query 
	 * @param whichField	the index of the column containing the data that should be returned   
	 * @return		List of Strings containing the data from the specified column
	 */
	 public List<String> getResultsAsList(Results inStuff, int whichField) {
		//
		//

		String [] dataRow;
        	int numRows = inStuff.getNumRows();
        	List<String> returnList = new ArrayList<String>();

        	if (numRows > 0) {
                	while ((dataRow = inStuff.getNextRow()) != null) {
                        	returnList.add(dataRow[whichField]); 
                	}
		} else {
			//log.debug("in getResultsAsList.  inStuff is null");
		}
		return returnList;
	}

  public List<String[]> getResultsAsListOfStringArrays(Results inStuff) {

	//
        // Make a list of string arrays from the Results object
	//

	String [] dataRow;
        int numRows = inStuff.getNumRows();
        String[] returnStringArray = new String[numRows];
	List<String[]> allRows = new ArrayList<String[]>();

        if (numRows > 0) {
		dataRow = inStuff.getColumnHeaders();
		allRows.add(dataRow);
                while ((dataRow = inStuff.getNextRow()) != null) {
			allRows.add(dataRow);
                }
	} else {
		log.debug("in getResultsAsListOfStringArrays.  inStuff is null");
	}
	return allRows;
  }

	/**
	 * Returns a String array using one of the fields passed in as a Results object.
	 * @param inStuff	the Results of a query 
	 * @param whichField	the index of the column containing the data that should be returned   
	 * @return		String array containing the data from the specified column
	 */
	 public String[] getResultsAsStringArray(Results inStuff, int whichField) {

		String [] dataRow;
        	int numRows = inStuff.getNumRows();
        	String[] returnStringArray = new String[numRows];

        	int rowNum = 0;
        	if (numRows > 0) {
                	while ((dataRow = inStuff.getNextRow()) != null) {
                        	returnStringArray[rowNum] = dataRow[whichField]; 
                        	rowNum++;
                	}
		} else {
			log.debug("in getResultsAsStringArray.  inStuff is null");
		}
		return returnStringArray;
	}

	/**
	 * Convert a String object separated by whitespace characters into a String array.
	 * @param inString	a String separated by whitespace
	 * @return		String array 
	 */
	 public String[] getStringAsStringArray(String inString) {

                List<String> stringList = new ArrayList<String>();

                //
                // Split the text on whitespace characters
                //
                String[] splitArray = inString.split("[\\s]");

                for (int i=0; i<splitArray.length; i++) {
                        if (splitArray[i].length() != 0) {
                                stringList.add(splitArray[i]);
                        }
                }

                return (String[]) stringList.toArray(new String[stringList.size()]);
	}

  /**
   * Gets an int array using one of the fields passed in as a Results object.
   * @param inStuff	the Results of a query 
   * @param whichField	the index of the column containing the data that should be returned   
   * @return		int array containing the data from the specified column
   */
  public int[] getResultsAsIntArray(Results inStuff, int whichField) {

	String [] dataRow;
        int numRows = inStuff.getNumRows();
        int[] returnArray = new int[numRows];

        int rowNum = 0;
        if (numRows > 0) {
                while ((dataRow = inStuff.getNextRow()) != null) {
                        returnArray[rowNum] = Integer.parseInt(dataRow[whichField]); 
                        rowNum++;
                }
	} else {
		//log.debug("in getResultsAsIntArray.  inStuff is null");
	}
	return returnArray;
  }

  /**
   * Turn a Results object into a String object separated by the separator.  
   * @param inStuff	a Results object generated by a query to the database
   * @param separator	a String used to separate the individual Strings
   * @param encloser	a String to place around each instance of the separated Strings
   * @param whichField	which of the columns in the Results object should be used (0 is the first column)
   * @return		a String object separated by separator
   */
  public String getResultsAsSeparatedString(Results inStuff, String separator, String encloser, int whichField) {

        StringBuilder sb=new StringBuilder();
	String [] dataRow;
        int numRows = inStuff.getNumRows();

        int rowNum = 0;
        if (numRows > 0) {
                while ((dataRow = inStuff.getNextRow()) != null) {
                        sb.append( encloser + dataRow[whichField] + 
					encloser); 
                        rowNum++;
                        if (rowNum < numRows) {
                                sb.append( separator);
                        }
                }
	} else {
		log.debug("in getResultsAsSeparatedString.  inStuff is null");
	}
	return sb.toString();
  }

	/** 
	 * Gets a particular field from an array of objects returned by a method and puts it into a Set of Strings.
	 * @param stuff	an array of something
	 * @param thisMethod the field to put into the Set
	 * @throws	Exception if something bad happens
	 * @return a Set of Strings from the specified field
	 */
        public Set<String> getAsStringSet(Object[] stuff, Method thisMethod) throws Exception {
                Set<String> mySet = new TreeSet<String>();
                
                for (int i=0; i<stuff.length; i++) {
                        Object obj = stuff[i];
                        try {
                                thisMethod.invoke(obj, new Object[] {});
                                mySet.add((String) thisMethod.invoke(obj, new Object[] {}));
                        } catch (Exception e) {
                                log.debug("got Exception while putting stuff into a StringSet", e);
                        }
                }
                return mySet;
        }

	/** 
	 * Gets an array of objects from a list of objects. 
	 * @param stuff	a List of sommething
	 * @return an array of something 
	 */
        public <T> T[] getAsArray(Collection<T> stuff, Class thisClass) {
		//log.debug("in ObjectHandler.getAsArray");
		// unchecked cast
    		T[] array = (T[])java.lang.reflect.Array.newInstance(thisClass, stuff.size());
		int i=0; 
		for (T x : stuff) array[i++] = x;
		return array;
	}
        
        /** 
	 * Gets an array of strings and returns an ArrayList<String>. 
	 * @param array of strings
	 * @return an ArrayList
	 */
        public ArrayList<String> getAsArrayList(String[] in) {
		ArrayList<String> array=new ArrayList<String>();
                for(int i=0;i<in.length;i++){
                    array.add(in[i]);
                }
		return array;
	}

	/** 
	 * Gets a particular field from an array of objects returned from method and puts it into a Set of Integers.
	 * @param stuff	an array of something
	 * @param thisMethod the method to call
	 * @throws	Exception if something bad happens
	 * @return a Set of Integers from the specified field
	 */
        public Set<Integer> getAsIntSet(Object[] stuff, Method thisMethod) throws Exception {
                Set<Integer> mySet = new TreeSet<Integer>();
                
                for (int i=0; i<stuff.length; i++) {
                        Object obj = stuff[i];
                        try {
                                thisMethod.invoke(obj, new Object[] {});
                                mySet.add((Integer) thisMethod.invoke(obj, new Object[] {}));
                        } catch (Exception e) {
                                log.debug("got Exception while putting stuff into a IntSet", e);
                        }
                }
                return mySet;
        }

	/** 
	 * Gets a particular field from an array of objects and puts it into a Set 
	 * @param stuff	an array of something
	 * @param fieldName the field to put into the Set
	 * @return a Set of the specified field
	 */
        public Set getAsSet(Object[] stuff, String fieldName) {
		if (stuff != null && stuff.length > 0) {
			try {
                		Class thisClass = Class.forName(stuff[0].getClass().getName());
                		Method thisMethod = thisClass.getDeclaredMethod("get" + fieldName, new Class[] {});
                		String setType = thisMethod.invoke(stuff[0], new Object[] {}).getClass().getName();
				//log.debug("setType = " + setType);
				if (setType.equals("java.lang.String")) {
					return getAsStringSet(stuff, thisMethod);
				} else if (setType.equals("java.lang.Integer")) {
					return getAsIntSet(stuff, thisMethod);
				}
			} catch (Exception e) {
				log.debug("Exception in myObjectHandler.getAsSet", e);
			}
		}
		return null;
        }

	/** 
	 * Turns an array of Strings (from an HTML form, for example) into a Set of Integers
	 * @param stuff	an array of Strings
	 * @return a Set of Integers
	 */
        public Set<Integer> getStringArrayAsIntegerSet(String[] stuff) {
		
		Set<Integer> mySet = new TreeSet<Integer>();
                for (int i=0; i<stuff.length; i++) {
			mySet.add(Integer.parseInt(stuff[i]));
                }
                return mySet;
        }
}
