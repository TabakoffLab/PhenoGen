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
import java.sql.Date;
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
    private final String insert="Insert into RNA_DATASET_RESULTS_FILES (RNA_DATASET_RESULT_FILE_ID,RNA_DATASET_RESULT_ID,UPLOADED,ORIGINAL_FILENAME,FILENAME,PATH,CHECKSUM) Values (?,?,?,?,?,?,?)";
     private final String insertSample="Insert into RNA_RESULTFILE_SAMPLE (RNA_DATASET_RESULT_FILE_ID,RNA_SAMPLE_ID) Values (?,?)";
    private final String delete="delete RNA_DATASET_RESULTS_FILES where RNA_DATASET_RESULT_FILE_ID= ?";
    private final String deleteSample="delete RNA_RESULTFILE_SAMPLE where RNA_DATASET_RESULT_FILE_ID = ?";
    
    private final String getID="select RNA_RESULT_FILE_SEQ.nextVal from dual";
    
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
        this.isSampleLoaded=false;
    }
    
    public boolean createRNAResultFile(RNAResultFile rrf, DataSource pool){
        boolean success=false;
        this.pool=pool;
        if(rrf.getRNAResultFileID()==0){
            try(Connection conn=pool.getConnection()){
                long newID=getNextID();
                PreparedStatement ps=conn.prepareStatement(insert);
                ps.setLong(1, newID);
                ps.setLong(2, rrf.getRNAResultID());
                ps.setDate(3, rrf.getUploadDate());
                ps.setString(4, rrf.getOrigFileName());
                ps.setString(5, rrf.getFileName());
                ps.setString(6, rrf.getPath());
                ps.setString(7, rrf.getChecksum());
                boolean tmpSuccess=ps.execute();
                rrf.setRNAResultFileID(newID);
                
                //Variables?
                if(tmpSuccess){
                    RNASample myRS=new RNASample();
                    ArrayList<RNASample> rs=rrf.getRNASamples();
                    try(Connection conn2=pool.getConnection()){
                        for(int i=0;i<rs.size()&&tmpSuccess;i++){
                                PreparedStatement ps2=conn2.prepareStatement(insertSample);
                                ps2.setLong(1, rs.get(i).getRnaSampleID());
                                ps2.setLong(2, rrf.getRNAResultFileID());
                                tmpSuccess=ps2.execute();
                                ps2.close();

                        }
                    }catch(Exception e){
                        tmpSuccess=false;
                    }
                }
                
                if(tmpSuccess){
                    success=true;
                }
            }catch(Exception e){

            }
        }
        return success;
    }
    
    public boolean deleteRNAResultFile(RNAResultFile rf, DataSource pool){
        boolean success=false;
        try{
            //delete resultsample entries
            try(Connection conn=pool.getConnection()){
                PreparedStatement ps=conn.prepareStatement(deleteSample);
                ps.setLong(1, rf.getRNAResultFileID());
                boolean tmpSuccess=ps.execute();
                if(tmpSuccess){
                    success=true;
                }
                ps.close();
            }catch(Exception e){

            }
            //delete result file
            try(Connection conn=pool.getConnection()){
                PreparedStatement ps=conn.prepareStatement(delete);
                ps.setLong(1, rf.getRNAResultFileID());
                boolean tmpSuccess=ps.execute();
                if(tmpSuccess){
                    success=true;
                }
                ps.close();
            }catch(Exception e){

            }
            success=true;
        }catch(Exception e){
            
        }
        return success;
    }
    
    private long getNextID(){
        long ret=0;
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(getID)){
            ResultSet rs=ps.executeQuery();
            ret=rs.getLong(1);
            rs.close();
        }catch(SQLException e){
            log.error("Error getting new RNA_Result_File_ID:",e);
        }
        return ret;
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
    
    public ArrayList<RNASample> getRNASamples(){
        if(!isSampleLoaded){
            loadSamples();
        }
        return samples;
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
                isSampleLoaded=true;
            }catch(SQLException er){
                
            }
        }catch(Exception e){
            
        }
    }
}
