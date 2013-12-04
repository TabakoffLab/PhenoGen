
<%@ include file="/web/common/session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<%
	
    gdt.setSession(session);
	
	DecimalFormat dfC = new DecimalFormat("#,###");
	String myOrganism="";
	String id="";
	LinkGenerator lg=new LinkGenerator(session);
	

	if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species").trim();
	}

	if(request.getParameter("id")!=null){
		id=request.getParameter("id");
	}
%>

<style>
	.bQTLListToolTip{
		font-weight:600;
	}
	table.report tr td{
		padding-top:10px;
	}
	table.report tr td.lessPad{
		padding-top:2px;
	}
</style>

<div id="bQTLReport"  style="border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:100%; text-align:left;">
	
	


	<% BQTL bqtls=gdt.getBQTL(id);
	if(session.getAttribute("getBQTLERROR")==null){
		if(bqtls!=null){
	%>
    <table class="report" style="width:100%;">
    <TR><TD colspan="3"  style="text-align:center;">
    	<H3><%=bqtls.getName()%></H3> 
    	(<a href="<%=lg.getRegionLink(bqtls.getChromosome(),bqtls.getStart(),bqtls.getStop(),myOrganism,true,true,false)%>" target="_blank">chr<%=bqtls.getChromosome()+":"+dfC.format(bqtls.getStart())+"-"+dfC.format(bqtls.getStop())%></a>)
    </TD>
    	
    </TR>
    <TR>
    	<%if(myOrganism.equals("Mm")){%>
                <TD style="min-width:33%;"><span class="bQTLListToolTip">MGI ID:</span> <a href="<%=LinkGenerator.getMGIQTLLink(bqtls.getMGIID())%>" target="_blank"> <%=bqtls.getMGIID()%></a> </TD>
       	<%}%>
      	<TD ><span class="bQTLListToolTip">RGD ID:</span> <a href="<%=LinkGenerator.getRGDQTLLink(bqtls.getRGDID())%>" target="_blank"> <%=bqtls.getRGDID()%></a></TD>
    	<TD ><span class="bQTLListToolTip" title="bQTL Symbol assigned by the databases."><img src="<%=imagesDir%>icons/info.gif"> QTL Symbol:</span> <%=bqtls.getSymbol()%></TD>
        <%if(!myOrganism.equals("Mm")){%>
         <TD ></TD>
         <%}%>
    </TR>
    <TR>
    <TD>
    	<span class="bQTLListToolTip" title="The LOD Score associated with this bQTL if available. bQTLs from RGD and MGI do not always have the LOD Score."><img src="<%=imagesDir%>icons/info.gif">LOD Score:</span>
    <%if(bqtls.getLOD()==0){%>
                        	Not Available
						<%}else{%>
							<%=bqtls.getLOD()%>
                        <%}%>
    </TD>
    <TD>
    <span class="bQTLListToolTip" title="The p-value associated with this bQTL if available.  bQTLs from RGD and MGI do not always have the p-value."><img src="<%=imagesDir%>icons/info.gif">P-value:</span>
    <%if(bqtls.getPValue()==0){%>
                        	Not Available
						<%}else{%>
							<%=bqtls.getPValue()%>
                        <%}%>
    </TD>
    <TD>
    	<span class="bQTLListToolTip" title="The method used to determine the bQTL region."><img src="<%=imagesDir%>icons/info.gif">Region Determination Method:</span>
    <%String tmpMM=bqtls.getMapMethod();
                        if(tmpMM!=null){
                        	if(tmpMM.indexOf("by")>0){
                            	tmpMM=tmpMM.substring(tmpMM.indexOf("by"));
                            }%>
							<%=tmpMM%>
                        <%}%>
    </TD>
    </TR>
    <TR>
    <TD colspan="3">
    	<span class="bQTLListToolTip" title="A longer description of the phenotype associated with the bQTL."><img src="<%=imagesDir%>icons/info.gif">Phenotype:</span><BR />
		<%if(bqtls.getPhenotype()!=null){%>
							<%=bqtls.getPhenotype()%>
        <%}%>
        </TD>
    </TR>
    <TR>
    <TD >
    	<span class="bQTLListToolTip" title="A breif description of the phenotype."><img src="<%=imagesDir%>icons/info.gif">Trait:</span><BR />
         				<%=bqtls.getTrait()%>
						<%if(bqtls.getSubTrait()!=null && !bqtls.getSubTrait().equals("null")){%>
							<%=" - "+bqtls.getSubTrait()%>
                        <%}%>
     </TD>
     </TR>
     <TR>
     <TD colspan="2" style="max-width:50%;">
   		<span class="bQTLListToolTip" title="The method used to quantify the trait."><img src="<%=imagesDir%>icons/info.gif">Trait Method:</span> <%if(bqtls.getTraitMethod()!=null && !bqtls.getTraitMethod().equals("")){%><BR />
                        	<%=bqtls.getTraitMethod()%>
                        <%}%>
    </TD>
    </TR>
    <TR><TD>
    	<span class="bQTLListToolTip" title="Any diseases associated with the database."><img src="<%=imagesDir%>icons/info.gif">Associated Diseases:</span> <BR /><%if(bqtls.getDiseases()!=null){%>
							<%=bqtls.getDiseases().replaceAll(";","<BR>")%>
                        <%}%>
    </TD>
    </TR>
    <TR><TD>
    	<span class="bQTLListToolTip" title="References for the bQTL with links to the appropriate database."><img src="<%=imagesDir%>icons/info.gif">References:</span> 
    </TD>
    </TR>
    <TR>
    	<TD class="lessPad">Pubmed:</TD>
    	<TD class="lessPad">RGD</TD>
    </TR>
    <TR>
    	<TD class="lessPad">
        	<%	ArrayList<String> ref2=bqtls.getPubmedRef();
						 if(ref2!=null){
							for(int j=0;j<ref2.size();j++){%>
								
                                <a href="<%=LinkGenerator.getPubmedRefLink(ref2.get(j))%>" target="_blank"><%=ref2.get(j)%></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <%}
						}%>
        </TD>
    	<TD class="lessPad">
    	 <%	ArrayList<String> ref1=bqtls.getRGDRef();
							if(ref1!=null){
							for(int j=0;j<ref1.size();j++){%>
								
                                <a href="<%=LinkGenerator.getRGDRefLink(ref1.get(j))%>" target="_blank"><%=ref1.get(j)%></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        	<%}
							}%>
    	</TD>
    </TR>
    <TR><TD>
    <span class="bQTLListToolTip" title="Candidate Genes in the bQTL region as noted by RGD.  The link will open a Detailed Transcription Information page on PhenoGen for the gene."><img src="<%=imagesDir%>icons/info.gif">Candidate Genes:</span><BR />
    <%	ArrayList<String> candidates=bqtls.getCandidateGene();
							if(candidates!=null){
							for(int j=0;j<candidates.size();j++){%>
                            	<a href="<%=lg.getGeneLink(candidates.get(j),myOrganism,true,true,false)%>" target="_blank" title="View Detailed Transcription Information for gene."><%=candidates.get(j)%></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        	<%}
							}%>
    </TD>
    </TR>
    <TR><TD>
    <span class="bQTLListToolTip" title="Any additional bQTLs RGD has found to be associated with this bQTL.  The link will open that region on PhenoGen."><img src="<%=imagesDir%>icons/info.gif">Related bQTL Symbols:</span><BR />
    <%	ArrayList<String> relQTL=bqtls.getRelatedQTL();
								//ArrayList<String> relQTLreason=bqtls.getRelatedQTLReason();
							if(relQTL!=null){
							for(int j=0;j<relQTL.size();j++){
								String regionQTL=gdt.getBQTLRegionFromSymbol(relQTL.get(j),myOrganism,dbConn);
                            	if(regionQTL.startsWith("chr")){
								%>
                                    <a href="<%=lg.getGeneLink(regionQTL,myOrganism,true,true,false)%>" target="_blank" title="Click to view this bQTL region in a new window.">
                                    <%=relQTL.get(j)%>
                                    </a>
                                <%}else{%>
                                	<%=relQTL.get(j)%>
                                <%}%>
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        	<%}
							}%>
    </TD>
    </TR>
    
   
    </table>
                   
    <%}else{%>
    	No bQTLs found in region.
    <%}%>
    <%}else{%>
    	<%=session.getAttribute("getBQTLsERROR")%>
    <%}%>
</div><!-- end bQTL List-->




