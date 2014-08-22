package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.web.SessionHandler; 
import edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserView;
import java.util.ArrayList;
import javax.sql.DataSource;
import oracle.jdbc.*;
import org.apache.log4j.Logger;
import javax.servlet.http.HttpSession;

public class BrowserTools{
    private DataSource pool=null;
    private HttpSession session = null;
    
    public BrowserTools(){
        
    }
    
    public BrowserTools(HttpSession session){
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
    public ArrayList<BrowserTrack> getBrowserTracks(int userID){
        BrowserTrack bv=new BrowserTrack();
        ArrayList<BrowserTrack> ret=bv.getBrowserTracks(0,pool);
        if(userID>0){
            ArrayList<BrowserTrack> tmp=bv.getBrowserTracks(userID,pool);
            if(tmp.size()>0){
                ret.addAll(tmp);
            }
        }
        return ret;
    }
    public void createCustomTrack(int uid,String trackclass, String trackname, String description, String organism,String settings, int order,String genCat,String category,String controls,Boolean vis,String location){
        BrowserTrack bt=new BrowserTrack();
        int trackID=bt.getNextID(pool);
        BrowserTrack newTrack=new BrowserTrack(trackID, uid, trackclass, trackname, description, organism,settings, order,genCat,category,controls,vis,location);
        if(newTrack.saveToDB(pool)){
            
        }else{//error
            
        }
    }
}