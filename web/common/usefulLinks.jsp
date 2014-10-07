<%--
 *  Author: Cheryl Hornbaker
 *  Created: May, 2006
 *  Description:  The web page created by this file displays links to other websites
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/access/include/login_vars.jsp" %>
<%	
	extrasList.add("normalize.css");
     extrasList.add("index.css");
	//mySessionHandler.createSessionActivity(session.getId(), "Looked at useful links page", dbConn);

%>

<%pageTitle="Useful Links";
pageDescription="Links to related resources";%>

<%@ include file="/web/common/header.jsp" %>


        <div id="overview-content">
        <div id="welcome" style="height:650px; width:946px;">

	<h2>Gene Expression databases:</h2>
	<ul>
	<li><a href="http://www.ncbi.nlm.nih.gov/geo/" target="_blank">Gene Expression Omnibus (GEO) </a>

	<li><a href="http://www.genenetwork.org/" target="_blank">The GeneNetwork </a>

	<!--<li><a href="http://www.longhornarraydatabase.org/index.html" target="_blank">The Longhorn Array Database </a>-->
	<li><a href="http://www.geneimprint.com/index.html" target="_blank">The Genomic Imprinting </a>
	<li><a href="http://www.ebi.ac.uk/arrayexpress/" target="_blank">ArrayExpress </a>

	<li><a href="http://www.brainatlas.org/" target="_blank">The Allen Brain Atlas </a> -- (<a href="http://www.brain-map.org/downloadExplorer.do" target="_blank">Install Brain Explorer) </a>
	<li><a href="http://www.bnl.gov/CTN/mouse.asp" target="_blank">Adult C57BL/6J Mouse Brain 3-D Digital Atlas </a>
	</ul>
	<BR>

	<h2>Annotation databases:</h2>
	<ul>

	<li><a href="http://www.informatics.jax.org/" target="_blank">Mouse Genome Informatics </a>
	<li><a href="http://phenome.jax.org/pub-cgi/phenome/mpdcgi?rtn=docs/home" target="_blank">Mouse Phenome Database </a>
	<li><a href="http://www.ncbi.nlm.nih.gov/mapview/" target="_blank">NCBI Map Viewer </a>
	<li><a href="http://rgd.mcw.edu/" target="_blank">The Rat Genome Database </a>
	</ul>
	<BR>

	<h2>Additional tools for microarray data analysis:</h2>
	<ul>
	<li><a href="http://www.bioconductor.org/" target="_blank">The BioConductor </a>
	<li><a href="http://www-genome.stanford.edu/" target="_blank">Stanford Genomic Resourses </a>
	<li><a href="http://www.geneontology.org/" target="_blank">The Gene Ontology </a>
	<li><a href="http://www.r-project.org/" target="_blank">The R Project </a>
	<li><a href="http://david.niaid.nih.gov/david/version2/index.htm" target="_blank">DAVID </a>
	<li><a href="http://string.embl.de/newstring_cgi/show_input_page.pl?UserId=6RCsQYqeKbvh&amp;sessionId=AsoHkPxfjf01" target="_blank">String </a>
	<li><a href="http://genome-www5.stanford.edu/cgi-bin/source/sourceSearch" target="_blank">SOURCE </a>
	<li><a href="http://www.chilibot.net/" target="_blank">Chilibot </a>
	<li><a href="http://www.mged.org/" target="_blank">The Microarray Gene Expression Data (MGED) Society </a>
	<li><a href="http://www.tm4.org/mev.html" target="_blank">TIGR TM4 Microarray Software Suite</a>
	<li><a href="http://linus.nci.nih.gov/BRB-ArrayTools.html" target="_blank">BRB ArrayTools</a>
	<!--<li><a href="http://ihome.cuhk.edu.hk/~b400559/arraysoft_rpackages.html" target="_blank">A summary of microarray analysis packages in the R language</a>-->

	</ul>


<%@ include file="/web/common/footer.jsp" %>
