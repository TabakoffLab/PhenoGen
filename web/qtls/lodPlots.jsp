<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2007
 *  Description:  The web page created by this file displays the LOD Plot images for a particular probe id 
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/qtls/include/qtlHeader.jsp"  %>

<%
	log.info("in lodPlots.jsp. user =  "+ user);
	
	String probeID = (String) request.getParameter("probeID");

        String imagesPath = "/LODPlots/";
	log.debug("imagesPath = "+imagesPath);

        String imageFileName = "Probe." +  probeID + ".jpg";

	mySessionHandler.createGeneListActivity("Viewed LODPlot for probeID '" + probeID +  "'", dbConn);
%>

<%@ include file="/web/common/externalWindowHeader.jsp" %>

<div class="scrollable">
<img src="<%=imagesPath%><%=imageFileName%>" alt="<%=imageFileName%>">
</div>

<%@ include file="/web/common/externalWindowFooter.html" %>
