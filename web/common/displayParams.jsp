<%
	if (paramsToDisplay != null && paramsToDisplay.length != 0) { %>
		<div class="title"> 
			<span class="trigger" name="<%=parameterType%>_parameters_Stuff">
			<%=paramTitle%>
			</span>
		</div>
		<div id="<%=parameterType%>_parameters_Stuff" style="display:none">
      		<table id="<%=parameterType%>_parameters" class="list_base" cellpadding="0" cellspacing="3"  width="95%">
			<thead>
			<tr class="col_title">
				<th> Category
				<th> Parameter Name
				<th> Value
			</tr>
			</thead>
			<tbody>
                        <% for (int i=0; i<paramsToDisplay.length; i++) { %>
				<tr>
                                	<td><b><%=paramsToDisplay[i].getCategory()%></b></td>
                                	<td><b><%=paramsToDisplay[i].getParameter()%></b></td>
                                        <td><%=paramsToDisplay[i].getValue()%></td>
				</tr>
			<% } %>
		</tbody>
		</table>
		</div>
		<div class="brClear"></div>
	<% }
%>

