package edu.ucdenver.ccp.PhenoGen.data.Bio;

import edu.ucdenver.ccp.PhenoGen.data.Bio.RNASequence;
import edu.ucdenver.ccp.PhenoGen.data.Bio.SequenceVariant;
import edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation;
import edu.ucdenver.ccp.PhenoGen.web.mail.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;


/* for logging messages */
import org.apache.log4j.Logger;
/**
 *
 * @author smahaffey
 */
public class SmallNonCodingRNA {
    int id=0,start=0,stop=0;
    String chromosome="",sample_count="",refSeq="";
    String strand="";
    int totalReads=0;
    ArrayList<RNASequence> seq=new ArrayList<RNASequence>();
    ArrayList<SequenceVariant> variant=new ArrayList<SequenceVariant>();
    HashMap annotHM=new HashMap();
    ArrayList<Annotation> annotList=new ArrayList<Annotation>();
    
    public SmallNonCodingRNA(int id, int start,int stop, String chr,String refSeq,int strand,int totalReads){
        this(id,start,stop,chr,refSeq,strand);
        this.totalReads=totalReads;
    }
    
    public SmallNonCodingRNA(int id, int start,int stop, String chr,String refSeq,int strand){
        this.id=id;
        this.start=start;
        this.stop=stop;
        this.chromosome=chr;
        this.refSeq=refSeq;
        if(strand==1){
            this.strand="+";
        }else if(strand==-1){
            this.strand="-";
        }else{
            this.strand=".";
        }
    }
    
    public SmallNonCodingRNA(int id,Connection conn, Logger log){
        this.id=id;
        String smncQuery="Select rsn.rna_smnc_id,rsn.feature_start,rsn.feature_stop,rsn.sample_count,rsn.total_reads,rsn.strand,rsn.reference_seq,c.name "+
                             "from rna_sm_noncoding rsn, chromosomes c "+ 
                             "where rsn.rna_smnc_id="+id+" "+
                             "and rsn.chromosome_id=c.chromosome_id";

        String smncSeqQuery="select s.* from rna_smnc_seq s "+
                                "where s.rna_smnc_id="+id;
                                
        String smncAnnotQuery="select a.rna_smnc_annot_id,a.rna_smnc_id,a.annotation,s.shrt_name from rna_smnc_annot a,rna_annot_src s "+
                                "where s.rna_annot_src_id=a.source_id "+
                                "and a.rna_smnc_id="+id;
           
        String smncVarQuery="select v.* from rna_smnc_variant v "+
                                "where v.rna_smnc_id="+id;

            try{
                log.debug("SQL smnc FROM QUERY\n"+smncQuery);
                PreparedStatement ps = conn.prepareStatement(smncQuery);
                ResultSet rs = ps.executeQuery();
                while(rs.next()){

                    this.start=rs.getInt(2);
                    this.stop=rs.getInt(3);
                    this.sample_count=rs.getString(4);
                    this.totalReads=rs.getInt(5);
                    int strand=rs.getInt(6);
                    if(strand==1){
                        this.strand="+";
                    }else if(strand==-1){
                        this.strand="-";
                    }else{
                        this.strand=".";
                    }
                    this.refSeq=rs.getString(7);
                    this.chromosome=rs.getString(8);
                }
                ps.close();
                log.debug("SQL smncSeq FROM QUERY\n"+smncSeqQuery);
                ps = conn.prepareStatement(smncSeqQuery);
                rs = ps.executeQuery();
                while(rs.next()){
                    int subid=rs.getInt(1);
                    String seq=rs.getString(3);
                    int readCount=rs.getInt(4);
                    int unique=rs.getInt(5);
                    int offset=rs.getInt(6);
                    int bnlx=rs.getInt(7);
                    int shrh=rs.getInt(8);
                    HashMap match=new HashMap();
                    match.put("BNLX", bnlx);
                    match.put("SHRH", shrh);
                    RNASequence tmpSeq=new RNASequence(subid,seq,readCount,unique,offset,match);
                    this.addSequence(tmpSeq);
                }
                ps.close();
                log.debug("SQL smncAnnot FROM QUERY\n"+smncAnnotQuery);
                ps = conn.prepareStatement(smncAnnotQuery);
                rs = ps.executeQuery();
                while(rs.next()){
                    int subid=rs.getInt(1);
                    String annot=rs.getString(3);
                    String src=rs.getString(4);
                    Annotation tmpAnnot=new Annotation(subid,src,annot,"smnc");
                    this.addAnnotation(tmpAnnot);
                }
                ps.close();
                ps = conn.prepareStatement(smncVarQuery);
                rs = ps.executeQuery();
                while(rs.next()){
                    int subid=rs.getInt(1);
                    int start=rs.getInt(3);
                    int stop=rs.getInt(4);
                    String refSeq=rs.getString(5);
                    String strainSeq=rs.getString(6);
                    String type=rs.getString(7);
                    String strain=rs.getString(8);
                    SequenceVariant tmpVar=new SequenceVariant(subid,start,stop,refSeq,strainSeq,type,strain);
                    this.addVariant(tmpVar);
                }
                ps.close();
            }catch(SQLException e){
                log.error("Error retreiving SMNCs.",e);
                //session.setAttribute("getTransControllingEQTL","Error retreiving eQTLs.  Please try again later.  The administrator has been notified of the problem.");
                e.printStackTrace(System.err);
                Email myAdminEmail = new Email();
                    myAdminEmail.setSubject("Exception thrown in GeneDataTools.getSmallNonCodingRNA");
                    myAdminEmail.setContent("There was an error while running getSmallNonCodingRNA.\n",e);
                    try {
                        myAdminEmail.sendEmailToAdministrator("");
                    } catch (Exception mailException) {
                        log.error("error sending message", mailException);
                    }
            }
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getStart() {
        return start;
    }

    public void setStart(int start) {
        this.start = start;
    }

    public int getStop() {
        return stop;
    }

    public void setStop(int stop) {
        this.stop = stop;
    }

    public String getChromosome() {
        return chromosome;
    }

    public void setChromosome(String chromosome) {
        this.chromosome = chromosome;
    }

    public String getSample_count() {
        return sample_count;
    }

    public void setSample_count(String sample_count) {
        this.sample_count = sample_count;
    }

    public String getRefSeq() {
        return refSeq;
    }

    public void setRefSeq(String refSeq) {
        this.refSeq = refSeq;
    }

    public String getStrand() {
        return strand;
    }

    public void setStrand(String strand) {
        this.strand = strand;
    }

    public int getTotalReads() {
        return totalReads;
    }

    public void setTotalReads(int totalReads) {
        this.totalReads = totalReads;
    }

    public ArrayList<RNASequence> getSeq() {
        return seq;
    }

    public void setSeq(ArrayList<RNASequence> seq) {
        this.seq = seq;
    }

    public ArrayList<SequenceVariant> getVariant() {
        return variant;
    }

    public void setVariant(ArrayList<SequenceVariant> variant) {
        this.variant = variant;
    }
    
    public void addSequence(RNASequence seq){
        this.seq.add(seq);
    }
    public void addVariant(SequenceVariant var){
        this.variant.add(var);
    }
    
    public void addAnnotation(Annotation annot){
        this.annotList.add(annot);
        if(this.annotHM.containsKey(annot.getSource())){
            ArrayList<Annotation> tmp=(ArrayList<Annotation>)annotHM.get(annot.getSource());
            tmp.add(annot);
        }else{
            ArrayList<Annotation> tmp=new ArrayList<Annotation>();
            tmp.add(annot);
            annotHM.put(annot.getSource(), tmp);
            //log.debug(this.id+":"+annot.getSource()+"::"+annot.getId());
        }
    }
    
    public ArrayList<Annotation> getAnnotationBySource(String source){
        ArrayList<Annotation> ret=null;
        if(annotHM.containsKey(source)){
            ret=(ArrayList<Annotation>)annotHM.get(source);
        }
        return ret;
    }
    public ArrayList<Annotation> getAnnotations(){
        return this.annotList;
    }
}
