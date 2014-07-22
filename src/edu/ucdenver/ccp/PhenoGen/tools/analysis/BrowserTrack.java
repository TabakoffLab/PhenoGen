package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.web.SessionHandler; 
import java.util.ArrayList;
import java.util.HashSet;
import oracle.jdbc.*;
import org.apache.log4j.Logger;

public class BrowserTrack{
    private int id=0;
    private int userid=0;
    private String settings="";
    private String trackClass="";
    private String trackName="";
    private String trackDescription="";
    private String organism="";
    private int order=-1;
    
    public BrowserTrack(){
    }
    
    public BrowserTrack(int id, int userid,  String trackclass, 
                String trackname, String description, String organism,String settings, int order){
        this.id=id;
        this.userid=userid;
        this.settings=settings;
        this.trackClass=trackclass;
        this.trackName=trackname;
        this.trackDescription=description;
        this.organism=organism;
        this.order=order;
    }

    public int getID() {
        return id;
    }

    public void setID(int id) {
        this.id = id;
    }

    public int getUserID() {
        return userid;
    }

    public void setUserID(int userid) {
        this.userid = userid;
    }

    public String getSettings() {
        return settings;
    }

    public void setSettings(String settings) {
        this.settings = settings;
    }

    public String getTrackClass() {
        return trackClass;
    }

    public void setTrackClass(String trackClass) {
        this.trackClass = trackClass;
    }

    public String getTrackName() {
        return trackName;
    }

    public void setTrackName(String trackName) {
        this.trackName = trackName;
    }

    public String getTrackDescription() {
        return trackDescription;
    }

    public void setTrackDescription(String trackDescription) {
        this.trackDescription = trackDescription;
    }

    public String getOrganism() {
        return organism;
    }

    public void setOrganism(String organism) {
        this.organism = organism;
    }

    public int getOrder() {
        return order;
    }

    public void setOrder(int order) {
        this.order = order;
    }
    
    public String getTrackLine(){
        return this.trackClass+","+this.settings;
    }
    
    
    
}