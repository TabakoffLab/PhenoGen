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
public class RNAResult {
    private long rnaDatasetResultID;
    private long rnaDatasetID;
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
    private ArrayList<RNASample> samples;
    
    private RNADataset parentDS;
    private boolean isFileLoaded;
    private boolean isSampleLoaded;
    private RNAPipeline pipeline;
    private boolean isPipelineLoaded;
    private DataSource pool;
    private Logger log;
    
    private final String select="";
    private final String selectSampleIDs="select RNA_SAMPLE_ID from RNA_RESULT_SAMPLE where RNA_DATASET_RESULT_ID=";
    
    public RNAResult(){
        log = Logger.getRootLogger();
    }
    
    public RNAResult(long rnaDatasetResultID, long rnaDatasetID, String type, String genomeVer, String version,
            Date versionDate, boolean visible, boolean isPublic, String locationType,String location, 
            String checksum, Date created,DataSource pool){
        log = Logger.getRootLogger();
        this.rnaDatasetResultID=rnaDatasetResultID;
        this.rnaDatasetID=rnaDatasetID;
        this.type=type;
        this.genomeVer=genomeVer;
        this.version=version;
        this.versionDate=versionDate;
        this.isVisible=visible;
        this.isPublic=isPublic;
        this.locationType=locationType;
        this.location=location;
        this.checksum=checksum;
        this.created=created;
        this.isFileLoaded=false;
        this.isVarLoaded=false;
        this.isPipelineLoaded=false;
        this.isSampleLoaded=false;
        this.pool=pool;
    }
    public ArrayList<RNAResult> getRNAResultsByDataset(long rnaDatasetID,DataSource pool){
        String query=select+" and rdp.rna_dataset_id="+rnaDatasetID;
        return getRNAResultsByQuery(query,pool);
    }
    
    private ArrayList<RNAResult> getRNAResultsByQuery(String query, DataSource pool){
        ArrayList<RNAResult> ret=new ArrayList<>();
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            
            ResultSet rs=ps.executeQuery();
            while(rs.next()){
                boolean vis=false;
                boolean isPub=false;
                if(rs.getInt("VISIBLE")==1){vis=true;}
                if(rs.getInt("ISPUBLIC")==1){isPub=true;}
                RNAResult tmp=new RNAResult(rs.getLong("RNA_DATASET_RESULT_ID"),
                                            rs.getLong("RNA_DATASET_ID"),
                                            rs.getString("RESULT_TYPE"),
                                            rs.getString("GENOME_ID"),
                                            rs.getString("VER"),
                                            rs.getDate("VERSION_DATE"),
                                            vis,
                                            isPub,
                                            rs.getString("RESULT_LOCATION_TYPE"),
                                            rs.getString("RESULT_LOCATION"),
                                            rs.getString("CHECKSUM"),
                                            rs.getDate("CREATED"),
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

    public long getRnaDatasetResultID() {
        return rnaDatasetResultID;
    }

    public void setRnaDatasetResultID(long rnaDatasetResultID) {
        this.rnaDatasetResultID = rnaDatasetResultID;
    }

    public long getRnaDatasetID() {
        return rnaDatasetID;
    }

    public void setRnaDAtasetID(long rnaDAtasetID) {
        this.rnaDatasetID = rnaDAtasetID;
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
        if(!this.isVarLoaded){
            loadVars();
        }
        return vars;
    }

    public void setVars(ArrayList<RNAResultVariable> vars) {
        this.vars = vars;
    }

    public ArrayList<RNAResultFile> getFiles() {
        if(!this.isFileLoaded){
            loadFiles();
        }
        return files;
    }

    public void setFiles(ArrayList<RNAResultFile> files) {
        this.files = files;
    }

    public RNAPipeline getPipeline() {
        if(!this.isPipelineLoaded){
            loadPipeline();
        }
        return pipeline;
    }

    public void setPipeline(RNAPipeline pipeline) {
        this.pipeline = pipeline;
    }
    
    public void setDataset(RNADataset par){
        this.parentDS=par;
    }
    public ArrayList<RNASample> getSamples(){
        if(!isSampleLoaded){
            loadSamples();
        }
        return samples;
    }
    private void loadFiles(){
        RNAResultFile rrf=new RNAResultFile();
        try{
            this.files=rrf.getRNAResultFilesByDatasetResult(this.rnaDatasetResultID, this.pool);
            this.isFileLoaded=true;
            for(int i=0;i<files.size();i++){
                files.get(i).setDatasetResults(this);
            }
        }catch(Exception e){
            isFileLoaded=false;
            files=new ArrayList<>();
            e.printStackTrace(System.err);
            log.error("error retreiving RNAResultFiles for RNAResult:"+rnaDatasetID,e);
        }
    }
    private void loadPipeline(){
        
    }
    private void loadVars(){
        RNAResultVariable rrv=new RNAResultVariable();
        try{
            this.vars=rrv.getRNAResultVariablesByDataset(this.rnaDatasetResultID, this.pool);
            this.isVarLoaded=true;
        }catch(Exception e){
            isVarLoaded=false;
            vars=new ArrayList<>();
            e.printStackTrace(System.err);
            log.error("error retreiving RNAResultVars for RNAResult:"+rnaDatasetID,e);
        }
    }
    private void loadSamples(){
        samples=new ArrayList<>();
        try{
            ArrayList<RNASample> fullList=this.parentDS.getSamples();
            HashMap<String,RNASample> hm=new HashMap<String,RNASample>();
            for(int i=0;i<fullList.size();i++){
                RNASample tmp=fullList.get(i);
                hm.put(Long.toString(tmp.getRnaSampleID()),tmp );
            }
            try(Connection conn=pool.getConnection();
                PreparedStatement ps=conn.prepareStatement(selectSampleIDs+this.rnaDatasetResultID)){
                ResultSet rs=ps.executeQuery();
                while(rs.next()){
                    long tmp=rs.getLong("RNA_SAMPLE_ID");
                    if(hm.containsKey(Long.toString(tmp))){
                        samples.add(hm.get(Long.toString(tmp)));
                    }
                }
            }catch(SQLException er){
                log.error("SQLException getting samples for RNAResults",er);
            }
        }catch(Exception e){
            log.error("Exception getting samples for RNAResults",e);
        }
    }
}
