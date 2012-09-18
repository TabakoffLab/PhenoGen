	<% if (datasetClass.equals("public")) { %>
		<div class="leftTitle">  Public Datasets 
                <span class="info" title="These data were generated and submitted by the Boris Tabakoff lab and are available for use by all registered users of PhenoGen.">
                    <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                </span>
		</div>
		<table name="items" id="publicDatasets" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="95%">
	<% } else { %>
		<div class="leftTitle">  My Private Datasets 
                <span class="info" title="Expression data from <b>My Private Datasets</b> can only be viewed and analyzed by you.">
                    <img src="<%=imagesDir%>icons/info.gif" alt="Help">
                </span></div>
		<table name="items" id="privateDatasets" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="95%">
	<% } %>
		<thead>
		<tr>
			<th colspan="5" class="topLine noSort noBox">&nbsp;</th>
			<th colspan="4" class="center noSort topLine">Results</th>
			<% if (!datasetClass.equals("public")) { %>
				<th colspan="3" class="topLine noSort noBox">&nbsp;</th>
			<% } else { %> 
				<th colspan="2" class="topLine noSort noBox">&nbsp;</th>
			<% } %> 
		</tr>
		<tr class="col_title">
			<th width="50%">Dataset Name</th>
			<th>Date Created</th>
			<th>QC Complete
                		<span class="info" title="The quality control step has been completed for this dataset.">
                    		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                		</span>
			</th>
			<th>Arrays Grouped and Normalized
                		<span class="info" title="Sample grouping has been defined and normalization has been completed.">
                    		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                		</span>
			</th>
			<th>Phenotype Data</th>
			<th>Quality Control Results</th>
            <th>Filter/Stats Results</th>
			<th>Cluster Results</th>
			<th>Gene Lists </th>
			<th class="noSort">Details</th>
			<% if (!datasetClass.equals("public")) { %>
				<th class="noSort">Delete
					<!--
                			<span class="info" title="Click to delete this dataset from PhenoGen.">
                    			<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                			</span>
					-->
				</th>
			<% } %>
			<th class="noSort">Download
                		<span class="info" title="Click to download a copy of your raw or normalized data onto your computer.">
                    		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                		</span>
			</th>
		</tr>
		</thead>
		<tbody>
