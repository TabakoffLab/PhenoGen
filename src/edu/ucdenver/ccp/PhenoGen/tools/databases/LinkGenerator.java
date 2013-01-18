package edu.ucdenver.ccp.PhenoGen.tools.databases;

import org.apache.log4j.Logger;
import javax.servlet.http.HttpSession;

public class LinkGenerator {
    HttpSession session;
    
    String contextPath="";
    
    public LinkGenerator(HttpSession session){
        this.session=session;
        this.contextPath=(String)session.getAttribute("contextPath");
        if(contextPath!=null&&contextPath.endsWith("null")&&contextPath.lastIndexOf("/")>0){
            contextPath=contextPath.substring(0,contextPath.lastIndexOf("/"));
        }
    }
    
    static public String getMGILink(String term){
        return "http://www.informatics.jax.org/searches/marker_report.cgi?op%3AmarkerSymname=contains&markerSymname="+term+"&symnameBreadth=CM&chromosome=&op%3Acoords=between&coords=&coordUnits=bp&startMarker=&endMarker=&op%3Acytoband=%3D&cytoband=&op%3Aoffset=between&offset=&op%3Ago_term=contains&go_term=&_Ontology_key=Molecular+Function&_Ontology_key=Biological+Process&_Ontology_key=Cellular+Component&interpro=&phenotypes=&clone=&sort=Nomenclature&*limit=500&format=Web";
    }
    
    static public String getBrainAtlasLink(String id){
        id=id.replaceAll(" ", "%20");
        return "http://mouse.brain-map.org/search/show?page_num=0&page_size=33&no_paging=false&exact_match=false&search_term="+id+"&search_type=gene";
    }
    
    static public String getNCBILink(String searchTerm){
        return "http://www.ncbi.nlm.nih.gov/gene?term="+searchTerm;
    }
    static public String getNCBILink(String searchTerm, String organism){
        String org="";
        if(organism.equals("Mm")){
            org="mus%20musculus";
        }else{
            org="rattus%20norvegicus";
        }
        return "http://www.ncbi.nlm.nih.gov/gene?term="+searchTerm+"%29%20AND%20"+org+"[Organism]";
    }
    static public String getUniProtLinkGene(String searchTerm){
        if(!searchTerm.startsWith("ENS")){
            searchTerm="gene:"+searchTerm;
        }
        return "http://www.uniprot.org/uniprot/?query="+searchTerm+"&sort=score";
    }
    static public String getUniProtLinkGene(String searchTerm, String organism){
        String org="";
        if(organism.equals("Mm")){
            org="Mus+musculus+[10090]";
        }else{
            org="Rattus+norvegicus+[10116]";
        }
        /*if(!searchTerm.startsWith("ENS")){
            searchTerm="gene:"+searchTerm;
        }*/
        return "http://www.uniprot.org/uniprot/?query="+searchTerm+"+AND+organism%3A%22"+org+"%22&sort=score";
    }
    
    static public String getRGDLink(String searchTerm){
        return "http://rgd.mcw.edu/rgdweb/search/genes.html?term="+searchTerm+"&chr=ALL&start=&stop=&map=60&imapped=1&speciesType=0&obj=gene";
        
    }
    static public String getRGDLink(String searchTerm,String organism){
        int org=3;
        if(organism.equals("Mm")){
            org=2;
        }else if(organism.equals("Hs")){
            org=1;
        }
        return "http://rgd.mcw.edu/rgdweb/search/genes.html?term="+searchTerm+"&chr=ALL&start=&stop=&map=60&imapped=1&speciesType="+org+"&obj=gene";
        
    }
    
    static public String getEnsemblLinkEnsemblID(String ensemblID,String fullOrganism){
        return "http://www.ensembl.org/"+fullOrganism+"/Gene/Summary?g="+ensemblID;
    }
    
    static public String getMGIQTLLink(String mgiQTLID){
        return "http://www.informatics.jax.org/marker/MGI:"+mgiQTLID;
    }
    
    static public String getRGDQTLLink(String rgdQTLID){
        return "http://rgd.mcw.edu/rgdweb/report/qtl/main.html?id="+rgdQTLID;
    }
    
    static public String getRGDRefLink(String rgdID){
        return "http://rgd.mcw.edu/rgdweb/report/reference/main.html?id="+rgdID;
    }
    
    static public String getPubmedRefLink(String pubmedID){
        return "http://www.ncbi.nlm.nih.gov/pubmed/"+pubmedID;
    }
    
    /*statis public String getMGI_Link(String searchTerm){
        
    }*/
    
    public String getRegionLink(String chr,long min,long max,String organism,boolean auto,boolean popup,boolean showTranscript){
        if(!chr.toLowerCase().startsWith("chr")){
            chr="chr"+chr;
        }
        String gene=chr+":"+min+"-"+max;
        return getGeneLink(gene,organism,auto,popup,showTranscript);
    }
    
    public String getGeneLink(String gene,String organism,boolean auto,boolean popup,boolean showTranscript){
        String autoString="";
        String windowString="";
        String tdString="";
        if(auto){
            autoString="&auto=Y";
        }
        if(popup){
            windowString="&newWindow=Y";
        }
        if(showTranscript){
            tdString="&showTrans=Y";
        }
        
        String link="gene.jsp?geneTxt="+gene+"&speciesCB="+organism+autoString+windowString+tdString;
        return link;
    }
}