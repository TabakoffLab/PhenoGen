package edu.ucdenver.ccp.util;

import edu.ucdenver.ccp.PhenoGen.web.MultipartRequest; 

import edu.ucdenver.ccp.util.sql.Results; 

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FilenameFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.io.PrintWriter;

import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.net.URLConnection;

import java.nio.CharBuffer;
import java.nio.MappedByteBuffer;

import java.nio.channels.AsynchronousCloseException;
import java.nio.channels.ClosedByInterruptException;
import java.nio.channels.ClosedChannelException;
import java.nio.channels.FileChannel;
import java.nio.channels.NonReadableChannelException;
import java.nio.channels.NonWritableChannelException;

import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;
import java.util.Vector;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.net.ssl.HttpsURLConnection;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.servlet.ServletOutputStream;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPConnectionClosedException;

import org.apache.commons.net.io.CopyStreamException;

import org.apache.tools.tar.TarEntry;
import org.apache.tools.tar.TarOutputStream;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling files. 
 *  @author  Cheryl Hornbaker
 */

public class FileHandler{

	private String path;
	private HttpServletRequest req;
	private Vector<String> fileNames = new Vector<String>();
	private Vector<String> fileParameterNames = new Vector<String>();
	private Vector<String> parameterNames = new Vector<String>();
	private Vector<String> parameterValues = new Vector<String>();

	private Logger log=null;

	public FileHandler() {
		log = Logger.getRootLogger();
	}

	public void setPath(String pathName) {
		if (pathName == null || pathName.equals(""))
			throw new IllegalArgumentException(
			"Invalid value passed to FileHandler.setPath");
		path = pathName;
	} 

	public String getPath () {
		return path;
	}

	public void setRequest(HttpServletRequest request) {
		log.debug("in FileHander.setRequest");
		if (request != null && request instanceof HttpServletRequest) {
			log.debug("request is an instance of HttpServletRequest");
			req = (HttpServletRequest) request;
		} else {
			log.debug("request is NOT an instance of HttpServletRequest");
			throw new IllegalArgumentException(
			"Invalid value passed to FileHandler.setRequest");
		}
	}

	public Vector<String> getFilenames () {
		return fileNames;
	}

	public Vector<String> getFileParameterNames () {
		return fileParameterNames;
	}

	public Vector<String> getParameterNames () {
		return parameterNames;
	}

	public Vector<String> getParameterValues () {
		return parameterValues;
	}

        /**
         * Opens a file for writing. 
         * @param fileName       name of the file
         * @throws IOException  if there is a problem writing to the file
         */
        public PrintWriter openFile(String fileName) throws IOException {
                //log.debug("in openFile. fileName = " + fileName);

		return new PrintWriter(new FileWriter(fileName));
        }
	
	public void uploadFiles() throws java.io.IOException {

		//
		// This takes all the input fields of type "file" from an 
		// HTML form and uploads them to the directory 
		// specified by path 
		//
		// File size limit is 10 GB
		//

		log.info("in FileHandler.uploadFiles");
		MultipartRequest mpr = new MultipartRequest(
			req, path, (10000 * 1024 * 1024)); 

		//log.debug("after return from mpr");

		Enumeration fileEnum = mpr.getFileNames();

		for (int i=0; fileEnum.hasMoreElements(); i++) {
			//log.debug("file # "+i+" = ");
			String nextElement = (String) fileEnum.nextElement();
			//log.debug("nextElement = " + nextElement);

			fileNames.add(mpr.getFile_name(nextElement));
			fileParameterNames.add(nextElement);
		}

		Enumeration paramEnum = mpr.getParameterNames();
		for (int i=0; paramEnum.hasMoreElements(); i++) {
			//log.debug("parameter # "+i+" = ");
			String nextElement = (String) paramEnum.nextElement();
			//log.debug("nextElement = " + nextElement);
			parameterNames.add(nextElement);
			parameterValues.add(mpr.getParameter(nextElement));
		}
	}

  	/**
 	 * Deletes all the files in a directory.  This does NOT delete any sub-directories. 
   	 * @param dir	the File object representing the location of the files to be deleted
   	 * @return success or failure
	 * @throws		Exception if there is a problem deleting the files in the directory 
	 */
	public boolean deleteAllFilesInDirectory(File dir) throws Exception {

		boolean success = true;
		log.info("in FileHandler.deleteAllFilesInDirectory.  dir = " + dir.getPath()); 
		if (dir.isDirectory()) {
			String [] dirFiles = dir.list();
			//log.debug("dirFiles.length = " + dirFiles.length);

                	//
                	// delete all the files in the directory
                	//
			for (int i=0; i<dirFiles.length; i++) {
				File thisFile = new File(dir + "/" + dirFiles[i]);
				if (!thisFile.isDirectory()) {
					//log.debug("planning to delete this file" + thisFile);
					if (!deleteFile(thisFile)) {
						success = false;
					}
				}
			}

			//log.debug("dir has no more files");
		} else {
			//log.debug("dir is not a directory");
		}
		return success;
	}

  	/**
 	 * Directory contains no sub-directories
   	 * @param dir	the File object representing the starting directory 
   	 * @return true if the directory contains no sub-directories
	 */
	public boolean isLowestDir(File dir) {
		//log.debug("checking if "+dir.getName() + " is lowest");
		if(dir.exists() && dir.isDirectory()) {
			if(dir.list().length == 0) {
				//log.debug("returning true");
				return true;
			} else {
				File[] files = dir.listFiles();
			
				for(File file : files) {
					if(file.isDirectory()) {
						//log.debug("returning false here");
						return false;
					}
				}
			}
		}
		//log.debug("returning true at end");
		return true; 
	}

  	/**
 	 * Gets all the final sub-directories below this
   	 * @param dir	the File object representing the starting directory 
   	 * @return a Set of directories
	 */
	public Set<String> getLowestDirsBelowThis(File dir) {

		//log.info("in FileHandler.getLowestDirsBelowThis.  dir = " + dir.getPath()); 
		Set<String> allDirs = new TreeSet<String>();	
		if (dir.isDirectory()) {
			String [] dirFiles = dir.list();
			for (int i=0; i<dirFiles.length; i++) {
				File thisFile = new File(dir + "/" + dirFiles[i]);
				if (thisFile.isDirectory()) {
					if (isLowestDir(thisFile)) {
						allDirs.add(thisFile.getPath());
					}
					//log.debug(thisFile.getName() + " file is a directory, so call recursively");
					allDirs.addAll(getLowestDirsBelowThis(thisFile));
				}
			}
		} else {
			log.debug("dir is not a directory");
		}
		return allDirs;
	}

  	/**
 	 * Gets all the directories below this
   	 * @param dir	the File object representing the starting directory 
   	 * @return a Set of directories
	 */
	public Set<String> getAllDirsBelowThis(File dir) {

		//log.info("in FileHandler.getAllDirsBelowThis.  dir = " + dir.getPath()); 
		Set<String> allDirs = new TreeSet<String>();	
		if (dir.isDirectory()) {
			String [] dirFiles = dir.list();
			for (int i=0; i<dirFiles.length; i++) {
				File thisFile = new File(dir + "/" + dirFiles[i]);
				if (thisFile.isDirectory()) {
					//log.debug("file is a directory, so call recursively");
					allDirs.add(thisFile.getPath());
					allDirs.addAll(getAllDirsBelowThis(thisFile));
				}
			}
		} else {
			log.debug("dir is not a directory");
		}
		return allDirs;
	}

  	/**
 	 * Gets all the files in this directory and all sub-directories
   	 * @param dir	the File object representing the starting directory 
   	 * @param thisFilter	the filter to apply
   	 * @return a Set of Files
	 * @throws		Exception if there is a problem 
	 */
	public Set<File> getAllFilesBelowThis(File dir, FilenameFilter thisFilter) {

		//log.info("in FileHandler.getAllFilesBelowThis.  dir = " + dir.getPath()); 
		Set<File> allFiles = new TreeSet<File>();	
		if (dir.isDirectory()) {
			File [] dirFiles = dir.listFiles();
			//log.debug("there are "+ dirFiles.length + " files in this directory");
			for (File thisFile : dirFiles) {
				if (thisFile.isDirectory()) {
					//log.debug("file is a directory, so call recursively");
					allFiles.addAll(getAllFilesBelowThis(thisFile, thisFilter));
				} else if (thisFilter.accept(thisFile.getParentFile(), thisFile.getName())) {
					//log.debug("file passed filter " + thisFile);
					allFiles.add(thisFile);
				} else {
					//log.debug("file did not pass filter: " + thisFile);
				} 
			}
		} else {
			log.debug("dir is not a directory");
		}
		return allFiles;
	}

  	/**
 	 * Deletes the directory plus all files within it.
   	 * @param dir	the File object representing the directory to be deleted
   	 * @return success or failure
	 * @throws		Exception if there is a problem deleting the directory 
	 */
	public boolean deleteAllFilesPlusDirectory(File dir) throws Exception {

		boolean success = true;
		log.info("in FileHandler.deleteAllFilesPlusDirectory.  dir = " + dir.getPath()); 
		if (dir.isDirectory()) {
			String [] dirFiles = dir.list();
			//log.debug("dirFiles.length = " + dirFiles.length);

                	//
                	// delete all the files in the directory
                	//
			for (int i=0; i<dirFiles.length; i++) {
				File thisFile = new File(dir + "/" + dirFiles[i]);
				if (thisFile.isDirectory()) {
					//log.debug("file is a directory, so calling deleteAllFilesPlusDirectory agian");
					if (!deleteAllFilesPlusDirectory(thisFile)) {
						success = false;
					};
				} else {
					if (!deleteFile(thisFile)) {
						success = false;
					}
				}
			}

			//log.debug("dir is empty and is being deleted");
			if (!deleteDir(dir)) {
				success = false;
			}
		} else {
			//log.debug("dir is not a directory");
		}
		return success;
	}

	public boolean deleteFile(File inFile) throws Exception {

		log.info("in FileHandler.  Deleting file " + inFile.getPath()); 

		return (inFile.delete());
	}

  	/**
 	 * Write the contents of an array of Strings to a file.
   	 * @param fileContents	the array of Strings to be written
   	 * @param filename	the location where the file should be stored
	 * @throws		IOException if the file cannot be created
	 */
	public void writeFile(String[] fileContents, String filename) throws IOException{

		log.info("in FileHandler.writeFile from array of Strings.  filename = " + filename);

		writeFile((List<String>) Arrays.asList(fileContents), filename);
	}

  	/**
 	 * Write the contents of a Set of Strings to a file.
   	 * @param fileContents	the Set of Strings to be written
   	 * @param filename	the location where the file should be stored
	 * @throws		IOException if the file cannot be created
	 */
	public void writeFile(Set<String> fileContents, String filename) throws IOException{

		log.info("in FileHandler.writeFile from Set of Strings.  filename = " + filename);

		List<String> fileContentList = new ArrayList<String>(fileContents);
		writeFile(fileContentList, filename);

	}

  	/**
 	 * Write the contents of a List of Strings to a file.
   	 * @param fileContents	the List of Strings to be written
   	 * @param filename	the location where the file should be stored
	 * @throws		IOException if the file cannot be created
	 */
	public void writeFile(List<String> fileContents, String filename) throws IOException{

		log.info("in FileHandler.writeFile from List of Strings.  filename = " + filename);

		Iterator itr = fileContents.iterator();

		BufferedWriter bufferedWriter = getBufferedWriter(filename); 
	
		while (itr.hasNext()) {
			bufferedWriter.write((String) itr.next());
			bufferedWriter.newLine();
		}
		bufferedWriter.close();
	}

  	/**
 	 * Write the contents of a String to a file.
   	 * @param fileContents	the String to be written
   	 * @param filename	the location where the file should be stored
	 * @throws		IOException if the file cannot be created
	 */
	public void writeFile(String fileContents, String filename) throws IOException{

		log.info("in FileHandler.writeFile. filename = " + filename);

		// Create a new file output stream
		// connected to the filename passed in
		
		FileOutputStream out = new FileOutputStream(filename);
	
		// Connect print stream to the output stream

		PrintStream printStream = new PrintStream(out);

		printStream.print(fileContents);
		printStream.close();
		out.close();
	}

        public void writeResultsAsDelimitedFile(Results myResults, String fileName, String delimiter) throws IOException {

                String[] dataRow;
		//
		// Create a new file output stream
		// connected to the filename passed in
		//
		
		BufferedWriter bufferedWriter = getBufferedWriter(fileName); 
	
                try {
                	while ((dataRow = myResults.getNextRow()) != null) {
                        	for (int i=0; i<dataRow.length; i++) {
					bufferedWriter.write(dataRow[i] + delimiter);
                        	}
				bufferedWriter.newLine();
			}
			bufferedWriter.close();
                } catch (IOException e) {
                        log.error("exception when writing delimited file", e);
                        throw e;
                }
        }

	public BufferedWriter getBufferedWriter(String fileName) throws IOException {
		//if (!new File(fileName).createNewFile()) {
		//	throw new IOException("file already exists!");
		//} else {
                	return new BufferedWriter(new FileWriter(new File(fileName)), 10000);
		//}
	}

  	/**
 	 * Copy one file to another
   	 * @param inFile	the file to be read
   	 * @param outFile	the file to be created
	 * @return		the File object just created
	 * @throws	IOException if an error occurs
	 */
	public File copyFile(File inFile, File outFile) throws IOException {

		log.info("in FileHandler.copyFile. inFile = " + inFile.getPath() + 
					" outFile = " + 
					outFile.getPath());

		try {
        		// Create channel on the source
		        FileChannel srcChannel = new FileInputStream(inFile).getChannel();
   		 
		        // Create channel on the destination
		        FileChannel dstChannel = new FileOutputStream(outFile).getChannel();
    
		        // Copy file contents from source to destination
		        dstChannel.transferFrom(srcChannel, 0, srcChannel.size());
    
		        // Close the channels
		        srcChannel.close();
		        dstChannel.close();
		} catch (IllegalArgumentException e) {
			log.error("In copyFile exception", e);
			throw e;
		} catch (NonReadableChannelException e) {
			log.error("In copyFile exception", e);
			throw e;
		} catch (NonWritableChannelException e) {
			log.error("In copyFile exception", e);
			throw e;
		} catch (ClosedByInterruptException e) {
			log.error("In copyFile exception", e);
			throw e;
		} catch (AsynchronousCloseException e) {
			log.error("In copyFile exception", e);
			throw e;
		} catch (ClosedChannelException e) {
			log.error("In copyFile exception", e);
			throw e;
		} catch (IOException e) {
			log.error("In copyFile exception", e);
			throw e;
    		}
		return outFile;
	}

  	/**
 	 * Read the contents of a file and return it as a String array.
   	 * @param inFile	the file to be read
	 * @return		a String array where each line of the file is one element of the array
	 */
	public String[] getFileContents (File inFile) throws IOException{
		return getFileContents(inFile, "withSpaces");
	}

        /**
         * Gets the path name starting at "/userFiles"
         * @return              the remaining String starting at the first occurrence of /userFiles
         */
        public String getPathFromUserFiles (String inString) {
                return inString.substring(inString.indexOf("/userFiles"));
        }

	public int getFileLength (File inFile) throws IOException{
	//
	// read the contents of a file and return the number of lines it contains
	// 
		String line = "";
		BufferedReader br = null;
		int numberOfLines = 0;

		//log.debug("in getFileLength.  file = "+inFile.getPath());
		try {
			br = new BufferedReader(new FileReader(inFile));
		} catch(IOException e) {
			//log.debug("in exception of getFileLength while setting up Buffered Reader", e);
			throw e;
		}
		
		try {
			while (((line = br.readLine()) != null)) { 
				numberOfLines++;
                    	}
		} catch(IOException e) {
			log.error("in exception of getFileLength while reading lines", e);
			throw e;
		}

		return numberOfLines;
	}

  	/**
 	 * Read the contents of a file and return it as a String array.
   	 * @param inFile	the file to be read
   	 * @param spaces	if this is "noSpaces", then remove all spaces on each line 
	 * @return		a String array where each line of the file is one element of the array
	 */
	public String[] getFileContents (File inFile, String spaces) throws IOException{

		String line = "";
		List<String> lines = new ArrayList<String>();
		BufferedReader br = null;

		log.debug("in getFileContents.  file = "+inFile.getPath());
		//log.debug("spaces = "+spaces);
		try {
			br = new BufferedReader(new FileReader(inFile));
		} catch(IOException e) {
			log.error("in exception of getFileContents while setting up Buffered Reader", e);
			throw e;
		}
		
		try {
			while (((line = br.readLine()) != null)) { 
				//log.debug("line = "+line);
				//
				// replace all white space characters with no spaces
				//
				if (spaces.equals("noSpaces") && !line.replaceAll("[\\s\r']","").equals("")) {
					//log.debug("replaced spaces and added this line: "+line.replaceAll("[\\s\r']",""));
					lines.add(line.replaceAll("[\\s\r']",""));
				} else {
					//log.debug("adding this line: "+line);
					lines.add(line);
				}
                    	}
		} catch(IOException e) {
			log.error("in exception of getFileContents while reading lines", e);
			throw e;
		}

		String[] lineArray = (String[]) lines.toArray(new String [lines.size()] );
		return lineArray;
	}

	/** Determines whether a file contains a string.
	 * @param inFile	the file to check
	 * @param inString	the string to look for 
	 * @throws IOException	if an IOException occurs
	 * @return	true if the File contains the String
	 */
	public boolean fileContainsString (File inFile, String inString) throws IOException {

		log.debug("in fileContainsString. file = " + inFile + ", and looking for " + inString);
                String[] lines = getFileContents(inFile);
                //log.debug("it contains " + lines.length + " lines");
                boolean stringFound = false;
                for (int i=0; i<lines.length; i++) {
			if (lines[i].indexOf(inString) > -1) {
                        	log.debug("string was found");
                                stringFound = true;
                                break;
                        }
                }
		return stringFound;
	}

	public String[] checkFileForErrors (File inFile, String startError, String endError) throws IOException {
		log.info("in FileHandler.checkFileForErrors");

		String [] thisFileContents = getFileContents(inFile);
		List<String> returnError = new ArrayList<String>();
		for (int i=0; i<thisFileContents.length; i++) {
			if (thisFileContents[i].indexOf(startError) == 0) {
				log.debug("An error occurred on line " + i + 
					" in file " + inFile.getPath());
				int j=i;
				log.debug("contents[" + j + "] = "+thisFileContents[j]);
				if (!endError.equals("LineOnly")) {
					while (j<thisFileContents.length && thisFileContents[j].indexOf(endError) <= -1) {
						log.debug("here contents[" + j + "] = "+thisFileContents[j]);
						returnError.add(thisFileContents[j]);
						j++;
					}
				} else {
					returnError.add(thisFileContents[i]);
				}
			}	
        	}
		if (returnError.size() > 0) {
			inFile.renameTo(new File(inFile.getPath() + ".Error"));
			return (String[]) returnError.toArray(new String[returnError.size()]);
		} 
		log.info("No errors found in file");
		return (String[]) null;
	}

	/**
 	 * Deletes a directory.
	 * @param dir the object to be deleted
	 * @return	true if successful
	 * @throws	Exception if ...
	 */
	public boolean deleteDir (File dir) throws Exception {
	
		boolean success = dir.delete();
		log.info("in FileHandler.deleteDir.  dirName = "+dir.toString() +
			", success = "+success);
		return success;
	}

	/**
 	 * Creates a directory.
	 * @param dirName	the full path name of the directory to create
	 * @return	true if successful
	 */
	public boolean createDir (String dirName) {
	
		log.info("in FileHandler.createDir.  dirName = "+dirName);
		File dir = new File(dirName);
		if (!dir.exists()) {
			log.debug("dir does not exist. so first going to create parent if necessary. parent = " + dir.getParentFile().getPath());
			createDir(dir.getParent());
			return (!dir.exists() ?  dir.mkdir() : true);
		}
		return (!dir.exists() ?  dir.mkdir() : true);
	}

	public void createTarFile(String[] files, String filename) {

                int BUFFER = 2048;
		byte data[] = new byte[BUFFER];
                BufferedInputStream inFile = null;
		FileOutputStream dest = null; 
		TarOutputStream outFile = null;

		try {
			dest = new FileOutputStream(filename);
			outFile = new TarOutputStream(new BufferedOutputStream(dest));

                	log.debug("there are "+ files.length + " files to be included in tar file");

			for (int i=0; i<files.length; i++) {
				log.debug("adding file  = "+files[i]);

				File f = new File(files[i]);
				FileInputStream inputStream = new FileInputStream(files[i]);
				inFile = new BufferedInputStream(inputStream, BUFFER);
				TarEntry entry = new TarEntry(f.getName());
				entry.setSize(f.length());
				outFile.putNextEntry(entry);

				int count;
				while((count = inFile.read(data, 0, BUFFER)) != -1) {
					outFile.write(data, 0, count);
				}
				inFile.close();
				outFile.closeEntry();
			}
                	outFile.close();
			dest.close();
                } catch(Exception e) {
			log.error("In exception of FileHandler.createTarFile", e);
                }
	}

	/**
	 * Reads a file with two columns and stores it in a Hashtable.
	 * @param inFile	a File object
	 * @return		the first two columns of the file as a Hashtable 
	 */
	public Hashtable<String, String> getFileAsHashtable(File inFile) throws IOException {

		Hashtable<String, String> myHashtable = new Hashtable<String, String>();

		String[] lines = getFileContents(inFile);
		log.debug("there are "+lines.length + " lines in this file");

        	if (lines != null && lines.length > 0) {
			for (int i=0; i<lines.length; i++) {
				String[] columns = lines[i].split("[\\t]");
        			myHashtable.put(columns[0], columns[1]); 
			}
		} else {
			log.debug("in getFileAsHashtable.  inFile is null");
		}

		return myHashtable;
	}

	/**
	 * Make a Hashtable with the first column in the line of a File.  If multiple lines are found for the first column, it makes a list
	 * of values from the second column. 
	 * @param inFile	a File object 
	 * @return		a Hashtable with the first field pointing to a list of values from the second field
	 */
	public Hashtable<String, List<String>> getFileAsHashtablePlusList(File inFile) throws IOException {

		Hashtable<String, List<String>> myHashtable = new Hashtable<String, List<String>>();

		String[] lines = getFileContents(inFile);
		String thisFirstColumn = "";
		//
		// initialize this to 'XXXXX' so that the first iteration will work correctly
		//
		String lastFirstColumn = "XXXXX";
		List<String> theList = null;

        	if (lines != null && lines.length > 0) {
			for (int i=0; i<lines.length; i++) {
				String[] columns = lines[i].split("[\\t]");
				thisFirstColumn = columns[0];
				//
				// If the value in first column is the same as the value in the 
				// first column of the previous record, add the value in the second 
				// column to the list of values.  Otherwise, close out this list
				// and put it in the hashtable.
				// 
				if (thisFirstColumn.equals(lastFirstColumn)) {
					List<String> existingList = (List<String>) myHashtable.get(thisFirstColumn);
					existingList.add(columns[1]);
				} else {
					theList = new ArrayList<String>();
					theList.add(columns[1]);
					myHashtable.put(thisFirstColumn, theList);
				}
				lastFirstColumn = columns[0];
			}
		} else {
			log.debug("in getFileAsHashtablePlusList.  inFile is null");
		}
		//log.debug("fileAsHashtablePlusList = "); new Debugger().print(myHashtable);

		return myHashtable;
	}

	public void createGZipFile(File fileToBeZipped, String filename) {

                int BUFFER = 2048;
		byte data[] = new byte[BUFFER];

		try {
			FileOutputStream dest = new FileOutputStream(filename);
			GZIPOutputStream outFile = new GZIPOutputStream(dest);

			FileInputStream inputStream = new FileInputStream(fileToBeZipped);
			BufferedInputStream inFile = new BufferedInputStream(inputStream, BUFFER);

			int count;
			while((count = inFile.read(data, 0, BUFFER)) != -1) {
				outFile.write(data, 0, count);
			}
			inFile.close();
                	outFile.close();
                } catch(Exception e) {
			log.error("In exception of FileHandler.createGZipFile", e);
                }
	}

	/**
 	 * Creates a single zipped-up file from many files.
	 * @param files	the names of the files to be zipped up
	 * @param filename	the name of the final zip file
	 * @throws	Exception if ...
	 */
	public void createZipFile(String[] files, String filename) throws Exception {

                int BUFFER = 2048;
		byte data[] = new byte[BUFFER];
                BufferedInputStream inFile = null;
		FileOutputStream dest = null; 
		ZipOutputStream outFile = null;

		try {
			dest = new FileOutputStream(filename);
			outFile = new ZipOutputStream(new BufferedOutputStream(dest));
			outFile.setMethod(ZipOutputStream.DEFLATED);
			outFile.setLevel(9);

                	log.debug("there are "+ files.length + " files to be zipped up");

			for (int i=0; i<files.length; i++) {
				log.debug("adding file  = "+files[i]);

				File f = new File(files[i]);
				FileInputStream inputStream = new FileInputStream(files[i]);
				inFile = new BufferedInputStream(inputStream, BUFFER);
				ZipEntry entry = new ZipEntry(f.getName());
				outFile.putNextEntry(entry);

				int count;
				while((count = inFile.read(data, 0, BUFFER)) != -1) {
					outFile.write(data, 0, count);
				}
				inFile.close();
			}
                	outFile.close();
                } catch(Exception e) {
			log.error("In exception of FileHandler.createZipFile", e);
			throw e;
                }
	}

  	/**
 	 * Transfers a file from a remote url to a local file.
   	 * @param address	the web address
   	 * @param localFileName	the name of file being transferred
	 */
	public void getRemoteFile(String address, String localFileName) throws MalformedURLException, IOException {

		OutputStream out = null;
		URLConnection conn = null;
		InputStream  in = null;
		URL url = new URL(address);
		log.debug("in getRemoteFile.  Transferring "+address+ " to "+localFileName);

  URL loginUrl=new URL("https://www.affymetrix.com/site/processLogin.jsp?");
  //URL loginUrl=new URL(address);
log.debug("here");

  HttpsURLConnection con=
    //(HttpURLConnection)loginUrl.openConnection();
    (HttpsURLConnection)loginUrl.openConnection();


  con.setRequestMethod("POST");
  con.setDoOutput(true);
  con.setDoInput(true);
  con.setUseCaches(false);
  //con.setFollowRedirects(true);
  con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
log.debug("here2");

  String params = URLEncoder.encode("logon", "UTF-8") + "=" + URLEncoder.encode("chornbak@mindspring.com", "UTF-8") + 
			"&" + 
			URLEncoder.encode("password", "UTF-8") + "=" + URLEncoder.encode("password", "UTF-8");
 String lengthString = String.valueOf(params.length());
 con.setRequestProperty("Content-Length", lengthString);
OutputStream out1 = con.getOutputStream();
 OutputStreamWriter osw = new OutputStreamWriter(out1);
log.debug("params = "+params);
// send data to servlet
osw.write(params);
osw.flush();
osw.close();
  //out1.write(params);
  //out1.write("logon=chornbak@mindspring.com&password=password".getBytes());
//out.write("foobar".getBytes());
//out1.flush();
//  OutputStreamWriter wr=
 //   new OutputStreamWriter(con.getOutputStream());
  //wr.write("logon=chornbak@mindspring.com&password=password".getBytes());
  //wr.flush(); 
//out1.close();
	log.debug("responseCode = "+con.getResponseCode());
log.debug("here3");

		String location = con.getHeaderField("Location");
		String cookie = con.getHeaderField("Set-Cookie");
log.debug("location="+location);
log.debug("cookie="+cookie);
		out = new BufferedOutputStream(
			new FileOutputStream(localFileName));
// con.setRequestProperty("Cookie", cookie);
		conn = url.openConnection();
log.debug("getRequestProperties="+conn.getRequestProperties());
 conn.setRequestProperty("Cookie", cookie);
		//conn = loginUrl.openConnection();
		in = conn.getInputStream();
log.debug("here4");
		//in = con.getInputStream();
		byte[] buffer = new byte[1024];
		int numRead;
		long numWritten = 0;
		while ((numRead = in.read(buffer)) > 0) {
			out.write(buffer, 0, numRead);
			numWritten += numRead;
		}
		log.debug(localFileName + "\t" + numWritten);
		if (in != null) {
			in.close();
		}
		if (out != null) {
			out.close();
		}
	}

  	/**
 	 * Transfers a file from an ftp URL
   	 * @param urlString	the ftp URL where the file is located
   	 * @param localDir	the name of the local directory
   	 * @param fileName	the name of the file
log.debug("6");
	 */
	public void getFileFromURL(String urlString, String localDir, String fileName) throws IOException {
		log.debug("in getFileFromURL.  Transferring file called "+fileName + " from "+urlString);

		URL url = new URL(urlString + fileName);
		URLConnection con = url.openConnection();

		BufferedInputStream in = new BufferedInputStream(con.getInputStream());
		FileOutputStream out = new FileOutputStream(localDir + fileName);
		int i = 0;
		byte[] bytesIn = new byte[4096];
                long count=0;
                long len=0;
		while ((i = in.read(bytesIn)) >= 0) {
			out.write(bytesIn, 0, i);
                        if(count%2000==0){
                            double mb=len/(1024.0*1024);
                            System.out.println(fileName+" Read: "+mb+"MB");
                        }
                        len+=i;
                        count++;
		}
		out.close();
		in.close();
    	}

  	/**
 	 * Transfers a file from a remote ftp server to a local server.
   	 * @param server	the remote server name
   	 * @param username	the username for logging into the remote server
   	 * @param password	the password for logging into the remote server
   	 * @param remoteFolder	the folder on the remote server
   	 * @param remoteFilename	the filename on the remote server
   	 * @param localFileName	the name of file being transferred
	 */
	public void ftpGetFile(String server,
                   String username,
                   String password,
                   String remoteFolder,
                   String remoteFilename,
                   String localFileName) throws FTPConnectionClosedException, CopyStreamException, IOException {

		log.debug("in ftpGetFile.  Transferring "+server + remoteFolder +remoteFilename + " to "+localFileName);
		// Connect and logon to FTP Server
		FTPClient ftp = new FTPClient();
		ftp.connect(server);
		ftp.login(username, password);
		log.debug("Connected to " + server + ".");
		log.debug(ftp.getReplyString());

		// List the files in the directory
		ftp.changeWorkingDirectory(remoteFolder);

		// Download a file from the FTP Server
		File file = new File(localFileName); 
		OutputStream fos = null;
		//if (localFileName.endsWith("gz")) {
		//	log.debug("Input stream is GZIP");
		//	fis = new GZIPInputStream(new FileInputStream(file)); 
		//} else {
		//	log.debug("Input stream is NOT GZIP");
			fos = new FileOutputStream(file); 
		//}
		ftp.setFileType(FTP.BINARY_FILE_TYPE);
		ftp.retrieveFile(remoteFilename, fos);
		log.debug(ftp.getReplyString());
		fos.close();

		// Logout from the FTP Server and disconnect
		ftp.logout();
		ftp.disconnect();

	}

  	/**
 	 * Transfers a file from a local server to a remote ftp server.
   	 * @param server	the remote server name
   	 * @param username	the username for logging into the remote server
   	 * @param password	the password for logging into the remote server
   	 * @param remoteFolder	the folder on the remote server
   	 * @param remoteFilename	the filename on the remote server
   	 * @param localFileName	the name of file being transferred
	 */
	public void ftpPutFile(String server,
                   String username,
                   String password,
                   String remoteFolder,
                   String remoteFilename,
                   String localFileName) throws IOException {

		log.debug("in ftpPutFile.  Transferring "+localFileName +" to "+server + 
				" into folder "+ remoteFolder +" and called "+remoteFilename);
		// Connect and logon to FTP Server
		FTPClient ftp = new FTPClient();
		ftp.connect(server);
		ftp.login(username, password);
		log.debug("Connected to " + server + ".");
		log.debug(ftp.getReplyString());

		// List the files in the directory
		ftp.changeWorkingDirectory(remoteFolder);

		// Upload a file to the FTP Server
		File file = new File(localFileName); 
		InputStream fis = null;
		if (localFileName.endsWith("gz")) {
			log.debug("Input stream is GZIP");
			fis = new GZIPInputStream(new FileInputStream(file)); 
		} else {
			log.debug("Input stream is NOT GZIP");
			fis = new FileInputStream(file); 
		}
		ftp.setFileType(FTP.BINARY_FILE_TYPE);
		ftp.storeFile(remoteFilename, fis);
		log.debug(ftp.getReplyString());
		fis.close();

		// Logout from the FTP Server and disconnect
		ftp.logout();
		ftp.disconnect();

	}

	public void downloadFile(HttpServletRequest req, 
			HttpServletResponse res) throws IOException {

		if (req == null) {
		      throw new IllegalArgumentException("request cannot be null");
		}

		res.setContentType("application/octet-stream");

		FileInputStream fis = null;
		ServletOutputStream fos = res.getOutputStream();

		String fullFileName = (String) req.getAttribute("fullFileName");
		File file = new File(fullFileName);
		String filename = file.getName(); 

		res.setHeader ("Content-Disposition", 
			"attachment; filename=\"" + filename + "\"");
		log.debug("In Download.java.  fullFileName = "+fullFileName);
		log.debug("filename = "+filename);

		// No file, nothing to download
		if (filename == null) {
			log.error("No file to download");
			return;
		}

		// Return the file
		try {
			fis = new FileInputStream(fullFileName);
			byte[] buf = new byte[4 * 1024]; // 4K buffer
			int bytesRead;
			while ((bytesRead = fis.read(buf)) != -1) {
				fos.write(buf, 0, bytesRead);
			}	
		} finally {
			if (fis != null) {
				try {
					fis.close();
					file.delete();
				} catch(Exception e) {
					log.error("In exception of downloadFile where fis is not null", e);
				}
			}
			if (fos != null) {
				try {
					fos.flush();
					fos.close();
				} catch(Exception e) {
					log.error("In exception of downloadFile where fos is not null", e);
				}
			}
		}
	}





    // Charset and decoder for ISO-8859-15
    private static Charset charset = Charset.forName("ISO-8859-15");
    private static CharsetDecoder decoder = charset.newDecoder();

    // Pattern used to parse lines
    private static Pattern linePattern
	= Pattern.compile(".*\r?\n");

    // The input pattern that we're looking for
    private static Pattern pattern;

    // Compile the pattern from the command line
    //
    private static void compile(String pat) {
	try {
	    pattern = Pattern.compile(pat);
	} catch (PatternSyntaxException x) {
	    System.err.println(x.getMessage());
	    System.exit(1);
	}
    }

    // Use the linePattern to break the given CharBuffer into lines, applying
    // the input pattern to each line to see if we have a match
    //
    private static String grep(File f, CharBuffer cb) {
	String result = "";
	Matcher lm = linePattern.matcher(cb);	// Line matcher
	Matcher pm = null;			// Pattern matcher
	int lines = 0;
	while (lm.find()) {
	    lines++;
	    CharSequence cs = lm.group(); 	// The current line
	    if (pm == null)
		pm = pattern.matcher(cs);
	    else
		pm.reset(cs);
	    if (pm.find())
		result = result + f + ":" + lines + ":" + cs + "\n";
		//System.out.print(f + ":" + lines + ":" + cs);
	    if (lm.end() == cb.limit())
		break;
	}
	return result;
    }

    // Search for occurrences of the input pattern in the given file
    //
    private static String grep(File f) throws IOException {
	String result = "";

	// Open the file and then get a channel from the stream
	FileInputStream fis = new FileInputStream(f);
	FileChannel fc = fis.getChannel();

	// Get the file's size and then map it into memory
	int sz = (int)fc.size();
	MappedByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0, sz);

	// Decode the file into a char buffer
	CharBuffer cb = decoder.decode(bb);

	// Perform the search
	result = grep(f, cb);

	// Close the channel and the stream
	fc.close();
	return result;
    }

    public String grep(String pattern, String file) {
	String result = "";
	compile(pattern);
	File f = new File(file);
	if (f.isDirectory()) {
		File[] fileList = f.listFiles();
		for (int i=0; i<fileList.length; i++) {
			try {
				result = result + grep(fileList[i]);
			} catch (IOException x) {
				log.error(fileList + ": " + x);
			}
		}
	} else {
		try {
			result = result + grep(f);
		} catch (IOException x) {
			log.error(file + ": " + x);
		}
	}
	return result;
    }

    /**
     * Given a list of files, gets the total number of file size in bytes 
     * @param fileList	a list of file names
     * @return the size of the download in bytes
     */
	public long getDownloadSize(List<String> fileList){
		long downloadSize = 0L;
		
		for (String file : fileList){
			File f = new File(file);
			downloadSize += f.length();
		}
		
		
		return downloadSize;
	}
}


