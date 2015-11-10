/*
 * author:Spencer Mahaffey
 * date: 11/13/12
 * Stores data for Demo Vidoes(eg. Path, description, title, etc.)  
 * To avoid dependence on the DB it will read demo data from a file. web/demo/demo.xml
 */
package edu.ucdenver.ccp.PhenoGen.web;


import javax.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import javax.sql.DataSource;

import org.apache.log4j.Logger;

public class Demo {
    String title="";
    String fileBase="";
    String description="";
    String category="";
    String formats="";
    String time="";
    boolean defaultVideo=false;
    Logger log;
    
    public Demo(){
        log = Logger.getRootLogger();
    }
    
    public Demo(String title,String fileBase,String description,String category,String formats,String time, boolean defaultVideo){
        this.title=title;
        this.fileBase=fileBase;
        this.description=description;
        this.category=category;
        this.formats=formats;
        this.defaultVideo=defaultVideo;
        this.time=time;
    }
    
    public HashMap getAllDemos(DataSource pool){
        HashMap ret=new HashMap();
        String query="select * from demo_files where visible=1";
        try{
            Connection conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                    String title=rs.getString(1);
                    String fileBase=rs.getString(2);
                    String desc=rs.getString(3);
                    String category=rs.getString(4);
                    String formats=rs.getString(5);
                    int defInt=rs.getInt(7);
                    String time=rs.getString(8);
                    boolean def=false;
                    if(defInt==1){
                        def=true;
                    }
                    Demo tmp=new Demo(title,fileBase,desc,category,formats,time,def);
                    if(ret.containsKey(category)){
                        ArrayList<Demo> tmpList=(ArrayList<Demo>)ret.get(category);
                        tmpList.add(tmp);
                    }else{
                        ArrayList<Demo> tmpList=new ArrayList<Demo>();
                        tmpList.add(tmp);
                        ret.put(category, tmpList);
                    }
            }
            ps.close();
            
            try{
                conn.close();
            }catch(Exception e){}
            
        }catch(SQLException e){
            log.error("Error getting Demos.",e);
        }
        return ret;
    }
    
    public ArrayList<String> getAllDemoCategories(DataSource pool){
        ArrayList<String> ret=new ArrayList<String>();
        String query="select unique category from demo_files where visible=1";
        try{
            Connection conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                  String tmp=rs.getString(1);
                  ret.add(tmp);
            }
            ps.close();
            try{
                conn.close();
            }catch(Exception e){}
        }catch(SQLException e){
            log.error("Error getting Demo categories.",e);
        }
        return ret;
    }

    public String getTitle() {
        return title;
    }

    public String getFileBase() {
        return fileBase;
    }

    public String getDescription() {
        return description;
    }

    public String getCategory() {
        return category;
    }

    public String getFormats() {
        return formats;
    }

    public String getTime() {
        return time;
    }

    public boolean isDefaultVideo() {
        return defaultVideo;
    }
    
    
}
