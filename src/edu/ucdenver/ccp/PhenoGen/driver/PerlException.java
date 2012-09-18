package edu.ucdenver.ccp.PhenoGen.driver; 

/*
** Authored by Cheryl Hornbaker
** 
*/

import java.lang.Exception;

/**
 * This exception is used to indicate that there is a problem
 * with executing a perl process.
 */

public class PerlException extends Exception {

	public PerlException() {
		super();
	}

	public PerlException(String msg) {
		super(msg);
	}

	public PerlException(String msg, Throwable cause) {
		super(msg, cause);
	}

	public PerlException(Throwable cause) {
		super(cause);
	}


}

