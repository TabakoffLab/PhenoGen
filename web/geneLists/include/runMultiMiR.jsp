<%@ include file="/web/common/session_vars.jsp" %>
<jsp:useBean id="miRT" class="edu.ucdenver.ccp.PhenoGen.tools.mir.MiRTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"/>
<jsp:useBean id="myGeneListAnalysis" class="edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis"/>
<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue"> </jsp:useBean>
<%

	String myOrganism="";
	String fullOrg="";
	String id="";
	String table="all";
	String predType="p";
	String disease="";
	String result="";
	String name="";
	int cutoff=20;
	
	miRT.setup(pool,session);
	
	
	if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species").trim();
		if(myOrganism.equals("Mm")){
			fullOrg="Mus_musculus";
		}else if(myOrganism.equals("Rn")){
			fullOrg="Rattus_norvegicus";
		}
	}
	
	if(request.getParameter("geneListID")!=null){
		id=request.getParameter("geneListID");
	}
	
	if(request.getParameter("table")!=null){
		table=request.getParameter("table");
	}
	
	if(request.getParameter("predType")!=null){
		predType=request.getParameter("predType");
	}
	if(request.getParameter("cutoff")!=null){
		cutoff=Integer.parseInt(request.getParameter("cutoff"));
	}
	if(request.getParameter("disease")!=null){
		disease=request.getParameter("disease");
	}else{
		disease="";
	}
	if(request.getParameter("name")!=null){
		name=request.getParameter("name");
	}
	
	String now = myObjectHandler.getNowAsMMddyyyy_HHmmss();
	java.sql.Timestamp timeNow = myObjectHandler.getNowAsTimestamp();
	
	int parameter_group_id = myParameterValue.createParameterGroup(dbConn);
		
	myGeneListAnalysis.setGene_list_id(selectedGeneList.getGene_list_id());
	myGeneListAnalysis.setUser_id(userID);
	myGeneListAnalysis.setCreate_date(timeNow);
	myGeneListAnalysis.setAnalysis_type("multiMiR");
	myGeneListAnalysis.setDescription("Search Tables: "+table+"\n Cutoff:"+predType+cutoff+"\n disease:"+disease);
	myGeneListAnalysis.setAnalysisGeneList(selectedGeneList);
	myGeneListAnalysis.setVisible(1);
	myGeneListAnalysis.setStatus("Running");
	myGeneListAnalysis.setName(name);
	myGeneListAnalysis.setParameter_group_id(parameter_group_id);
		
	ParameterValue[] myParameterValues = new ParameterValue[4];
	for (int i=0; i<myParameterValues.length; i++) {
		myParameterValues[i] = new ParameterValue();
		myParameterValues[i].setCreate_date();
		myParameterValues[i].setParameter_group_id(parameter_group_id);
		myParameterValues[i].setCategory("multiMiR");
	}
	myParameterValues[0].setParameter("Table");
	myParameterValues[0].setValue(table);
	myParameterValues[1].setParameter("Prediction Cutoff Type");
	myParameterValues[1].setValue(predType);
	myParameterValues[2].setParameter("Cutoff");
	myParameterValues[2].setValue(Integer.toString(cutoff));
	myParameterValues[3].setParameter("Disease");
	if(disease.equals("")){
		myParameterValues[3].setValue("None");
	}else{
		myParameterValues[3].setValue(disease);
	}
	
	myGeneListAnalysis.setParameterValues(myParameterValues);
	int glaID=myGeneListAnalysis.createGeneListAnalysis(pool);
	
	mySessionHandler.createGeneListActivity("Ran multiMiR on Gene List", pool);
	
	
	
	result=miRT.runMultiMiRGeneList(selectedGeneList,myOrganism,table,predType,cutoff,name,glaID);
%>


<%=result%>