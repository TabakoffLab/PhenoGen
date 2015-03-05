package edu.ucdenver.ccp.PhenoGen.data.internal;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.data.User;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.ObjectHandler;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import javax.sql.DataSource;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling the resources available for downloading
 *  @author  Cheryl Hornbaker
 */

public class SharedFiles {

	private Logger log=null;

	public SharedFiles(){
            log = Logger.getRootLogger();
        }
        
        public ArrayList<GenericSharedFile> getMyFiles(HttpSession session){
            User curUser=(User)session.getAttribute("userLoggedIn");
            DataSource pool=(DataSource) session.getAttribute("dbPool");
            String contextRoot = (String) session.getAttribute("contextRoot");
            String appRoot = (String) session.getAttribute("applicationRoot");
            ArrayList<GenericSharedFile> ret=new ArrayList<GenericSharedFile>();
            if(!curUser.getUser_name().equals("anon")){
                String query="Select * from Files f where f.Owner_UID="+curUser.getUser_id()+" order by f.created desc";
                log.debug("getMyFiles:"+query);
                Connection conn=null;
                try{
                    conn=pool.getConnection();
                    
                    PreparedStatement ps = conn.prepareStatement(query);
                    ResultSet rs = ps.executeQuery();
                    //int count=0;
                    while(rs.next()){
                        int fileID=rs.getInt(1);
                        Timestamp created=rs.getTimestamp(3);
                        boolean shared=false;
                        boolean shareAll=false;
                        if(rs.getInt(4)==1){
                            shared=true;
                        }
                        if(rs.getInt(5)==1){
                            shareAll=true;
                        }
                        String path=rs.getString(6);
                        String desc=rs.getString(7);
                        GenericSharedFile gsf=new GenericSharedFile(fileID,curUser,created,shared,shareAll,path,desc);
                        ret.add(gsf);
                    }
                    ps.close();
                    conn.close();
                    conn=null;
                }catch(SQLException e){
                    log.error("ERROR:getMyFiles()",e);
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
            return ret;
        }
        public ArrayList<GenericSharedFile> getFilesSharedWithMe(HttpSession session){
            User curUser=(User)session.getAttribute("userLoggedIn");
            DataSource pool=(DataSource) session.getAttribute("dbPool");
            String contextRoot = (String) session.getAttribute("contextRoot");
            String appRoot = (String) session.getAttribute("applicationRoot");
            ArrayList<GenericSharedFile> ret=new ArrayList<GenericSharedFile>();
            if(!curUser.getUser_name().equals("anon")){
                String query="Select f.*,u.user_id,u.first_name,u.last_name from Files f, users u  where u.user_id=f.Owner_UID and ((f.shared=1 and f.file_id in (Select file_id from files_shared where user_id="+curUser.getUser_id()+") )or (f.all_users=1 and f.Owner_UID<>"+curUser.getUser_id()+")) order by f.created desc";
                Connection conn=null;
                log.debug("getSharedFiles:"+query);
                try{
                    conn=pool.getConnection();
                    
                    PreparedStatement ps = conn.prepareStatement(query);
                    ResultSet rs = ps.executeQuery();
                    //int count=0;
                    while(rs.next()){
                        int fileID=rs.getInt(1);
                        Timestamp created=rs.getTimestamp(3);
                        boolean shared=false;
                        boolean shareAll=false;
                        if(rs.getInt(4)==1){
                            shared=true;
                        }
                        if(rs.getInt(5)==1){
                            shareAll=true;
                        }
                        String path=rs.getString(6);
                        String desc=rs.getString(7);
                        User newUser = new User(rs.getInt(8));
			newUser.setFirst_name(rs.getString(9));
			newUser.setLast_name(rs.getString(10));
                        GenericSharedFile gsf=new GenericSharedFile(fileID,newUser,created,shared,shareAll,path,desc);
                        ret.add(gsf);
                    }
                    ps.close();
                    conn.close();
                    conn=null;
                }catch(SQLException e){
                    log.error("ERROR:getSharedFiles()",e);
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
            return ret;
        }
        
        public boolean toggleFileShare(int fid,boolean all,HttpSession session){
            boolean success=false;
            User curUser=(User)session.getAttribute("userLoggedIn");
            DataSource pool=(DataSource) session.getAttribute("dbPool");
            String editColumn="shared";
            if(all){
                editColumn="all_users";
            }
            if(!curUser.getUser_name().equals("anon")){
                String query="Select "+editColumn+" from Files f where f.file_id = "+fid+" and f.owner_uid="+curUser.getUser_id();
                String update="Update files set "+editColumn+"=? where file_id="+fid;
                Connection conn=null;
                log.debug("getSharedFiles:"+query);
                try{
                    conn=pool.getConnection();
                    PreparedStatement ps = conn.prepareStatement(query);
                    ResultSet rs = ps.executeQuery();
                    //int count=0;
                    if(rs.next()){
                        int cur=rs.getInt(1);
                        int next=1;
                        if(cur>0){
                            next=0;
                        }
                        PreparedStatement us = conn.prepareStatement(update);
                        us.setInt(1, next);
                        int updated=us.executeUpdate();
                        if(updated==1){
                            success=true;
                        }
                        us.close();
                    }
                    ps.close();
                    conn.close();
                    conn=null;
                }catch(SQLException e){
                    log.error("ERROR:toggleFileShare()",e);
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
            return success;
        }
        public boolean getFileShareStatus(int fid,boolean all,HttpSession session){
            boolean status=false;
            User curUser=(User)session.getAttribute("userLoggedIn");
            DataSource pool=(DataSource) session.getAttribute("dbPool");
            String editColumn="shared";
            if(all){
                editColumn="all_users";
            }
            if(!curUser.getUser_name().equals("anon")){
                String query="Select "+editColumn+" from Files f where f.file_id = "+fid+" and f.owner_uid="+curUser.getUser_id();
                Connection conn=null;
                try{
                    conn=pool.getConnection();
                    PreparedStatement ps = conn.prepareStatement(query);
                    ResultSet rs = ps.executeQuery();
                    //int count=0;
                    if(rs.next()){
                        int cur=rs.getInt(1);
                        if(cur>0){
                            status=true;
                        }
                    }
                    ps.close();
                    conn.close();
                    conn=null;
                }catch(SQLException e){
                    log.error("ERROR:toggleFileShare()",e);
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
            return status;
        }
        public boolean deleteFile(int fid,HttpSession session){
            boolean success=false;
            User curUser=(User)session.getAttribute("userLoggedIn");
            DataSource pool=(DataSource) session.getAttribute("dbPool");
            String userFilesRoot=(String) session.getAttribute("userFilesRoot");
            if(!curUser.getUser_name().equals("anon")){
                String query="Select location from files f where f.file_id = "+fid+" and f.owner_uid="+curUser.getUser_id();
                String query1="delete from Files_Shared f where f.file_id = "+fid;
                String query2="delete from Files f where f.file_id = "+fid+" and f.owner_uid="+curUser.getUser_id();
                Connection conn=null;
                try{
                    conn=pool.getConnection();
                    conn.setAutoCommit(false);
                    PreparedStatement ps = conn.prepareStatement(query);
                    ResultSet rs=ps.executeQuery();
                    if(rs.next()){
                        String path=rs.getString(1);
                        //add full path before manipulating path
                        path=userFilesRoot+path;
                        //get path parts
                        String fName=path.substring(path.lastIndexOf("/")+1);
                        String newPath=path.substring(0,path.lastIndexOf("/")+1);
                        newPath=newPath+"toDelete/";
                        
                        log.debug("NewPath:"+newPath);
                        File dirs=new File(newPath);
                        if(!dirs.exists()){
                            dirs.mkdirs();
                        }
                        log.debug("src:"+path);
                        log.debug("dest:"+newPath+fName);
                        File src=new File(path);
                        File dest=new File(newPath+fName);
                        src.renameTo(dest);
                        
                        PreparedStatement ps2 = conn.prepareStatement(query1);
                        ps2.executeUpdate();
                        ps2.close();
                        ps2 = conn.prepareStatement(query2);
                        int delete = ps2.executeUpdate();
                        ps2.close();
                        conn.commit();
                        if(delete==1){
                            success=true;
                        }
                    }
                    ps.close();
                    conn.close();
                    conn=null;
                }catch(SQLException e){
                    log.error("ERROR:deleteFile()",e);
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
            return success;
        }
        
        public boolean updateSharedWith(int fid,String list,HttpSession session){
            boolean success=false;
            User curUser=(User)session.getAttribute("userLoggedIn");
            DataSource pool=(DataSource) session.getAttribute("dbPool");
            String[] idList=list.split(",");
            if(!curUser.getUser_name().equals("anon")){
                String queryCheck="select owner_uid from files f where f.file_id="+fid;
                String query1="delete from Files_Shared f where f.file_id = "+fid;
                String query2="Insert into Files_shared (file_id,user_id) values (?,?)";
                Connection conn=null;
                try{
                    conn=pool.getConnection();
                    conn.setAutoCommit(false);
                    PreparedStatement psTest = conn.prepareStatement(queryCheck);
                    ResultSet rsTest=psTest.executeQuery();
                    int ownerUID=0;
                    if(rsTest.next()){
                        ownerUID=rsTest.getInt(1);
                    }
                    psTest.close();
                    if(ownerUID==curUser.getUser_id()){
                        PreparedStatement ps = conn.prepareStatement(query1);
                        int deleted=ps.executeUpdate();
                        ps.close();

                        for(int i=0;i<idList.length;i++){
                            int uid=Integer.parseInt(idList[i]);
                            PreparedStatement ps2 = conn.prepareStatement(query2);
                            ps2.setInt(1, fid);
                            ps2.setInt(2, uid);
                            ps2.executeUpdate();
                            ps2.close();
                        }
                        conn.commit();
                        success=true;
                    }
                    conn.close();
                    conn=null;
                }catch(SQLException e){
                    log.error("ERROR:updateSharedWith()",e);
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
            return success;
        }
        
        public String getSharedUsers(int fid,HttpSession session){
            String ret="";
            User curUser=(User)session.getAttribute("userLoggedIn");
            DataSource pool=(DataSource) session.getAttribute("dbPool");
            if(!curUser.getUser_name().equals("anon")){
                String query1="Select user_id from Files_Shared f where f.file_id = "+fid;
                Connection conn=null;
                try{
                    conn=pool.getConnection();
                    
                    PreparedStatement ps = conn.prepareStatement(query1);
                    ResultSet rs=ps.executeQuery();
                    boolean first=true;
                    while(rs.next()){
                        if(first){
                            ret=Integer.toString(rs.getInt(1));
                            first=false;
                        }else{
                            ret=ret+","+rs.getInt(1);
                        }
                    }
                    ps.close();
                    conn.close();
                    conn=null;
                }catch(SQLException e){
                    log.error("ERROR:getSharedWith()",e);
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
            return ret;
        }
}
