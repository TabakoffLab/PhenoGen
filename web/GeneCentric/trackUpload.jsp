<%@ page language="java"
import="org.json.*" %>



<%@ include file="/web/common/anon_session_vars.jsp" %>
<%
	String sessionid="";
	sessionid=session.getId();
	java.util.Date d=new java.util.Date();
	String content="";
	boolean htmlCreated=false;
	BufferedReader in=request.getReader();
	String fileName=applicationRoot+contextRoot+"tmpData/trackUpload/"+sessionid+"_"+d.getTime();
	File test=new File(fileName);
	int counter=0;
	String tmpfileName=fileName;
	while(test.exists()){
		fileName=tmpfileName+"_"+counter;
		test=new File(fileName);
		counter++;
	}
	try{
			BufferedWriter output=new BufferedWriter(new FileWriter(fileName));
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
    genejson.put("trackFile" , sessionid+"_"+d.getTime());
	response.setContentType("application/json");
	response.getWriter().write(genejson.toString());
%>

