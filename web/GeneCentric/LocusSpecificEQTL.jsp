
<%@ include file="/web/common/anon_session_vars.jsp" %>

<%
	extrasList.add("fancyBox/jquery.fancybox.js");
	extrasList.add("jquery.fancybox.css");
	extrasList.add("jquery.twosidedmultiselect.js");
	extrasList.add("tsmsselect.css");	
	ArrayList<String> geneSymbol=new ArrayList<String>();
	int selectedGene=0;
	String gcPath="";
%>


<%@ include file="/web/common/header_noMenu.jsp" %>
<%@ include file="/web/GeneCentric/lsEQTLPart.jsp" %>
<%@ include file="/web/common/basicFooter.jsp" %>

 
