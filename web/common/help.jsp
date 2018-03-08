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

<%@ include file="/web/access/include/login_vars.jsp" %>

<%
	String topic = (request.getParameter("topic") != null ? (String) request.getParameter("topic"):"");
	String fileName = "";
	String entireCaller = caller;
	//
	// if caller (url) has a query string appended to it, remove it
	//
	if (caller != null && caller.indexOf("?") != -1) {		
		StringTokenizer tokenizer = new StringTokenizer(caller, "?");
		String token = tokenizer.nextToken();
		caller = token;
	}						
	log.debug("caller = " + caller);
	log.debug("host = " + host);
	if (loggedIn) {
		mySessionHandler.createSessionActivity(session.getId(), 
                	"Clicked help on this page for "+entireCaller + ", topic = " + topic,
			pool);
	} else {
		mySessionHandler.createSessionActivity("-99", 
                        request.getRemoteAddr() + " " +  
                	"clicked help on this page for "+entireCaller + ", topic = " + topic,
			pool);
	}
/*****************************************************************************
		MAIN HOME PAGE HELP
*****************************************************************************/						
	/***** Home Page and Main Tab Page *****/
	if (caller.endsWith("index.jsp") || caller.equals("http://"+host+"/")||caller.equals("https://"+host+"/") || caller.endsWith("startPage.jsp")) {
		if (topic.equals("DYK1")) {
			fileName="DYK_Home1.htm";
		} else if (topic.equals("DYK2")) {
			fileName="Annotation_Overview.htm";
		} else if (topic.equals("DYK3")) {
			fileName="DYK_Home2.htm";
		} else if (topic.equals("DYK4")) {
			fileName="Sharing_a_Gene_List.htm";
		} else if (topic.equals("DYK5")) {
			fileName="Creating_a_Gene_List.htm";
		} else if (topic.equals("HDI1")) {
			fileName="Performing_Annotation.htm";
		} else if (topic.equals("HDI2")) {
			fileName="HDI_Home1.htm";
		} else if (topic.equals("HDI3")) {
			fileName="Uploading_Datasets.htm";
		} else if (topic.equals("HDI4")) {
			fileName="HDI_Home2.htm";
		} else if (topic.equals("HDI5")) {
			fileName="HDI_Home3.htm";
		} else if (topic.equals("HDI6")) {
			fileName="Quality_Control_Checks.htm";
		} else {
			fileName="Phenogen_Overview.htm";
		}


/*****************************************************************************
		MAIN TAB HELP PAGES
*****************************************************************************/						
	/***** Main MicroArray Page *****/
	} else if (caller.endsWith("microarrayMain.jsp")) {
		if (topic.equals("DYK1")) {
			fileName="Downloading_a_Dataset.htm";
		} else if (topic.equals("DYK2")) {
			fileName="DYK_Analyze1.htm";
		} else if (topic.equals("DYK3")) {
			fileName="Viewing_Quality_Control_Results.htm";
		} else if (topic.equals("HDI1")) {
			fileName="Viewing_Quality_Control_Results.htm";
		} else if (topic.equals("HDI2")) {
			fileName="HDI_Analyze1.htm";
		} else if (topic.equals("HDI3")) {
			fileName="HDI_Analyze2.htm";
		} else if (topic.equals("HDI4")) {
			fileName="HDI_Analyze3.htm";
		} else { 
			fileName="Analyzing_Microarray_Data.htm";
		}

	/***** Main Research Gene List Page *****/
	} else if (caller.endsWith("geneListMain.jsp")) {
		if (topic.equals("DYK1")) {
			fileName="Sharing_a_Gene_List.htm";
		} else if (topic.equals("DYK2")) {
			fileName="DYK_Research1.htm";
		} else if (topic.equals("DYK3")) {
			fileName="DYK_Research2.htm";
		} else if (topic.equals("DYK4")) {
			fileName="DYK_Research3.htm";
		} else if (topic.equals("DYK5")) {
			fileName="DYK_Research4.htm";
		} else if (topic.equals("HDI1")) {
			fileName="Literature_Search_Overview.htm";
		} else if (topic.equals("HDI2")) {
			fileName="Performing_Annotation.htm";
		} else if (topic.equals("HDI3")) {
			fileName="HDI_Research1.htm";
		} else if (topic.equals("HDI4")) {
			fileName="HDI_Research2.htm";
		} else if (topic.equals("HDI5")) {
			fileName="Viewing_Homologs.htm";
		} else if (topic.equals("HDI6")) {
			fileName="Viewing_Gene_Lists.htm";
		} else { 
			fileName="Research_Gene_Lists.htm";
		}

	/***** Main Investigate QTL Regions Page *****/
	} else if (caller.endsWith("qtlMain.jsp")) {
		if (topic.equals("DYK1")) {
			fileName="DYK_Investigate1.htm";
		} else if (topic.equals("DYK2")) {
			fileName="DYK_Investigate2.htm";
		} else if (topic.equals("DYK3")) {
			fileName="DYK_Investigate3.htm";
		} else if (topic.equals("HDI1")) {
			fileName="HDI_Investigate1.htm";
		} else if (topic.equals("HDI2")) {
			fileName="Entering_Phenotypic_QTLs.htm";
		} else if (topic.equals("HDI3")) {
			fileName="HDI_Investigate2.htm";
		} else { 
			fileName="Investigating_QTL_Regions.htm";
		}

	
/*****************************************************************************
		ANALYZE MICROARRAY DATA HELP PAGES
*****************************************************************************/						

	/***** Upload Arrays *****/
	} else if (caller.endsWith("listExperiments.jsp") ||
		caller.endsWith("createExperiment.jsp") ||
		caller.endsWith("chooseProtocols.jsp") ||
		caller.endsWith("downloadSpreadsheet.jsp") ||
		caller.endsWith("uploadSpreadsheet.jsp") ||
		caller.endsWith("uploadCELFiles.jsp") ||
		caller.endsWith("reviewExperiment.jsp")) {
		fileName="Uploading_Datasets.htm";

	/***** View All Datasets *****/
	} else if (caller.endsWith("listDatasets.jsp")) {
		fileName="Viewing_Datasets.htm";

	/***** View Dataset Versions *****/
	} else if (caller.endsWith("listDatasetVersions.jsp")) {
		fileName="Group_Normalizing_Datasets.htm";

	/***** Create New Dataset *****/
	} else if (caller.endsWith("selectArrays.jsp")) { 
		fileName="creating_datasets.htm";

	/***** Retrieve Arrays *****/
	} else if (caller.endsWith("advancedQuery.jsp") || 
		caller.endsWith("basicQuery.jsp")) { 
		fileName="Retrieving_Arrays.htm";

	/***** Running Quality Control *****/
	} else if (caller.endsWith("qualityControl.jsp")) {
		fileName="Running_a_Quality_Control_Check.htm";

	/***** View Quality Control Results *****/
	/***** Affymetrix QC Results *****/

	} else if (caller.endsWith("qualityControlResults.jsp")) {
		if  (entireCaller.indexOf("tab=winarray") > 0) {
			fileName="Within-Array_Checks.htm";
		} else if (entireCaller.indexOf("tab=model") > 0) {
			fileName="Model-based_Checks.htm";
		} else if (entireCaller.indexOf("tab=pseudo") > 0) {
			fileName="Pseudo_Images_Affy.htm";
		} else if (entireCaller.indexOf("tab=maplot") > 0) { 
			fileName="MA_Plots.htm";

		/***** CodeLink QC Results *****/
		} else if (entireCaller.indexOf("tab=rle") > 0) { 
			fileName="RLE_CodeLink.htm";
		} else if (entireCaller.indexOf("tab=cv") > 0) { 
			fileName="Coefficient_of_Variation.htm";
		} else if (entireCaller.indexOf("tab=clsoft") > 0) { 
			fileName="CodeLink_Software.htm";

		/***** No Tab Selected *****/
		} else {
			fileName="Quality_Control_Checks.htm";
		}
	
	/***** Data Groups and Normalization *****/
	} else if (caller.endsWith("normalize.jsp") || 
			caller.endsWith("groupArrays.jsp")) { 
		fileName="Group_Normalizing_Datasets.htm";

	/***** Choose Type of Data Analysis *****/
	} else if (caller.endsWith("typeOfAnalysis.jsp")) { 
		fileName="Analyzing_Datasets_Overview.htm";

	/***** Filtering *****/
	} else if (caller.endsWith("filters.jsp")) { 
			fileName="Filtering_Overview.htm";

	/***** Statistics  *****/
	} else if (caller.endsWith("statistics.jsp")) { 
		/***** Differential Expression *****/
		if (entireCaller.indexOf("diffExp") > 0) { 
			fileName="Differential_Expressions_Analysis.htm";
		/***** Correlation *****/
		} else if (entireCaller.indexOf("correlation") > 0) { 
			fileName="Correlation_Analysis.htm";
		}

	/***** Multiple Testing *****/
	} else if (caller.endsWith("multipleTest.jsp")) { 
			fileName="Multiple_Testing_Adjustment.htm";

	/***** Save Gene List *****/
	} else if (caller.endsWith("nameGeneListFromAnalysis.jsp")) { 
			fileName="Filtering_and_Analyzing_Datasets.htm";

	/***** Clustering  *****/
	} else if (caller.endsWith("cluster.jsp")) { 
		fileName="Clustering_Analysis.htm";
	}

	/***** View Gene Expression Data *****/
	else if (caller.endsWith("geneData.jsp")) {
		fileName="Viewing_Gene_Expression_Data.htm";

	/***** Correlation and Create Phenotype Data *****/
	} else if (caller.endsWith("correlation.jsp")) {
		fileName="Using_Phenotype_Data.htm";

	} else if (caller.endsWith("createPhenotype.jsp")) {
		fileName="Using_Phenotype_Data.htm";

	 /***** Download Dataset  *****/
	} else if (caller.endsWith("downloadDataset.jsp")) {
		fileName="Downloading_a_Dataset.htm";

/*****************************************************************************
			GENE LIST HELP PAGES
*****************************************************************************/						
	/***** View All Gene Lists *****/
	} else if (caller.endsWith("listGeneLists.jsp") ||
			caller.endsWith("geneList.jsp")) {
		if (entireCaller.indexOf("fromQTL=Y") > 0) {
			fileName="Viewing_Location_and_eQTL.htm";
		} else {
			fileName="Viewing_Gene_Lists.htm";
		}

	/*****  Basic Annotation *****/
	} else if (caller.endsWith("annotation.jsp") || 
		caller.endsWith("advancedAnnotation.jsp") || 
		caller.endsWith("iDecoderResults.jsp")) {
		fileName="Annotation_Overview.htm";

	/*****  Location *****/
	} else if (caller.endsWith("locationEQTL.jsp")) {
		fileName="Viewing_Location_and_eQTL.htm";

	/***** Promoter *****/
	} else if (caller.endsWith("promoter.jsp")) { 
		fileName="Promoter_Analysis_Extraction.htm";

	/***** Homologs *****/
        } else if (caller.endsWith("homologs.jsp")) { 
		fileName="Homolog_Overview.htm";

	/***** Analysis Statistics *****/
        } else if (caller.endsWith("stats.jsp")) { 
		fileName="Viewing_Analysis_Statistics.htm";

	/***** Pathway *****/
        } else if (caller.indexOf("athway") > -1) { 
		fileName="Viewing_Pathways.htm";

	/***** Expression Values *****/
        } else if (caller.endsWith("expressionValues.jsp")) { 
		fileName="Viewing_Gene_Expression_Data.htm";

	/***** Save As *****/
        } else if (caller.endsWith("saveAs.jsp")) { 
		fileName="Saving_as_Gene_List.htm";

	/***** Sharing *****/
	} else if (caller.endsWith("geneListUsers.jsp")) {
		fileName="Sharing_a_Gene_List.htm";

	/***** Compare Gene Lists *****/
	} else if (caller.endsWith("compareGeneLists.jsp") || 
		caller.endsWith("compareWithOneGeneList.jsp") ||
		caller.endsWith("compareWithAllGeneLists.jsp")) {
		fileName="Comparing_Gene_Lists.htm";


/***** Create Gene List *****/ 
	// From Existing Gene List
	} else if (caller.endsWith("copyGeneList.jsp")) {
		fileName="Copying_a_Gene_List.htm";
	// By Manually Entering
	} else if (caller.endsWith("createGeneList.jsp")) {
		fileName="Creating_a_Gene_List.htm";
/*****  Advanced Annotation *****/
	} else if (caller.endsWith("advancedAnnotation.jsp") ||
		caller.endsWith("iDecoderResults.jsp")) {
		fileName="Advanced_Annotation.htm";
/*****  // From QTL Analysis *****/
	} else if (caller.endsWith("calculateQTLs.jsp") ||
		caller.endsWith("runQTLAnalysis.jsp") ||
		caller.endsWith("displayQTLResults.jsp")) {
		fileName="Calculating_QTLs_for_Phenotype.htm"; 
        } else if (caller.endsWith("eQTLInstructions.jsp")) {
		fileName="eQTL_Explorer.htm";
        } else if (caller.endsWith("qtlLists.jsp")) {
		fileName="Viewing_All_QTL_Lists.htm";
        } else if (caller.endsWith("qtlQuery.jsp") ||
		caller.endsWith("qtlQueryResults.jsp")) {
		fileName="QTL_Query.htm";

/*****  // From Promoter Analysis *****/
	} else if (caller.endsWith("meme.jsp")) { 
		fileName="Running_MEME.htm";
	} else if (caller.endsWith("promoterExtraction.jsp")) { 
		fileName="Running_Upstream_Sequence_Extraction.htm";
	} else if (caller.endsWith("snp.jsp")) { 
		fileName="Retrieving_Genetic_Variation_Data.htm";

/***** Literature Search *****/
	} else if (caller.endsWith("litSearch.jsp")) { 
		fileName="Performing_a_Literature_Search.htm";
/***** Gene List Results *****/
	} else if (caller.endsWith("results.jsp")) {
		//fileName="Viewing_Interpretation_Results.htm";
		fileName="Viewing_Interpretation_Results_By_Gene_List.htm";
/***** Upload Gene List *****/
	} else if (caller.endsWith("uploadGeneList.jsp")) {
		fileName="Uploading_a_Gene_List.htm";
/***** Download Gene List *****/
	} else if (caller.endsWith("downloadGeneList.jsp")) {
		fileName="Downloading_a_Gene_List.htm";
/***** Copy Gene List handled above in 'Create Gene List' *****/
/***** Delete Gene List *****/
	} else if (caller.endsWith("deleteGeneList.jsp")) {
		fileName="Deleting_a_Gene_List.htm";
/***** Exon Correlation Tab *****/
	} else if (caller.contains("exonCorrelationTab.jsp")) {
		fileName="Viewing_Exon_Information.htm";
/*****************************************************************************
		QTL TAB HELP PAGES
*****************************************************************************/						
	/***** Defining QTL *****/
	} else if (caller.endsWith("defineQTL.jsp")) {
		fileName="Entering_Phenotypic_QTLs.htm";

	/***** Download Marker *****/
        } else if (caller.endsWith("downloadMarker.jsp")) { 
		fileName="Expression_QTL_Derivation.htm";
/*****************************************************************************
		Explore Exon TAB HELP PAGES
*****************************************************************************/						
	/***** Explore Exon Main Page *****/
	 } else if (caller.contains("exonMain.jsp")) { 
		fileName="Explore_Exons.htm";
	/***** Exon-Exon correlation *****/
	 } else if (caller.contains("exonCorrelationGene.jsp")) { 
		fileName="Viewing_Exon_Information.htm";
	
/*****************************************************************************
		RESOURCES TAB HELP PAGES
*****************************************************************************/						
	/***** Downloading Resources *****/
        } else if (caller.endsWith("resources.jsp")) { 
		fileName="DownloadResources.htm";
/*****************************************************************************
		RESULT HELP PAGES
*****************************************************************************/						
/***** View Cluster Analysis Results *****/
	} else if (caller.endsWith("allClusterResults.jsp") ||
		caller.endsWith("clusterResults.jsp") ||
		caller.endsWith("clusterDetails.jsp") ||
		caller.endsWith("clusterImages.jsp")) {
		fileName="Viewing_Cluster_Analysis_Results.htm";
	}
/***** View Promoter Results *****/
	else if ((caller.endsWith("allAnalysisResults.jsp") &&
			entireCaller.indexOf("type=oPOSSUM") > 0) ||
			caller.endsWith("promoterResults.jsp") ||
			caller.endsWith("targetGenes.jsp")) {
		fileName="Viewing_oPOSSUM_Results.htm";
	}
/***** View MEME Results *****/
	else if ((caller.endsWith("allAnalysisResults.jsp") &&
			entireCaller.indexOf("type=MEME") > 0) ||
			caller.endsWith("memeResults.jsp")) {
		fileName="Viewing_MEME_Results.htm";
	}
/***** View Upstream Extraction Results *****/
	else if ((caller.endsWith("allAnalysisResults.jsp") &&
			entireCaller.indexOf("type=extraction") > 0) ||
			caller.endsWith("upstreamExtractionResults.jsp")) {
		fileName="Viewing_Upstream_Sequence_Extraction_Results.htm";
	}
/***** View Literature Results *****/
	else if ((caller.endsWith("allAnalysisResults.jsp") &&
			entireCaller.indexOf("type=litSearch") > 0) ||
			caller.endsWith("litSearchResults.jsp")) {
		fileName="Viewing_Literature_Search_Results.htm";
	}
	
/*****************************************************************************
		PI HELP PAGES
*****************************************************************************/						
/***** Approving Array Requests *****/
	else if (caller.endsWith("approveRequests.jsp")) {
		fileName="Approve_Pending_Requests.htm";
	}
/***** Publish Datasets *****/
	else if (caller.endsWith("createMAGEML.jsp")) {
		fileName="Publishing_Experiments.htm";
	}
	else if (caller.endsWith("sendMAGEML.jsp")) {
		fileName="Publishing_Experiments.htm";
	}
/***** Grant Array Access *****/
	else if (caller.endsWith("publishExperiment.jsp") ||
		caller.endsWith("grantArrayAccess.jsp")) {
		fileName="Granting_Array_Access.htm";
	}

/*****************************************************************************
		OTHER HELP PAGES
*****************************************************************************/						
	else if ((caller.endsWith("index.jsp")) || 
		(caller.endsWith("http://" + host + contextRoot))|| 
		(caller.endsWith("https://" + host + contextRoot))) {
		fileName="getting_started_front.htm";
	}	
	else if (caller.endsWith("userUpdate.jsp")) {
		fileName="Updating_Your_Profile.htm";
	}
	else if (caller.endsWith("registration.jsp")) {
		fileName="Registration.htm";
	}
	

/*****************************************************************************
		ELSE CLAUSE - all pages not listed above go to PhenoGen Overview
*****************************************************************************/							
	else {
		fileName="Phenogen_Overview.htm#Overview";
		//fileName="PhenoGen_Overview_Left.htm#CSHID=Overview.htm|StartTopic=Content%2FOverview.htm|SkinName=PhenoGen";
	}
	//fileName="/helpdocs/Content/" + fileName;
	fileName=contextPath+"/helpdocs/PhenoGen_Overview_CSH.htm#"+fileName;
	
	log.debug("fileName = "+fileName);
	response.sendRedirect(fileName);
	%><!-- <div align="right"><a href="javascript:window.close()">Close</a></div>--> <%
	%><!--<jsp:include page="<%=fileName%>" flush="true"/>--><%
	%><!-- <center><a href="javascript:window.close()">Close</a></center><BR><BR>--> <%
	 
%>
		
		

