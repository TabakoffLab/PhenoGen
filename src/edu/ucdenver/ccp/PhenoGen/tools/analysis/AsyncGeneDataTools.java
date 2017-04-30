package edu.ucdenver.ccp.PhenoGen.tools.analysis;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.mail.MessagingException;
import javax.mail.SendFailedException;

import javax.servlet.http.HttpSession;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.Dataset.DatasetVersion;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.PhenoGen.driver.ExecHandler;
import edu.ucdenver.ccp.PhenoGen.web.mail.Email;
import edu.ucdenver.ccp.PhenoGen.driver.RException;
import edu.ucdenver.ccp.PhenoGen.driver.R_session;
import edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneLoc;
import edu.ucdenver.ccp.util.ObjectHandler;
import edu.ucdenver.ccp.util.sql.PropertiesConnection;
import edu.ucdenver.ccp.util.FileHandler;

/* for handling exceptions in Threads */
import au.com.forward.threads.ThreadReturn;
import au.com.forward.threads.ThreadInterruptedException;
import au.com.forward.threads.ThreadException;
import edu.ucdenver.ccp.PhenoGen.driver.ExecException;
import java.io.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;
import java.util.logging.Level;
import javax.sql.DataSource;



/* for logging messages */
import org.apache.log4j.Logger;

public class AsyncGeneDataTools extends Thread {
        private String[] rErrorMsg = null;
        private HttpSession session=null;
        private Logger log = null;
        private String userFilesRoot = "";
        private String urlPrefix = "";
        private String ucscDir="";
        private DataSource pool=null;
        private String dbPropertiesFile=null;
        private String mongoDBPropertiesFile=null;
        private String outputDir="";
        private String chrom="";
        private String genomeVer="";
        private String perlDir="";
        private String perlEnvVar="";
        
        private int minCoord=0;
        private int maxCoord=0;
        private int arrayTypeID=0;
        private int rnaDatasetID=0;
        private int usageID=0;
        private boolean done=false;
        private boolean isEnsemblGene=true;
        private String updateSQL="update TRANS_DETAIL_USAGE set TIME_ASYNC_GENE_DATA_TOOLS=? , RESULT=? where TRANS_DETAIL_ID=?";
        private String[] tissues=new String[2];
        private ExecHandler myExec_session = null;
        
    public AsyncGeneDataTools(HttpSession inSession,DataSource pool,String outputDir,String chr,int min,int max,int arrayTypeID,int rnaDS_ID,int usageID,String genomeVer,boolean isEnsemblGene) {
                this.session = inSession;
                this.outputDir=outputDir;
                log = Logger.getRootLogger();
                log.debug("in AsynGeneDataTools()");
                this.session = inSession;
                this.pool=pool;
                this.chrom=chr;
                this.minCoord=min;
                this.maxCoord=max;
                this.arrayTypeID=arrayTypeID;
                this.rnaDatasetID=rnaDS_ID;
                this.usageID=usageID;
                this.genomeVer=genomeVer;
                this.isEnsemblGene=isEnsemblGene;

                log.debug("start");

                //this.selectedDataset = (Dataset) session.getAttribute("selectedDataset");
                //this.selectedDatasetVersion = (Dataset.DatasetVersion) session.getAttribute("selectedDatasetVersion");
                //this.publicDatasets = (Dataset[]) session.getAttribute("publicDatasets");
                this.pool = (DataSource) session.getAttribute("dbPool");
                dbPropertiesFile = (String) session.getAttribute("dbPropertiesFile");
                mongoDBPropertiesFile = (String)session.getAttribute("mongoDbPropertiesFile");
                //log.debug("db");
                this.perlDir = (String) session.getAttribute("perlDir") + "scripts/";
                this.perlEnvVar=(String)session.getAttribute("perlEnvVar");
                String contextRoot = (String) session.getAttribute("contextRoot");
                //log.debug("context" + contextRoot);
                String appRoot = (String) session.getAttribute("applicationRoot");
                //log.debug("app" + appRoot);
                
                //log.debug("userFilesRoot");
                this.urlPrefix = (String) session.getAttribute("mainURL");
                if (urlPrefix.endsWith(".jsp")) {
                    urlPrefix = urlPrefix.substring(0, urlPrefix.lastIndexOf("/") + 1);
                }
                //log.debug("mainURL");
                
                this.ucscDir = (String) session.getAttribute("ucscDir");
                //log.debug("ucsc");
                
                tissues[0]="Brain";
                tissues[1]="Liver";
                
    }
    
    

    public void run() throws RuntimeException {
        done=false;
        Date start=new Date();
        try{
            outputRNASeqExprFiles(outputDir,chrom,minCoord,maxCoord,genomeVer);
            if(isEnsemblGene){
                //log.debug("Before outputProbesetID");
                outputProbesetIDFiles(outputDir,chrom, minCoord, maxCoord,arrayTypeID,genomeVer);
                //log.debug("before DEHeatMap");
                callDEHeatMap(outputDir,chrom, minCoord, maxCoord,arrayTypeID,rnaDatasetID,genomeVer);
                //log.debug("before Panel HErit");
                callPanelHerit(outputDir,chrom, minCoord, maxCoord,arrayTypeID,rnaDatasetID,genomeVer);
                //log.debug("After Panel Herit");
                done=true;
                Date end=new Date();
                Connection conn=null;
                try{
                    conn=pool.getConnection();
                    PreparedStatement ps=conn.prepareStatement(updateSQL);
                    long returnTimeMS=end.getTime()-start.getTime();
                    ps.setLong(1, returnTimeMS);
                    ps.setString(2, "AsyncGeneDataTools completed successfully");
                    ps.setInt(3, usageID);
                    int updated=ps.executeUpdate();
                    log.debug("AsyncGeneDataTools: updated "+updated +"records");
                    ps.close();
                    conn.close();
                }catch(SQLException e){
                    log.error("Error saving AsyncGeneDataTools Timing",e);
                }finally{
                    try {
                        if(conn!=null)
                            conn.close();
                    } catch (SQLException ex) {
                    }
                }
            }
            
            log.debug("AsyncGeneDataTools DONE");
        } catch (Exception ex) {
            done=true;
            log.error("Error processing initial files in AsyncGeneDataTools",ex);
            Date end=new Date();
            Connection conn2=null;
            try{
                conn2=pool.getConnection();
                PreparedStatement ps=conn2.prepareStatement(updateSQL);
                long returnTimeMS=end.getTime()-start.getTime();
                ps.setLong(1, returnTimeMS);
                ps.setString(2, "AsyncGeneDataTools had errors:"+ex.getMessage());
                ps.setInt(3, usageID);
                ps.executeUpdate();
                ps.close();
                conn2.close();
            }catch(SQLException e){
                log.error("Error saving AsyncGeneDataTools Timing",e);
            }finally{
                try {
                    if(conn2!=null)
                        conn2.close();
                } catch (SQLException ex2) {
                }
            }
            String fullerrmsg=ex.getMessage();
                    StackTraceElement[] tmpEx=ex.getStackTrace();
                    for(int i=0;i<tmpEx.length;i++){
                        fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
                    }
            Email myAdminEmail = new Email();
            myAdminEmail.setSubject("Exception thrown in AsyncGeneDataTools");
            myAdminEmail.setContent("There was an error while running AsyncGeneDataTools \nStackTrace:\n"+fullerrmsg);
            try {
                myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
            } catch (Exception mailException) {
                log.error("error sending message", mailException);
                throw new RuntimeException();
            }
        }
        done=true;
    }
    
    private void outputProbesetIDFiles(String outputDir,String chr, int min, int max,int arrayTypeID,String genomeVer){
        if(chr.toLowerCase().startsWith("chr")){
            chr=chr.substring(3);
        }
        String probeQuery="select s.Probeset_ID "+
                                "from Chromosomes c, Affy_Exon_ProbeSet s "+
                                "where s.chromosome_id = c.chromosome_id "+
                                "and c.name = '"+chr.toUpperCase()+"' "+
                                "and s.genome_id='"+genomeVer+"' "+
                            "and ( "+
                            "(s.psstart >= "+min+" and s.psstart <="+max+") OR "+
                            "(s.psstop >= "+min+" and s.psstop <= "+max+") OR "+
                            "(s.psstart <= "+min+" and s.psstop >="+min+")"+
                            ") "+
                            "and s.psannotation <> 'transcript' " +
                            "and s.updatedlocation = 'Y' "+
                            "and s.Array_TYPE_ID = "+arrayTypeID;
        
        String probeTransQuery="select s.Probeset_ID,c.name,s.PSSTART,s.PSSTOP,s.PSLEVEL,s.Strand "+
                                "from Chromosomes c, Affy_Exon_ProbeSet s "+
                                "where s.chromosome_id = c.chromosome_id "+
                                "and c.name = '"+chr.toUpperCase()+"' "+
                                "and s.genome_id='"+genomeVer+"' "+
                            "and ( "+
                            "(s.psstart >= "+min+" and s.psstart <="+max+") OR "+
                            "(s.psstop >= "+min+" and s.psstop <= "+max+") OR "+
                            "(s.psstart <= "+min+" and s.psstop >="+min+") )"+
                            "and s.psannotation like 'transcript' " +
                            "and s.updatedlocation = 'Y' "+
                            "and s.Array_TYPE_ID = " + arrayTypeID +
                            " and s.PROBESET_ID in (select l.probe_id from location_specific_eqtl l,snps sn where sn.genome_id='"+genomeVer+"' and l.snp_id=sn.snp_id)";
        
        log.debug("PSLEVEL SQL:"+probeQuery);
        log.debug("Transcript Level SQL:"+probeTransQuery);
        String pListFile=outputDir+"tmp_psList.txt";
            try{
                BufferedWriter psout=new BufferedWriter(new FileWriter(new File(pListFile)));
                Connection conn=null;
                try{
                    conn=pool.getConnection();
                    PreparedStatement ps = conn.prepareStatement(probeQuery);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        int psid = rs.getInt(1);
                        psout.write(psid + "\n");
                    }
                    ps.close();
                    conn.close();
                }catch(SQLException ex){
                    log.error("Error getting exon probesets",ex);
                }finally{
                    try {
                        if(conn!=null)
                            conn.close();
                    } catch (SQLException ex) {
                    }
                }
                psout.flush();
                psout.close();
            }catch(IOException e){
                log.error("Error writing exon probesets",e);
            }
            done=true;
            ArrayList<GeneLoc> geneList=GeneLoc.readGeneListFile(outputDir,log);
            log.debug("Read in gene list:"+geneList.size());
            String ptransListFiletmp = outputDir + "tmp_psList_transcript.txt";
                StringBuilder sb=new StringBuilder();
                Connection conn=null;
                try{
                    conn=pool.getConnection();
                    PreparedStatement ps = conn.prepareStatement(probeTransQuery);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        int psid = rs.getInt(1);
                        log.debug("transcript read ps:"+psid);
                        String ch = rs.getString(2);
                        long start = rs.getLong(3);
                        long stop = rs.getLong(4);
                        String level=rs.getString(5);
                        String strand=rs.getString(6);
                        
                        String ensemblId="",ensGeneSym="";
                        double maxOverlapTC=0.0,maxOverlapGene=0.0,maxComb=0.0;
                        GeneLoc maxGene=null;
                        for(int i=0;i<geneList.size();i++){
                            GeneLoc tmpLoc=geneList.get(i);
                            //log.debug("strand:"+tmpLoc.getStrand()+":"+strand);
                            if(tmpLoc.getStrand().equals(strand)){
                                long maxStart=tmpLoc.getStart();
                                long minStop=tmpLoc.getStop();
                                if(start>maxStart){
                                    maxStart=start;
                                }
                                if(stop<minStop){
                                    minStop=stop;
                                }
                                long genLen=tmpLoc.getStop()-tmpLoc.getStart();
                                long tcLen=stop-start;
                                double overlapLen=minStop-maxStart;
                                double curTCperc=0.0,curGperc=0.0,comb=0.0;
                                if(overlapLen>0){
                                    curTCperc=overlapLen/tcLen*100;
                                    curGperc=overlapLen/tcLen*100;
                                    comb=curTCperc+curGperc;
                                    if(comb>maxComb){
                                        maxOverlapTC=curTCperc;
                                        maxOverlapGene=curGperc;
                                        maxComb=comb;
                                        maxGene=tmpLoc;
                                    }
                                }
                            }
                        }
                        if(maxGene!=null){
                            String tmpGS=maxGene.getGeneSymbol();
                            if(tmpGS.equals("")){
                                tmpGS=maxGene.getID();
                            }
                            //log.debug("out:"+psid + "\t" + ch + "\t" + start + "\t" + stop + "\t" + level + "\t"+tmpGS+"\n");
                            sb.append(psid + "\t" + ch + "\t" + start + "\t" + stop + "\t" + level + "\t"+tmpGS+"\n");
                            
                        }else{
                            //log.debug("out"+psid + "\t" + ch + "\t" + start + "\t" + stop + "\t" + level + "\t\n");
                            sb.append(psid + "\t" + ch + "\t" + start + "\t" + stop + "\t" + level + "\t\n");
                            
                        }
                    }
                    ps.close();
                    conn.close();
                }catch(SQLException ex){
                    log.error("Error getting transcript probesets",ex);
                }finally{
                    try {
                        if(conn!=null)
                            conn.close();
                    } catch (SQLException ex) {
                    }
                }
                try{
                    log.debug("To File:"+ptransListFiletmp+"\n\n"+sb.toString());
                    FileHandler myFH=new FileHandler();
                    myFH.writeFile(sb.toString(),ptransListFiletmp);
                    log.debug("DONE");
                }catch(IOException e){
                    log.error("Error outputing transcript ps list.",e);
                }
            
    }
    
    public boolean callDEHeatMap(String outputDir,String chr, int min, int max,int arrayTypeID,int rnaDS_ID,String genomeVer){
        boolean error=false;
        if(chr.startsWith("chr")){
            chr=chr.substring(3);
        }
        //create DE mean heatmap
        String meanQuery="select dem.probeset_id,dem.mean,dad.tissue,des.strain_name from de_means dem, de_arrays_dataset dad,de_strains des "+
                         "where des.diff_exp_id=dad.diff_exp_id "+
                         "and des.de_strain_id = dem.de_strain_id "+
                         "and dad.diff_exp_id=dem.diff_exp_id "+
                         "and dad.genome_id='"+genomeVer+"' "+
                         "and dem.diff_exp_id in (select rdd.diff_exp_id from rnadataset_dedataset rdd where rdd.rna_dataset_id = "+rnaDS_ID+") "+
                            "and dem.probeset_id in ("+
                                "select s.Probeset_ID "+
                                "from Chromosomes c, Affy_Exon_ProbeSet s "+
                                "where s.chromosome_id = c.chromosome_id "+
                                "and c.name = '"+chr+"' "+
                                "and s.genome_id='"+genomeVer+"' "+
                            "and "+
                            "((s.psstart >= "+min+" and s.psstart <="+max+") OR "+
                            "(s.psstop >= "+min+" and s.psstop <= "+max+")) "+
                            "and s.psannotation <> 'transcript' " +
                            "and s.Array_TYPE_ID = "+arrayTypeID+") "+ 
                            "order by dem.probeset_id,dad.tissue,des.strain_name";
        
        String foldchangeQuery="select def.probeset_id,def.foldchange,def.fdr,def.pvalue,dad.tissue,des1.strain_name as strain1,des2.strain_name as strain2 from de_foldchange def, de_arrays_dataset dad,de_strains des1, de_strains des2 "+
                    "where des1.diff_exp_id=dad.diff_exp_id "+
                    "and des2.diff_exp_id=dad.diff_exp_id "+
                    "and def.strain_id1 = des1.de_strain_id "+
                    "and def.strain_id2 = des2.de_strain_id "+
                    "and dad.diff_exp_id=def.diff_exp_id  "+
                    "and dad.genome_id='"+genomeVer+"' "+
                    "and def.diff_exp_id in (select rdd.diff_exp_id from rnadataset_dedataset rdd where rdd.rna_dataset_id = "+rnaDS_ID+") "+
                    "and def.probeset_id in ( "+
                                "select s.Probeset_ID "+
                                "from Chromosomes c, Affy_Exon_ProbeSet s "+
                                "where s.chromosome_id = c.chromosome_id "+
                                "and c.name = '"+chr+"' "+
                                "and s.genome_id='"+genomeVer+"' "+
                                "and  "+
                                "((s.psstart >= "+min+" and s.psstart <="+max+") OR "+
                                "(s.psstop >= "+min+" and s.psstop <= "+max+")) "+
                                "and s.psannotation <> 'transcript' "+
                                "and s.Array_TYPE_ID = "+arrayTypeID+")  "+
                    "order by def.probeset_id,dad.tissue,des1.strain_name,des2.strain_name";
        Connection conn=null;
        try{
            log.debug("SQL\n"+meanQuery);
            conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(meanQuery);
            ResultSet rs = ps.executeQuery();
            ArrayList<HashMap> data=new ArrayList<HashMap>();
            ArrayList<String> tissueList=new ArrayList<String>();
            ArrayList<String> strainList=new ArrayList<String>();
            HashMap templine=new HashMap();
            HashMap tissueTH=new HashMap();
            HashMap strainTH=new HashMap();
            String curprobeset="";
            while(rs.next()){
                String probeset=Integer.toString(rs.getInt("PROBESET_ID"));
                double mean=rs.getDouble("MEAN");
                String tissue=rs.getString("TISSUE");
                String strain=rs.getString("STRAIN_NAME");
                if(probeset.equals(curprobeset)){
                    if(templine.containsKey(tissue)){
                        HashMap strainhm=(HashMap)templine.get(tissue);
                        strainhm.put(strain,mean);
                    }else{
                        HashMap strainhm=new HashMap();
                        strainhm.put(strain, mean);
                        templine.put(tissue, strainhm);
                    }
                }else{//newline
                    if(!templine.isEmpty()){
                        data.add(templine);
                    }
                    templine=new HashMap();
                    HashMap strainhm=new HashMap();
                    strainhm.put(strain, mean);
                    templine.put(tissue, strainhm);
                    templine.put("probeset",probeset);
                    curprobeset=probeset;
                }
                if(!tissueTH.containsKey(tissue)){
                    tissueTH.put(tissue, 1);
                    tissueList.add(tissue);
                }
                if(!strainTH.containsKey(strain)){
                    strainTH.put(strain, 1);
                    strainList.add(strain);
                }
            }
            ps.close();
            conn.close();
            DecimalFormat df = new DecimalFormat("#############.##");
            try{
            BufferedWriter out=new BufferedWriter(new FileWriter(new File(outputDir+"DE_means.csv")));
            //this.deMeanURL=outputDir+"DE_means.csv";
            out.write("Probeset");
            for(int j=0;j<tissueList.size();j++){
                String tissue=tissueList.get(j);    
                for(int k=0;k<strainList.size();k++){
                        String strain=strainList.get(k);
                        out.write(","+tissue+"."+strain+".Mean");
                }
            }
            out.write("\n");
            for(int i=0;i<data.size();i++){
                HashMap thm=data.get(i);
                String pset=(String)thm.get("probeset");
                out.write(pset);
                for(int j=0;j<tissueList.size();j++){
                    HashMap shm=(HashMap)thm.get(tissueList.get(j));
                    if(shm!=null){
                        for(int k=0;k<strainList.size();k++){
                           Object tmp=shm.get(strainList.get(k));
                           if(tmp!=null){
                               double tmpdbl=Double.parseDouble(tmp.toString());
                               out.write(","+df.format(tmpdbl));
                           }else{
                               out.write(",0");
                           }
                        }
                    }else{
                        for(int k=0;k<strainList.size();k++){
                            out.write(",0");
                        }
                    }
                }
                out.write("\n");
            }
            out.close();
           
            }catch(IOException er){
                error=true;
                log.error("Error outputting means ",er);
            }
        }catch(SQLException e){
            error=true;
            log.error("Error getting dataset id",e);
        }finally{
            try {
                    if(conn!=null)
                        conn.close();
                } catch (SQLException ex) {
                }
        }
        //create DE foldchange heatmap
        conn=null;
        try{
           log.debug("SQL\n"+foldchangeQuery);
           conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(foldchangeQuery);
            ResultSet rs = ps.executeQuery();
            ArrayList<HashMap> data=new ArrayList<HashMap>();
            ArrayList<String> tissueList=new ArrayList<String>();
            ArrayList<String> strainList=new ArrayList<String>();
            HashMap templine=new HashMap();
            HashMap tissueTH=new HashMap();
            HashMap strainTH=new HashMap();
            String curprobeset="";
            while(rs.next()){
                String probeset=Integer.toString(rs.getInt("PROBESET_ID"));
                double foldchange=rs.getDouble("foldchange");
                double fdr=rs.getDouble("fdr");
                double pval=rs.getDouble("pvalue");
                String tissue=rs.getString("TISSUE");
                String strain1=rs.getString("strain1");
                String strain2=rs.getString("strain2");
                String strain=strain1+" vs "+strain2;
                if(probeset.equals(curprobeset)){
                    if(templine.containsKey(tissue)){
                        HashMap strainhm=(HashMap)templine.get(tissue);
                        HashMap values=new HashMap();
                        values.put("fdr",fdr);
                        values.put("pvalue",pval);
                        values.put("folddiff",foldchange);
                        strainhm.put(strain, values);
                    }else{
                        HashMap strainhm=new HashMap();
                        HashMap values=new HashMap();
                        values.put("fdr",fdr);
                        values.put("pvalue",pval);
                        values.put("folddiff",foldchange);
                        strainhm.put(strain, values);
                        templine.put(tissue, strainhm);
                    }
                }else{//newline
                    if(!templine.isEmpty()){
                        data.add(templine);
                    }
                    templine = new HashMap();
                    HashMap strainhm=new HashMap();
                    HashMap values=new HashMap();
                    values.put("fdr",fdr);
                    values.put("pvalue",pval);
                    values.put("folddiff",foldchange);
                    strainhm.put(strain, values);
                    templine.put(tissue, strainhm);
                    templine.put("probeset", probeset);
                    curprobeset=probeset;
                }
                if(!tissueTH.containsKey(tissue)){
                    tissueTH.put(tissue, 1);
                    tissueList.add(tissue);
                }
                if(!strainTH.containsKey(strain)){
                    strainTH.put(strain, 1);
                    strainList.add(strain);
                }
            }
            ps.close();
            conn.close();
            DecimalFormat df = new DecimalFormat("#############.##");
            try{
            BufferedWriter out=new BufferedWriter(new FileWriter(new File(outputDir+"DE_folddiff.csv")));
            //this.deFoldDiffURL=outputDir+"DE_folddiff.csv";
            out.write("Probeset");
            for(int j=0;j<tissueList.size();j++){
                String tissue=tissueList.get(j);    
                for(int k=0;k<strainList.size();k++){
                        String strain=strainList.get(k);
                        out.write(","+tissue+"."+strain+".FoldDiff"+","+tissue+"."+strain+".Pvalue"+","+tissue+"."+strain+".FDR");
                }
            }
            out.write("\n");
            for(int i=0;i<data.size();i++){
                HashMap thm=data.get(i);
                String pset=(String)thm.get("probeset");
                out.write(pset);
                for(int j=0;j<tissueList.size();j++){
                    HashMap shm=(HashMap)thm.get(tissueList.get(j));
                    if(shm!=null){
                        for(int k=0;k<strainList.size();k++){
                           Object tmp=shm.get(strainList.get(k));
                           if(tmp!=null){
                               HashMap tmphm=(HashMap)tmp;
                               String sfdr=tmphm.get("fdr").toString();
                               String spval=tmphm.get("pvalue").toString();
                               String sfc=tmphm.get("folddiff").toString();
                               double dfdr=Double.parseDouble(sfdr);
                               double dpval=Double.parseDouble(spval);
                               double dfc=Double.parseDouble(sfc);
                               out.write(","+df.format(dfc)+","+df.format(dpval)+","+df.format(dfdr));
                           }else{
                               out.write(",0,0,0");
                           }
                        }
                    }else{
                        for(int k=0;k<strainList.size();k++){
                            out.write(",0,0,0");
                        }
                    }
                }
                out.write("\n");
            }
            out.close();
           
            }catch(IOException er){
                error=true;
                log.error("Error outputting means ",er);
            }
        }catch(SQLException e){
            error=true;
            log.error("Error getting dataset id",e);
        }finally{
            try {
                    if(conn!=null)
                        conn.close();
                } catch (SQLException ex) {
                }
        }
        return error;
    }
    
    
    public boolean callPanelHerit(String outputDir,String chr, int min, int max,int arrayTypeID,int rnaDS_ID,String genomeVer){
        boolean error=false;
        if(chr.startsWith("chr")){
            chr=chr.substring(3);
        }
        //create File with Probeset Tissue herit and DABG
        String probeQuery="select phd.probeset_id, rd.tissue, phd.herit,phd.dabg "+
                            "from probeset_herit_dabg phd , rnadataset_dataset rd "+
                            "where rd.rna_dataset_id = "+rnaDS_ID+" "+
                            "and phd.genome_id='"+genomeVer+"' "+
                            "and phd.dataset_id=rd.dataset_id "+
                            "and phd.probeset_id in ("+
                                "select s.Probeset_ID "+
                                "from Chromosomes c, Affy_Exon_ProbeSet s "+
                                "where s.chromosome_id = c.chromosome_id "+
                                "and c.name = '"+chr+"' "+
                                "and s.genome_id='"+genomeVer+"' "+
                            "and "+
                            "((s.psstart >= "+min+" and s.psstart <="+max+") OR "+
                            "(s.psstop >= "+min+" and s.psstop <= "+max+")) "+
                            "and s.psannotation <> 'transcript' " +
                            "and s.Array_TYPE_ID = "+arrayTypeID+") "+ 
                            "order by phd.probeset_id,rd.tissue";
        
        Connection conn=null;
        try{
            //log.debug("SQL\n"+meanQuery);
            conn=pool.getConnection();
            PreparedStatement ps = conn.prepareStatement(probeQuery);
            ResultSet rs = ps.executeQuery();
            ArrayList<HashMap> data=new ArrayList<HashMap>();
            ArrayList<String> tissueList=new ArrayList<String>();
            HashMap templine=new HashMap();
            HashMap tissueTH=new HashMap();
            String curprobeset="";
            while(rs.next()){
                String probeset=Integer.toString(rs.getInt("PROBESET_ID"));
                double herit=rs.getDouble("herit");
                double dabg=rs.getDouble("dabg");
                String tissue=rs.getString("TISSUE");
                if(probeset.equals(curprobeset)){
                        HashMap valueshm=new HashMap();
                        valueshm.put("herit", herit);
                        valueshm.put("dabg",dabg);
                        templine.put(tissue, valueshm);
                
                }else{//newline
                    if(!templine.isEmpty()){
                        data.add(templine);
                    }
                    templine=new HashMap();
                    HashMap valueshm=new HashMap();
                        valueshm.put("herit", herit);
                        valueshm.put("dabg",dabg);
                        templine.put(tissue, valueshm);
                    templine.put("probeset",probeset);
                    curprobeset=probeset;
                }
                if(!tissueTH.containsKey(tissue)){
                    tissueTH.put(tissue, 1);
                    tissueList.add(tissue);
                }
            }
            ps.close();
            conn.close();
            DecimalFormat df = new DecimalFormat("#############.###");
            try{
            BufferedWriter out=new BufferedWriter(new FileWriter(new File(outputDir+"Panel_Herit.csv")));
            //this.deMeanURL=outputDir+"DE_means.csv";
            out.write("Probeset");
            for(int j=0;j<tissueList.size();j++){
                String tissue=tissueList.get(j);
                out.write(","+tissue+".Herit,"+tissue+".Dabg");
            }
            out.write("\n");
            for(int i=0;i<data.size();i++){
                HashMap thm=data.get(i);
                String pset=(String)thm.get("probeset");
                out.write(pset);
                for(int j=0;j<tissueList.size();j++){
                    HashMap vhm=(HashMap)thm.get(tissueList.get(j));
                    if(vhm!=null){
                           Object oh=vhm.get("herit");
                           Object od=vhm.get("dabg");
                           if(oh!=null){
                               double tmpdbl=Double.parseDouble(oh.toString());
                               out.write(","+df.format(tmpdbl));
                           }else{
                               out.write(",0");
                           }
                           if(od!=null){
                               double tmpdbl=Double.parseDouble(od.toString());
                               out.write(","+df.format(tmpdbl));
                           }else{
                               out.write(",0");
                           }
                    }else{
                            out.write(",0,0");
                    }
                }
                out.write("\n");
            }
            out.close();
           
            }catch(IOException er){
                error=true;
                log.error("Error outputting means ",er);
            }
        }catch(SQLException e){
            error=true;
            log.error("Error getting dataset id",e);
        }finally{
            try {
                    if(conn!=null)
                        conn.close();
            } catch (SQLException ex) {
            }
        }
        return error;
    }
    
    public boolean outputRNASeqExprFiles(String outputDir,String chr, int min, int max,String genomeVer){
        boolean success=true;
        // get list of tissues/datasets
        String query="select RNA_DATASET_ID, TISSUE,BUILD_VERSION,EXP_DATA_ID from rna_dataset where genome_id=? and trx_recon=1 and visible=1 and exp_data_id is not null";
        Connection conn=null;
        HashMap<String,Tissues> tissues=new HashMap<String,Tissues>(); 
        try{
            conn=pool.getConnection();
            PreparedStatement ps=conn.prepareStatement(query);
            ps.setString(1,genomeVer);
            ResultSet rs=ps.executeQuery();
            while (rs.next()){
                String tissue=rs.getString(2);
                int build=Integer.parseInt(rs.getString(3));
                Tissues t=new Tissues(rs.getInt(1),tissue,build,rs.getInt(4));
                if(tissues.containsKey(tissue)){
                    if(tissues.get(tissue).getBuildVer()<build){
                        tissues.put(tissue,t);
                    }
                }else{
                    tissues.put(tissue, t);
                }
                log.debug("*********"+tissue+":"+build+":"+rs.getInt(1)+":"+rs.getInt(4));
            }
            ps.close();
            conn.close();
        }catch(SQLException e){
            log.error("Error in outputRNASeqExprFiles",e);
        }finally{
            try{
                if(conn!=null && !conn.isClosed()){
                    conn.close();
                }
            }catch(SQLException e){}
        }
        Iterator itr=tissues.keySet().iterator();
        ArrayList<FeatureID> featList=new ArrayList<FeatureID>();
        HashMap<String, GeneID> genes=new HashMap<String,GeneID>();
        StringBuilder sb=new StringBuilder();
        while(itr.hasNext()){
            Tissues curTissue=(Tissues)tissues.get(itr.next());
            //get transcripts
            String selectTrx="select r.merge_gene_id,r.merge_isoform_id,r.herit_gene,r.herit_trx from rna_transcripts r, chromosomes c where "+
                        "c.organism=? and c.name=? and c.chromosome_id=r.chromosome_id "+
                        "and r.rna_dataset_id=? "+
                        "and ((trstart>="+min+" and trstart<="+max+") OR (trstop>="+min+" and trstop<="+max+") OR (trstart<="+min+" and trstop>="+max+"))";
            String selectR2="select r.merge_gene_id,r.merge_isoform_id,r.herit_gene,r.herit_trx from rna_transcripts r where r.rna_dataset_id=? and "+
                    " r.merge_gene_id in (";
            log.debug(selectTrx);
            try{
                conn=pool.getConnection();
                PreparedStatement ps=conn.prepareStatement(selectTrx);
                String org="Rn";
                if(genomeVer.toLowerCase().startsWith("mm")){
                    org="Mm";
                }
                ps.setString(1,org);
                if(chr.startsWith("chr")){
                    chr=chr.substring(3);
                }
                ps.setString(2,chr);
                ps.setInt(3,curTissue.getDatasetID());
                ResultSet rs=ps.executeQuery();
                while (rs.next()){
                    String geneID=rs.getString(1);
                    String trxID=rs.getString(2);
                    double gHerit=rs.getDouble(3);
                    double tHerit=rs.getDouble(4);
                    TrxID tmpTrx=new TrxID(trxID,tHerit);
                    if(genes.containsKey(geneID)){
                        GeneID tmpGene=genes.get(geneID);
                        tmpGene.addTranscript(tmpTrx);
                    }else{
                        GeneID tmpGene=new GeneID(geneID,gHerit);
                        tmpGene.addTranscript(tmpTrx);
                        genes.put(geneID, tmpGene);
                        if(sb.length()>0){
                            sb.append(",");
                        }
                        sb.append("'"+geneID+"'");
                        featList.add(tmpGene);
                    }
                    featList.add(tmpTrx);
                    log.debug("\n&&&&&&&&&&&&&&&&&&&&&&&& trx:"+trxID+"::"+geneID);
                }
                ps.close();
                
                ps=conn.prepareStatement(selectR2+sb.toString()+" )");
                ps.setInt(1,curTissue.getDatasetID());
                rs=ps.executeQuery();
                while (rs.next()){
                    String geneID=rs.getString(1);
                    String trxID=rs.getString(2);
                    double gHerit=rs.getDouble(3);
                    double tHerit=rs.getDouble(4);
                    TrxID tmpTrx=new TrxID(trxID,tHerit);
                    
                    GeneID tmpGene=genes.get(geneID);
                    boolean found=false;
                    for(int i=0;i<tmpGene.getTranscripts().size()&&!found;i++){
                        if(tmpGene.getTranscripts().get(i).getID().equals(trxID)){
                            found=true;
                        }
                    }
                    if(!found){
                        tmpGene.addTranscript(tmpTrx);
                        featList.add(tmpTrx);
                    }
                    
                }
                ps.close();
                conn.close();
            }catch(SQLException e){
                log.error("\n\nError in outputRNASeqExprFiles",e);
            }finally{
                try{
                    if(conn!=null && !conn.isClosed()){
                        conn.close();
                    }
                }catch(SQLException e){}
            }
            //create gene list for perl call
            String perlGeneList="";
            Iterator gItr=genes.keySet().iterator();
            int c=0;
            while(gItr.hasNext()){
                String next=(String)gItr.next();
                if(c>0){
                    perlGeneList=perlGeneList+",";
                }
                perlGeneList=perlGeneList+next;
                c++;
            }
            log.debug("PERLGENELIST:\n"+perlGeneList);
            String heritFile=outputDir+curTissue.getTissue()+"_herit.txt";
            //output heritablity file for each dataset
            try{
                BufferedWriter psout=new BufferedWriter(new FileWriter(new File(heritFile)));
                for(int i=0;i<featList.size();i++){
                    psout.write(featList.get(i).getID()+"\t"+featList.get(i).getHeritability()+"\n");
                }
                psout.close();
            }catch(IOException e){
                log.error("\n\nError outputing herit file:"+heritFile, e);
            }
            
            
            File mongoPropertiesFile = new File(mongoDBPropertiesFile);
            Properties myMongoProperties = new Properties();
            try{
                myMongoProperties.load(new FileInputStream(mongoPropertiesFile));
            }catch(IOException e){
                log.error("Error opening property file",e);
            }
            String mongoHost=myMongoProperties.getProperty("HOST");
            String mongoUser=myMongoProperties.getProperty("USER");
            String mongoPassword=myMongoProperties.getProperty("PASSWORD");
            //for each tissue call perl
            String[] perlArgs = new String[9];
            perlArgs[0] = "perl";
            perlArgs[1] = perlDir + "readExprDataFromMongo.pl";
            perlArgs[2] = outputDir+curTissue.getTissue()+"expr.json";
            perlArgs[3] = Integer.toString(curTissue.getExprDataID());
            perlArgs[4] = perlGeneList;
            perlArgs[5] = heritFile;
            perlArgs[6] = mongoHost;
            perlArgs[7] = mongoUser;
            perlArgs[8] = mongoPassword;

            log.debug("after perl args");
            log.debug("setup params");
            //set environment variables so you can access oracle pulled from perlEnvVar session variable which is a comma separated list
             String[] envVar=perlEnvVar.split(",");

            /*for (int i = 0; i < envVar.length; i++) {
                if(envVar[i].contains("/ensembl")){
                    envVar[i]=envVar[i].replaceFirst("/ensembl", "/"+ensemblPath);
                }
                log.debug(i + " EnvVar::" + envVar[i]);
            }*/

            log.debug("setup envVar");
            //construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
            myExec_session = new ExecHandler(perlDir, perlArgs, envVar, outputDir+curTissue.getTissue()+"expr");
            boolean exception = false;
            try {

                myExec_session.runExec();

            } catch (ExecException e) {
                exception=true;
                success=false;
                e.printStackTrace(System.err);
                log.error("In Exception of run callWriteXML:writeXML_RNA.pl Exec_session", e);
            }
        }
        return success;
    }
    
    public boolean isDone(){
        return done;
    }
    
    
    
}

class Tissues{
    private int dsid;
    private String tissue;
    private int buildVer;
    private int exprID;
    
    public Tissues(int dsid,String tissue, int buildVer,int exprID){
        this.dsid=dsid;
        this.tissue=tissue;
        this.buildVer=buildVer;
        this.exprID=exprID;
    }
    public String getTissue(){
        return this.tissue;
    }
    public int getDatasetID(){
        return this.dsid;
    }
    public int getBuildVer(){
        return this.buildVer;
    }
    public int getExprDataID(){
        return exprID;
    }
}

class FeatureID{
    private String id;
    private double herit;
    public FeatureID(String id, double herit){
        this.id=id;
        this.herit=herit;
    }
    public String getID(){
        return this.id;
    }
    public double getHeritability(){
        return this.herit;
    }
}

class GeneID extends FeatureID{
    private ArrayList<TrxID> trx;
    
    public GeneID(String geneID, double herit){
        super(geneID,herit);
        this.trx=new ArrayList<TrxID>();
    }
    
    public ArrayList<TrxID> getTranscripts(){
        return this.trx;
    }
    public void addTranscript(TrxID transcript){
        trx.add(transcript);
    }
}

class TrxID extends FeatureID{
    public TrxID(String geneID, double herit){
        super(geneID,herit);
    }
}
