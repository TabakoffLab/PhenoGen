package edu.ucdenver.ccp.PhenoGen.data;



import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;



import edu.ucdenver.ccp.util.sql.Results;
import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.PhenoGen.util.DbUtils;
//import edu.ucdenver.ccp.PhenoGen.util.AsyncCopyFiles;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email; 
import edu.ucdenver.ccp.PhenoGen.web.SessionHandler; 
import java.util.ArrayList;
import java.sql.Date;

import edu.ucdenver.ccp.PhenoGen.data.FilterGroup;
import edu.ucdenver.ccp.PhenoGen.data.FilterStep;
import edu.ucdenver.ccp.PhenoGen.data.StatsGroup;
import edu.ucdenver.ccp.PhenoGen.data.StatsStep;
import java.sql.*;
import javax.sql.DataSource;


/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to filter and statistics methods applied to a version of a dataset.  
 * <br>
 *  @author  Spencer Mahaffey
 */

public class DSFilterStat {
    String selectq ="select * ";
    String fromq= "from DATASET_FILTER_STATS ";
    String whereDSDSVID="where DATASET_ID=? and VERSION=? and USER_ID=?";
    String andTD=" and FILTERDATE=? and FILTERTIME=?";
    String whereDSFSID="where DS_FILTER_STATS_ID=?";
    String orderbyq=" order by FILTERDATE,FILTERTIME";
    String insertq="INSERT INTO DATASET_FILTER_STATS (CREATED_DATE,EXPIRATION_DATE,FILTERDATE,FILTERTIME,DATASET_ID,VERSION,ANALYSIS_TYPE,USER_ID) VALUES (?,?,?,?,?,?,?,?)";
    String selectCurID="SELECT DATASET_FILTER_STATS_SEQ.CURRVAL FROM DUAL";
    String updateFilterGroupIDq="UPDATE DATASET_FILTER_STATS SET FILTER_GROUP_ID=? ";
    String updateStatsGroupIDq="UPDATE DATASET_FILTER_STATS SET STATS_GROUP_ID=? ";
    String deleteq="Delete from DATASET_FILTER_STATS ";
    String updateExpDateq="UPDATE DATASET_FILTER_STATS SET EXPIRATION_DATE=? ";
    
    
    
    
    
    private int dsFilterStatID=0;
    private Dataset parentDS;
    private Dataset.DatasetVersion parentDSVer;
    private FilterGroup filterGroup;
    private StatsGroup statsGroup;
    private String filterDate="";
    private String filterTime="";
    private String analysisType="";
    private Date expirationDate;
    private Timestamp createDate;
    private Logger log=null;
    private int userID=-99;
    
    
    
    public DSFilterStat(){
        log = Logger.getRootLogger();
    }
    
    public int createFilterStats(String filterdate,String filtertime,Dataset ds,Dataset.DatasetVersion dsVer,String analysisType,int userID,DataSource pool){
        int ret=-1;
        Connection dbConn=null;
        java.util.Date tmpD=new java.util.Date();
        java.util.Date tmpexpirD=new java.util.Date();
        tmpexpirD.setTime(tmpexpirD.getTime()+7*24*60*60*1000);
        
        Date expDate=new Date(tmpexpirD.getTime());
        Timestamp curDate=new Timestamp(tmpD.getTime());
        try {
            String query=insertq;
            dbConn=pool.getConnection();
            PreparedStatement ps = dbConn.prepareStatement(query);
            ps.setTimestamp(1,curDate);
            ps.setDate(2,expDate);
            ps.setString(3, filterdate);
            ps.setString(4, filtertime);
            ps.setInt(5, ds.getDataset_id());
            ps.setInt(6, dsVer.getVersion());
            ps.setString(7, analysisType);
            ps.setInt(8, userID);
            ps.executeUpdate();
            ps.close();
            dbConn.close();
            dbConn=null;
            dbConn=pool.getConnection();
            ps = dbConn.prepareStatement(selectCurID);
            ResultSet rs=ps.executeQuery();
            if(rs.next()){
                //System.out.println("RS has next");
                //System.out.println(rs.toString());
                //System.out.println(rs.getMetaData().getColumnClassName(1));
                ret=rs.getInt(1);
            }else{
                //System.out.println("RS has no results");
            }
            ps.close();
            dbConn.close();
            dbConn=null;
        }catch(SQLException e){
            log.error("DSFilterStats SQL ERROR:"+e);
        }finally{
                            if (dbConn != null) {
                                 try { dbConn.close(); } catch (SQLException e) { ; }
                                 dbConn = null;
                            }
                     }
        return ret;
    }
    
    public void createFilterGroup(int step_count,int phenotypeGroupID,int paramGroupID,DataSource pool){
        FilterGroup tmpnew=new FilterGroup();
        int id=tmpnew.addFilterGroup(step_count,phenotypeGroupID,paramGroupID,pool);
        filterGroup=new FilterGroup(id,pool);
        updateFilterGroupID(pool);
    }
    
    public void createStatsGroup(int step_count,int status,DataSource pool){
        System.out.println("createStatsGroup called");
        StatsGroup tmpnew=new StatsGroup();
        int id=tmpnew.addStatsGroup(step_count,status,pool);
        //System.out.println("createStatsGroup id returned"+id);
        statsGroup=new StatsGroup(id,pool);
        //System.out.println("getStatGroupfromDB"+statsGroup.getStatsGroupID());
        updateStatsGroupID(pool);
    }
    
    public void addFilterStep(String method,String parameters,int step_count, int stepNumber,int phenotypeGroupID,int paramGroupID,DataSource pool){
        if(filterGroup==null||filterGroup.getFilterGroupID()==-1){
            createFilterGroup(step_count,phenotypeGroupID,paramGroupID,pool);
        }
        filterGroup.addStep(method,parameters, step_count,stepNumber,pool);
    }
    
    public void addStatsStep(String method,String parameters, int step_count,int stepNumber,int status, DataSource pool){
        System.out.println("ADD STats STep: SGRoup id:"+statsGroup.getStatsGroupID());
        if(statsGroup==null||statsGroup.getStatsGroupID()<=0){
            createStatsGroup(step_count,status,pool);
        }
        statsGroup.addStep(method,parameters,step_count,stepNumber,status,pool);
        
    }
    
    public DSFilterStat[] getFilterStatsFromDB(Dataset ds,Dataset.DatasetVersion dsVer,int userID, DataSource pool){
        parentDS=ds;
        parentDSVer=dsVer;
        Connection dbConn=null;
        ArrayList<DSFilterStat> ret=new ArrayList<DSFilterStat>();
        try {
            String query=selectq+fromq+whereDSDSVID+orderbyq;
            dbConn=pool.getConnection();
            PreparedStatement ps = dbConn.prepareStatement(query);
            ps.setInt(1, ds.getDataset_id());
            ps.setInt(2, dsVer.getVersion());
            ps.setInt(3, userID);
            
            ResultSet rs = ps.executeQuery();
            
            while(rs.next()){
                
                DSFilterStat tmps=new DSFilterStat();
                tmps.setAnalysisType(rs.getString("ANALYSIS_TYPE"));
                tmps.setDSFilterStatID(rs.getInt("DS_FILTER_STATS_ID"));
                Timestamp tmp=rs.getTimestamp("EXPIRATION_DATE");
                if(tmp!=null)
                    tmps.setExpirationDate(tmp.getTime());
                tmp=rs.getTimestamp("CREATED_DATE");
                if(tmp!=null)
                    tmps.setCreateDate(tmp.getTime());
                tmps.setFilterDate(rs.getString("FILTERDATE"));
                tmps.setFilterTime(rs.getString("FILTERTIME"));
                tmps.setParentDS(parentDS);
                tmps.setParentDSVer(parentDSVer);
                tmps.setStatsGroup(new StatsGroup(rs.getInt("STATS_GROUP_ID"),pool));
                tmps.setFilterGroup(new FilterGroup(rs.getInt("FILTER_GROUP_ID"),pool));
                ret.add(tmps);
            }
            ps.close();
            dbConn.close();
            dbConn=null;
        } catch (SQLException ex) {
           log.error("DSFilterStats SQL ERROR:"+ex);
        }finally{
           if (dbConn != null) {
              try { dbConn.close(); } catch (SQLException e) { ; }
                                 dbConn = null;
              }
           }
        return ret.toArray(new DSFilterStat[0]);
    }
    
    public DSFilterStat getFilterStatFromDB(int ds_ID,int ver,int userID,String filterDate,String filterTime, DataSource pool){
        System.out.println("get:"+ds_ID+":"+ver+":"+filterDate+":"+filterTime);
        Connection dbConn=null;
        DSFilterStat ret=new DSFilterStat();
        try {
            String query=selectq+fromq+whereDSDSVID+andTD;
            dbConn=pool.getConnection();
            PreparedStatement ps = dbConn.prepareStatement(query);
            ps.setInt(1, ds_ID);
            ps.setInt(2, ver);
            ps.setInt(3, userID);
            ps.setString(4, filterDate);
            ps.setString(5, filterTime);
            
            ResultSet rs = ps.executeQuery();
            //log.debug("Get DSFS by date and time:"+filterDate+"_"+filterTime);
            if(rs.next()){
                //log.debug("ID:"+rs.getInt("DS_FILTER_STATS_ID"));
                DSFilterStat tmps=new DSFilterStat();
                tmps.setAnalysisType(rs.getString("ANALYSIS_TYPE"));
                tmps.setDSFilterStatID(rs.getInt("DS_FILTER_STATS_ID"));
                Timestamp tmp=rs.getTimestamp("EXPIRATION_DATE");
                if(tmp!=null)
                    tmps.setExpirationDate(tmp.getTime());
                tmp=rs.getTimestamp("CREATED_DATE");
                if(tmp!=null)
                    tmps.setCreateDate(tmp.getTime());
                tmps.setFilterDate(rs.getString("FILTERDATE"));
                tmps.setFilterTime(rs.getString("FILTERTIME"));
                tmps.setStatsGroup(new StatsGroup(rs.getInt("STATS_GROUP_ID"),pool));
                tmps.setFilterGroup(new FilterGroup(rs.getInt("FILTER_GROUP_ID"),pool));
                ret=tmps;
            }else{
                System.out.println("no results");
            }
            ps.close();
            dbConn.close();
            dbConn=null;
        } catch (SQLException ex) {
           log.error("DSFilterStats SQL ERROR:"+ex);
        }finally{
           if (dbConn != null) {
              try { dbConn.close(); } catch (SQLException e) { ; }
                                 dbConn = null;
              }
           }
        return ret;
    }

    public void updateFilterGroupID(DataSource pool){
        Connection dbConn=null;
        try {
            String query=updateFilterGroupIDq+whereDSFSID;
            dbConn=pool.getConnection();
            PreparedStatement ps = dbConn.prepareStatement(query);
            ps.setInt(1, filterGroup.getFilterGroupID());
            ps.setInt(2, this.getDSFilterStatID());
            ps.executeUpdate();
            ps.close();
            dbConn.close();
            dbConn=null;
        }catch(SQLException ex){
            log.error("DSFilterStats SQL ERROR:"+ex);
        }finally{
           if (dbConn != null) {
              try { dbConn.close(); } catch (SQLException e) { ; }
                                 dbConn = null;
              }
           }
    }
    
    public void updateStatsGroupID(DataSource pool){
        Connection dbConn=null;
        try {
            String query=updateStatsGroupIDq+whereDSFSID;
            dbConn=pool.getConnection();
            PreparedStatement ps = dbConn.prepareStatement(query);
            ps.setInt(1, statsGroup.getStatsGroupID());
            ps.setInt(2, this.getDSFilterStatID());
            ps.executeUpdate();
            ps.close();
            dbConn.close();
            dbConn=null;
            System.out.println("UPDATE"+statsGroup.getStatsGroupID()+":"+this.getDSFilterStatID());
        }catch(SQLException ex){
            log.error("DSFilterStats SQL ERROR:"+ex);
        }finally{
           if (dbConn != null) {
              try { dbConn.close(); } catch (SQLException e) { ; }
                                 dbConn = null;
              }
           }
    }
    
    public String getAnalysisType() {
        if(analysisType.equals("diffExp")){
            return "Differential Expression";
        }else if(analysisType.equals("cluster")){
            return "Clustering";
        }else if(analysisType.equals("correlation")){
            return "Correlation";
        }
        return analysisType;
    }
    public String getAnalysisTypeShort() {
        return analysisType;
    }
    
    public void setAnalysisType(String analysisType) {
            this.analysisType = analysisType;
    }

    public int getDSFilterStatID() {
        return dsFilterStatID;
    }

    public void setDSFilterStatID(int dsFilterStatID) {
        this.dsFilterStatID = dsFilterStatID;
    }

    public Date getExpirationDate() {
        return expirationDate;
    }

    public void setExpirationDate(long expirationDate) {
        this.expirationDate = new Date(expirationDate);
    }

    public String getFilterDate() {
        return filterDate;
    }

    public void setFilterDate(String filterDate) {
        this.filterDate = filterDate;
    }

    public FilterGroup getFilterGroup() {
        if(filterGroup.getFilterGroupID()==-1){
            return null;
        }
        return filterGroup;
    }

    public void setFilterGroup(FilterGroup filterGroup) {
        this.filterGroup = filterGroup;
    }

    public String getFilterTime() {
        return filterTime;
    }

    public void setFilterTime(String filterTime) {
        this.filterTime = filterTime;
    }

    public Dataset getParentDS() {
        return parentDS;
    }

    public void setParentDS(Dataset parentDS) {
        this.parentDS = parentDS;
    }

    public Dataset.DatasetVersion getParentDSVer() {
        return parentDSVer;
    }

    public void setParentDSVer(Dataset.DatasetVersion parentDSVer) {
        this.parentDSVer = parentDSVer;
    }

    public StatsGroup getStatsGroup() {
        if(statsGroup.getStatsGroupID()==-1){
            return null;
        }
        return statsGroup;
    }

    public void setStatsGroup(StatsGroup statsGroup) {
        this.statsGroup = statsGroup;
    }

    public Timestamp getCreateDate() {
        return createDate;
    }

    public void setCreateDate(long createDate) {
        this.createDate = new Timestamp(createDate);
    }
    
    public void deleteFromDB(DataSource pool){
        Connection dbConn=null;
        try {
            this.filterGroup.deleteFromDB(pool);
            this.statsGroup.deleteFromDB(pool);
            String query=deleteq+whereDSFSID;
            dbConn=pool.getConnection();
            PreparedStatement ps = dbConn.prepareStatement(query);
            ps.setInt(1, this.getDSFilterStatID());
            ps.executeUpdate();
            ps.close();
            dbConn.close();
            dbConn=null;
        } catch (SQLException ex) {
            log.error("DSFilterStats SQL ERROR:"+ex,ex);
        }finally{
           if (dbConn != null) {
              try { dbConn.close(); } catch (SQLException e) { ; }
                                 dbConn = null;
              }
           }
    }
    
    public void extend(Connection conn){
        try {
            String query=updateExpDateq+whereDSFSID;
            PreparedStatement ps = conn.prepareStatement(query);
            expirationDate.setTime(expirationDate.getTime()+7*24*60*60*1000);
            ps.setTimestamp(1, new Timestamp(expirationDate.getTime()));
            ps.setInt(2, this.getDSFilterStatID());
            ps.executeUpdate();
            ps.close();
        } catch (SQLException ex) {
            log.error("DSFilterStats SQL ERROR:"+ex,ex);
        }
    }
  
    public int getPhenotypeParamGroupID(){
        int ret=-99;
        if(this.filterGroup!=null){
            ret=filterGroup.getPhenotypeParamGroupID();
        }
        return ret;
    }
    public int getParameterGroupID(){
        int ret=-99;
        if(this.filterGroup!=null){
            ret=filterGroup.getParamGroupID();
        }
        return ret;
    }
}

