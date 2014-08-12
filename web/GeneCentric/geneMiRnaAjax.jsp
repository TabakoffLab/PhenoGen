<%@ include file="/web/common/anon_session_vars.jsp" %>


<jsp:useBean id="miRT" class="edu.ucdenver.ccp.PhenoGen.tools.mir.MiRTools" scope="session"> </jsp:useBean>

<%

	String myOrganism="";
	String id="";
	String table="all";
	String predType="p";
	int cutoff=20;
	
	miRT.setup(pool,session);
	
	ArrayList<MiRResult> mirList=new ArrayList<MiRResult>();
	
	if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species").trim();
	}
	
	if(request.getParameter("id")!=null){
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
	
    %>
<BR />

<%@ include file="/web/GeneCentric/geneMiRnaPart.jsp" %>

<script type="text/javascript">
	runMultiMir();
</script>


