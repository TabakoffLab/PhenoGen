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
    private String variation;
    
    private DataSource pool;
    private final Logger log;
    
    private final String select="select rdp.RNA_SAMPLE_ID,rdp.ORD,rdp.VARIATION_FROM_PROTOCOL,rp.*,rpt.PROTOCOL_TYPE "
                    + "from RNA_DS_PROTOCOLS rdp, RNA_PROTOCOLS rp, RNA_PROTOCOL_TYPE rpt "
                    + "where rdp.RNA_PROTOCOL_ID=rp.RNA_PROTOCOL_ID and rp.RNA_PROTOCOL_TYPE_ID=rpt.RNA_PROTOCOL_TYPE_ID";
     private final String insert="";
     private final String update="";
     private final String delete="delete rna_protocols where RNA_PROTOCOL_ID=?";
    private final String insertPS="Insert into RNA_DS_PROTOCOLS (RNA_SAMPLE_ID,RNA_PROTOCOL_ID,ORD,VARIATION_FROM_PROTOCOL) Values (?,?,?,?)";
    private final String updatePS="update set ORD=?,VARIATION_FROM_PROTOCOL=? where RNA_SAMPLE_ID=? and RNA_PROTOCOL_ID=?";
    private final String deleteSampleProtocol="delete RNA_DS_PROTOCOLS where RNA_SAMPLE_ID=? and RNA_PROTOCOL_ID=?";
    private final String deleteAllBySample="delete RNA_DS_PROTOCOLS where RNA_SAMPLE_ID=?";
    
    
    public RNAProtocol(){
        log = Logger.getRootLogger();
    }
    
    public RNAProtocol(long rnaSampleID,int order, String notes, long rnaProtocolID, int userID, String title, String description,
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
    
    public ArrayList<RNAProtocol> getProtocolsBySample(long rnaSampleID,DataSource pool){
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
    
    /*public boolean createRNAProtocol(RNAProtocol rp, DataSource pool){
        boolean success=false;
        this.pool=pool;
        if(rp.getRnaProtocolID()==0){
            try(Connection conn=pool.getConnection()){
                long newID=getNextID();
                PreparedStatement ps=conn.prepareStatement(insert);
                ps.setLong(1, newID);
                ps.setLong(2, rs.getRnaDatasetID());
                ps.setString(3, rs.getSampleName());
                ps.setString(4, rs.getStrain());
                ps.setString(5, rs.getAge());
                ps.setString(6, rs.getSex());
                ps.setString(7, rs.getTissue());
                ps.setString(8, rs.getSrcName());
                ps.setDate(9, rs.getSrcDate());
                ps.setString(10, rs.getSrcType());
                ps.setString(11, rs.getBreeding());
                ps.setString(12, rs.getGenoType());
                ps.setString(13,rs.getMiscDetail());
                ps.setString(14,rs.getDisease() );
                ps.setString(15,rs.getPhenotype());
                boolean tmpSuccess=ps.execute();
                rs.setRnaSampleID(newID);
                //Treatments?
                if(tmpSuccess){
                    RNATreatment myRS=new RNATreatment();
                    ArrayList<RNATreatment> rt=rs.getTreatment();
                    for(int i=0;i<rt.size()&&tmpSuccess;i++){
                        tmpSuccess=myRS.createTreatment(rt.get(i),pool);
                    }
                }
                //RawFiles?
                if(tmpSuccess){
                    RNARawDataFile myRDF=new RNARawDataFile();
                    ArrayList<RNARawDataFile> rdf=rs.getRawFiles();
                    for(int i=0;i<rdf.size()&&tmpSuccess;i++){
                        tmpSuccess=myRDF.createRawDataFile(rdf.get(i),pool);
                    }
                }
                if(tmpSuccess){
                    success=true;
                }
            }catch(Exception e){

            }
        }
        return success;
    }*/
    
    public boolean addRNAProtocolToSample(long rnaSampleID,long rnaProtocolID,int order, String variance,DataSource pool){
        boolean success=false;
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(insertPS);
            ps.setInt(1, order );
            ps.setString(2,variance);
            ps.setLong(3, rnaSampleID);
            ps.setLong(4, rnaProtocolID);
            boolean tmpSuccess=ps.execute();
            if(tmpSuccess){
                success=true;
            }
            ps.close();
        }catch(Exception e){

        }
        return success;
    }
    
    /*public boolean updateRNAProtocol(RNAProtocol rp, DataSource pool){
        boolean success=false;
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(update);
            ps.setInt(1, rs.getSampleName());
            ps.setString(2, rp.get);
            ps.setLong(14, rs.getRnaSampleID());
            int numUpdated=ps.executeUpdate();
            if(numUpdated==1){
                success=true;
            }
        }catch(Exception e){
            
        }
        return success;
    }*/
    
    public boolean updateRNASampleProtocol(long RNASampleID,long RNAProtocolID, int order,String variance,DataSource pool){
        boolean success=false;
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(updatePS);
            ps.setInt(1, order );
            ps.setString(2,variance);
            ps.setLong(3, rnaSampleID);
            ps.setLong(4, rnaProtocolID);
            int updated=ps.executeUpdate();
            if(updated==1){
                success=true;
            }
            ps.close();
        }catch(Exception e){

        }
        return success;
    }
    
    public boolean deleteRNAProtocol(long rnaProtocolID, DataSource pool){
        boolean success=false;
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(delete);
            ps.setLong(1, rnaProtocolID);
            boolean tmpSuccess=ps.execute();
            if(tmpSuccess){
                success=true;
            }
            ps.close();
        }catch(Exception e){
            
        }
        return success;
    }
    public boolean deleteRNAProtocolFromSample(long rnaSampleID,long rnaProtocolID, DataSource pool){
        boolean success=false;
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(deleteSampleProtocol);
            ps.setLong(1, rnaSampleID);
            ps.setLong(2, rnaProtocolID);
            boolean tmpSuccess=ps.execute();
            if(tmpSuccess){
                success=true;
            }
            ps.close();
        }catch(Exception e){
            
        }
        return success;
    }
    public boolean deleteRNAProtocolsFromSample(long rnaSampleID, DataSource pool){
        boolean success=false;
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(deleteAllBySample);
            ps.setLong(1, rnaSampleID);
            boolean tmpSuccess=ps.execute();
            if(tmpSuccess){
                success=true;
            }
            ps.close();
        }catch(Exception e){
            
        }
        return success;
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

    public String getVariation() {
        return variation;
    }

    public void setVariation(String variation) {
        this.variation = variation;
    }
    
    
    
}
