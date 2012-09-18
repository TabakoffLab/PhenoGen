<%
edu.ucdenver.ccp.PhenoGen.data.Dataset.DatasetVersion selectedDatasetVersion = (edu.ucdenver.ccp.PhenoGen.data.Dataset.DatasetVersion) session.getAttribute("selectedDatasetVersion");
edu.ucdenver.ccp.PhenoGen.data.Dataset.Group[] phenotypeGroups = (edu.ucdenver.ccp.PhenoGen.data.Dataset.Group[]) session.getAttribute("phenotypeGroups");
	int i=0;
	for (edu.ucdenver.ccp.PhenoGen.data.Dataset.Group thisGroup : phenotypeGroups) {
		if (i < phenotypeGroups.length - 1) {
			out.println(phenotypeGroups[i].getGroup_name() + "\t");
		} else {
			out.print(phenotypeGroups[i].getGroup_name() + "\t");
		}
		i++;
	}
String filename = selectedDatasetVersion.getDataset().getNameNoSpaces() + "_v" + selectedDatasetVersion.getVersion() + "_groups";
response.setContentType("application/text");
response.setHeader("Content-Disposition","attachment; filename=\"" + filename + ".txt\"");
%>
