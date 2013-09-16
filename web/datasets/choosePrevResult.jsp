<%--
 *  Author: Cheryl Hornbaker
 *  Created: Aug, 2009
 *  Description:  This file performs the logic necessary for selecting a dataset 
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>
<%@ include file="/web/datasets/include/selectDataset.jsp"  %>
<%
	DataSource pool=(DataSource)session.getAttribute("dbPool");

	String dsfsID = (request.getParameter("dsFilterStatID") != null ?
				(String) request.getParameter("dsFilterStatID") : "");
	
				log.debug("Choosing Previous Results ID:"+dsfsID);
	DSFilterStat dsfs=selectedDatasetVersion.getFilterStat(Integer.parseInt(dsfsID),userLoggedIn.getUser_id(),pool);
	String analysisPathPartial = userLoggedIn.getUserGeneListsDir() + 
                       selectedDataset.getNameNoSpaces() + 
                       "_v" +
                       selectedDatasetVersion.getVersion() +
                       "_Analysis" + "/";
	String curDate=dsfs.getFilterDate();
	String curTime=dsfs.getFilterTime();
	String analysisPathPlusDate = analysisPathPartial + curDate + "/";
	String analysisPathPlusDateTime = analysisPathPlusDate + curTime + "/";
    analysisPath = analysisPathPlusDateTime;
	String abnormalPath=null;
	
	String specificStep=(request.getParameter("specificStep") != null ?
				(String) request.getParameter("specificStep") : "");
	
	int numGroups = selectedDatasetVersion.getNumber_of_non_exclude_groups();
	session.setAttribute("numGroups", Integer.toString(numGroups));
	
	
	log.debug("ChoosePrev Results\nAnalysis Path:"+analysisPath);
	
	if(!specificStep.equals("")){
		log.debug("dsfs ID when started:"+dsfs.getDSFilterStatID());
		String analysisType=dsfs.getAnalysisTypeShort();
		session.setAttribute("verFilterDate",dsfs.getFilterDate());
		session.setAttribute("verFilterTime",dsfs.getFilterTime());
		session.setAttribute("analysisPath", analysisPath);
		parameterGroupID=dsfs.getParameterGroupID();
		session.setAttribute("parameterGroupID",Integer.toString(parameterGroupID));
		if(specificStep.equals("multtest")){
			response.sendRedirect("multipleTest.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion()+"&analysisType="+dsfs.getAnalysisTypeShort());
		}else if(specificStep.equals("stats")){
			Statistic myStatistic=new Statistic();
			myStatistic.setSession(session);
			int tmpnumprobe=800000;//myStatistic.moveFilterToHDF5(selectedDataset,selectedDatasetVersion,abnormalPath);
			Hashtable durationHash = myDataset.getExpectedDuration(selectedDataset.getNumber_of_arrays(),tmpnumprobe , dbConn);
			session.setAttribute("durationHash", durationHash);
			response.sendRedirect("statistics.jsp?datasetID="+selectedDataset.getDataset_id()+
				"&datasetVersion="+selectedDatasetVersion.getVersion()+
				//"&parameterGroupID="+parameterGroupID+
				"&analysisType="+dsfs.getAnalysisTypeShort());
		}else if(specificStep.equals("statscorr")){
			Statistic myStatistic=new Statistic();
			myStatistic.setSession(session);
			phenotypeParameterGroupID=dsfs.getPhenotypeParamGroupID();
			log.debug("PhenotypeParamGroupID:"+phenotypeParameterGroupID);
			String phenotypeName = myParameterValue.getPhenotypeName(phenotypeParameterGroupID, dbConn);
            String groupingUserPhenotypeDir = selectedDatasetVersion.getGroupingUserPhenotypeDir(userName, phenotypeName);
			abnormalPath=groupingUserPhenotypeDir;
			log.debug("Selecting correlation filter results"+phenotypeName+"\n"+groupingUserPhenotypeDir);
			log.debug("parameterGroupID:"+parameterGroupID);
			int tmpnumprobe=800000;//myStatistic.moveFilterToHDF5(selectedDataset,selectedDatasetVersion,abnormalPath);
			Hashtable durationHash = myDataset.getExpectedDuration(selectedDataset.getNumber_of_arrays(),tmpnumprobe , dbConn);
			session.setAttribute("durationHash", durationHash);
			response.sendRedirect("statistics.jsp?datasetID="+selectedDataset.getDataset_id()+
										"&datasetVersion="+selectedDatasetVersion.getVersion()+
										"&phenotypeParameterGroupID="+phenotypeParameterGroupID+
										//"&parameterGroupID="+parameterGroupID+
										"&analysisType="+dsfs.getAnalysisTypeShort());
		}else if(specificStep.equals("genelist")){
			response.sendRedirect("nameGeneListFromAnalysis.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion()+"&analysisType="+dsfs.getAnalysisTypeShort());
		}else if(specificStep.equals("cluster")){
			response.sendRedirect("cluster.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion()+"&analysisType=cluster");
		}else if(specificStep.equals("clusterResults")){
			response.sendRedirect("allClusterResults.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion());
		}else if(specificStep.equals("clusterprev")){
			int clusterid=dsfs.getStatsGroup().getClusterIDFromParam();
			response.sendRedirect("cluster.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion()+"&analysisType=cluster&newParameterGroupID="+clusterid);
		}else{
			response.sendRedirect("typeOfAnalysis.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion());
		}
		
	}/*else if(dsfs.getFilterGroup().getFilterGroupID()<=0&&dsfs.getStatsGroup().getStatsGroupID()<=0){
		if (dsfs.getAnalysisTypeShort().equals("correlation")) {
			response.sendRedirect("correlation.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion()+"&analysisType=correlation");
		}else{
			//redirect to filtering
			//response.sendRedirect("listDatasetVersions.jsp?datasetID="+selectedDataset.getDataset_id());
			response.sendRedirect("filters.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion()+"&"+dsfs.getAnalysisTypeShort());
		}
	}else if(dsfs.getStatsGroup().getStatsGroupID()<=0){
			session.setAttribute("verFilterDate",dsfs.getFilterDate());
			session.setAttribute("verFilterTime",dsfs.getFilterTime());
			session.setAttribute("analysisPath", analysisPath);
			parameterGroupID=dsfs.getParameterGroupID();
			session.setAttribute("parameterGroupID",Integer.toString(parameterGroupID));
		if(dsfs.getAnalysisTypeShort().equals("diffExp")){
			Statistic myStatistic=new Statistic();
			myStatistic.setSession(session);
			int tmpnumprobe=myStatistic.moveFilterToHDF5(selectedDataset,selectedDatasetVersion,abnormalPath);
			Hashtable durationHash = myDataset.getExpectedDuration(selectedDataset.getNumber_of_arrays(),tmpnumprobe , dbConn);
			session.setAttribute("durationHash", durationHash);
			response.sendRedirect("statistics.jsp?datasetID="+selectedDataset.getDataset_id()+
				"&datasetVersion="+selectedDatasetVersion.getVersion()+
				//"&parameterGroupID="+parameterGroupID+
				"&analysisType="+dsfs.getAnalysisTypeShort());
		}else if(dsfs.getAnalysisTypeShort().equals("cluster")){
			//response.sendRedirect("cluster.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion()+"&analysisType=cluster");
		}else if (dsfs.getAnalysisTypeShort().equals("correlation")) {
			Statistic myStatistic=new Statistic();
			myStatistic.setSession(session);
			phenotypeParameterGroupID=dsfs.getPhenotypeParamGroupID();
			log.debug("PhenotypeParamGroupID:"+phenotypeParameterGroupID);
			String phenotypeName = myParameterValue.getPhenotypeName(phenotypeParameterGroupID, dbConn);
            String groupingUserPhenotypeDir = selectedDatasetVersion.getGroupingUserPhenotypeDir(userName, phenotypeName);
			abnormalPath=groupingUserPhenotypeDir;
			log.debug("Selecting correlation filter results"+phenotypeName+"\n"+groupingUserPhenotypeDir);
			log.debug("parameterGroupID:"+parameterGroupID);
			int tmpnumprobe=myStatistic.moveFilterToHDF5(selectedDataset,selectedDatasetVersion,abnormalPath);
			Hashtable durationHash = myDataset.getExpectedDuration(selectedDataset.getNumber_of_arrays(),tmpnumprobe , dbConn);
			session.setAttribute("durationHash", durationHash);
			response.sendRedirect("statistics.jsp?datasetID="+selectedDataset.getDataset_id()+
										"&datasetVersion="+selectedDatasetVersion.getVersion()+
										"&phenotypeParameterGroupID="+phenotypeParameterGroupID+
										//"&parameterGroupID="+parameterGroupID+
										"&analysisType="+dsfs.getAnalysisTypeShort());
		}
	}else if(dsfs.getStatsGroup().getStatsGroupID()>0){
		StatsStep[] tmpSteps=dsfs.getStatsGroup().getStatsSteps();
		String analysisType=dsfs.getAnalysisTypeShort();
		session.setAttribute("verFilterDate",dsfs.getFilterDate());
			session.setAttribute("verFilterTime",dsfs.getFilterTime());
			session.setAttribute("analysisPath", analysisPath);
			parameterGroupID=dsfs.getParameterGroupID();
			session.setAttribute("parameterGroupID",Integer.toString(parameterGroupID));
		if(tmpSteps.length==1&&dsfs.getAnalysisTypeShort().equals("diffExp")){
			//response.sendRedirect("multipleTest.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion()+"&analysisType="+dsfs.getAnalysisTypeShort());
		}else if(tmpSteps.length==2&&dsfs.getAnalysisTypeShort().equals("diffExp")){
			//response.sendRedirect("nameGeneListFromAnalysis.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion()+"&analysisType="+dsfs.getAnalysisTypeShort());
		}else if(tmpSteps.length<=1&&dsfs.getAnalysisTypeShort().equals("cluster")){
			int clusterid=dsfs.getStatsGroup().getClusterIDFromParam();
			response.sendRedirect("cluster.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion()+"&analysisType=cluster&newParameterGroupID="+clusterid);
		}else if(tmpSteps.length==1&&dsfs.getAnalysisTypeShort().equals("correlation")){
			phenotypeParameterGroupID=dsfs.getPhenotypeParamGroupID();
			String param=tmpSteps[0].getStatsParameter();
			String stat_method=param.substring(param.indexOf("'")+1,param.lastIndexOf("'"));
			//session.setAttribute("stat_method",stat_method);
			//response.sendRedirect("multipleTest.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion()+
				"&phenotypeParameterGroupID="+phenotypeParameterGroupID+
				//"&parameterGroupID="+parameterGroupID+
				"&analysisType="+dsfs.getAnalysisTypeShort());
		}else if(tmpSteps.length==2&&dsfs.getAnalysisTypeShort().equals("correlation")){
			//response.sendRedirect("nameGeneListFromAnalysis.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion()+"&analysisType="+dsfs.getAnalysisTypeShort());
		}
	}*/else{
		response.sendRedirect("typeOfAnalysis.jsp?datasetID="+selectedDataset.getDataset_id()+"&datasetVersion="+selectedDatasetVersion.getVersion());
	}
	
	
%>
