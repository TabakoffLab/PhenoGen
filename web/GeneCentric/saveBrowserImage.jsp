<%@ page language="java"
import="org.json.*" %>



<%@ include file="/web/common/session_vars.jsp" %>
<%
	String sessionid="";
	sessionid=session.getId();
	java.util.Date d=new java.util.Date();
	BufferedReader in=request.getReader();
	String content="";
	String htmlHead="<HTML><head><script type=\"text/javascript\" src=\""+applicationRoot+contextRoot+"javascript/d3.v3.min.js\"></script></head><BODY style=\"background:#FFFFFF;margin:0px;\"><style>ul{list-style-type:none;padding:0px;} .axis path{fill:none;stroke:black;shape-rendering: crispEdges;} .tick{fill:black;stroke: black;} .grid .tick { stroke: lightgrey; opacity: 0.7;}</style><div style=\"font-family: Arial,Verdana,sans-serif;font-size: 14px;\">";
	String htmlEnd="</div><script>d3.selectAll(\".infoIcon\").remove();d3.selectAll(\".settings\").remove();d3.selectAll(\".scroll\").style(\"overflow\",\"\").style(\"max-height\",\"\");</script></BODY></HTML>";
	
	boolean htmlCreated=false;
	try{
			String tmpc=in.readLine();
			//log.debug("Save SVG char"+count+":"+tmpc);
			content=content+tmpc;
			in.close();
			String html=htmlHead+content+htmlEnd;
			FileHandler myFH=new FileHandler();
			myFH.writeFile(html, applicationRoot+contextRoot+"tmpData/download/"+sessionid+"_"+d.getTime()+".html");
			htmlCreated=true;
	}catch(IOException e){
		log.error("Error reading SVG part",e);
	}
	if(htmlCreated){
		String functionPath=applicationRoot+contextRoot+"tmpData/download/";
		String[] functionArgs=new String[4];
		functionArgs[0]=applicationRoot+contextRoot+"tmpData/download/phantomjs";
		functionArgs[1]="outputDoc.js";
		functionArgs[2]=applicationRoot+contextRoot+"tmpData/download/"+sessionid+"_"+d.getTime()+".html";
		functionArgs[3]=applicationRoot+contextRoot+"tmpData/download/"+sessionid+"_"+d.getTime()+".png";
		String[] envVar=new String[0];
		ExecHandler eh=new ExecHandler(functionPath,functionArgs,envVar,applicationRoot+contextRoot+"tmpData/download/phantom_"+sessionid);
		eh.runExec();
	}
%>
	
<% 
	JSONObject genejson;
	genejson = new JSONObject();
    genejson.put("imageFile" , sessionid+"_"+d.getTime()+".png");
	response.setContentType("application/json");
	response.getWriter().write(genejson.toString());
%>

