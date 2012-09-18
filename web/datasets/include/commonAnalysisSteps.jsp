<%
	int numSteps = 1;
	boolean pre = true;
	String stepHeader = "Steps for a " + (analysisType.equals("diffExp") ? "differential expression" : 
					(analysisType.equals("correlation")  ? "correlation" : 
						(analysisType.equals("cluster") ? "cluster" : ""))) + " analysis:";

	String prepLink = "<span>Group and Normalize Dataset</span>"; 
	String chooseVersionLink = "<span>Choose Normalized Version</span>"; 
	String chooseAnalysisLink = "<span>Select Analysis Method</span>"; 
	String phenotypeLink = "<span>Choose Phenotype Data</span>"; 
	String filtersLink = "<span>Filter Genes</span>";
	String statsLink = "<span>Run Statistical Test</span>"; 
	String mtLink = "<span>Correct for Multiple Testing</span>"; 
	String clusterLink = "<span>Cluster</span>";
	String clusterResultsLink = "<span>Review Cluster Results</span>"; 
	String saveGeneListLink = "<span>Save Gene List</span>"; 
%>
	<h2 style="margin-left:50px; margin-bottom:0px;"><%=stepHeader%></h2>


