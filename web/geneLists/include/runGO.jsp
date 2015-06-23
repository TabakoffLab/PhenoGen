<%@ include file="/web/common/session_vars.jsp" %>
<jsp:useBean id="goT" class="edu.ucdenver.ccp.PhenoGen.tools.go.GOTools" scope="session"> </jsp:useBean>
<jsp:useBean id="myGeneList" class="edu.ucdenver.ccp.PhenoGen.data.GeneList"/>
<jsp:useBean id="myGeneListAnalysis" class="edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis"/>
<jsp:useBean id="myParameterValue" class="edu.ucdenver.ccp.PhenoGen.data.ParameterValue"> </jsp:useBean>
<%

	String myOrganism="";
	String fullOrg="";
	String id="";
	String result="";
	String name="";
	
	goT.setup(pool,session);
	
	
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
	if(request.getParameter("name")!=null){
		name=request.getParameter("name");
	}
	
	String now = myObjectHandler.getNowAsMMddyyyy_HHmmss();
	java.sql.Timestamp timeNow = myObjectHandler.getNowAsTimestamp();
	
	int parameter_group_id = myParameterValue.createParameterGroup(dbConn);
		
	myGeneListAnalysis.setGene_list_id(selectedGeneList.getGene_list_id());
	myGeneListAnalysis.setUser_id(userID);
	myGeneListAnalysis.setCreate_date(timeNow);
	myGeneListAnalysis.setAnalysis_type("GO");
	myGeneListAnalysis.setDescription(name);
	myGeneListAnalysis.setAnalysisGeneList(selectedGeneList);
	myGeneListAnalysis.setVisible(1);
	myGeneListAnalysis.setStatus("Running");
	myGeneListAnalysis.setName(name);
	myGeneListAnalysis.setParameter_group_id(parameter_group_id);
		
	ParameterValue[] myParameterValues = new ParameterValue[1];
	for (int i=0; i<myParameterValues.length; i++) {
		myParameterValues[i] = new ParameterValue();
		myParameterValues[i].setCreate_date();
		myParameterValues[i].setParameter_group_id(parameter_group_id);
		myParameterValues[i].setCategory("GO");
	}
	myParameterValues[0].setParameter("Name");
	myParameterValues[0].setValue(name);
	myGeneListAnalysis.setParameterValues(myParameterValues);
	int glaID=myGeneListAnalysis.createGeneListAnalysis(pool);
	
	mySessionHandler.createGeneListActivity("Ran GO on Gene List", pool);
	
	
	
	result=goT.runGOGeneList(selectedGeneList,myOrganism,name,glaID);
%>


<%=result%>