<%-- 
 *  Author: Cheryl Hornbaker
 *  Created: Jan, 2010
 *  Description:  Displays common code for protocol selection
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

                <div class="title"> <%=title%>
		<div class="left inlineButton" style="margin-left:150px;margin-right:-200px;" name="createNewProtocol" id="<%=protocolType%>"> Create New </div>
		</div>
                <table id="<%=tableID%>" name="items" class="list_base" cellpadding="0" cellspacing="3" width="70%">
                        <thead>
                        <tr class="col_title">
                                <th>Select</th>
                                <th>Private Protocols</th>
                                <th>Description</th>
                                <th>Delete</th>
                        </tr>
                        </thead>
                        <tbody>
			<%
			theseProtocols = myProtocol.getProtocolForUserByType(userLoggedIn.getUser_name(), myProtocols, protocolType);
			if (theseProtocols != null && theseProtocols.length > 0) {
				for (int i=0; i<theseProtocols.length; i++) {
					Protocol thisProtocol = theseProtocols[i];
					String checked = (chosenProtocolIDs.contains(thisProtocol.getProtocol_id()) ? " checked " : "");
                                	%>
                                	<tr id="<%=thisProtocol.getProtocol_id()%>" descr="<center><h2><%=thisProtocol.getProtocol_name()%></h2><BR><%=thisProtocol.getProtocol_description()%></center>">
                                        	<td class="center"><input type="checkbox" name="<%=protocolType%>" value="<%=thisProtocol.getProtocol_id()%>" <%=checked%> ></td>
                                        	<td class="left"><%=thisProtocol.getProtocol_name()%></td>
                                        	<td class="details">View</td>
						<td class="actionIcons"> <div class="linkedImg delete"></div> </td>
                                	</tr>
                                	<%
                        	}
                	}
			// There are no public protocols for growth conditions or treatments
			if (!protocolType.equals("SAMPLE_GROWTH_PROTOCOL") && !protocolType.equals("SAMPLE_LABORATORY_PROTOCOL")) {
				%> <%@ include file="/web/experiments/include/displayPublicProtocols.jsp" %> <%
			}
		%>
		</table>
		<BR>
		<HR>
		<BR>
