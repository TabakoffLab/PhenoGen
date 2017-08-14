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
import java.util.Date;
import java.util.HashMap;
import javax.sql.DataSource;
import org.apache.log4j.Logger;

/**
 *
 * @author smahaffey
 */
public class RNAResultFile {
    private long rnaResultFileID;
    private long rnaResultID;
    private Date uploadDate;
    private String origFileName;
    private String fileName;
    private String path;
    private String checksum;
    private ArrayList<RNASample> samples;
    private RNAResult parentDSR;
    private boolean isSampleLoaded;
    
    private DataSource pool;
    private final Logger log;
    private final String select="select * from RNA_DATASET_RESULTS_FILES rdrf";
    private final String selectSampleIDs="select RNA_SAMPLE_ID from RNA_RESULTFILE_SAMPLE where RNA_DATASET_RESULT_FILE_ID=";
    
    public RNAResultFile(){
        log = Logger.getRootLogger();
    }
    
    public RNAResultFile(long rnaResultFileID,long rnaResultID,Date uploadDate,String origFileName,String fileName, String path, String checksum,DataSource pool){
        log = Logger.getRootLogger();
        this.rnaResultFileID=rnaResultFileID;
        this.rnaResultID=rnaResultID;
        this.uploadDate=uploadDate;
        this.origFileName=origFileName;
        this.fileName=fileName;
        this.path=path;
        this.checksum=checksum;
        this.pool=pool;
    }

    
    public RNAResultFile getRNAResultFile(long id, DataSource pool){
        String query=select+" where rdrf.rna_dataset_result_file_id="+id;
        return getRNAResultFileByQuery(query,pool);
    }
    public ArrayList<RNAResultFile> getRNAResultFilesByDatasetResult(long dsrid, DataSource pool){
        String query=select+" where rs.rna_dataset_result_id="+dsrid;
        return getRNAResultFilesByQuery(query,pool);
    }
    
    private RNAResultFile getRNAResultFileByQuery(String query, DataSource pool){
        RNAResultFile ret=null;
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            ResultSet rs=ps.executeQuery();
            if(rs.next()){
                ret=new RNAResultFile(rs.getInt("RNA_DATASET_RESULT_FILE_ID"),
                                    rs.getInt("RNA_DATASET_RESULT_ID"),
                                    rs.getDate("UPLOADED"),
                                    rs.getString("ORIGINAL_FILENAME"),
                                    rs.getString("FILENAME"),
                                    rs.getString("PATH"),
                                    rs.getString("CHECKSUM"),
                                    pool);
            }
            ps.close();
            conn.close();
        }catch(SQLException e){
            log.error("Error getting RNASample from \n"+query,e);
        }
        return ret;
    }
    
    public ArrayList<RNAResultFile> getRNAResultFilesByQuery(String query, DataSource pool){
        ArrayList<RNAResultFile> ret=new ArrayList<>();
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            ResultSet rs=ps.executeQuery();
            while(rs.next()){
                RNAResultFile tmp=new RNAResultFile(rs.getInt("RNA_DATASET_RESULT_FILE_ID"),
                                    rs.getInt("RNA_DATASET_RESULT_ID"),
                                    rs.getDate("UPLOADED"),
                                    rs.getString("ORIGINAL_FILENAME"),
                                    rs.getString("FILENAME"),
                                    rs.getString("PATH"),
                                    rs.getString("CHECKSUM"),
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

    
    public long getRNAResultFileID() {
        return rnaResultFileID;
    }

    public void setRNAResultFileID(long rnaResultFileID) {
        this.rnaResultFileID = rnaResultFileID;
    }

    public long getRNAResultID() {
        return rnaResultID;
    }

    public void setRNAResultID(long rnaResultID) {
        this.rnaResultID = rnaResultID;
    }

    public Date getUploadDate() {
        return uploadDate;
    }

    public void setUploadDate(Date uploadDate) {
        this.uploadDate = uploadDate;
    }

    public String getOrigFileName() {
        return origFileName;
    }

    public void setOrigFileName(String origFileName) {
        this.origFileName = origFileName;
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

    public String getChecksum() {
        return checksum;
    }

    public void setChecksum(String checksum) {
        this.checksum = checksum;
    }
    public void setDatasetResults(RNAResult parent){
        this.parentDSR=parent;
    }
    private void loadSamples(){
        samples=new ArrayList<>();
        try{
            ArrayList<RNASample> fullList=this.parentDSR.getSamples();
            HashMap<String,RNASample> hm=new HashMap<String,RNASample>();
            for(int i=0;i<fullList.size();i++){
                RNASample tmp=fullList.get(i);
                hm.put(Long.toString(tmp.getRnaSampleID()),tmp );
            }
            try(Connection conn=pool.getConnection();
                PreparedStatement ps=conn.prepareStatement(selectSampleIDs+this.rnaResultFileID)){
                ResultSet rs=ps.executeQuery();
                while(rs.next()){
                    long tmp=rs.getLong("RNA_SAMPLE_ID");
                    if(hm.containsKey(Long.toString(tmp))){
                        samples.add(hm.get(Long.toString(tmp)));
                    }
                }
            }catch(SQLException er){
                
            }
        }catch(Exception e){
            
        }
    }
}
