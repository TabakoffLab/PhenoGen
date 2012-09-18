package edu.ucdenver.ccp.PhenoGen.web; 

/*
** Authored by Cheryl Hornbaker
** 
*/

import java.lang.Exception;

/**
 * This exception is used to indicate that there is a problem
 * in the application that has an error message attached to it
 */

public class ErrorException extends Exception {

	private String additionalInfo;

        public void setAdditionalInfo(String inString) {
                this.additionalInfo = inString;
        }

        public String getAdditionalInfo() {
                return additionalInfo;
        }

	public ErrorException() {
		super();
	}

	public ErrorException(String msg) {
		super(msg);
	}

	public ErrorException(String msg, String additionalInfo) {
		super(msg);
		setAdditionalInfo(additionalInfo);
	}

	public ErrorException(String msg, Throwable cause) {
		super(msg, cause);
	}

	public ErrorException(Throwable cause) {
		super(cause);
	}


}

