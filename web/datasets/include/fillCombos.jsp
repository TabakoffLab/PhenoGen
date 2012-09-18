        <!-- fill up the client-side array with saved combination values -->
        <script language="JAVASCRIPT" type="text/javascript"><%
                int compoundDoseComboRowNum = 0;
                if (myCompoundDoseCombos != null && myCompoundDoseCombos.size() > 0) {
			for (Iterator itr =  myCompoundDoseCombos.iterator(); itr.hasNext();) {
				String[] thisArray = (String[]) itr.next();
				String compound = (thisArray[0].equals("-") ? "" : thisArray[0]);
				String dose = (thisArray[1].equals("- -") ? "" : thisArray[1]);
				%> compoundDoseCombos[<%=compoundDoseComboRowNum%>] =
                                               new compoundDoseCombo("<%=compound%>",
							"<%=dose%>");
				<%
                                compoundDoseComboRowNum++;
			}
                } 
                int treatmentDurationComboRowNum = 0;
                if (myTreatmentDurationCombos != null && myTreatmentDurationCombos.size() > 0) {
			for (Iterator itr =  myTreatmentDurationCombos.iterator(); itr.hasNext();) {
				String[] thisArray = (String[]) itr.next();
				String treatment = (thisArray[0].equals("-") ? "" : thisArray[0]);
				String duration = (thisArray[1].equals("-") ? "" : thisArray[1]);
				%> treatmentDurationCombos[<%=treatmentDurationComboRowNum%>] =
                                               new treatmentDurationCombo("<%=treatment%>",
							"<%=duration%>");
				<%
                                treatmentDurationComboRowNum++;
			}
                } %>
	</script>

