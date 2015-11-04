<%@ page language="java"
import="org.json.*" %>



<%@ include file="/web/common/anon_session_vars.jsp" %>
<jsp:useBean id="bt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.BrowserTools" scope="session"> </jsp:useBean>
<%
	String sessionid="";
	sessionid=session.getId();
	
	//Parameters
	String trackClass="";
	String trackName="";
	String trackDesc="";
	String trackOrg="";
	String genericCat="";
	String category="";
	String controls="";
	String location="";
	String type="";
	String prevFile="";
	//User userLoggedIn=(User) session.getAttribute("userLoggedIn");
	int uid=userLoggedIn.getUser_id();
	
	
	String extension=".bed";
	if(request.getParameter("trackClass")!=null){
		trackClass=FilterInput.getFilteredInput(request.getParameter("trackClass"));
	}
	if(request.getParameter("trackName")!=null){
		trackName=FilterInput.getFilteredInput(request.getParameter("trackName"));
	}
	if(request.getParameter("trackDesc")!=null){
		trackDesc=FilterInput.getFilteredInput(request.getParameter("trackDesc"));
	}
	if(request.getParameter("trackOrg")!=null){
		trackOrg=FilterInput.getFilteredInput(request.getParameter("trackOrg"));
	}
	if(request.getParameter("genericCategory")!=null){
		genericCat=FilterInput.getFilteredInput(request.getParameter("genericCategory"));
	}
	if(request.getParameter("category")!=null){
		category=FilterInput.getFilteredInput(request.getParameter("category"));
	}
	if(request.getParameter("controls")!=null){
		controls=request.getParameter("controls");
	}
	if(request.getParameter("location")!=null){
		location=request.getParameter("location");
	}
	if(request.getParameter("type")!=null){
		type=FilterInput.getFilteredInput(request.getParameter("type"));
	}
	if(request.getParameter("file")!=null){
		prevFile=request.getParameter("file");
	}
%>
	
<% 
	int tmpuserID=0;
	bt.setSession(session);

	boolean success=bt.createCustomTrack(uid,trackClass,trackName,trackDesc,trackOrg,"",0,genericCat,category,controls,true,location,prevFile,type);
	//else will just return path to save to cookie.
	JSONObject genejson;
	genejson = new JSONObject();
    genejson.put("success" , Boolean.toString(success));
	response.setContentType("application/json");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setDateHeader("Expires", 0);
	response.getWriter().write(genejson.toString());
%>


