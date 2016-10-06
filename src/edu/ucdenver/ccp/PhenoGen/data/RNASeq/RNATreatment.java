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
public class RNATreatment {
    private int rnaSampleID;
    private int rnaTreatmentID;
    private int uid;
    private String name;
    private String description;
    private DataSource pool;
    private final Logger log;
    private final String select="select * from RNA_SAMPLE_TREATMENTS rst , RNA_TREATMENTS rt where rst.RNA_TREATMENT_ID=rt.RNA_TREATMENT_ID ";
    
    public RNATreatment(){
        log = Logger.getRootLogger();
    }
    
    public RNATreatment(int rnaSampleId, int rnaTreatmentID, int userID, String name, String description,DataSource pool){
        log = Logger.getRootLogger();
        this.setRnaSampleID(rnaSampleId);
        this.setRnaTreatmentID(rnaTreatmentID);
        this.setUid(userID);
        this.setName(name);
        this.setDescription(description);
        this.pool=pool;
    }
    
    public ArrayList<RNATreatment> getTreatmentBySample(int rnaSampleID,DataSource pool){
        String query=select+" where rst.rna_sample_id="+rnaSampleID;
        return getRNATreatmentByQuery(query,pool);
    }
    
    public ArrayList<RNATreatment> getRNATreatmentByQuery(String query, DataSource pool){
        //final Connection conn=null;
        ArrayList<RNATreatment> ret=new ArrayList<>();
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            
            ResultSet rs=ps.executeQuery();
            while(rs.next()){
                boolean pair=false;
                if(rs.getInt("PAIRED_END")==1){
                    pair=true;
                }
                RNATreatment tmp=new RNATreatment(rs.getInt("RNA_SAMPLE_ID"),
                                    rs.getInt("RNA_TREATMENT_ID"),
                                    rs.getInt("USER_ID"),
                                    rs.getString("NAME"),
                                    rs.getString("DESCRIPTION"),
                                    pool
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

    public int getRnaSampleID() {
        return rnaSampleID;
    }

    public void setRnaSampleID(int rnaSampleID) {
        this.rnaSampleID = rnaSampleID;
    }

    public int getRnaTreatmentID() {
        return rnaTreatmentID;
    }

    public void setRnaTreatmentID(int rnaTreatmentID) {
        this.rnaTreatmentID = rnaTreatmentID;
    }

    public int getUid() {
        return uid;
    }

    public void setUid(int uid) {
        this.uid = uid;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
    
    
    
}
