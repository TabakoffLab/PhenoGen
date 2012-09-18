/*******************************************************
 ** Name:     GOlogin.java                            **
 ** Date:     January 27, 2005                        **
 ** Original: May 5, 2004                             **
 **                                                   **
 ** Author(s):     Purvesh Khatri                     **
 ** Modification:  Joachim Almergren                  **
 *******************************************************/

/******************************************************************************

 Description:  

   This example program takes DOS/Linux command line arguments to login to 
   the ISBL Onto_Tools Server. It generates a session ID and submits a number
   of variables to test the Onto-Tools using a number of Accession IDs.
   The server responds by sending back a URL with the correct parameters that
   can be used to start a Java enabled web browser. Under windows it attempts 
   to automatically start the default browser, and under Linux, the mozilla 
   browser.
 
 Syntax:  
 
   java -cp GOlogin <username> <pasword> <ip:port> <genelist>
 
 Default parameters:

 Name             Values       Function   
 ------------------------------------------------------------------------------
 "standalone"     "true"       Must always be this for non ISBL software
 "id"             id           The session id
 "version"        1            Sofware version: 1 for reference array, 1.1 for none...
 "organism"       "Mm"         Type of Organism: Hs, Mm, Rn, Cel, Dm
 "application"    "applet"     Type of application 
 "queryMethod"    "accession"  Type of query: accession, cluster, probe
 "submit"         "Submit"     Always needed 
 "listOfIds"      "true"       Are we submitting a list?  true, false
 "downloadgotree" "true"       Do we want to download the GO tree?  true, false
 "ref"            "none"       The <array id> name if needed 
                               (If specified one must also include "dist." & "corr.")
 *"distribution"  "0"          What kind:  0-Binomial, 1-Hypergeometric, 2-Chi-square
 *"correction"    "4"          What kind:  0-Bonferroni, 1-Sidak, 2-???, 3-Holme's, 4-FDR

 "list"           "AF320340,BE134617,BF658806" 
 ------------------------------------------------------------------------------

   The constructor is now changed to accept hostURL.
   E.g., vortex.cs.wayne.edu:8080, vortex.cs.wayne.edu:9080, etc.
   The modification allows us to use the same configuration file for any port
   on Vortex as well as any other server (e.g., www.xyz.com) without any
   modification.

   * The LoginExaple class is modified to accept the host name as a parameter.
   * As a result, a new input parameter, <connection URL> is added. The value of
   * connection URL parameter looks like one of the following examples. Note that
   * it does not contain "HTTP://". 
   * 1. vortex.cs.wayne.edu:8080
   * 2. 141.217.17.10:9580
  ******************************************************************************/

package edu.ucdenver.ccp.PhenoGen.tools.oe;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Enumeration;
import java.util.Properties;
import java.util.StringTokenizer;

//import edu.ucdenver.ccp.PhenoGen.tools.oe.BrowserControl;
import edu.ucdenver.ccp.PhenoGen.tools.oe.Constants;
import edu.ucdenver.ccp.PhenoGen.tools.oe.IniFile;
import edu.ucdenver.ccp.PhenoGen.tools.oe.HttpMessage;
import java.io.UnsupportedEncodingException;

import org.apache.log4j.Logger;

public class GOlogin
{
  private static String id;
  private String version;
  private static String host;  // This is the host value returned by the OT server

  private Logger log=null;

// Added by joal for testing genelist
/*public static final String GeneList = "AF320340,BE134617,BF658806,BC003305,NM_010594,NM_133753," + 
            "BE912771,NM_007410,BC002136,NM_010256,NM_025388,BC005430," + 
            "NM_019719,NM_011801,NM_013902,NM_133835,NM_019716,NM_024191," + 
            "NM_013916,NM_013522,NM_011838,NM_016696,NM_008142,BE368753," + 
            "NM_009321,NM_025427,NM_008761,BC026445,BC006030,BC003317," + 
            "NM_008951,NM_025341,NM_023456,NM_022007,NM_138607,NM_021531," + 
            "R75193,AK010394,BG064031,BC006680,NM_013772,NM_009136,BG060855," + 
            "BB026596,BC013506, AF320340,BE134617,BF658806,BC003305,NM_010594," + 
            "NM_133753,BE912771,NM_007410,BC002136,NM_010256,NM_025388,BC005430," + 
            "NM_019719,NM_011801,NM_013902,NM_133835,NM_019716,NM_024191," + 
            "NM_013916,NM_013522,NM_011838,NM_016696,NM_008142,BE368753,NM_009321," + 
            "NM_025427,NM_008761,BC026445,BC006030,BC003317,NM_008951,NM_025341,NM_023456," +
            "NM_022007,NM_138607,NM_021531,R75193,AK010394,BG064031,BC006680,NM_013772," +
            "NM_009136,BG060855,BB026596,BC013506";
  */
  
  public GOlogin () {
	log = Logger.getRootLogger();
  }

  public String callGO (String username, String password, String hostURL, String GeneList)  {

	log.debug("In callGO");
    //create a properties object that contains parameter names and value for a request.
    Properties props = new Properties();
    props.setProperty("username", username);
    props.setProperty("password", password);
    props.setProperty("submit", "login"); 
    String url = "";
    try {
	log.debug("sending Post Request");
      InputStream in = sendPostRequest("http://" + hostURL + "/ontoexpress/servlet/UserInfo", props);
      if(in == null) {
        log.debug("GOlogin: Error when trying to login to Onto-Tools server.");
        return "Error";
      }
      //Chain the InputStream object with BufferedReader to facilitate the response reading.
      BufferedReader br = new BufferedReader(new InputStreamReader(in));

      /************************************************************************
         Start reading the response using java.io.BufferedReader object.
         The response only contains one of the following text:
           1. login failed
           2. login failed;user not registered
           3. login failed;password didn't match
           4. login successfull;<session id>;<OE version number the user is allowed to use>
         For example: 
           login successfull;E29B01A57AF01F7CEA05E9A20DBC8E08;1.5     or           
           login successfull;E29B01A57AF01F7CEA05E9A20DBC8E08;2.5
         ;<update OR donot_update> (Last part is for Auto Upgrade) by Valmik
       ************************************************************************/
      
      String s;
	log.debug("reading stuff returned");
      while ((s = br.readLine()) != null) {
        s = s.trim();
	log.debug("s = " + s);
        if (s.startsWith("login failed")) {  //Check the server response.
          log.debug("Onto-Tools Login Error: Login attempt to Onto-Tools server failed.");
          log.debug("Onto-Tools Login server said: \"" + s + "\"");
          return "Error";
        }
        else if (s.startsWith("login successful")) {
          log.debug("ISBL server says: \"" + s + "\"");
          // Note: The session is active for one hour only. If not queried 
          // within an hour, it will expire and the user will have to log back in again.

          StringTokenizer stk = new StringTokenizer(s, ";");
          stk.nextToken();               // skip the First token.
          id          = stk.nextToken(); // Second token is the session id.
          version     = stk.nextToken(); // Third token is the OE version that the user is allowed to use.
          host        = stk.nextToken(); // Fourth token is the host name

          InputStream inConfig = sendGetRequest("http://" + host + "/ontoexpress/servlets/OntoToolsApp.config", null);
          if(inConfig == null) {
            log.debug("GOlogin: Error when trying to read configuration file from Onto-Tools server.");
            return "Error";
          }
  	  else {
		log.debug("inConfig is not null");
	  }

          BufferedReader brConfig = new BufferedReader(new InputStreamReader(inConfig));
          // joal: Changed from OntoToolsApp.config.testV3...
	log.debug("here");
          PrintWriter pw = new PrintWriter(new FileWriter("/st1/userFiles/ckh/OntoToolsApp.config.test"));
	log.debug("here2");
          while( (s = brConfig.readLine()) != null) {
            pw.println(s);
          }
          brConfig.close();
          pw.close();
        } else {
          log.debug("Unexpected error during login to Onto-Tools server:");
          log.debug("Onto-Tools Login server said:\n" + s);
          while((s = br.readLine()) != null) {
             log.debug(s);
          }
        }
      }
	log.debug("here3");
    IniFile ini = new IniFile("/st1/userFiles/ckh/OntoToolsApp.config");
	log.debug("here4. GeneList = " + GeneList);
    url = getRunOERequest(ini, GeneList);    
	log.debug("here5");
	log.debug("url = " + url);
    }
    catch (IOException ioe) {
      log.debug("IOException", ioe);
      return "Error" ;
    }    
    return url;
  }

  
  //public static InputStream sendPostRequest(String urlString, Properties props) {
  public static InputStream sendPostRequest(String urlString, Properties props) throws MalformedURLException, IOException {
   // try    {
      URL url = new URL(urlString);
      HttpMessage request = new HttpMessage(url); // Create our HttpMessage object for a given URL object.
      return request.sendPostMessage(props);      // Now, send the request to the server.
      // The response from the server is a java.io.InputStream object.
/*
    }
    catch(MalformedURLException murle) {
      log.debug("MalformedURLException", murle);
      return null;
    }
    catch(IOException ioe)    {
      log.debug("IOException", ioe);
      return null;
    }
*/
  }

  
  //public static InputStream sendGetRequest(String urlString, Properties props) {
  public static InputStream sendGetRequest(String urlString, Properties props) throws MalformedURLException, IOException {
 //   try {
       URL url = new URL(urlString);
       HttpMessage request = new HttpMessage(url);
       return request.sendGetMessage(props);
/*
    }
    catch(MalformedURLException murle) {
       log.debug("MalformedURLException", murle);
       return null;
    }
    catch(IOException ioe) {
       log.debug("IOException", ioe);
       return null;
    }
*/
  }
  
  
  //private static void writeParameter(DataOutputStream out, String name, String value) {
  private static void writeParameter(DataOutputStream out, String name, String value) throws IOException {
//    try {
      out.writeBytes("--" + Constants.BOUNDARY); // First line is the boundary.
      out.writeBytes(Constants.BLANK_LINE);      // Then blank line.
      out.writeBytes(Constants.DISPOSITION_STR + "\"" + name + "\"; ");
      out.writeBytes(Constants.BLANK_LINE);      // Then blank line.
      out.writeBytes(Constants.CONTENT_TYPE);    // Then, content type.
      out.writeBytes(Constants.BLANK_LINE);      // Then blank line.
      out.writeBytes(Constants.BLANK_LINE);      // Then blank line.
      out.writeBytes(value);
      out.writeBytes(Constants.BLANK_LINE);
/*
    }
    catch (IOException ioe) {
      log.debug("IOException: There was an error sending file data: " + name, ioe);
    }
*/
  }


  public static void main(String [] args) throws IOException
  {
    if(args.length != 4) {
//      log.debug("USAGE: java oe.GOlogin <username> <password> <ip:port> <genelist>");
      System.exit(0);
    }
    //change in the LoginExample constructor.
//    new GOlogin(args[0].trim(), args[1].trim(), args[2].trim(), args[3].trim());
    IniFile ini = null;
    String GeneList = args[3].trim();
    try { 
      // joal: renamed from "OntoToolsApp.config.testV3":
      ini = new IniFile("/st1/userFiles/ckh/OntoToolsApp.config");
    } 
    catch(IOException e) {
 //     log.debug("IOException", e);
      System.exit(1);
    }
    String url = getRunOERequest(ini, GeneList);    
//    log.debug(url);
    //BrowserControl.displayURL(url); // This is not needed for INGED.
  }

  
  public static String getRunOERequest(IniFile ini, String GeneList)
  {     
    Properties props = new Properties();
    props.put("standalone", "true");           
    props.put("id", id);                       // '<session id'>
    props.put("ref", "none");                  // 'none' or '<array id>'
    props.put("version", Constants.VERSION_1); // 1 for reference <array id>, 1.1 for 'none'...
    props.put("organism", "Mm");               // Hs, Mm, Rn, Cel, Dm
    props.put("application", "applet");        // Always "applet"
    props.put("queryMethod", "accession");     // accession, cluster, probe
    props.put("submit", "Submit");             // Always "submit"
    props.put("listOfIds", "true");            // true, false
    props.put("list", GeneList);               // The genelist...
    props.put("downloadgotree", "true");       // true, false
    // props.put("distribution", "0");         // 0-Binomial, 1-Hypergeometric, 2-Chi-square
    // props.put("correction", "4");           // 0-Bonferroni, 1-Sidak, 2-???, 3-Holme's, 4-FDR
    
    String encodedString = "?" + toEncodedString(props);
    String oeURL = "http://" + host + ini.getProfile("url", "ontoexpress_url");
    return oeURL + encodedString;
  }

  
  private static String toEncodedString(Properties args) {
	StringBuffer buf = new StringBuffer();
	Enumeration names = args.propertyNames();
	while(names.hasMoreElements()) {
		String name = (String) names.nextElement();
		String value = args.getProperty(name);
		String unic = "UTF-8"; //joal ISO-8859-1/UTF-8/US-ASCII?
		try {
			buf.append(URLEncoder.encode(name, unic) + "=" + URLEncoder.encode(value, unic));
			//buf.append(URLEncoder.encode(name) + "=" + URLEncoder.encode(value));
		}
		catch (Exception e) {
		}
		if(names.hasMoreElements())
			buf.append("&");
		}
	return buf.toString();
  }
}
