package edu.ucdenver.ccp.PhenoGen.tools.analysis;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;

import edu.ucdenver.ccp.PhenoGen.tools.analysis.AsyncGeneDataExpr;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import org.apache.log4j.Logger;
import javax.sql.DataSource;


public class SyncAndClose {

    Date start;
    Date end;
    Connection dbConn;
    ArrayList<AsyncGeneDataExpr> list;
    BufferedWriter outGroup;
    BufferedWriter outIndiv;
    int usageID;
    String updateSQL="update TRANS_DETAIL_USAGE set TIME_ASYNC_GENE_DATA_EXPR=? , RESULT=? where TRANS_DETAIL_ID=?";
    String message="";
    String outputDir="";
    private Logger log = null;
    DataSource pool=null;

    public SyncAndClose(Date start,ArrayList<AsyncGeneDataExpr> list,Connection dbConn,DataSource pool,BufferedWriter outGroup,BufferedWriter outIndiv,int usageID,String outputDir) {
        this.start=start;
        this.list=list;
        this.dbConn=dbConn;
        this.pool=pool;
        this.outGroup=outGroup;
        this.outIndiv=outIndiv;
        this.usageID=usageID;
        this.outputDir=outputDir;
        log = Logger.getRootLogger();
    }
    
    public synchronized void processFiles(AsyncGeneDataExpr agde,String groupFile,String outGroupPath,String outIndivPath,String tissue){
        HashMap groupNum = readGroups(groupFile);
        processGroupFile(outGroupPath, groupNum, tissue, outGroup);
        processIndivFile(outIndivPath, tissue, outIndiv);
        File group = new File(outGroupPath);
        group.delete();
        File indiv = new File(outIndivPath);
        indiv.delete();
    }

    public synchronized void done(AsyncGeneDataExpr agde,String message){
        log.debug("SyncAndClose.done() called by "+agde.getId());
        //check AllDone
        boolean allDone=true;
        this.message=this.message+","+message;
        for(int i=0;i<list.size();i++){
            if(agde.equals(list.get(i))){
                
            }else{
                log.debug("testing "+list.get(i).getId()+":"+list.get(i).isDone());
                if(!list.get(i).isDone()){
                    allDone=false;
                }
            }
            
        }
        if(allDone){
            log.debug("ALL DONE");
            try{
                outGroup.flush();
                outGroup.close();
                log.debug("Group File Closed");
            }catch(IOException e){
                log.error("Error Closing Group File",e);
            }
            try{
                outIndiv.flush();
                outIndiv.close();
                log.debug("Indiv File Closed");
            }catch(IOException e){
                log.error("Error Closing Individual File",e);
            }
            
            File groupf=new File(outputDir+"Panel_Expr_group_tmp.txt");
            File groupfinal=new File(outputDir+"Panel_Expr_group.txt");
            groupf.renameTo(groupfinal);
            log.debug("Group File Renamed\n"+groupf+"->"+groupfinal+"\n");
            File indivf=new File(outputDir+"Panel_Expr_indiv_tmp.txt");
            File indivfinal=new File(outputDir+"Panel_Expr_indiv.txt");
            indivf.renameTo(indivfinal);
            log.debug("Indiv File Renamed\n"+indivf+"->"+indivfinal+"\n");
            end=new Date();
            Connection conn=null;
            try{
                PreparedStatement ps=null;
                
                if(pool!=null){
                    conn=pool.getConnection();
                    ps=conn.prepareStatement(updateSQL, 
                                                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                                                    ResultSet.CONCUR_UPDATABLE);
                }else{
                    ps=dbConn.prepareStatement(updateSQL, 
                                                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                                                    ResultSet.CONCUR_UPDATABLE);
                }
                
                long returnTimeMS=end.getTime()-start.getTime();
                ps.setLong(1, returnTimeMS);
                ps.setString(2, this.message);
                ps.setInt(3, usageID);
                ps.executeUpdate();
                ps.close();
                if(conn!=null)
                    conn.close();
            }catch(SQLException ex){
                log.error("Error saving AsyncGeneDataExpr Timing",ex);
            }finally{
                try {
                    if(conn!=null)
                        conn.close();
                } catch (SQLException ex) {
                }
            }
        }
    }

    
    private void processGroupFile(String path,HashMap groups,String tissue,BufferedWriter out){
        try {
            BufferedReader in=new BufferedReader(new FileReader(new File(path)));
            String header=in.readLine();
            String[] items=header.split("\t");
            //output new header
            String newHeader="Probeset\tTissue";
            for(int i=1;i<items.length;i++){
                //log.debug("item:"+i+":"+items[i]);
                String[] sections=items[i].split("\\.");
                //log.debug(i+":"+items.length+"::"+sections.length);
                //log.debug(sections[1]+":"+sections[2]);
                //if(sections.length==3){
                    String groupName=(String)groups.get(sections[1]);
                    newHeader=newHeader+"\t"+groupName+"."+sections[2];
                    
                    //log.debug("newheader="+newHeader);
                    //log.debug("groupname="+groupName+":"+sections[2]);
                //}
            }
            out.write(newHeader+"\n");
            while(in.ready()){
                String line=in.readLine();
                if(line!=null){
                    int first=line.indexOf("\t");
                    if(first>-1){
                        String output=line.substring(0, first)+"\t"+tissue+line.substring(first)+"\n";
                        out.write(output);
                    }
                }
            }
            
        } catch (IOException ex) {
            log.error("Error processing group tissue file",ex);
        }
    }
    
    private void processIndivFile(String path,String tissue,BufferedWriter out){
        try {
            BufferedReader in=new BufferedReader(new FileReader(new File(path)));
            String header=in.readLine();
            String[] items=header.split("\t");
            //output new header
            String newHeader="Probeset\tTissue";
            for(int i=1;i<items.length;i++){
                newHeader=newHeader+"\t"+items[i];
            }
            out.write(newHeader+"\n");
            while(in.ready()){
                String line=in.readLine();
                if(line!=null){
                    int first=line.indexOf("\t");
                    if(first>-1){
                        String output=line.substring(0, first)+"\t"+tissue+line.substring(first)+"\n";
                        out.write(output);
                    }
                }
            }
            
        } catch (IOException ex) {
            log.error("Error processing individual tissue file",ex);
        }
    }
    
    private HashMap readGroups(String path) {
        HashMap ret=new HashMap();
        try {
            BufferedReader in=new BufferedReader(new FileReader(new File(path)));
            in.readLine();
            while(in.ready()){
                String line=in.readLine();
                String[] tabs=line.split("\t");
                if(tabs.length==2){
                    ret.put(tabs[0], tabs[1]);  //(Key=Group #, Value=Group Name)
                }
            }
            
        } catch (IOException ex) {
            log.error("Error readign group file",ex);
        }
        return ret;
    }
    
}