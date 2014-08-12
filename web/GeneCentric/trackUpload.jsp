<%@ page language="java"
import="org.json.*" %>



<%@ include file="/web/common/anon_session_vars.jsp" %>
<%
	String sessionid="";
	sessionid=session.getId();
	java.util.Date d=new java.util.Date();
	BufferedReader in=request.getReader();
	String content="";
	boolean htmlCreated=false;
	try{
			BufferedWriter output=new BufferedWriter(new FileWriter(applicationRoot+contextRoot+"tmpData/trackUpload/"+sessionid+"_"+d.getTime()+".bed"));
			boolean cont=true;
			while(cont){
				String tmpc=in.readLine();
				if(tmpc!=null && !tmpc.equals("")){
					output.write(tmpc+"\n");
				}else{
					cont=false;
				}		
			}
			output.flush();
			output.close();
			in.close();
	}catch(IOException e){
		log.error("Error reading SVG part",e);
	}
%>
	
<% 
	JSONObject genejson;
	genejson = new JSONObject();
    genejson.put("trackFile" , sessionid+"_"+d.getTime()+".bed");
	response.setContentType("application/json");
	response.getWriter().write(genejson.toString());
%>

