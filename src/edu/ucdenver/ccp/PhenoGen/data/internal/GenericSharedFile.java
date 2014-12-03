package edu.ucdenver.ccp.PhenoGen.data.internal;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.data.User;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.ObjectHandler;
import java.sql.Timestamp;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling the resources available for downloading
 *  @author  Cheryl Hornbaker
 */

public class GenericSharedFile {

	private Logger log=null;

        private User owner=null;
        private int fileID=-99;
        private boolean shared=false;
        private boolean sharedAll=false;
        private String path="";
        private String description="";
        private ArrayList<User> sharedWith=new ArrayList<User>();
        private Timestamp created=null;
        
        public GenericSharedFile(){
            
        }
        
        public GenericSharedFile(int fileID,User owner, Timestamp created,boolean shared, boolean shareAll, String path, String description){
            this.fileID=fileID;
            this.owner=owner;
            this.created=created;
            this.shared=shared;
            this.sharedAll=shareAll;
            this.path=path;
            this.description=description;
        }

    public User getOwner() {
        return owner;
    }

    public void setOwner(User owner) {
        this.owner = owner;
    }

    public int getFileID() {
        return fileID;
    }

    public void setFileID(int fileID) {
        this.fileID = fileID;
    }

    public boolean isShared() {
        return shared;
    }

    public void setShared(boolean shared) {
        this.shared = shared;
    }

    public boolean isSharedAll() {
        return sharedAll;
    }

    public void setSharedAll(boolean sharedAll) {
        this.sharedAll = sharedAll;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public ArrayList<User> getSharedWith() {
        return sharedWith;
    }

    public void setSharedWith(ArrayList<User> sharedWith) {
        this.sharedWith = sharedWith;
    }

    public Timestamp getCreated() {
        return created;
    }

    public void setCreated(Timestamp created) {
        this.created = created;
    }
	
}
