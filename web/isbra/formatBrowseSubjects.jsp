<form method="post"
        action="<%=formName%>"
        enctype="application/x-www-form-urlencoded"
        name="chooseCriterion">

<center><span class=heading>Search By:</span></center>
<TABLE class=borderlessTable3>
        <TR>
                <TD class=columnHeading> Center: </TD>
                <TD class=columnHeading> Attribute: </TD>
		<TD class=columnHeading> Equals:</TD>
        </TR>
        <TR>
        <TD>
                <%
                LinkedHashMap centerHash = myIsbra.getCenters(dbConn);

		optionHash = new LinkedHashMap();
		optionHash.put("All", "All");

		Iterator centerHashItr = centerHash.keySet().iterator();
		while (centerHashItr.hasNext()) {
			String center = (String) centerHashItr.next();
			optionHash.put(center, (String) centerHash.get(center));
		}

                selectName = "criterion1";
                selectedOption = (String) fieldValues.get(selectName);

                %> <%@ include file="/web/common/selectBox.jsp" %>

        </TD><TD>
                <%
                Isbra.Question[] myQuestions = myIsbra.getQuestions("All", dbConn);
		optionHash = new LinkedHashMap();
		optionHash.put("-99", "All");

		for (int i=0; i<myQuestions.length; i++) {
			optionHash.put(Integer.toString(myQuestions[i].getQuestion_id()), myQuestions[i].getDescription());		
		}

                selectName = "criterion2";
                selectedOption = (String) fieldValues.get(selectName);
		onChange = "setFormSubmitMarker(this.form,'selectmenu');this.form.submit();";

                %> <%@ include file="/web/common/selectBox.jsp" %>

        </TD><TD>
                <%
                selectName = "criterion2_value";
                selectedOption = (String) fieldValues.get(selectName);
		onChange = "";

		if (whichSubmit != null && whichSubmit.equals("selectmenu")) {
			optionHash = myIsbra.getValidValues(Integer.parseInt((String) fieldValues.get("criterion2")), dbConn);	
		} else {
			optionHash = new LinkedHashMap();
		} 
	        %> <%@ include file="/web/common/selectBox.jsp" %> 
	</TD>
	<TD>


	<input type="hidden" name="whichSubmit" value="">
	<input type="submit" name="action" value="Find Subjects" onClick="setFormSubmitMarker(this.form,'submitbutton')"> 
        </TD>
        </TR>
        </TABLE>

<BR><BR>
</form>

