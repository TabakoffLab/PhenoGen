	<%@ include file="headTags.jsp" %>
	
	<body class="noPrint">
    	<div id="wait1"  style="background:#FFFFFF;position:absolute; top:175px;height:200px;"><img src="<%=imagesDir%>wait.gif" alt="Working..." /><BR />Working...It may take  1-2 minutes the first time you run a summary for a gene or region.</div>
		<div id="page_header">
    		<div id="header_title"><a href="<%=request.getContextPath()%>">PhenoGen Informatics</a></div>
	  	</div> <!-- page_header -->
		
		<div id="body_wrapper_plain">
		<div id="main_body_plain" >
       

	<%@ include file="/web/common/alertMsgDisplay.jsp"  %>
	<%@ include file="/web/common/toolbarStuff.jsp" %>

