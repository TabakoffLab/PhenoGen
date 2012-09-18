			<%
			int selectedStep = (request.getAttribute("selectedStep") != null ? 
						Integer.parseInt((String) request.getAttribute("selectedStep")) : 1); 
			for (int i=1; i<numSteps + 1; i++) { 
				String fileName = (selectedStep == i ? "Step" + i + "_dark.gif" :  "Step" + i + ".gif"); 
				%> 
				<img width="27" src="<%= imagesDir %>/icons/<%=fileName%>" alt="<%=i%>" height="27" border="0" /> <%
				if (i<numSteps) {
					%>
					<img width="45" src="<%= imagesDir %>/lineSpacer.gif" alt="" height="27" border="0" /><%
				}
			} %>
