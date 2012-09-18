<%@ include file="/web/common/session_vars.jsp" %>
<%
	extrasList.add("index.css");
	request.setAttribute( "selectedMain", "microarrayTools" );
	session.setAttribute("dummyDataset", null);
	session.setAttribute("selectedDataset", null);
	session.setAttribute("selectedExperiment", null);
	session.setAttribute("selectedGeneList", null);
	mySessionHandler.createActivity("On Microarray Main Page", dbConn);

%>

<%@ include file="/web/common/header.jsp" %>

<script type="text/javascript">
	var crumbs = ["Home", "Analyze Microarray Data"];
</script>

    <div id="primary-content">
        <div id="welcome">
            <h2>Analyze Microarray Data</h2>
		<p>You may analyze your own expression data, or you can analyze any of the arrays on the website that are available to the public.  
                	To analyze your own data, you must first upload the raw data files 
			(the .CEL files for Affymetrix or the .txt files for CodeLink)<BR><BR>
			Once the arrays you want to analyze are available on the website, perform the following steps:
			<ol id="steps" style="padding-left:40px;">
			<li>Designate which arrays you want to include in your analysis. 
			<li>Run the quality control process to ensure the arrays meet basic quality standards. 
			<li>Group the arrays based on your hypothesis and normalize the data using one or more methods.  
			Each normalized version may be saved and analyzed independently.  
			<li>Analyze the normalized versions and save the resulting list of genes.
			</ol>
                </p>

        	<div id="what-to-do">
            	<h2>What Would You Like To Do?</h2>
			<div>
            			<p><a href="<%=experimentsDir%>listExperiments.jsp">Upload your own data</a></p>
            			<p><a href="<%=datasetsDir%>basicQuery.jsp">Create a dataset</a></p>
            			<p><a href="<%=datasetsDir%>listDatasets.jsp">Analyze microarray data</a></p>
            			<p><a href="<%=datasetsDir%>geneData.jsp">View expression values for a list of genes in a dataset</a></p>
			</div>
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
			You can download raw or normalized microarray data.
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK2" target="PhenoGen Help Window">
			You can view an inventory of all your datasets organized by their 
			normalization, QC, and gene list-creation status.
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK3" target="PhenoGen Help Window">
			After running QC on your dataset, you can remove defective arrays from subsequent analyses.
			</a>
		</p>
		<!-- 
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK4" target="PhenoGen Help Window">
			You can correlate phenotype data with our BXD Recombinant Inbred Mouse Brain data. 
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK5" target="PhenoGen Help Window">
			You can share your private expression data with other investigators that you designate. 
			</a>
		</p>
		-->
            </div>
        </div> <!-- // end did-you-know for microarray_tools -->
        <div id="how-do-i">
            <h2>How Do I?</h2>
            <!-- The following div is added to enable a scrolling content box -->
            <div>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI1" target="PhenoGen Help Window">
			View my QC results?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI2" target="PhenoGen Help Window">
			Assign samples to groups for analysis within a dataset?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI3" target="PhenoGen Help Window">
			Analyze for differential expression?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI4" target="PhenoGen Help Window">
			Run a cluster analysis?
			</a>
		</p>
            </div>
        </div> <!-- // end how-do-i for microarray_tools -->

    </div> <!-- // end secondary-content -->
	<div class="brClear"></div>
<%@ include file="/web/common/footer.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		setTimeout("setupMain()", 100); 
	});
</script>
