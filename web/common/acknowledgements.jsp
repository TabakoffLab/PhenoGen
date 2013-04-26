<%--
 *  Author: Spencer Mahaffey
 *  Created: April, 2013
 *  Description:  The web page created by this file displays acknowledgements for the site and data.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<% extrasList.add("index.css"); %>

<%pageTitle="Acknowledgements";%>

<%@ include file="/web/common/header.jsp" %>

        <div id="overview-content">
        <div id="welcome" style="height:780px; width:946px; overflow:auto;">

	<h2>Acknowledgements</h2>
	<H3>Funding</H3>
    We would like to thank the National Institue on Alcohol Abuse and Alcoholism (<a href="http://www.niaaa.nih.gov/">NIAAA</a>) for continued funding to develop and support this site.  The Banbury Fund for supporting the development of this site.
    <BR /><BR />
    <h3>Recombinant Inbred Panels</h3>
    We are grateful to the following investigators for providing the recombinant inbred panels found on the site.<BR />
    HXB/BXH Rat RI Panel was provided by <a href="http://pharmacology.ucsd.edu/faculty/printz.html">Morton Prinz</a>(UC San Diego).<BR />
	ILSXISS Mouse RI Panel was provided by <a href="http://ibgwww.colorado.edu/tj-lab/">Thomas Johnson</a>(CU Boulder) and <a href="http://profiles.ucdenver.edu/ProfileDetails.aspx?From=SE&Person=568">John DeFries</a>(CU Boulder).<BR />
    
<%@ include file="/web/common/footer.jsp" %>
