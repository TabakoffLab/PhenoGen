  <div class="brClear"></div>

  <div class="viewingPane">
	<div class="viewingTitle">You are viewing:</div>

	<div class="listName"><%=selectedGeneList.getGene_list_name()%>
	</div>
        
  </div>
<BR><BR><BR>
	<div class="object_details"></div>

	<script type="text/javascript">
		$(document).ready(function() {
			// setup Details click
			var detailsBox;
			if (detailsBox == undefined) {
				detailsBox = createDialog(".object_details", {width: 700, height: 800, title: "Gene List Details"});
			}

			$("span.details").click(function(){
				var parameters = {geneListID: $(this).attr("geneListID"), 
					parameterType : "geneList", 
					parameterGroupID : $(this).attr("parameterGroupID") };
				$.get("<%=commonDir%>formatParameters.jsp", parameters, function(data){
                			detailsBox.dialog("open").html(data);
					closeDialog(detailsBox);
				});
			});
		});
	</script>


