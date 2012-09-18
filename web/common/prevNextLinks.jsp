	<div align=right>
                <%

                if (pageNum != 0) {
                        %>
                        <%=th.getLinkText().replaceAll("PutPageNumberHere", Integer.toString(firstPageNum)).replaceAll("PutSortOrderHere", sortOrder).replaceAll("PutSortColumnHere", sortColumn).replaceAll("action=sort", "action=more")%>">First</a> &nbsp;|&nbsp;
                        <%=th.getLinkText().replaceAll("PutPageNumberHere", Integer.toString(previousPageNum)).replaceAll("PutSortOrderHere", sortOrder).replaceAll("PutSortColumnHere", sortColumn).replaceAll("action=sort", "action=more")%>">Previous</a> &nbsp;
                        <%
                }
		//
		// If only one page is being displayed, don't show any of the page numbers
		//
		if (startBatchNum != endBatchNum - 1) {
                	for (int i=startBatchNum; i <= endBatchNum; i++) {
                        	if (i == pageNum) {
                                	%> | <%=i+1%> <%
                        	} else {
                                	if (i != endBatchNum) {
                                        	%>  | <%=th.getLinkText().replaceAll("PutPageNumberHere", Integer.toString(i)).replaceAll("PutSortOrderHere", sortOrder).replaceAll("PutSortColumnHere", sortColumn).replaceAll("action=sort", "action=more")%>"><%=i+1%></a> <% 
                                	} else if (lastPageNum != 0) {
                                        	%>
                                        	| &nbsp; <%=th.getLinkText().replaceAll("PutPageNumberHere", Integer.toString(nextPageNum)).replaceAll("PutSortOrderHere", sortOrder).replaceAll("PutSortColumnHere", sortColumn).replaceAll("action=sort", "action=more")%>">&nbsp;Next</a> 
                                        	| &nbsp; <%=th.getLinkText().replaceAll("PutPageNumberHere", Integer.toString(lastPageNum)).replaceAll("PutSortOrderHere", sortOrder).replaceAll("PutSortColumnHere", sortColumn).replaceAll("action=sort", "action=more")%>">&nbsp;Last</a> 
                                        	<%
                                	}
                        	}
                	}
		}
                %> 
	</div>
