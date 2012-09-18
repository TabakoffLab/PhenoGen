package edu.ucdenver.ccp.PhenoGen.data;
                                                                                                                       
import java.sql.*;
import java.util.*;
import edu.ucdenver.ccp.util.sql.*;
                                                                                                                       
/* for logging messages */
import org.apache.log4j.Logger;
                                                                                                                       
/**
 * Class for handling messages.
 *  @author  Cheryl Hornbaker
 */

public class Message{
  	private String id;
	private String text;
  	private String type;
	
  	private Logger log=null;
                                                                                                                       
  	public Message () {
        	log = Logger.getRootLogger();
  	}

  	public String getId() {
		return id;
  	}

  	public void setId(String inString) {
		this.id = inString;
  	}

  	public String getText() {
		return text;
  	}

  	public void setText(String inString) {
		this.text = inString;
  	}

  	public String getType() {
		return type;
  	}

  	public void setType(String inString) {
		this.type = inString;
  	}

	/**
	 * Retrieves the text for the requested message id.
	 * @param msgID	the ID of the message
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            the text of the message
	 */
  	public String getMessage(String msgID, Connection conn) throws SQLException {
		
		String query =
			"select text "+
			"from messages "+
			"where id = ?";

		//log.debug("query = "+ query);
		log.debug("in getMessage. msgID = " + msgID);

                Results myResults = new Results(query, msgID, conn);

                String message = myResults.getStringValueFromFirstRow();

                myResults.close();

		return message;
  	}

}

