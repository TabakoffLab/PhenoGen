package edu.ucdenver.ccp.PhenoGen.tools.analysis;


import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.web.SessionHandler;
import edu.ucdenver.ccp.PhenoGen.web.mail.*;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.*;
import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;
import oracle.jdbc.*;
import org.apache.log4j.Logger;

public class WGCNATools{
    private DataSource pool=null;
    private HttpSession session = null;
    private Logger log=null;
    private String fullPath="";
    
    public WGCNATools(){
        log=Logger.getRootLogger();
    }
    
    public WGCNATools(HttpSession session){
        log=Logger.getRootLogger();
        this.session=session;
        this.pool= (DataSource) session.getAttribute("dbPool");
    }
    
    public void setSession(HttpSession session){
        this.session=session;
        this.pool= (DataSource) session.getAttribute("dbPool");
        String contextRoot = (String) session.getAttribute("contextRoot");
        String appRoot = (String) session.getAttribute("applicationRoot");
        this.fullPath = appRoot + contextRoot;
    }
    

    public ArrayList<String> getWGCNAModulesForGene(String id,String panel,String tissue,String org,String genomeVer){
        ArrayList<String> ret=new ArrayList<String>();
        int dsid=this.getWGCNADataset(panel,tissue,org,genomeVer);
        String query="Select unique module from wgcna_module_info where wdsid="+dsid+" and gene_id='"+id+"'";
        log.debug("QUERY:"+query);
        Connection conn = null;
        try {
            conn = pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                ret.add(rs.getString(1));
            }
            ps.close();
            conn.close();
            conn=null;
                    
        }catch(SQLException e){
             e.printStackTrace(System.err);
            log.error("Error getting WGCNA dataset id.",e);
            Email myAdminEmail = new Email();
            String fullerrmsg=e.getMessage();
            StackTraceElement[] tmpEx=e.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown getting WGCNA dataset id");
            myAdminEmail.setContent("There was an error getting WGCNA dataset id.\n"+fullerrmsg);
            try {
                    myAdminEmail.sendEmailToAdministrator("");
            } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    throw new RuntimeException();
            }
        }finally{
            try{
                    if(conn!=null&&!conn.isClosed()){
                        conn.close();
                        conn=null;
                    }
            }catch(SQLException er){
            }
        }
        return ret;
    }
    
     public ArrayList<String> getWGCNAModulesForRegion(String region,String panel,String tissue,String org,String genomeVer){
        ArrayList<String> ret=new ArrayList<String>();
        HashMap<String,String> geneCount=new HashMap<String,String>();
        int dsid=this.getWGCNADataset(panel,tissue,org,genomeVer);
        String chr=region.substring(0,region.indexOf(":"));
        if(chr.indexOf("chr")>-1){
            chr=chr.substring(3);
        }
        chr=chr.toUpperCase();
        String startStr=region.substring(region.indexOf(":")+1,region.indexOf("-"));
        String stopStr=region.substring(region.indexOf("-")+1);
        int start=Integer.parseInt(startStr);
        int stop=Integer.parseInt(stopStr);
        int arrayID=21;
        if(org.equals("Rn")){
            arrayID=22;
        }
        //String query="Select unique module from wgcna_module_info where wdsid="+dsid+" and gene_id='"+id+"'";
        String query ="select unique module,gene_id from wgcna_module_info where probeset_id in " +
                        "(select aep.probeset_id from affy_exon_probeset aep, chromosomes c " +
                        " where aep.array_type_id=" + arrayID+
                        " and aep.chromosome_id=c.chromosome_id" +
                        " and c.name = '"+chr+"'" +
                        " and ( ("+start+"<=aep.psstart and aep.psstart<="+stop+")" +
                        " or " +
                        " ("+start+"<=aep.psstop and aep.psstop<="+stop+") )" +
                        ")" +
                        "  and wdsid=" +dsid+" order by module";
                        
        log.debug("QUERY:"+query);
        Connection conn = null;
        try {
            conn = pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                String mod=rs.getString(1);
                String gene=rs.getString(2);
               if(geneCount.containsKey(rs.getString(1))){
                   String tmp=geneCount.get(mod);
                   tmp=tmp+","+gene;
                   geneCount.put(mod,tmp);
               }else{
                   geneCount.put(mod, gene);
               }
            }
            ps.close();
            conn.close();
            conn=null;     
        }catch(SQLException e){
             e.printStackTrace(System.err);
            log.error("Error getting WGCNA dataset id.",e);
            Email myAdminEmail = new Email();
            String fullerrmsg=e.getMessage();
            StackTraceElement[] tmpEx=e.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown getting WGCNA dataset id");
            myAdminEmail.setContent("There was an error getting WGCNA dataset id.\n"+fullerrmsg);
            try {
                    myAdminEmail.sendEmailToAdministrator("");
            } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    throw new RuntimeException();
            }
        }finally{
            try{
                    if(conn!=null&&!conn.isClosed()){
                        conn.close();
                        conn=null;
                    }
            }catch(SQLException er){
            }
        }
        Set keys=geneCount.keySet();
        Iterator itr=keys.iterator();
        while(itr.hasNext()){
            String key=(String)itr.next();
            String geneList=geneCount.get(key);
            ret.add(key+":"+geneList);
        }
        return ret;
    }
     
    public ArrayList<String> getWGCNAModulesForGeneList(int glID,String panel,String tissue,String genomeVer){
        ArrayList<String> ret=new ArrayList<String>();
        HashMap<String,String> geneCount=new HashMap<String,String>();
        String ensemblStart="ENSMUSG";
        
        int id=glID;
        GeneList myGeneList=new GeneList();
        try{
            GeneList gl=myGeneList.getGeneList(id,pool);
            String org=gl.getOrganism();
            if(org.equals("Rn")){
                ensemblStart="ENSRNOG";
            }
            IDecoderClient myIDecoder=new IDecoderClient();
            myIDecoder.setNum_iterations(1);
            Set iDecoderAnswer=myIDecoder.getIdentifiersByInputIDAndTarget(id,new String[] {"Ensembl ID"},pool);
            StringBuilder ensIDs=new StringBuilder(100);
            //StringBuilder affyIDs=new StringBuilder(100);
            Iterator ida=iDecoderAnswer.iterator();
            while(ida.hasNext()){
                Identifier ident=(Identifier)ida.next();
                //log.debug("FROM WGCNA GENE LIST:"+ident.getIdentifier());
                Set ens = myIDecoder.getIdentifiersForTargetForOneID(ident.getTargetHashMap(), new String[] {"Ensembl ID"});
                Iterator ensItr=ens.iterator();
                while(ensItr.hasNext()){
                    Identifier ensIdent=(Identifier) ensItr.next();
                    if(ensIdent.getIdentifier().startsWith(ensemblStart)){
                        if(ensIDs.length()>0){
                            ensIDs.append(",");
                        }
                        ensIDs.append("'"+ensIdent.getIdentifier()+"'");
                    }
                }
            }


            int dsid=this.getWGCNADataset(panel,tissue,org,genomeVer);
            int arrayID=21;
            if(org.equals("Rn")){
                arrayID=22;
            }
            //String query="Select unique module from wgcna_module_info where wdsid="+dsid+" and gene_id='"+id+"'";
            String query ="select unique module,gene_id from wgcna_module_info where gene_id in " +
                            "( "+ensIDs.toString()+")" +
                            "  and wdsid=" +dsid+" order by module";

            log.debug("QUERY:"+query);
            Connection conn = null;
            try {
                conn = pool.getConnection();
                PreparedStatement ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery();
                while(rs.next()){
                    String mod=rs.getString(1);
                    String gene=rs.getString(2);
                   if(geneCount.containsKey(rs.getString(1))){
                       String tmp=geneCount.get(mod);
                       tmp=tmp+","+gene;
                       geneCount.put(mod,tmp);
                   }else{
                       geneCount.put(mod, gene);
                   }
                }
                ps.close();
                conn.close();
                conn=null;     
            }catch(SQLException e){
                 e.printStackTrace(System.err);
                log.error("Error getting WGCNA dataset id.",e);
                Email myAdminEmail = new Email();
                String fullerrmsg=e.getMessage();
                StackTraceElement[] tmpEx=e.getStackTrace();
                for(int i=0;i<tmpEx.length;i++){
                    fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                }
                myAdminEmail.setSubject("Exception thrown getting WGCNA dataset id");
                myAdminEmail.setContent("There was an error getting WGCNA dataset id.\n"+fullerrmsg);
                try {
                        myAdminEmail.sendEmailToAdministrator("");
                } catch (Exception mailException) {
                        log.error("error sending message", mailException);
                        throw new RuntimeException();
                }
            }finally{
                try{
                        if(conn!=null&&!conn.isClosed()){
                            conn.close();
                            conn=null;
                        }
                }catch(SQLException er){
                }
            }
            Set keys=geneCount.keySet();
            Iterator itr=keys.iterator();
            while(itr.hasNext()){
                String key=(String)itr.next();
                String geneList=geneCount.get(key);
                ret.add(key+":"+geneList);
            }
        }catch(SQLException ex){
            
        }
        return ret;
    }
    
    private int getWGCNADataset(String panel, String tissue, String org,String genomeVer) {
        Connection conn = null;
        String query="Select wdsid from WGCNA_Dataset where organism=? and tissue=? and panel=? and genome_id=? and visible=1";
        int ret=-1;
        try {
            conn = pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1,org);
            ps.setString(2,tissue);
            ps.setString(3,panel);
            ps.setString(4, genomeVer);
            
            ResultSet rs = ps.executeQuery();
            //int count=0;
            if (rs.next()) {
                ret=rs.getInt(1);
            }
            ps.close();
            conn.close();
            conn=null;
        }catch(SQLException e){
             e.printStackTrace(System.err);
            log.error("Error getting WGCNA dataset id.",e);
            Email myAdminEmail = new Email();
            String fullerrmsg=e.getMessage();
            StackTraceElement[] tmpEx=e.getStackTrace();
            for(int i=0;i<tmpEx.length;i++){
                fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
            }
            myAdminEmail.setSubject("Exception thrown getting WGCNA dataset id");
            myAdminEmail.setContent("There was an error getting WGCNA dataset id.\n"+fullerrmsg);
            try {
                    myAdminEmail.sendEmailToAdministrator("");
            } catch (Exception mailException) {
                    log.error("error sending message", mailException);
                    throw new RuntimeException();
            }
        }finally{
            try{
                    if(conn!=null&&!conn.isClosed()){
                        conn.close();
                        conn=null;
                    }
            }catch(SQLException er){
            }
        }
        return ret;
    }

}