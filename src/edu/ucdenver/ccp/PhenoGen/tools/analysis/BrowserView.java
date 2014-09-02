package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserTrack;
import edu.ucdenver.ccp.PhenoGen.web.mail.*;
import edu.ucdenver.ccp.PhenoGen.web.SessionHandler;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
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
                        " and bt.visible=1 "+
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
                    String genCat=rs.getString(8);
                    String cat=rs.getString(9);
                    String controls=rs.getString(10);
                    boolean vis=rs.getBoolean(11);
                    String location=rs.getString(12);
                    Timestamp ts=rs.getTimestamp(13);
                    String file=rs.getString(14);
                    String type=rs.getString(15);
                    String sett=rs.getString(16);
                    int order=rs.getInt(17);
                    BrowserTrack tmpBT=new BrowserTrack(tid,uid,tclass,name,desc,org,sett,order,genCat,cat,controls,vis,location,file,type,ts);
                    if(hm.containsKey(bvid)){
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
    
    
    public int getNextID(DataSource pool){
        int id=-1;
        String query="select Browser_View_ID_SEQ.nextVal from dual";
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
    public int getNextTrackSettingID(DataSource pool){
        int id=-1;
        String query="select Browser_TrackSetting_ID_SEQ.nextVal from dual";
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
        String insertUsage="insert into browser_views ("
                + "BVID,USER_ID,NAME,DESCRIPTION,ORGANISM,"
                + "VISIBLE,IMAGE_SETTINGS) values (?,?,?,?,?,?,?)";
        Connection conn=null;
        try{
            conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(insertUsage, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
            ps.setInt(1, this.id);
            ps.setInt(2,this.userID);
            ps.setString(3, name);
            ps.setString(4, this.description);
            ps.setString(5, this.organism);
            ps.setBoolean(6,this.visible);
            ps.setString(7, this.imageSettings);
            ps.execute();
            ps.close();
            conn.close();
            conn=null;
            success=true;
        }catch(SQLException e){
            e.printStackTrace(System.err);
            Logger log = Logger.getRootLogger();
            log.error("Error inserting new View:",e);
            Email myAdminEmail = new Email();
            String fullerrmsg=e.getMessage();
            StackTraceElement[] tmpEx=e.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown inserting a custom track");
            myAdminEmail.setContent("There was an error inserting a custom track.\n"+fullerrmsg);
            try {
                    myAdminEmail.sendEmailToAdministrator("");
            } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    throw new RuntimeException();
            }
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
    public boolean copyTracksInView(int source,int dest,DataSource pool){
            boolean success=false;
            String query="select * from BROWSER_VIEWS_TRACKS "+
                        "where bvid="+source;
            String insert="insert into BROWSER_VIEWS_TRACKS (BVID,TRACKID,TRACKSETTINGID,ORDERING) VALUES (?,?,?,?)";
            
            Connection conn=null;
            PreparedStatement ps=null;
           try{
                conn=pool.getConnection();
                PreparedStatement insertBVT=conn.prepareStatement(insert, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
                ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                //int count=0;
                while(rs.next()){
                    int tid=rs.getInt(2);
                    int tsid=rs.getInt(3);
                    int order=rs.getInt(4);
                    int newTSID=-1;
                    boolean copied=false;
                    int preventLooping=0;
                    while(!copied && preventLooping<20){
                        newTSID=getNextTrackSettingID(pool);
                        copied=copyTrackSettings(tsid,newTSID,conn);
                        preventLooping++;
                    }
                    if(copied && newTSID>0){
                        insertBVT.setInt(1, dest);
                        insertBVT.setInt(2, tid);
                        insertBVT.setInt(3, newTSID);
                        insertBVT.setInt(4, order);
                        insertBVT.execute();
                        insertBVT.clearParameters();
                    }
                }
                insertBVT.close();
                ps.close();
                conn.close();
                conn=null;
                success=true;
            }catch(SQLException e){
                e.printStackTrace(System.err);
                Logger log = Logger.getRootLogger();
                log.error("Error copying View:",e);
                Email myAdminEmail = new Email();
                String fullerrmsg=e.getMessage();
                StackTraceElement[] tmpEx=e.getStackTrace();
                for(int i=0;i<tmpEx.length;i++){
                            fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                }
                myAdminEmail.setSubject("Exception thrown inserting a copied view");
                myAdminEmail.setContent("There was an error inserting a copied view.\n"+fullerrmsg);
                try {
                        myAdminEmail.sendEmailToAdministrator("");
                } catch (Exception mailException) {
                        log.error("error sending message", mailException);
                        throw new RuntimeException();
                }
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
        
    public boolean copyTrackSettings(int source,int dest,Connection conn){
        boolean success=false;
        try{
            String query="select * from BROWSER_TRACK_SETTINGS "+
                        "where tracksettingid="+source;
            String insert="insert into BROWSER_TRACK_SETTINGS (TRACKSETTINGID,SETTINGS) VALUES (?,?)";
            PreparedStatement ps=null;
                PreparedStatement insertBTS=conn.prepareStatement(insert, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
                ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                //int count=0;
                if(rs.next()){
                    String settings=rs.getString(2);
                    insertBTS.setInt(1, dest);
                    insertBTS.setString(2, settings);
                    insertBTS.execute();
                    insertBTS.close();
                }
                ps.close();
                success=true;
        }catch(SQLException e){
             e.printStackTrace(System.err);
            Logger log = Logger.getRootLogger();
            log.error("Error copying track settings:",e);
            Email myAdminEmail = new Email();
            String fullerrmsg=e.getMessage();
            StackTraceElement[] tmpEx=e.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown inserting a track setting");
            myAdminEmail.setContent("There was an error inserting a track setting.\n"+fullerrmsg);
            try {
                    myAdminEmail.sendEmailToAdministrator("");
            } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    throw new RuntimeException();
            }
        }
        return success;
    }
}