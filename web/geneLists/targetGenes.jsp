<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2005
 *  Description:  This file formats the target gene files generated by the Promoter module.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 
<%
	log.info("in targetGenes.jsp. user = " + user);
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");

	String tf = request.getParameter("tf");
	String filePrefix = (String) session.getAttribute("filePrefix");
	String[] tfbsResults = myFileHandler.getFileContents(new File(filePrefix + "tfbsHits.txt"), "withSpaces");

	String ensemblOrganism = new ObjectHandler().replaceBlanksWithUnderscores(
							new Organism().getOrganism_name(selectedGeneList.getOrganism(), dbConn));

	//String linkText = "<a target='TargetGeneWindow' href='http://www.ensembl.org/" + ensemblOrganism + "/textview?&amp;idx=Gene&amp;q=";
        String linkText = "<a target='TargetGeneWindow' href='http://www.ensembl.org/" + ensemblOrganism +
				"/Search/Summary?species="+
                                ensemblOrganism + ";idx=All;q=";
	String ncbiLinkText = "<a target='Entrez Window' href=\"http://view.ncbi.nlm.nih.gov/nucleotide/"; 
	mySessionHandler.createGeneListActivity("Looked at target genes generated by oPOSSUM", dbConn);

%>

<%@ include file="/web/common/header.jsp" %>
	<script type="text/javascript">
		crumbs = ["Home", "Research Genes", "Promoter"];
	</script>

	<%@ include file="/web/geneLists/include/viewingPane.jsp" %>

	<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>

	<div class="dataContainer" style="height:400px" >
	<div id="related_links">
		<div class="action" title="Return to select a different promoter analysis">
			<a class="linkedImg return" href="promoter.jsp">
			<%=fiveSpaces%>
			Select Another Promoter Analysis
			</a>
		</div>
	</div>
	<div class="brClear"></div>

	<table class="list_base" cellpadding="0" cellspacing="3" width="50%">
		<tr class="title">
			<th colspan="100%"><%=tf%> associated genes:</th>
		</tr>
		<tr class="col_title">

		<% if ((new File(filePrefix + "fisher.txt")).exists()) { %>
        		<th> Gene ID 
			<th> Ensembl ID
        		<th> Start
        		<th> End
        		<th> Strand
        		<th> Score
		<% } else { %>
        		<th> Gene ID
        		<th> Ensembl ID
        		<th> Chromosome
        		<th> Strand
        		<th> TSS
        		<th> Promoter Start
        		<th> Promoter End
        		<th> TFBS Sequence
        		<th> TFBS Start
        		<th> TFBS Rel. Start
        		<th> TFBS End
        		<th> TFBS Rel. End
        		<th> TFBS Orientation
        		<th> TFBS Score
		<% } %>
		</tr>
<% 	


	//
	// The first line of this file is the column headers, so start reading from the second line
	//
	int i=0;
	while (i<tfbsResults.length && !tfbsResults[i].equals(tf+" associated genes:")) {
		i++;
	}
	log.debug("tf + associated genes found.  tf = "+tf + " i = " + i);
	i++;
	i++;
	//log.debug ("before loop this line = "+tfbsResults[i]);
	while (i < tfbsResults.length && !tfbsResults[i].endsWith("associated genes:") && !tfbsResults[i].equals("")) {

	//log.debug ("this line = "+tfbsResults[i]);
		%> <tr> <%
		String[] lineElements = tfbsResults[i].split("\t");
		for (int j=0; j<lineElements.length; j++) {
				if (j == 0) {
					%> <td><%=ncbiLinkText%><%=lineElements[j]%>"><%=lineElements[j]%> </a> <%
				// 
				// If this is the Ensembl ID column, build a link to the ensembl.org page
				//
				} else if (j == 1) {
					%> <td><%=linkText%><%=lineElements[j]%>'><%=lineElements[j]%></a></td> <%
				} else {
					%> <td> <%=lineElements[j]%> </td> <%
				}
		}
		%> </tr> <%
		i++;
	}
%>
</table>
</div>

<BR>
<BR>
<%@ include file="/web/common/footer.jsp" %>

