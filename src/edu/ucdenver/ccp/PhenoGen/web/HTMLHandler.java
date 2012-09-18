package edu.ucdenver.ccp.PhenoGen.web;

/* for logging messages */
import org.apache.log4j.Logger;

import edu.ucdenver.ccp.util.Debugger;

import java.util.LinkedHashMap;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
/*
import edu.ucdenver.ccp.util.sql.Results;
import edu.ucdenver.ccp.util.*;
import java.sql.*;
*/

/**
 * Class for returning HTML-tagged code with data.
 *  <br> Authors:  Cheryl Hornbaker
 */

public class HTMLHandler{

	private Logger log=null;
	private Debugger myDebugger = new Debugger();
	private String[] dataRow;
	
	public HTMLHandler() {
		log = Logger.getRootLogger();
	}

	/** 
	 * Get the list of possible titles an individual may choose.
	 * @return	a Hashtable with the title mapped to the value 
	 * 	(in this case they are both the same) 
	 */

	public LinkedHashMap<String, String> getTitleList () {

		LinkedHashMap<String, String> outHash = new LinkedHashMap<String, String>();
		outHash.put("", "");
		outHash.put("Mr.", "Mr.");
		outHash.put("Ms.", "Ms."); 
		outHash.put("Dr.", "Dr."); 
		outHash.put("Prof.", "Prof.");
  		return outHash;
  	}

	/** 
	 * Get the list of possible state abbreviations an individual may choose.
	 * @return	a Hashtable with the state abbreviation mapped to the value 
	 * 	(in this case they are both the same) 
	 */
	public LinkedHashMap<String, String> getStateList () {

		LinkedHashMap<String, String> outHash = new LinkedHashMap<String, String>();
		outHash.put("","");
		outHash.put("AK","AK");
		outHash.put("AL","AL");
		outHash.put("AR","AR");
		outHash.put("AZ","AZ");
		outHash.put("CA","CA");
		outHash.put("CO","CO");
		outHash.put("CT","CT");
		outHash.put("DE","DE");
		outHash.put("FL","FL");
		outHash.put("GA","GA");
		outHash.put("HI","HI");
		outHash.put("IA","IA");
		outHash.put("ID","ID");
		outHash.put("IL","IL");
		outHash.put("IN","IN");
		outHash.put("KS","KS");
		outHash.put("KY","KY");
		outHash.put("LA","LA");
		outHash.put("MA","MA");
		outHash.put("MD","MD");
		outHash.put("ME","ME");
		outHash.put("MI","MI");
		outHash.put("MN","MN");
		outHash.put("MO","MO");
		outHash.put("MS","MS");
		outHash.put("MT","MT");
		outHash.put("NC","NC");
		outHash.put("ND","ND");
		outHash.put("NE","NE");
		outHash.put("NH","NH");
		outHash.put("NJ","NJ");
		outHash.put("NM","NM");
		outHash.put("NV","NV");
		outHash.put("NY","NY");
		outHash.put("OH","OH");
		outHash.put("OK","OK");
		outHash.put("OR","OR");
		outHash.put("PA","PA");
		outHash.put("RI","RI");
		outHash.put("SC","SC");
		outHash.put("SD","SD");
		outHash.put("TN","TN");
		outHash.put("TX","TX");
		outHash.put("UT","UT");
		outHash.put("VA","VA");
		outHash.put("VT","VT");
		outHash.put("WA","WA");
		outHash.put("WI","WI");
		outHash.put("WV","WV");
		outHash.put("WY","WY");
	
  		return outHash;
  	}
        public Hashtable<String, String> getFieldValues (HttpServletRequest request, List fieldNames) {
		Hashtable<String, String> fieldValues = new Hashtable<String, String>();
        	for (Iterator fieldItr = fieldNames.iterator(); fieldItr.hasNext();) {
                	String fieldName = (String) fieldItr.next();
                	fieldValues.put(fieldName,
                                	((String)request.getParameter(fieldName) == null ? "" :
                                	(String)request.getParameter(fieldName)));
        		//log.debug("fieldValues = "); myDebugger.print(fieldValues);
        	}
		return fieldValues;
	}

        public HashMap<String, String[]> getMultipleFieldValues (HttpServletRequest request, List multipleFieldNames) {
		HashMap<String, String[]> multipleFieldValues = new HashMap<String, String[]>();
        	for (Iterator fieldItr = multipleFieldNames.iterator(); fieldItr.hasNext();) {
                	String fieldName = (String) fieldItr.next();
                	if ((String[]) request.getParameterValues(fieldName) != null) {
                        	multipleFieldValues.put(fieldName,
                                	(String[])request.getParameterValues(fieldName));
                	}
        	}
        	//log.debug("multipleFieldValues = "); myDebugger.print(multipleFieldValues);
		return multipleFieldValues;
	}
}


