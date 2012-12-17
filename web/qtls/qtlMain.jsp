<%@ include file="/web/common/session_vars.jsp" %>
<jsp:useBean id="myDataset" class="edu.ucdenver.ccp.PhenoGen.data.Dataset"> </jsp:useBean>

<%
	extrasList.add("index.css");
	request.setAttribute( "selectedMain", "qtlTools" );

	// This is needed in order to set the default dataset when calling calculateQTLs
        Dataset[] qtlDatasets = myDataset.getPublicDatasetsForQTL(publicDatasets);
	session.setAttribute("qtlDatasets", qtlDatasets);
	int defaultDatasetID = myDataset.getDefaultPublicDatasetID(qtlDatasets);

	mySessionHandler.createSessionActivity(session.getId(), "On QTL Tools Main Page", dbConn);

%>

<%@ include file="/web/common/header.jsp" %>



    <div id="primary-content">
        <div id="welcome" style="height:400px;width:946px;">
            <h2>Investigate QTL Regions</h2>
                        <p>Use our QTL tools to investigate genes that fall within a range on the genome that has
			been shown to contribute to a particular phenotype.  You may:
			<ul id="tools" style="padding-left:40px;">
			<li>View physical location and eQTL information about specific genes.
			<li>Download marker set used in eQTL calculations.
			<li>Calculate QTLs based on your phenotype data and PhenoGen marker data.  
			<li>Utilize an interactive chromosomal map to find genes within a specific region.  (under construction)
			</ul>
                        </p>

        <div id="what-to-do">
            <h2>What Would You Like To Do?</h2>
		<div>
            <p><a href="<%=qtlsDir%>defineQTL.jsp?fromMain=Y&fromQTL=Y">Enter phenotypic QTL information</a></p>
            <p><a href="<%=qtlsDir%>calculateQTLs.jsp?datasetID=<%=defaultDatasetID%>&datasetVersion=1">Calculate QTLs for phenotype</a></p>
            <p><a href="<%=qtlsDir%>downloadMarker.jsp">Download marker set used in eQTL calculations</a></p>
            <p><a href="<%=geneListsDir%>listGeneLists.jsp?fromQTL=Y">View physical location and eQTL information about specific genes</a></p>
		</div>
        </div> <!-- // end what-to-do -->
        
        </div> <!-- // end welcome-->
    </div> <!-- // end primary-content -->

	<div class="brClear"></div>
	<div id="secondary-content">
    <div id="did-you-know">
            <h2>Did You Know?</h2>
            <!-- The following div is added to enable a scrolling content box -->
            <div>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK1" target="PhenoGen Help Window">
			You can query a pQTL interval for the genes in your gene list?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK2" target="PhenoGen Help Window">
			You can find genes with cis eQTLs within your pQTL region?
			</a>
		</p>
		<p>
			<a href="<%=helpDir%>help.jsp?topic=DYK3" target="PhenoGen Help Window">
			You can find genes with trans eQTLs within your pQTL region?
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
			Download eQTL information for my candidate genes?
			</a>
		</p>
		<p> 
			<a href="<%=helpDir%>help.jsp?topic=HDI2" target="PhenoGen Help Window">
			Define a pQTL region for a given phenotype?
			</a>
		</p>
		<p> 
			<a href="<%=helpDir%>help.jsp?topic=HDI3" target="PhenoGen Help Window">
			Download marker data used to calculate eQTLs in the BXD RI panel?
			</a>
		</p>
            </div>
        </div> <!-- // end how-do-i for qtl_tools -->
        </div>
        <div class="brClear"></div>
<script type="text/javascript">
	$(document).ready(function(){
		setTimeout("setupMain()", 100); 
	});
</script>
<%@ include file="/web/common/footer.jsp" %>
