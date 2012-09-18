/*
 * Created by Cheryl Hornbaker Mar, 2006
 *
 */

package edu.ucdenver.ccp.PhenoGen.tools.idecoder;

import java.io.*;
import java.sql.*;
import java.util.*;
import edu.ucdenver.ccp.util.sql.*;
import edu.ucdenver.ccp.util.*;
import org.apache.log4j.Logger;

public class IdentifierLink {
        private Logger log = null;

        private Identifier fromIdentifier;
        private Identifier toIdentifier;
        private String linkSource;

        public IdentifierLink(Identifier fromIdentifier, Identifier toIdentifier, String linkSource) {
            log = Logger.getRootLogger();
            this.fromIdentifier = fromIdentifier;
            this.toIdentifier = toIdentifier;
            this.linkSource = linkSource;
        }

        public Identifier getFromIdentifier() {
            return fromIdentifier;
        }

        public Identifier getToIdentifier() {
            return toIdentifier;
        }

        public String getLinkSource() {
            return linkSource;
        }

        public void print() {
                log.debug("from=" + fromIdentifier.toString() +
                        ", to=" + toIdentifier.toString() +
                        ", source=" + linkSource);
        }
        
	/**
	 * Determines equality of IdentifierLink objects.  An IdentifierLink object is equal to another
	 * if (1) the fromIdentifiers are the same and the toIdentifiers are the same, or
	 * (2) the fromIdentifier of one is the same as the toIdentifier of the other AND 
	 * the toIdentifier of one is the same as the fromIdentifier of the other
	 * @param myIdentifierLinkObject	the IdentifierLink object being tested for equality
	 * @return	true if the objects are equal, otherwise false			
	 */
        public boolean equals(Object myIdentifierLinkObject) {
		if (!(myIdentifierLinkObject instanceof IdentifierLink)) return false;
        	IdentifierLink myIdentifierLink = (IdentifierLink) myIdentifierLinkObject;

	//	log.debug("in IdentiferLink equals.  this.from = " + this.getFromIdentifier() +
	//		", my.from = "+myIdentifierLink.getFromIdentifier() + 
	//		", this.to = " + this.getToIdentifier() + ", my.to = " + myIdentifierLink.getToIdentifier());

		if ((this.getFromIdentifier().equals(myIdentifierLink.getFromIdentifier()) &&
			this.getToIdentifier().equals(myIdentifierLink.getToIdentifier())) ||
			(this.getFromIdentifier().equals(myIdentifierLink.getToIdentifier()) &&
			this.getToIdentifier().equals(myIdentifierLink.getFromIdentifier()))) {
                	return true;
        	} else {
                	return false;
        	}
        }

        public int hashCode() {
	            return Long.toString(getFromIdentifier().getIdNumber()).hashCode() + 
            		Long.toString(getToIdentifier().getIdNumber()).hashCode();
        }
}

