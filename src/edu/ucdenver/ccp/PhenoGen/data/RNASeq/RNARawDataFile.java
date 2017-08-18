/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.ucdenver.ccp.PhenoGen.data.RNASeq;

import java.io.File;
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
    private long rawDataID;
    private long rnaSampleID;
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
    private double size;
    private String sizeUnit;
    private boolean isSizeLoaded;
    private boolean isPublic;
    private boolean isDownloadable;
    
    private final Logger log;
    private final String select="select * from RNA_RAW_DATA_FILES rdf ";
    private final String insert="Insert into RNA_RAW_DATA_FILES (RNA_RAW_DATA_ID,RNA_SAMPLE_ID,RNA_SAMPLE_NAME,BATCH,ORIGINAL_FILE,FILENAME,PATH,CHECKSUM,PAIRED_END,INSTRUMENT,READ_LENGTH,TOTAL_READS,IS_PUBLIC,IS_DOWNLOAD) Values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    private final String update="update set RNA_SAMPLE_ID=?,RNA_SAMPLE_NAME=?,BATCH=?,ORIGINAL_FILE=?,FILENAME=?,PATH=?,PAIRED_END=?,INSTRUMENT=?,READ_LENGTH=?,TOTAL_READS=?,IS_PUBLIC=?,IS_DOWNLOAD=? where RNA_RAW_DATA_ID=?";
    private final String delete="delete RNA_RAW_DATA_FILES where RNA_RAW_DATA_ID=?";
    private final String getID="select RNA_RAW_DATAFILES_SEQ.nextVal from dual";
    
    public RNARawDataFile(){
        log = Logger.getRootLogger();
    }
    
    public RNARawDataFile(long rawDataID,long rnaSampleID, String sampleName, String batch,String origFileName, String fileName,
            String path, String checksum, boolean paired, String instrument,int readLen,long totalReads,boolean isPublic,boolean isDownload){
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
        this.setIsPublic(isPublic);
        this.setIsDownloadable(isDownload);
        isSizeLoaded=false;
        size=0;
        sizeUnit="MB";
        
    }

    public ArrayList<RNARawDataFile> getRawDataFilesBySample(long rnaSampleID,DataSource pool){
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
                if(rs.getInt("PAIRED_END")==1){pair=true;}
                boolean pub=false;
                if(rs.getInt("IS_PUBLIC")==1){pub=true;}
                boolean down=false;
                if(rs.getInt("IS_DOWNLOAD")==1){down=true;}
                RNARawDataFile tmp=new RNARawDataFile(rs.getLong("RNA_RAW_DATA_ID"),
                                    rs.getLong("RNA_SAMPLE_ID"),
                                    rs.getString("RNA_SAMPLE_NAME"),
                                    rs.getString("BATCH"),
                                    rs.getString("ORIGINAL_FILE"),
                                    rs.getString("FILENAME"),
                                    rs.getString("PATH"),
                                    rs.getString("CHECKSUM"),
                                    pair,
                                    rs.getString("INSTRUMENT"),
                                    rs.getInt("READ_LENGTH"),
                                    rs.getLong("TOTAL_READS"),
                                    pub,
                                    down);
                ret.add(tmp);
            }
            ps.close();
            conn.close();
        }catch(SQLException e){
            log.error("Error getting RNADataset from \n"+query,e);
        }
        return ret;
    }
    
    public boolean createRNARawDataFile(RNARawDataFile rdf, DataSource pool){
        boolean success=false;
        if(rdf.getRawDataID()==0){
            try(Connection conn=pool.getConnection()){
                long newID=getNextID(pool);
                PreparedStatement ps=conn.prepareStatement(insert);
                ps.setLong(1, newID);
                ps.setLong(2, rdf.getRnaSampleID());
                ps.setString(3, rdf.getSampleName());
                ps.setString(4, rdf.getBatch());
                ps.setString(5, rdf.getOrigFileName());
                ps.setString(6, rdf.getFileName());
                ps.setString(7, rdf.getPath());
                ps.setString(8, rdf.getChecksum());
                if(rdf.getPaired()){
                    ps.setInt(9, 1);
                }else{
                    ps.setInt(9, 0);
                }
                ps.setString(10,rdf.getInstrument());
                ps.setInt(11, rdf.getReadLen());
                ps.setLong(12, rdf.getTotalReads());
                if(rdf.isPublic()){
                    ps.setInt(13, 1);
                }else{
                    ps.setInt(13, 0);
                }
                if(rdf.isDownloadable()){
                    ps.setInt(14, 1);
                }else{
                    ps.setInt(14, 0);
                }
                boolean tmpSuccess=ps.execute();
                rdf.setRnaSampleID(newID);
                if(tmpSuccess){
                    success=true;
                }
            }catch(Exception e){

            }
        }
        return success;
    }
    
    public boolean updateRNARawDataFile(RNARawDataFile rdf, DataSource pool){
        boolean success=false;
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(update);
            ps.setLong(1, rdf.getRnaSampleID());
            ps.setString(2, rdf.getSampleName());
            ps.setString(3, rdf.getBatch());
            ps.setString(4, rdf.getOrigFileName());
            ps.setString(5, rdf.getFileName());
            ps.setString(6, rdf.getPath());
            if(rdf.getPaired()){
                ps.setInt(7,1);
            }else{
                ps.setInt(7,0);
            }
            ps.setString(8, rdf.getInstrument());
            ps.setInt(9, rdf.getReadLen());
            ps.setLong(10,rdf.getTotalReads());
            if(rdf.isPublic()){
                ps.setInt(11,1);
            }else{
                ps.setInt(11,0);
            }
            if(rdf.isDownloadable()){
                ps.setInt(12,1);
            }else{
                ps.setInt(12,0);
            }
            ps.setLong(13, rdf.getRawDataID());
            int numUpdated=ps.executeUpdate();
            if(numUpdated==1){
                success=true;
            }
        }catch(Exception e){
            
        }
        return success;
    }
    
    public boolean deleteRNADataset(RNARawDataFile rdf, DataSource pool){
        boolean success=false;
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(delete);
            ps.setLong(1, rdf.getRawDataID());
            success=true;
        }catch(Exception e){
            
        }
        return success;
    }
    private long getNextID(DataSource pool){
        long ret=0;
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(getID)){
            ResultSet rs=ps.executeQuery();
            ret=rs.getLong(1);
            rs.close();
        }catch(SQLException e){
            log.error("Error getting new RNA_RAW_DATAFILE_ID:",e);
        }
        return ret;
    }
    
    public long getRawDataID() {
        return rawDataID;
    }

    public void setRawDataID(long rawDataID) {
        this.rawDataID = rawDataID;
    }

    public long getRnaSampleID() {
        return rnaSampleID;
    }

    public void setRnaSampleID(long rnaSampleID) {
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

    public boolean isPublic() {
        return isPublic;
    }

    public void setIsPublic(boolean isPublic) {
        this.isPublic = isPublic;
    }

    public boolean isDownloadable() {
        return isDownloadable;
    }

    public void setIsDownloadable(boolean isDownloadable) {
        this.isDownloadable = isDownloadable;
    }
    
    public double getSize(){
        if(!isSizeLoaded){
            File tmp=new File(path+fileName);
            double tmpDiv=1024;
            if(sizeUnit.equals("GB")){
                tmpDiv=1024*1024*1024;
            }else if(sizeUnit.equals("MB")){
                tmpDiv=1024*1024;
            }
            size=tmp.length()/tmpDiv;
        }
        return size;
    }
    
}
