<%
        //
        // Fill-up the client-side QTL array
        //
        %><script type="text/javascript" language="JAVASCRIPT"><%
	int j=0;
	for (QTL thisQTL : myQTLs) {
		for (QTL.Locus thisLocus : thisQTL.getLoci()) {
                	%>qtlArray[<%=j%>] = new qtl(<%=thisQTL.getQtl_list_id()%>,
                	"<%=thisLocus.getLocus_name()%>",
                	"<%=thisLocus.getChromosome()%>",
                	<%=thisLocus.getRange_start()%>,
                	<%=thisLocus.getRange_end()%>); <%
		}
		j++;
        }
        %></script>

    <table name="items" class="list_base " cellpadding="0" cellspacing="3" align="center" width="90%">
      <tr class="col_title">
        <th style="width: 200px;">Region Name</th>
        <th class="noSort">Details</th>
        <th class="noSort">Delete</th>
        <!-- <th class="noSort">Download</th> -->
      </tr>

<%
        NumberFormat nf = NumberFormat.getInstance();
        for ( int i = 0; i < myQTLLists.length; i++ ) {
                QTL qtl = (QTL) myQTLLists[i];
%>
                <tr id="<%=qtl.getQtl_list_id()%>">
                <td><%=qtl.getQtl_list_name()%></td>
                <td>
                        <%
                        String qtlDetails = "";
			for (QTL thisQTL : myQTLs) {
                                if (thisQTL.getQtl_list_id() == qtl.getQtl_list_id()) {
					for (QTL.Locus thisLocus : thisQTL.getLoci()) {
                                        	qtlDetails = qtlDetails +
                                                	"QTL ID:  " + thisLocus.getLocus_name() +
                                                	", Chromosome: " + thisLocus.getChromosome() + ", " +
                                                	nf.format(thisLocus.getRange_start()) + " bp - "+
                                                	nf.format(thisLocus.getRange_end()) + " bp" + "<BR>";
					}
                                }
                        } %>
                <span class="vList" data-list="<%=qtlDetails%>">View</span>
        </td>
        <td>
          <div class="linkedImg delete"></div>
	</td>
	<!--
	<td>
          <div class="linkedImg download"></div>
        </td>
	-->
      </tr>
<%
    }
%>
    </table>
