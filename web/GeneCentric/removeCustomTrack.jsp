<%@ page language="java"
import="org.json.*" %>



<%@ include file="/web/common/anon_session_vars.jsp" %>
<%
	String status="Failure";
	
	String id="";
	if(request.getParameter("id")!=null){
		id=request.getParameter("id").trim();
		log.debug("delete id:"+id);
		if(id.startsWith("custom")){
			id=id.substring(6);
		}
		String file=applicationRoot+contextRoot+"tmpData/trackUpload/"+id;
		String mvFile=applicationRoot+contextRoot+"tmpData/toDelete/"+id;
		File tmp=new File(file);
		File dest=new File(mvFile);
		tmp.renameTo(dest);
		status="Success";
	}
	
%>
	
<% 
	JSONObject genejson;
	genejson = new JSONObject();
    genejson.put("result" , status);
	response.setContentType("application/json");
	response.getWriter().write(genejson.toString());
%>

