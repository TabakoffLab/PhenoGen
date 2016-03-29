<%@ include file="/web/geneLists/include/geneListHeader.jsp"%>

<%
	request.setAttribute( "selectedTabId", "list" );
	extrasList.add("geneList.js");
	extrasList.add("jquery.dataTables.1.10.9.min.js");
	extrasList.add("dataTables.paging.css");
        //extrasList.add("jquery.dataTables.min.css");
	
        log.debug("before getGenesAsArray");
        
	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");
	optionsListModal.add("download");
        
        if(userLoggedIn.getUser_name().equals("anon")){
            optionsListModal.add("linkEmail");
        }
        
	GeneList.Gene[] myGeneArray = selectedGeneList.getGenesAsGeneArray(pool);
	session.setAttribute("geneListOrganism",selectedGeneList.getOrganism());
	log.debug("geneListOrganism="+selectedGeneList.getOrganism());
        //log.debug("iDecoderSet = "); myDebugger.print(iDecoderSet);
        
       	if ((action != null) && action.equals("Download")) {
			log.debug("action is Download");
			mySessionHandler.createGeneListActivity("Downloaded Gene List", pool);
			String fileName = userLoggedIn.getUserGeneListsDir() + "downloads/" + selectedGeneList.getGene_list_name() + "Gene_List_Contents.csv";
			try{
				BufferedWriter outF=new BufferedWriter(new FileWriter(new File(fileName)));
				for (int i=0; i<myGeneArray.length; i++) {
					Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(myGeneArray[i].getGene_id(), iDecoderSet); 			
					if (thisIdentifier != null) {
						myIDecoderClient.setNum_iterations(3);
						Set geneSymbols = myIDecoderClient.getIdentifiersForTargetForOneID(thisIdentifier.getTargetHashMap(), 
												new String[] {"Gene Symbol"});
						if (geneSymbols.size() > 0) { 						
							for (Iterator symbolItr = geneSymbols.iterator(); symbolItr.hasNext();) { 
								Identifier symbol = (Identifier) symbolItr.next();                					
								outF.write(myGeneArray[i].getGene_id() + "," + symbol.getIdentifier() + "\r\n");
							}
						} else {
							outF.write(myGeneArray[i].getGene_id() + "\r\n");
						} 
					}                       
				}
				outF.flush();
				outF.close();
				
				//myFileHandler.writeFile(output, fileName);
				request.setAttribute("fullFileName", fileName);
				myFileHandler.downloadFile(request, response);
				// This is required to avoid the getOutputStream() has already been called for this response error
				out.clear();
				out = pageContext.pushBody(); 
		//		response.sendRedirect(geneListsDir + "downloadGeneListInCSV.jsp?geneName=" + selectedGeneList.getGene_list_name());
			}catch(IOException e){
				log.error("Error writing genelist download file.",e);
				String fullerrmsg=e.getMessage();
						StackTraceElement[] tmpEx=e.getStackTrace();
						for(int i=0;i<tmpEx.length;i++){
							fullerrmsg=fullerrmsg+"\n"+tmpEx[i];
						}
				Email myAdminEmail = new Email();
					myAdminEmail.setSubject("IOException thrown in geneList.jsp");
					myAdminEmail.setContent("There was an error writing to the download file.\n\nFull Stacktrace:\n"+fullerrmsg);
					try {
						myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
					} catch (Exception mailException) {
						log.error("error sending message", mailException);
						throw new RuntimeException();
					}
			}
		}
        mySessionHandler.createGeneListActivity("Viewed geneList contents", pool);
%>

<%@ include file="/web/common/header_adaptive_menu.jsp" %>

<style>
	.rightControl{
		position:relative;
		float:right;
		top:5px;
	}
	.rightControlb{
		float:right;
		position:relative;
		top:15px;
	}
</style>

<%@ include file="/web/geneLists/include/viewingPane.jsp" %>
        <div class="page-intro">
                <p> This page contains the identifiers and their symbols for the genes in your list.
                </p>
        </div> <!-- // end page-intro -->

<%@ include file="/web/geneLists/include/geneListToolsTabs.jsp" %>
	<form 	method="POST"
		name="geneList"
		action="geneList.jsp"
		enctype="application/x-www-form-urlencoded">
	<div class="dataContainer" style="padding-bottom:70px;">
		<div class="title">  Gene List Contents </div>

		<table name="items" id="list" class="list_base" cellpadding="0" cellspacing="3" width="100%">			 
			<thead>
			<tr class="col_title">
				<th > ID in Gene List </th>
				<th> GeneSymbol</th>
			</tr>
			</thead>
			<tbody>
			<%
					myIDecoderClient.setNum_iterations(2);
	                session.setAttribute("myGeneArray", myGeneArray);
                	for (int i=0; i<myGeneArray.length; i++) {
				%>
                        	<tr><td><%=myGeneArray[i].getGene_id()%></td><%
							Identifier thisIdentifier = myIdentifier.getIdentifierFromSet(myGeneArray[i].getGene_id(), iDecoderSet);
							if(thisIdentifier ==null){
								thisIdentifier = myIdentifier.getIdentifierFromSetIgnoreCase(myGeneArray[i].getGene_id(), iDecoderSet);
							}
							if (thisIdentifier != null) {
								Set geneSymbols = myIDecoderClient.getIdentifiersForTargetForOneID(thisIdentifier.getTargetHashMap(),new String[] {"Gene Symbol"});
								/*if(geneSymbols == null ||  geneSymbols.size()== 0){
									geneSymbols = myIDecoderClient.getIdentifiersForTargetForOneIDIgnoreCase(thisIdentifier.getTargetHashMap(),new String[] {"Gene Symbol"});
								}*/
								if (geneSymbols != null && geneSymbols.size() > 0) { 
									%><td><%
											for (Iterator symbolItr = geneSymbols.iterator(); symbolItr.hasNext();) { 
												Identifier symbol = (Identifier) symbolItr.next();
												%><a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=symbol.getIdentifier()%>&speciesCB=<%=selectedGeneList.getOrganism()%>&auto=Y&newWindow=Y" target="_blank"><%=symbol.getIdentifier()%></a><BR><%
									}
									%></td><% 
								} else { 
									//log.debug("no gene symbols");	
									%><td>&nbsp; </td><% 
								} 
							} else {
								%><td>&nbsp; </td><%
							} 
                       	%></tr><%
                	}
					myIDecoderClient.setNum_iterations(1);
			%> 
			</tbody>
		</table> 
		<input type="hidden" name="action" value="">
		<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>"/>
	</form>
	</div>
	<div class="brClear"> </div>
	<script type="text/javascript">
		var geneListLen=<%=myGeneArray.length%>;
		var defaultLen=100;
		var geneListdt;
		var optionArr=[[10,25,50,100,250,500,-1],[10,25,50,100,250,500,"All"]];
		var format='<"leftSearch"Tfri><l><"rightControl"p><t><i><"rightControlb"p>';
		$(document).ready(function() {
			setupPage();
			setTimeout("setupMain()", 100); 
			
			if(geneListLen<=10){
				format='<"leftSearch"Tfri><t>';
			}else if(geneListLen<=100){
				format='<"leftSearch"Tfri><l><"rightControl"p><t>';
			}
			
			if(geneListLen<=10){
				defaultLen=-1;
				optionArr=[[-1],["All"]];
			}else if (geneListLen<=25){
				defaultLen=-1;
				optionArr=[[10,-1],[10,"All"]];
			}else if (geneListLen<=50){
				defaultLen=-1;
				optionArr=[[10,25,-1],[10,25,"All"]];
			}else if (geneListLen<=100){
				defaultLen=-1;
				optionArr=[[10,25,50,-1],[10,25,50,"All"]];
			}else if (geneListLen<=250){
				optionArr=[[10,25,50,100,-1],[10,25,50,100,"All"]];
			}else if (geneListLen<=500){
				optionArr=[[10,25,50,100,250,-1],[10,25,50,100,250,"All"]];
			}
			
			geneListdt=$("table#list").dataTable({
					"bPaginate": true,
					"bProcessing": true,
					"bStateSave": false,
					"bAutoWidth": true,
					"aLengthMenu": optionArr,
					"iDisplayLength": defaultLen,
					"sPaginationType": "full_numbers",
					//"sScrollX": "950px",
					//"sScrollY": "550px",
					"aaSorting": [[ 0, "asc" ]],
					/*"aoColumnDefs": [
      						{ "bVisible": false, "aTargets": hideFirst }
    					],*/
					"sDom": format/*,
					"oTableTools": {
							"sSwfPath": "/css/swf/copy_csv_xls.swf",
							"aButtons": [ "csv", "xls","copy"]
							}*/
	
			});
			
		});
	</script>

<%@ include file="/web/common/footer_adaptive.jsp" %>
