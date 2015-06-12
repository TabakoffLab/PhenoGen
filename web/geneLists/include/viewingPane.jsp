  <div class="brClear"></div>
<!--
  <div id="related_links">

    <div class="action" title="Return to all gene lists page">
      <a class="linkedImg return" href="listGeneLists.jsp?fromQTL=<%=fromQTL%>">
        <%=fiveSpaces%>
        Select Different Gene List
      </a>
    </div>

  </div>
-->

  <div class="viewingPane">
	<div class="viewingTitle">You are viewing:</div>

	<div class="listName"><%=selectedGeneList.getGene_list_name()%>
<!--
		<span class="details" geneListID="<%=selectedGeneList.getGene_list_id()%>" 
						parameterGroupID="<%=selectedGeneList.getParameter_group_id()%>"> 
		<img src="<%=imagesDir%>icons/detailsMagnifier.gif" alt="Gene List Details"></span> 
-->
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


