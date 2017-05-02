package edu.ucdenver.ccp.PhenoGen.data;


/* for logging messages */
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import javax.sql.DataSource;
import org.apache.log4j.Logger;

/**
 * Class for handling data related to filter and statistics methods applied to a version of a dataset.  
 * <br>
 *  @author  Spencer Mahaffey
 */

public class WGCNAMetaModule {
    private int wdsid;
    private int mmid;
    private int mmpid;
    private ArrayList<String> mod;
    private ArrayList<String> modColor;
    private ArrayList<WGCNAMetaModLink> links;
    
    public WGCNAMetaModule(){
        
    }
    public WGCNAMetaModule(int wdsid,int mmid,int mmpid){
        this(wdsid,mmid,mmpid,null,null);
    }
    public WGCNAMetaModule(int wdsid,int mmid,int mmpid,ArrayList<String> mod){
        this(wdsid,mmid,mmpid,mod,null);
    }
    public WGCNAMetaModule(int wdsid,int mmid,int mmpid,ArrayList<String> mod,ArrayList<String> color){
        this.wdsid=wdsid;
        this.mmid=mmid;
        this.mmpid=mmpid;
        this.mod=mod;
        this.modColor=color;
    }
    public int getWGCNADSID() {
        return wdsid;
    }

    public void setWGCNADSID(int wdsid) {
        this.wdsid = wdsid;
    }

    public int getMMID() {
        return mmid;
    }

    public void setMMID(int mmid) {
        this.mmid = mmid;
    }

    public int getMMPID() {
        return mmpid;
    }

    public void setMMPID(int mmpid) {
        this.mmpid = mmpid;
    }

    public ArrayList<String> getModNames() {
        return mod;
    }

    public void setModNames(ArrayList<String> mod) {
        this.mod = mod;
    }

    public void addModules(ArrayList<String> mods,ArrayList<String> colors){
        this.mod.addAll(mods);
        if(colors!=null){
            this.modColor.addAll(colors);
        }
    }
    
    public void addModule(String modName,String modColor){
        this.mod.add(modName);
        if(modColor!=null){
            this.modColor.add(modColor);
        }
    }
    
    public ArrayList<String> getModColors() {
        return modColor;
    }

    public void setModColors(ArrayList<String> modColor) {
        this.modColor = modColor;
    }
    
    public void addLinks(ArrayList<WGCNAMetaModLink> add){
        this.links.addAll(add);
    }
    public void addLink(WGCNAMetaModLink add){
        this.links.add(add);
    }

    public ArrayList<WGCNAMetaModLink> getLinks() {
        return links;
    }

    public void setLinks(ArrayList<WGCNAMetaModLink> links) {
        this.links = links;
    }
    
    public WGCNAMetaModule getMetaModule(DataSource pool,int mmpid){
        WGCNAMetaModule ret=null;
        Connection conn=null;
        String query="Select wm.*,wc.hex from WGCNA_META_MODULES wm, WGCNA_MODULE_COLORS wc where wm.mmpid=? and wm.module_name=wc.module";
        String query2="Select module_name1,module_name2,cor from WGCNA_META_COR wc where wc.mmpid=?";
        try{
            conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query);
            ps.setInt(1,mmpid);
            ResultSet rs=ps.executeQuery();
            ArrayList<String> tmpMod=new ArrayList<String>();
            ArrayList<String> tmpColor=new ArrayList<String>();
            if(rs.next()){
                ret=new WGCNAMetaModule(rs.getInt(1),rs.getInt(2),rs.getInt(4));
                tmpMod.add(rs.getString(3));
                tmpColor.add(rs.getString(5));
            }
            while(rs.next()){
                tmpMod.add(rs.getString(3));
                tmpColor.add(rs.getString(5));
            }
            ret.addModules(tmpMod, tmpColor);
            rs.close();
            ps.close();
            ps=conn.prepareStatement(query2);
            ps.setInt(1,mmpid);
            rs=ps.executeQuery();
            ArrayList<WGCNAMetaModLink> tmpLinks=new ArrayList<WGCNAMetaModLink>();
            while(rs.next()){
                WGCNAMetaModLink mml=new WGCNAMetaModLink(rs.getString(1),rs.getString(2),rs.getDouble(3));
                tmpLinks.add(mml);
            }
            ret.addLinks(tmpLinks);
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
        return ret;
    }
    
}

