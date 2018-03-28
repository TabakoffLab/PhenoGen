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
public class RNAPipeline {
    private Logger log;
    private long rnaPipelineID;
    private String title;
    private String description;
    private long rnaDatasetResultID;
    private long rnaEnvID;
    
    private ArrayList<RNAPipelineSteps> steps;
    private boolean isStepLoaded;
    private DataSource pool;
    
    private final String select="select * from RNA_PIPELINE";
    
    
    
    public RNAPipeline(){
        log = Logger.getRootLogger();
    }
    
    public RNAPipeline(long rnaPipelineID, String title, String description, long rnaDAtasetResultID, long rnaEnvID, DataSource pool){
        this.setRnaPipelineID(rnaPipelineID);
        this.setTitle(title);
        this.setDescription(description);
        this.setRnaDatasetResultID(rnaDAtasetResultID);
        this.setRnaEnvID(rnaEnvID);
        this.pool=pool;
        this.isStepLoaded=false;
    }

    public ArrayList<RNAPipeline> getRNAPipelineByResultID(long rnaResultID,DataSource pool){
        String query=select+" where rna_dataset_result_id="+rnaResultID;
        return getRNAResultsByQuery(query,pool);
    }
    
    private ArrayList<RNAPipeline> getRNAResultsByQuery(String query, DataSource pool){
        ArrayList<RNAPipeline> ret=new ArrayList<>();
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            ResultSet rs=ps.executeQuery();
            while(rs.next()){
                RNAPipeline tmp=new RNAPipeline(rs.getLong("RNA_PIPELINE_ID"),
                                                rs.getString("TITLE"),
                                                rs.getString("DESCRIPTION"),
                                                rs.getLong("RNA_DATASET_RESULT_ID"),
                                                rs.getLong("RNA_ENV_ID"),
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

    
    public long getRnaPipelineID() {
        return rnaPipelineID;
    }

    public void setRnaPipelineID(long rnaPipelineID) {
        this.rnaPipelineID = rnaPipelineID;
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

    public long getRnaDatasetResultID() {
        return rnaDatasetResultID;
    }

    public void setRnaDatasetResultID(long rnaDatasetResultID) {
        this.rnaDatasetResultID = rnaDatasetResultID;
    }

    public ArrayList<RNAPipelineSteps> getSteps() {
        if(!isStepLoaded){
            loadSteps();
        }
        return steps;
    }

    public void setSteps(ArrayList<RNAPipelineSteps> steps) {
        this.steps = steps;
    }
    
    public void setRnaEnvID(long rnaEnvID){
        this.rnaEnvID=rnaEnvID;
    }
    private void loadSteps(){
        RNAPipelineSteps rps=new RNAPipelineSteps();
        try{
            this.steps=rps.getRNAPipelineStepsByPipelineID(this.rnaPipelineID, this.pool);
            this.isStepLoaded=true;
        }catch(Exception e){
            isStepLoaded=false;
            steps=new ArrayList<>();
            e.printStackTrace(System.err);
            log.error("error retreiving RNAPipelineSteps:",e);
        }
    }
}
