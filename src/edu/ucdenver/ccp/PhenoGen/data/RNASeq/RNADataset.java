/**
 *
 *
 * 
 *
 */
package edu.ucdenver.ccp.PhenoGen.data.RNASeq;

import edu.ucdenver.ccp.PhenoGen.data.User;
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
 * @author Spencer Mahaffey
 * 
 */
public class RNADataset {
    private int rnaDatasetID;
    private String organism;
    private String panel;
    private String description;
    private boolean visible;
    private Date created;
    private boolean isPublic;
    private int userID;
    private User rdsUser;
    private boolean isUserLoaded;
    private ArrayList<RNASample> samples;
    private boolean isSampleLoaded;
    private int sampleCount;
    private DataSource pool;
    private final Logger log;
    private final String selectWCount="select rd.*,(Select count(*) from RNA_DS_SAMPLES rs where rd.RNA_DATASET_ID=rs.RNA_DATASET_ID) as sample_count  from rna_dataset2 rd ";
    
    public RNADataset(){
        log = Logger.getRootLogger();
    }
    
    public RNADataset(int rnaDatasetID, String organism, String panel, String description, boolean visible, Date created, boolean isPublic,int uid,DataSource pool){
        log = Logger.getRootLogger();
        this.pool=pool;
        this.setRnaDatasetID(rnaDatasetID);
        this.setOrganism(organism);
        this.setPanel(panel);
        this.setDescription(description);
        this.setVisible(visible);
        this.setCreated(created);
        this.setIsPublic(isPublic);
        this.setUserID(uid);
        isUserLoaded=false;
        isSampleLoaded=false;
        samples=new ArrayList<>();
        rdsUser=null;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }
    
    
    public RNADataset getRNADataset(long id, DataSource pool){
        String query=selectWCount+" where rd.rna_dataset_id="+id;
        return getRNADatasetByQuery(query,pool);
    }
    public ArrayList<RNADataset> getRNADatasetsByUser(long uid, DataSource pool){
        String query=selectWCount+" where rd.user_id="+uid;
        return getRNADatasetsByQuery(query,pool);
    }
    public ArrayList<RNADataset> getRNADatasetsByPublic(boolean pub,String org, DataSource pool){
        int ispub=0;
        if(pub){
            ispub=1;
        }
        String query=selectWCount+" where rd.ispublic="+ispub+" and visible=1";
        if(!org.equals("All")){
            query=query+" and rd.organism='"+org+"'";
        }
       return getRNADatasetsByQuery(query,pool);
    }

    public RNADataset getRNADatasetByQuery(String query, DataSource pool){
        RNADataset ret=null;
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            ResultSet rs=ps.executeQuery();
            if(rs.next()){
                boolean vis=false;
                if(rs.getInt("Visible")==1){
                    vis=true;
                }
                boolean pub=false;
                if(rs.getInt("ISPUBLIC")==1){
                    pub=true;
                }
                ret=new RNADataset(rs.getInt("RNA_DATASET_ID"),
                                   rs.getString("Organism"),
                                   rs.getString("Panel"),
                                   rs.getString("Descripton"),
                                   vis,
                                   rs.getDate("CREATED"),
                                   pub,
                                   rs.getInt("USER_ID"),
                                   pool
                    );
                ret.setSampleCount(rs.getInt("SAMPLE_COUNT"));
            }
            ps.close();
            conn.close();
        }catch(SQLException e){
            log.error("Error getting RNADataset from \n"+query,e);
        }
        return ret;
    }
    
    public ArrayList<RNADataset> getRNADatasetsByQuery(String query, DataSource pool){
        ArrayList<RNADataset> ret=new ArrayList<>();
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            ResultSet rs=ps.executeQuery();
            while(rs.next()){
                boolean vis=false;
                if(rs.getInt("Visible")==1){
                    vis=true;
                }
                boolean pub=false;
                if(rs.getInt("ISPUBLIC")==1){
                    pub=true;
                }
                RNADataset tmp=new RNADataset(rs.getInt("RNA_DATASET_ID"),
                                   rs.getString("Organism"),
                                   rs.getString("Panel"),
                                   rs.getString("Descripton"),
                                   vis,
                                   rs.getDate("CREATED"),
                                   pub,
                                   rs.getInt("USER_ID"),
                                   pool
                    );
                tmp.setSampleCount(rs.getInt("SAMPLE_COUNT"));
                ret.add(tmp);
            }
            ps.close();
            conn.close();
            
        }catch(SQLException e){
            log.error("Error getting RNADataset from \n"+query,e);
        }
        return ret;
    }
    
    public long getRnaDatasetID() {
        return rnaDatasetID;
    }

    public void setRnaDatasetID(int rnaDatasetID) {
        this.rnaDatasetID = rnaDatasetID;
    }

    public String getOrganism() {
        return organism;
    }

    public void setOrganism(String organism) {
        this.organism = organism;
    }

    public int getSampleCount() {
        return sampleCount;
    }

    public void setSampleCount(int sampleCount) {
        this.sampleCount = sampleCount;
    }

    public String getPanel() {
        return panel;
    }

    public void setPanel(String panel) {
        this.panel = panel;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isVisible() {
        return visible;
    }

    public void setVisible(boolean visible) {
        this.visible = visible;
    }

    public Date getCreated() {
        return created;
    }

    public void setCreated(Date created) {
        this.created = created;
    }

    public boolean isIsPublic() {
        return isPublic;
    }

    public void setIsPublic(boolean isPublic) {
        this.isPublic = isPublic;
    }

    public User getUser() {
        if(!isUserLoaded){
            User myUser=new User();
            try{
                this.rdsUser=myUser.getUser(userID,pool);
                isUserLoaded=true;
            }catch(SQLException e){
                isUserLoaded=false;
                rdsUser=null;
                e.printStackTrace(System.err);
                log.error("error retreiving RNADataset User:"+userID,e);
            }
        }
        return rdsUser;
    }

    public void setUser(User rdsUser) {
        this.rdsUser = rdsUser;
    }

    public boolean isIsUserLoaded() {
        return isUserLoaded;
    }

    public void setIsUserLoaded(boolean isUserLoaded) {
        this.isUserLoaded = isUserLoaded;
    }

    public ArrayList<RNASample> getSamples() {
        if(!isSampleLoaded){
            RNASample mySample=new RNASample();
            try{
                this.samples=mySample.getRNASamplesByDataset(rnaDatasetID,pool);
                isSampleLoaded=true;
            }catch(Exception e){
                isSampleLoaded=false;
                samples=new ArrayList<>();
                e.printStackTrace(System.err);
                log.error("error retreiving RNASamples for RNADataset:"+rnaDatasetID,e);
            }
        }
        return samples;
    }

    public void setSamples(ArrayList<RNASample> samples) {
        this.samples = samples;
    }

    public boolean isIsSampleLoaded() {
        return isSampleLoaded;
    }

    public void setIsSampleLoaded(boolean isSampleLoaded) {
        this.isSampleLoaded = isSampleLoaded;
    }


    public void setPool(DataSource pool) {
        this.pool = pool;
    }
    
    
}
