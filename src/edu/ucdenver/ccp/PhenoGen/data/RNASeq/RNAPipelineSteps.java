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
public class RNAPipelineSteps {
    private long rnaPipelineStepID;
    private long rnaPipelineID;
    private String name;
    private String type;
    private int order;
    private String scriptFile;
    private String program;
    private String version;
    private String command;
    private long startReadCount;
    private long endReadCount;
    
    private Logger log;
    private final String select="select * from RNA_PIPELINE_STEPS";
    
    public RNAPipelineSteps(){
        log = Logger.getRootLogger();
    }
    
    public RNAPipelineSteps(long rnaPipelineStepID,long rnaPipelineID,String stepName,String stepType,int ord,String script,String prog,String ver, String command,long startRead,long endRead){
        this.setRnaPipelineStepID(rnaPipelineStepID);
        this.setRnaPipelineID(rnaPipelineID);
        this.setName(stepName);
        this.setType(stepType);
        this.setOrder(ord);
        this.setScriptFile(script);
        this.setProgram(prog);
        this.setVersion(ver);
        this.setCommand(command);
        this.setStartReadCount(startRead);
        this.setEndReadCount(endRead);
    }

    public ArrayList<RNAPipelineSteps> getRNAPipelineStepsByPipelineID(long rnaPipelineID,DataSource pool){
        String query=select+" where rna_Pipeline_id="+rnaPipelineID+" order by ord";
        return getRNAResultsByQuery(query,pool);
    }
    
    private ArrayList<RNAPipelineSteps> getRNAResultsByQuery(String query, DataSource pool){
        ArrayList<RNAPipelineSteps> ret=new ArrayList<>();
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            ResultSet rs=ps.executeQuery();
            while(rs.next()){
                RNAPipelineSteps tmp=new RNAPipelineSteps(rs.getLong("RNA_PIPELINE_STEP_ID"),
                        rs.getLong("RNA_PIPELINE_ID"),
                        rs.getString("STEP_NAME"),
                        rs.getString("STEP_TYPE"),
                        rs.getInt("ORD"),
                        rs.getString("SCRIPT_FILE"),
                        rs.getString("PROG"),
                        rs.getString("VER"),
                        rs.getString("COMMAND_LINE"),
                        rs.getLong("start_read_count"),
                        rs.getLong("end_read_count")
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

    public long getRnaPipelineStepID() {
        return rnaPipelineStepID;
    }

    public void setRnaPipelineStepID(long rnaPipelineStepID) {
        this.rnaPipelineStepID = rnaPipelineStepID;
    }

    public long getRnaPipelineID() {
        return rnaPipelineID;
    }

    public void setRnaPipelineID(long rnaPipelineID) {
        this.rnaPipelineID = rnaPipelineID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getOrder() {
        return order;
    }

    public void setOrder(int order) {
        this.order = order;
    }

    public String getScriptFile() {
        return scriptFile;
    }

    public void setScriptFile(String scriptFile) {
        this.scriptFile = scriptFile;
    }

    public String getProgram() {
        return program;
    }

    public void setProgram(String program) {
        this.program = program;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getCommand() {
        return command;
    }

    public void setCommand(String command) {
        this.command = command;
    }

    public long getStartReadCount() {
        return startReadCount;
    }

    public void setStartReadCount(long startReadCount) {
        this.startReadCount = startReadCount;
    }

    public long getEndReadCount() {
        return endReadCount;
    }

    public void setEndReadCount(long endReadCount) {
        this.endReadCount = endReadCount;
    }
    
    
    
}
