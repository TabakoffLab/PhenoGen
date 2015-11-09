package edu.ucdenver.ccp.PhenoGen.data;

import java.io.File;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.sql.DataSource;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.Results;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email; 
import edu.ucdenver.ccp.PhenoGen.web.SessionHandler; 

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to managing users. 
 *  @author  Cheryl Hornbaker
 */

public class User{
  private int user_id;
  private String title="Dr.";
  private String first_name="";
  private String middle_name="";
  private String last_name="";
  private String full_name="";
  private String formal_name="";
  private String sorting_name="";
  private String user_name="";
  private String password="";
  private String email="";
  private String telephone="";
  private String fax="";
  private String institution="";
  private String lab_name="";
  private String box="";
  private String street="";
  private String city="";
  private String state="CO";
  private String zip="";
  private String country="USA";
  private String userMainDir;
  private int pi_user_id=-99;
  private int checked;
  private List<User> subordinates;

  private Hashtable user_chips;

  private Logger log=null;

  private DbUtils myDbUtils = new DbUtils();

  public User (int user_id) {
	log = Logger.getRootLogger();
	this.setUser_id(user_id);
  }

  public User (int user_id, String userName) {
	log = Logger.getRootLogger();
	this.setUser_id(user_id);
	this.setUser_name(userName);
  }

  public User () {
	log = Logger.getRootLogger();
  }

  public int getUser_id() {
    return user_id; 
  }

  public void setUser_id(int inInt) {
    this.user_id = inInt;
  }

  public void setTitle(String inString) {
    this.title = inString;
  }

  public String getTitle() {
    return title; 
  }

  public void setFirst_name(String inString) {
    this.first_name = inString;
  }

  public String getFirst_name() {
    return first_name; 
  }

  public void setMiddle_name(String inString) {
    this.middle_name = inString;
  }

  public String getMiddle_name() {
    return middle_name; 
  }

  public void setLast_name(String inString) {
    this.last_name = inString;
  }

  public String getLast_name() {
    return last_name; 
  }

  public void setFormal_name(String inString) {
    this.formal_name = inString;
  }

  public String getFormal_name() {
    return formal_name; 
  }

  public void setSorting_name(String inString) {
    this.sorting_name = inString;
  }

  public String getSorting_name() {
    return sorting_name; 
  }

  public void setFull_name(String inString) {
    this.full_name = inString;
  }

  public String getFull_name() {
    return full_name; 
  }

  public void setUser_name(String inString) {
    this.user_name = inString;
  }

  public String getUser_name() {
    return user_name;
  }

  public void setPassword(String inString) {
    this.password = inString;
  }

  public String getPassword() {
    return password;
  }

  public void setEmail(String inString) {
    this.email = inString;
  }

  public String getEmail() {
    return email;
  }

  public void setTelephone(String inString) {
    this.telephone = inString;
  }

  public String getTelephone() {
    return telephone;
  }

  public void setFax(String inString) {
    this.fax = inString;
  }

  public String getFax() {
    return fax;
  }

  public void setInstitution(String inString) {
    this.institution = inString;
  }

  public String getInstitution() {
    return institution;
  }

  public void setLab_name(String inString) {
    this.lab_name = inString;
  }

  public String getLab_name() {
    return lab_name;
  }

  public void setBox(String inString) {
    this.box = inString;
  }

  public String getBox() {
    return box;
  }

  public void setStreet(String inString) {
    this.street = inString;
  }

  public String getStreet() {
    return street;
  }

  public void setCity(String inString) {
    this.city = inString;
  }

  public String getCity() {
    return city;
  }

  public void setState(String inString) {
    this.state = inString;
  }

  public String getState() {
    return state;
  }

  public void setZip(String inString) {
    this.zip = inString;
  }

  public String getZip() {
    return zip;
  }

  public void setCountry(String inString) {
    this.country = inString;
  }

  public String getCountry() {
    return country;
  }

  public String getUser_name_and_domain() {
    return user_name + "@phenogen.ucdenver.edu";
  }

	/** Sets the user's main directory.  
	 * @param userFilesRoot	location of the website filesystem's topmost directory (~/userFiles).  Upon login, userMainDir is set to "~/userFiles/userName/".
	 */
	public void setUserMainDir(String userFilesRoot) {
		this.userMainDir = userFilesRoot + this.getUser_name() + "/";
	}

	/** Retrieves the user's main directory.  
	 * @return location of the user's topmost directory.  Upon login, this is set to "~/userFiles/userName/".
	 */
	public String getUserMainDir() {
		return userMainDir;
	}

	/** Retrieves the user's main directory, given the filesystem's topmost directory.  
	 * @param userFilesRoot	location of the website filesystem's topmost directory (~/userFiles).  
	 * @return location of the user's topmost directory.  I.e., "~/userFiles/userName/".
	 */
	public String getUserMainDir(String userFilesRoot) {
		return userFilesRoot + this.getUser_name() + "/";
	}

	/**
	 * Constructs the path where files related to datasets will be stored.
	 * @return            a String containing the directory for datasets
	 *			(e.g., ~/userFiles/userName/Datasets/)
	 */
  	public String getUserDatasetDir() {
		return getUserMainDir() + "Datasets" + "/";
  	}

	/**
	 * Constructs the path where files related to experiments will be stored.
	 * @return            a String containing the directory for experiments
	 *			(e.g., ~/userFiles/userName/Experiments/)
	 */
  	public String getUserExperimentDir() {
		return getUserMainDir() + "Experiments" + "/";
  	}

	/**
	 * Constructs the path where files related to genelists will be stored.
	 * @return            a String containing the directory for genelists
	 *			(e.g., ~/userFiles/userName/GeneLists/)
	 */
  	public String getUserGeneListsDir() {
		return getUserMainDir() + "GeneLists" + "/";
  	}

	/**
	 * Constructs the path where uploaded files related to genelists will be stored.
	 * @return            a String containing the directory for uploaded genelists
	 *			(e.g., ~/userFiles/userName/GeneLists/uploads/)
	 */
  	public String getUserGeneListsUploadDir() {
		return getUserGeneListsDir() + "uploads" + "/";
  	}

	/**
	 * Constructs the path where downloaded files related to genelists will be stored.
	 * @return            a String containing the directory for downloaded genelists
	 *			(e.g., ~/userFiles/userName/GeneLists/downloads/)
	 */
  	public String getUserGeneListsDownloadDir() {
		return getUserGeneListsDir() + "downloads" + "/";
  	}

	/**
	 * Constructs the path where uploaded files related to datasets will be stored.
	 * @return            a String containing the upload directory for datasets
	 *			(e.g., ~/userFiles/userName/Datasets/uploads/)
	 */
  	public String getUserDatasetUploadDir() {
		return getUserDatasetDir() + "uploads" + "/";
  	}

	/**
	 * Constructs the path where uploaded files related to experiments will be stored.
	 * @return            a String containing the upload directory for experiments
	 *			(e.g., ~/userFiles/userName/Experiments/uploads/)
	 */
  	public String getUserExperimentUploadDir() {
		return getUserExperimentDir() + "uploads" + "/";
  	}

	/**
	 * Constructs the path where downloaded files related to experiments will be stored.
	 * @return            a String containing the directory for downloaded experiment files
	 *			(e.g., ~/userFiles/userName/Experiments/downloads)
	 */
  	public String getUserExperimentDownloadDir() {
		return getUserExperimentDir() + "downloads" + "/";
  	}


  public void setPi_user_id(int inInt) {
    this.pi_user_id = inInt;
  }

  public int getPi_user_id() {
    return pi_user_id;
  }

  public void setChecked(int inInt) {
    this.checked = inInt;
  }

  public int getChecked() {
    return checked;
  }

  public void setSubordinates(List<User> inList) {
    this.subordinates = inList;
  }

  public List<User> getSubordinates() {
    return subordinates;
  }

  public void setUser_chips(Hashtable user_chips) {
    this.user_chips = user_chips;
  }

  public Hashtable getUser_chips() {
    return user_chips;
  }

	/**
	 * Gets the users who report to this principal investigator.
	 * @param user_id the id of the PI
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a comma-separated string of user_names
	 */
	public String getSubordinates(int user_id, Connection conn) throws SQLException {
	
		log.debug("in getSubordinates. user_id = " + user_id);

        	String query =
                	"select user_id, "+
			"user_name "+
                	"from users "+
			"where pi_user_id = ? "+
			"order by user_name";

		String subordinates = "";
		//log.debug("query = "+query);

        	Results myResults = new Results(query, user_id, conn);

        	subordinates = "(" +
                		new ObjectHandler().getResultsAsSeparatedString(myResults, ",", "'", 1)
                		+ ")";

		if (subordinates.equals("()")) {
			subordinates = "('')";
		}

        	myResults.close();

		return subordinates;
	}

	/**
	 * Returns the user_id of this principal investigator for the user passed in.
	 * @param user_id the id of the user
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the user_id of the PI
	 */

	public int getPi_user_id(int user_id, Connection conn) throws SQLException {

		//log.debug("in getPi_user_id. user_id = " + user_id);

        	String query =
                	"select pi_user_id "+
                	"from users "+
			"where user_id = ?";

		//log.debug("query = "+query);

                Results myResults = new Results(query, user_id, conn);

                int pi_user_id = myResults.getIntValueFromFirstRow();

                myResults.close();

		return pi_user_id;
	}

	//
	// returns whether this user is a principal investigator 
	//
  	public boolean checkPI(DataSource pool) throws SQLException {
	
		log.debug("in checkPI");
        	String query =
                	"select count(*) "+
                	"from users "+
			"where pi_user_id = ?";

		boolean principal_investigator = false;
                Connection conn=pool.getConnection();
		Results myResults = new Results(query, this.user_id, conn);

        	int subordinates = myResults.getIntValueFromFirstRow();
		if (subordinates == 0) {
			log.debug("user is not a principal_investigator");
			principal_investigator = false;
		} else {
			log.debug("user is a principal_investigator");
			principal_investigator = true;
		}

        	myResults.close();
                try{
                    conn.close();
                }catch(Exception e){}
		return principal_investigator;
	}
        
        public boolean checkIsUserPublic(int userID,Connection conn) throws SQLException {
	
		log.debug("in checkIsUserPublic");
        	String query =
                	"select user_id "+
                	"from users "+
			"where username like 'public'";

		boolean ispublic = false;
		PreparedStatement ps=conn.prepareStatement(query);
                ResultSet rs=ps.executeQuery();
                if(rs.next()){
                    int publicUserID=rs.getInt(1);
                    log.debug("Public user is "+publicUserID);
                    if (publicUserID==userID) {
                            ispublic=true;
                    } 
                    
                }
                ps.close();
		return ispublic;
	}

  public boolean checkRole(String user_name, String password, String role, DataSource pool) throws SQLException {

		log.debug("in checkRole. user_name = "+ user_name + ", and role = "+role); 
		String query = 
			"select 'x' "+
			"from users u "+
			"where user_name = ? "+
			"and password = ? "+
			"and exists "+
			"	(select 'x' "+
			"	from roles r "+
			"	where r.user_id = u.user_id "+
			"	and role_name = ?)";

		//log.debug("query = "+ query);
	
		boolean hasRole = false;
                Connection conn=pool.getConnection();
		Results myResults = new Results(query, new Object[] {user_name, password, role}, conn);

        	String value = myResults.getStringValueFromFirstRow();

        	myResults.close();
                
                try{
                    conn.close();
                }catch(Exception e){}
                
		if (value.equals("x")) {
			log.debug("user does have that role ");
			hasRole = true;			
		} else {
			log.debug("user does NOT have that role ");
			hasRole = false;
		}
		return hasRole;
	}
  

	/**
	 * Gets all the users 
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	an array of User objects
	 */
	public User[] getAllUsers(Connection conn) throws SQLException {

        	String query =
                	"select u.user_id, u.user_name, u.first_name, u.last_name, u.institution "+
                	"from users u "+
			"order by u.last_name";

		//log.debug("in getAllUsers");

                Results myResults = new Results(query, conn);
		String[] dataRow;
		List<User> userList = new ArrayList<User>();

		while ((dataRow = myResults.getNextRow()) != null) {
			User newUser = new User(Integer.parseInt(dataRow[0]), dataRow[1]);
			newUser.setFirst_name(dataRow[2]);
			newUser.setLast_name(dataRow[3]);
                        newUser.setInstitution(dataRow[4]);
			userList.add(newUser);
		}
		User[] myUsers = (User[]) userList.toArray(new User[userList.size()]);
		
		myResults.close();

        	return myUsers;
	}

	/**
	 * Gets the users who are not yet approved.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	an array of User objects 
	 */
	public User[] getUnApprovedUsers(Connection conn) throws SQLException {

        	String query =
                	"select u.user_id, "+
                	"u.last_name "+
                	"from users u "+
			"where approved = 'N' "+
			"order by u.last_name";

		log.debug("in getUnApprovedUsers");
		//log.debug("query = " + query);

                Results myResults = new Results(query, conn);
		List<User> userList = new ArrayList<User>();
        	String[] dataRow;

        	while ((dataRow = myResults.getNextRow()) != null) {
        		User thisUser = getUser(Integer.parseInt(dataRow[0]), conn); 
			userList.add(thisUser);
		}

                User[] myUsers = (User[]) userList.toArray(new User[userList.size()]);

		myResults.close();

		return myUsers;
	}

        /**
	 * Gets the principal investigators.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a LinkedHashMap of the PI's user_id mapped to the name
	 */
	public LinkedHashMap getAllPrincipalInvestigators(DataSource pool) throws SQLException {
		String query =
			"select pi.user_id, "+
			"pi.last_name||', '||pi.title||' '||pi.first_name "+
			"from users pi "+
			"where exists ("+
			"	select 'x' "+
			"	from users u "+
			"	where u.pi_user_id = pi.user_id)  "+
			"and pi.approved = 'Y' "+
			"order by pi.last_name";
                                                                                                                      
		log.debug("in getAllPrincipalInvestigators");
		//log.debug("query = "+query);
                Connection conn=pool.getConnection();                                                                                                     
		Results myResults = new Results(query, conn);
		String[] dataRow;
		LinkedHashMap<String, String> piHash = new LinkedHashMap<String, String>();
		while ((dataRow = myResults.getNextRow()) != null) {
                        piHash.put(dataRow[0], dataRow[1]);
                }
                try{
                    conn.close();
                }catch(Exception e){}
		return piHash;
	}
        
	/**
	 * Gets the principal investigators.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a LinkedHashMap of the PI's user_id mapped to the name
	 */
	public LinkedHashMap getAllPrincipalInvestigators(Connection conn) throws SQLException {
		String query =
			"select pi.user_id, "+
			"pi.last_name||', '||pi.title||' '||pi.first_name "+
			"from users pi "+
			"where exists ("+
			"	select 'x' "+
			"	from users u "+
			"	where u.pi_user_id = pi.user_id)  "+
			"and pi.approved = 'Y' "+
			"order by pi.last_name";
                                                                                                                      
		log.debug("in getAllPrincipalInvestigators");
		//log.debug("query = "+query);
                                                                                                                     
		Results myResults = new Results(query, conn);
		String[] dataRow;
		LinkedHashMap<String, String> piHash = new LinkedHashMap<String, String>();
		while ((dataRow = myResults.getNextRow()) != null) {
                        piHash.put(dataRow[0], dataRow[1]);
                }
		return piHash;
	}

	/**
	 * Gets the principal investigator for each user_name.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the a HashMap of the user_name mapped to a principal investigator User object
	 */
	public HashMap getPrincipalInvestigatorsByUser(Connection conn) throws SQLException {

		//log.info("in getPrinicpalInvestigatorsByUser");

        	String query =
                	"select u.user_name, pi.user_id "+ 
                	"from users u, "+
                	"users pi "+
                	"where u.pi_user_id = pi.user_id "+
			"order by u.user_name";

		String[] dataRow;
		HashMap<String, User> piHashMap = new HashMap<String, User>();

                Results myResults = new Results(query, conn);

                int piNumRows = myResults.getNumRows();

                if (piNumRows > 0) {
                        while ((dataRow = myResults.getNextRow()) != null) {
                                User principalInvestigator = getUser(Integer.parseInt(dataRow[1]), conn);
                                piHashMap.put(dataRow[0], principalInvestigator);
                        }
                }
                myResults.close();

        	return piHashMap;
	}

	/**
	 * Retrieves the principal investigators along with a comma-delimited string of the users reporting to them.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a Hashtable mapping the PI's name to a List of subordinate names
	 */
	public Hashtable<String, List<String>> getSubordinateListByPI(Connection conn) throws SQLException {
	
		log.debug("in getSubordinateListByPI");

        	String query =
			/*
			"select "+
			"'Public Data', "+
			"'Public', "+
			"'', "+
			"1 "+
			"from dual "+
			"union "+
			"select pi.title||' '||pi.first_name||' '||pi.last_name, "+
			"to_char('('||join(cursor(select ''''||u.user_name||'''' "+
			"		from users u "+
			"		where u.pi_user_id = pi.user_id))||')'), "+
			"pi.last_name, "+
			"2 "+
			"from users pi "+
			"where exists (select 'x' "+
			"		from users u2 "+
			"		where u2.pi_user_id = pi.user_id) "+
			"order by 4, 3";
			*/
			"select pi.last_name||', '||pi.first_name||' '||pi.title, "+
			"u.user_name "+
			"from users u, users pi "+
			"where u.pi_user_id = pi.user_id "+
			"order by 1, 2";

		//log.debug("query = "+query);

		Results myResults = new Results(query, conn);

		Hashtable<String, List<String>> piHash = new ObjectHandler().getResultsAsHashtablePlusList(myResults); 

        	return piHash;
	}

	/**
	 * Gets the user information as a string.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a string that looks like: Title. First_name Last_name from the 
	 * 		Institution in City, State (Email address: Email
	 *		 Phone number: Telephone)
	 */

	public String getUserInfoAsString(Connection conn) throws SQLException {

		log.debug("in getUserInfoAsString");

		// Make sure this isn't needed!
		User thisUser = getUser(this.getUser_id(), conn);
		String userInformation = thisUser.getTitle() + " " +
				thisUser.getFirst_name() + " " +
				thisUser.getLast_name() + " from the " +
				thisUser.getInstitution() + " in " +
				thisUser.getCity() + ", " +
				thisUser.getState() + " (Email Address:  " +
				thisUser.getEmail() + ", Phone Number: " +
				thisUser.getTelephone() + ") ";

        	return userInformation;
	}

        /**
	 * Gets the user_name for a user_id.
	 * @param user_id	the identifier for a user
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the user_name of the user
	 */
	public String getUser_name(int user_id, DataSource pool) throws SQLException {

		log.debug("in getUser_name. ");

		String query = 
			"select user_name "+
			"from users "+
			"where user_id = ?";

		//log.debug("query = " + query);
                Connection conn=pool.getConnection();
		Results myResults = new Results(query, user_id, conn);

        	String user_name = myResults.getStringValueFromFirstRow();

        	myResults.close();
                try{
                    conn.close();
                }catch(Exception e){}
                
		return user_name;
	}
        
	/**
	 * Gets the user_name for a user_id.
	 * @param user_id	the identifier for a user
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the user_name of the user
	 */
	public String getUser_name(int user_id, Connection conn) throws SQLException {

		log.debug("in getUser_name. ");

		String query = 
			"select user_name "+
			"from users "+
			"where user_id = ?";

		//log.debug("query = " + query);

		Results myResults = new Results(query, user_id, conn);

        	String user_name = myResults.getStringValueFromFirstRow();

        	myResults.close();

		return user_name;
	}



	/**
	 * Gets the person who approves website access
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the User object of the person who can approve access
	 */
	public User getRegistrationApprover(Connection conn) throws SQLException {

		log.debug("in RegistrationApprover");

		User myUser = getUser("bhaves", conn);

        	return myUser;
	}


	/**
	 * Gets the User object for this user_id
	 * @param user_id the identifier of the user
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a User object
	 */
	public User getUser(int user_id, DataSource pool) throws SQLException {

		//log.debug("in getUser passing in user_id");

        	String query =
			"select nvl(title,' '), first_name, middle_name, last_name, "+
                	"user_name, password, email, telephone, fax, "+
                	"institution, lab_name, box, street, city, "+
                	"state, zip, country, pi_user_id "+
                	"from users "+
                	"where user_id = ?";
                Connection conn=pool.getConnection();
        	Results myResults = new Results(query, user_id, conn);
        	User myUser = new User();

        	String[] dataRow;

        	while ((dataRow = myResults.getNextRow()) != null) {

			myUser.setUser_id(user_id);
                	myUser.setTitle(myDbUtils.setToEmptyIfNull(dataRow[0]));
                	myUser.setFirst_name(dataRow[1]);
                	myUser.setMiddle_name(dataRow[2]);
                	myUser.setLast_name(dataRow[3]);
                	myUser.setUser_name(dataRow[4]);
                	myUser.setPassword(dataRow[5]);
              		myUser.setEmail(dataRow[6]);
                	myUser.setTelephone(dataRow[7]);
                	myUser.setFax(dataRow[8]);
                	myUser.setInstitution(dataRow[9]);
                	myUser.setLab_name(dataRow[10]);
                	myUser.setBox(dataRow[11]);
                	myUser.setStreet(dataRow[12]);
                	myUser.setCity(dataRow[13]);
                	myUser.setState(dataRow[14]);
                	myUser.setZip(dataRow[15]);
                	myUser.setCountry(dataRow[16]);
                	myUser.setPi_user_id(Integer.parseInt(dataRow[17]));
			myUser.setFull_name(dataRow[0] + " " + dataRow[1] + " " + dataRow[3]);
			myUser.setFormal_name(dataRow[0] + " " + dataRow[3]);
			myUser.setSorting_name(dataRow[3] + ", "+dataRow[0] + " " + dataRow[1]);

        	}
        	myResults.close();
                try{
                    conn.close();
                }catch(Exception e){}
        	return myUser;
	}
        /**
	 * Gets the User object for this user_id
	 * @param user_id the identifier of the user
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a User object
	 */
	public User getUser(int user_id, Connection conn) throws SQLException {

		//log.debug("in getUser passing in user_id");

        	String query =
			"select nvl(title,' '), first_name, middle_name, last_name, "+
                	"user_name, password, email, telephone, fax, "+
                	"institution, lab_name, box, street, city, "+
                	"state, zip, country, pi_user_id "+
                	"from users "+
                	"where user_id = ?";

        	Results myResults = new Results(query, user_id, conn);
        	User myUser = new User();

        	String[] dataRow;

        	while ((dataRow = myResults.getNextRow()) != null) {

			myUser.setUser_id(user_id);
                	myUser.setTitle(myDbUtils.setToEmptyIfNull(dataRow[0]));
                	myUser.setFirst_name(dataRow[1]);
                	myUser.setMiddle_name(dataRow[2]);
                	myUser.setLast_name(dataRow[3]);
                	myUser.setUser_name(dataRow[4]);
                	myUser.setPassword(dataRow[5]);
              		myUser.setEmail(dataRow[6]);
                	myUser.setTelephone(dataRow[7]);
                	myUser.setFax(dataRow[8]);
                	myUser.setInstitution(dataRow[9]);
                	myUser.setLab_name(dataRow[10]);
                	myUser.setBox(dataRow[11]);
                	myUser.setStreet(dataRow[12]);
                	myUser.setCity(dataRow[13]);
                	myUser.setState(dataRow[14]);
                	myUser.setZip(dataRow[15]);
                	myUser.setCountry(dataRow[16]);
                	myUser.setPi_user_id(Integer.parseInt(dataRow[17]));
			myUser.setFull_name(dataRow[0] + " " + dataRow[1] + " " + dataRow[3]);
			myUser.setFormal_name(dataRow[0] + " " + dataRow[3]);
			myUser.setSorting_name(dataRow[3] + ", "+dataRow[0] + " " + dataRow[1]);

        	}
        	myResults.close();

        	return myUser;
	}

        /**
	 * Gets the User object for this user_name
	 * @param user_name the user_name of the user
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a User object
	 */
	public User getUser(String user_name, DataSource pool) throws SQLException {
	
		//log.debug("in getUser as a User object passing in user_name");

		int user_id = getUser_id(user_name, pool);

        	User myUser = getUser(user_id, pool);

        	return myUser;
	}
        
	/**
	 * Gets the User object for this user_name
	 * @param user_name the user_name of the user
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a User object
	 */
	public User getUser(String user_name, Connection conn) throws SQLException {
	
		//log.debug("in getUser as a User object passing in user_name");

		int user_id = getUser_id(user_name, conn);

        	User myUser = getUser(user_id, conn);

        	return myUser;
	}

	/**
	 * Gets the user_id for this user_name
	 * @param user_name the user_name of the user
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the user_id
	 */
	public int getUser_id(String user_name, Connection conn) throws SQLException {

		log.debug("in getUser_id from user_name");

		String query = 
			"select user_id "+
			"from users "+
			"where user_name = ?";

		log.debug("query = " + query);

                Results myResults = new Results(query, user_name, conn);

                int user_id = myResults.getIntValueFromFirstRow();
                log.debug(" user id="+user_id);
		myResults.close();

    		return user_id;
	}
        
        public int getUser_id(String user_name, DataSource pool) throws SQLException {

                log.debug("in getUser_id from user_name");

		String query = 
			"select user_id "+
			"from users "+
			"where user_name = ?";

		log.debug("query = " + query);
                Connection conn=pool.getConnection();
                log.debug("got connection");
                Results myResults = new Results(query, user_name, conn);
                int user_id = myResults.getIntValueFromFirstRow();
                log.debug("user_id="+user_id);
		myResults.close();
                log.debug("close myresults");
                conn.close();
                log.debug("close");
                
    		return user_id;
	}

	/**
	 * Gets the user's password.
	 * @param email	the user's email address
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the user's password
	 */
	 public String getUserPassword(String email, DataSource pool) throws SQLException {
        	log.debug("in getUserPassword");

        	String query =
                	"select u.password "+
                	"from users u "+
                	"where upper(u.email) = ?";
                Connection conn=pool.getConnection();
		Results myResults = new Results(query, email.toUpperCase(), conn);

		String[] dataRow;
		String password = "";
		while ((dataRow = myResults.getNextRow()) != null) {
			password = dataRow[0];
		}
		myResults.close();
                try{
                    conn.close();
                }catch(Exception e){}
        	return password;
	}

	/**
	 * Gets the user's password.
	 * @param first_name	the user's first name
	 * @param last_name	the user's last name
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	an array containing the user's password in [0] and the email in [1]
	 */
	 public String[] getUserPassword(String first_name, String last_name, DataSource pool) throws SQLException {
        	log.debug("in getUserPassword passing in first and last name");

        	String query =
                	"select u.password, u.email "+
                	"from users u "+
                	"where upper(u.first_name) = ? "+
                	"and upper(u.last_name) = ?";
                Connection conn=pool.getConnection();
		Results myResults = 
			new Results(query, first_name.toUpperCase(), last_name.toUpperCase(), conn);

		String[] dataRow;
		String[] values = null;
		while ((dataRow = myResults.getNextRow()) != null) {
			values = new String[2];
			values[0] = dataRow[0];
			values[1] = dataRow[1];
		}
		myResults.close();
                try{
                    conn.close();
                }catch(Exception e){}
        	return values;
	}

         
        /**
	 * Checks to see if a user with the same user_name or first and last name already exists.
	 * @param myUser	the User object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the user_id of a user that currently exists
	 */
	   public int checkUserExists(User myUser, DataSource pool) throws SQLException {
                log.debug("in checkUserExists");

                String query =
                        "select user_id "
                        + "from users "
                        + "where (user_name = ? "
                        + "or (first_name = ? and last_name = ?))";
                Connection conn=pool.getConnection();
                Results myResults = new Results(query, new Object[]{myUser.getUser_name(), myUser.getFirst_name(), myUser.getLast_name()}, conn);

                int user_id = myResults.getIntValueFromFirstRow();

                user_id = (user_id == -99 ? -1 : user_id);

                myResults.close();
                try{
                    conn.close();
                }
                catch(Exception e){}
                return user_id;
            }
         
	/**
	 * Checks to see if a user with the same user_name or first and last name already exists.
	 * @param myUser	the User object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the user_id of a user that currently exists
	 */
	   public int checkUserExists(User myUser, Connection conn) throws SQLException {
                log.debug("in checkUserExists");

                String query =
                        "select user_id "
                        + "from users "
                        + "where (user_name = ? "
                        + "or (first_name = ? and last_name = ?))";

                Results myResults = new Results(query, new Object[]{myUser.getUser_name(), myUser.getFirst_name(), myUser.getLast_name()}, conn);

                int user_id = myResults.getIntValueFromFirstRow();

                user_id = (user_id == -99 ? -1 : user_id);

                myResults.close();

                return user_id;
            }

    /**
     * Gets the User object for this user_name and password combination
     * @param user_name the user_name for the user
     * @param password the password for the user
     * @param conn	the database connection
     * @throws            SQLException if an error occurs while accessing the database
     * @return	a User object
     */
    public User getUser(String user_name, String password, DataSource pool) throws SQLException {

        log.debug("in getUser passing in user_name and pwd");

        User thisUser = new User();

        String query =
                "select user_id, title, first_name, last_name, "
                + "lab_name, email, user_name "
                + "from users "
                + "where user_name = ? "
                + "and password = ? "
                + "and approved = 'Y'";
        Connection conn=pool.getConnection();
        Results myResults = new Results(query, new Object[]{user_name, password}, conn);

        int user_id = myResults.getIntValueFromFirstRow();

        myResults.close();

        user_id = (user_id == -99 ? -1 : user_id);

        if (user_id != -1) {
            thisUser.setUser_id(user_id);
            log.debug("user exists.  user_id = " + user_id);
            thisUser = getUser(user_id, conn);
        } else {
            log.debug("user does not exist.");
            thisUser.setUser_id(user_id);
        }
        try{
            conn.close();
        }catch(Exception e){}
        return thisUser;
    }

    public int createUser(User myUser, DataSource pool) throws SQLException {
        user_id=-1;
        if (myUser.getFirst_name().equals(myUser.getLast_name())) {
            log.debug("**************************CREATE USER CALLED WITH SAME FIRST AND LAST NAME"+myUser.toFullString());
        } else {
            Connection conn=pool.getConnection();
            user_id = myDbUtils.getUniqueID("users_seq", conn);
            
            try{
                conn.close();
            }catch(Exception e){}
            
            String query =
                    "insert into users "
                    + "(user_id, title, first_name, middle_name, last_name, "
                    + "user_name, password, email, telephone, fax, "
                    + "institution, lab_name, box, street, city, "
                    + "state, zip, country, create_date, pi_user_id, "
                    + "approved) values "
                    + "(?, ?, ?, ?, ?, "
                    + "?, ?, ?, ?, ?, "
                    + "?, ?, ?, ?, ?, "
                    + "?, ?, ?, ?, ?, "
                    + "'N')";


            PreparedStatement pstmt = null;

            try {

                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
                conn=pool.getConnection();
                pstmt = conn.prepareStatement(query,
                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                        ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, user_id);
                pstmt.setString(2, myUser.getTitle());
                pstmt.setString(3, myUser.getFirst_name());
                pstmt.setString(4, myUser.getMiddle_name());
                pstmt.setString(5, myUser.getLast_name());
                pstmt.setString(6, myUser.getUser_name());
                pstmt.setString(7, myUser.getPassword());
                pstmt.setString(8, myUser.getEmail());
                pstmt.setString(9, myUser.getTelephone());
                pstmt.setString(10, myUser.getFax());
                pstmt.setString(11, myUser.getInstitution());
                pstmt.setString(12, myUser.getLab_name());
                pstmt.setString(13, myUser.getBox());
                pstmt.setString(14, myUser.getStreet());
                pstmt.setString(15, myUser.getCity());
                pstmt.setString(16, myUser.getState());
                pstmt.setString(17, myUser.getZip());
                pstmt.setString(18, myUser.getCountry());
                // This is the create_date
                pstmt.setTimestamp(19, now);
                log.debug("pi_user_id = " + myUser.getPi_user_id());
                if (myUser.getPi_user_id() == -99) {
                    pstmt.setInt(20, user_id);
                } else {
                    pstmt.setInt(20, myUser.getPi_user_id());
                }

                pstmt.executeUpdate();
                pstmt.close();

                myUser.setUser_id(user_id);
                try{
                    conn.close();
                }catch(Exception e){}
            } catch (SQLException e) {
                log.error("In exception of createUser", e);
                throw e;
            }
        }
  	return user_id;
  }


	/**
	 * Creates a record in the TSUBMTR table 
	 * @param myUser the User object containing the information 
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */
	public void createTSUBMTR (User myUser, DataSource pool) throws SQLException {

		// The record created in the TSUBMTR table defaults the country 
		// code to 275, which is the code for USA.

        	String query =
                	"insert into TSUBMTR "+
                	"(tsubmtr_login, tsubmtr_password, tsubmtr_fname, "+
			"tsubmtr_middle, tsubmtr_lname, tsubmtr_institution, "+
                	"tsubmtr_dep, tsubmtr_address, tsubmtr_stateprov, "+
                	"tsubmtr_zip, tsubmtr_city, tsubmtr_tel, "+
			"tsubmtr_fax, tsubmtr_email, tsubmtr_last_login, "+
			"tsubmtr_last_change, "+
			"tsubmtr_country, tsubmtr_del_status, tsubmtr_role, tsubmtr_user) "+ 
			"values "+
                	"(?, ?, ?, "+
                	"?, ?, ?, "+
                	"?, ?, ?, "+
                	"?, ?, ?, "+
                	"?, ?, ?, "+
                	"?, "+
			"275, 'U', 'N', 'DBMAN@phenogen.ucdenver.edu')";


		log.debug("createTSUBMTR.query = "+query);

                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
                Connection conn=pool.getConnection();
        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
                pstmt.setString(1, myUser.getUser_name());
                pstmt.setString(2, myUser.getPassword());
                pstmt.setString(3, myUser.getFirst_name());
                pstmt.setString(4, myUser.getMiddle_name());
                pstmt.setString(5, myUser.getLast_name());
                pstmt.setString(6, myUser.getInstitution());
                pstmt.setString(7, myDbUtils.setToNoneIfNull(myUser.getLab_name()));
                pstmt.setString(8, myDbUtils.setToNoneIfNull(myUser.getStreet()));
                pstmt.setString(9, myDbUtils.setToNoneIfNull(myUser.getState()));
                pstmt.setString(10, myDbUtils.setToNoneIfNull(myUser.getZip()));
                pstmt.setString(11, myDbUtils.setToNoneIfNull(myUser.getCity()));
                pstmt.setString(12, myDbUtils.setToNoneIfNull(myUser.getTelephone()));
                pstmt.setString(13, myUser.getFax());
                pstmt.setString(14, myUser.getEmail());
                pstmt.setTimestamp(15, now);
                pstmt.setTimestamp(16, now);

                pstmt.executeUpdate();
                try{
                conn.close();
                }catch(Exception e){}
  	}

	/**
 	 * Creates one or more records in the user_chips table.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */
	public void createUser_chips(Connection conn) throws SQLException {

        	log.info("in createUser_chips. user_id = "+this.getUser_id());

		int user_chip_id = -99;
 
		String query =
                  	"insert into user_chips "+
                  	"(user_chip_id, user_id, hybrid_id, owner_user_id, request_date, approved) "+
                  	"values "+
                  	"(?, ?, ?, ?, ?, ?)";
 
		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query,
                                        	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                        	ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(2, this.getUser_id());
                pstmt.setTimestamp(5, now);
                pstmt.setInt(6, 0);
		//
		// For each of the chips for which the user requested access, 
		// create a record in the user_chips table.
		//
		if (this.getUser_chips() != null) {
			log.debug("getUser_chips().size = "+this.getUser_chips().size());
	                Iterator idIterator  = this.getUser_chips().keySet().iterator();
			while (idIterator.hasNext()) {
				user_chip_id = myDbUtils.getUniqueID("user_chips_seq", conn);
                        	String hybridIDString = (String) idIterator.next();
                        	int hybridID = Integer.parseInt(hybridIDString);
				int ownerUserID = Integer.parseInt((String) this.getUser_chips().get(hybridIDString)); 

                        	pstmt.setInt(1, user_chip_id);
                        	pstmt.setInt(3, hybridID);
                        	pstmt.setInt(4, ownerUserID);
				try {
                        		pstmt.executeUpdate();
				} catch (SQLException e) {
					// Get ORA-0001 -- chip already exists
					if (e.getErrorCode() == 1) {
                				log.error("Got a SQLException while in createUser_chips for user_chip_id = " + 
							user_chip_id + ", and user = "+this.getUser_id());
					} else {
						log.debug("Error code = "+e.getErrorCode());
                				throw e;
					}
				}
			}
		} else {
			log.debug("getUser_chips() is null");
		}
		pstmt.close();
	}

  public String[] getUserChipsForUserStatements(String typeOfQuery) {

        String[] query = new String[1];

        String selectClause = myDbUtils.getSelectClause(typeOfQuery);
        String rownumClause = myDbUtils.getRownumClause(typeOfQuery);

        query[0] =
                selectClause +
                "from user_chips "+
                "where user_id = ?"+
                rownumClause;
	return query;
  }

  public List<List<String[]>> getUserChipsForUser(int userID, Connection conn) throws SQLException {

        log.debug("in getUserChipsForUser");
        String[] query = getUserChipsForUserStatements("SELECT10");

        List<List<String[]>> allResults = null;

        try {
                allResults = new Results().getAllResults(query, userID, conn);

        } catch (SQLException e) {
                log.error("In exception of getUserChipsForUser", e);
                throw e;
        }
        log.debug("returning allResults for getUserChipsForUser.length = "+allResults.size());
        return allResults;

  }



  public void deleteUserChipsForUser(int userID, Connection conn) throws SQLException {
 
	log.debug("in deleteUserChipsForUser");
        String[] query = getUserChipsForUserStatements("DELETE");

        PreparedStatement pstmt = null;
 
        try {
                for (int i=0; i<query.length; i++) {
                        pstmt = conn.prepareStatement(query[i],
                                	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                	ResultSet.CONCUR_UPDATABLE);
                	pstmt.setInt(1, userID);
 
                	pstmt.executeUpdate();
                	pstmt.close();
		}
 
        } catch (SQLException e) {
                log.error("In exception of deleteUserChipsForUser", e);
                throw e;
        }
  }

	/**
	 * Get the owners for the set of unapproved arrays in this dummy dataset
	 * @param hybridIDs	the list of hybridIDs
	 * @param conn      the database connection 
	 * @throws            Exception if an error occurs in sending email
	 * @return	an array of owner IDs
	 */
	public int[] getChipsNeedingPermission(String hybridIDs, Connection conn) throws SQLException {

		log.info("in getChipsNeedingPermission");
		log.debug("hybridIDs = "+hybridIDs); 

        	String query =
			"select distinct owner_user_id "+
			"from user_chips uc "+
			"where uc.approved = 0 "+
			"and uc.user_id = ? "+
			"and uc.hybrid_id in "+
			hybridIDs +
			" order by uc.owner_user_id";

		log.debug("query = "+query);
		Results myResults = new Results(query, this.getUser_id(), conn);

		int[] owners = new ObjectHandler().getResultsAsIntArray(myResults, 0); 
		myResults.close();
        	return owners; 
	}

	/**
	 * Get the hybridIDs requested by this user for this owner
	 * @param user_id	the identifier of the user
	 * @param owner_id	the identifier of the owner
	 * @param conn      the database connection 
	 * @throws            Exception if an error occurs in sending email
	 * @return            a comma-delimited string of hybrid_ids
	 */
	public String getUserArraysForThisOwner(int user_id, int owner_id, Connection conn) throws SQLException {

		log.info("in getUserArraysForThisOwner");
		log.debug("user_id = "+user_id + ", owner_id = "+owner_id);

        	String query =
			"select uc.hybrid_id "+
			"from user_chips uc "+
			"where uc.approved = 0 "+
			"and uc.user_id = ? "+
			"and uc.owner_user_id = ? "+
			"order by uc.hybrid_id";

		//log.debug("query = "+query);
		Results myResults = new Results(query, new Object[] {user_id, owner_id}, conn);

		String arrayList = new ObjectHandler().getResultsAsSeparatedString(myResults, ",", "'", 0); 
		myResults.close();
        	return arrayList; 
	}

	/**
	 * Get the hybridIDs owned by this user.
	 * @param user_id the id of the user
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a comma-separated string of hybrid ids
	 */
	public String getMyArrays(int user_id, Connection conn) throws SQLException {

		log.info("in getMyArrays");

        	String query =
			"select uc.hybrid_id "+
			"from user_chips uc "+
			"where uc.approved = 1 "+
			"and uc.user_id = ? "+
			"order by uc.hybrid_id";

		//log.debug("query = "+query);

        	Results myResults = new Results(query, user_id, conn);
		//log.debug("number of Arrays = "+myResults.getNumRows());
		String hybridIDs = "(" +
                        	(myResults.getNumRows() == 0 ? "" :
					new ObjectHandler().getResultsAsSeparatedString(myResults, ",", "", 0)) +
                        	")";

		myResults.close();
        	return hybridIDs;
	}

	/**
	 * Get the hybridIDs and all the userIDs associated with each  hybrid ID for 
	 * all of the requested arrays owned by this PI.
	 * @param owner_id	the id of the owner
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	a Results object
	 */
	public Results getPendingRequests(int owner_id, Connection conn) throws SQLException {

		log.info("in getPendingRequests");

        	String query =
			"select distinct uc.hybrid_id, "+
			"uc.user_id "+
			"from user_chips uc, users u "+
			"where uc.approved = 0 "+
			"and uc.user_id = u.user_id "+
			"and uc.owner_user_id = ? "+
			"order by uc.hybrid_id, 2";

		//log.debug("query = "+query);
        	Results myResults = new Results(query, owner_id, conn);

        	return myResults;
	}

  public void updateUser (User myUser, Connection conn) throws SQLException {

        String query =
                "update users "+
                "set title = ?, first_name = ?, middle_name = ?, " +
                "last_name = ?, user_name = ?, password = ?, " +
                "email = ?, telephone = ?, fax = ?, " +
                "institution = ?, lab_name = ?, box = ?, " +
                "street = ?, city = ?, state = ?, " +
                "zip = ?, country = ?, pi_user_id = ?, last_updated_date = ? " +
                "where user_id = ?";

        PreparedStatement pstmt = null;

        try {
                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

                pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
                pstmt.setString(1, myUser.getTitle());
                pstmt.setString(2, myUser.getFirst_name());
                pstmt.setString(3, myUser.getMiddle_name());
                pstmt.setString(4, myUser.getLast_name());
                pstmt.setString(5, myUser.getUser_name());
                pstmt.setString(6, myUser.getPassword());
                pstmt.setString(7, myUser.getEmail());
                pstmt.setString(8, myUser.getTelephone());
                pstmt.setString(9, myUser.getFax());
                pstmt.setString(10, myUser.getInstitution());
                pstmt.setString(11, myUser.getLab_name());
                pstmt.setString(12, myUser.getBox());
                pstmt.setString(13, myUser.getStreet());
                pstmt.setString(14, myUser.getCity());
                pstmt.setString(15, myUser.getState());
                pstmt.setString(16, myUser.getZip());
                pstmt.setString(17, myUser.getCountry());
                pstmt.setInt(18, myUser.getPi_user_id());
                // Column 19 is the last_updated_date
                pstmt.setTimestamp(19, now);
                pstmt.setInt(20, myUser.getUser_id());

                pstmt.executeUpdate();

        } catch (SQLException e) {
		log.error("In exception of updateUser", e);
		throw e;
        }
  }
  
  public List getUserData (User userToDelete, Connection conn) throws SQLException {
  	
	log.info("in getUserData");
	//
	// prior to calling this method, userToDelete.setUserMainDir() must be called to set the 
	// directory to delete
	//
	int userID = userToDelete.getUser_id();
	String userMainDir = userToDelete.getUserMainDir();

	//
	// allResults is a List of Lists of String[] (i.e., each query returns
	// a List of String[]), and allResults contains multiple queries
	// the Dataset and GeneList queries only return a List of String[], so 
	// they need to be wrapped in another List in order to be added to allResults
	//
	List<List<String[]>> allResults = new SessionHandler().getSessionsForUser(userID, conn);
	allResults.addAll(new LitSearch().getAllLitSearchesForUser(userID, conn));
	allResults.addAll(new Promoter().getAllPromoterResultsForUser(userID, conn));
	//
	// Get those gene lists that the user has access to
	//
	allResults.addAll(new GeneList().getUserGeneListsForUser(userID, conn));
	allResults.addAll(getUserChipsForUser(userID, conn));

	//
	// Get those datasets the user has access to
	// This part needs to be written
	//

	//pstmt = new GeneList().getGeneLists(userID, conn);
	//allResults.add(new ObjectHandler().getResultsAsListOfStringArrays(new Results(pstmt)));
	//pstmt.close();
/*

	String userExperimentsDir = userToDelete.getUserMainDir() + "/Experiments";
	String geneListsDir = userToDelete.getUserMainDir() + "/GeneLists";
	String[] dsfiles = (new File(userExperimentsDir)).list();
	log.debug("dsfiles.len = "+dsfiles.length);
	String[] tenFiles = new String[Math.min(dsfiles.length,10)];
	for (int i=0; i<Math.min(dsfiles.length, 10); i++) {
		tenFiles[i] = dsfiles[i];
	}
	List filesList = new ArrayList();
	filesList.add(tenFiles);

	String[] glfiles = (new File(geneListsDir)).list();
	log.debug("glfiles.len = "+glfiles.length);
	tenFiles = new String[Math.min(glfiles.length,10)];
	for (int i=0; i<Math.min(glfiles.length, 10); i++) {
		tenFiles[i] = glfiles[i];
	}
	filesList.add(tenFiles);
	allResults.addAll(filesList);
*/
	return allResults;

  }
        
  public void deleteUser (User userToDelete, Connection conn) throws SQLException, Exception {
  	
	log.info("in deleteUser");
	//
	// prior to calling this method, userToDelete.setUserMainDir() must be called to set the 
	// directory to delete
	//
	conn.setAutoCommit(false);
	int userID = userToDelete.getUser_id();
	String userMainDir = userToDelete.getUserMainDir();

	new SessionHandler().deleteSessionsForUser(userID, conn);
	new LitSearch().deleteAllLitSearchesForUser(userID, conn);
	new Promoter().deleteAllPromoterResultsForUser(userID, conn);
	new GeneList().deleteUserGeneListsForUser(userID, conn);

	PreparedStatement pstmt = null;
        try {
		String getDatasets = 
			"select dataset_id from datasets " +
			"where created_by_user_id = ?";

		pstmt = conn.prepareStatement(getDatasets, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, userID);

		ResultSet rs = pstmt.executeQuery();

                while (rs.next()) {
                        int dataset_id = rs.getInt(1);
			log.debug("dataset_id uploaded by this user = "+dataset_id);
			Dataset datasetToDelete = new Dataset().getDataset(dataset_id, userToDelete, conn,this.getUserMainDir());
			datasetToDelete.deleteDataset(userID,conn);
                }
                pstmt.close();

		String getUsersGeneLists = 
			"select gene_list_id from gene_lists " +
			"where created_by_user_id = ?";

		pstmt = conn.prepareStatement(getUsersGeneLists, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, userID);

		rs = pstmt.executeQuery();

                while (rs.next()) {
                        int geneListID = rs.getInt(1);
			log.debug("geneListID created by this user = "+geneListID);
			new GeneList().deleteGeneList(geneListID, conn);
                }
                pstmt.close();

		deleteUserChipsForUser(userID, conn);

		String[] query = new String[4];

  		query[0] =
			"delete from roles " +
			"where user_id = ?";

  		query[1] =
			"delete from group_subjects " +
			"where group_id in (select group_id from isbra_groups where created_by_user_id = ?)";
	
		query[2] = 
			"delete from isbra_groups " +
			"where created_by_user_id = ?";

  		query[3] =
			"delete from users " +
			"where user_id = ?";

                for (int i=0; i<query.length; i++) {
                        log.debug("i = " + i + ", query = " + query[i]);
                        pstmt = conn.prepareStatement(query[i],
                            		ResultSet.TYPE_SCROLL_INSENSITIVE,
                            		ResultSet.CONCUR_UPDATABLE);
                        pstmt.setInt(1, userID);

                        pstmt.executeUpdate();
                        pstmt.close();
                }
		conn.commit();
	} catch (Exception e) {
		log.debug("error in deleteUser");
		conn.rollback();
		throw e;
	}
	conn.setAutoCommit(true);

	log.debug("now deleting the user's directory.  Planning to delete everything in " + userToDelete.getUserMainDir());
        new FileHandler().deleteAllFilesPlusDirectory(new File(userToDelete.getUserMainDir()));

  }
        
  /**
   * Sends an email to notify the user when array access has either been granted or denied.
   * @param mainURL	the website URL        
   * @param arraysList        a List of Array objects for which notification was requested 
   * @throws            Exception if an error occurs in sending email
   */

  public void sendAccessNotification(String mainURL, List arraysList) throws Exception {

	log.info("in User.sendAccessNotification");

	Email myEmail = new Email();

	String content = this.getFormal_name() + ",\n\n";
	log.debug("content here = " + content);
	String approvedArrayList = "";
	String deniedArrayList = "";

	for (int i=0; i<arraysList.size(); i++) {
		if (((Array) arraysList.get(i)).getAccess_approval() == 1) {
			approvedArrayList = approvedArrayList + "\n" + ((Array) arraysList.get(i)).getHybrid_name(); 
		} else {
			deniedArrayList = deniedArrayList + "\n" + ((Array) arraysList.get(i)).getHybrid_name(); 
		}
	}

	if (!approvedArrayList.equals("")) {
		content = content + "You have been granted access to the following " +
	        "arrays on the PhenoGen Informatics website: "; 

		content = content + approvedArrayList + "\n" + 
				"If you have been granted access to all the arrays in a dataset, you will now "+
				"be able to run the quality control checks on your dataset.  Logon to "+mainURL +
				" to proceed. ";
	} 
	if (!deniedArrayList.equals("")) {
		content = content + "\n" + "You have been denied access to the following " +
	        "arrays on the PhenoGen Informatics website: "; 

		content = content + deniedArrayList + "\n";
	}

	log.debug("content now = " + content);

	myEmail.setTo(this.getEmail());
        myEmail.setSubject("Access Notification for PhenoGen Array(s)");
        myEmail.setContent(content);

	try {
		log.debug("sending message to requestor");
                myEmail.sendEmail();
	}
        catch(Exception e) {
		log.error("In exception of sendAccessNotification", e);
		throw e;
        }
  }

	/**
	 * Sends an email to the owner(s) of the arrays for which access is being requested.
	 * @param hybridIDs	the list of hybrid IDs in this dataset
	 * @param mainURL	the website URL        
	 * @param dbConn      the Connection to the PhenoGen database 
         * @return            whether access was required
	 * @throws            Exception if an error occurs in sending email
	 */
	public boolean sendAccessRequest(String hybridIDs, String mainURL, Connection dbConn) throws Exception {

		log.info("in User.sendAccessRequest");

		Email myEmail = new Email();
		boolean accessRequired = false;

		String userInformation = this.getUserInfoAsString(dbConn);

		int[] ownerIDs = this.getChipsNeedingPermission(hybridIDs, dbConn);

		log.debug("ownerIDs = "); new Debugger().print(ownerIDs);
		if (ownerIDs != null && ownerIDs.length > 0) {
			accessRequired = true;

                	for (int i=0; i<ownerIDs.length; i++) {
				User owner = getUser(ownerIDs[i], dbConn);
				log.debug("thisOwner = " + ownerIDs[i] + ", " +owner.getLast_name());
				String thisOwnersHybridIDs = 
					"(" +
					getUserArraysForThisOwner(this.getUser_id(), ownerIDs[i], dbConn) + 
					")";

				log.debug("ThisOwnersHybridIDS = "+thisOwnersHybridIDs);
				String arrayInformation = new Array().getArrayInfoAsString(thisOwnersHybridIDs, dbConn);
				myEmail.setTo(owner.getEmail());
	        		myEmail.setSubject("Access Request for your Array(s)");
        			myEmail.setContent(owner.getTitle() + owner.getLast_name() + ",\n\n" +
					userInformation  +
	        			" has requested access to the following arrays for " +
					"which you are the principal investigator:  \r\n\r\n"+
					arrayInformation + 
        				".\r\n\r\nYou may go to " + mainURL +
        				" and select 'Approve Array Requests' from the "+
					"Principal Investigator menu to approve this access.");

				log.debug("sending message to dataset owner");
                		myEmail.sendEmail();
                	}
		}
		return accessRequired;
	}

	/**
	 * Sends an email to an approver notifying him/her of a registration request for the website. 
	 * @param approver      the User object of the person who will approve this registration
	 * @param mainURL	the website URL        
	 * @param conn      the connection to the database
	 * @throws            Exception if an error occurs in sending email
	 */
	 public void sendRegistrationRequest(User approver, String mainURL, Connection conn) throws Exception {

		log.info("in User.sendRegistrationRequest");

		Email myEmail = new Email();

		try {
			String userInformation = this.getUserInfoAsString(conn);
		
			myEmail.setTo(approver.getEmail());
	        	myEmail.setSubject("Registration Request for the PhenoGen Informatics website");
        		myEmail.setContent(approver.getFormal_name() + ",\n\n" +
				userInformation  +
	        		" has completed the registration form and is requesting access to the " +
				"PhenoGen website.  "+
        			"\r\n\r\nYou may go to " + mainURL +
        			" and select 'Approve Registration' from the "+
				"Administrator menu to approve or deny this person access to the site.");

			log.debug("sending message to website administrator/principal investigator");
                	myEmail.sendEmail();
		} catch(Exception e) {
			log.error("In exception of sendRegistrationRequest", e);
			throw e;
        	}
	}

	
	/**
	 * Updates the user's record to indicate whether he/she has been granted access to the website.  
	 * Also sends an email to the user notifying him/her of his/her access status. 
	 * @param requestor      the User object of the person who requested access to the website
	 * @param approval     whether the user has been approved or not 
	 * @param mainURL	the website URL        
	 * @param conn      the connection to the database
	 * @throws            Exception if an error occurs updating the database or sending email
	 */
	 public void updateRegistrationApproval(User requestor, boolean approval, String mainURL, DataSource pool) throws Exception {

	Email myEmail = new Email();
	log.debug("requestor is:"); print(requestor);

	String contentMsg = "";
	String approvalMsg = requestor.getFormal_name() + ", \n\n" +
				"You have been granted access to the PhenoGen Informatics website.  \r\n\r\nYou can access "+
				"the site at the link below and login using the username and password "+
				"you selected during registration. \r\n\r\n"+
				"For best results, your computer should meet or exceed the following hardware "+
				"requirements: \r\n\r\n "+
				"3.0 Ghz CPU \r\n" +
				"1 Gb RAM";
	String denialMsg = requestor.getFormal_name() + ", \n\n" +
				"You have been denied access to the PhenoGen Informatics website.  \r\n\r\nFor more information "+
				"regarding obtaining access to the site, please contact the website administrator(s) "+
				"using the contact information on the main page of the website. \r\n\r\n";

	if (approval) {
		String query = 
			"update users "+
                        "set approved = 'Y' "+
                        "where user_id = ?";
		//log.debug("query = " + query);
                Connection conn=pool.getConnection();
	        PreparedStatement pstmt = conn.prepareStatement(query,
                                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                                        ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, requestor.getUser_id());
		pstmt.executeUpdate();
                try{
                    conn.close();
                }catch(Exception e){}
		contentMsg = approvalMsg;
	}
  }

  public void updateArrayApproval (List arraysList, Connection conn) throws SQLException {

	log.info ("in updateArrayApproval. user_id = "+this.getUser_id());
	String approvedHybridIDList = "("; 
	String deniedHybridIDList = "("; 
	log.debug("arraysList.size = "+ arraysList.size());
	boolean previousApprovalExists = false;
	boolean previousDenialExists = false;

	if (((Array) arraysList.get(0)).getAccess_approval() == 1) {
		approvedHybridIDList = approvedHybridIDList +
			((Array) arraysList.get(0)).getHybrid_id(); 
		previousApprovalExists = true;
	} else if (((Array) arraysList.get(0)).getAccess_approval() == -1) {
		deniedHybridIDList = deniedHybridIDList +
			((Array) arraysList.get(0)).getHybrid_id(); 
		previousDenialExists = true;
	}

	for (int i=1; i<arraysList.size(); i++) {
		if (((Array) arraysList.get(i)).getAccess_approval() == 1) {
			if (previousApprovalExists) {
				approvedHybridIDList = approvedHybridIDList +
				 	"," + ((Array) arraysList.get(i)).getHybrid_id(); 
			} else {
				approvedHybridIDList = approvedHybridIDList +
				 	((Array) arraysList.get(i)).getHybrid_id(); 
				previousApprovalExists = true;
			}
		} else if (((Array) arraysList.get(i)).getAccess_approval() == -1) {
			if (previousDenialExists) {
				deniedHybridIDList = deniedHybridIDList +
					 "," + ((Array) arraysList.get(i)).getHybrid_id(); 
			} else {
				deniedHybridIDList = deniedHybridIDList +
				 ((Array) arraysList.get(i)).getHybrid_id(); 
				previousDenialExists = true;
			}
		}
	}
	approvedHybridIDList = approvedHybridIDList + ")";
	log.debug("approvedHybridIDList = " + approvedHybridIDList);

	deniedHybridIDList = deniedHybridIDList + ")";
	log.debug("deniedHybridIDList = " + deniedHybridIDList);

	if (!approvedHybridIDList.equals("()")) {
		String query = 
			"update user_chips "+
			"set approved = 1, "+
			"approved_date = ? "+
			"where user_id = ? "+
			"and hybrid_id in "+
			approvedHybridIDList;

		log.debug("in updateArrayApproval for approvals. ");
		//log.debug("query = " + query);

  		PreparedStatement pstmt = conn.prepareStatement(query, 
			ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_UPDATABLE);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		pstmt.setTimestamp(1, now);
		pstmt.setInt(2, this.getUser_id());	
		pstmt.executeUpdate();

		// Update the user's 'Pending' datasets if there are no more unapproved arrays
		query = 
			"update datasets set name = "+
			"        substr(name, 0, instr(name, '(Pending)') -2) "+
			"where created_by_user_id = ? "+
			" and dataset_id in  "+
			"(select distinct ds.dataset_id "+
			"from datasets ds "+
			"where ds.name like '%(Pending)%' "+
			"minus "+
			"select distinct ds.dataset_id "+
			"from datasets ds, dataset_chips dc, user_chips uc "+
			"where dc.user_chip_id = uc.user_chip_id "+
			"and dc.dataset_id = ds.dataset_id "+
			"and ds.name like '%(Pending)%' "+
			"and exists "+ 
			"        (select 'x' "+
			"        from dataset_chips dc, user_chips uc "+
			"        where dc.user_chip_id = uc.user_chip_id "+
			"        and dc.dataset_id = ds.dataset_id "+
			"        and uc.approved = 0)  "+
			")";

		//log.debug("query = " + query);

  		pstmt = conn.prepareStatement(query, 
			ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, this.getUser_id());	
		pstmt.executeUpdate();

		pstmt.close();
	}
	if (!deniedHybridIDList.equals("()")) {
		String query = 
			"update user_chips "+
			"set approved = -1, "+
			"approved_date = ? "+
			"where user_id = ? "+
			"and hybrid_id in "+
			deniedHybridIDList;

		log.debug("in updateArrayApproval for denials. ");
		//log.debug("query = " + query);
  		PreparedStatement pstmt = null;

		try {
			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

			java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

			pstmt.setTimestamp(1, now);
			pstmt.setInt(2, this.getUser_id());	
			pstmt.executeUpdate();

		} catch (SQLException e) {
			log.error("in SQLException of updateArrayApproval for denials", e);
			throw e;
		}
		pstmt.close();
	}
  }

	private String sortColumn;

	public void setSortColumn(String inString) {
        	this.sortColumn = inString;
	}

	public String getSortColumn() {
        	return sortColumn;
	}

        /**
         * Sorts an array of Users by a particular column.
         * @param myUsers  an array of Users
         * @return            the array in sorted order
         */

	public User[] sortUsers (User[] myUsers, String sortColumn) {
        	setSortColumn(sortColumn);
        	Arrays.sort(myUsers, new UserSortComparator());
        	return myUsers;
	}

	/** Compares Users based on different fields.
	 *
	 */
	public class UserSortComparator implements Comparator <User>{
        	int compare;
        	User user1, user2;

        	public int compare(User object1, User object2) {
                	//log.debug("in UserSortComparator. ", sortColumn = "+getSortColumn());
                        user1 = object1;
                        user2 = object2;

                	if (getSortColumn().equals("lastName")) {
                        	compare = user1.getLast_name().compareTo(user2.getLast_name());
                	} else if (getSortColumn().equals("userName")) {
                        	compare = user1.getUser_name().compareTo(user2.getUser_name());
                	} else {
                        	compare = new Integer(user1.getUser_id()).compareTo(new Integer(user2.getUser_id()));
                	}
                	return compare;
        	}

  	}

	public boolean equals(Object obj) {
		if (!(obj instanceof User)) return false;
		return (this.user_id == ((User)obj).user_id);
	}
        
	public String toString() {
		return "This User has user_id = " + user_id +
		", Full_name = " + full_name +
		", email = " + email;
	}
        
        public String toFullString(){
            String full="userID:"+user_id+
                "\nName:"+title+" "+first_name+" "+middle_name+" "+last_name+
                    "\n "+full_name+"  "+formal_name+"\n UserName: "+user_name+
                    "\n "+password+ "\nemail:"+email+"\ntele:"+telephone+
                    " Fax:"+fax+"\n Inst:"+institution+"\n Lab Name:"+lab_name+
                    "\n"+box+street+city+state+zip+country;

            return full;
        }

	public void print() {
		log.debug(toString());
	}

	public void print(User myUser) {
		myUser.print();
	}


	 

	/**
	 * Gets the User that most closely matches the first and last name passed in. 
	 * @param piFirstName First name of the PI
	 * @param piLastName Last name of the PI
	 * @param conn Database connection
	 * @return User object that matches the first name and last name
	 * 
	 * 
	 * Used from the Registration page and PI pages to look up a user using first name and last name
	 * 
	 * @throws SQLException
	 */
	  public User getUserWithNameMatch(String piFirstName, String piLastName, Connection conn) throws SQLException{

	      int      userId = 0;	
	      User     user   = null;
			
          String query = 
				"select USER_ID "+ 
				"from users "+
				"where " +
				"UPPER(first_name) like '%"+piFirstName.toUpperCase()+"%' and UPPER(last_name) like '%"+piLastName.toUpperCase()+"%'";
		
		  Results myResults = null;
			
		  myResults = new Results(query, conn);					
		
		  userId = myResults.getIntValueFromFirstRow();				
			
		  myResults.close();
		  
		  if (userId > 0) {
			  user = getUser(userId, conn);
		  }
		  
		  return user;
	  }	 
		 
		 
	  
      /**
      * Gets the number of users that matches the first and last name passed in. 
      * @param piFirstName First name of the PI
      * @param piLastName Last name of the PI
      * @param conn Database connection
      * @return long number of users
      * 
      * 
      * Used from the Registration page and PI pages to look up a user using first name and last name
      * 
      * @throws SQLException
      */	  
	  public long getNumberOfUsersWithNameMatch(String piFirstName, String piLastName, Connection conn) throws SQLException{
		  long numberOfUsersFound = 0;
		  
          String query = 
				"select count(*) "+ 
				"from users "+
				"where " +
				"UPPER(first_name) like '%"+piFirstName.toUpperCase()+"%' and UPPER(last_name) like '%"+piLastName.toUpperCase()+"%'";
		
		  Results myResults = null;
			
		  myResults = new Results(query, conn);					
		
		  numberOfUsersFound = myResults.getIntValueFromFirstRow();				
			
		  myResults.close();
		  
		  return numberOfUsersFound;
	  }
		 

	
	
	/**
	 * Creates an array of UserChip objects and sets the data values to those retrieved from the database.
	 * @param myResults   the result set of data returned from the database
	 * @return            an array of UserChip objects
	 */
	public UserChip[] setupUserChipValues(Results myResults) {

                List<UserChip> userChipList = new ArrayList<UserChip>();
                //User enclosingUser = new User();

		String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        User.UserChip myUserChip = new UserChip();
                        myUserChip.setUser_chip_id(Integer.parseInt(dataRow[0]));
                        myUserChip.setHybrid_id(Integer.parseInt(dataRow[1]));
                        myUserChip.setOwner_user_id(Integer.parseInt(dataRow[2]));
			if (dataRow.length > 3) {
                        	myUserChip.setGroup(new Dataset().new Group(Integer.parseInt(dataRow[3])));
			}
                        userChipList.add(myUserChip);
                }
                User.UserChip[] myUserChips = (User.UserChip[]) userChipList.toArray(
                                                                new User.UserChip[userChipList.size()]);

		return myUserChips;
	}

	public class UserChip {
		private int user_chip_id;
		private int hybrid_id;
		private int owner_user_id;
		private int approved;
		private Dataset.Group group;
		private String hybrid_name;
	
		public UserChip() {
			log = Logger.getRootLogger();
		}

		public UserChip(int user_chip_id) {
			log = Logger.getRootLogger();
			this.user_chip_id = user_chip_id;
		}

		public void setUser_chip_id(int inInt) {
			user_chip_id = inInt;
		}

		public int getUser_chip_id() {
			return user_chip_id;
		}
	
		public void setHybrid_id(int inInt) {
			hybrid_id = inInt;
		}

		public int getHybrid_id() {
			return hybrid_id;
		}
	
		public void setOwner_user_id(int inInt) {
			owner_user_id = inInt;
		}

		public int getOwner_user_id() {
			return owner_user_id;
		}

		public void setApproved(int inInt) {
			approved = inInt;
		}

		public int getApproved() {
			return approved;
		}

		public void setGroup(Dataset.Group inGroup) {
			group = inGroup;
		}

		public Dataset.Group getGroup() {
			return group;
		}

		public void setHybrid_name(String inString) {
			hybrid_name = inString;
		}

		public String getHybrid_name() {
			return hybrid_name;
		}

  		public String toString() {
        		return ("This UserChip object has userChipID =" + " " + user_chip_id +
				" and hybrid_id = "+hybrid_id + 
				" and owner_user_id = "+owner_user_id + 
				" and group = " + group);
  		}

		public void print() {
			log.debug(toString());
		}

		public boolean equals(Object obj) {
        		if (!(obj instanceof UserChip)) return false;
			return (this.user_chip_id == ((UserChip)obj).user_chip_id);
		}
	
		public UserChip getUserChipFromMyUserChips(UserChip[] myUserChips, int hybrid_id) {
        		//
        		// Return the UserChip object that contains the hybrid_id from the myUserChips
        		//

        		myUserChips = sortUserChips(myUserChips, "hybrid_id");

			    UserChip chipToFind = new UserChip();
			    chipToFind.setHybrid_id(hybrid_id);

        		int hybridToFindIndex = Arrays.binarySearch(myUserChips, chipToFind, new UserChipSortComparator());
        		
        		
        		UserChip thisUserChip = myUserChips[hybridToFindIndex];

			
        		return thisUserChip;
		}

		/** Compares UserChips based on different fields.
	 	*
	 	*/
		public class UserChipSortComparator implements Comparator<UserChip> {
        		int compare;

        		public int compare(UserChip userChip1, UserChip userChip2) {
                		//log.debug("in UserChipSortComparator. ", sortColumn = "+getSortColumn());

                		if (getSortColumn().equals("user_chip_id")) {
                        		compare = new Integer(userChip1.getUser_chip_id()).compareTo(new Integer(userChip2.getUser_chip_id()));
                		} else if (getSortColumn().equals("hybrid_id")) {
                        		compare = new Integer(userChip1.getHybrid_id()).compareTo(new Integer(userChip2.getHybrid_id()));
                		}
                		return compare;
        		}

  		}

		private String sortColumn;

		public void setSortColumn(String inString) {
        		this.sortColumn = inString;
		}

		public String getSortColumn() {
        		return sortColumn;
		}

        	/**
         	* Sorts an array of UserChips by a particular column.
         	* @param myUserChips  an array of UserChips
         	* @param sortColumn  the column by which to sort.  Options are "user_chip_id" or "hybrid_id".
         	* @return            the array in sorted order
         	*/

		public UserChip[] sortUserChips (UserChip[] myUserChips, String sortColumn) {
        		setSortColumn(sortColumn);
        		Arrays.sort(myUserChips, new UserChipSortComparator());
        		return myUserChips;

		}

	}
}

