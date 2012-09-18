package edu.ucdenver.ccp.util.sql;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

import edu.ucdenver.ccp.util.PropertyName;



/**
 *<br>  Authors:  Philip V. Ogren
 *<br>  Created: May, 2004
 *<br>  Description:  This class provides a JDBC connection based on a properties
 *     file.  The properties that should be specified in the properties file are
 *     indicated by the static PropertyName members of this class.
 *     A properties file that I have used for connecting to MySQL looks 
 *     something like this:
 *  <br><pre> 

DRIVER_NAME=com.mysql.jdbc.Driver
HOST=yoda
PORT=3306
DATABASE=medline
USER=user-name
PASSWORD=password
URL_PREFIX=jdbc:mysql://

 </pre>
 *     A properties file for connecting to Oracle on hal looks 
 *     something like this:
 *  <br><pre> 

DRIVER_NAME=oracle.jdbc.OracleDriver
HOST=hal.ucdenver.edu
PORT=1521
DATABASE=dev.ucdenver.edu
USER=username
PASSWORD=password
URL_PREFIX=jdbc:oracle:thin:@//

 </pre>
 *         
 * 
 * <br> Changes:
 * <br> 01-Feb-2005 Cheryl: &nbsp Updated javadoc to include a sample Oracle properties file
 * <br>
 *
 *
 * <br> Todo:  
 */

public class PropertiesConnection {
	public static final PropertyName DRIVER_NAME = new PropertyName("DRIVER_NAME");
	public static final PropertyName URL_PREFIX = new PropertyName("URL_PREFIX");
	public static final PropertyName HOST = new PropertyName("HOST");
	public static final PropertyName PORT = new PropertyName("PORT");
	public static final PropertyName DATABASE = new PropertyName("DATABASE");
	public static final PropertyName USER = new PropertyName("USER");
	public static final PropertyName PASSWORD = new PropertyName("PASSWORD");


	/** 
	 *Gets a database connection for the given properties.  Times out after 15 seconds.
	 *@param properties	a set of properties for a database connection
	 *@throws ClassNotFoundException if the specified driver cannot be found
	 *@throws SQLException if there is a problem accessing the database
	 */
	public static Connection getConnection(Properties properties) throws ClassNotFoundException, SQLException {
		Connection connection;
		String driverName = properties.getProperty(DRIVER_NAME.getName());
		String urlprefix = properties.getProperty(URL_PREFIX.getName());
		String host = properties.getProperty(HOST.getName());
		String port = properties.getProperty(PORT.getName());
		String database = properties.getProperty(DATABASE.getName());
		String user = properties.getProperty(USER.getName());
		String password = properties.getProperty(PASSWORD.getName());

		Class.forName(driverName);
		// added by Cheryl on 2/7/2007 to timeout after 15 seconds
                // modified by Spencer on 1/31/12 to timeout after 20s.  and then retry usually second attempt will succeed if first fails randomly.
		DriverManager.setLoginTimeout(20);
		String url = urlprefix + host + ":" + port + "/" + database;
                try{
                    connection = DriverManager.getConnection(url, user, password);
                }catch(SQLException e){
                    if(e.getMessage().indexOf("Socket read timed out")>-1){
                        connection = DriverManager.getConnection(url, user, password);
                    }else{
                        throw(e);
                    }
                }
                
		return connection;
	}
    
	/** 
	 *Gets a database connection for the properties in the specified file.  Times out after 15 seconds.
	 *@param propertiesFileName	the name of the file containing the properties
	 *@throws ClassNotFoundException if the specified driver cannot be found
	 *@throws SQLException if there is a problem accessing the database
	 *@throws IOException if the file cannot be opened
	 */
	public static Connection getConnection(String propertiesFileName) throws ClassNotFoundException, FileNotFoundException, IOException, SQLException {
        	Properties myProperties = new Properties();
                myProperties.load(new FileInputStream(new File(propertiesFileName)));
		return getConnection(myProperties);
	}

	/** 
	 *Gets a database connection for the properties in the specified file.  Times out after 15 seconds.
	 *@param propertiesFile	the file containing the properties
	 *@throws ClassNotFoundException if the specified driver cannot be found
	 *@throws SQLException if there is a problem accessing the database
	 *@throws IOException if the file cannot be opened
	 */
	public static Connection getConnection(File propertiesFile) throws ClassNotFoundException, IOException, SQLException {
        	Properties myProperties = new Properties();
                myProperties.load(new FileInputStream(propertiesFile));
		return getConnection(myProperties);
	}
    
	public static void main(String[] args) {
        	Properties properties = new Properties();
        
        	try {
            	properties.load(new FileInputStream(args[0]));
            	Connection connection = getConnection(properties);
            	System.out.println("successfully connected!");
            	connection.close();
        	}
        	catch(Exception exception) {
            	exception.printStackTrace();
        	}
	}
}

