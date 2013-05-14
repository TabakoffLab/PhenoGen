	<div class="viewingPane">
		<% if (selectedExperiment.getExp_id() == -99) { %> 
			<div class="viewingTitle">You Are Creating A New Experiment</div>
		<% } else { %>
			<div class="viewingTitle">You Are Creating Experiment:</div>
			<div class="expName"><%=selectedExperiment.getExpName()%></div> 
		<% } %>
	</div>
	<div class="object_details"></div>
	<div class="brClear"></div>

	<script type="text/javascript">
	// setup Details click
	$(document).ready(function() {
		var detailsBox = 
			createDialog(".object_details", {width: 700, height: 800, title: "Experiment Details"});
		$("span.details").click(function(){
			var experimentID = $(this).attr("experimentID");
			var parameters = {experimentID: experimentID} 
			$.get("<%=request.getContextPath()%>/web/experiments/showExpDetails.jsp", parameters, function(data){
				detailsBox.dialog("open").html(data);
				closeDialog(detailsBox);
			});
		});
	});
	</script>

