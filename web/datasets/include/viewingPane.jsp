<% 
	String version = (selectedDatasetVersion.getVersion() == -99 ? "" : "v" + selectedDatasetVersion.getVersion()); 
	String title= (selectedDatasetVersion.getVersion() != -99 ? "Dataset Version Details" : 
			"Dataset Details");
	String parameterType = (selectedDatasetVersion.getVersion() != -99 ? "datasetVersion" : 
			"dataset");
%>
	
  <div class="brClear"></div>
<!--
  <div id="related_links">
    <div class="action" title="Return to select a different dataset">
      <a class="linkedImg return" href="listDatasets.jsp">
        <%=fiveSpaces%>
        Select Different Dataset
      </a>
    </div>
  </div>
-->

  <div class="viewingPane">
    <div class="viewingTitle">You are Analyzing:</div>
    <div class="listName"><%=selectedDataset.getName()%> <%=version%><%=twoSpaces%>
    </div>

  </div>

  <div class="object_details"></div>

	<script type="text/javascript">
	// setup Details click
	$(document).ready(function() {
		var detailsBox = 
			createDialog(".object_details", {width: 700, height: 800, title: "<%=title%>"});
		$("span.details").click(function(){
			var datasetID = $(this).attr("datasetID");
			var datasetVersion = $(this).attr("datasetVersion");
			var parameters = {datasetID: datasetID, 
					datasetVersion: datasetVersion,
					parameterType: "<%=parameterType%>"};
			$.get("<%=commonDir%>formatParameters.jsp", parameters, function(data){
				detailsBox.dialog("open").html(data);
				closeDialog(detailsBox);
			});
		});
	});
	</script>
