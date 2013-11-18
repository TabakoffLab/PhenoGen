<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  This file takes the input from an ajax request and returns a json object with genes.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ page language="java"
        import="java.util.GregorianCalendar"
		import="java.util.Date"
		import="org.json.*" %>

<%@ include file="/web/common/session_vars.jsp"  %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>

<%
String folderName="";
if(request.getParameter("folderName")!=null){
	folderName=request.getParameter("folderName").trim();
}
//String chr="chr1";
//String chr="chr19";
//int start=220933937;
//int start=54000000;
//int stop=228258506;
//int stop=55000000;
String organism="Rn";
String fullOrganism="Rattus_norvegicus";
//String date="_4232013_165646";
//String date="_4242013_122355";
//String path=applicationRoot+contextRoot+"tmpData/regionData/"+organism+chr+"_"+start+"_"+stop+date+"/Region.xml";
String path=applicationRoot+contextRoot+"tmpData/regionData/"+folderName+"/Region.xml";

LinkGenerator lg=new LinkGenerator(session);
log.debug(path);

ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> geneList=edu.ucdenver.ccp.PhenoGen.data.Bio.Gene.readGenes(path);

geneList=gdt.mergeAnnotatedOverlapping(geneList);

org.json.JSONObject json      = new JSONObject();
JSONArray  genes = new JSONArray();
JSONObject genejson;
try
{

   for (int i=0 ; i<geneList.size() ; i++)
   {
   		edu.ucdenver.ccp.PhenoGen.data.Bio.Gene gene=geneList.get(i);
		String txList="";
		ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Transcript> tx=gene.getTranscripts();
		for(int j=0;j<tx.size();j++){
			if(tx.get(j).getID().startsWith("ENS")){
				txList+=tx.get(j).getID()+"<BR>";
			}else{
				txList+="<B>"+tx.get(j).getID()+"</B> - "+tx.get(j).getMatchReason()+"<BR>";
			}
		}
		log.debug("JSON:"+gene.getGeneID());
       genejson = new JSONObject();
       genejson.put("Name"     , gene.getGeneID().replaceAll("\\.","_"));
       genejson.put("start"        , gene.getStart());
       genejson.put("end"           , gene.getEnd());
	   genejson.put("html",  "Ensembl ID:<a href=\""+lg.getEnsemblLinkEnsemblID(gene.getGeneID(),fullOrganism)+"\" target=\"_blank\">"+ gene.getGeneID()+"</a><BR>Gene Symbol:"+gene.getGeneSymbol()+"<BR>Location: "+gene.getChromosome()+":"+gene.getStart()+"-"+gene.getEnd()+"<BR>Strand:"+gene.getStrand()+"<BR>Transcripts:<BR>"+txList);
	   genejson.put("strand",gene.getStrand());
       genes.put(genejson);
   }
   //json.put("Genes", genes);
}
catch (JSONException jse)
{ 

}
response.setContentType("application/json");
response.getWriter().write(genes.toString());%>




