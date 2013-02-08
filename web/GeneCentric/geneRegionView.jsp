<%@ include file="/web/common/session_vars.jsp" %>

<%
String myGene="";
String myGeneID="";
if(request.getParameter("region")!=null){
		myGene=request.getParameter("region");
}
if(request.getParameter("gene")!=null){
		myGeneID=request.getParameter("gene");
}
%>



<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>

<% 

	//GeneDataTools gdt=new GeneDataTools();
    gdt.setSession(session);
	
	String myOrganism="";
	

	ArrayList<String> ucscURL=new ArrayList<String>();
	ArrayList<String> genURL=new ArrayList<String>();
	ArrayList<String> geneSymbol=new ArrayList<String>();
	ArrayList<String> firstEnsemblID=new ArrayList<String>();
	//ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList=new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
	
	String fullImg="";
	String fullOrg="";
	String filteredImg="";
	String panel="";
	String chromosome="";

	boolean region=true;
	
	int rnaDatasetID=0;
	int arrayTypeID=0;
	int selectedGene=0;
	int min=0;
	int max=0;
	String selectedEnsemblID="";
	String regionError="";
	

	if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species").trim();
	}
	
	
	
		log.debug("RUNNING REGION");
		int[] tmp=gdt.getOrganismSpecificIdentifiers(myOrganism,dbConn);
		if(tmp!=null&&tmp.length==2){
			rnaDatasetID=tmp[1];
			arrayTypeID=tmp[0];
		}
		log.debug("AFTER IDENTIFIERS:"+myGene+":");
		
		String minCoord="";
		String maxCoord="";
		if(myGene.indexOf(":")>0){
			chromosome=myGene.substring(0,myGene.indexOf(":"));
			if(myGene.indexOf("-")>0){
				minCoord=myGene.substring(myGene.indexOf(":")+1,myGene.indexOf("-")).trim();
				maxCoord=myGene.substring(myGene.indexOf("-")+1).trim();
				min=Integer.parseInt(minCoord);
				max=Integer.parseInt(maxCoord);
			}else{
				regionError="You have entered an invalid region.  Please see the examples in the instructions.";
			}
			if(regionError.equals("")){
				if(min<max){
					if(min<1){
						min=1;
					}
					DecimalFormat df0 = new DecimalFormat("#,###");
					log.debug("Calling GENEDATATOOLS");
					gdt.getRegionGeneView(chromosome,min,max,panel,myOrganism,rnaDatasetID,arrayTypeID);					
					String tmpURL =gdt.getGenURL();//(String)session.getAttribute("genURL");
					String tmpGeneSymbol=gdt.getGeneSymbol();//(String)session.getAttribute("geneSymbol");
					String tmpUcscURL =gdt.getUCSCURL();//(String)session.getAttribute("ucscURL");
					
					if(tmpURL!=null){
						genURL.add(tmpURL);
						if(tmpGeneSymbol==null){
							geneSymbol.add("");
						}else{
							geneSymbol.add(tmpGeneSymbol);
						}
						if(tmpUcscURL==null){
							ucscURL.add("");
						}else{
							ucscURL.add(tmpUcscURL);
						}
					}
				}else{
					regionError="You have entered a SNP.  Please enter a range around the snp such as chr1:50000+5000  or chr1:50000+-2500";
				}
			}
		
		
		
		
	}
	
	
	if(firstEnsemblID!=null && firstEnsemblID.size()>selectedGene){
		selectedEnsemblID=firstEnsemblID.get(selectedGene);
	}
%>


	<%@ include file="regionTranscriptResult.jsp" %>