    <form name="tabLink" action="" method="get">
        <input type="hidden" name="datasetID" value="<%=selectedDataset.getDataset_id()%>" />
        <input type="hidden" name="tab" value="" />
    </form>
	<div class="action_tabs">
        	<div id="array" data-landingPage="qualityControlResults"><span>Array Compatibility</span></div>
		<% if (selectedDataset.getPlatform().equals(selectedDataset.AFFYMETRIX_PLATFORM)) { %>
        		<div id="winarray" data-landingPage="qualityControlResults"><span>Within-Array Checks</span></div>
        		<div id="model" data-landingPage="qualityControlResults"><span>Model-Based Checks</span></div>
                	<% if (!myArray.EXON_ARRAY_TYPES.contains(selectedDataset.getArray_type())) { %>
        			<div id="pseudo" data-landingPage="qualityControlResults"><span>Pseudo-Images</span></div>
			<% } %>
        		<div id="maplot" data-landingPage="qualityControlResults"><span>MA Plots</span></div>
		<% } else if (selectedDataset.getPlatform().equals(selectedDataset.CODELINK_PLATFORM)) { %>
        		<div id="rle" data-landingPage="qualityControlResults"><span>Relative Log Expressions</span></div>
        		<div id="cv" data-landingPage="qualityControlResults"><span>Coefficient of Variation</span></div>
        		<div id="pseudo" data-landingPage="qualityControlResults"><span>Pseudo-Images</span></div>
        		<div id="clsoft" data-landingPage="qualityControlResults"><span>CodeLink Software</span></div>
		<% } %>
	</div>


<%
    String selectedQCTabId = request.getAttribute( "selectedQCTabId" ) == null ? "" : (String) request.getAttribute( "selectedQCTabId" );
%>
  <script type="text/javascript">
    $(document).ready(function(){
        setupTabs( '<%=selectedQCTabId%>' );
    });
  </script>
