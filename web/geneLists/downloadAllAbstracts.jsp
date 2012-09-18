<%--
 *  Author: Aris Tan
 *  Created: Aug, 2010
 *  Description:  The web page created by this file displays all the pubmed abstracts for 
 *  a particular literature search in PDF.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ page language="java" 
import="com.itextpdf.text.pdf.*"
import="com.itextpdf.text.Document"
import="com.itextpdf.text.Paragraph"
import="com.itextpdf.text.Chunk"
import="com.itextpdf.text.Font"
import="com.itextpdf.text.BaseColor"
import="com.itextpdf.text.Paragraph"
import="com.itextpdf.text.Font.FontFamily"

import="edu.ucdenver.ccp.util.sql.Results"


import="java.util.Date"
import="java.util.List"
import="java.util.ArrayList"
%>


<jsp:useBean id="myObjectHandler" class="edu.ucdenver.ccp.util.ObjectHandler"/>
<jsp:useBean id="myLitSearch" class="edu.ucdenver.ccp.PhenoGen.data.LitSearch"> </jsp:useBean>
<jsp:useBean id="myPdfUtil" class="edu.ucdenver.ccp.PhenoGen.util.PdfUtil"> </jsp:useBean>

	<%
		
	java.sql.Connection dbConn = (java.sql.Connection)session.getAttribute("dbConn");

	Object previousClobKey = null;
	Object[] dataRowWithClob = null;;
	
	java.sql.Connection mdlnConn = (java.sql.Connection)session.getAttribute("mdlnConn");

    String oracleSID = (String) session.getAttribute("oracleSID");
	String oracleUser = (String) session.getAttribute("oracleUser");
	String databaseLink = oracleUser + "_" + oracleSID + "_link";
	
	
	String itemIDString =  request.getParameter("itemID");
	int itemID = Integer.parseInt(itemIDString);
	
	String corefIDString =  request.getParameter("corefID")==""?"-99":request.getParameter("corefID");
	int corefID = Integer.parseInt(corefIDString);
	
	
	String litSearchName = (String) request.getParameter("litSearchName");
    String geneListName = (String) request.getParameter("geneListName");
    String createDate = (String) request.getParameter("createDate");
	
	
	List<Results> allAbstracts = new ArrayList<Results>();
	
	Results myAbstracts = myLitSearch.getAbstracts(itemID, "", "", databaseLink, mdlnConn);
	allAbstracts.add(myAbstracts);
	 
	if (corefIDString != "-99") {
	    Results myCoRefAbstracts = myLitSearch.getCoRefAbstracts(Integer.parseInt(corefIDString), databaseLink, mdlnConn);
		allAbstracts.add(myCoRefAbstracts);
	}

	
    %>



<%

Document document = new Document();
String filename = geneListName + " " + litSearchName;
response.setContentType("application/pdf");
response.setHeader("Content-Disposition", "attachment; filename=\""+filename+".pdf\"");

myPdfUtil.createReport(request, response, allAbstracts);

out.clear();
out = pageContext.pushBody();
%>



