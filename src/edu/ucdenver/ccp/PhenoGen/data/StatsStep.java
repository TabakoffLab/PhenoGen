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
import javax.sql.DataSource;


/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to filter and statistics methods applied to a version of a dataset.  
 * <br>
 *  @author  Spencer Mahaffey
 */

public class StatsStep {
        ///DB Access Variables
        String selectq ="select * ";
        String fromq= "from STAT_PARAMETERS ";
        String whereStatGroupID="where STAT_GROUP_ID=? ";
        String orderq="ORDER BY STEP_NUMBER ";
        String updateq="UPDATE STAT_PARAMETERS SET STAT_METHOD_NAME=?,STAT_PARAMETERS=?,STEP_COUNT=? WHERE STEP_NUMBER=? AND STAT_GROUP_ID=?";
        String insertq="INSERT INTO STAT_PARAMETERS (STAT_GROUP_ID,STAT_METHOD_NAME,STAT_PARAMETERS,STEP_NUMBER,STEP_COUNT) VALUES (?,?,?,?,?)";
        
       
    
  	String statsName="";
        StatsGroup sg;
        String statsParam="";
        int stepNumber=-1;
        int stepCount=-1;
        private Logger log=null;
        
        StatsStep(){
            log = Logger.getRootLogger();
        }
        
        public StatsStep[] getStatsSteps(StatsGroup sg, DataSource pool){
            StatsStep[] ret=this.getStatsSteps(sg.getStatsGroupID(),pool);
            for(int i=0;i<ret.length;i++){
                ret[i].setStatsGroup(sg);
            }
            return ret;
        }
        
    public StatsStep[] getStatsSteps(int StatsGroupID, DataSource pool){
        ArrayList<StatsStep> steps=new ArrayList<StatsStep>();
        Connection conn=null;
        try {
            
            String query=selectq+fromq+whereStatGroupID+orderq;
            conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, StatsGroupID);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                StatsStep tmps=new StatsStep();
                tmps.setStatsName(rs.getString("STAT_METHOD_NAME"));
                tmps.setStatsParameter(rs.getString("STAT_PARAMETERS"));
                tmps.setStepNumber(rs.getInt("STEP_NUMBER"));
                tmps.setStepCount(rs.getInt("STEP_COUNT"));
                steps.add(tmps);
            }
            rs.close();
            ps.close();
        } catch (SQLException ex) {
            log.error("StatsStep SQL ERROR:"+ex);
        }finally{
                   if (conn != null) {
                        try { conn.close(); } catch (SQLException e) { ; }
                        conn = null;
                   }
                }
        return steps.toArray(new StatsStep[0]);
    }
    
    public void addStep(int StatsGroupID, String method,String parameters, int step_count, int stepNumber, DataSource pool){
        Connection conn=null;
        try {
            String query=insertq;
            conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, StatsGroupID);
            ps.setString(2, method);
            ps.setString(3, parameters);
            ps.setInt(4, stepNumber);
            ps.setInt(5, step_count);
            ps.executeUpdate();
            ps.close();
            conn.close();
            conn=null;
        } catch (SQLException ex) {
            log.error("StatsStep SQL ERROR:"+ex);
        }finally{
                   if (conn != null) {
                        try { conn.close(); } catch (SQLException e) { ; }
                        conn = null;
                   }
                }
    }
    
    public void updateStep(String method,String param,int stepCount,DataSource pool){
        Connection conn=null;
        try {
            String query=updateq;
            conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, method);
            ps.setString(2, param);
            ps.setInt(3, stepCount);
            ps.setInt(4, this.getStepNumber());
            ps.setInt(5, this.getStatsGroup().getStatsGroupID());
            ps.executeUpdate();
            ps.close();
            conn.close();
            conn=null;
            this.setStatsName(method);
            this.setStatsParameter(param);
            this.setStepCount(stepCount);
        } catch (SQLException ex) {
            log.error("StatsStep SQL ERROR:"+ex);
        }finally{
                   if (conn != null) {
                        try { conn.close(); } catch (SQLException e) { ; }
                        conn = null;
                   }
                }
    }

    public StatsGroup getStatsGroup() {
        return sg;
    }

    public void setStatsGroup(StatsGroup sg) {
        this.sg = sg;
    }

    public String getStatsName() {
        if(statsName.substring(statsName.indexOf(":")+1).equals("'BH'")){
            return statsName.replaceAll("'BH'", "Benjamini and Hochberg");
        }else if(statsName.substring(statsName.indexOf(":")+1).equals("'BY'")){
            return statsName.replaceAll("'BY'", "Benjamini and Yekutieli");
        }
        return statsName;
    }

    public void setStatsName(String statsName) {
            this.statsName = statsName;
    }

    public String getStatsParameter() {
        
        return statsParam;
    }

    public void setStatsParameter(String statsParam) {
        this.statsParam = statsParam;
    }

    public int getStepCount() {
        return stepCount;
    }

    public void setStepCount(int stepCount) {
        this.stepCount = stepCount;
    }

    public int getStepNumber() {
        return stepNumber;
    }

    public void setStepNumber(int stepNumber) {
        this.stepNumber = stepNumber;
    }
        
    public String getShortParam(){
        String[] tmp=statsParam.split(",");
        String ret="";
        int length=tmp.length;
        if(this.statsName.contains("Clustering")){
            length--;
        }
        for(int i=0;i<length;i++){
            if(tmp[i].contains("'null'")){
                
            }else{
                tmp[i]=tmp[i].replaceAll("parameter", "p");
                if(ret.equals("")){
                    ret=tmp[i];
                }else{
                    ret=ret+","+tmp[i];
                }
            }
        }
        return ret;
    }    
    
    public int getClusterIDFromParam(){
        int ret=-99;
        int ind=statsParam.indexOf("ClusterID=");
        if(ind>0){
            String tmp=statsParam.substring(ind+10);
            ret=Integer.parseInt(tmp);
        }
        return ret;
    }
}

