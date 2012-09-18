<%--
 *  Author: Cheryl Hornbaker
 *  Created: Feb, 2010
 *  Description:  Displays common code for public protocol selection
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

		<%
			%><tr class="col_title">
                                <th>Select</th>
				<th>Public Protocols</th>
				<th colspan="2">Description</th>
			</tr><%
			if (myPublicProtocols != null && myPublicProtocols.length > 0 && !protocolType.equals("")) {
				for (int i=0; i<myPublicProtocols.length; i++) {
					Protocol thisProtocol = myPublicProtocols[i];
					String checked = (chosenProtocolIDs.contains(thisProtocol.getProtocol_id()) ? " checked " : "");
					if (!protocolType.equals("") && 
						thisProtocol.getTypeName() != null && thisProtocol.getTypeName().equals(protocolType) &&
						thisProtocol.getProtocol_description() != null) {
                                		%>
                                		<tr id="<%=thisProtocol.getProtocol_id()%>" title="<%=thisProtocol.getProtocol_name()%>">

                                        		<td class="center"><input type="checkbox" name="<%=protocolType%>" value="<%=thisProtocol.getProtocol_id()%>" <%=checked%> ></td>
                                        		<td class="left"><%=thisProtocol.getProtocol_name()%></td>
                                        		<td colspan="2" class="publicDetails">View </td>
                                		</tr>
                                		<%
					}
                        	}
                	} else {
				%><tr><td colspan="100%">Unfortunately, the public protocols are not available for viewing at this time</td></tr><%
			}
		%>
