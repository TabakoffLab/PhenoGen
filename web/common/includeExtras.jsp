
<%
	ArrayList extrasAttributes = (ArrayList)request.getAttribute( "extrasList" );

	if ( extrasAttributes != null ) {
		for ( int i = 0; i < extrasAttributes.size(); i++ ) {
			String extra = (String) extrasAttributes.get(i);

			if ( extra.indexOf( ".css" ) > 0 ) { %> 
				<link rel="stylesheet" href="<%=contextPath%>/css/<%= extra %>" type="text/css" media="screen"> <%
			} else if ( extra.indexOf( ".js" ) > 0 ) { %> 
				<script type="text/javascript" src="<%=contextPath%>/javascript/<%= extra %>"></script> <%
			}
		}
	}
%>
