package edu.ucdenver.ccp.PhenoGen.data.Bio;


import java.util.ArrayList;

/**
 *
 * @author smahaffey
 */
public class EQTLCount implements Comparable{
    String location="";
    int probeCount=0;
    double minLOD=0;
    double maxLOD=0;
    double sumLOD=0;
    ArrayList<EQTL> qtlList=new ArrayList<EQTL>();
            
    public EQTLCount(){
        
    }
    
    public void add(EQTL tmp){
        if(probeCount==0){
            minLOD=tmp.getLODScore();
            maxLOD=tmp.getLODScore();
        }else{
            if(tmp.getLODScore()<minLOD){
                minLOD=tmp.getLODScore();
            }
            if(tmp.getLODScore()>maxLOD){
                maxLOD=tmp.getLODScore();
            }
        }
        sumLOD=sumLOD+tmp.getLODScore();
        qtlList.add(tmp);
        probeCount++;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public int getProbeCount() {
        return probeCount;
    }

    public void setProbeCount(int probeCount) {
        this.probeCount = probeCount;
    }

    public double getMinLOD() {
        return minLOD;
    }

    public void setMinLOD(double minLOD) {
        this.minLOD = minLOD;
    }

    public double getMaxLOD() {
        return maxLOD;
    }

    public void setMaxLOD(double maxLOD) {
        this.maxLOD = maxLOD;
    }

    public ArrayList<EQTL> getQtlList() {
        return qtlList;
    }

    public void setQtlList(ArrayList<EQTL> qtlList) {
        this.qtlList = qtlList;
    }

    public double getAvgLOD(){
        return this.sumLOD/this.probeCount;
    }
    
    public int compareTo(Object t) {
        EQTLCount ec2=(EQTLCount)t;
        if(this.getProbeCount()>ec2.getProbeCount()){
            return -1;
        }else if(this.getProbeCount()<ec2.getProbeCount()){
            return 1;
        }
        if(this.getMaxLOD()>ec2.getMaxLOD()){
            return -1;
        }else if(this.getMaxLOD()<ec2.getMaxLOD()){
            return 1;
        }
        if(this.getMinLOD()>ec2.getMinLOD()){
            return -1;
        }else if(this.getMinLOD()<ec2.getMinLOD()){
            return 1;
        }
        return 0;
    }
}
