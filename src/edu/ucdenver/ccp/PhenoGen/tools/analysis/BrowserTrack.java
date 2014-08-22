package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.web.SessionHandler; 
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
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
    private boolean visible=true;
    private String location="";
    
    public BrowserTrack(){
    }
    
    public BrowserTrack(int id, int userid,  String trackclass, 
                String trackname, String description, String organism,String settings, int order,String genCat,String category,String controls,Boolean vis,String location){
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
        this.visible=vis;
        this.location=location;
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
                    String location=rs.getString(11);
                    BrowserTrack tmpBT=new BrowserTrack(tid,uid,tclass,name,desc,org,"",0,genCat,cat,controls,vis,location);
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

    public boolean isVisible() {
        return visible;
    }

    public void setVisible(boolean visible) {
        this.visible = visible;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }
    
    public int getNextID(DataSource pool){
        int id=-1;
        String query="select Browser_Track_ID_SEQ.nextVal from dual";
        Connection conn=null;
        try{
            conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
            ResultSet rs=ps.executeQuery();
            if (rs.next()){
                id=rs.getInt(1);
            }
            ps.close();
            conn.close();
            conn=null;
        }catch(SQLException e){
            
        }finally{
            try{
            if(conn!=null&&!conn.isClosed()){
                conn.close();
                conn=null;
            }
            }catch(SQLException er){
                
            }
        }
        return id;
    }
    
    public boolean saveToDB(DataSource pool){
        boolean success=false;
        String insertUsage="insert into browser_tracks (TRACKID,USER_ID,TRACK_CLASS "
                + "TRACK_NAME,TRACK_DESC,ORGANISM,CATEGORY_GENERIC,CATEGORY,DISPLAY_OPTS "
                + "VISIBLE,CUSTOM_LOCATION) values (?,?,?,?,?,?,?,?,?,?,?)";
        Connection conn=null;
        try{
            conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(insertUsage, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
            ps.setInt(1, this.id);
            ps.setInt(2,this.userid);
            ps.setString(3, this.trackClass);
            ps.setString(4, this.trackName);
            ps.setString(5, this.trackDescription);
            ps.setString(6, this.organism);
            ps.setString(7, this.genericCategory);
            ps.setString(8, this.category);
            ps.setString(9, this.controls);
            ps.setBoolean(10, this.visible);
            ps.setString(11, this.location);
            ps.execute();
            ps.close();
            conn.close();
            conn=null;
            success=true;
        }catch(SQLException e){
            
        }finally{
            try{
            if(conn!=null&&!conn.isClosed()){
                conn.close();
                conn=null;
            }
            }catch(SQLException er){
                
            }
        }
        
        return success;
    }
}