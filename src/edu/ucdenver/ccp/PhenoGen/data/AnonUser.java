package edu.ucdenver.ccp.PhenoGen.data;


import java.sql.Date;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to managing anonymous users. 
 *  @author  Spencer Mahaffey
 */

public class AnonUser{
    String uuid="";
    String email="";
    Date created=null;
    Date last_access=null;
    int access_count=0;

    private Logger log=null;


    public AnonUser () {
          log = Logger.getRootLogger();
    }

    public String getUUID() {
        return uuid;
    }

    public void setUUID(String uuid) {
        this.uuid = uuid;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        if(email!=null && !email.equals("null")){
            this.email = email;
        }
    }
    
    public String getObfuscatedEmail(){
        String oEmail="";
        int atInd=email.indexOf("@");
        if( atInd>-1 ){
            oEmail=email.substring(0, 1);
            for(int i=1;i<atInd;i++){
                oEmail+="*";
            }
            oEmail+=email.substring(atInd);
        }
        return oEmail;
    }

    public Date getCreated() {
        return created;
    }

    public void setCreated(Date created) {
        this.created = created;
    }

    public Date getLast_access() {
        return last_access;
    }

    public void setLast_access(Date last_access) {
        this.last_access = last_access;
    }

    public int getAccess_count() {
        return access_count;
    }

    public void setAccess_count(int access_count) {
        this.access_count = access_count;
    }
  
  
  
  public AnonUser createAnonUser(String uuid, DataSource pool){
      String insert="insert into ANON_USERS (UUID,CREATED,LAST_ACCESS,ACCESS_COUNT) VALUES (?,?,?,?)";
      Connection conn=null;
      try{
          conn=pool.getConnection();
          Date created=new Date((new java.util.Date()).getTime());
          Date access=created;
          int count=1;
          PreparedStatement ps=conn.prepareStatement(insert);
          ps.setString(1, uuid);
          ps.setDate(2, created);
          ps.setDate(3, access);
          ps.setInt(4, count);

          ps.execute();
          conn.close();
          conn=null;
      }catch(SQLException e){
          
      }finally{
          try{
              if(conn!=null && !conn.isClosed()){
                  conn.close();
                  conn=null;
              }
          }catch(Exception e){}
      }
      return this.getAnonUser(uuid, pool);
  }
  
  public AnonUser linkEmail(String uuid,String email, DataSource pool){
      String update="update ANON_USERS set EMAIL = ? where UUID=?";
      String checkEmail="select email from Anon_Users where UUID=?";
      Connection conn=null;
      try{
          conn=pool.getConnection();
          PreparedStatement ps=conn.prepareStatement(checkEmail);
          ps.setString(1, uuid);
          ResultSet rs=ps.executeQuery();
          if(rs.next()){
              if(rs.getString(1)==null){
                    PreparedStatement ps2=conn.prepareStatement(update);
                    ps2.setString(1, email);
                    ps2.setString(2, uuid);
                    ps2.execute();
                    ps2.close();
              }
          }
          rs.close();
          ps.close();
          conn.close();
          conn=null;
      }catch(SQLException e){
          
      }finally{
          try{
              if(conn!=null && !conn.isClosed()){
                  conn.close();
                  conn=null;
              }
          }catch(Exception e){}
      }
      return this.getAnonUser(uuid, pool);
  }
  
  
  public void linkGeneList(int glID, DataSource pool) throws SQLException{
      String insert="insert into ANON_USER_GENELIST (UUID,GENELIST_ID) VALUES (?,?)";
      Connection conn=null;
      try{
          conn=pool.getConnection();
          PreparedStatement ps=conn.prepareStatement(insert);
          ps.setString(1, uuid);
          ps.setInt(2, glID);

          ps.execute();
          conn.close();
          conn=null;
      }catch(SQLException e){
          throw e;
      }finally{
          try{
              if(conn!=null && !conn.isClosed()){
                  conn.close();
                  conn=null;
              }
          }catch(Exception e){}
      }
  }
  
  public AnonUser getAnonUser(String uuid, DataSource pool){
      AnonUser ret=null;
      String select="select * from ANON_USERS where uuid=?";
      Connection conn=null;
      try{
          conn=pool.getConnection();
          PreparedStatement ps=conn.prepareStatement(select);
          ps.setString(1, uuid);
          ResultSet rs=ps.executeQuery();
          if(rs.next()){
              ret=new AnonUser();
              ret.setUUID(rs.getString("UUID"));
              ret.setCreated(rs.getDate("CREATED"));
              ret.setLast_access(rs.getDate("LAST_ACCESS"));
              ret.setAccess_count(rs.getInt("ACCESS_COUNT"));
              ret.setEmail(rs.getString("EMAIL"));
          }
          rs.close();
          ps.close();
          conn.close();
          conn=null;
      }catch(SQLException e){
          
      }finally{
          try{
              if(conn!=null && !conn.isClosed()){
                  conn.close();
                  conn=null;
              }
          }catch(Exception e){}
      }
      
      return ret;
  }

  public ArrayList<String> getAnonSessionListByEmail(String email,DataSource pool){
      ArrayList<String> list= new ArrayList<String>();
      String select="select uuid from ANON_USERS where email=?";
      Connection conn=null;
      try{
          conn=pool.getConnection();
          PreparedStatement ps=conn.prepareStatement(select);
          ps.setString(1, email);
          ResultSet rs=ps.executeQuery();
          while(rs.next()){
              list.add(rs.getString("uuid"));
          }
          rs.close();
          ps.close();
          conn.close();
          conn=null;
      }catch(SQLException e){
          
      }finally{
          try{
              if(conn!=null && !conn.isClosed()){
                  conn.close();
                  conn=null;
              }
          }catch(Exception e){}
      }
      return list;
  }
  
}