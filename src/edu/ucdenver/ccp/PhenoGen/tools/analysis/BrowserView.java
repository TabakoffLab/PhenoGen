package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.web.SessionHandler; 
import edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserTrack;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import javax.sql.DataSource;
import oracle.jdbc.*;
import org.apache.log4j.Logger;

public class BrowserView{
    private int id=0;
    private int userID=0;
    private String name="";
    private String description="";
    private String organism="";
    private boolean visible=false;
    private String imageSettings="";
    private ArrayList<BrowserTrack> btList=new ArrayList<BrowserTrack>();
    
    public BrowserView(){
        
    }
    
    public BrowserView(int id,int userid,String name,String description, String organism,boolean visible,String imgsetting){
        this.id=id;
        this.userID=userid;
        this.name=name;
        this.description=description;
        this.organism=organism;
        this.visible=visible;
        this.imageSettings=imgsetting;
    }
    
    public ArrayList<BrowserView> getBrowserViews(int userid,DataSource pool){
        Logger log=Logger.getRootLogger();
        ArrayList<BrowserView> ret=new ArrayList<BrowserView>();
        
        HashMap<Integer,BrowserView> hm=new HashMap<Integer,BrowserView>();
        
        String query="select * from BROWSER_VIEWS "+
                        "where user_id="+userid+" and visible=1";
        String trackquery="select bvt.bvid,bt.*,bts.settings,bvt.ordering from BROWSER_VIEWS_TRACKS bvt,BROWSER_TRACKS bt, BROWSER_TRACK_SETTINGS bts where "+
                        " bvt.trackid=bt.trackid and bvt.tracksettingid=bts.tracksettingid "+
                        " and bvt.bvid in (select bvid from browser_views where user_id="+userid+" and visible=1) "+
                        " order by bvt.bvid,bvt.ordering";
            Connection conn=null;
            PreparedStatement ps=null;
            try {
                conn=pool.getConnection();
                ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                //int count=0;
                while(rs.next()){
                    int id=rs.getInt(1);
                    int uid=rs.getInt(2);
                    String name=rs.getString(3);
                    String desc=rs.getString(4);
                    String org=rs.getString(5);
                    boolean vis=rs.getBoolean(6);
                    String imgsetting=rs.getString(7);
                    BrowserView tmpBV=new BrowserView(id,uid,name,desc,org,vis,imgsetting);
                    ret.add(tmpBV);
                    hm.put(id,tmpBV);
                    //count++;
                }
                log.debug("size:"+hm.size());
                log.debug("keys:"+hm.keySet());
                ps.close();
                ps = conn.prepareStatement(trackquery);
                rs = ps.executeQuery();
                while(rs.next()){
                    int bvid=rs.getInt(1);
                    int tid=rs.getInt(2);
                    int uid=rs.getInt(3);
                    String tclass=rs.getString(4);
                    String name=rs.getString(5);
                    String desc=rs.getString(6);
                    String org=rs.getString(7);
                    String sett=rs.getString(8);
                    int order=rs.getInt(9);
                    BrowserTrack tmpBT=new BrowserTrack(tid,uid,tclass,name,desc,org,sett,order);
                    log.debug("test:"+bvid);
                    if(hm.containsKey(bvid)){
                        log.debug("bvid found:"+bvid);
                        hm.get(bvid).addTrack(tmpBT);
                    }
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
    
    public void addTrack(BrowserTrack toAdd){
        btList.add(toAdd);
    }

    public String getImageSettings() {
        return imageSettings;
    }

    public void setImageSettings(String imageSettings) {
        this.imageSettings = imageSettings;
    }

    public int getID() {
        return id;
    }

    public void setID(int id) {
        this.id = id;
    }

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getOrganism() {
        return organism;
    }

    public void setOrganism(String organism) {
        this.organism = organism;
    }

    public boolean isVisible() {
        return visible;
    }

    public void setVisible(boolean visible) {
        this.visible = visible;
    }

    public ArrayList<BrowserTrack> getTracks() {
        return btList;
    }

    public void setTracks(ArrayList<BrowserTrack> btList) {
        this.btList = btList;
    }
    
    
    
}