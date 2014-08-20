package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.web.SessionHandler; 
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import javax.sql.DataSource;
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
    private String genericCategory="";
    private String category="";
    private int order=-1;
    private String controls="";
    
    public BrowserTrack(){
    }
    
    public BrowserTrack(int id, int userid,  String trackclass, 
                String trackname, String description, String organism,String settings, int order,String genCat,String category,String controls){
        this.id=id;
        this.userid=userid;
        this.settings=settings;
        this.trackClass=trackclass;
        this.trackName=trackname;
        this.trackDescription=description;
        this.organism=organism;
        this.order=order;
        this.genericCategory=genCat;
        this.category=category;
        this.controls=controls;
    }

    public ArrayList<BrowserTrack> getBrowserTracks(int userid,DataSource pool){
        Logger log=Logger.getRootLogger();
        ArrayList<BrowserTrack> ret=new ArrayList<BrowserTrack>();
        
        HashMap<Integer,BrowserTrack> hm=new HashMap<Integer,BrowserTrack>();
        
        String query="select * from BROWSER_TRACKS "+
                        "where user_id="+userid;
            Connection conn=null;
            PreparedStatement ps=null;
            try {
                conn=pool.getConnection();
                ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                //int count=0;
                while(rs.next()){
                    int tid=rs.getInt(1);
                    int uid=rs.getInt(2);
                    String tclass=rs.getString(3);
                    String name=rs.getString(4);
                    String desc=rs.getString(5);
                    String org=rs.getString(6);
                    String genCat=rs.getString(7);
                    String cat=rs.getString(8);
                    String controls=rs.getString(9);
                    boolean vis=rs.getBoolean(10);
                    BrowserTrack tmpBT=new BrowserTrack(tid,uid,tclass,name,desc,org,"",0,genCat,cat,controls);
                    ret.add(tmpBT);
                }
                
                ps.close();
                conn.close();
                conn=null;
            } catch (SQLException ex) {
                log.error("SQL Exception retreiving browser views:" ,ex);
                try {
                    ps.close();
                } catch (Exception ex1) {
                   
                }
            } finally{
                if(conn!=null){
                    try{
                        conn.close();
                        conn=null;
                    }catch(SQLException e){
                        
                    }
                    conn=null;
                }
            }
            
            
        return ret;
    }

    public String getControls() {
        return controls;
    }

    public void setControls(String controls) {
        this.controls = controls;
    }

    public String getGenericCategory() {
        return genericCategory;
    }

    public void setGenericCategory(String genericCategory) {
        this.genericCategory = genericCategory;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
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