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

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to filter and statistics methods applied to a version of a dataset.  
 * <br>
 *  @author  Spencer Mahaffey
 */

public class FilterStep {
  	///DB Access Variables
        String selectq ="select * ";
        String fromq= "from FILTER_PARAMETERS ";
        String whereStatGroupID="where FILTER_GROUP_ID=? ";
        String orderq="ORDER BY STEP_NUMBER ";
        String updateq="UPDATE FILTER_PARAMTERS SET FILTER_NAME=?,FILTER_PARAMETERS=?,STEP_COUNT=? WHERE STEP_NUMBER=? AND FILTER_GROUP_ID=?";
        String insertq="INSERT INTO FILTER_PARAMETERS (FILTER_GROUP_ID,FILTER_NAME,FILTER_PARAMETERS,STEP_NUMBER,STEP_COUNT) VALUES (?,?,?,?,?)";
       
    
  	String filterName="";
        FilterGroup fg;
        String filterParam="";
        int stepNumber=-1;
        int stepCount=-1;
        private Logger log=null;
        
        public FilterStep(){
            log = Logger.getRootLogger();
        }
        
        public FilterStep[] getFilterSteps(FilterGroup fg, Connection conn){
            FilterStep[] ret=this.getFilterSteps(fg.getFilterGroupID(),conn);
            for(int i=0;i<ret.length;i++){
                ret[i].setFilterGroup(fg);
            }
            return ret;
        }
        
    public FilterStep[] getFilterSteps(int FilterGroupID, Connection conn){
        ArrayList<FilterStep> steps=new ArrayList<FilterStep>();
        try {
            String query=selectq+fromq+whereStatGroupID;
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, FilterGroupID);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                FilterStep tmps=new FilterStep();
                tmps.setFilterName(rs.getString("FILTER_NAME"));
                tmps.setFilterParameter(rs.getString("FILTER_PARAMETERS"));
                tmps.setStepNumber(rs.getInt("STEP_NUMBER"));
                tmps.setStepCount(rs.getInt("STEP_COUNT"));
                steps.add(tmps);
            }
            ps.close();
        } catch (SQLException ex) {
            log.error("FilterStep SQL ERROR:"+ex);
        }
        return steps.toArray(new FilterStep[0]);
    }
    
    public void addStep(int filterGroupID, String method,String parameters, int step_count, int stepNumber, Connection conn){
        try {
            String query=insertq;
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, filterGroupID);
            ps.setString(2, method);
            ps.setString(3, parameters);
            ps.setInt(4, stepNumber);
            ps.setInt(5, step_count);
            ps.executeUpdate();
            ps.close();
        } catch (SQLException ex) {
            log.error("FilterStep SQL ERROR:"+ex);
        }
    }
    
    public void updateStep(String method,String param,int stepCount,Connection conn){
        try {
            String query=updateq;
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, method);
            ps.setString(2, param);
            ps.setInt(3, stepCount);
            ps.setInt(4, this.getStepNumber());
            ps.setInt(5, this.getFilterGroup().getFilterGroupID());
            ps.executeUpdate();
            ps.close();
            this.setFilterName(method);
            this.setFilterParameter(param);
            this.setStepCount(stepCount);
            ps.close();
        } catch (SQLException ex) {
            
            log.error("FilterStep SQL ERROR:"+ex);
        }
    }

    public FilterGroup getFilterGroup() {
        return fg;
    }

    public void setFilterGroup(FilterGroup fg) {
        this.fg = fg;
    }

    public String getFilterName() {
        return filterName;
    }

    public void setFilterName(String filterName) {
        this.filterName = filterName;
    }

    public String getFilterParameter() {
        return filterParam;
    }

    public void setFilterParameter(String filterParam) {
        this.filterParam = filterParam;
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
        
    
}

