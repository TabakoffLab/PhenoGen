package edu.ucdenver.ccp.PhenoGen.tools.analysis;

import java.util.ArrayList;
import java.io.BufferedReader;
/* for handling exceptions in Threads */

import java.io.*;



/* for logging messages */
import org.apache.log4j.Logger;

public class GeneLoc{
    String id="",geneSymbol="",strand;
    long start=0,stop=0;
    public GeneLoc(String name,String symbol,long start, long stop,String strand){
        id=name;
        this.geneSymbol=symbol;
        this.start=start;
        this.stop=stop;
        this.strand=strand;
    }

    public String getID() {
        return id;
    }

    public void setID(String id) {
        this.id = id;
    }

    public String getGeneSymbol() {
        return geneSymbol;
    }

    public void setGeneSymbol(String geneSymbol) {
        this.geneSymbol = geneSymbol;
    }

    public long getStart() {
        return start;
    }

    public void setStart(long start) {
        this.start = start;
    }

    public long getStop() {
        return stop;
    }

    public void setStop(long stop) {
        this.stop = stop;
    }
    
    public String getStrand(){
        return strand;
    }
    
    public static ArrayList<GeneLoc> readGeneListFile(String outputDir, Logger log){
        ArrayList<GeneLoc> ret=new ArrayList<GeneLoc>();
        File inf=new File(outputDir+"geneList.txt");
        try{
        BufferedReader in = new BufferedReader(new FileReader(inf));
        while(in.ready()){
            String line=in.readLine();
            String[] tabs=line.split("\t");
            String ensID=tabs[0];
            String geneSym=tabs[1];
            String sStart=tabs[2];
            String sStop=tabs[3];
            String strand=tabs[4];
            long start=Long.parseLong(sStart);
            long stop=Long.parseLong(sStop);
            GeneLoc g=new GeneLoc(ensID,geneSym,start,stop,strand);
            ret.add(g);
        }
        in.close();
        }catch(IOException e){
            log.error("Error reading GeneList.txt.",e);
        }
        return ret;
    }
    
}