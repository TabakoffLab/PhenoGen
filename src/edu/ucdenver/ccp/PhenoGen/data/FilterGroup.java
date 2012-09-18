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



/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to filter and statistics methods applied to a version of a dataset.  
 * <br>
 *  @author  Spencer Mahaffey
 */

public class FilterGroup {
    ///DB Access Variables
    String selectq ="select * ";
    String fromq= "from FILTER_GROUP ";
    String whereFilterGroupID="where FILTER_GROUP_ID=?";
    String updateCountq="UPDATE FILTER_GROUP SET LAST_COUNT=? "+whereFilterGroupID;
    String insertq="INSERT INTO FILTER_GROUP (LAST_COUNT,PHENOTYPEPARAMGROUPID,Parameter_Group_ID) VALUES (?,?,?)";
    String insertqwo="INSERT INTO FILTER_GROUP (LAST_COUNT,Parameter_Group_ID) VALUES (?,?)";
    String selectCurID="SELECT FILTER_GROUP_SEQ.CURRVAL FROM DUAL";
    String deleteq="Delete from FILTER_GROUP ";
    String deleteStepsq="Delete from FILTER_PARAMETERS ";
        
    int filterGroupID=-1;
    int phenotypeParamGroupID=-99;
    int paramGroupID=-99;
    int lastCount=-1;
    FilterStep[] filterSteps;
    private Logger log=null;
    
    public int addFilterGroup(int last,int phenotypeParamGroupID,int paramGroupID, Connection conn){
        int fgID=-1;
        try {
            String query=insertqwo;
            if(phenotypeParamGroupID>0){
                query=insertq;
            }
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1,last);
            if(phenotypeParamGroupID>0){
                ps.setInt(2, phenotypeParamGroupID);
                ps.setInt(3, paramGroupID);
            }else{
                ps.setInt(2, paramGroupID);
            }
            ps.executeUpdate();
            ps.close();
            ps = conn.prepareStatement(selectCurID);
            ResultSet rs=ps.executeQuery();
            if(rs.next()){
                fgID=rs.getInt(1);
            }
            ps.close();
        } catch (SQLException ex) {
            log.error("FilterGroup SQL ERROR:"+ex);
        }
        
        System.out.println("returning FGID="+fgID);
        return fgID;
    }
    public FilterGroup(){
        log = Logger.getRootLogger();
        
    }
    public FilterGroup(int filterGroupID,Connection conn){
        log = Logger.getRootLogger();
        if(filterGroupID>0){
            this.filterGroupID=filterGroupID;
            this.setupFilterGroupFromDB(conn);
            filterSteps=new FilterStep().getFilterSteps(this, conn);
        }else{
            filterSteps=new FilterStep[0];
        }
    }

    public int getLastCount() {
        return lastCount;
    }

    public void setLastCount(int lastCount) {
        this.lastCount = lastCount;
    }

    public int getFilterGroupID() {
        return filterGroupID;
    }

    public void setFilterGroupID(int filterGroupID) {
        this.filterGroupID = filterGroupID;
    }

    public FilterStep[] getFilterSteps() {
        if(filterSteps==null){
            filterSteps=new FilterStep[0];
        }
        return filterSteps;
    }

    public void setFilterSteps(FilterStep[] filterSteps) {
        this.filterSteps = filterSteps;
    }
    
    public void setupFilterGroupFromDB(Connection conn){
        try {
            String query=selectq+fromq+whereFilterGroupID;
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, filterGroupID);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                    this.setLastCount(rs.getInt("LAST_COUNT"));
                    this.setPhenotypeParamGroupID(rs.getInt("PHENOTYPEPARAMGROUPID"));
                    this.setParamGroupID(rs.getInt("Parameter_Group_ID"));
            }else{
                //error
            }
            ps.close();
        } catch (SQLException ex) {
            log.error("FilterGroup SQL ERROR:"+ex);
        }
    }
    
    public void updateLastCount(int lastCount,Connection conn){
        try {
            String query=updateCountq;
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, lastCount);
            ps.setInt(2, filterGroupID);
            ps.executeUpdate();
            ps.close();
        } catch (SQLException ex) {
            log.error("FilterGroup SQL ERROR:"+ex);
        }
    }
    
    public void addStep(String method,String parameters, int step_count, int stepNumber,Connection conn){
        int curInd=stepNumberIndex(stepNumber);
        if(curInd>-1){
            filterSteps[curInd].updateStep(method,parameters,step_count,conn);
            if(curInd==filterSteps.length-1){
                this.updateLastCount(step_count,conn);
            }
        }else{
            if(stepNumber==-1){
                int max=findMaxStepNumber();
                stepNumber=max+1;
            }
            new FilterStep().addStep(this.getFilterGroupID(),method, parameters, step_count,stepNumber, conn);
            filterSteps=new FilterStep().getFilterSteps(this, conn);
            this.updateLastCount(step_count,conn);
        }
    }
    private int findMaxStepNumber(){
        int ret=0;
        if(filterSteps!=null){
            for(int i=0;i<filterSteps.length;i++){
                if(filterSteps[i].getStepNumber()>ret){
                    ret=filterSteps[i].getStepNumber();
                }
            }
        }
        return ret;
    }
    private int stepNumberIndex(int stepNum){
        int ret=-1;
        if(filterSteps!=null){
            for(int i=0;i<filterSteps.length&&ret==-1;i++){
                if(filterSteps[i].getStepNumber()==stepNum){
                    ret=i;
                }
            }
        }
        return ret;
    }
    
    public void deleteFromDB(Connection conn){
        try {
            String stepquery=deleteStepsq+whereFilterGroupID;
            PreparedStatement ps = conn.prepareStatement(stepquery);
            ps.setInt(1, this.getFilterGroupID());
            ps.executeUpdate();
            ps.close();
            String query=deleteq+whereFilterGroupID;
            ps = conn.prepareStatement(query);
            ps.setInt(1, this.getFilterGroupID());
            ps.executeUpdate();
            ps.close();
        } catch (SQLException ex) {
            log.error("FilterGroup SQL ERROR:"+ex);
        }
    }
    
    public void setPhenotypeParamGroupID(int id){
        this.phenotypeParamGroupID=id;
    }
    
    public int getPhenotypeParamGroupID(){
        return this.phenotypeParamGroupID;
    }
    public void setParamGroupID(int id){
        this.paramGroupID=id;
    }
    
    public int getParamGroupID(){
        return this.paramGroupID;
    }
}

