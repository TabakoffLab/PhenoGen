<% log.debug("start gene list tools tabs");%>
<form name="tabLink" action="" method="get">
        <input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>">
    </form>
    <form name="iconLink" action="" method="get">
        <input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>">
    </form>

  <div class="action_tabs">
        <div id="list" class="single" data-landingPage="geneList"><span>List</span></div>
        <div id="annotation" class="single" data-landingPage="annotation"><span>Annotation</span></div>
        <div id="loc_eQTL"  data-landingPage="locationEQTL"><span>Location<BR />(eQTL)</span> </div>
        <%if(!userLoggedIn.getUser_name().equals("anon")){%>
            <div id="literature" class="single" data-landingPage="litSearch"><span>Literature </span></div>
        <%}%>
        <div id="mir" data-landingPage="mir"><span>miRNA<BR />(multiMiR)</span> </div>
        <div id="wgcna" class="single" data-landingPage="wgcna"><span>WGCNA</span></div>
        <div id="go" class="single" data-landingPage="go"><span>GO</span></div>
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
        <div id="compare" class="single" data-landingPage="compareGeneLists"><span>Compare</span></div>
        <%if(!userLoggedIn.getUser_name().equals("anon")){%>
            <div id="saveAs"  data-landingPage="saveAs"><span>Save <BR /> As...</span></div>
            <div id="share" class="single" data-landingPage="geneListUsers" class="last"><span>Share</span></div>
        <%}%>
    </div>
<%
    String selectedTabId = request.getAttribute( "selectedTabId" ) == null ? "" : (String) request.getAttribute( "selectedTabId" );
%>
  <script type="text/javascript">
    $(document).ready(function(){
        setupTabs( '<%=selectedTabId%>' );
    });
  </script>
  
  <style>
        .hoverDetail{ text-decoration:underline;}
        #container{
            min-height:45em;
        }
        #toolsAccord{
            float:left;
            height:55em;
            width:400px;
            vertical-align: top;
            padding-bottom:9em;
            padding-right:10px;
        }
        #topResultData{
            height:100%;
            vertical-align: top;
            overflow:hidden;
            padding-bottom:6em;
        }        
        table#resultTbl tr.selected td{
		background:	#bed9ba;
	}
        
        .delete{
            cursor:pointer;
        }
        @media screen and (max-width:1000px){
            #toolsAccord{
                height: 15em;
                width:100%;
                vertical-align: auto;
                float:none;
            }
            #topResultData{
                width:100%;
                vertical-align: auto;
                position: relative;
                top:70px;
                padding-bottom: 150px;
            }
        }
</style>
<% log.debug("end gene list tools tabs");%>