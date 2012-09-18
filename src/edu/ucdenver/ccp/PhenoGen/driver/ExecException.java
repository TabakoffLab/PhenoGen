package edu.ucdenver.ccp.PhenoGen.driver; 

/*
** Authored by Cheryl Hornbaker
** 
*/

import java.lang.Exception;

/**
 * This exception is used to indicate that there is a problem
 * with executing a exec process.
 */

public class ExecException extends Exception {

	public ExecException() {
		super();
	}

	public ExecException(String msg) {
		super(msg);
	}

	public ExecException(String msg, Throwable cause) {
		super(msg, cause);
	}

	public ExecException(Throwable cause) {
		super(cause);
	}


}

