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
import java.util.HashMap;
import javax.sql.DataSource;
import org.apache.log4j.Logger;

/**
 *
 * @author smahaffey
 */
public class RNAResultVariable {
    private long rnaResultVarID;
    private long rnaDatasetResultID;
    private String name;
    private ArrayList<String> values;
    
    private final Logger log;
    private final String select="select rrv.*,rrvv.value from RNA_RESULT_VARIABLES rrv, RNA_RESULT_VAR_VALUES rrvv where rrv.RNA_RVAR_ID=rrvv.RNA_RVAR_ID and rrv.RNA_DATASET_RESULT_ID=";
    private final String orderBy=" order by rrv.RNA_RVAR_ID";
    private final String delete="delete RNA_RESULT_VARIABLES where RNA_RVAR_ID = ?";
    private final String deleteValues="delete RNA_RESULT_VAR_VALUES where RNA_RVAR_ID = ?";
    
    public RNAResultVariable(){
        log = Logger.getRootLogger();
    }
    public RNAResultVariable(long rnaResultVarID, long rnaDatasetResultID, String name, ArrayList<String> values){
        log = Logger.getRootLogger();
        this.setRNAResultVarID(rnaResultVarID);
        this.setRNADatasetResultID(rnaDatasetResultID);
        this.setName(name);
        this.setValues(values);
    }
    
    public ArrayList<RNAResultVariable> getRNAResultVariablesByDataset(long rnaDatasetResultID,DataSource pool){
        String query=select+rnaDatasetResultID+orderBy;
        return this.getRNAResultVariablesByQuery(query, pool);
    }
    
    private ArrayList<RNAResultVariable> getRNAResultVariablesByQuery(String query, DataSource pool){
        ArrayList<RNAResultVariable> ret=new ArrayList<>();
        HashMap<String,RNAResultVariable> hm=new HashMap<String,RNAResultVariable>();
        try(Connection conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query)){
            ResultSet rs=ps.executeQuery();
            while(rs.next()){
                long tmpID=rs.getLong("RNA_RVAR_ID");
                if(hm.containsKey(Long.toString(tmpID))){
                    RNAResultVariable tmp=hm.get(Long.toString(tmpID));
                    tmp.addValue(rs.getString("VALUE"));
                }else{
                    ArrayList<String> tmpV=new ArrayList<String>();
                    tmpV.add(rs.getString("VALUE"));
                    RNAResultVariable tmp=new RNAResultVariable(tmpID,
                                                rs.getLong("RNA_DATASET_RESULT_ID"),
                                                rs.getString("VARIABLE_NAME"),
                                                tmpV);
                    hm.put(Long.toString(tmpID), tmp);
                    ret.add(tmp);
                }
            }
            ps.close();
            conn.close();
        }catch(SQLException e){
            log.error("Error getting RNADataset from \n"+query,e);
        }
        return ret;
    }

    public boolean deleteRNAResultVariable(RNAResultVariable rv, DataSource pool){
        boolean success=false;
        try{
            //delete resultsample entries
            try(Connection conn=pool.getConnection()){
                PreparedStatement ps=conn.prepareStatement(deleteValues);
                ps.setLong(1, rv.getRNAResultVarID());
                boolean tmpSuccess=ps.execute();
                if(tmpSuccess){
                    success=true;
                }
                ps.close();
            }catch(Exception e){

            }
            //delete result file
            try(Connection conn=pool.getConnection()){
                PreparedStatement ps=conn.prepareStatement(delete);
                ps.setLong(1, rv.getRNAResultVarID());
                boolean tmpSuccess=ps.execute();
                if(tmpSuccess){
                    success=true;
                }
                ps.close();
            }catch(Exception e){

            }
            success=true;
        }catch(Exception e){
            
        }
        return success;
    }
    
    public long getRNAResultVarID() {
        return rnaResultVarID;
    }

    public void setRNAResultVarID(long rnaResultVarID) {
        this.rnaResultVarID = rnaResultVarID;
    }

    public long getRNADatasetResultID() {
        return rnaDatasetResultID;
    }

    public void setRNADatasetResultID(long rnaDatasetResultID) {
        this.rnaDatasetResultID = rnaDatasetResultID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public ArrayList<String> getValues() {
        return values;
    }

    public void setValues(ArrayList<String> values) {
        this.values = values;
    }
    public void addValue(String value){
        this.values.add(value);
    }
}
