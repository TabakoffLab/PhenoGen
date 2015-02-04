<%--
 *  Author: Cheryl Hornbaker
 *  Created: Apr, 2009
 *  Description:  This file displays the help specific to the page the user is 
 *					currently viewing.  Having all re-directs in one file prevents
 *					the need to modify many files if changes to help are necessary.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>



<%
	String fileNameHelpURL = "";
	String currentPage=request.getRequestURL().toString();
	//
	// if currentPage (url) has a query string appended to it, remove it
	//
	if (currentPage != null && currentPage.indexOf("?") != -1) {		
		StringTokenizer tokenizer = new StringTokenizer(currentPage, "?");
		String token = tokenizer.nextToken();
		currentPage = token;
	}						
	
/*****************************************************************************
		MAIN HOME PAGE HELP
*****************************************************************************/						
	/***** Home Page and Main Tab Page *****/
	if (currentPage.endsWith("index.jsp") || currentPage.equals("http://"+host+"/") || currentPage.equals("https://"+host+"/") || currentPage.endsWith("startPage.jsp")) {
			fileNameHelpURL="Phenogen_Overview.htm";

/*****************************************************************************
		MAIN TAB HELP PAGES
*****************************************************************************/						
	/***** Main MicroArray Page *****/
	} else if (currentPage.endsWith("microarrayMain.jsp")) {
			fileNameHelpURL="Analyzing_Microarray_Data.htm";

	/***** Main Research Gene List Page *****/
	} else if (currentPage.endsWith("geneListMain.jsp")) {
			fileNameHelpURL="Research_Gene_Lists.htm";

	/***** Main Investigate QTL Regions Page *****/
	} else if (currentPage.endsWith("qtlMain.jsp")) {
			fileNameHelpURL="Investigating_QTL_Regions.htm";

	
/*****************************************************************************
		ANALYZE MICROARRAY DATA HELP PAGES
*****************************************************************************/						

	/***** Upload Arrays *****/
	} else if (currentPage.endsWith("listExperiments.jsp") ||
		currentPage.endsWith("createExperiment.jsp") ||
		currentPage.endsWith("chooseProtocols.jsp") ||
		currentPage.endsWith("downloadSpreadsheet.jsp") ||
		currentPage.endsWith("uploadSpreadsheet.jsp") ||
		currentPage.endsWith("uploadCELFiles.jsp") ||
		currentPage.endsWith("reviewExperiment.jsp")) {
		fileNameHelpURL="Uploading_Datasets.htm";

	/***** View All Datasets *****/
	} else if (currentPage.endsWith("listDatasets.jsp")) {
		fileNameHelpURL="Viewing_Datasets.htm";

	/***** View Dataset Versions *****/
	} else if (currentPage.endsWith("listDatasetVersions.jsp")) {
		fileNameHelpURL="Group_Normalizing_Datasets.htm";

	/***** Create New Dataset *****/
	} else if (currentPage.endsWith("selectArrays.jsp")) { 
		fileNameHelpURL="creating_datasets.htm";

	/***** Retrieve Arrays *****/
	} else if (currentPage.endsWith("advancedQuery.jsp") || 
		currentPage.endsWith("basicQuery.jsp")) { 
		fileNameHelpURL="Retrieving_Arrays.htm";

	/***** Running Quality Control *****/
	} else if (currentPage.endsWith("qualityControl.jsp")) {
		fileNameHelpURL="Running_a_Quality_Control_Check.htm";

	/***** View Quality Control Results *****/
	/***** Affymetrix QC Results *****/

	} else if (currentPage.endsWith("qualityControlResults.jsp")) {
		if  (currentPage.indexOf("tab=winarray") > 0) {
			fileNameHelpURL="Within-Array_Checks.htm";
		} else if (currentPage.indexOf("tab=model") > 0) {
			fileNameHelpURL="Model-based_Checks.htm";
		} else if (currentPage.indexOf("tab=pseudo") > 0) {
			fileNameHelpURL="Pseudo_Images_Affy.htm";
		} else if (currentPage.indexOf("tab=maplot") > 0) { 
			fileNameHelpURL="MA_Plots.htm";

		/***** CodeLink QC Results *****/
		} else if (currentPage.indexOf("tab=rle") > 0) { 
			fileNameHelpURL="RLE_CodeLink.htm";
		} else if (currentPage.indexOf("tab=cv") > 0) { 
			fileNameHelpURL="Coefficient_of_Variation.htm";
		} else if (currentPage.indexOf("tab=clsoft") > 0) { 
			fileNameHelpURL="CodeLink_Software.htm";

		/***** No Tab Selected *****/
		} else {
			fileNameHelpURL="Quality_Control_Checks.htm";
		}
	
	/***** Data Groups and Normalization *****/
	} else if (currentPage.endsWith("normalize.jsp") || 
			currentPage.endsWith("groupArrays.jsp")) { 
		fileNameHelpURL="Group_Normalizing_Datasets.htm";

	/***** Choose Type of Data Analysis *****/
	} else if (currentPage.endsWith("typeOfAnalysis.jsp")) { 
		fileNameHelpURL="Analyzing_Datasets_Overview.htm";

	/***** Filtering *****/
	} else if (currentPage.endsWith("filters.jsp")) { 
			fileNameHelpURL="Filtering_Overview.htm";

	/***** Statistics  *****/
	} else if (currentPage.endsWith("statistics.jsp")) { 
		/***** Differential Expression *****/
		if (currentPage.indexOf("diffExp") > 0) { 
			fileNameHelpURL="Differential_Expressions_Analysis.htm";
		/***** Correlation *****/
		} else if (currentPage.indexOf("correlation") > 0) { 
			fileNameHelpURL="Correlation_Analysis.htm";
		}

	/***** Multiple Testing *****/
	} else if (currentPage.endsWith("multipleTest.jsp")) { 
			fileNameHelpURL="Multiple_Testing_Adjustment.htm";

	/***** Save Gene List *****/
	} else if (currentPage.endsWith("nameGeneListFromAnalysis.jsp")) { 
			fileNameHelpURL="Filtering_and_Analyzing_Datasets.htm";

	/***** Clustering  *****/
	} else if (currentPage.endsWith("cluster.jsp")) { 
		fileNameHelpURL="Clustering_Analysis.htm";
	}

	/***** View Gene Expression Data *****/
	else if (currentPage.endsWith("geneData.jsp")) {
		fileNameHelpURL="Viewing_Gene_Expression_Data.htm";

	/***** Correlation and Create Phenotype Data *****/
	} else if (currentPage.endsWith("correlation.jsp")) {
		fileNameHelpURL="Using_Phenotype_Data.htm";

	} else if (currentPage.endsWith("createPhenotype.jsp")) {
		fileNameHelpURL="Using_Phenotype_Data.htm";

	 /***** Download Dataset  *****/
	} else if (currentPage.endsWith("downloadDataset.jsp")) {
		fileNameHelpURL="Downloading_a_Dataset.htm";

/*****************************************************************************
			GENE LIST HELP PAGES
*****************************************************************************/						
	/***** View All Gene Lists *****/
	} else if (currentPage.endsWith("listGeneLists.jsp") ||
			currentPage.endsWith("geneList.jsp")) {
		if (currentPage.indexOf("fromQTL=Y") > 0) {
			fileNameHelpURL="Viewing_Location_and_eQTL.htm";
		} else {
			fileNameHelpURL="Viewing_Gene_Lists.htm";
		}

	/*****  Basic Annotation *****/
	} else if (currentPage.endsWith("annotation.jsp") || 
		currentPage.endsWith("advancedAnnotation.jsp") || 
		currentPage.endsWith("iDecoderResults.jsp")) {
		fileNameHelpURL="Annotation_Overview.htm";

	/*****  Location *****/
	} else if (currentPage.endsWith("locationEQTL.jsp")) {
		fileNameHelpURL="Viewing_Location_and_eQTL.htm";

	/***** Promoter *****/
	} else if (currentPage.endsWith("promoter.jsp")) { 
		fileNameHelpURL="Promoter_Analysis_Extraction.htm";

	/***** Homologs *****/
        } else if (currentPage.endsWith("homologs.jsp")) { 
		fileNameHelpURL="Homolog_Overview.htm";

	/***** Analysis Statistics *****/
        } else if (currentPage.endsWith("stats.jsp")) { 
		fileNameHelpURL="Viewing_Analysis_Statistics.htm";

	/***** Pathway *****/
        } else if (currentPage.indexOf("athway") > -1) { 
		fileNameHelpURL="Viewing_Pathways.htm";

	/***** Expression Values *****/
        } else if (currentPage.endsWith("expressionValues.jsp")) { 
		fileNameHelpURL="Viewing_Gene_Expression_Data.htm";

	/***** Save As *****/
        } else if (currentPage.endsWith("saveAs.jsp")) { 
		fileNameHelpURL="Saving_as_Gene_List.htm";

	/***** Sharing *****/
	} else if (currentPage.endsWith("geneListUsers.jsp")) {
		fileNameHelpURL="Sharing_a_Gene_List.htm";

	/***** Compare Gene Lists *****/
	} else if (currentPage.endsWith("compareGeneLists.jsp") || 
		currentPage.endsWith("compareWithOneGeneList.jsp") ||
		currentPage.endsWith("compareWithAllGeneLists.jsp")) {
		fileNameHelpURL="Comparing_Gene_Lists.htm";


/***** Create Gene List *****/ 
	// From Existing Gene List
	} else if (currentPage.endsWith("copyGeneList.jsp")) {
		fileNameHelpURL="Copying_a_Gene_List.htm";
	// By Manually Entering
	} else if (currentPage.endsWith("createGeneList.jsp")) {
		fileNameHelpURL="Creating_a_Gene_List.htm";
/*****  Advanced Annotation *****/
	} else if (currentPage.endsWith("advancedAnnotation.jsp") ||
		currentPage.endsWith("iDecoderResults.jsp")) {
		fileNameHelpURL="Advanced_Annotation.htm";
/*****  // From QTL Analysis *****/
	} else if (currentPage.endsWith("calculateQTLs.jsp") ||
		currentPage.endsWith("runQTLAnalysis.jsp") ||
		currentPage.endsWith("displayQTLResults.jsp")) {
		fileNameHelpURL="Calculating_QTLs_for_Phenotype.htm"; 
        } else if (currentPage.endsWith("eQTLInstructions.jsp")) {
		fileNameHelpURL="eQTL_Explorer.htm";
        } else if (currentPage.endsWith("qtlLists.jsp")) {
		fileNameHelpURL="Viewing_All_QTL_Lists.htm";
        } else if (currentPage.endsWith("qtlQuery.jsp") ||
		currentPage.endsWith("qtlQueryResults.jsp")) {
		fileNameHelpURL="QTL_Query.htm";

/*****  // From Promoter Analysis *****/
	} else if (currentPage.endsWith("meme.jsp")) { 
		fileNameHelpURL="Running_MEME.htm";
	} else if (currentPage.endsWith("promoterExtraction.jsp")) { 
		fileNameHelpURL="Running_Upstream_Sequence_Extraction.htm";
	} else if (currentPage.endsWith("snp.jsp")) { 
		fileNameHelpURL="Retrieving_Genetic_Variation_Data.htm";

/***** Literature Search *****/
	} else if (currentPage.endsWith("litSearch.jsp")) { 
		fileNameHelpURL="Performing_a_Literature_Search.htm";
/***** Gene List Results *****/
	} else if (currentPage.endsWith("results.jsp")) {
		//fileNameHelpURL="Viewing_Interpretation_Results.htm";
		fileNameHelpURL="Viewing_Interpretation_Results_By_Gene_List.htm";
/***** Upload Gene List *****/
	} else if (currentPage.endsWith("uploadGeneList.jsp")) {
		fileNameHelpURL="Uploading_a_Gene_List.htm";
/***** Download Gene List *****/
	} else if (currentPage.endsWith("downloadGeneList.jsp")) {
		fileNameHelpURL="Downloading_a_Gene_List.htm";
/***** Copy Gene List handled above in 'Create Gene List' *****/
/***** Delete Gene List *****/
	} else if (currentPage.endsWith("deleteGeneList.jsp")) {
		fileNameHelpURL="Deleting_a_Gene_List.htm";
/***** Exon Correlation Tab *****/
	} else if (currentPage.contains("exonCorrelationTab.jsp")) {
		fileNameHelpURL="Viewing_Exon_Information.htm";
/*****************************************************************************
		QTL TAB HELP PAGES
*****************************************************************************/						
	/***** Defining QTL *****/
	} else if (currentPage.endsWith("defineQTL.jsp")) {
		fileNameHelpURL="Entering_Phenotypic_QTLs.htm";

	/***** Download Marker *****/
        } else if (currentPage.endsWith("downloadMarker.jsp")) { 
		fileNameHelpURL="Expression_QTL_Derivation.htm";
/*****************************************************************************
		Explore Exon TAB HELP PAGES
*****************************************************************************/						
	/***** Explore Exon Main Page *****/
	 } else if (currentPage.contains("exonMain.jsp")) { 
		fileNameHelpURL="Explore_Exons.htm";
	/***** Exon-Exon correlation *****/
	 } else if (currentPage.contains("exonCorrelationGene.jsp")) { 
		fileNameHelpURL="Viewing_Exon_Information.htm";
	
/*****************************************************************************
		RESOURCES TAB HELP PAGES
*****************************************************************************/						
	/***** Downloading Resources *****/
        } else if (currentPage.endsWith("resources.jsp")) { 
		fileNameHelpURL="DownloadResources.htm";
/*****************************************************************************
		RESULT HELP PAGES
*****************************************************************************/						
/***** View Cluster Analysis Results *****/
	} else if (currentPage.endsWith("allClusterResults.jsp") ||
		currentPage.endsWith("clusterResults.jsp") ||
		currentPage.endsWith("clusterDetails.jsp") ||
		currentPage.endsWith("clusterImages.jsp")) {
		fileNameHelpURL="Viewing_Cluster_Analysis_Results.htm";
	}
/***** View Promoter Results *****/
	else if ((currentPage.endsWith("allAnalysisResults.jsp") &&
			currentPage.indexOf("type=oPOSSUM") > 0) ||
			currentPage.endsWith("promoterResults.jsp") ||
			currentPage.endsWith("targetGenes.jsp")) {
		fileNameHelpURL="Viewing_oPOSSUM_Results.htm";
	}
/***** View MEME Results *****/
	else if ((currentPage.endsWith("allAnalysisResults.jsp") &&
			currentPage.indexOf("type=MEME") > 0) ||
			currentPage.endsWith("memeResults.jsp")) {
		fileNameHelpURL="Viewing_MEME_Results.htm";
	}
/***** View Upstream Extraction Results *****/
	else if ((currentPage.endsWith("allAnalysisResults.jsp") &&
			currentPage.indexOf("type=extraction") > 0) ||
			currentPage.endsWith("upstreamExtractionResults.jsp")) {
		fileNameHelpURL="Viewing_Upstream_Sequence_Extraction_Results.htm";
	}
/***** View Literature Results *****/
	else if ((currentPage.endsWith("allAnalysisResults.jsp") &&
			currentPage.indexOf("type=litSearch") > 0) ||
			currentPage.endsWith("litSearchResults.jsp")) {
		fileNameHelpURL="Viewing_Literature_Search_Results.htm";
	}
	
/*****************************************************************************
		PI HELP PAGES
*****************************************************************************/						
/***** Approving Array Requests *****/
	else if (currentPage.endsWith("approveRequests.jsp")) {
		fileNameHelpURL="Approve_Pending_Requests.htm";
	}
/***** Publish Datasets *****/
	else if (currentPage.endsWith("createMAGEML.jsp")) {
		fileNameHelpURL="Publishing_Experiments.htm";
	}
	else if (currentPage.endsWith("sendMAGEML.jsp")) {
		fileNameHelpURL="Publishing_Experiments.htm";
	}
/***** Grant Array Access *****/
	else if (currentPage.endsWith("publishExperiment.jsp") ||
		currentPage.endsWith("grantArrayAccess.jsp")) {
		fileNameHelpURL="Granting_Array_Access.htm";
	}

/*****************************************************************************
		OTHER HELP PAGES
*****************************************************************************/						
	else if ((currentPage.endsWith("index.jsp")) || 
		(currentPage.endsWith("http://" + host + contextRoot))|| 
		(currentPage.endsWith("https://" + host + contextRoot))) {
		fileNameHelpURL="getting_started_front.htm";
	}	
	else if (currentPage.endsWith("userUpdate.jsp")) {
		fileNameHelpURL="Updating_Your_Profile.htm";
	}
	else if (currentPage.endsWith("registration.jsp")) {
		fileNameHelpURL="Registration.htm";
	}
	
	
	
/****************************************************************************
		Detailed Transcription Information Help Pages
****************************************************************************/
	else if (currentPage.endsWith("gene.jsp")) {
		fileNameHelpURL="Detailed_Transcription_Info.htm";
	}
	

/*****************************************************************************
		ELSE CLAUSE - all pages not listed above go to PhenoGen Overview
*****************************************************************************/							
	else {
		fileNameHelpURL="Phenogen_Overview.htm#Overview";
		//fileNameHelpURL="PhenoGen_Overview_Left.htm#CSHID=Overview.htm|StartTopic=Content%2FOverview.htm|SkinName=PhenoGen";
	}
	//fileNameHelpURL="/helpdocs/Content/" + fileNameHelpURL;
	String helpFileURL=request.getContextPath()+"/helpdocs/PhenoGen_Overview_CSH.htm?filename="+fileNameHelpURL;
	
	log.debug("HELP URL = "+helpFileURL);
	//response.sendRedirect(fileNameHelpURL);
	%><!-- <div align="right"><a href="javascript:window.close()">Close</a></div>--> <%
	%><!--<jsp:include page="<%=fileNameHelpURL%>" flush="true"/>--><%
	%><!-- <center><a href="javascript:window.close()">Close</a></center><BR><BR>--> <%
	 
%>
		
		

