<%@ include file="/web/common/anon_session_vars.jsp" %>


<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>

<%

	String myOrganism="";
	String id="";
	String chromosome="";
	
	String[] selectedLevels=null;
	String levelString="core;extended;full";
	String fullOrg="";
		String panel="";
	String gcPath="";
	int selectedGene=0;
	ArrayList<String>geneSymbol=new ArrayList<String>();
	
	
	
	if(request.getParameter("levels")!=null && !request.getParameter("levels").equals("")){			
				String tmpSelectedLevels = request.getParameter("levels");
				selectedLevels=tmpSelectedLevels.split(";");
				log.debug("Getting selected levels:"+tmpSelectedLevels);
				levelString = "";
				//selectedLevelError = true;
				for(int i=0; i< selectedLevels.length; i++){
					//selectedLevelsError = false;
					levelString = levelString + selectedLevels[i] + ";";
				}
	}else{
		log.debug("Getting selected levels: NULL Using defaults.");
		selectedLevels=levelString.split(";");
	}
	if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species").trim();
		if(myOrganism.equals("Rn")){
			panel="BNLX/SHRH";
			fullOrg="Rattus_norvegicus";
		}else{
			panel="ILS/ISS";
			fullOrg="Mus_musculus";
		}
	}
	if(request.getParameter("chromosome")!=null){
		chromosome=request.getParameter("chromosome");
	}
	
		
	if(request.getParameter("geneSymbol")!=null){
		geneSymbol.add(request.getParameter("geneSymbol"));
	}else{
		geneSymbol.add("None");
	}
	if(request.getParameter("id")!=null){
		id=request.getParameter("id");
	}
	
	gcPath=applicationRoot + contextRoot+"tmpData/geneData/" +id+"/";
	
	String[] tissuesList1=new String[1];
	String[] tissuesList2=new String[1];
	if(myOrganism.equals("Rn")){
		tissuesList1=new String[4];
		tissuesList2=new String[4];
		tissuesList1[0]="Brain";
		tissuesList2[0]="Whole Brain";
		tissuesList1[1]="Heart";
		tissuesList2[1]="Heart";
		tissuesList1[2]="Liver";
		tissuesList2[2]="Liver";
		tissuesList1[3]="Brown Adipose";
		tissuesList2[3]="Brown Adipose";
	}else{
		tissuesList1[0]="Brain";
		tissuesList2[0]="Whole Brain";
	}
	int rnaDatasetID=0;
	int arrayTypeID=0;
	
	int[] tmp=gdt.getOrganismSpecificIdentifiers(myOrganism);
							if(tmp!=null&&tmp.length==2){
								rnaDatasetID=tmp[1];
								arrayTypeID=tmp[0];
							}
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> tmpGeneList=gdt.getGeneCentricData(id,id,panel,myOrganism,rnaDatasetID,arrayTypeID,true);
	log.debug("OPENED GENE:"+id);

        //response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        //response.setDateHeader("Expires", 0);

        %>
<BR />

<%@ include file="/web/GeneCentric/geneEQTLPart.jsp" %>

<script type="text/javascript">
	$('#geneEQTL table#circosOptTbl').css("top","0px");
	$("span[name='circosOption']").css("margin-left","60px");
	//runCircos();
</script>


