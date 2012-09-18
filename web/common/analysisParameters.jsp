<% 
	boolean printStats = false;
	boolean printMT = false;
	boolean printCluster = false;
	if (formName.equals("filters.jsp")) { 
	} else if (formName.equals("statistics.jsp")) {
		printStats = true;
	} else if (formName.equals("multipleTest.jsp")) {
		printStats = true;
		printMT = true;
	} else if (formName.startsWith("cluster")) {
		printStats = true;
		printCluster = true;
	}
%>
	<div class="title">Analysis Parameters</div>
        	<div class="resultGroup">
                	<span class="trigger" name="normalizationStuff">
                       		Normalization 
			</span>
                        <div id="normalizationStuff" style="display:none">
                                <% if (analysisParameters != null && analysisParameters.length > 0) { %>
                        		<table class="analysisParameters" cellpadding="5" cellspacing="5">
                                	<% for (int i=0; i<analysisParameters.length; i++) {
                                		if (analysisParameters[i].getCategory().indexOf("ormaliz") > 0) {%>
                                        		<tr>
                                                		<td><b><%=analysisParameters[i].getCategory()%>:</b> </td>
                                                        	<td><%=analysisParameters[i].getValue()%> </td>
						</tr>
                                        	<% } %>
					<% } 
                                	%></table><%
				} %>
			</div>
                        <div class="brClear"></div>
			<% if (phenotypeParameterGroupID != -99) { 
				ParameterValue[] phenotypeParameters = 
							myParameterValue.getParameterValues(phenotypeParameterGroupID, dbConn); %>
				<span class="trigger" name="phenotypeStuff">
					Phenotype Values
				</span>
				<div id="phenotypeStuff" style="display:none">
                                <% if (analysisParameters != null && analysisParameters.length > 0) { %>
                        		<table class="analysisParameters" cellpadding="5" cellspacing="5">
					<% for (int i=0; i<phenotypeParameters.length; i++) {
						if (!phenotypeParameters[i].getParameter().equals("User ID")) { %>
							<tr>
								<td><%=phenotypeParameters[i].getCategory()%> </td>
								<td><%=phenotypeParameters[i].getParameter()%> </td>
								<td><%=phenotypeParameters[i].getValue()%> </td>
							</tr>
						<% } 
					} 
					%> </table><%
				} %>
                               </div>
                               <div class="brClear"></div>
			<% } %>
			<% if (formName.equals("filters.jsp")) { %>
                        	<span class="trigger less" name="filterStuff">
					Filters
				</span>
                                <div id="filterStuff">
			<% } else { %>
                                <span class="trigger" name="filterStuff">
					Filters
                                </span>
                                <div id="filterStuff" style="display:none">
			<% } %>
			<% if (analysisParameters != null && analysisParameters.length > 0) { %>
                        	<table class="analysisParameters" cellpadding="5" cellspacing="5">
                        	<% for (int i=0; i<analysisParameters.length; i++) {
					if (analysisParameters[i].getCategory().indexOf("ilter") > 0) {
						%> <tr>
                                        		<td><b><%=analysisParameters[i].getCategory()%>:</b> </td>
						</tr><tr>
							<td><p class="indent"><%=analysisParameters[i].getValue()%> </p></td>
						</tr> <% 
					} %>
                        	<% } %>
                        	</table>
			<% } %>
                        </div>
			<% if (printStats) { %>
                        	<div class="brClear"></div>
				<% if (formName.startsWith("cluster") || formName.equals("statistics.jsp")) { %>
                        		<span class="trigger less" name="statsStuff">
                                                		Statistical Method 
                                	</span>
                                	<div id="statsStuff">
				<% } else { %>
                        		<span class="trigger" name="statsStuff">
                                                		Statistical Method 
                                	</span>
                                	<div id="statsStuff" style="display:none">
				<% } %>
				<% if (analysisParameters != null && analysisParameters.length > 0) { %>
                        		<table class="analysisParameters" cellpadding="5" cellspacing="5">
                        		<% for (int i=0; i<analysisParameters.length; i++) {
                        			if (analysisParameters[i].getCategory().indexOf("atist") > 0) {%>
                                			<tr>
                                        			<td><b><%=analysisParameters[i].getParameter()%>:</b> </td>
                                                		<td><%=analysisParameters[i].getValue()%> </td>
							</tr>
						<% } %>
					<% } %>
                        		</table>
				<% } %>
                        	</div>
			<% } %>
                        <div class="brClear"></div>
			<% if (printMT) { %>
				<% if (formName.equals("multipleTest.jsp")) { %>
                        		<span class="trigger less" name="mtStuff">
                                               Multiple Test Adjustment 
                                	</span>
                                	<div id="mtStuff">
				<% } else { %>
                        		<span class="trigger" name="mtStuff">
                                               Multiple Test Adjustment 
                                	</span>
                                	<div id="mtStuff" style="display:none">
				<% } %>
				<% if (analysisParameters != null && analysisParameters.length > 0) { %>
                        		<table class="analysisParameters" cellpadding="5" cellspacing="5">
                       			<% for (int i=0; i<analysisParameters.length; i++) {
						if (analysisParameters[i].getCategory().indexOf("ultipl") > 0) {%>
                                			<tr>
                                				<td><b><%=analysisParameters[i].getCategory()%></b> </td>
							</tr>
							<tr>
                                				<td><b><%=analysisParameters[i].getParameter()%>:</b> </td>
                                        			<td><%=analysisParameters[i].getValue()%> </td>
							</tr>
						<% } %>
					<% } %>
					</table>
				<% } %>
				</div>
			<% } %>
                        <div class="brClear"></div>
			<% if (printCluster) { %>
				<% if (formName.startsWith("cluster")) { %>
                        		<span class="trigger less" name="clusterStuff">
						Cluster Parameters
                                	</span>
                                	<div id="clusterStuff">
				<% } else { %>
                        		<span class="trigger" name="clusterStuff">
						Cluster Parameters
                                	</span>
                                	<div id="clusterStuff" style="display:none">
				<% } %>
				<% if (analysisParameters != null && analysisParameters.length > 0) { %>
                        		<table class="analysisParameters" cellpadding="5" cellspacing="5">
                       			<% for (int i=0; i<analysisParameters.length; i++) {
						if (analysisParameters[i].getCategory().indexOf("luster") > 0) {%>
							<tr>
                                				<td><b><%=analysisParameters[i].getParameter()%>:</b> </td>
                                        			<td><%=analysisParameters[i].getValue()%> </td>
							</tr>
						<% } %>
					<% } %>
					</table>
				<% } %>
				</div>
			<% } %>
            
            <div id="param-working"><img src="<%=imagesDir%>param-wait.gif" alt="Working..." /><BR /><br />Working please wait...</div>
			<BR/><BR/>
			<BR/><BR/>
			<BR/><BR/>
			<%=message%>
			</div>
            <script>
				document.getElementById("param-working").style.display = 'none';
			</script>

