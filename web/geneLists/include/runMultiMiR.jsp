<%@ include file="/web/common/session_vars.jsp" %>
<jsp:useBean id="miRT" class="edu.ucdenver.ccp.PhenoGen.tools.mir.MiRTools" scope="session"> </jsp:useBean>

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
		id=request.getParameter("id");
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
	}
	if(request.getParameter("name")!=null){
		name=request.getParameter("name");
	}
	result=miRT.runMultiMiRGeneList(selectedGeneList,myOrganism,table,predType,cutoff,name);
%>


<%=result%>