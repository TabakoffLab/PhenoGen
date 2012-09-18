// Copyright (C) 1999-2001 by Jason Hunter <jhunter_AT_acm_DOT_org>.
// All rights reserved.  Use of this class is limited.
// Please see the LICENSE for more information.

package edu.ucdenver.ccp.PhenoGen.web;

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import javax.servlet.ServletInputStream;

import com.oreilly.servlet.multipart.*;

/* for logging messages */
import org.apache.log4j.Logger;
/**
 * A <code>FilePart</code> is an upload part which represents a 
 * <code>INPUT TYPE="file"</code> form parameter.  Note that because file 
 * upload data arrives via a single InputStream, each FilePart's contents
 * must be read before moving onto the next part.  Don't try to store a
 * FilePart object for later processing because by then their content will
 * have been passed by.
 * 
 * @author Geoff Soutter
 * @version 1.2, 2001/01/22, getFilePath() addition thanks to Stefan Eissing
 * @version 1.1, 2000/11/26, writeTo() bug fix thanks to Mike Shivas
 * @version 1.0, 2000/10/27, initial revision
 */
public class FilePart extends Part {
  private Logger log=null;
  
  /** "file system" name of the file  */
  private String fileName;     
  
  /** path of the file as sent in the request, if given */
  private String filePath;

  /** content type of the file */
  private String contentType;   
  
  /** input stream containing file data */
  private PartInputStream partInput;  
    
  /** file rename policy */
  private FileRenamePolicy policy;

  /**
   * Construct a file part; this is called by the parser.
   * 
   * @param name the name of the parameter.
   * @param in the servlet input stream to read the file from.
   * @param boundary the MIME boundary that delimits the end of file.
   * @param contentType the content type of the file provided in the 
   * MIME header.
   * @param fileName the file system name of the file provided in the 
   * MIME header.
   * @param filePath the file system path of the file provided in the
   * MIME header (as specified in disposition info).
   * 
   * @exception IOException	if an input or output exception has occurred.
   */
  FilePart(String name, ServletInputStream in, String boundary,
           String contentType, String fileName, String filePath)
                                                   throws IOException {
    super(name);
    this.fileName = fileName;
    this.filePath = filePath;
    this.contentType = contentType;
    log = Logger.getRootLogger();
log.debug("in FilePart constructor");
    partInput = new PartInputStream(in, boundary);
log.debug("after setting partInput ");
  }

  /**
   * Puts in place the specified policy for handling file name collisions.
   */
  public void setRenamePolicy(FileRenamePolicy policy) {
    this.policy = policy;
  }
  
  /**
   * Returns the name that the file was stored with on the remote system, 
   * or <code>null</code> if the user didn't enter a file to be uploaded. 
   * Note: this is not the same as the name of the form parameter used to 
   * transmit the file; that is available from the <code>getName</code>
   * method.  Further note: if file rename logic is in effect, the file
   * name can change during the writeTo() method when there's a collision
   * with another file of the same name in the same directory.  If this
   * matters to you, be sure to pay attention to when you call the method.
   * 
   * @return name of file uploaded or <code>null</code>.
   * 
   * @see Part#getName()
   */
  public String getFileName() {
    return fileName;
  }

  /**
   * Returns the full path and name of the file on the remote system,
   * or <code>null</code> if the user didn't enter a file to be uploaded.
   * If path information was not supplied by the remote system, this method
   * will return the same as <code>getFileName()</code>.
   *
   * @return path of file uploaded or <code>null</code>.
   *
   * @see Part#getName()
   */
  public String getFilePath() {
    return filePath;
  }

  /** 
   * Returns the content type of the file data contained within.
   * 
   * @return content type of the file data.
   */
  public String getContentType() {
    return contentType;
  }
  
  /**
   * Returns an input stream which contains the contents of the
   * file supplied. If the user didn't enter a file to upload
   * there will be <code>0</code> bytes in the input stream.
   * It's important to read the contents of the InputStream 
   * immediately and in full before proceeding to process the 
   * next part.  The contents will otherwise be lost on moving
   * to the next part.
   * 
   * @return an input stream containing contents of file.
   */
  public InputStream getInputStream() {
    return partInput;
  }

  /**
   * Write this file part to a file or directory. If the user 
   * supplied a file, we write it to that file, and if they supplied
   * a directory, we write it to that directory with the filename
   * that accompanied it. If this part doesn't contain a file this
   * method does nothing.
   *
   * @return number of bytes written
   * @exception IOException	if an input or output exception has occurred.
   *///
  public long writeTo(File fileOrDirectory) throws IOException {
log.debug("in FilePart.writeTo.  fileOrDirectory = " + fileOrDirectory.getName());
    long written = 0;
    
    OutputStream fileOut = null;
    try {
      // Only do something if this part contains a file
      if (fileName != null) {
log.debug("fileName is not null.  It is "+fileName);
        // Check if user supplied directory
        File file;
        if (fileOrDirectory.isDirectory()) {
log.debug("fileOrDirectory is a directory ");
          // Write it to that dir the user supplied, 
          // with the filename it arrived with
          file = new File(fileOrDirectory, fileName);
log.debug("just created a new file in that directory ");
        }
        else {
log.debug("fileOrDirectory is NOT a directory ");
          // Write it to the file the user supplied,
          // ignoring the filename it arrived with
          file = fileOrDirectory;
log.debug("just set file to the fileOrDirectory ");
        }
        if (policy != null) {
log.debug("policy is not null .  It is "+fileName);
          file = policy.rename(file);
          fileName = file.getName();
log.debug("fileName  is now = "+fileName);
        }
log.debug("before fileOut");
        fileOut = new BufferedOutputStream(new FileOutputStream(file));
log.debug("after fileOut. before written");
        written = write(fileOut);
log.debug("after written");
      }
    }
    finally {
log.debug("in finally clause");
      if (fileOut != null) fileOut.close();
    }
log.debug("done with writeTo ");
    return written;
  }

  /**
   * Write this file part to the given output stream. If this part doesn't 
   * contain a file this method does nothing.
   *
   * @return number of bytes written.
   * @exception IOException	if an input or output exception has occurred.
   */
  public long writeTo(OutputStream out) throws IOException {
log.debug("in filePart writeTo outputStream");
    long size=0;
    // Only do something if this part contains a file
    if (fileName != null) {
log.debug("fileName is not null.  it is "+fileName);
      // Write it out
      size = write( out );
    }
log.debug("size is  "+size);
    return size;
  }

  /**
   * Internal method to write this file part; doesn't check to see
   * if it has contents first.
   *
   * @return number of bytes written.
   * @exception IOException	if an input or output exception has occurred.
   */
  long write(OutputStream out) throws IOException {
log.debug("in write to outputStream");
    // decode macbinary if this was sent
    if (contentType.equals("application/x-macbinary")) {
log.debug("contentType is x-macbinary");
      out = new MacBinaryDecoderOutputStream(out);
    }
    long size=0;
    int read;
    byte[] buf = new byte[8 * 1024];
log.debug("before reading ");
int debugNow = 1000000;
    while((read = partInput.read(buf)) != -1) {
      out.write(buf, 0, read);
      size += read;
if (size > debugNow) {
//log.debug("inside reading. just wrote. size =  " + size);
	debugNow = debugNow + 1000000;
}
    }
log.debug("after reading . size = " + size);
    return size;
  }
  
  /**
   * Returns <code>true</code> to indicate this part is a file.
   * 
   * @return true.
   */
  public boolean isFile() {
    return true;
  }
}
