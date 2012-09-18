package edu.ucdenver.ccp.PhenoGen.data; 

/*
** Authored by Cheryl Hornbaker
** 
*/

import java.lang.Exception;

/**
 * This exception is used to indicate that there is a problem
 * with reading a data element.
 */

public class DataException extends Exception {

	public DataException() {
		super();
	}

	public DataException(String msg) {
		super(msg);
	}

	public DataException(String msg, Throwable cause) {
		super(msg, cause);
	}

	public DataException(Throwable cause) {
		super(cause);
	}


}

