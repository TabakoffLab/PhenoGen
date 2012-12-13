<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>
<jsp:useBean id="myErrorEmail" class="edu.ucdenver.ccp.PhenoGen.web.mail.Email"> </jsp:useBean>

<%


GeneList.Gene[] myGeneArray = (GeneList.Gene[]) session.getAttribute("myGeneArray");
String myOrganism=(String)session.getAttribute("geneListOrganism");
String myTissue="";
String myGene="";
String url=(request.getRequestURL()).toString();
boolean fromGeneList=false;
if(url.contains("exonCorrelationTab.jsp")){
    fromGeneList=true;
}
int selectedInd=0;
Set iDecoderAnswer;


if(request.getParameter("speciesCB")!=null){
	myOrganism=request.getParameter("speciesCB").trim();
}
if(request.getParameter("tissueCB")!=null){
	myTissue=request.getParameter("tissueCB").trim();
}

if ((action != null) && action.equals("Get Exon Correlations")) {
	if(myGeneArray!=null){
		selectedInd=Integer.parseInt(request.getParameter("geneCB").trim());
		myGene=myGeneArray[selectedInd].getGene_id();
	}else{
		myGene=request.getParameter("geneTxt").trim();
	}
	
	myIDecoderClient.setNum_iterations(1);
	iDecoderAnswer = myIDecoderClient.getIdentifiersByInputIDAndTarget(myGene,myOrganism, new String[] {"Ensembl ID"},dbConn);
	myIDecoderClient.setNum_iterations(0);
	session.setAttribute("iDecoderAnswer", iDecoderAnswer);
	session.setAttribute("exonCorGeneFile",null);
	session.setAttribute("exonCorHeatFile",null);
}else{
	session.setAttribute("exonCorGeneFile",null);
	session.setAttribute("exonCorHeatFile",null);
	session.setAttribute("iDecoderAnswer",null);
}
ArrayList<String> myCBGeneList=new ArrayList<String>();
if(myGeneArray!=null){
    for (int i=0; i<myGeneArray.length; i++) {
            Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(myGeneArray[i].getGene_id(), iDecoderSet); 
            if (thisIdentifier != null) {
                    Set geneSymbols = myIDecoderClient.getIdentifiersForTargetForOneID(thisIdentifier.getTargetHashMap(), 
                                                                                    new String[] {"Gene Symbol"});
                    if (geneSymbols != null && geneSymbols.size() > 0) {
                            int j=0;
                            String tmp="";
                for (Iterator symbolItr = geneSymbols.iterator(); symbolItr.hasNext();j++) { 
                    Identifier symbol = (Identifier) symbolItr.next();
                                    if(j>0){
                            tmp=tmp+","+symbol.getIdentifier();
                                    }else{
                        tmp=symbol.getIdentifier();
                                    }
                            }
                            myCBGeneList.add(tmp);
                    } else { 
                            myCBGeneList.add(myGeneArray[i].getGene_id());
                    } 
            }   	
    }
}
%>




<% if(myGeneArray!=null&&myCBGeneList.size()>0&&fromGeneList||!fromGeneList){%>
<form method="post" 
		action="<%=formName%>"
		enctype="application/x-www-form-urlencoded"
		name="exonCor">
  <%if(myGeneArray!=null){%>
	<label>Gene:*
  	<select name="geneCB" id="geneCB">
		<% for (int i=0;i<myCBGeneList.size();i++){ %>
        	<option value="<%=i%>"  <%if(i==selectedInd){%>selected<%}%>>
								<%=myCBGeneList.get(i)%>
                                </option>
        <% } %>
    </select>
  	</label>*
	<%} else{%>
    	<label>Gene:
  		<input type="text" name="geneTxt" id="geneTxt" value="<%=myGene%>">
  		</label>
	<% }%>
  <label>Species:
  <select name="speciesCB" id="speciesCB" onchange="show_species_tissue(this.selectedIndex)">
  	<option value="Mm" <%if(myOrganism!=null && myOrganism.equals("Mm")){%>selected<%}%>>Mus musculus</option>
    <option value="Rn" <%if(myOrganism!=null && myOrganism.equals("Rn")){%>selected<%}%>>Rattus norvegicus</option>
  </select>
  </label>
  <label>Tissue:
  <select name="tissueCB" id="tissueCB">
  	<option value="Brain" <%if(myTissue!=null && myTissue.equals("Brain")){%>selected<%}%> >Whole Brain</option>
    <% if(myOrganism!=null&&myOrganism.equals("Rn")){ %>
    <option value="Heart" <%if(myTissue!=null && myTissue.equals("Heart")){%>selected<%}%> >Heart</option>
    <option value="Liver" <%if(myTissue!=null && myTissue.equals("Liver")){%>selected<%}%> >Liver</option>
    <option value="BAT" <%if(myTissue!=null && myTissue.equals("BAT")){%>selected<%}%> >Brown Adipose</option>
    <% } %>
  </select>
  </label>
<!--<input type="hidden" name="duration" id="duration" value="120">-->

 <span style="padding-left:40px;"> <input type="submit" name="action" id="refreshBTN" value="Get Exon Correlations" onClick="return displayWorking()"></span>
  
  
</form>


<%if(myGeneArray!=null){%>
<BR />
*Note:Some genes maybe missing from the list of available genes. IDs that are missing could not be converted to an Ensembl ID needed to retrieve transcripts.
<%}%>
<%}else if(myGeneArray==null&&fromGeneList){%>
	<B>Error:This gene list is missing any identifiers that can be linked to Ensembl IDs.  Please report the gene list and the type of identifiers in the gene list to the administrator.  It is possible a new identifier data source is needed to link the IDs to Ensembl IDs. Sorry for any inconvenience.</B>
    <%
			myErrorEmail.setSubject("User '"+ userLoggedIn.getUser_name() + 
			"' encountered system error 'No Ensembl IDs in Gene List' on PhenoGen website");
            myErrorEmail.setContent("This gene list(ID#"+selectedGeneList.getGene_list_id()+") is missing any identifiers that can be linked to Ensembl IDs.  Please report the type of identifiers in the gene list to the administrator.  An email has already been sent alerting the administrator to the problem.  It is possible a new identifier data source is needed to link the IDs to Ensembl IDs. Sorry for any inconvenience.");
            try {
                        	myErrorEmail.sendEmailToAdministrator(adminEmail);
                        } catch (Exception error) {
                                log.error("exception while trying to send message to phenogen.help about jackson lab connection", error);
                        }
    %>
    
<%}%>


