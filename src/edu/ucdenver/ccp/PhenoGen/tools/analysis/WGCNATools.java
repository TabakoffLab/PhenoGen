package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.data.User;
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

public class WGCNATools{
    private DataSource pool=null;
    private HttpSession session = null;
    private Logger log=null;
    private String fullPath="";
    
    public WGCNATools(){
        log=Logger.getRootLogger();
    }
    
    public WGCNATools(HttpSession session){
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
    

    public ArrayList<String> getWGCNAModulesForGene(String id,String panel,String tissue,String org){
        ArrayList<String> ret=new ArrayList<String>();
        int dsid=this.getWGCNADataset(panel,tissue,org);
        String query="Select unique module from wgcna_module_info where wdsid="+dsid+" and gene_id='"+id+"'";
        log.debug("QUERY:"+query);
        Connection conn = null;
        try {
            conn = pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                ret.add(rs.getString(1));
            }
            ps.close();
            conn.close();
            conn=null;
                    
        }catch(SQLException e){
             e.printStackTrace(System.err);
            log.error("Error getting WGCNA dataset id.",e);
            Email myAdminEmail = new Email();
            String fullerrmsg=e.getMessage();
            StackTraceElement[] tmpEx=e.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown getting WGCNA dataset id");
            myAdminEmail.setContent("There was an error getting WGCNA dataset id.\n"+fullerrmsg);
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
        return ret;
    }
    
    private int getWGCNADataset(String panel, String tissue, String org) {
        Connection conn = null;
        String query="Select wdsid from WGCNA_Dataset where organism=? and tissue=? and panel=? and visible=1";
        int ret=-1;
        try {
            conn = pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1,org);
            ps.setString(2,tissue);
            ps.setString(3,panel);
            
            ResultSet rs = ps.executeQuery();
            //int count=0;
            if (rs.next()) {
                ret=rs.getInt(1);
            }
            ps.close();
            conn.close();
            conn=null;
        }catch(SQLException e){
             e.printStackTrace(System.err);
            log.error("Error getting WGCNA dataset id.",e);
            Email myAdminEmail = new Email();
            String fullerrmsg=e.getMessage();
            StackTraceElement[] tmpEx=e.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown getting WGCNA dataset id");
            myAdminEmail.setContent("There was an error getting WGCNA dataset id.\n"+fullerrmsg);
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
        return ret;
    }

}