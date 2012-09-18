<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2008
 *  Description:  This captures the values entered by the user in a Hashtable
 *
 *  Todo:
 *  Modification Log:
 *
--%>

<%
	//
	//Get values entered by the user
	//
	for (Iterator fieldItr = fieldNames.iterator(); fieldItr.hasNext();) {
		String fieldName = (String) fieldItr.next();
		fieldValues.put(fieldName,
				((String)request.getParameter(fieldName) == null ? "" :
				(String)request.getParameter(fieldName).trim()));
	}
	//log.debug("fieldValues = "); myDebugger.print(fieldValues);
	for (Iterator fieldItr = multipleFieldNames.iterator(); fieldItr.hasNext();) {
		String fieldName = (String) fieldItr.next();
		if ((String[]) request.getParameterValues(fieldName) != null) { 
			multipleFieldValues.put(fieldName,
				(String[])request.getParameterValues(fieldName));
		}
	}
	//log.debug("multipleFieldValues = "); myDebugger.print(multipleFieldValues);

%>

