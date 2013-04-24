package edu.ucdenver.ccp.PhenoGen.data.Bio;

import edu.ucdenver.ccp.PhenoGen.data.Bio.RNASequence;
import edu.ucdenver.ccp.PhenoGen.data.Bio.SequenceVariant;
import edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation;
import edu.ucdenver.ccp.PhenoGen.data.Bio.MirDeepAnnotation;
import edu.ucdenver.ccp.PhenoGen.web.mail.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;


/* for logging messages */
import org.apache.log4j.Logger;
/**
 *
 * @author smahaffey
 */
public class SmallNonCodingRNA extends Transcript{
    String chromosome="",sample_count="",refSeq="";
    int totalReads=0;
    ArrayList<RNASequence> seq=new ArrayList<RNASequence>();
    ArrayList<SequenceVariant> variant=new ArrayList<SequenceVariant>();
    HashMap variantHM=new HashMap();
    HashMap annotHM=new HashMap();
    int numID=0;
    //ArrayList<Annotation> annotList=new ArrayList<Annotation>();
    
    public SmallNonCodingRNA(int id, int start,int stop, String chr,String refSeq,int strand,int totalReads){
        //this(id,strand,start,stop);
        //this.chromosome=chr;
        //this.refSeq=refSeq;
        this(id,start,stop,chr,refSeq,strand);
        this.totalReads=totalReads;
    }
    
    public SmallNonCodingRNA(int id, long start,long stop, String chr,String refSeq,int strand){
        //this(id,strand,start,stop);
        this.ID="smRNA_"+Integer.toString(id);
        this.numID=id;
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
        this.ID=Integer.toString(id);
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
        String smncMirQuery="select * from rna_smnc_mirdeep where rna_smnc_annot_id in (select rna_smnc_annot_id from rna_smnc_annot "+
                                "where rna_smnc_id="+id+" )";

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
                
                HashMap tmpMDAnnot=new HashMap();
                ps = conn.prepareStatement(smncMirQuery);
                rs = ps.executeQuery();
                while(rs.next()){
                    int mdid=rs.getInt(1);
                    String provID=rs.getString(3);
                    String rfam=rs.getString(6);
                    int mature=rs.getInt(8);
                    int star=rs.getInt(10);
                    int total=rs.getInt(7);
                    int loop=rs.getInt(9);
                    double score=rs.getDouble(4);
                    double prob=rs.getDouble(5);
                    String matureSeq=rs.getString(12);
                    String starSeq=rs.getString(13);
                    String preCurSeq=rs.getString(14);
                    long start=rs.getLong(16);
                    long stop=rs.getLong(17);
                    String strand=rs.getString(18);
                    String chr=rs.getString(15);
                    boolean sig=false;
                    if(rs.getInt(11)==1){
                        sig=true;
                    }
                    MirDeepAnnotation tmpAnnot=new MirDeepAnnotation(mdid,provID,rfam,mature,star,total,loop,score,prob,matureSeq,starSeq,preCurSeq,start,stop,strand,chr,sig);
                    tmpMDAnnot.put(provID, tmpAnnot);
                }
                ps.close();
                
                log.debug("SQL smncAnnot FROM QUERY\n"+smncAnnotQuery);
                ps = conn.prepareStatement(smncAnnotQuery);
                rs = ps.executeQuery();
                while(rs.next()){
                    int subid=rs.getInt(1);
                    String annot=rs.getString(3);
                    String src=rs.getString(4);
                    if(!src.equals("mirDeep")){
                        Annotation tmpAnnot=new Annotation(subid,src,annot,"smnc");
                        this.addAnnotation(tmpAnnot);
                    }else{
                        Annotation tmp=(Annotation)tmpMDAnnot.get(annot);
                        if(tmp!=null){
                            this.addAnnotation(tmp);
                        }
                    }
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

    public int getNumberID(){
        return this.numID;
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
        setupSnps(var);
    }
    
    public void addAnnotation(Annotation annot){
        this.fullAnnotation.add(annot);
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
        return this.fullAnnotation;
    }
    
    public int getSnpCount(String strain,String type){
        int ret=0;
        HashMap m=(HashMap)variantHM.get(strain);
        if(m!=null){
            HashMap t=(HashMap)m.get(type);
            if(t!=null){
                ret=t.size();
            }
        }
        return ret;
    }
    
    private void setupSnps(SequenceVariant v){
        //Logger log = Logger.getRootLogger();
        //fill strain specific
                HashMap strain=null;
                HashMap type=null;
                if(this.variantHM.containsKey(v.getStrain())){
                    strain=(HashMap)variantHM.get(v.getStrain());
                }else{
                    strain=new HashMap();
                    variantHM.put(v.getStrain(), strain);
                }
                if(strain.containsKey(v.getShortType())){
                    type=(HashMap)strain.get(v.getShortType());
                }else{
                    type=new HashMap();
                    strain.put(v.getShortType(), type);
                }
                if(type.containsKey(v.getId())){
                    
                }else{
                    type.put(v.getId(), v);
                }

        //find common variants
        HashMap common=null;
        if(variantHM.containsKey("common")){
            common=(HashMap)variantHM.get("common");
        }else{
            common=new HashMap();
            variantHM.put("common", common);
        }
        //Need to make this work for different strains in the future but for now this will work.
        HashMap bnlx=(HashMap)variantHM.get("BNLX");
        HashMap shrh=(HashMap)variantHM.get("SHRH");
        if(bnlx!=null&&shrh!=null){
            Iterator bnlxKey=bnlx.keySet().iterator();
            while(bnlxKey.hasNext()){
                String bTypeKey=(String)bnlxKey.next();
                HashMap bTypeHM=(HashMap)bnlx.get(bTypeKey);
                HashMap sTypeHM=(HashMap)shrh.get(bTypeKey);
                //log.debug("bType:"+bTypeKey);
                ArrayList<Integer> bToRemove=new ArrayList<Integer>();
                ArrayList<Integer> sToRemove=new ArrayList<Integer>();
                if(bTypeHM!=null&&sTypeHM!=null){
                    //log.debug("TYPE MATCH");
                    matchCommon(common,bTypeHM,sTypeHM,bToRemove,sToRemove);
                    while(!bToRemove.isEmpty()){
                        Integer tmp=bToRemove.get(0);
                        bTypeHM.remove(tmp.intValue());
                        bToRemove.remove(0);
                    }
                    while(!sToRemove.isEmpty()){
                        Integer tmp=sToRemove.get(0);
                        sTypeHM.remove(tmp.intValue());
                        sToRemove.remove(0);
                    }
                }
            }
        }
    }
    
    private void matchCommon(HashMap common,HashMap bTypeHM,HashMap sTypeHM,ArrayList<Integer> bToRemove,ArrayList<Integer> sToRemove){
       //Logger log = Logger.getRootLogger();
       Iterator bnlxKey=bTypeHM.keySet().iterator();
        while(bnlxKey.hasNext()){
                int bk=((Integer)bnlxKey.next()).intValue();
                SequenceVariant bv=(SequenceVariant)bTypeHM.get(bk);
                if(bv!=null){
                    //log.debug("bnlxVar:"+bv.toString());
                    boolean foundMatch=false;
                    Iterator shrhKey=sTypeHM.keySet().iterator();
                    while(!foundMatch&&shrhKey.hasNext()){
                        int sk=((Integer)shrhKey.next()).intValue();
                        SequenceVariant sv=(SequenceVariant)sTypeHM.get(sk);
                        if(sv!=null&& bv.getShortType().equals(sv.getShortType())){
                            //log.debug(" Compare to shrhVar:"+sv.toString());
                            if(bv.getStart()==sv.getStart() && bv.getStop()==sv.getStop() && 
                                    bv.getRefSeq().equals(sv.getRefSeq()) && bv.getStrainSeq().equals(sv.getStrainSeq())){
                                HashMap type;
                                if(common.containsKey(bv.getShortType())){
                                    type=(HashMap)common.get(bv.getShortType());
                                }else{
                                    type=new HashMap();
                                    common.put(bv.getShortType(), type);
                                }
                                //log.debug("FOUND MATCH");
                                foundMatch=true;
                                ArrayList<SequenceVariant> combined=new ArrayList<SequenceVariant>();
                                combined.add(sv);
                                combined.add(bv);
                                type.put(bv.getId()+":"+sv.getId(),combined);
                                sToRemove.add(sk);
                                bToRemove.add(bk);
                            }
                        }
                    }
                }

            }
    }
    
}
