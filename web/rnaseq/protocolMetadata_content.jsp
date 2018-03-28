<%--
 *  Author: Spencer Mahaffey
 *  Created: Nov, 2017
 *  Description:  The web page created by this file allows the user to 
 *		view metadata associated with RNASeqDatasets.
 *  Todo: 
 *  Modification Log:
 *      
--%>

<H2>Experimental Protocols:</H2>
    <table id="protocols" name="items" class="list_base tablesorter">
    <thead><TR class="col_title">
            <TH> Step</TH>
            <TH> Protocol Type</TH>
            <TH> Name</TH>
            <TH> Description</TH>
            <TH> Version</th>
            <TH> Download Protocol</TH>
        </TR>
    </thead>
    <TBODY>
        <%  
            for(int i=0;i<prtcl.size();i++){
                    if(prtcl.get(i).size()>1){
                        ArrayList<RNAProtocol> list=prtcl.get(i);
                        for(int j=0;j<list.size();j++){
                    %>
                            <TR id="<%=prtcl.get(i).get(0).getRnaProtocolID()%>">
                                <TD><%=(i+1)+"."+j%></TD>
                                <TD><%=prtcl.get(i).get(j).getType()%></TD>
                                <TD><%=prtcl.get(i).get(j).getTitle()%></TD>
                                <TD><%=prtcl.get(i).get(j).getDescription()%></TD>
                                <TD><%=prtcl.get(i).get(j).getVersion()%></TD>
                                <td class="actionIcons">
                                        <%if(prtcl.get(i).get(j).getFileName()!=null){%>
                                            <div class="linkedImg download" type="protocol"><div>
                                        <%}%>
                                </td>
                            </TR>
                        <%}%>
                    <%}else if(prtcl.get(i).size()==1){
                        %>
            
                        <TR id="<%=prtcl.get(i).get(0).getRnaProtocolID()%>">
                            <TD><%=i+1%></TD>
                            <TD><%=prtcl.get(i).get(0).getType()%></TD>
                            <TD><%=prtcl.get(i).get(0).getTitle()%></TD>
                            <TD><%=prtcl.get(i).get(0).getDescription()%></TD>
                            <TD><%=prtcl.get(i).get(0).getVersion()%></TD>
                            <td class="actionIcons">
                                    <%if(prtcl.get(i).get(0).getFileName()!=null){%>
                                        <div class="linkedImg download" type="protocol"><div>
                                    <%}%>
                            </td>
                        </TR>
                    <%}%>
        <%}%>
    </TBODY>
</table>

<script>
        var tableRows = getRowsFromNamedTable($("table#protocols"));
	stripeAndHoverTable( tableRows );
</script>
