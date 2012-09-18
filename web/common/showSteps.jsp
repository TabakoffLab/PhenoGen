	<h2 style="margin:10px 0px 0px 20px;"><%=stepHeader%></h2>
	<div class="steps_container">
		<div id="circles">
			<%
		        String spacer = "<img src=\"" + imagesDir + "icons/arrow.png\" alt=\"\"/>";
			
			int thisStep = (request.getAttribute("selectedStep") != null ? 
						Integer.parseInt((String) request.getAttribute("selectedStep")) : 0); 
			log.debug("thisStep = "+thisStep);
			for (int i=0; i<steps.length; i++) {
				Toolbar.Option thisOption = steps[i]; 
				String linkTo = thisOption.getLinkTo(); 
				String icon = thisOption.getIcon(); 
				String altText = thisOption.getAltText(); 
				//log.debug("option = "+option);
				//log.debug("linkTo = "+linkTo);
				String linkStuffFront = (thisStep > i ? "<a href=\"" + linkTo + "\">" : "");
				String linkStuffEnd = (thisStep > i ? "</a>" : "");
				String stepHighlight = (thisStep == i ? "currentStep" : 
							(thisStep > i ? "earlierStep" : 
							(thisStep < i ? "laterStep" : "")));
				%> 
				<%=linkStuffFront%> 
				<div class="picture icons <%=stepHighlight%>"> 
					<img src="<%=imagesDir%>/icons/<%=icon%>" alt="" /> 
					<br/><%=altText%> 
				</div>
				<%=linkStuffEnd%>
				<% if (i<steps.length-1) { %>
					<div class="icons"><%=spacer%></div>
				<% } %>
			<% } %>
		</div>
	</div> <!-- end div_class_steps_container -->
	<div class="brClear"></div>
