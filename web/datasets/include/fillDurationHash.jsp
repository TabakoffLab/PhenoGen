<%--
 *  Author: Cheryl Hornbaker
 *  Created: Oct, 2007
 *  Description: This file is included in screens that have 'Working...' box implemented 
 *  Todo:
 *  Modification Log:
 *
--%>

<%
        //
        // Fill-up the client-side runtime array
        //
        int rowNumber=0;
        %><script language="JAVASCRIPT" type="text/javascript"><%
		//log.debug("before durationHash.keySet()");
        Iterator itr = durationHash.keySet().iterator();
		//log.debug("after durationHash.keySet()");
        while (itr.hasNext()) {
                String program = (String) itr.next();
				//log.debug("program"+program);
                int duration = Integer.parseInt((String) durationHash.get(program));
                        %>durationArray[<%=rowNumber%>] = new durationRow('<%=program%>', <%=duration%>); <%
                        rowNumber++;
        }
        %></script><%
%>


