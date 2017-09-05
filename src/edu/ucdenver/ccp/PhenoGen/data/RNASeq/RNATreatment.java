/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.ucdenver.ccp.PhenoGen.data.RNASeq;

import edu.ucdenver.ccp.PhenoGen.data.User;
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
    private long rnaSampleID;
    private long rnaTreatmentID;
    private int uid;
    private User trtmtUser;
    private boolean isUserLoaded;
    private String name;
    private String description;
    private DataSource pool;
    private final Logger log;
    private final String select="select rst.RNA_SAMPLE_ID,rt.* from RNA_SAMPLE_TREATMENTS rst , RNA_TREATMENTS rt where rst.RNA_TREATMENT_ID=rt.RNA_TREATMENT_ID ";
    private final String insert="insert into RNA_TREATMENTS (RNA_TREATMENT_ID,USER_ID,NAME,DESCRIPTION) Values (?,?,?,?)";
    private final String update="update RNA_TREATMENTS set NAME=?,DESCRIPTION=? where RNA_TREATMENT_ID=?";
    private final String insertSample="Insert into RNA_SAMPLE_TREATMENTS (RNA_SAMPLE_ID,RNA_TREATMENT_ID) Values (?,?)";
    private final String deleteSample="delete RNA_SAMPLE_TREATMENTS where RNA_SAMPLE_ID=? and RNA_TREATMENT_ID=?";
    private final String deleteSampleAll="delete RNA_SAMPLE_TREATMENTS where RNA_SAMPLE_ID=?";
    private final String delete="delete RNA_TREATMENTS where RNA_TREATMENT_ID=?";
    private final String getID="select RNA_TREATMENT_SEQ.nextVal from dual";
    
    public RNATreatment(){
        log = Logger.getRootLogger();
    }
    
    public RNATreatment(long rnaSampleId, long rnaTreatmentID, int userID, String name, String description,DataSource pool){
        log = Logger.getRootLogger();
        this.setRnaSampleID(rnaSampleId);
        this.setRnaTreatmentID(rnaTreatmentID);
        this.setUid(userID);
        this.setName(name);
        this.setDescription(description);
        isUserLoaded=false;
        this.pool=pool;
    }
    
    public ArrayList<RNATreatment> getTreatmentBySample(long rnaSampleID,DataSource pool){
        String query=select+" where rst.rna_sample_id="+rnaSampleID;
        return getRNATreatmentByQuery(query,pool);
    }
    
    public ArrayList<RNATreatment> getRNATreatmentByQuery(String query, DataSource pool){
        ArrayList<RNATreatment> ret=new ArrayList<>();
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            
            ResultSet rs=ps.executeQuery();
            while(rs.next()){
                RNATreatment tmp=new RNATreatment(rs.getLong("RNA_SAMPLE_ID"),
                                    rs.getLong("RNA_TREATMENT_ID"),
                                    rs.getInt("USER_ID"),
                                    rs.getString("NAME"),
                                    rs.getString("DESCRIPTION"),
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

    public boolean addTreatmentToSample(long sampleID,long treatmentID, DataSource pool){
        boolean success=false;
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(insertSample);
            ps.setLong(1, sampleID);
            ps.setLong(2, treatmentID);
            boolean tmpSuccess=ps.execute();
            if(tmpSuccess){
                success=true;
            }
            ps.close();
        }catch(Exception e){

        }
        return success;
    }
    public boolean removeTreatmentFromSample(long sampleID,long treatmentID, DataSource pool){
        boolean success=false;
        
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(deleteSample);
            ps.setLong(1, sampleID);
            ps.setLong(2, treatmentID);
            boolean tmpSuccess=ps.execute();
            if(tmpSuccess){
                success=true;
            }
            ps.close();
        }catch(Exception e){

        }
        
        return success;
    }
    public boolean removeAllTreatmentsFromSample(long sampleID,DataSource pool){
        boolean success=false;
        
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(deleteSampleAll);
            ps.setLong(1, sampleID);
            boolean tmpSuccess=ps.execute();
            if(tmpSuccess){
                success=true;
            }
            ps.close();
        }catch(Exception e){

        }
        
        return success;
    }
    public boolean createTreatment(RNATreatment rt, DataSource pool){
        boolean success=false;
        if(rt.getRnaTreatmentID()==0){
            try(Connection conn=pool.getConnection()){
                long newID=getNextID(pool);
                PreparedStatement ps=conn.prepareStatement(insert);
                ps.setLong(1, newID);
                ps.setInt(2, rt.getUid());
                ps.setString(3, rt.getName());
                ps.setString(4, rt.getDescription());
                boolean tmpSuccess=ps.execute();
                rt.setRnaTreatmentID(newID);
                if(tmpSuccess){
                    success=true;
                }
                ps.close();
            }catch(Exception e){
                log.error("Error creating treatment:",e);
            }
        }
        return success;
    }
    public boolean updateTreatment(RNATreatment rt, DataSource pool){
        boolean success=false;
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(update);
            ps.setString(1, rt.getName());
            ps.setString(2, rt.getDescription());
            ps.setLong(3, rt.getRnaTreatmentID());
            int numUpdated=ps.executeUpdate();
            if(numUpdated==1){
                success=true;
            }
            ps.close();
        }catch(Exception e){
            
        }
        return success;
    }
    
    public boolean deleteTreatment(RNATreatment rt, DataSource pool){
        boolean success=false;
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(delete);
            ps.setLong(1, rt.getRnaTreatmentID());
            int count=ps.executeUpdate();
            if(count==1){
                success=true;
            }
            ps.close();
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
            log.error("Error getting new RNA_TREATMENT_ID:",e);
        }
        return ret;
    }
    
    public long getRnaSampleID() {
        return rnaSampleID;
    }

    public void setRnaSampleID(long rnaSampleID) {
        this.rnaSampleID = rnaSampleID;
    }

    public long getRnaTreatmentID() {
        return rnaTreatmentID;
    }

    public void setRnaTreatmentID(long rnaTreatmentID) {
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
        if(name!=null){
            this.name = name;
        }else{
            this.name="";
        }
    }

    public String getDescription() {
        
        return description;
    }

    public void setDescription(String description) {
        if(description!=null){
            this.description = description;
        }else{
            this.description="";
        }
    }
    
    public User getUser() {
        if(!isUserLoaded){
            User myUser=new User();
            try{
                this.trtmtUser=myUser.getUser(uid,pool);
                isUserLoaded=true;
            }catch(SQLException e){
                isUserLoaded=false;
                trtmtUser=null;
                e.printStackTrace(System.err);
                log.error("error retreiving RNATreatment User:"+uid,e);
            }
        }
        return trtmtUser;
    }
    
}
