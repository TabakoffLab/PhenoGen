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

<% 	extrasList.add("normalize.css");
	extrasList.add("index.css");
%>

<%pageTitle="Acknowledgements";
pageDescription="Acknowledgements for providing funding and resources";%>

<%@ include file="/web/common/header.jsp" %>

        <div id="overview-content">
        <div id="welcome" style="height:780px; width:946px; overflow:auto;">

	<h2>Acknowledgements</h2>
	<H3 style="margin:10px;">Funding</H3>
        <p>We would like to thank the National Institue on Alcohol Abuse and Alcoholism (<a href="http://www.niaaa.nih.gov/">NIAAA</a>) for 
            continued funding to develop and support this site.  The Banbury Fund for supporting the development of this site.</p>
    <BR /><BR />
    <H3 style="margin:10px;">Computational Resources</H3>
    <p>We would like acknowledge the UNLV National Supercomputing Institute (<a href="https://www.nscee.edu/">UNLV NSI</a>) for access to 
        supercomputing resources to support analysis of sequencing data.</p>
    <BR><BR>
    <h3 style="margin:10px;">Recombinant Inbred Panels</h3>
    <p>We are grateful to the following investigators for providing the recombinant inbred panels found on the site.</p>
    <p>HXB/BXH Rat RI Panel was provided by <a href="http://pharmacology.ucsd.edu/faculty/printz.html">Morton Printz</a>(UC San Diego).</p>
    <p>ILSXISS Mouse RI Panel was provided by <a href="http://ibgwww.colorado.edu/tj-lab/">Thomas Johnson</a>(CU Boulder) and John DeFries (CU Boulder).</p>
    
<%@ include file="/web/common/footer.jsp" %>
