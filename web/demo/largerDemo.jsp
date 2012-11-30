
<%@ include file="/web/access/include/login_vars.jsp" %>



<%@ include file="/web/common/header_noMenu.jsp" %>

<%
	String mainFilePart="web/demo/detailed_transcript_fullv3";
	if(request.getParameter("demoPath")!=null){
		mainFilePart=request.getParameter("demoPath");
	}
%>

<div style="text-align:center;">
	
    <video width="800" height="650" controls="controls">
                    		<source src="<%=contextRoot%><%=mainFilePart%>.mp4" type="video/mp4">
                            <source src="<%=contextRoot%><%=mainFilePart%>.webm" type="video/webm">
                          <object data="<%=contextRoot%><%=mainFilePart%>.mp4" width="800" height="650">
                          </object>
                        </video>
    
</div>
    

<%@ include file="/web/common/basicFooter.jsp" %>

 
