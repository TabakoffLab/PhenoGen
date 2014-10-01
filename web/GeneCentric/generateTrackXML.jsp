


<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  This file takes the input from an ajax request and returns a json object with genes.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ page language="java"
import="org.json.*" %>

<%@ include file="/web/common/anon_session_vars.jsp"  %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>


<%
    gdt.setSession(session);
String chromosome="",panel="",myOrganism="",track="",folderName="",bedFile="",outputFile="",web="",type="";
int min=0,max=0,rnaDatasetID=0,arrayTypeID=0,binSize=0;
double forwardPValueCutoff=0;
if(request.getParameter("chromosome")!=null){
		chromosome=request.getParameter("chromosome").trim();
}
if(request.getParameter("track")!=null){
		track=request.getParameter("track").trim();
}
if(request.getParameter("folder")!=null){
		folderName=request.getParameter("folder").trim();
}
if(request.getParameter("minCoord")!=null){
	try{
		min=Integer.parseInt(request.getParameter("minCoord").trim());
	}catch(NumberFormatException e){
		log.error("Number format exception:Min\n",e);
	}
}
if(request.getParameter("maxCoord")!=null){
	try{
		max=Integer.parseInt(request.getParameter("maxCoord").trim());
	}catch(NumberFormatException e){
		log.error("Number format exception:Max\n",e);
	}
}
if(request.getParameter("panel")!=null){
		panel=request.getParameter("panel").trim();
}
if(request.getParameter("rnaDatasetID")!=null){
	try{
		rnaDatasetID=Integer.parseInt(request.getParameter("rnaDatasetID").trim());
	}catch(NumberFormatException e){
		log.error("Number format exception:rnaDatasetID\n",e);
	}
}
if(request.getParameter("arrayTypeID")!=null){
	try{
		arrayTypeID=Integer.parseInt(request.getParameter("arrayTypeID").trim());
	}catch(NumberFormatException e){
		log.error("Number format exception:arrayTypeID\n",e);
	}
}
if(request.getParameter("binSize")!=null){
	try{
		binSize=Integer.parseInt(request.getParameter("binSize").trim());
	}catch(NumberFormatException e){
		log.error("Number format exception:binSize\n",e);
	}
}
if(request.getParameter("myOrganism")!=null){
		myOrganism=request.getParameter("myOrganism").trim();
}else{
	if(!panel.equals("")){
		if(panel.equals("BNLX/SHRH")){
			myOrganism="Rn";
		}else if(panel.equals("ILS/ISS")){
			myOrganism="Mm";
		}
	}else if(arrayTypeID==21){
		myOrganism="Mm";
	}else if(arrayTypeID==22){
		myOrganism="Rn";
	}
}

if(request.getParameter("bedFile")!=null){
		bedFile=request.getParameter("bedFile").trim();
}
if(request.getParameter("outFile")!=null){
		outputFile=request.getParameter("outFile").trim();
}
if(request.getParameter("web")!=null){
	web=request.getParameter("web");
}
if(request.getParameter("type")!=null){
	type=request.getParameter("type");
}

%>


<% 
	String status="";
	if(!track.startsWith("custom")&&bedFile.equals("") && outputFile.equals("") ){
		status=gdt.generateXMLTrack(chromosome,min,max,panel,track,myOrganism,rnaDatasetID,arrayTypeID,folderName,binSize);
	}else if(track.startsWith("custom")){
		log.debug("Generating custom xml track");
		if(web.startsWith("http")){
			if(type.equals("bb")||type.equals("bw")){
				status=gdt.generateCustomRemoteXMLTrack(chromosome,min,max,track,myOrganism,folderName,bedFile,outputFile,type,web,binSize);
			}
		}else{
			if(type.equals("bed")){
				File tmp=new File(applicationRoot+contextRoot+outputFile);
				if(tmp.exists()){
					tmp.delete();
				}
				status=gdt.generateCustomBedXMLTrack(chromosome,min,max,track,myOrganism,folderName,bedFile,outputFile);
			}else if(type.equals("bg")){
				File tmp=new File(applicationRoot+contextRoot+outputFile);
				if(tmp.exists()){
					tmp.delete();
				}
				status=gdt.generateCustomBedGraphXMLTrack(chromosome,min,max,track,myOrganism,folderName,bedFile,outputFile,binSize);
			}
		}
	}
	JSONObject genejson;
	genejson = new JSONObject();
    genejson.put("status" , status);
	response.setContentType("application/json");
	response.getWriter().write(genejson.toString());
%>





