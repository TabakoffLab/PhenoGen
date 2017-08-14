/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.ucdenver.ccp.PhenoGen.data.RNASeq;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import javax.sql.DataSource;
import org.apache.log4j.Logger;

/**
 *
 * @author smahaffey
 */
public class RNAProtocol {
    private long rnaSampleID;
    private int order;
    private String notes;
    private long rnaProtocolID;
    private int userID;
    private String title;
    private String description;
    private String version;
    private String fileName;
    private String path;
    private String prevVer;
    private String type;
    
    private DataSource pool;
    private final Logger log;
    
    private final String select="select rdp.RNA_SAMPLE_ID,rdp.ORD,rdp.VARIATION_FROM_PROTOCOL,rp.*,rpt.PROTOCOL_TYPE "
                    + "from RNA_DS_PROTOCOLS rdp, RNA_PROTOCOLS rp, RNA_PROTOCOL_TYPE rpt "
                    + "where rdp.RNA_PROTOCOL_ID=rp.RNA_PROTOCOL_ID and rp.RNA_PROTOCOL_TYPE_ID=rpt.RNA_PROTOCOL_TYPE_ID";
    
    
    public RNAProtocol(){
        log = Logger.getRootLogger();
    }
    
    public RNAProtocol(int rnaSampleID,int order, String notes, int rnaProtocolID, int userID, String title, String description,
            String version, String fileName, String path, String prevVersion, String type, DataSource pool ){
        log = Logger.getRootLogger();
        this.setRnaSampleID(rnaSampleID);
        this.setOrder(order);
        this.setNotes(notes);
        this.setRnaProtocolID(rnaProtocolID);
        this.setUserID(userID);
        this.setTitle(title);
        this.setDescription(description);
        this.setVersion(version);
        this.setFileName(fileName);
        this.setPath(path);
        this.setPrevVer(prevVer);
        this.setType(type);
        this.pool=pool;
    }
    
    public ArrayList<RNAProtocol> getProtocolBySample(int rnaSampleID,DataSource pool){
        String query=select+" and rdp.rna_sample_id="+rnaSampleID;
        return getRNAProtocolsByQuery(query,pool);
    }
    
    public ArrayList<RNAProtocol> getRNAProtocolsByQuery(String query, DataSource pool){
        ArrayList<RNAProtocol> ret=new ArrayList<>();
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            
            ResultSet rs=ps.executeQuery();
            while(rs.next()){
                RNAProtocol tmp=new RNAProtocol(rs.getInt("RNA_SAMPLE_ID"),
                                    rs.getInt("ORD"),
                                    rs.getString("VARIATION_FROM_PROTOCOL"),
                                    rs.getInt("RNA_PROTOCOL_ID"),
                                    rs.getInt("USER_ID"),
                                    rs.getString("TITLE"),
                                    rs.getString("DESCRIPTION"),
                                    rs.getString("VER"),
                                    rs.getString("FILENAME"),
                                    rs.getString("PATH"),
                                    rs.getString("PREVIOUS_VERSION"),
                                    rs.getString("PROTOCOL_TYPE"),
                                    pool);
                ret.add(tmp);
            }
            ps.close();
            conn.close();
        }catch(SQLException e){
            log.error("Error getting RNADataset from \n"+query,e);
        }
        return ret;
    }

    public long getRnaSampleID() {
        return rnaSampleID;
    }

    public void setRnaSampleID(long rnaSampleID) {
        this.rnaSampleID = rnaSampleID;
    }

    public int getOrder() {
        return order;
    }

    public void setOrder(int order) {
        this.order = order;
    }

    public long getRnaProtocolID() {
        return rnaProtocolID;
    }

    public void setRnaProtocolID(long rnaProtocolID) {
        this.rnaProtocolID = rnaProtocolID;
    }

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getPrevVer() {
        return prevVer;
    }

    public void setPrevVer(String prevVer) {
        this.prevVer = prevVer;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
    
}
