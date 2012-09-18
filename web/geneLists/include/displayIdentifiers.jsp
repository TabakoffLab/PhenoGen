<%
				pTag = (extraText.equals("") ? "" : "<p style='font-size:80%'>");
				closingTag = (extraText.equals("") ? "" : "</p>");

				for (int i=0; i<(Math.min(thisList.size(), 4)); i++) {
					thisValue = (String) thisList.get(i);
					if ((thisValue.indexOf("XM_") != 0) || (columnName.indexOf("Ucsc") != 0)){
						%><%=pTag%> <%=thisText%><%=thisValue%>" target="<%=target%>"> <%=thisValue%><%=extraText%></a><%=closingTag%><BR><%
					}
				}
				if (thisList.size() > 4) {
					%> 
					<span class="trigger" name="more<%=columnName%><%=thisIdentifier.getIdentifier()%>">More<BR></span>
					<div id="more<%=columnName%><%=thisIdentifier.getIdentifier()%>" style="display:none">
					<%
						for (int i=4; i<thisList.size(); i++) {
							thisValue = (String) thisList.get(i);
							%><%=pTag%> <%=thisText%><%=thisValue%>" target="<%=target%>"> <%=thisValue%><%=extraText%></a> <BR><% 
						} %>
					</div> 
				<% 
				}			

%>
