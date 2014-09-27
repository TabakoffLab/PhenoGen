package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserView;
import edu.ucdenver.ccp.PhenoGen.web.SessionHandler;
import edu.ucdenver.ccp.PhenoGen.web.mail.*;
import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;
import oracle.jdbc.*;
import org.apache.log4j.Logger;

public class BrowserTools{
    private DataSource pool=null;
    private HttpSession session = null;
    private Logger log=null;
    private String fullPath="";
    
    public BrowserTools(){
        log=Logger.getRootLogger();
    }
    
    public BrowserTools(HttpSession session){
        log=Logger.getRootLogger();
        this.session=session;
        this.pool= (DataSource) session.getAttribute("dbPool");
    }
    
    public void setSession(HttpSession session){
        this.session=session;
        this.pool= (DataSource) session.getAttribute("dbPool");
        String contextRoot = (String) session.getAttribute("contextRoot");
        String appRoot = (String) session.getAttribute("applicationRoot");
        this.fullPath = appRoot + contextRoot;
    }
    
    public ArrayList<BrowserView> getBrowserViews(){
        BrowserView bv=new BrowserView();
        ArrayList<BrowserView> ret=bv.getBrowserViews(0,pool);
        int userID=((User)session.getAttribute("userLoggedIn")).getUser_id();
        if(userID>0){
            ArrayList<BrowserView> tmp=bv.getBrowserViews(userID,pool);
            if(tmp.size()>0){
                ret.addAll(tmp);
            }
        }
        return ret;
    }
    public ArrayList<BrowserTrack> getBrowserTracks(){
        BrowserTrack bv=new BrowserTrack();
        ArrayList<BrowserTrack> ret=bv.getBrowserTracks(0,pool);
        int userID=((User)session.getAttribute("userLoggedIn")).getUser_id();
        log.debug("getBROWSERTRACK():uid:"+userID);
        if(userID>0){
            ArrayList<BrowserTrack> tmp=bv.getBrowserTracks(userID,pool);
            if(tmp.size()>0){
                ret.addAll(tmp);
            }
        }
        return ret;
    }
    public boolean createCustomTrack(int uid,String trackclass, String trackname, String description, String organism,String settings, int order,String genCat,String category,String controls,Boolean vis,String location,String fileName,String type){
        BrowserTrack bt=new BrowserTrack();
        int trackID=bt.getNextID(pool);
        BrowserTrack newTrack=new BrowserTrack(trackID, uid, trackclass, trackname, description, organism,settings, order,genCat,category,controls,vis,location,fileName,type,new Timestamp((new Date()).getTime()));
        boolean success=newTrack.saveToDB(pool);
        return success;
    }
    
    public int createBlankView(String name,String description,String organism,String imgDisp){
        BrowserView bv= new BrowserView();
        int ret=-1;
        int viewID=bv.getNextID(pool);
        int userID=((User)session.getAttribute("userLoggedIn")).getUser_id();
        BrowserView newView=new BrowserView(viewID,userID,name,description,organism.toUpperCase(),true,imgDisp);
        boolean success=newView.saveToDB(pool);
        if(success){
            ret=viewID;
        }
        return ret;
    }
    public int createCopiedView(String name,String description,String organism,String imgDisp,int copyFrom){
        BrowserView bv= new BrowserView();
        int ret=-1;
        int viewID=bv.getNextID(pool);
        int userID=((User)session.getAttribute("userLoggedIn")).getUser_id();
        BrowserView newView=new BrowserView(viewID,userID,name,description,organism.toUpperCase(),true,imgDisp);
        boolean success=newView.saveToDB(pool);
        //copy tracks and settings
        if(success){
           success=bv.copyTracksInView(copyFrom,newView.getID(),pool);
        }
        if(success){
            ret=viewID;
        }
        return ret;
    }
    
    public String updateView(int id,String tracks){
        String ret="";
        BrowserView bv= new BrowserView();
        BrowserView toUpdate=bv.getBrowserView(id,pool);
        int userID=((User)session.getAttribute("userLoggedIn")).getUser_id();
        if(toUpdate!=null){
            if(toUpdate.getUserID()==userID&&toUpdate.getUserID()>0){
                toUpdate.updateTracks(tracks,pool);
            }else{
                ret="Edit View:Permission Denied";
            }
        }else{
            ret="View not found.";
        }
        return ret;
    }
    
    public String deleteBrowserView(int id){
        String ret="";
        BrowserView bv= new BrowserView();
        BrowserView toDelete=bv.getBrowserView(id,pool);
        int userID=((User)session.getAttribute("userLoggedIn")).getUser_id();
        if(toDelete!=null){
            if(toDelete.getUserID()==userID&&toDelete.getUserID()>0){
                boolean success=bv.deleteView(id,pool);
                if(success){
                    ret="Deleted Successfully";
                }else{
                    ret="An Error occurred the view was not deleted.";
                }
            }else{
                ret="Delete View:Permission Denied";
            }
        }else{
            ret="View not found.";
        }
        return ret;
    }
    
    public void addViewCount(int id){
        String update="update browser_view_counts set counter=(counter+1) where bvid="+id;
        Connection conn=null;
        try{
            conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(update, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
            ps.execute();
            ps.close();
            conn.close();
            conn=null;
        }catch(SQLException e){
            e.printStackTrace(System.err);
            Logger log = Logger.getRootLogger();
            log.error("Error incrementing BrowserViewCount",e);
            Email myAdminEmail = new Email();
            String fullerrmsg=e.getMessage();
            StackTraceElement[] tmpEx=e.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown incrementing BrowserViewCount");
            myAdminEmail.setContent("There was an error incrementing BrowserViewCount.\n"+fullerrmsg);
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
    }
    
    public String deleteCustomTrack(int id){
        String ret="";
        BrowserTrack bt= new BrowserTrack();
        BrowserTrack toDelete=bt.getBrowserTrack(id,pool);
        int userID=((User)session.getAttribute("userLoggedIn")).getUser_id();
        if(toDelete!=null){
            if(toDelete.getUserID()==userID&&toDelete.getUserID()>0){
                boolean success=bt.deleteTrack(id,pool);
                if(success){
                    ret="Deleted Successfully";
                    if(toDelete.getType().equals("bed")||toDelete.getType().equals("bg")){
                        //delete files too
                        File source=new File(fullPath+"tmpData/trackUpload/"+toDelete.getLocation());
                        File dest=new File(fullPath+"tmpData/toDelete/"+toDelete.getLocation());
                        source.renameTo(dest);
                    }
                }else{
                    ret="An Error occurred the track was not deleted.";
                }
            }else{
                ret="Delete View:Permission Denied";
            }
        }else{
            ret="View not found.";
        }
        return ret;
    }
}