package edu.ucdenver.ccp.iDecoder;

import java.io.*;
import java.sql.*;
import java.util.*;
import edu.ucdenver.ccp.util.sql.*;
import edu.ucdenver.ccp.util.*;


/* for logging messages */
import org.apache.log4j.Logger;       

public class PhenoGenIDs{

  private Logger log=null;
  private int datasetID;
  private String filename;
  private Connection conn;

  public PhenoGenIDs (int datasetID,String filename, Connection conn) {
	log = Logger.getRootLogger();
        this.datasetID=datasetID;
        this.filename=filename;
        this.conn=conn;
  }

  public ResultSet getIDs(Connection conn) throws SQLException {
  	

	String query = "select gene_id,isoform_id,c.name,trstart,trstop,strand,rta.annotation "+
                "from rna_transcripts rt, CHROMOSOMES c, RNA_TRANSCRIPTS_ANNOT rta "+
                "where rt.RNA_TRANSCRIPT_ID=rta.RNA_TRANSCRIPT_ID and rta.SOURCE_ID=13 "+
                "and rt.CHROMOSOME_ID=c.CHROMOSOME_ID and RNA_DATASET_ID="+datasetID; 
 
	log.debug("in getIDs");
	PreparedStatement pstmt = null;
        ResultSet rs=null;
	try {
                pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
                rs=pstmt.executeQuery();
	} catch (SQLException e) {
		log.error("In exception of getIDs", e);
		throw e;
	}
	return rs;
  }

  

  public void run() {

	try {
		String idFileName = "/data/iDecoder/InputFiles/PhenoGen/"+filename;
		
		PhenoGenIDs pgi = new PhenoGenIDs(datasetID,filename,conn);

        	ResultSet rs= pgi.getIDs(conn);
                
                HashMap<String,GeneID> genes=new HashMap<String,GeneID>();
                //ProcessResults
                try {
                	while (rs.next()) {
                            
                        	String geneID=rs.getString("Gene_id");
                                String trxID=rs.getString("Isoform_id");
                                String chr=rs.getString("name");
                                int start=rs.getInt("TRstart");
                                int stop=rs.getInt("TRstop");
                                int strand=rs.getInt("Strand");
                                String annot=rs.getString("Annotation");
                                GeneID cur=null;
                                if(genes.containsKey(geneID)){
                                    cur=genes.get(geneID);
                                }else{
                                    cur=new GeneID(geneID,chr,start,stop,strand,annot);
                                    genes.put(geneID, cur);
                                }
                                cur.addTrx(new TransID(trxID,chr,start,stop,strand,annot,cur));
                                //System.out.println("geneID:"+geneID+"\ttrxID:"+trxID);
			}
                } catch (SQLException e) {
                        log.error("exception running SQL", e);
                        System.err.println("exception running SQL");
                        e.printStackTrace();
                        throw e;
                }
                
                //Output Genes
                BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(new File(filename)), 16000);
                Iterator itr=genes.keySet().iterator();
                while(itr.hasNext()){
                    GeneID cur=genes.get(itr.next());
                    cur.updateCoordFromTrx();
                    //print gene line
                    bufferedWriter.write(cur.toString()+"\n");
                    HashMap<String,TransID> trx=cur.getTranscripts();
                    Iterator itrt=trx.keySet().iterator();
                    while(itrt.hasNext()){
                        TransID curTrx=trx.get(itrt.next());
                        //print trx line
                        bufferedWriter.write(curTrx.toString()+"\n");
                    }
                }
                bufferedWriter.close();
		
        } catch (Exception e) {
                log.debug("in exception of PhenoGenIDs", e);
                System.err.println("in exception of PhenoGenIDs");
                e.printStackTrace();
		
	}
  }
  public static void main(String[] args) {
	try {
		
        } catch (Exception e) {
                System.out.println("in exception of JacksonLab");
                e.printStackTrace();
        }

  }

}

class GeneID{
    private String geneID;
    private String chr;
    private int start;
    private int stop;
    private int strand;
    private ArrayList<String> annotation;
    private HashMap<String,TransID> trxHM;
    GeneID(String geneID,String chr,int start, int stop,int strand,String annotation){
        this.geneID=geneID;
        this.start=start;
        this.stop=stop;
        this.strand=strand;
        this.chr=chr;
        this.annotation=new ArrayList<String>();
        //parse Annotation
        String[] tmpA=annotation.split(":");
        for(int i=0;i<tmpA.length;i++){
            if( tmpA[i].startsWith("ENSRNOG") || ! tmpA[i].startsWith("ENSRNOT") ){
                this.annotation.add(tmpA[i]);
            }
        }
        trxHM=new HashMap<String,TransID>();
    }
    
    void updateCoordFromTrx(){
        Iterator trxItr=trxHM.keySet().iterator();
        while(trxItr.hasNext()){
            TransID t=trxHM.get(trxItr.next());
            if(t.getStart()<this.start){
                this.start=t.getStart();
            }
            if(t.getStop()>this.stop){
                this.stop=t.getStop();
            }
        }
    }
    void addTrx(TransID trx){
        if(!trxHM.containsKey(trx.getTrxID())){
            trxHM.put(trx.getTrxID(), trx);
        }
    }

    public String getGeneID() {
        return geneID;
    }

    public String getChr() {
        return chr;
    }

    public int getStart() {
        return start;
    }

    public int getStop() {
        return stop;
    }

    public int getStrand() {
        return strand;
    }

    public ArrayList<String> getAnnotation() {
        return annotation;
    }

    public HashMap<String, TransID> getTranscripts() {
        return trxHM;
    }
    
    public String toString(){
        String annot="";
        for(int i=0;i<annotation.size();i++){
            if(i>0){
                annot+=",";
            }
            annot+=annotation.get(i);
        }
        return geneID+"\t"+chr+"\t"+start+"\t"+stop+"\t"+strand+"\t"+annot;
    }
    
}

class TransID{
    private String trxID;
    private String chr;
    private int start;
    private int stop;
    private int strand;
    private String annot;
    
    TransID(String trxId,String chr, int start, int stop, int strand, String annotation,GeneID gene){
        this.trxID=trxId;
        this.chr=chr;
        this.start=start;
        this.stop=stop;
        this.strand=strand;
        this.annot=gene.getGeneID();
        String[] split=annotation.split(":");
        for(int i=0;i<split.length;i++){
            if(split[i].startsWith("ENSRNOT")){
                this.annot+=","+split[i];
            }
        }
    }

    public String getTrxID() {
        return trxID;
    }

    public String getChr() {
        return chr;
    }

    public int getStart() {
        return start;
    }

    public int getStop() {
        return stop;
    }

    public int getStrand() {
        return strand;
    }

    public String getAnnot() {
        return annot;
    }
    public String toString(){

        return trxID+"\t"+chr+"\t"+start+"\t"+stop+"\t"+strand+"\t"+annot;
    }
}