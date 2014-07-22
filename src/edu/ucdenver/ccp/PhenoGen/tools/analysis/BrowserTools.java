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
    
}