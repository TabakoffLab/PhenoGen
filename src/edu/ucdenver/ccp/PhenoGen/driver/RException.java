package edu.ucdenver.ccp.PhenoGen.driver; 

/*
** Authored by Cheryl Hornbaker
** 
*/

import java.lang.Exception;

/**
 * This exception is used to indicate that there is a problem
 * with executing an 'R' process.
 */

public class RException extends Exception {

	public RException() {
		super();
	}

	public RException(String msg) {
		super(msg);
	}

	public RException(String msg, Throwable cause) {
		super(msg, cause);
	}

	public RException(Throwable cause) {
		super(cause);
	}


}

