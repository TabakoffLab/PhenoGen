<%--
 *  Author: Cheryl Hornbaker
 *  Created: January, 2010
 *  Description:  This file formats a select box using a Hashtable of value/display pairs for a 
 *		box where the user can select multiple values
 *
 *  Todo:
 *  Modification Log:
 *
--%>

	<select name="<%=selectName%>" id="<%=selectName%>" style="<%=style%>" onChange="<%=onChange%>" multiple="multiple" size="10"> <%
	optionItr = optionHash.keySet().iterator();
	optionCount=0;
	firstOptGroup = true;
	while (optionItr.hasNext()) {
                String optionValue = (String) optionItr.next();
                String optionDisplay = (String) optionHash.get(optionValue);
                optionDisplay = optionDisplay.substring(0,Math.min(optionDisplay.length(),100)) +
				(optionDisplay.length() > 100 ? "..." : "");
		String selected = (optionValue.equals(selectedOption) ? " selected" : "");
		if (optGroupHash != null && optGroupHash.containsKey(Integer.toString(optionCount))) {
                	String optGroupDisplay = (String) optGroupHash.get(Integer.toString(optionCount));
			if (firstOptGroup) {
				firstOptGroup = false;
				%>
				<optgroup label="<%=optGroupDisplay%>"> <%	
			} else { 
				%> 
				</optgroup>
				<optgroup label="<%=optGroupDisplay%>"> <%	
			}
		}
		optionCount++;
		%>
		<option value="<%=optionValue%>"<%=selected%>><%=optionDisplay%></option> <%	
        }
	if (optGroupHash != null) {
		%></optgroup> <%	
	}
	%>
	</select>
