<%--
 *  Author: Cheryl Hornbaker
 *  Created: April, 2006
 *  Description:  This file contains the options displayed for the categories on the litSearch page
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%
	selectedOption = "None";

	optionHash = new LinkedHashMap();
	optionHash.put("None", "---None---");
	optionHash.put("Behavior", "Behavior");
	optionHash.put("Pathology", "Pathology");
	optionHash.put("Physiology", "Physiology");
	optionHash.put("BioChemistry", "BioChemistry");
	optionHash.put("Genetics", "Genetics");
	optionHash.put("Anatomy", "Anatomy");
%>
