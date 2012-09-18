package edu.ucdenver.ccp.PhenoGen.web; 

//
// Copied from O'Reilly for use in PhenoGen
//
// Copyright (C) 1998-2001 by Jason Hunter <jhunter_AT_acm_DOT_org>.
// All rights reserved.  Use of this class is limited.
// Please see the LICENSE for more information.


import java.io.File;
import java.io.IOException;
import javax.servlet.http.HttpServletRequest;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;
/*
import javax.servlet.*;
*/

/* for logging messages */
import org.apache.log4j.Logger;

import edu.ucdenver.ccp.PhenoGen.web.MultipartParser;

/** 
 * A utility class to handle <code>multipart/form-data</code> requests,
 * the kind of requests that support file uploads.  
 * 
 * It cannot handle nested data (multipart content within multipart content).
 * 
 */
public class MultipartRequest {

  protected Hashtable<String, Vector<String>> parameters = new Hashtable<String, Vector<String>>();  // name - Vector of values
  protected Hashtable<String, File> files = new Hashtable<String, File>();       // name - File
 
  private Logger log=null;

  /**
   * Constructs a new MultipartRequest to handle the specified request, 
   * saving any uploaded files to the given directory, and limiting the 
   * upload size to the specified length.  If the content is too large, an 
   * IOException is thrown.  
   *
   * This constructor actually parses the 
   * <tt>multipart/form-data</tt> and throws an IOException if there's any 
   * problem reading or parsing the request.
   *
   * @param request the servlet request.
   * @param saveDirectory the directory in which to save any uploaded files.
   * @param maxPostSize the maximum size of the POST content.
   * @exception IOException if the uploaded content is larger than 
   */
  public MultipartRequest(HttpServletRequest request,
                          String saveDirectory,
                          int maxPostSize)
                          throws IOException {

    log = Logger.getRootLogger();

    // Sanity check values
    if (request == null)
      throw new IllegalArgumentException("request cannot be null");
    if (saveDirectory == null)
      throw new IllegalArgumentException("saveDirectory cannot be null");
    if (maxPostSize <= 0) {
      throw new IllegalArgumentException("maxPostSize must be positive");
    }
	log.debug("maxPostSize = "+maxPostSize);
	//log.debug("saveDirectory = "+saveDirectory);

    // Save the dir
    File dir = new File(saveDirectory);

    // Check saveDirectory is truly a directory
    if (!dir.isDirectory())
      throw new IllegalArgumentException("Not a directory: " + saveDirectory);

    // Check saveDirectory is writable
    if (!dir.canWrite())
      throw new IllegalArgumentException("Not writable: " + saveDirectory);

    // Parse the incoming multipart, storing files in the dir provided, 
    // and populate the meta objects which describe what we found
    log.debug("before declaring parser");
    MultipartParser parser =
      new MultipartParser(request, maxPostSize, true, true);
    log.debug("after declaring parser");

    Part part;
    while ((part = parser.readNextPart()) != null) {
      String name = part.getName();

      //log.debug("in MPR and setting name = "+name);

      if (part.isParam()) {
        // It's a parameter part, add it to the vector of values
        ParamPart paramPart = (ParamPart) part;
        String value = paramPart.getStringValue();

        log.debug("It's a parameter.  name = " + name + ", value = "+value);
	
        Vector<String> existingValues = (Vector<String>)parameters.get(name);
        if (existingValues == null) {
          existingValues = new Vector<String>();
          parameters.put(name, existingValues);
        }
        existingValues.addElement(value);
      } else if (part.isFile()) {
        // It's a file part
        FilePart filePart = (FilePart) part;
        String fileName = filePart.getFileName();

	log.debug("It's a file.  fileName = " + fileName + " and filePath = " + filePart.getFilePath());
        filePart.writeTo(dir);
	log.debug("just wrote to directory");
	log.debug("putting the following onto files Hashtable:  " + name + ", and file = " + dir.toString() + "/" + fileName);
        files.put(name, new File(dir.toString() + "/" + fileName));
      }
    }
	log.debug("done with while part = parser.readNextPart");
  }

  /**
   * Returns the names of all the parameters as an Enumeration of 
   * Strings.  It returns an empty Enumeration if there are no parameters.
   *
   * @return the names of all the parameters as an Enumeration of Strings.
   */
  public Enumeration getParameterNames() {
    return parameters.keys();
  }


  /**
   * Returns the names of all the uploaded files as an Enumeration of 
   * Strings.  It returns an empty Enumeration if there are no uploaded 
   * files.  Each file name is the name specified by the form, not by 
   * the user.
   *
   * @return the names of all the uploaded files as an Enumeration of Strings.
   */
  public Enumeration getFileNames() {
    return files.keys();
  }

  /**
   * Returns the value of the named parameter as a String, or null if 
   * the parameter was not sent or was sent without a value.  The value 
   * is guaranteed to be in its normal, decoded form.  If the parameter 
   * has multiple values, only the last one is returned (for backward 
   * compatibility).  For parameters with multiple values, it's possible
   * the last "value" may be null.
   *
   * @param name the parameter name.
   * @return the parameter value.
   */
  public String getParameter(String name) {
    try {
      Vector<String> values = (Vector<String>)parameters.get(name);
      if (values == null || values.size() == 0) {
        return null;
      }
      String value = (String)values.elementAt(values.size() - 1);
      return value;
    }
    catch (Exception e) {
	log.error("In exception of getParameter", e);
      return null;
    }
  }

  /**
   * Returns the values of the named parameter as a String array, or null if 
   * the parameter was not sent.  The array has one entry for each parameter 
   * field sent.  If any field was sent without a value that entry is stored 
   * in the array as a null.  The values are guaranteed to be in their 
   * normal, decoded form.  A single value is returned as a one-element array.
   *
   * @param name the parameter name.
   * @return the parameter values.
   */
  public String[] getParameterValues(String name) {
    try {
      Vector<String> values = (Vector<String>)parameters.get(name);
      if (values == null || values.size() == 0) {
        return null;
      }
      String[] valuesArray = new String[values.size()];
      values.copyInto(valuesArray);
      return valuesArray;
    }
    catch (Exception e) {
	log.error("In exception of getParameterValues", e);
      return null;
    }
  }

  /**
   * Returns the path name of the specified file, or null if the 
   * file was not included in the upload.  
   *
   * @param name the file name.
   * @return the path name of the file.
   */
  public String getPath(String name) {
    try {
      File file = (File)files.get(name);
      return file.getPath();  // may be null
    }
    catch (Exception e) {
	log.error("In exception of getPath", e);
      return null;
    }
  }

  /**
   * Returns the filesystem name of the specified file, or null if the 
   * file was not included in the upload.  A filesystem name is the name 
   * specified by the user.  It is also the name under which the file is 
   * actually saved.
   *
   * @param name the file name.
   * @return the filesystem name of the file.
   */
  public String getFile_name(String name) {
    try {
      File file = (File)files.get(name);
      return file.getName();  // may be null
    }
    catch (Exception e) {
	log.error("In exception of getFile_name", e);
      return null;
    }
  }

  /**
   * Returns a File object for the specified file saved on the server's 
   * filesystem, or null if the file was not included in the upload.
   *
   * @param name the file name.
   * @return a File object for the named file.
   */
  public File getFile(String name) {
    try {
      log.debug("in getFile of MPR");
      log.debug("name = " + name);
      File file = (File)files.get(name);
      return file;  // may be null
    }
    catch (Exception e) {
      log.error("in exception of getFile of MPR", e);
      return null;
    }
  }
}



