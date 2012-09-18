<%--
 *  Author: Cheryl Hornbaker
 *  Created: January, 2007
 *  Description:  This file formats the results obtained from a call to iDecoder for homologs.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%
	String homologText = "<a href=\"http://view.ncbi.nlm.nih.gov/homologene/"; 

	String entrezText = "<a href=\"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?"+
				"db=gene&amp;cmd=Retrieve&amp;dopt=full_report&amp;list_uids="; 

%>
	<div class="title"> Homologs</div>
      	<table class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
		<thead>
		<tr class="col_title">
			<th>Gene Identifier</th>
			<th>HomoloGene ID
                        	<span class="info" title="Link to NCBI's HomoloGene website for the gene">
                        	<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        	</span>
			</th>
			<th>Gene Symbol</th> 
			<th>Species -- Identifier -- Chromosome:Location
                        	<span class="info" title="The homolog species and identifier link to NCBI's Entrez Gene website for the gene">
                        	<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        	</span>
			</th>
		</tr>
		</thead>
		<tbody>
<% 	
        //
        // Turn the iDecoderAnswer into a List of Identifiers
        //
        List myIdentifierList = Arrays.asList(iDecoderAnswer.toArray((Identifier[]) new Identifier[iDecoderAnswer.size()]));
        myIdentifierList = new Identifier().sortIdentifiers(myIdentifierList, "identifier");
        Iterator sortedIterator = myIdentifierList.iterator();
	while (sortedIterator.hasNext()) {
		Identifier thisIdentifier = (Identifier) sortedIterator.next();

		HashMap linksHash = thisIdentifier.getTargetHashMap();

		Set homologSet = myIDecoderClient.getIdentifiersForTargetForOneID(linksHash, homologTargets);
		Set entrezSet = myIDecoderClient.getIdentifiersForTargetForOneID(linksHash, entrezTargets);
		Set symbolSet = myIDecoderClient.getIdentifiersForTargetForOneID(linksHash, geneSymbolTargets);
		List homologList = myObjectHandler.getAsList(homologSet);
		List entrezList = myObjectHandler.getAsList(entrezSet);
		List symbolList = myObjectHandler.getAsList(symbolSet);
		List sortedSymbols= new Identifier().sortIdentifiers(symbolList, "organism");
		List sortedEntrez= new Identifier().sortIdentifiers(entrezList, "organism");

//		log.debug("thisIdentifier.getIdentifier() = " + thisIdentifier.getIdentifier() + ", linksHash = "); myDebugger.print(linksHash);

%>
		<tr>
		<td> <%=thisIdentifier.getIdentifier()%> </td>
		<%
		if (homologList != null) {
			%><td><%
                               for (int i=0; i< homologList.size(); i++) {
				Identifier homologIdentifier = (Identifier) homologList.get(i);
                                       %><%=homologText%><%=homologIdentifier.getIdentifier()%>" target="Entrez Window"> 
				<%=homologIdentifier.getIdentifier()%> </a> <BR>
			<% } %> </td>
		<% }
		if (sortedSymbols != null) {
			%><td><%
                               for (int i=0; i< sortedSymbols.size(); i++) {
				Identifier symbolIdentifier = (Identifier) sortedSymbols.get(i);
				%><%=symbolIdentifier.getOrganism()%> -- <%=symbolIdentifier.getIdentifier()%> <BR>
			<% } %> </td>
		<% }
		if (sortedEntrez != null) {
			%><td><%
                               for (int i=0; i< sortedEntrez.size(); i++) {
				Identifier entrezIdentifier = (Identifier) sortedEntrez.get(i);
                                       %><%=entrezText%><%=entrezIdentifier.getIdentifier()%>" target="Entrez Window"> 
				<%=entrezIdentifier.getOrganism()%> -- <%=entrezIdentifier.getIdentifier()%> </a> --
				<% 
				if (entrezIdentifier.getChromosome() == null) { 
					%>Chromosome Unknown:<%
				} else { 
					%><%=entrezIdentifier.getChromosome()%>:<%
				} 
				if (entrezIdentifier.getMapLocation() == null) { 
					%>Location Unknown<%
				} else { 
					%><%=entrezIdentifier.getMapLocation()%><%
				}
				%><BR>
			<% } %> </td>
		<% }
		%>
		</tr> 
		<%
	}	

	//
	// print at the bottom of the page all the identifiers that were not found by iDecoder
	//
	if (noHomologList != null && noHomologList.size() > 0) {
		//Collections.sort(noHomologList);
        	%><tr><td colspan=4><hr class=annotation></td></tr><%
		for (int i=0; i< noHomologList.size(); i++) {
			%>
			<tr>
			<td> <%=(String) noHomologList.get(i)%> </td>
			<td> Not Available </td>
			<td> Not Available </td>
			<td> Not Available </td>
			</tr>
		<% 
		}
	}

%> 

</tbody>
</table>
	

