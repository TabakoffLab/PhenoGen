  <div class="brClear"></div>
<!--
  <div id="related_links">
    <div class="action" title="Return to select a different dataset and/or phenotype">
      <a class="linkedImg return" href="calculateQTLs.jsp?datasetID=<%=selectedDataset.getDataset_id()%>&datasetVersion=<%=selectedDatasetVersion.getVersion()%>">
        <%=fiveSpaces%>
        Select Different Phenotype
      </a>
    </div>
  </div>
-->

	<div class="viewingPane">
        	<div class="viewingTitle"> You are calculating QTLs for this phenotype: </div>
                <div class="listName"><%=phenotypeName%>
<!--
    			<span class="details" phenotypeParameterGroupID="<%=phenotypeParameterGroupID%>"> 
			<img src="<%=imagesDir%>icons/detailsMagnifier.gif" alt="Phenotype Details"> 
			</span>
-->
		</div> 
	</div>

  <div class="object_details"></div>

	<script type="text/javascript">
	// setup Details click
	$(document).ready(function() {
		var detailsBox = 
			createDialog(".object_details", {width: 700, height: 800, title: "Phenotype Details"});
		$("span.details").click(function(){
			var phenotypeParameterGroupID = $("input[name='phenotypeParameterGroupID']").val();
			var datasetID = $("input[name='datasetID']").val();
			var datasetVersion = $("input[name='datasetVersion']").val();
			var parameters = {datasetID: datasetID,
					datasetVersion: datasetVersion,
					parameterGroupID: phenotypeParameterGroupID, 
					parameterType: "phenotype"};
			$.get("<%=contextPath%>/web/common/formatParameters.jsp", parameters, function(data){
				detailsBox.dialog("open").html(data);
				closeDialog(detailsBox);
			});
		});
	});
	</script>

	<%@ include file="/web/qtls/include/qtlTabs.jsp" %>
