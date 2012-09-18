package edu.ucdenver.ccp.PhenoGen.data;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;

import java.net.URL;
import java.net.MalformedURLException;

import java.sql.Clob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Hashtable;
import java.util.LinkedHashMap;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

import edu.ucdenver.ccp.util.Debugger;

import edu.ucdenver.ccp.util.ObjectHandler;

import edu.ucdenver.ccp.util.sql.Results;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to Protocol
 *  @author  Cheryl Hornbaker
 */

public class Protocol {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();

    	private static final String NONE = "None";
	private static final String TREATMENT_TYPE = "SAMPLE_LABORATORY_PROTOCOL";
	private static final String GROWTH_TYPE = "SAMPLE_GROWTH_PROTOCOL";
	private static final String EXTRACT_TYPE = "EXTRACT_LABORATORY_PROTOCOL";
	private static final String LABEL_TYPE = "LABEL_LABORATORY_PROTOCOL";
	private static final String HYBRID_TYPE = "HYBRID_LABORATORY_PROTOCOL";
	private static final String SCAN_TYPE = "SCANNING_LABORATORY_PROTOCOL";

	public Protocol() {
		log = Logger.getRootLogger();
	}

	public Protocol(int protocol_id) {
		log = Logger.getRootLogger();
		this.setProtocol_id(protocol_id);
	}


	private int protocol_id;
	private int protocol_type;
	private String protocol_name;
	private String protocol_description;
	private int globid;
	private String created_by_login;
	private java.sql.Timestamp protocol_create_date;
	private String type;
        private String sortColumn ="";
        private String sortOrder ="A";

	public void setProtocol_id(int inInt) {
		this.protocol_id = inInt;
	}

	public int getProtocol_id() {
		return this.protocol_id;
	}

	public void setProtocol_type(int inInt) {
		this.protocol_type = inInt;
	}

	public int getProtocol_type() {
		return this.protocol_type;
	}

	public void setProtocol_name(String inString) {
		this.protocol_name = inString;
	}

	public String getProtocol_name() {
		return this.protocol_name;
	}

	public void setProtocol_description(String inString) {
		this.protocol_description = inString;
	}

	public String getProtocol_description() {
		return this.protocol_description;
	}

	public void setGlobid(int inInt) {
		this.globid = inInt;
	}

	public int getGlobid() {
		return this.globid;
	}

	public void setCreated_by_login(String inString) {
		this.created_by_login = inString;
	}

	public String getCreated_by_login() {
		return this.created_by_login;
	}

	public void setProtocol_create_date(java.sql.Timestamp inTimestamp) {
		this.protocol_create_date = inTimestamp;
	}

	public java.sql.Timestamp getProtocol_create_date() {
		return this.protocol_create_date;
	}

        public void setSortColumn(String inString) {
                this.sortColumn = inString;
        }

        public String getSortColumn() {
                return this.sortColumn;
        }

        public void setSortOrder(String inString) {
                this.sortOrder = inString;
        }

        public String getSortOrder() {
                return this.sortOrder;
        }

	public void setTypeName(String inString) {
		this.type = inString;
	}

	public String getTypeName() {
		return this.type;
	}

	private void isRequiredAndValid(String value, String type, String messageWords, Connection conn) throws DataException, SQLException {
		isRequired(value, messageWords);
		isValid(value, type, messageWords, conn);
	}
	private void isRequired(String value, String messageWords) throws DataException {
		if (myObjectHandler.isEmpty(value) || (!myObjectHandler.isEmpty(value) && value.equals(NONE))) {
			throw new DataException("ERROR:  " + messageWords + " is required.");
		}
	}
	private void isValid(String value, String type, String messageWords, Connection conn) throws DataException, SQLException {
		if (!myObjectHandler.isEmpty(value) && 
			!value.equals(NONE) &&
			getProtocol_id(value, type, conn) == -99) {
			throw new DataException("ERROR: The " + messageWords + " you entered could not be found.  You must " +
						"edit the experiment and create a new protocol in order to "+
						"choose it in the spreadsheet");
		}
	}

	public void validateTreatment_protocol(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateTreatment_protocol");
		isValid(value, TREATMENT_TYPE, "Sample Treatment Protocol", conn);
	}

	public void validateGrowth_protocol(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateGrowth_protocol");
		isValid(value, GROWTH_TYPE, "Sample Growth Protocol", conn);
	}

	public void validateExtract_protocol(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateExtract_protocol");
		isRequiredAndValid(value, EXTRACT_TYPE, "Extract Protocol", conn);
	}

	public void validateLabel_protocol(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateLabel_protocol");
		isRequiredAndValid(value, LABEL_TYPE, "Labeled Extract Protocol", conn);
	}

	public void validateHybrid_protocol(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateHybrid_protocol");
		isRequiredAndValid(value, HYBRID_TYPE, "Hybridization Protocol", conn);
	}

	public void validateScan_protocol(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateScan_protocol");
		isRequiredAndValid(value, SCAN_TYPE, "Scanning Protocol", conn);
	}

	/**
	 * Gets all the Protocol
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Protocol objects
	 */
	public Protocol[] getPrivateProtocols(Connection conn) throws SQLException {
	
		log.debug("in getPrivateProtocols");
		String query = 
                        "select "+
                        "protocol_id, protocol_type, protocol_name, nvl(protocol_description, ''), nvl(globid, ''), "+
                        "created_by_login, to_char(protocol_create_date, 'dd-MON-yyyy hh24:mi:ss'), b.value "+
                        "from protocols a, valid_terms b "+
                        "where a.protocol_type = b.term_id "+
			"and a.protocol_name is not null "+
			"and a.created_by_login != 'public' "+
                        "order by protocol_name";

		//log.debug("query = "+query);

		Results myResults = new Results(query, conn);

		Protocol[] protocolArray = setupProtocolValues(myResults);

		myResults.close();

		return protocolArray;
	}

	/**
	 * Gets the Protocol object for this protocol_id
	 * @param protocol_id	 the identifier of the Protocol
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Protocol object
	 */
	public Protocol getProtocol(int protocol_id, Connection conn) throws SQLException {

		log.debug("in getProtocol. sysuid = "+protocol_id);

		String query = 
			"select "+
			"protocol_id, protocol_type, protocol_name, protocol_description, globid, "+
			"created_by_login, to_char(protocol_create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from protocols "+ 
			"where protocol_id = ?";

		//log.debug("query = "+query);

		Results myResults = new Results(query, protocol_id, conn);

		Protocol myProtocol = (myResults != null && myResults.getNumRows() > 0 ? 
					setupProtocolValues(myResults)[0] : null);
		myResults.close();

		return myProtocol;
	}

	/**
	 * Gets the protocol_id for this protocol_name and type. If a record is not found, then check public protocols.
	 *		If none found, return -99.
	 * @param protocol_name	 the name of the Protocol
	 * @param type	 the type of protocol -- one of the static variables listed above 
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Protocol object
	 */
	public int getProtocol_id(String protocol_name, String type, Connection conn) throws SQLException {
		
		log.debug("in getProtocol_id.  name = "+protocol_name + ", and type = "+type);
		Protocol myProtocol = getProtocolByNameAndType(protocol_name, type, conn);
		
		int sysuid = myProtocol.getProtocol_id();
		
		return sysuid;
	}

	/**
	 * Gets the Protocol object for this user and type
	 * @param user	 the user
	 * @param type	 the type of protocol -- one of the static variables listed above 
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Protocol object
	 */
	public Protocol[] getProtocolByUserAndType(String user, String type, Connection conn) throws SQLException {

		log.debug("in getProtocolByUserAndType.  user = "+user + ", and type = "+type);
		String query = 
			"select "+
			"protocol_id, protocol_type, protocol_name, "+
			"protocol_description, "+
			"globid, "+
			"created_by_login, to_char(protocol_create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from protocols p, valid_terms v "+ 
			"where p.protocol_type = v.term_id "+
			"and p.created_by_login like ? ||'%' "+
			"and p.protocol_name is not null "+
			"and v.value = ? "+
			"order by 3";

		//log.debug("query = "+query);

		Results myResults = new Results(query, new Object[] {user, type}, conn);
		log.debug("there are " + myResults.getNumRows() + " rows returned");

		Protocol[] myProtocol = setupProtocolValues(myResults);

		//log.debug("myProtocol = "); myDebugger.print(myProtocol);

		myResults.close();

		return myProtocol;
	}

	/**
   	* Gets the array of Protocol as select options
	* @param myProtocols 	an array of Protocol objects
   	* @return            a LinkedHashMap of values
   	*/
	public LinkedHashMap<String, String> getAsSelectOptions(Protocol[] myProtocols) {
        	//log.debug("in getAsSelectOptions");

        	LinkedHashMap<String, String> optionHash = new LinkedHashMap<String, String>();

        	for (int i=0; i<myProtocols.length; i++) {
                	optionHash.put(Integer.toString(myProtocols[i].getProtocol_id()), myProtocols[i].getProtocol_name());
        	}
        	return optionHash;
	}

	/**
	 * Gets the Protocol object for this user and globid
	 * @param userLoggedIn	 the User object
	 * @param globid	 the id of the public protocol
	 * @param type	 the type of protocol -- one of the static variables listed above 
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Protocol object
	 */
	public Protocol getProtocolByUserAndGlobid(User userLoggedIn, int globid, String type, Connection conn) throws SQLException {

		log.debug("in getProtocolByUserAndGlobid.  globid = "+globid + ", and type = "+type);
		String query = 
			"select "+
			"protocol_id, protocol_type, protocol_name, protocol_description, globid, "+
			"created_by_login, to_char(protocol_create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from protocols p, valid_terms v "+ 
			"where p.protocol_type = v.term_id "+
			"and p.created_by_login = ? "+
			"and p.globid = ? "+
			"and v.value = ?";

		log.debug("query = "+query);
		Results myResults = new Results(query, new Object[] {userLoggedIn.getUser_name(), globid, type}, conn);

		Protocol myProtocol = (myResults != null && myResults.getNumRows() > 0 ? 
					setupProtocolValues(myResults)[0] : new Protocol(-99)); 

		//log.debug("myProtocol = "); myDebugger.print(myProtocol);

		myResults.close();

		return myProtocol;
	}

	/**
	 * Gets the Protocol object for this protocol_name and type
	 * @param protocol_name	 the name of the Protocol
	 * @param type	 the type of protocol -- one of the static variables listed above 
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Protocol object
	 */
	public Protocol getProtocolByNameAndType(String protocol_name, String type, Connection conn) throws SQLException {

		log.debug("in getProtocolByNameAndType.  name = "+protocol_name + ", and type = "+type);
		String query = 
			"select "+
			"protocol_id, protocol_type, protocol_name, protocol_description, globid, "+
			"created_by_login, to_char(protocol_create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from protocols p, valid_terms v "+ 
			"where p.protocol_type = v.term_id "+
			"and p.protocol_name = ? "+
			"and v.value = ?";

		//log.debug("query = "+query);
		Results myResults = new Results(query, new Object[] {protocol_name, type}, conn);

		Protocol myProtocol = (myResults != null && myResults.getNumRows() > 0 ? 
					setupProtocolValues(myResults)[0] : new Protocol(-99)); 

		//log.debug("myProtocol = "); myDebugger.print(myProtocol);

		myResults.close();

		return myProtocol;
	}

	/**
	 * Gets the Public Protocols object for this globid and user 
	 * @param globid	 the globid of the Protocol
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Protocol object
	 */
	public Protocol getPublicProtocolByGlobid(int globid, Connection conn) throws SQLException {

		log.debug("in getPublicProtocolByGlobid.  globid = "+globid);
		String query = 
			"select "+
			"protocol_id, protocol_type, protocol_name, "+
			"nvl(protocol_description, 'No Description Provided'), "+
			"globid, "+
			"created_by_login, to_char(protocol_create_date, 'dd-MON-yyyy hh24:mi:ss') "+
			"from protocols  "+ 
			"where protocol_id = ?";

		//log.debug("query = "+query);
		Results myResults = new Results(query, new Object[] {globid}, conn);

		Protocol myProtocol = (myResults != null && myResults.getNumRows() > 0 ? 
					setupProtocolValues(myResults)[0] : new Protocol(-99)); 

		//log.debug("myProtocol = "); myDebugger.print(myProtocol);

		myResults.close();

		return myProtocol;
	}

	/**
	 * Gets the Protocol objects for this type
	 * @param user	 name of user
	 * @param myProtocols	 an array of Protocol objects
	 * @param type	 the type of protocol -- one of the static variables listed above 
	 * @return	an array of Protocol objects
	 */
	public Protocol[] getProtocolForUserByType(String user, Protocol[] myProtocols, String type) {

		log.debug("in getProtocolByType.  type = "+type);

		List<Protocol> protocolList = new ArrayList<Protocol>();
		if (myProtocols != null && myProtocols.length > 0) {
                	for (int i=0; i<myProtocols.length; i++) {
                        	Protocol thisProtocol = myProtocols[i];
                                if (thisProtocol.getCreated_by_login().startsWith(user) &&
                                                thisProtocol.getTypeName().equals(type)) {
					protocolList.add(thisProtocol);
				}
			}
		}
		
		Protocol[] protocolArray = (Protocol[]) protocolList.toArray(new Protocol[protocolList.size()]);
		return protocolArray;

	}

        /**
         * Gets a Protocol object from a set of Protocols based on the globid.
         * @param globid the globid 
         * @param protocols an array of Protocol objects
         * @return      a Protocol object
        */
        public Protocol getProtocolByGlobid(int globid, Protocol[] protocols) {
		log.debug("in getProtocolByGlobid.  globid="+globid);
		for (int i=0; i<protocols.length; i++) {
                	Protocol thisProtocol = protocols[i];
			//log.debug("thisProtocolglobid = "+thisProtocol.getGlobid());
                        if (thisProtocol.getGlobid() == globid) {
				//log.debug("it matches");
                        	return thisProtocol;
			}
		}
		log.debug("nothing ever matched");
                return null;
        }

	/**
	 * Gets the public protocols
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Protocol objects
	 */
	public Protocol[] getPublicProtocols(Connection conn) throws SQLException, MalformedURLException {

		log.debug("in getPublicProtocols");
		String query = 
                        "select "+
                        "protocol_id, protocol_type, protocol_name, nvl(protocol_description, ''), nvl(globid, ''), "+
                        "created_by_login, to_char(protocol_create_date, 'dd-MON-yyyy hh24:mi:ss'), b.value "+
                        "from protocols a, valid_terms b "+
                        "where a.protocol_type = b.term_id "+
			"and a.protocol_name is not null "+
			"and a.created_by_login = 'public' "+
                        "order by protocol_name";

		//log.debug("query = "+query);

		Results myResults = new Results(query, conn);

		Protocol[] protocolArray = setupProtocolValues(myResults);

		myResults.close();

		return protocolArray;
	}

        /**
         * Creates record in the protocols table so it will be available for experiment_protocols table
         * @param userLoggedIn User object of the person logged in
         * @param globid id of the public protocol
         * @param protocolType the type of protocol
         * @param conn  the database connection
         * @throws SQLException if an error occurs while accessing the database
	 * @return	the identifier of the record created
         */
        public int createForPublicProtocol(User userLoggedIn, int globid, String protocolType, Connection conn) throws SQLException {

                log.debug("in Protocol createForPublicProtocol with globid. globid = " + globid);

		Protocol myProtocol = new Protocol();                        

	        int protocolCode = new ValidTerm().getValidTermByValueAndID(protocolType, "PROTOCOL_HEADER_TYPE", conn).getTerm_id();
	        log.debug("protocolType = "+protocolType+ ", code = "+protocolCode);

		int protocol_id = getProtocolByUserAndGlobid(userLoggedIn, globid, protocolType, conn).getProtocol_id();
		log.debug("protocol_id = "+protocol_id);
		if (protocol_id == -99) {
                	myProtocol.setProtocol_type(protocolCode);
                	myProtocol.setGlobid(globid);
                	myProtocol.setCreated_by_login(userLoggedIn.getUser_name());

                	return myProtocol.createProtocol(conn);
		} else {
			return protocol_id;
		}
	}

        /**
         * Creates record in the protocols table based on values from the form
         * @param userLoggedIn User object of the person logged in
         * @param fieldValues fieldNames mapped to their values
         * @param conn  the database connection
         * @throws SQLException if an error occurs while accessing the database
	 * @return	the identifier of the record created
         */
        public int createProtocol(User userLoggedIn, Hashtable<String, String> fieldValues, Connection conn) throws SQLException {

                log.debug("in Protocol create with fieldValues and multipleFieldValues");
                //log.debug("fieldValues = "); myDebugger.print(fieldValues);
                //log.debug("multipleFieldValues = "); myDebugger.print(multipleFieldValues);
		Protocol myProtocol = new Protocol();                        

	        int protocolCode = new ValidTerm().getValidTermByValueAndID((String) fieldValues.get("protocolType"), 
							"PROTOCOL_HEADER_TYPE", conn).getTerm_id();
	        log.debug("protocolCode = "+protocolCode);

                myProtocol.setProtocol_type(protocolCode);
                myProtocol.setProtocol_name((String) fieldValues.get("protocolName"));
                myProtocol.setProtocol_description((String) fieldValues.get("description"));
                myProtocol.setCreated_by_login(userLoggedIn.getUser_name());

                return myProtocol.createProtocol(conn);
	}

	/**
	 * Creates a record in the protocols table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createProtocol(Connection conn) throws SQLException {

		int protocol_id = myDbUtils.getUniqueID("protocols_seq", conn);

		log.debug("In create Protocol");
		String query = 
			"insert into protocols "+
			"(protocol_id, protocol_type, protocol_name, protocol_description, globid, "+
			"created_by_login, protocol_create_date) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?)";
		PreparedStatement pstmt = null;

		try {
			java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

			pstmt.setInt(1, protocol_id);
			pstmt.setInt(2, protocol_type);
			pstmt.setString(3, protocol_name);
			pstmt.setString(4, protocol_description);
log.debug("going to set to null if zero.  it is = " + globid);
			myDbUtils.setToNullIfZero(pstmt, 5, globid);
			pstmt.setString(6, created_by_login);
			pstmt.setTimestamp(7, now);

			pstmt.executeUpdate();
			pstmt.close();

			this.setProtocol_id(protocol_id);

		} catch (SQLException e) {
			log.error("In exception of createProtocol", e);
			throw e;
		}
		return protocol_id;
	}

	/**
	 * Updates a record in the protocols table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 
			"update protocols "+
			"set protocol_id = ?, protocol_type = ?, protocol_name = ?, protocol_description = ?, globid = ?, "+
			"created_by_login = ?, protocol_create_date = ? "+
			"where protocol_id = ?";

		PreparedStatement pstmt = null;

		try {
			java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

			pstmt.setInt(1, protocol_id);
			pstmt.setInt(2, protocol_type);
			pstmt.setString(3, protocol_name);
			pstmt.setString(4, protocol_description);
			pstmt.setInt(5, globid);
			pstmt.setString(6, created_by_login);
			pstmt.setTimestamp(7, protocol_create_date);
			pstmt.setInt(8, protocol_id);

			pstmt.executeUpdate();
			pstmt.close();

		} catch (SQLException e) {
			log.error("In exception of update protocols", e);
			throw e;
		}
	}


        /**
         * Deletes the record in the protocols table and also deletes child records in related tables.
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteProtocol(Connection conn) throws SQLException {

                log.info("in deleteProtocols");

                //conn.setAutoCommit(false);

                PreparedStatement pstmt = null;
                try {

			new Hybridization().deleteAllHybridizationForProtocol(protocol_id, conn);
			new Tlabel().deleteAllTlabelForProtocol(protocol_id, conn);
			new Textract().deleteAllTextractForProtocol(protocol_id, conn);
			new Tsample().deleteAllTsampleForProtocol(protocol_id, conn);
			new Protocol_value().deleteAllProtocol_valuesForProtocol(protocol_id, conn);
			new Experiment_protocol().deleteAllExperiment_protocolsForProtocol(protocol_id, conn);

                        String query =
                                "delete from protocols " +
                                "where protocol_id = ?";

                        pstmt = conn.prepareStatement(query,
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                        pstmt.setInt(1, protocol_id);
                        pstmt.executeQuery();
                        pstmt.close();

                        //conn.commit();
                } catch (SQLException e) {
                        log.debug("error in deleteProtocol");
                        //conn.rollback();
                        pstmt.close();
                        throw e;
                }
                //conn.setAutoCommit(true);
        }

        /**
         * Checks to see if a Protocol with the same  combination already exists.
         * @param myProtocol    the Protocol object being tested
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         * @return      the protocol_id of a Protocol that currently exists
         */
        public int checkRecordExists(Protocol myProtocol, Connection conn) throws SQLException {

                log.debug("in checkRecordExists");

                String query =
                        "select protocol_id "+
                        "from protocols "+
                        "where  = ?";

                PreparedStatement pstmt = conn.prepareStatement(query,
                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                        ResultSet.CONCUR_UPDATABLE);


                ResultSet rs = pstmt.executeQuery();

                int pk = (rs.next() ? rs.getInt(1) : -1);
                pstmt.close();
                return pk;
        }

	/**
	 * Creates an array of Protocol objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Protocol
	 * @return	An array of Protocol objects with their values setup 
	 */
	public Protocol[] setupProtocolValues(Results myResults) throws SQLException {

		log.debug("in setupProtocolValues");

		List<Protocol> protocolList = new ArrayList<Protocol>();

		Object[] dataRow;

		while ((dataRow = myResults.getNextRowWithClob()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			//log.debug("dataRow length = "+dataRow.length);
			Protocol thisProtocol = new Protocol();

			thisProtocol.setProtocol_id(Integer.parseInt((String)dataRow[0]));
			thisProtocol.setProtocol_type(Integer.parseInt((String)dataRow[1]));
			thisProtocol.setProtocol_name((String)dataRow[2]);
			if (dataRow[3] != null) {
				if (dataRow[3].getClass().getName().equals("oracle.sql.CLOB")) {
				//log.debug("class = " + dataRow[3].getClass().getName());
				thisProtocol.setProtocol_description(myResults.getClobAsString(dataRow[3]));
				} else {
					log.debug("class = " + dataRow[3].getClass().getName());
					thisProtocol.setProtocol_description((String) dataRow[3]);
				}
			}
			thisProtocol.setGlobid((((String) dataRow[4]) != null ? Integer.parseInt((String) dataRow[4]) : -99));
			thisProtocol.setCreated_by_login((String) dataRow[5]);
			thisProtocol.setProtocol_create_date(new ObjectHandler().getOracleDateAsTimestamp((String) dataRow[6]));
			if (dataRow.length > 7 && ((String) dataRow[7]) != null && !((String) dataRow[7]).equals("")) {
				thisProtocol.setTypeName((String) dataRow[7]);
			}

			protocolList.add(thisProtocol);
		}

		Protocol[] protocolArray = (Protocol[]) protocolList.toArray(new Protocol[protocolList.size()]);

		return protocolArray;
	}

        /**
         * Compares Protocol based on different fields.
         */
        public class ProtocolSortComparator implements Comparator<Protocol> {
                int compare;
                Protocol protocol1, protocol2;

                public int compare(Protocol object1, Protocol object2) {
                        String sortColumn = getSortColumn();
                        String sortOrder = getSortOrder();

                        if (sortOrder.equals("A")) {
                                protocol1 = object1;
                                protocol2 = object2;
                                // default for null columns for ascending order
                                compare = 1;
                        } else {
                                protocol2 = object1;
                                protocol1 = object2;
                                // default for null columns for ascending order
                                compare = -1;
                        }

                        //log.debug("protocol1 = " +protocol1+ "protocol2 = " +protocol2);

                        if (sortColumn.equals("protocol_id")) {
                                compare = new Integer(protocol1.getProtocol_id()).compareTo(new Integer(protocol2.getProtocol_id()));
                        } else if (sortColumn.equals("protocol_type")) {
                                compare = new Integer(protocol1.getProtocol_type()).compareTo(new Integer(protocol2.getProtocol_type()));
                        } else if (sortColumn.equals("protocol_name") && protocol1.getProtocol_name() != null && protocol2.getProtocol_name() != null) {
                                compare = protocol1.getProtocol_name().compareTo(protocol2.getProtocol_name());
                        } else if (sortColumn.equals("protocol_description")) {
                                compare = protocol1.getProtocol_description().compareTo(protocol2.getProtocol_description());
                        } else if (sortColumn.equals("globid")) {
                                compare = new Integer(protocol1.getGlobid()).compareTo(new Integer(protocol2.getGlobid()));
                        } else if (sortColumn.equals("created_by_login")) {
                                compare = protocol1.getCreated_by_login().compareTo(protocol2.getCreated_by_login());
                        } else if (sortColumn.equals("protocol_create_date")) {
                                compare = protocol1.getProtocol_create_date().compareTo(protocol2.getProtocol_create_date());
                        }
                        return compare;
                }
        }

        public Protocol[] sortProtocols (Protocol[] myProtocols, String sortColumn, String sortOrder) {
                setSortColumn(sortColumn);
                setSortOrder(sortOrder);
                Arrays.sort(myProtocols, new ProtocolSortComparator());
                return myProtocols;
        }

        /**
         * Determines equality of Protocol objects.  
         * @param obj    the Protocol object being tested for equality
         * @return      true if the objects are equal, otherwise false                  
         */
        public boolean equals(Object obj) {
                //log.debug("in equals");
                if (!(obj instanceof Protocol)) return false;
                return (this.protocol_id == ((Protocol) obj).protocol_id);
        }

	public String toString() {
		return "This Protocol object has name = " + protocol_name + " and sysuid = "+protocol_id + " and type = " + protocol_type; 
	}

	public void print() {
		log.debug(toString());
	}

}
