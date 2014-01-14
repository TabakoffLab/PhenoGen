<%@ include file="/web/access/include/login_vars.jsp" %>

        
<%

	String url=request.getParameter("menuURL").trim();
	String mainMenu="";
	String specMenuOpt=url.substring(url.lastIndexOf("/")+1);
	String mainFunc="";
	String mainFuncStep="";
	
	//SET Selected Menu and Selected Function based on menu choice.
	
	if(url.equals(contextRoot+"index.jsp")||
		url.equals(commonDir+"ovrvw_transcript_details.jsp") ||
		url.equals(commonDir+"ovrvw_whats_new.jsp") ||
		url.equals(commonDir+"ovrvw_downloads.jsp") ||
		url.equals(commonDir+"ovrvw_microarray_tools.jsp") ||
		url.equals(commonDir+"ovrvw_genelist_tools.jsp") ||
		url.equals(commonDir+"ovrvw_qtl_tools.jsp")
	){
		mainMenu="overview";
		
	}else if(url.equals(contextRoot+"gene.jsp")){
		mainMenu="transcript";
		mainFunc="Genome/Transcriptome Data Browser";
	}else if(url.equals(accessDir+"createAnnonymousSession.jsp?url="+sysBioDir+"resources.jsp")){
		mainMenu="download";
		mainFunc="Downloads";
	}else if(url.equals(accessDir+"checkLogin.jsp?url="+datasetsDir+"listDatasets.jsp")||
		url.equals(accessDir+"checkLogin.jsp?url="+experimentsDir+"listExperiments.jsp") ||
		url.equals(accessDir+"checkLogin.jsp?url="+datasetsDir+"basicQuery.jsp") ||
		url.equals(accessDir+"checkLogin.jsp?url="+datasetsDir+"geneData.jsp")
	){
		mainMenu="microarray";
		if(specMenuOpt.equals("listDatasets.jsp")){
			mainFunc="Analyze Dataset";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("listExperiments.jsp")){
			mainFunc="Upload Arrays";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("basicQuery.jsp")){
			mainFunc="Create a Dataset";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("geneData.jsp")){
			mainFunc="View Expression Data";
			//mainFuncStep="Step 1 of ?";
		}
	}else if(url.equals(accessDir+"checkLogin.jsp?url="+geneListsDir+"listGeneLists.jsp")||
		url.equals(accessDir+"checkLogin.jsp?url="+geneListsDir+"createGeneList.jsp?fromMain=Y")||
		url.equals(accessDir+"checkLogin.jsp?url="+datasetsDir+"listDatasets.jsp?")
	){
		mainMenu="genelist";
		if(specMenuOpt.equals("listGeneLists.jsp")){
			mainFunc="Analyze a Gene List";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("createGeneList.jsp?fromMain=Y")){
			mainFunc="Upload or enter a Gene List";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("listDatasets.jsp?")){
			mainFunc="Derive a Gene List from Array Analysis ";
			//mainFuncStep="Step 1 of ?";
		}
	}else if(url.equals(accessDir+"checkLogin.jsp?url="+qtlsDir+"defineQTL.jsp?fromMain=Y")||
		url.equals(accessDir+"checkLogin.jsp?url="+qtlsDir+"calculateQTLs.jsp")||
		url.equals(accessDir+"checkLogin.jsp?url="+qtlsDir+"downloadMarker.jsp")||
		url.equals(accessDir+"checkLogin.jsp?url="+geneListsDir+"listGeneLists.jsp?fromQTL=Y")
	){
		mainMenu="qtl";
		if(specMenuOpt.equals("defineQTL.jsp?fromMain=Y")){
			mainFunc="Create a QTL list";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("calculateQTLs.jsp")){
			mainFunc="Calculate QTLs for a Phenotype";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("downloadMarker.jsp")){
			mainFunc="Download Marker Files";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("listGeneLists.jsp?fromQTL=Y")){
			mainFunc="View eQTL information<BR>Click the location tab after selecting a gene list.";
			//mainFuncStep="Step 1 of ?";
		}
	}else if(url.equals(contextRoot+"CurrentDataSets.jsp")||
		url.equals(commonDir+"publications.jsp") ||
		url.equals(commonDir+"siteVersion.jsp") ||
		url.equals(commonDir+"citation.jsp") ||
		url.equals(commonDir+"usefulLinks.jsp") ||
		url.equals("https://github.com/TabakoffLab/PhenoGen")
	){
		mainMenu="about";
		if(specMenuOpt.equals("CurrentDataSets.jsp")){
			mainFunc="Current Dataset";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("publications.jsp")){
			mainFunc="Publications";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("siteVersion.jsp")){
			mainFunc="Software Version Information";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("citation.jsp")){
			mainFunc="Citation Information";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("usefulLinks.jsp")){
			mainFunc="Useful Links";
			//mainFuncStep="Step 1 of ?";
		}
		
	}else if(url.equals(commonDir+"siteRequirements.jsp")||
		url.equals(commonDir+"contact.jsp")
	){
		mainMenu="help";
		if(specMenuOpt.equals("siteRequirements.jsp")){
			mainFunc="Browser/Software Requirements";
			//mainFuncStep="Step 1 of ?";
		}else if(specMenuOpt.equals("contact.jsp")){
			mainFunc="Contact Us";
			//mainFuncStep="Step 1 of ?";
		}
	}
	
	if(url.contains("/helpdocs/")){
		url=url.replace("?filename=","#");
	}
	session.setAttribute("mainMenuSelected",mainMenu);
	session.setAttribute("mainFunction",mainFunc);
	session.setAttribute("mainFunctionStep",mainFuncStep);
	//log.debug("URL:"+url+"\nMenu Selected:"+mainMenu+"->"+specMenuOpt);
	try{
		mySessionHandler.createSessionActivity(session.getId(), "Selected Menu option "+mainMenu+"->"+specMenuOpt, dbConn);
	}catch(Exception e){
		
	}
    response.sendRedirect(url);           
	
%>

