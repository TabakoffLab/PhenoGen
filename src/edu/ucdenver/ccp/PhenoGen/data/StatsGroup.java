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
import javax.sql.DataSource;



/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to filter and statistics methods applied to a version of a dataset.  
 * <br>
 *  @author  Spencer Mahaffey
 */

public class StatsGroup {
    ///DB Access Variables
    String selectq ="select * ";
    String fromq= "from STAT_GROUP ";
    String whereStatGroupID="where STAT_GROUP_ID=?";
    String updateCountq="UPDATE STAT_GROUP SET LAST_COUNT=? "+whereStatGroupID;
    String updateStatusq="UPDATE STAT_GROUP SET STATUS=? , LAST_COUNT=? "+whereStatGroupID;
    String insertq="INSERT INTO STAT_GROUP (LAST_COUNT,STATUS) VALUES (?,?)";
    String selectCurID="SELECT STAT_GROUP_SEQ.CURRVAL FROM DUAL";
    String deleteq="Delete from STAT_GROUP ";
    String deleteStepsq="Delete from STAT_PARAMETERS ";
            
        
    int statsGroupID=-1;
    int lastCount=-1;
    int status=-99;
    StatsStep[] statsSteps;
    private Logger log=null;
    
    
    public int addStatsGroup(int last,int status, DataSource pool){
        System.out.println("ADDSTATSGROUP CALLED");
        Connection conn=null;
        int sgID=-1;
        try {
            String query=insertq;
            conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1,last);
            ps.setInt(2,status);
            ps.executeUpdate();
            ps.close();
            System.out.println();
            ps = conn.prepareStatement(selectCurID);
            ResultSet rs=ps.executeQuery();
            if(rs.next()){
                sgID=rs.getInt(1);
            }
            ps.close();
            conn.close();
            conn=null;
        } catch (SQLException ex) {
            log.error("StatsGroup SQL ERROR:"+ex);
            ex.printStackTrace(System.out);
        }finally{
                   if (conn != null) {
                        try { conn.close(); } catch (SQLException e) { ; }
                        conn = null;
                   }
                }
        System.out.println("Added Stats Group ID:"+sgID);
        return sgID;
    }
    public StatsGroup(){
        log = Logger.getRootLogger();
    }
    public StatsGroup(int statsGroupID,DataSource pool){
        log = Logger.getRootLogger();
        this.statsGroupID=statsGroupID;
        this.setupStatsGroupFromDB(pool);
        statsSteps=new StatsStep().getStatsSteps(this, pool);
    }

    public int getLastCount() {
        return lastCount;
    }

    public void setLastCount(int lastCount) {
        this.lastCount = lastCount;
    }

    public int getStatsGroupID() {
        return statsGroupID;
    }

    public void setStatsGroupID(int statsGroupID) {
        this.statsGroupID = statsGroupID;
    }

    public StatsStep[] getStatsSteps() {
        if(statsSteps==null){
            statsSteps=new StatsStep[0];
        }
        return statsSteps;
    }

    public void setStatsSteps(StatsStep[] statsSteps) {
        this.statsSteps = statsSteps;
    }
    
    public void setupStatsGroupFromDB(DataSource pool){
        Connection conn=null;
        try {
            String query=selectq+fromq+whereStatGroupID;
            conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, statsGroupID);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                    this.setLastCount(rs.getInt("LAST_COUNT"));
                    this.setStatus(rs.getInt("STATUS"));
            }else{
                //log.error("StatsGroup SQL ERROR: No matches for StatsGroupID"+statsGroupID);
            }
            ps.close();
            conn.close();
            conn=null;
        } catch (SQLException ex) {
            log.error("StatsGroup SQL ERROR:"+ex);
        }finally{
                   if (conn != null) {
                        try { conn.close(); } catch (SQLException e) { ; }
                        conn = null;
                   }
                }
    }
    
    public void updateLastCount(int lastCount,DataSource pool){
        Connection conn=null;
        try {
            String query=updateCountq;
            conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, lastCount);
            ps.setInt(2, statsGroupID);
            ps.executeUpdate();
            ps.close();
            conn.close();
            conn=null;
        } catch (SQLException ex) {
            log.error("StatsGroup SQL ERROR:"+ex);
        }finally{
                   if (conn != null) {
                        try { conn.close(); } catch (SQLException e) { ; }
                        conn = null;
                   }
                }
    }
    
    public void updateStatus(int status,int lastCount,DataSource pool){
        Connection conn=null;
        try {
            String query=updateStatusq;
            conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, status);
            ps.setInt(2, lastCount);
            ps.setInt(3, statsGroupID);
            ps.executeUpdate();
            ps.close();
            conn.close();
            conn=null;
            this.status=status;
            this.lastCount=lastCount;
        } catch (SQLException ex) {
            log.error("StatsGroup SQL ERROR:"+ex);
        }finally{
                   if (conn != null) {
                        try { conn.close(); } catch (SQLException e) { ; }
                        conn = null;
                   }
                }
    }
    
    public void addStep(String method,String parameters, int step_count, int stepNumber,int status,DataSource pool){
        int curInd=stepNumberIndex(stepNumber);
        if(curInd>-1){
            statsSteps[curInd].updateStep(method,parameters,step_count,pool);
        }else{
            new StatsStep().addStep(this.getStatsGroupID(),method, parameters, step_count,stepNumber, pool);
            statsSteps=new StatsStep().getStatsSteps(this, pool);
        }
        this.updateStatus(status, step_count, pool);
    }
    
    private int stepNumberIndex(int stepNum){
        int ret=-1;
        if(statsSteps!=null){
            for(int i=0;i<statsSteps.length&&ret==-1;i++){
                if(statsSteps[i].getStepNumber()==stepNum){
                    ret=i;
                }
            }
        }
        return ret;
    }
    
    

    public int getStatus() {
        return status;
    }
    public void setStatus(int status) {
        this.status=status;
    }
    
    public String getStatusString(){
        switch(status){
            case 1:
                return "Done";

            case 0:
                return "Running";

            case -1:
                return "Error";
            case -99:
                return "";
        }
        
        return "Error:Invalid Status";
        
    }
    
    public void deleteFromDB(DataSource pool){
        Connection conn=null;
        try {
            String stepquery=deleteStepsq+whereStatGroupID;
            conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(stepquery);
            ps.setInt(1, this.getStatsGroupID());
            ps.executeUpdate();
            ps.close();
            String query=deleteq+whereStatGroupID;
            ps = conn.prepareStatement(query);
            ps.setInt(1, this.getStatsGroupID());
            ps.executeUpdate();
            ps.close();
            conn.close();
            conn=null;
        } catch (SQLException ex) {
            log.error("FilterGroup SQL ERROR:"+ex);
        }finally{
                   if (conn != null) {
                        try { conn.close(); } catch (SQLException e) { ; }
                        conn = null;
                   }
                }
    }
    
    public int getClusterIDFromParam(){
        int ret=-99;
        for(int i=0;i<this.statsSteps.length&&ret==-99;i++){
            int tmp=statsSteps[i].getClusterIDFromParam();
            if(tmp>0){
                ret=tmp;
            }
        }
        return ret;
    }
    
}

