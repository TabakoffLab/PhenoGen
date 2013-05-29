<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2006
 *  Description:  The web page created by this file allows the user to create a QTL list.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/qtls/include/qtlHeader.jsp"%>

<%
	log.info("in defineQTL.jsp. user = " + user);
	String fromMainStr="N",fromDialogStr="N";
	boolean fromMain = false;
	if(request.getParameter("fromMain") != null  && request.getParameter("fromDialog").equals("Y")){
		fromMain=true;
		fromMainStr="Y";
	}
	boolean fromDialog = false;
	if(request.getParameter("fromDialog") != null && request.getParameter("fromDialog").equals("Y") ){
		fromDialog=true;
		fromDialogStr="Y";
	}

	extrasList.add("defineQTL.js");

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-005");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

        log.debug("action = "+action+"\nfromDialog:"+fromDialog+"\nfromMain:"+fromMain);

        String phenotype = "";
        String organism = "";

	if ((action != null) && action.equals("Save QTL List")) {
		String nextRowNum = request.getParameter("nextRowNum");
		int numLoci = Integer.parseInt(nextRowNum) + 1;

		if (!((String) request.getParameter("phenotype")).equals("")) {
			phenotype = (String) request.getParameter("phenotype");
		}

		if (!((String) request.getParameter("organism")).equals("")) {
			organism = (String) request.getParameter("organism");
		}

		log.debug("phenotype = "+phenotype);
		myQTL.setQtl_list_name(phenotype);
		myQTL.setOrganism(organism);
		myQTL.setCreated_by_user_id(userID);

		List<QTL.Locus> myLocusList = new ArrayList<QTL.Locus>();

		log.debug("filling Locus array");
		for (int i=0; i<numLoci; i++) {
			QTL.Locus thisLocus = myQTL.new Locus();
			thisLocus.setLocus_name((String) request.getParameter("qtl"+i));
			thisLocus.setChromosome((String) request.getParameter("chromosome"+i));
			thisLocus.setRange_start(Double.parseDouble((String) request.getParameter("rangeStart"+i)));
			thisLocus.setRange_end(Double.parseDouble((String) request.getParameter("rangeEnd"+i)));
			myLocusList.add(thisLocus);
		}
		QTL.Locus[] myLocusArray = myObjectHandler.getAsArray(myLocusList, QTL.Locus.class);

		myQTL.setLoci(myLocusArray);

		log.debug("creating QTL List");
	
		myQTL.createQTLList(myQTL, dbConn);

        	mySessionHandler.createSessionActivity(session.getId(), 
			"Created QTL List called '" + phenotype + "'.  It contains " + myLocusArray.length + " Locus records." ,
                	dbConn);

		//Success - "QTL list saved"
		//session.setAttribute("successMsg", "QTL-003");
		if(!fromDialog){
			response.sendRedirect(qtlsDir + "savedQTL.jsp?name="+phenotype);
		}else{%>
        	<script type="text/javascript">
				alert("QTL List saved successfully.");
			</script>
            
		<%
		response.sendRedirect(geneListsDir+"locationEQTL.jsp?geneListID="+selectedGeneList.getGene_list_id());}
	}	
%>



	<% if (fromMain) { %>
    	<%pageTitle="Create QTL list";%>
		<%@ include file="/web/common/header.jsp" %>
	<% } else { %>
		<%@ include file="/web/common/headTags.jsp" %>
	<% } %>

	<form   method="post"
        	action="<%=qtlsDir%>defineQTL.jsp"
		onSubmit="return IsFormComplete(defineQTL)"
        	enctype="application/x-www-form-urlencoded"
        	name="defineQTL"> 

	  <div class="page-intro">
		Information about phenotypic (behavioral) QTLs can be obtained from <a href="http://www.informatics.jax.org/" target="QTLWindow">MGI</a> (mouse QTLs) or <a href="http://rgd.mcw.edu/" target="QTLWindow">RGD</a> (rat and mouse QTLs).<BR>
		Phenotypic QTL boundaries must be defined in bases.  This information (base positions for markers at the boundaries) can be obtained from any of the public databases -- <a href="http://rgd.mcw.edu/" target="QTLWindow">RGD</a>, <a href="http://www.ncbi.nlm.nih.gov/mapview/" target="QTLWindow">NCBI Map Viewer</a>, or <a href="http://www.ensembl.org/index.html" target="QTLWindow">Ensembl</a>.
	</div>
		
	<div class="brClear"></div>
	<div class="list_container">
	<table width="950px">
		<tr>
		<td style="vertical-align:top">
		<div class="title"> Enter a Phenotype or QTL List Name and then enter one Locus/Region in each row.  </div>
		<table class="list_base" width="580px">
        		<tr>
				<td>
				<table id="QTLTable">
					<tbody id="QTLTableBody">
					<tr>
						<th colspan=2>Phenotype or QTL List Name
						<th colspan=3>Organism
					</tr>
					<tr>
						<td colspan=2> <input type="text" NAME="phenotype" size=40 value="" title="Phenotype Name or QTL List Name"> </td>
						<td colspan=3> 
						<%
						selectName = "organism";
						selectedOption = "";
						onChange = "";

						optionHash = new LinkedHashMap();
						optionHash.put("-99", "-- Select an option --");
						optionHash.putAll(new Organism().getOrganismsAsSelectOptions(dbConn));

						%>
                				<%@ include file="/web/common/selectBox.jsp" %>
						</td>
					</tr>
					<tr>
						<th width="25%">Locus/Region Identifier 
						<th width="45%">Chromosome Number / Name
						<th width="10%">Start bp 
						<th width="10%">End bp
					</tr>
					<tr>
						<td><input type="text" NAME="qtl0" size=15 value="" title="Locus/Region Identifier"> </td>
						<td><input type="text" NAME="chromosome0" size=15 value="" title="Locus/Region Chromosome"> </td>
						<td><input type="text" id="rangeStart0" NAME="rangeStart0" size=10 value="" title="Starting Point for Base Pair Range"> </td>
						<td><input type="text" id="rangeEnd0" NAME="rangeEnd0" size=10 value="" title="Ending Point for Base Pair Range"> </td>
					</tr>
					</tbody>
				</table>
				</td>
		
			</tr>
			<tr><td><a href="javascript:addQTLRow()">Add New Locus/Region</a>
	               		<div id="newQTLDiv"> </div>
			</td></tr>
		</table>
		</td>
		<td><%=fiveSpaces%>
	               <input type="hidden" value="0" name="nextRowNum" id="nextRowNum" />
		</td>
		<td style="vertical-align:top">
		<div class="title"> QTL Work Area</div>
		<table class="list_base">
			<tr>
			<td>
				<textarea name="workArea" rows="15" cols="50">This area can be used as a work area for pasting QTL information gathered from other sources.  The information in this work area will not be saved in the QTL list.
				</textarea>
			</td>
			</tr>
		</table>
		</td>
	</tr>
	</table>
	</div>
	<BR>
	<center>
	<input type="reset" size=3 value="Reset" /><%=tenSpaces%>
	<input type="submit" name="action" value="Save QTL List" />
	</center>
	<input type="hidden" name="fromMain" value="<%=fromMainStr%>">
    <input type="hidden" name="fromDialog" value="<%=fromDialogStr%>">
</form>
	<% if (fromMain) { %>
		<%@ include file="/web/common/footer.jsp" %>
	<% } %>
<script type="text/javascript">
	$(document).ready(function() {
		setTimeout("setupMain()", 100); 
	});
</script>
