package edu.ucdenver.ccp.PhenoGen.tools.mage; 

/*
** Authored by Cheryl Hornbaker
** 
*/

import java.lang.Exception;

/**
 * This exception is used to indicate that there is a problem
 * with executing a perl process that handles validating MAGE-ML.
 */

public class ValidatorException extends Exception {

	public ValidatorException() {
		super();
	}

	public ValidatorException(String msg) {
		super(msg);
	}

	public ValidatorException(String msg, Throwable cause) {
		super(msg, cause);
	}

	public ValidatorException(Throwable cause) {
		super(cause);
	}


}

