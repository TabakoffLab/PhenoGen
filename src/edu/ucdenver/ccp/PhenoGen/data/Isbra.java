package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.*;
import java.util.*;
import java.io.*;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;
import edu.ucdenver.ccp.PhenoGen.web.*; 
import edu.ucdenver.ccp.util.*;
import edu.ucdenver.ccp.util.sql.*;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling ISBRA data. 
 *  @author  Cheryl Hornbaker
 */
public class Isbra {
  	private int subject_id;
	private int center_id;
  	private int question_id;
  	private String answer;
  	private String[] dataRow;

  	private Logger log=null;

  	private DbUtils myDbUtils = new DbUtils();
	
  	PreparedStatement pstmt = null;

  	public Isbra () {
		log = Logger.getRootLogger();
  	}

  	public int getSubject_id() {
    		return subject_id; 
  	}

  	public void setSubject_id(int inInt) {
    		this.subject_id = inInt;
  	}

  	public int getCenter_id() {
    		return center_id; 
  	}

  	public void setCenter_id(int inInt) {
    		this.center_id = inInt;
  	}

  	public int getQuestion_id() {
    		return question_id; 
  	}

  	public void setQuestion_id(int inInt) {
    		this.question_id = inInt;
  	}

  	public String getAnswer() {
    		return answer; 
  	}

  	public void setAnswer(String inString) {
    		this.answer = inString;
  	}

  	/**
   	* Creates a record in the isbra_groups table.
   	* @param group_name	the name of the group
   	* @param userID	the ID of the group creator
   	* @param conn	the database connection
   	* @throws            SQLException if a database error occurs
   	*/

  	public int createIsbraGroup(String group_name, int userID, Connection conn) throws SQLException {
        	log.debug("in createIsbraGroup."); 

		int groupID = myDbUtils.getUniqueID("isbra_groups_seq", conn);

        	String query =
                	"insert into isbra_groups"+
                	"(group_id, created_by_user_id, group_name) "+
                	"values "+
                	"(?, ?, ?)";

		log.debug("query = "+query);
        	PreparedStatement pstmt = conn.prepareStatement(query,
                                        	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                        	ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, groupID);
        	pstmt.setInt(2, userID);
        	pstmt.setString(3, group_name);

        	pstmt.executeUpdate();
        	pstmt.close();
	
		return groupID;

  	}

  	/**
   	* Creates a record in the group_subjects table.
   	* @param subjectID	the ID of the subject
   	* @param groupID	the ID of the group
   	* @param conn	the database connection
   	* @throws            SQLException if a database error occurs
   	*/

  	public void createGroup_subjects(int subjectID, int groupID, Connection conn) throws SQLException {
        	log.debug("in createGroup_subjects. groupID = " +groupID + ", subjectID = "+subjectID); 

        	String query =
                	"insert into group_subjects "+
                	"(group_id, subject_id) "+
                	"values "+
                	"(?, ?)";

        	PreparedStatement pstmt = conn.prepareStatement(query,
                                        	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                        	ResultSet.CONCUR_UPDATABLE);
		pstmt.setInt(1, groupID);
        	pstmt.setInt(2, subjectID);

		try {
                        pstmt.executeUpdate();
		} catch (SQLException e) {
			if (e.getErrorCode() == 1) {
                		log.error("Got a duplicate record SQLException while in createGroup_subjects"); 
			} else {
				log.error("Error code = "+e.getErrorCode());
                		throw e;
			}
		}
        	pstmt.close();

  	}

  	/**
   	* Checks to see if the group name being created already exists.
   	* @param groupName	the name of the new group
   	* @param userID	the id of the user creating the group
   	* @param conn	the database connection
   	* @throws            SQLException if a database error occurs
   	* @return            true if a group by this name already exists, or false otherwise
   	*/
  	public boolean groupNameExists(String groupName, int userID, Connection conn) throws SQLException {

        	String query =
                	"select group_id "+
                	"from isbra_groups "+
                	"where group_name = ? "+
			"and created_by_user_id = ?";

		boolean alreadyExists = false;

        	Results myResults = new Results(query, groupName, userID, conn);

        	if (myResults.getNumRows() != 0) {
			alreadyExists = true;
		}
		myResults.close();

        	return alreadyExists;
  	}
	

  	/**
   	* Gets the list of valid values for an attribute.
   	* @param attribute	the identifier of the attribute
   	* @param conn	the database connection
   	* @throws            SQLException if a database error occurs
   	* @return            a LinkedHashMap containing the answer values
   	*/
	public LinkedHashMap getValidValues(int attribute, Connection conn) throws SQLException {
        	String query =
                	"select distinct value "+
			"from answers "+
			"where question_id = ? "+
			"and value is not null "+
			"order by value";

        	log.debug ("in Isbra.getValidValues");
        	log.debug("query = "+query);
        	Results myResults = new Results(query, attribute, conn);

		LinkedHashMap<String, String> hashMap = new LinkedHashMap<String, String>();
		String [] dataRow;
		while ((dataRow = myResults.getNextRow()) != null) {
			hashMap.put(dataRow[0], dataRow[0]);
		}

		myResults.close();

        	return hashMap;
	}

  	/**
   	 * Retrieves the list of centers.
   	 * @param conn	the database connection
   	 * @throws            SQLException if a database error occurs
	 * @return	a LinkedHashMap mapping the center id to the center name
	 */
	public LinkedHashMap getCenters(Connection conn) throws SQLException {
        	String query =
                	"select center_id, name "+
			"from centers "+
			"order by name";

        	log.debug ("in Isbra.getCenters");
        	log.debug("query = "+query);
        	PreparedStatement pstmt = conn.prepareStatement(query,
                                        	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                        	ResultSet.CONCUR_UPDATABLE);
		Results myResults = new Results(pstmt);

		LinkedHashMap<String,String> centerHash = new LinkedHashMap<String,String>();
		String [] dataRow;
		while ((dataRow = myResults.getNextRow()) != null) {
			centerHash.put(dataRow[0], dataRow[1]);
		}

        	return centerHash;
	}

  	/**
   	* Gets the list of isbra categories as an array.
   	* @param conn	the database connection
   	* @throws            SQLException if a database error occurs
   	* @return            an array of Category objects
   	*/
	public Category[] getIsbraCategories(Connection conn) throws SQLException {
		
        	String query =
                	"select category_name "+
			"from isbra_categories "+
			"order by category_name";

        	log.debug ("in Isbra.getIsbraCategories");
        	log.debug("query = "+query);
        	PreparedStatement pstmt = conn.prepareStatement(query,
                                        	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                        	ResultSet.CONCUR_UPDATABLE);

		Results myResults = new Results(pstmt);

		Category[] myCategories = new Category().setupAllCategoryValues(myResults);

		pstmt.close();

        	return myCategories;
		
	}

  	/**
   	* Retrieves a record from the isbra_groups table.
   	* @param groupID	the identifier of the group
   	* @param conn	the database connection
   	* @throws SQLException if a database error occurs 
   	* @return            a Group object
   	*/
  	public Group getIsbraGroup(int groupID, Connection conn) throws SQLException {

		log.debug("in getIsbraGroup");

        	String query =
			"select group_id, "+
			"group_name, "+
			"created_by_user_id "+
			"from isbra_groups "+
			"where group_id = ?";

		log.debug("query = "+query);
        	Results myResults = new Results(query, groupID, conn);

		Group myGroup = null;
        	while ((dataRow = myResults.getNextRow()) != null) {
			myGroup = new Group().setupGroupValues(dataRow);
		}

		myResults.close();

        	return myGroup;
  	}

  	/**
   	* Retrieves a list of isbra_groups created by this user.
   	* @param userID	the identifier of the user logged in
   	* @param conn	the database connection
   	* @throws SQLException if a database error occurs 
   	* @return            an array of Group objects
   	*/
  	public Group[] getIsbraGroups(int userID, Connection conn) throws SQLException {

		log.debug("in getIsbraGroups");

        	String query =
			"select group_id, "+
			"group_name, "+
			"created_by_user_id "+
			"from isbra_groups "+
			"where created_by_user_id = ? "+
			"order by group_name";

		//log.debug("query = "+query);
        	Results myResults = new Results(query, userID, conn);

		//log.debug("numGroups = "+myResults.getNumRows());

		Group[] myGroups = new Group().setupAllGroupValues(myResults);

		myResults.close();

        	return myGroups;
  	}


  	/**
   	* Retrieves a Subject, including answers to questions.
   	* @param subjectID	the identifier of the subject
   	* @param conn	the database connection
   	* @throws SQLException if a database error occurs 
   	* @return            an array with one Subject object
   	*/
  	public Subject[] getSubject(int subjectID, Connection conn) throws SQLException {

		log.debug("in getSubject");

        	String query =
			"select s.subject_id, "+
			"s.subject_identification_number, "+
			"ctr.name, "+
			"a.question_id, "+
			"q.description, "+
			"a.value, "+
			"c.category_name "+
			"from subjects s, centers ctr, answers a, questions q, isbra_categories c "+
			"where s.center_id = ctr.center_id "+
			"and s.subject_id = a.subject_id "+
			"and a.question_id = q.question_id "+
			"and q.category_id = c.category_id "+
			"and s.subject_id = ? "+
			"order by s.subject_id, a.question_id";

		//log.debug("query = "+query);
        	Results myResults = new Results(query, subjectID, conn);

		Subject[] mySubject = new Subject().setupAllSubjectValues(myResults);

		myResults.close();

        	return mySubject;

  	}

  	/**
   	* Retrieves an array of Subjects, including answers to questions.
   	* @param groupID	the identifier of the group
   	* @param questions	a comma-delimited string containing question numbers
   	* @param conn	the database connection
   	* @throws SQLException if a database error occurs 
   	* @return            an array of Subject objects
   	*/
  	public Subject[] getSubjects(int groupID, String questions, Connection conn) throws SQLException {

		log.debug("in getSubjects");

        	String query =
			"select s.subject_id, "+
			"s.subject_identification_number, "+
			"ctr.name, "+
			"a.question_id, "+
			"q.description, "+
			"a.value, "+
			"c.category_name "+
			"from subjects s, centers ctr, answers a, questions q, group_subjects gs, isbra_categories c "+
			"where s.center_id = ctr.center_id "+
			"and s.subject_id = a.subject_id "+
			"and a.question_id = q.question_id "+
			"and s.subject_id = gs.subject_id "+
			"and q.category_id = c.category_id "+
			"and gs.group_id = ? "+
			"and q.question_id in "+
			questions +
			" "+
			"order by s.subject_id, a.question_id";

		log.debug("query = "+query);
        	Results myResults = new Results(query, groupID, conn);

		Subject[] mySubjects = new Subject().setupAllSubjectValues(myResults);

		myResults.close();

        	return mySubjects;

  	}

  	/**
   	* Retrieves an array of Questions.
   	* @param questions	a comma-delimited string containing question descriptions
   	* @param conn	the database connection
   	* @throws SQLException if a database error occurs 
   	* @return            an array of Question objects
   	*/
  	public Question[] getQuestions(String questions, Connection conn) throws SQLException {

		log.debug("in getQuestions");

        	String query =
			"select q.question_id, "+
			"q.description, "+
			"c.category_name "+
			"from questions q, isbra_categories c "+
			"where q.category_id = c.category_id ";
			if (!questions.equals("All")) {
				query = query + "and q.question_id in "+
					questions + " ";
			}
			query = query + " order by c.category_name, q.question_id";

		//log.debug("query = "+query);
        	PreparedStatement pstmt = conn.prepareStatement(query,
                                        	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                        	ResultSet.CONCUR_UPDATABLE);

        	Results myResults = new Results(pstmt);

		Question[] myQuestions = new Question().setupAllQuestionValues(myResults);

		pstmt.close();

        	return myQuestions;

  	}

	/**
 	 * Gets answers that match the combination of search criteria
   	* @param attributes  Hashtable of attributes, along with their values, used for matching answers. Possible values are:
                        	<TABLE>
                                	<TH>Key<TH>Examples
                                	<TR> <TD>Center</TD><TD>3</TD> </TR>
                                	<TR> <TD>WorkStudentpart_time</TD><TD>2=No</TD> </TR>
                        	</TABLE></indent>
   	* @param conn    the database connection
   	* @throws            SQLException if a database error occurs
   	* @return            an array of Subject objects satisfying the selection criteria
   	*/

  	public Subject[] getSubjectsThatMatchCriteria(Hashtable attributes, Connection conn) throws SQLException {

		log.debug("in getSubjectsThatMatchCriteria");

        	String query =
			"select s.subject_id, "+
			"s.subject_identification_number, "+
			"ctr.name "+
			"from answers a, questions q, subjects s, centers ctr "+
			"where a.question_id = q.question_id "+
			"and a.subject_id = s.subject_id "+
			"and s.center_id = ctr.center_id ";

                List<String> parameterValues = new ArrayList<String>();
                Enumeration hashKeys = attributes.keys();
                while (hashKeys.hasMoreElements()) {

                        String nextKey = (String) hashKeys.nextElement();
                        String nextValue = (String) attributes.get(nextKey);

			if (nextKey.equals("center")) {
                                if (!nextValue.equals("All")) {
                                        query = query +
                                                "and ctr.center_id = ? ";
                                        parameterValues.add(nextValue);
                                }
			} else if (nextKey.equals("question")) {
                                if (!nextValue.equals("All")) {
                                        query = query +
                                                "and q.question_id = ? "+
                                                "and a.value = ? ";
					String[] splitVals = nextValue.split("///");
                                        parameterValues.add(splitVals[0]);
                                        parameterValues.add(splitVals[1]);
                                }
			}
		}
		query = query + " order by ctr.name, s.subject_identification_number ";

		//log.debug("query = "+query);
        	PreparedStatement pstmt = conn.prepareStatement(query,
                                        	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                        	ResultSet.CONCUR_UPDATABLE);

		for (int i=0; i<parameterValues.size(); i++) {
                	pstmt.setString(i+1, (String) parameterValues.get(i));
                        log.debug("just set parameter value "+ i+" to "+parameterValues.get(i));
                }

		String[] dataRow;
                Results myResults = new Results(pstmt);
        	Subject [] mySubjects = new Subject[myResults.getNumRows()];
		
        	int i=0;

        	while ((dataRow = myResults.getNextRow()) != null) {
			mySubjects[i] = new Subject().setupSubjectValues(dataRow);
			i++;
		}

		pstmt.close();

		return mySubjects;
	}


	public class Category implements Comparable {

		private int category_id;
		private String category_name;

        	public Category() {
                	log = Logger.getRootLogger();
        	}

        	public Category(int category_id, String category_name) {
                	log = Logger.getRootLogger();
			setCategory_id(category_id);
			setCategory_name(category_name);
        	}

  		public int getCategory_id() {
    			return category_id; 
  		}

  		public void setCategory_id(int inInt) {
    			this.category_id = inInt;
  		}

  		public String getCategory_name() {
    			return category_name; 
  		}

  		public void setCategory_name(String inString) {
    			this.category_name = inString;
  		}

  		/**
   		* Creates a new Category object and sets the data values to those retrieved from the database.
   		* @param dataRow	the row of data corresponding to one Category 
   		* @return            a Category object with its values setup 
   		*/
		private Category setupCategoryValues(String[] dataRow) {

        		//log.debug("in setupCategoryValues");
        		//log.debug("dataRow= "); new Debugger().print(dataRow);

        		Category myCategory = new Category();

			myCategory.setCategory_name(dataRow[0]);

        		return myCategory;
		}

  		/**
   		* Creates an array of Category objects and sets the data values to those retrieved from the database.
   		* @param myResults	a Results object
   		* @return            an array of Category objects with their values setup 
   		*/
		private Category[] setupAllCategoryValues(Results myResults) {
        		String[] dataRow;
        		Category[] myCategories = new Category[myResults.getNumRows()];

        		int i=0;

        		while ((dataRow = myResults.getNextRow()) != null) {
				myCategories[i] = setupCategoryValues(dataRow);
				i++;
			}

			return myCategories;
		}

	        public int compareTo(Object myCategoryObject) {
                	if (!(myCategoryObject instanceof Category)) return -1;
                	Category myCategory = (Category) myCategoryObject;

                        return this.category_name.compareTo(myCategory.category_name);

        	}
	}

	public class Answer implements Comparable {

		private Question question;
		private String value;

        	public Answer() {
                	log = Logger.getRootLogger();
        	}

        	public Answer(Question question, String value) {
                	log = Logger.getRootLogger();
			setQuestion(question);
			setValue(value);
        	}

  		public Question getQuestion() {
    			return question; 
  		}

  		public void setQuestion(Question inQuestion) {
    			this.question = inQuestion;
  		}

  		public String getValue() {
    			return value; 
  		}

  		public void setValue(String inString) {
    			this.value = inString;
  		}

	        public int compareTo(Object myAnswerObject) {
                	if (!(myAnswerObject instanceof Answer)) return -1;
                	Answer myAnswer = (Answer) myAnswerObject;

                        return this.question.compareTo(myAnswer.question);

        	}
	}

	public class Question implements Comparable {

		private int question_id;
		private String description;
		private String category_name;

        	public Question() {
                	log = Logger.getRootLogger();
        	}

        	public Question(int question_id, String description) {
                	log = Logger.getRootLogger();
			setQuestion_id(question_id);
			setDescription(description);
        	}

        	public Question(int question_id, String description, String category_name) {
                	log = Logger.getRootLogger();
			setQuestion_id(question_id);
			setDescription(description);
			setCategory_name(category_name);
        	}

  		public int getQuestion_id() {
    			return question_id; 
  		}

  		public void setQuestion_id(int inInt) {
    			this.question_id = inInt;
  		}

  		public String getDescription() {
    			return description; 
  		}

  		public void setDescription(String inString) {
    			this.description = inString;
  		}

  		public String getCategory_name() {
    			return category_name; 
  		}

  		public void setCategory_name(String inString) {
    			this.category_name = inString;
  		}


  		/**
   		* Creates a new Question object and sets the data values to those retrieved from the database.
   		* @param dataRow	the row of data corresponding to one Question 
   		* @return            a Question object with its values setup 
   		*/
		private Question setupQuestionValues(String[] dataRow) {

        		//log.debug("in setupQuestionValues");
        		//log.debug("dataRow= "); new Debugger().print(dataRow);

        		Question myQuestion = new Question();

			myQuestion.setQuestion_id(Integer.parseInt(dataRow[0]));
			myQuestion.setDescription(dataRow[1]);
			myQuestion.setCategory_name(dataRow[2]);

        		return myQuestion;

  		}

  		/**
   		* Creates an array of Question objects and sets the data values to those retrieved from the database.
   		* @param myResults	a Results object
   		* @return            an array of Question objects with their values setup 
   		*/
		private Question[] setupAllQuestionValues(Results myResults) {
        		String[] dataRow;
        		Question[] myQuestions = new Question[myResults.getNumRows()];

        		int i=0;

        		while ((dataRow = myResults.getNextRow()) != null) {
				myQuestions[i] = setupQuestionValues(dataRow);
				i++;
			}

			return myQuestions;
		}

	        public int compareTo(Object myQuestionObject) {
                	if (!(myQuestionObject instanceof Question)) return -1;
                	Question myQuestion = (Question) myQuestionObject;

                        //return (this.category_name+" "+this.question_id).compareTo(myQuestion.category_name+" "+myQuestion.question_id);
                        return (new Integer(this.question_id)).compareTo(new Integer(myQuestion.question_id));

        	}
	}

	public class Subject implements Comparable {

		private int subject_id;
		private String center_name;
		private int subject_identification_number;
		private Set<Answer> answers;

        	public Subject() {
                	log = Logger.getRootLogger();
        	}

  		public int getSubject_id() {
    			return subject_id; 
  		}

  		public void setSubject_id(int inInt) {
    			this.subject_id = inInt;
  		}

  		public int getSubject_identification_number() {
    			return subject_identification_number; 
  		}

  		public void setSubject_identification_number(int inInt) {
    			this.subject_identification_number = inInt;
  		}

  		public String getCenter_name() {
    			return center_name; 
  		}

  		public void setCenter_name(String inString) {
    			this.center_name = inString;
  		}

  		public Set<Answer> getAnswers() {
    			return answers; 
  		}

  		public void setAnswers(Set<Answer> inSet) {
    			this.answers = inSet;
  		}

  		/**
   		 * Creates a new Subject object and sets the data values to those retrieved from the database.
   		 * @param dataRow	the row of data corresponding to one Subject 
   		 * @return            a Subject object with its values setup 
   		 */
		private Subject setupSubjectValues(String[] dataRow) {

        		//log.debug("in setupSubjectValues");
        		//log.debug("dataRow= "); new Debugger().print(dataRow);

        		Subject mySubject = new Subject();

			mySubject.setSubject_id(Integer.parseInt(dataRow[0]));
			mySubject.setSubject_identification_number(Integer.parseInt(dataRow[1]));
			mySubject.setCenter_name(dataRow[2]);

        		return mySubject;

  		}

  		/**
   		* Creates an array of Subject objects and sets the data values to those retrieved from the database.
   		* @param myResults	a Results object
   		* @return            an array of Subject objects with their values setup 
   		*/
		private Subject[] setupAllSubjectValues(Results myResults) {
        		log.debug("in setupAllSubjectValues");

        		String[] dataRow;
        		Set<Subject> mySubjectSet = new TreeSet<Subject>();
			Subject newSubject = null;
			DbUtils myDbUtils = new DbUtils();

        		String thisSubjectID = "";
        		//
        		// initialize this to 'X' so that the first iteration will work correctly
        		//
        		String lastSubjectID = "X";

                	while ((dataRow = myResults.getNextRow()) != null) {
                        	thisSubjectID = dataRow[0];
                        	//
                        	// If the value in first column is the same as the value in the
                        	// first column of the previous record, add the value in the fourth
                        	// column to the Set.  Otherwise, close out this Set 
                        	// and set getAnswers()
                        	//
                        	if (thisSubjectID.equals(lastSubjectID)) {
					Set<Answer> answers = newSubject.getAnswers();
					if (thisSubjectID.equals("67")) {
						log.debug("adding this to answers:"+dataRow[3]+" "+dataRow[4] + " " + dataRow[6] + " " +
							myDbUtils.setToEmptyIfNull(dataRow[5]));
					}
                                	answers.add(new Answer(new Question(Integer.parseInt(dataRow[3]), dataRow[4], dataRow[6]), myDbUtils.setToEmptyIfNull(dataRow[5])));
					newSubject.setAnswers(answers);
                        	} else {
					newSubject = setupSubjectValues(dataRow);
					Set<Answer> answers = new HashSet<Answer>();
                                	answers.add(new Answer(new Question(Integer.parseInt(dataRow[3]), dataRow[4], dataRow[6]), myDbUtils.setToEmptyIfNull(dataRow[5])));
					if (thisSubjectID.equals("67")) {
						log.debug("adding this to answers:"+dataRow[3]+" "+dataRow[4] + " " + dataRow[6] + " " +
							myDbUtils.setToEmptyIfNull(dataRow[5]));
					}
					newSubject.setAnswers(answers);
					mySubjectSet.add(newSubject);
                        	}
                        	lastSubjectID = dataRow[0]; 
        		}
			log.debug("size of SubjectSet = "+mySubjectSet.size());

			return (Subject[]) mySubjectSet.toArray(new Subject[mySubjectSet.size()]);
		}

	        public int compareTo(Object mySubjectObject) {
                	if (!(mySubjectObject instanceof Subject)) return -1;
                	Subject mySubject = (Subject) mySubjectObject;

                        return (this.center_name + " " + this.subject_identification_number).compareTo(
				mySubject.center_name + " " + mySubject.subject_identification_number);

        	}

  		public String toString() {
			String subjectInfo = "This Subject object has subject_id = " + subject_id + 
				" and center_id = " + center_id; 
			return subjectInfo;
  		}

  		public void print() {
			log.debug(toString());
  		}

	}

	public class Group {

		private int group_id;
		private String group_name;
		private int created_by_user_id;

        	public Group() {
                	log = Logger.getRootLogger();
        	}

  		public int getGroup_id() {
    			return group_id; 
  		}

  		public void setGroup_id(int inInt) {
    			this.group_id = inInt;
  		}

  		public int getCreated_by_user_id() {
    			return created_by_user_id; 
  		}

  		public void setCreated_by_user_id(int inInt) {
    			this.created_by_user_id = inInt;
  		}

  		public String getGroup_name() {
    			return group_name; 
  		}

  		public void setGroup_name(String inString) {
    			this.group_name = inString;
  		}

  		/**
   		* Creates a new Group object and sets the data values to those retrieved from the database.
   		* @param dataRow	the row of data corresponding to one Group 
   		* @return            a Group object with its values setup 
   		*/
		private Group setupGroupValues(String[] dataRow) {

        		//log.debug("in setupGroupValues");
        		//log.debug("dataRow= "); new Debugger().print(dataRow);

        		Group myGroup = new Group();

			myGroup.setGroup_id(Integer.parseInt(dataRow[0]));
			myGroup.setGroup_name(dataRow[1]);
			myGroup.setCreated_by_user_id(Integer.parseInt(dataRow[2]));

        		return myGroup;

  		}

  		/**
   		* Creates an array of Group objects and sets the data values to those retrieved from the database.
   		* @param myResults	a Results object
   		* @return            an array of Group objects with their values setup 
   		*/
		private Group[] setupAllGroupValues(Results myResults) {
        		String[] dataRow;
        		Group[] myGroups = new Group[myResults.getNumRows()];

        		int i=0;

        		while ((dataRow = myResults.getNextRow()) != null) {
				myGroups[i] = setupGroupValues(dataRow);
				i++;
			}

			return myGroups;
		}
	}
}

