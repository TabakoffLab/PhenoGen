        <!-- fill up the client-side array with saved combination values -->
        <script language="JAVASCRIPT" type="text/javascript"><%
                int orgModRowNum = 0;
                int orgModSLGRowNum = 0;
                int orgModSLGTissueRowNum = 0;
                int orgModSLGTissueChipRowNum = 0;
                if (myCombos != null && myCombos.size() > 0) {
			List<String[]> orgModCombos = myArray.getSet(myCombos, 0, 2);
			for (Iterator itr =  orgModCombos.iterator(); itr.hasNext();) {
				String[] thisCombo = (String[]) itr.next();
				String organism = thisCombo[0];
				String mod = thisCombo[1];
				%> organismModCombos[<%=orgModRowNum%>] =
                                               new organismModCombo("<%=organism%>",
							"<%=mod%>");
				<%
                                orgModRowNum++;
			}
			List<String[]> orgModSLGCombos = myArray.getSet(myCombos, 0, 3);
			for (Iterator itr =  orgModSLGCombos.iterator(); itr.hasNext();) {
				String[] thisCombo = (String[]) itr.next();
				String organism = thisCombo[0];
				String mod = thisCombo[1];
				String slg = thisCombo[2];
				%> organismModSLGCombos[<%=orgModSLGRowNum%>] =
                                               new organismModSLGCombo("<%=organism%>", "<%=mod%>", "<%=slg%>");
				<%
                                orgModSLGRowNum++;
			}
			List<String[]> orgModSLGTissueCombos = myArray.getSet(myCombos, 0, 4);
			for (Iterator itr =  orgModSLGTissueCombos.iterator(); itr.hasNext();) {
				String[] thisCombo = (String[]) itr.next();
				String organism = thisCombo[0];
				String mod = thisCombo[1];
				String slg = thisCombo[2];
				String organismPart = thisCombo[3];
				%> organismModSLGTissueCombos[<%=orgModSLGTissueRowNum%>] =
                                               new organismModSLGTissueCombo("<%=organism%>", "<%=mod%>", "<%=slg%>", "<%=organismPart%>");
				<%
                                orgModSLGTissueRowNum++;
			}
			List<String[]> orgModSLGTissueChipCombos = myArray.getSet(myCombos, 0, 5);
			for (Iterator itr =  orgModSLGTissueChipCombos.iterator(); itr.hasNext();) {
				String[] thisCombo = (String[]) itr.next();
				String organism = thisCombo[0];
				String mod = thisCombo[1];
				String slg = thisCombo[2];
				String organismPart = thisCombo[3];
				String chip = thisCombo[4];
				%> organismModSLGTissueChipCombos[<%=orgModSLGTissueChipRowNum%>] =
                                               new organismModSLGTissueChipCombo("<%=organism%>", "<%=mod%>", "<%=slg%>", "<%=organismPart%>", "<%=chip%>");
				<%
                                orgModSLGTissueChipRowNum++;
			}
                } %>
	</script>

