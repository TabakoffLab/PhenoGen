package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserView;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.web.SessionHandler;
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
    }
    
    public ArrayList<BrowserView> getBrowserViews(int userID){
        BrowserView bv=new BrowserView();
        ArrayList<BrowserView> ret=bv.getBrowserViews(0,pool);
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
}