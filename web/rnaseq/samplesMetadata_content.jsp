<%--
 *  Author: Spencer Mahaffey
 *  Created: Oct, 2017
 *  Description:  The web page created by this file allows the user to 
 *		view metadata associated with RNASeqDatasets.
 *  Todo: 
 *  Modification Log:
 *      
--%>

<H2>Samples:</H2>
<table id="samples" name="items" class="list_base tablesorter">
    <thead><TR class="col_title">
            <TH> Sample Name</TH>
            <TH> Strain</TH>
            <TH> Age</TH>
            <TH> Sex</TH>
            <TH> Tissue</th>
            <TH> Source</th>
            <TH> Associated Disease</TH>
            <TH> Misc Details</TH>
        </TR>
    </thead>
    <TBODY>
        <% for(int i=0;i<samples.size();i++){
            String srcInfo="";
            if(samples.get(i).getSrcType()!=null){
                srcInfo=srcInfo+samples.get(i).getSrcType();
            }
            if(samples.get(i).getSrcName()!=null){
                srcInfo=srcInfo+" from "+samples.get(i).getSrcName();
            }
            if(samples.get(i).getSrcDate().getTime()!=0){
                srcInfo=srcInfo+" on "+samples.get(i).getSrcDate();
            }
        %>
        <TR>
            <TD><%=samples.get(i).getSampleName()%></TD>
            <TD><%=samples.get(i).getStrain()%></TD>
            <TD><%=samples.get(i).getAge()%></TD>
            <TD><%=samples.get(i).getSex()%></TD>
            <TD><%=samples.get(i).getTissue()%></TD>
            <TD><%=srcInfo%></td>
            <TD><%=samples.get(i).getDisease()%></td>
            <TD><%=samples.get(i).getMiscDetail()%></td>
        </TR>
        <%}%>
    </TBODY>
</table>

<script>
        var tableRows = getRowsFromNamedTable($("table#samples"));
	stripeAndHoverTable( tableRows );
     
</script>
