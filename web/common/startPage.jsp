<%@ include file="/web/common/session_vars.jsp" %>

<%	extrasList.add("normalize.css");
	extrasList.add("index.css");
	request.setAttribute( "selectedMain", "home" );
	//log.debug("full_name = XXX"+full_name+"XXX");
	mySessionHandler.createSessionActivity(session.getId(), "On Start Page", dbConn);
%>


<%@ include file="/web/common/header.jsp" %>

<style>
    #main_body{height: 775px;}
</style>
    <div id="primary-content">
        <div id="welcome">
            <h2>Welcome, <strong><%=full_name%></strong></h2>
               <% if (userLoggedIn != null && userLoggedIn.getUser_name().equals("guest")) { %>
                        <p>You are logged into the website's guest account.  This account contains four public datasets, gene lists, and
                        gene list interpretation results.  Feel free to browse the contents.  <BR>
                        NOTE:  You will not be able to create any new datasets or gene lists without creating a registered user first.
<p>
                        <BR>
                <% } else { %>
			<!--
                        <p>The following has changed since you last logged in:<BR>
                        <a href="">1</a> new message(s)<BR>
			<a class="popup" href="">What's New</a>
                        </p>
			-->
                <% } %>

	<div id="what-to-do">
		<h2>What Would You Like To Do?</h2>
		<div>
			<!-- <p><a href="<%=geneListsDir%>chooseGeneList.jsp?geneListID=1191">Return to what I was doing</a> </p>  -->
			<!-- <p><a href="<%=qtlsDir%>calculateQTLs.jsp?datasetID=376">Return to what I was doing</a> </p> -->
			<p><a href="<%=experimentsDir%>listExperiments.jsp">Put my arrays onto this web site</a></p>
			<p><a href="<%=datasetsDir%>listDatasets.jsp">Begin a microarray analysis</a></p>
			<p><a href="<%=geneListsDir%>createGeneList.jsp?fromMain=Y">Create a list of genes</a></p>
			<p><a href="<%=geneListsDir%>listGeneLists.jsp">Research a list of candidate genes</a></p>
			<p><a href="<%=qtlsDir%>qtlMain.jsp">Find the genes in my list that have eQTL</a></p>
            <p><a href="<%=exonDir%>exonMain.jsp">Explore expression relationships among exons in a gene</a></p>
            <p><a href="<%=sysBioDir%>resources.jsp">Download raw/normalized expression data</a></p>
            
		</div>
		<div class="brClear"></div>
		<BR>
        	<% if (session.getAttribute("isPrincipalInvestigator") != null && 
			((String) session.getAttribute("isPrincipalInvestigator")).equals("Y")) { %>
			<h2>As a Principal Investigator, you may also:</h2>
			<div>
				<p><a href="<%=experimentsDir%>approveRequests.jsp">Approve array requests</a></p>
				<!-- <p><a href="<%=experimentsDir%>grantArrayAccess.jsp">Grant array access to an individual</a></p>-->
				<p><a href="<%=experimentsDir%>publishExperiment.jsp">Grant array access</a></p>
				<!-- <p><a href="<%=experimentsDir%>createMAGEML.jsp">Create a MAGE-ML file for uploading to Array Express</a></p>
				<p><a href="<%=experimentsDir%>sendMAGEML.jsp">Upload an experiment to Array Express</a></p> -->
			</div>
        		<% } %>
        </div> <!-- // end what-to-do -->
    
    <div id="whats-new" class="whats-new">
		<h2>What's New</h2>
		<!--<div id="secondary-content">
			<p style="text-align:center">Version: v2.6<BR /> Updated:5/22/2012</p>

				<ul>
				<li> 
					<span class="highlight-dark">Exon level analysis tools:</span>Analyze probeset-level data for the public exon arrays.<BR />
				<li>
					<span class="highlight-dark">Exon-exon correlation heatmaps:</span> Perform exon-exon correlation within a gene:  	
                    <ol type="a">
                    <li> Select a gene (from a gene list or enter your own). and 
                    <li> Select an exon dataset (from Rats or Mice).
                    <li> Select Brain(Mouse or Rat), Heart(Rat), Liver(Rat), or Brown Adipose tissues(Rat). 
                    <li> View any Ensembl transcript for the gene, or compare two 
                    transcripts side by side.
                    </ol>
				
				<li> 
					<span class="highlight-dark">Download RNA-sequencing:</span>SAM files from three replicates of polyA+ 
                    RNA from whole brain of two rat strains and three replicates of total RNA from whole
                    brain of the same two rat strains can now be downloaded in the Download Resources tab.<BR />
                <li> 
					<span class="highlight-dark">Data storage format:</span>A new system for storing data in the database and HDF5 files speeds up normalization, filtering, and statistics.  This is currently implemented 
                    to support analysis on Affymetrix Exon arrays, but future updates will implement the new storage methods for the 
                    remaining array types.
				</ul>
		</div>-->
        <%@ include file="/web/common/whats_new_content.jsp"%>
		<div class="brClear"></div>
		<BR>
        	<% if (session.getAttribute("isPrincipalInvestigator") != null && 
			((String) session.getAttribute("isPrincipalInvestigator")).equals("Y")) { %>
			<h2>As a Principal Investigator, you may also:</h2>
			<div>
				<p><a href="<%=experimentsDir%>approveRequests.jsp">Approve array requests</a></p>
				<!-- <p><a href="<%=experimentsDir%>grantArrayAccess.jsp">Grant array access to an individual</a></p>-->
				<p><a href="<%=experimentsDir%>publishExperiment.jsp">Grant array access</a></p>
				<!-- <p><a href="<%=experimentsDir%>createMAGEML.jsp">Create a MAGE-ML file for uploading to Array Express</a></p>
				<p><a href="<%=experimentsDir%>sendMAGEML.jsp">Upload an experiment to Array Express</a></p> -->
			</div>
        		<% } %>
        </div> <!-- // end what-to-do -->
        </div> <!-- // end welcome-->
    </div> <!-- // end primary-content -->
    
    <div id="secondary-content">
        <div id="did-you-know">
            <h2>Did You Know?</h2>
            <!-- The following div is added to enable a scrolling content box -->
            <div>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK1" target="PhenoGen Help Window">
			You can use data that others have made available on this website. 
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK2" target="PhenoGen Help Window">
			Your gene list can contain any combination of identifiers, and the website will translate them for you. 
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK3" target="PhenoGen Help Window">
			You can correlate phenotype data with the BXD Recombinant inbred mouse brain data on the website. 
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK4" target="PhenoGen Help Window">
			You can share your gene list with other investigators. 
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK5" target="PhenoGen Help Window">
			You can create gene lists from your microarray data analyses. 
			</a>
		</p>
            </div>
        </div> <!-- // end did-you-know -->
        <div id="how-do-i">
            <h2>How Do I?</h2>
            <!-- The following div is added to enable a scrolling content box -->
		<div>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI1" target="PhenoGen Help Window">
			Find the RefSeq Identifiers for my set of genes?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI2" target="PhenoGen Help Window">
			Find the genes that are differentially expressed between my disease and control samples?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI3" target="PhenoGen Help Window">
			Put my arrays onto this web site?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI4" target="PhenoGen Help Window">
			Correlate my phenotype data with microarray data on a publicly available panel of (recombinant) inbred strains of mice or rats?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI5" target="PhenoGen Help Window">
			Prepare my microarray data for analysis?	
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI6" target="PhenoGen Help Window">
			Determine the quality of my microarray data?
			</a>
		</p>
		</div>
        </div> <!-- // end how-do-i -->
    </div> <!-- // end secondary-content -->
	<div class="brClear"></div>
<%@ include file="/web/common/footer.jsp" %>
