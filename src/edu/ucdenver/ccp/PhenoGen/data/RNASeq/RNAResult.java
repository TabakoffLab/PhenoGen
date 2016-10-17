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
import javax.sql.DataSource;
import org.apache.log4j.Logger;

/**
 *
 * @author smahaffey
 */
public class RNAResult {
    private int rnaDatasetResultID;
    private int rnaDAtasetID;
    private String type;
    private String genomeVer;
    private String version;
    private Date versionDate;
    private boolean isVisible;
    private boolean isPublic;
    private String locationType;
    private String location;
    private String checksum;
    private Date created;
    
    private ArrayList<RNAResultVariable> vars;
    private boolean isVarLoaded;
    private ArrayList<RNAResultFile> files;
    private boolean isFileLoaded;
    private RNAPipeline pipeline;
    private boolean isPipelineLoaded;
    private DataSource pool;
    private Logger log;
    
    private final String select="";
    
    public RNAResult(){
        log = Logger.getRootLogger();
    }
    
    public RNAResult(int rnaDatasetResultID, int rnaDatasetID, String type, String genomeVer, String version,
            Date versionDate, boolean visible, boolean isPublic, String locationType,String location, 
            String checksum, Date created,DataSource pool){
        log = Logger.getRootLogger();
        
        this.pool=pool;
    }
    public ArrayList<RNAResult> getRNAResultsByDataset(int rnaDatasetID,DataSource pool){
        String query=select+" and rdp.rna_dataset_id="+rnaDatasetID;
        return getRNAResultsByQuery(query,pool);
    }
    
    private ArrayList<RNAResult> getRNAResultsByQuery(String query, DataSource pool){
        ArrayList<RNAResult> ret=new ArrayList<>();
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            
            ResultSet rs=ps.executeQuery();
            while(rs.next()){
                RNAResult tmp=new RNAResult(,
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

    public int getRnaDatasetResultID() {
        return rnaDatasetResultID;
    }

    public void setRnaDatasetResultID(int rnaDatasetResultID) {
        this.rnaDatasetResultID = rnaDatasetResultID;
    }

    public int getRnaDAtasetID() {
        return rnaDAtasetID;
    }

    public void setRnaDAtasetID(int rnaDAtasetID) {
        this.rnaDAtasetID = rnaDAtasetID;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getGenomeVer() {
        return genomeVer;
    }

    public void setGenomeVer(String genomeVer) {
        this.genomeVer = genomeVer;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public Date getVersionDate() {
        return versionDate;
    }

    public void setVersionDate(Date versionDate) {
        this.versionDate = versionDate;
    }

    public boolean isIsVisible() {
        return isVisible;
    }

    public void setIsVisible(boolean isVisible) {
        this.isVisible = isVisible;
    }

    public boolean isIsPublic() {
        return isPublic;
    }

    public void setIsPublic(boolean isPublic) {
        this.isPublic = isPublic;
    }

    public String getLocationType() {
        return locationType;
    }

    public void setLocationType(String locationType) {
        this.locationType = locationType;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getChecksum() {
        return checksum;
    }

    public void setChecksum(String checksum) {
        this.checksum = checksum;
    }

    public Date getCreated() {
        return created;
    }

    public void setCreated(Date created) {
        this.created = created;
    }

    public ArrayList<RNAResultVariable> getVars() {
        return vars;
    }

    public void setVars(ArrayList<RNAResultVariable> vars) {
        this.vars = vars;
    }

    public ArrayList<RNAResultFile> getFiles() {
        return files;
    }

    public void setFiles(ArrayList<RNAResultFile> files) {
        this.files = files;
    }

    public RNAPipeline getPipeline() {
        return pipeline;
    }

    public void setPipeline(RNAPipeline pipeline) {
        this.pipeline = pipeline;
    }
    
}
