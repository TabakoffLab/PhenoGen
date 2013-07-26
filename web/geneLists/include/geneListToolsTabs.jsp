    <form name="tabLink" action="" method="get">
        <input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>">
    </form>
    <form name="iconLink" action="" method="get">
        <input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>">
    </form>

  <div class="action_tabs">
        <div id="list" class="single" data-landingPage="geneList"><span>List</span></div>
        <div id="annotation" class="single" data-landingPage="annotation"><span>Annotation</span></div>
        <div id="loc_eQTL" class="single" data-landingPage="locationEQTL"><span>Location(eQTL)</span> </div>
        <div id="literature" class="single" data-landingPage="litSearch"><span>Literature </span></div>
    <% if (!selectedGeneList.getOrganism().equalsIgnoreCase("Dm")) { %>    
        <div id="promoter" class="single" data-landingPage="promoter"><span>Promoter</span></div>
     <% } %>   
        <div id="homologs" class="single" data-landingPage="homologs"><span>Homologs</span></div>
	<% if (selectedGeneList.getDataset_id() != -99) { %>
        	<div id="stats" data-landingPage="stats"><span style="vertical-align: middle;">Analysis<BR />Statistics</span></div>
    		<% 
		// Display the pathway tab if the gene list has less than 1000 genes AND it was either derived from a correlation analysis OR
		// it was derived from a differential expression analysis using only 2 groups and a parametric or nonparametric test
		if (
			((selectedGeneList.getStatisticalMethod().equals("pearson") || 
    			selectedGeneList.getStatisticalMethod().equals("spearman")) ||
    			(selectedGeneList.getDatasetVersion().getNumber_of_groups() == 2 &&
			(selectedGeneList.getStatisticalMethod().equals("parametric") ||
			selectedGeneList.getStatisticalMethod().equals("nonparametric")))) &&
    			selectedGeneList.getNumber_of_genes() < 5000 

		) { %> 
        		<div id="pathway" class="single" data-landingPage="pathwayTab"><span>Pathway</span></div>
     		<% } %>   
	<% } %>
        <div id="expressionValues" data-landingPage="expressionValues"><span>Expression<BR />Values</span></div>
        <div id="exonCorrelationTab" data-landingPage="exonCorrelationTab"><span>Exon<BR />Correlation</span></div>
        <div id="saveAs" class="single" data-landingPage="saveAs"><span>Save As...</span></div>
        <div id="compare" class="single" data-landingPage="compareGeneLists"><span>Compare</span></div>
        <div id="share" class="single" data-landingPage="geneListUsers" class="last"><span>Share</span></div>
    </div>
<%
    String selectedTabId = request.getAttribute( "selectedTabId" ) == null ? "" : (String) request.getAttribute( "selectedTabId" );
%>
  <script type="text/javascript">
    $(document).ready(function(){
        setupTabs( '<%=selectedTabId%>' );
    });
  </script>
