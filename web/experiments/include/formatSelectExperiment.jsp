<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2006
 *  Description:  This file formats the experiments in the drop down list.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<script language="JAVASCRIPT" type="text/javascript">
	function IsExperimentSelected(){
		if ((document.selectExperiment.experimentID.value == 'None') || 
			(document.selectExperiment.experimentID.value == '')) {

			alert('Please select a valid experiment before proceeding.')
			document.selectExperiment.experimentID.focus();
			return false;
		}
		return true;
	}
</script>

                                                                                                                  
<%
	Experiment[] myExperiments = null;

	if (experimentTypes.equals("uploadedBySubordinates")) {
		myExperiments = myArray.getExperimentsUploadedBySubordinates(subordinates, "All", dbConn);
	} else if (experimentTypes.equals("uploadedBySubordinatesNotPublic")) {
		myExperiments = myArray.getExperimentsUploadedBySubordinatesNotPublic(subordinates, "All", dbConn);
	} else if (experimentTypes.equals("mageCompleted")) {
		myExperiments = myArray.getExperimentsUploadedBySubordinates(subordinates, "Y", dbConn);
	}
%>

<BR>
	<form   method="post"
        	action="<%=formName%>"
        	enctype="application/x-www-form-urlencoded"
        	onSubmit="return IsExperimentSelected()"
        	name="selectExperiment">

	<TABLE class="borderlessTableWide">
	<TR>
<%
	selectName = "experimentID";
        selectedOption = "None";
        onChange = "";

	if (experimentID == -99) {
        	optionHash = new LinkedHashMap();
		optionHash.put("None", "---------- Select an experiment ----------");
	} else {
        	optionHash = new LinkedHashMap();
		optionHash.put("None", "---------- Select a new experiment ----------"); 
	}

	for (int i=0; i<myExperiments.length; i++) {
		optionHash.put(Integer.toString(myExperiments[i].getExperiment_exprid()), myExperiments[i].getExpName());
	}
	%>
        <%@ include file="/web/common/selectBox.jsp" %>

	<%=twoSpaces%> <input type="submit" name="action" value="Go" >


	</TD>
</TR></TABLE>
</form>
<hr class="experiment">

