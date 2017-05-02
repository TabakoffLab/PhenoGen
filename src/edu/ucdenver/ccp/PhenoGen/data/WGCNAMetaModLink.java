package edu.ucdenver.ccp.PhenoGen.data;


/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to filter and statistics methods applied to a version of a dataset.  
 * <br>
 *  @author  Spencer Mahaffey
 */

public class WGCNAMetaModLink {
  	private String mod1;
        private String mod2;
        private double cor;
        
        public WGCNAMetaModLink(String mod1,String mod2,double cor){
            this.mod1=mod1;
            this.mod2=mod2;
            this.cor=cor;
        }

    public String getModuleName1() {
        return mod1;
    }

    public void setModuleName1(String mod1) {
        this.mod1 = mod1;
    }

    public String getModuleName2() {
        return mod2;
    }

    public void setModuleName2(String mod2) {
        this.mod2 = mod2;
    }

    public double getCorrelation() {
        return cor;
    }

    public void setCorrelation(double cor) {
        this.cor = cor;
    }
     
}

