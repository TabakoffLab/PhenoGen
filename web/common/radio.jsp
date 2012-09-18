<%--
 *  Author: Cheryl Hornbaker
 *  Created: September, 2008
 *  Description:  This file formats a radio button list using a Hashtable of value/display pairs
 *
 *  Todo:
 *  Modification Log:
 *
--%>
	<%
	optionItr = optionHash.keySet().iterator();
	while (optionItr.hasNext()) {
                String optionValue = (String) optionItr.next();
                String optionDisplay = (String) optionHash.get(optionValue);
		String chosen = (optionValue.equals(selectedOption) ? " checked" : "");
		// In order to format the radio button the way you want it, insert HTML tags in the optionDisplay string
		%>
		<input type="radio" name="<%=radioName%>" value="<%=optionValue%>" <%=chosen%> onClick="<%=onClick%>"> <%=optionDisplay%><%
        }
	%>
