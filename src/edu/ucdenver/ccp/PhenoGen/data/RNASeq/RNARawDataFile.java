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
public class RNARawDataFile {
    private int rawDataID;
    private int rnaSampleID;
    private String sampleName;
    private String batch;
    private String origFileName;
    private String fileName;
    private String path;
    private String checksum;
    private boolean paired;
    private String instrument;
    private int readLen;
    private long totalReads;
    private long size;
    private String sizeUnit;
    private boolean isSizeLoaded;
    
    private final Logger log;
    private final String select="select * from RNA_RAW_DATA_FILES rdf ";
    
    public RNARawDataFile(){
        log = Logger.getRootLogger();
    }
    
    public RNARawDataFile(int rawDataID,int rnaSampleID, String sampleName, String batch,String origFileName, String fileName,
            String path, String checksum, boolean paired, String instrument,int readLen,long totalReads){
        log = Logger.getRootLogger();
        this.setRawDataID(rawDataID);
        this.setRnaSampleID(rnaSampleID);
        this.setSampleName(sampleName);
        this.setBatch(batch);
        this.setOrigFileName(origFileName);
        this.setFileName(fileName);
        this.setPath(path);
        this.setChecksum(checksum);
        this.setPaired(paired);
        this.setInstrument(instrument);
        this.setReadLen(readLen);
        this.setTotalReads(totalReads);
        isSizeLoaded=false;
        size=0;
        sizeUnit="MB";
        
    }

    public ArrayList<RNARawDataFile> getRawDataFileBySample(int rnaSampleID,DataSource pool){
        String query=select+" where rna_sample_id="+rnaSampleID;
        return getRNARawDataFileByQuery(query,pool);
    }
    
    public ArrayList<RNARawDataFile> getRNARawDataFileByQuery(String query, DataSource pool){
        ArrayList<RNARawDataFile> ret=new ArrayList<>();
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            
            ResultSet rs=ps.executeQuery();
            while(rs.next()){
                boolean pair=false;
                if(rs.getInt("PAIRED_END")==1){
                    pair=true;
                }
                RNARawDataFile tmp=new RNARawDataFile(rs.getInt("RNA_RAW_DATA_ID"),
                                    rs.getInt("RNA_SAMPLE_ID"),
                                    rs.getString("RNA_SAMPLE_NAME"),
                                    rs.getString("BATCH"),
                                    rs.getString("ORIGINAL_FILE"),
                                    rs.getString("FILENAME"),
                                    rs.getString("PATH"),
                                    rs.getString("CHECKSUM"),
                                    pair,
                                    rs.getString("INSTRUMENT"),
                                    rs.getInt("READ_LENGTH"),
                                    rs.getLong("TOTAL_READS")
                    );
                ret.add(tmp);
            }
            ps.close();
            conn.close();
        }catch(SQLException e){
            log.error("Error getting RNADataset from \n"+query,e);
        }
        return ret;
    }
    
    public int getRawDataID() {
        return rawDataID;
    }

    public void setRawDataID(int rawDataID) {
        this.rawDataID = rawDataID;
    }

    public int getRnaSampleID() {
        return rnaSampleID;
    }

    public void setRnaSampleID(int rnaSampleID) {
        this.rnaSampleID = rnaSampleID;
    }

    public String getSampleName() {
        return sampleName;
    }

    public void setSampleName(String sampleName) {
        this.sampleName = sampleName;
    }

    public String getBatch() {
        return batch;
    }

    public void setBatch(String batch) {
        this.batch = batch;
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

    public boolean getPaired() {
        return paired;
    }

    public void setPaired(boolean paired) {
        this.paired = paired;
    }

    public String getInstrument() {
        return instrument;
    }

    public void setInstrument(String instrument) {
        this.instrument = instrument;
    }

    public int getReadLen() {
        return readLen;
    }

    public void setReadLen(int readLen) {
        this.readLen = readLen;
    }

    public long getTotalReads() {
        return totalReads;
    }

    public void setTotalReads(long totalReads) {
        this.totalReads = totalReads;
    }
    
}
