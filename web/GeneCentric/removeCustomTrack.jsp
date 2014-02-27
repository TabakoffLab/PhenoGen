<%@ page language="java"
import="org.json.*" %>



<%@ include file="/web/common/session_vars.jsp" %>
<%
	String status="Failure";
	
	String id="";
	if(request.getParameter("id")!=null){
		id=request.getParameter("id").trim();
		//try{
		log.debug("delete id:"+id+".bed");
		if(id.startsWith("custom")){
			id=id.substring(6);
		}
			String file=applicationRoot+contextRoot+"tmpData/trackUpload/"+id+".bed";
			String mvFile=applicationRoot+contextRoot+"tmpData/toDelete/"+id+".bed";
			File tmp=new File(file);
			File dest=new File(mvFile);
			tmp.renameTo(dest);
			status="Success";
		/*}catch(IOException e){
			log.error("Error removing custom track file",e);
			status=status+": An error occurred removing the file.";
		}*/
	}
	
%>
	
<% 
	JSONObject genejson;
	genejson = new JSONObject();
    genejson.put("result" , status);
	response.setContentType("application/json");
	response.getWriter().write(genejson.toString());
%>

