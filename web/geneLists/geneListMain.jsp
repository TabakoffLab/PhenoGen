<%@ include file="/web/common/session_vars.jsp" %>
<%
	extrasList.add("normalize.css");
	extrasList.add("index.css");
	request.setAttribute( "selectedMain", "geneListTools" );
	mySessionHandler.createActivity("On Research Genes Main Page", dbConn);

%>

<%@ include file="/web/common/header_adaptive_menu.jsp" %>


    <div id="primary-content">
        <div id="welcome">
            <h2>Research Genes</h2>
                        <p>Use our suite of tools to help you understand more about a list of genes 
			that you've either created or generated through a microarray analysis.<BR><BR>
			Once the list of genes you want to research is available on the website, you can use the following tools:
			<ul id="tools" style="padding-left:40px;">
			<li><span class="highlight">Annotation</span> to link to other databases containing information about your genes.
			<li><span class="highlight">Location</span> to view your genes on a chromosome map.
			<li><span class="highlight">Literature Search</span> to retrieve papers related to your genes.
			<li><span class="highlight">Promoter</span> to find motifs and transcription factor binding sites for your list of genes.
			<li><span class="highlight">Homologs</span> to find homologous genes in other species.
			<li><span class="highlight">Expression Values</span> to get the expression values for your genes in a dataset.
			<li><span class="highlight">Save As...</span> to save the list in another format.
			<li><span class="highlight">Compare</span> to find other gene lists that contain the same genes.
			<li><span class="highlight">Share</span> to give others access to your gene list.
			</ul>
                        </p>

        <div id="what-to-do">
            <h2>What Would You Like To Do?</h2>
		<div>
            <p><a href="<%=geneListsDir%>createGeneList.jsp?fromMain=Y">Upload or create a new gene list</a></p>
            <p><a href="<%=datasetsDir%>listDatasets.jsp?">Derive a gene list from a microarray analysis</a></p>
            <p><a href="<%=geneListsDir%>listGeneLists.jsp">Select a gene list for further investigation</a></p>
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
			You can share your gene list with other investigators?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK2" target="PhenoGen Help Window">
			You can display the location of your genes on a zoomable chromosome map that you 
			can also download?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK3" target="PhenoGen Help Window">
			You can assess your gene list for over-representation of 
			transcription factor binding sites (TFBS)?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK4" target="PhenoGen Help Window">
			You can view up to 2,000 bases upstream of your gene(s) of interest?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK5" target="PhenoGen Help Window">
			You can reduce the number of genes in your list by their physical 
			location or location of their eQTL?
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
                        Find literature that mentions more than one gene on my list?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI2" target="PhenoGen Help Window">
                        Find the RefSeq identifiers for my set of genes?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI3" target="PhenoGen Help Window">
                        Download annotation information for my gene list?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI4" target="PhenoGen Help Window">
                        Identify common genes across gene lists?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI5" target="PhenoGen Help Window">
                        Find out if my genes are conserved across species?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=HDI6" target="PhenoGen Help Window">
                        View all available gene lists?
			</a>
		</p>
            </div>
        </div> <!-- // end how-do-i for genelist_tools -->
    </div> <!-- // end secondary-content -->
	<div class="brClear"></div>
<%@ include file="/web/common/footer_adaptive.jsp" %>
<script type="text/javascript">
	$(document).ready(function(){
		setTimeout("setupMain()", 100); 
	});
</script>
