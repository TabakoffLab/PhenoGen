<%@ page language="java"
import="org.json.*" %>



<%@ include file="/web/common/anon_session_vars.jsp" %>
<jsp:useBean id="bt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserTools" scope="session"> </jsp:useBean>
<%
	String sessionid="";
	sessionid=session.getId();
	
	//Parameters
	String trackName="";
	String trackDesc="";
	String trackOrg="";
	String genericCat="";
	String category="";
	String controls="";
	
	
	
	String extension=".bed";
	if(request.getParameter("trackName")!=null){
		trackName=request.getParameter("trackName");
	}
	if(request.getParameter("trackDesc")!=null){
		trackDesc=request.getParameter("trackDesc");
	}
	if(request.getParameter("trackOrg")!=null){
		trackOrg=request.getParameter("trackOrg");
	}
	if(request.getParameter("genericCat")!=null){
		genericCat=request.getParameter("genericCat");
	}
	if(request.getParameter("category")!=null){
		category=request.getParameter("category");
	}
	if(request.getParameter("controls")!=null){
		controls=request.getParameter("controls");
	}

%>
	
<% 
	int tmpuserID=0;
	bt.setSession(session);
	//If user is logged in other than anonymous save track to DB and return file to save to cookie.
	if(loggedIn && !userLoggedIn.getUser_name().equals("anon")){
		tmpuserID=userLoggedIn.getUser_id();
		bt.createCustomTrack(tmpuserID,sessionid+"_"+d.getTime(),trackName,trackDesc,trackOrg,"",0,genericCat,category,controls,true,fileName);
	}
	//else will just return path to save to cookie.
	JSONObject genejson;
	genejson = new JSONObject();
    genejson.put("trackFile" , sessionid+"_"+d.getTime()+".bed");
	response.setContentType("application/json");
	response.getWriter().write(genejson.toString());
%>

