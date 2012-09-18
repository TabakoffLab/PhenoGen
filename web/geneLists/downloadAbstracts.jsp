<%--
 *  Author: Aris Tan
 *  Created: Aug, 2010
 *  Description:  The web page created by this file displays the pubmed abstracts for 
 *  a particular literature search.
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
import="java.util.*"

%>


<jsp:useBean id="myObjectHandler" class="edu.ucdenver.ccp.util.ObjectHandler"/>
<jsp:useBean id="myLitSearch" class="edu.ucdenver.ccp.PhenoGen.data.LitSearch"> </jsp:useBean>
<jsp:useBean id="myPdfUtil" class="edu.ucdenver.ccp.PhenoGen.util.PdfUtil"> </jsp:useBean>


<%

    Results myAbstracts = (Results) session.getAttribute("myAbstracts");

    String litSearchName = (String) request.getParameter("litSearchName");
    String geneListName = (String) request.getParameter("geneListName");
   
    String filename = geneListName + " " + litSearchName;
    response.setContentType("application/pdf");

    response.setHeader("Content-Disposition", "attachment; filename=\""+filename+".pdf\"");

    List<Results> allAbstracts = new ArrayList<Results>();
    allAbstracts.add(myAbstracts);

    myPdfUtil.createReport(request, response, allAbstracts);
    out.clear();
    out = pageContext.pushBody(); 
    
%>


