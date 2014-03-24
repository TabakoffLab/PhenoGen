	<%@ include file="adaptive_headTags.jsp" %>
    
	<body>
       	<div id="wait1"  style="background:#FFFFFF;position:absolute; top:175px;height:50px;"><img src="<%=imagesDir%>wait.gif" alt="Working..." /><BR />Working...It may take  1-3 minutes the first time you run a summary for a gene or region depending on the size of the gene/region.</div>
		
       
		<div id="page_header_wide">
    		<div id="header_title">
            	<a href="<%=request.getContextPath()%>">PhenoGen Informatics</a>
            	<div style=" font-size:12px;">The site for quantitative genetics of the transcriptome.</div>
            </div>
	  	</div> <!-- page_header -->
		
		<div id="body_wrapper_plain">
       

	<%@ include file="/web/common/alertMsgDisplay.jsp"  %>
	<%@ include file="/web/common/toolbarStuff.jsp" %>

