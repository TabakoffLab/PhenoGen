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
import java.sql.Date;
import javax.sql.DataSource;

import org.apache.log4j.Logger;
/**
 *
 * @author Spencer Mahaffey
 * 
 */
public class RNADataset {
    private long rnaDatasetID;
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
    private ArrayList<RNAResult> results;
    private boolean isSampleLoaded;
    private boolean isResultsLoaded;
    private int sampleCount;
    private DataSource pool;
    private final Logger log;
    private final String selectWCount="select rd.*,(Select count(*) from RNA_DS_SAMPLES rs where rd.RNA_DATASET_ID=rs.RNA_DATASET_ID) as sample_count  from rna_dataset2 rd ";
    private final String insert="Insert into RNA_DATASET2 (RNA_DATASET_ID,ORGANISM,USER_ID,STRAIN_PANEL,DESCRIPTION,VISIBLE,CREATED,ISPUBLIC) Values (?,?,?,?,?,?,?,?)";
    private final String update="update set ORGANISM=?,USER_ID=?,STRAIN_PANEL=?,DESCRIPTION=?,VISIBLE=?,CREATED=?,ISPUBLIC=? where RNA_DATASET_ID=?";
    private final String delete="delete RNA_DATASET2 where RNA_DATASET_ID=?";
    private final String getID="select RNA_DATASET_SEQ.nextVal from dual";
    
    public RNADataset(){
        log = Logger.getRootLogger();
    }
    
    public RNADataset(long rnaDatasetID, String organism, String panel, String description, boolean visible, Date created, boolean isPublic,int uid,DataSource pool){
        log = Logger.getRootLogger();
        this.pool=pool;
        this.setRnaDatasetID(rnaDatasetID);
        this.setOrganism(organism);
        this.setPanel(panel);
        this.setDescription(description);
        this.setVisible(visible);
        this.setCreated(created);
        this.setPublic(isPublic);
        this.setUserID(uid);
        isUserLoaded=false;
        isSampleLoaded=false;
        isResultsLoaded=false;
        rdsUser=null;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }
    
    public boolean createRNADataset(RNADataset rd, DataSource pool){
        boolean success=false;
        this.pool=pool;
        if(rd.getRnaDatasetID()==0){
            try(Connection conn=pool.getConnection()){
                long newID=getNextID();
                //rd.setRnaDatasetID(newID);
                PreparedStatement ps=conn.prepareStatement(insert);
                ps.setLong(1, newID);
                ps.setString(2, rd.getOrganism());
                ps.setInt(3, rd.getUserID());
                ps.setString(4, rd.getPanel());
                ps.setString(5,rd.getDescription());
                if(rd.isVisible()){
                    ps.setInt(6, 1);
                }else{
                    ps.setInt(6, 0);
                }
                ps.setDate(7, rd.getCreated());
                if(rd.isPublic()){
                    ps.setInt(8, 1);
                }else{
                    ps.setInt(8, 0);
                }
                boolean tmpSuccess=ps.execute();
                rd.setRnaDatasetID(newID);
                //Samples?
                if(tmpSuccess){
                    RNASample myRS=new RNASample();
                    ArrayList<RNASample> rs=rd.getSamples();
                    for(int i=0;i<rs.size()&&tmpSuccess;i++){
                        tmpSuccess=myRS.createRNASample(rs.get(i),pool);
                    }
                }
                //Results?
                if(tmpSuccess){
                    RNAResult myRR=new RNAResult();
                    ArrayList<RNAResult> rr=rd.getResults();
                    for(int i=0;i<rr.size()&&tmpSuccess;i++){
                        tmpSuccess=myRR.createRNAResult(rr.get(i),pool);
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
    
    public boolean updateRNADataset(RNADataset rd, DataSource pool){
        boolean success=false;
        try(Connection conn=pool.getConnection()){
            PreparedStatement ps=conn.prepareStatement(update);
            ps.setString(1, rd.getOrganism());
            ps.setInt(2, rd.getUserID());
            ps.setString(3, rd.getPanel());
            ps.setString(4, rd.getDescription());
            if(rd.isVisible()){
                    ps.setInt(5, 1);
                }else{
                    ps.setInt(5, 0);
                }
            ps.setDate(6,rd.getCreated());
            if(rd.isPublic){
                ps.setInt(7, 1);
            }else{
                ps.setInt(7, 0);
            }
            ps.setLong(8, rd.getRnaDatasetID());
            int numUpdated=ps.executeUpdate();
            if(numUpdated==1){
                success=true;
            }
        }catch(Exception e){
            
        }
        return success;
    }
    
    public boolean deleteRNADataset(RNADataset rd, DataSource pool){
        boolean success=false;
        try{
            //delete results
            //delete samples
            //delete dataset
            
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
            log.error("Error getting new RNA_Dataset_ID:",e);
        }
        return ret;
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
                if(rs.getInt("Visible")==1){vis=true;}
                boolean pub=false;
                if(rs.getInt("ISPUBLIC")==1){pub=true;}
                ret=new RNADataset(rs.getLong("RNA_DATASET_ID"),
                                   rs.getString("Organism"),
                                   rs.getString("Panel"),
                                   rs.getString("Descripton"),
                                   vis,
                                   rs.getDate("CREATED"),
                                   pub,
                                   rs.getInt("USER_ID"),
                                   pool);
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
                if(rs.getInt("Visible")==1){vis=true;}
                boolean pub=false;
                if(rs.getInt("ISPUBLIC")==1){pub=true;}
                RNADataset tmp=new RNADataset(rs.getLong("RNA_DATASET_ID"),
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

    public void setRnaDatasetID(long rnaDatasetID) {
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

    public boolean isPublic() {
        return isPublic;
    }

    public void setPublic(boolean isPublic) {
        this.isPublic = isPublic;
    }
    public int getUserID(){
        return this.userID;
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

    public boolean isUserLoaded() {
        return isUserLoaded;
    }

    public void setUserLoaded(boolean isUserLoaded) {
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

    public boolean isSampleLoaded() {
        return isSampleLoaded;
    }

    public void setSampleLoaded(boolean isSampleLoaded) {
        this.isSampleLoaded = isSampleLoaded;
    }


    public void setPool(DataSource pool) {
        this.pool = pool;
    }

    public ArrayList<RNAResult> getResults() {
        return results;
    }

    public void setResults(ArrayList<RNAResult> results) {
        if(!isResultsLoaded){
            RNAResult myResult=new RNAResult();
            try{
                this.results=myResult.getRNAResultsByDataset(rnaDatasetID,pool);
                isResultsLoaded=true;
                for(int i=0;i<results.size();i++){
                    results.get(i).setDataset(this);
                }
            }catch(Exception e){
                isResultsLoaded=false;
                results=new ArrayList<>();
                e.printStackTrace(System.err);
                log.error("error retreiving RNADataSetResults for RNADataset:"+rnaDatasetID,e);
            }
        }
        this.results = results;
    }
    
    
}
