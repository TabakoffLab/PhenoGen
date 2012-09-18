<%--
 *  Author: Cheryl Hornbaker
 *  Created: January, 2006
 *  Description:  This file creates a web page that displays detailed information 
 *	about an array.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>

<%
	log.debug("in arrayDetails");
	loggedIn = false;
	String sectionHeading = "";

        if((String) session.getAttribute("userID") != null) {
                loggedIn = true;
		userID = Integer.parseInt((String) session.getAttribute("userID"));
        } 

	int arrayID = -99;
	if ((String)request.getParameter("arrayID") != null) {
        	arrayID = Integer.parseInt((String)request.getParameter("arrayID"));
	}

	log.info("in arrayDetails.jsp. arrayID = "+arrayID + 
			", RemoteAddr = "+request.getRemoteAddr());  
			//", Country = "+request.getLocale().getDisplayCountry() + 
			//", Language = "+request.getLocale().getDisplayLanguage()); 

        edu.ucdenver.ccp.PhenoGen.data.Array thisArray = myArray.getSampleDetailsForHybridID(arrayID, dbConn);

	if (loggedIn) {
		mySessionHandler.createSessionActivity(session.getId(), 
			"Viewed array details for array '" + arrayID +  "'",
			dbConn);
	}

	if ((String) request.getParameter("filename") != null) {
		String [] filelist = new String[1];
		String filename = (String) request.getParameter("filename");
		String arrayName = (String) request.getParameter("arrayName");
		userName = ((String) session.getAttribute("userName") == null ? 
					"guest": 
					(String) session.getAttribute("userName"));
		String downloadDir = userLoggedIn.getUserExperimentDownloadDir();
                if (!myFileHandler.createDir(downloadDir)) {
                	log.debug("error creating experiment downloads directory in arrayDetails");
			throw new ErrorException("SYS-001");
		} else {
                	log.debug("no problems creating experiment downloads directory in arrayDetails");
                }

		filelist[0] = filename;
		String zipFileName = downloadDir +
			// replace all spaces and apostrophes with blanks
                        myObjectHandler.removeBadCharacters(arrayName) + 
			"_Download.zip";
		myFileHandler.createZipFile(filelist, zipFileName);
		request.setAttribute("fullFileName", zipFileName);
		myFileHandler.downloadFile(request, response);
		// This is required to avoid the getOutputStream() has already been called for this response error
		out.clear();
		out = pageContext.pushBody(); 
		if (loggedIn) {
			mySessionHandler.createSessionActivity(session.getId(), 
				"Downloaded file for array '" + arrayName +  "'",
				dbConn);
		}
	}

%>

<%@ include file="/web/common/includeExtras.jsp" %>

<BR>

<div id="container">

  <div id="arrayDetailsTab" class="modalTab">
    <ul>
      <li><a href="#tab-1">Sample Details</a></li>
      <li><a href="#tab-2">Experiment Details</a></li>
      <li><a href="#tab-3">Extract Details</a></li>
      <li><a href="#tab-4">Labeled Extract Details</a></li>
      <li><a href="#tab-5">Hybridization Details</a></li>
      <li><a href="#tab-6">File Name</a></li>
      </ul>
      
    
    <div id="tab-1" class="modalTabContent">      
      <table class="sideHeading" >
		<tr><td class="header">Sample Name:</td><td><%=thisArray.getSample_name()%></td></tr>
		<tr><td class="header">Organism:</td><td><%=thisArray.getOrganism()%></td></tr>
		<tr><td class="header">Gender:</td><td><%=thisArray.getGender()%></td></tr>
		<tr><td class="header">Sample Provider:</td><td><%=thisArray.getProvider()%></td></tr>
		<tr><td class="header">Sample Type:</td><td><%=thisArray.getBiosource_type()%></td></tr>
		<tr><td class="header">Development Stage:</td>
			<td> <%=thisArray.getDevelopment_stage()%> <%=twoSpaces%>
			Age:<%=twoSpaces%><%=thisArray.getAge_status()%> <%=twoSpaces%> 
			Min:<%=twoSpaces%><%=thisArray.getAge_range_min()%> <%=twoSpaces%> 
			Max:<%=twoSpaces%><%=thisArray.getAge_range_max()%> </td>
		</tr> 
		<tr><td class="header">Unit:</td><td><%=thisArray.getAge_range_units()%></td></tr>
		<tr><td class="header">Initial Time Point:</td><td><%=thisArray.getTime_point()%></td></tr>
		<tr><td class="header">Organism Part/Tissue:</td><td><%=thisArray.getOrganism_part()%></td></tr>
		<tr><td class="header">Genetic Modification:</td><td><%=thisArray.getGenetic_variation()%></td></tr>
		<tr><td class="header">Individual Identifier:</td><td><%=thisArray.getIndividual_identifier()%></td></tr>
		<tr><td class="header">Individual Genotype:</td><td><%=thisArray.getIndividual_genotype()%></td></tr>
		<tr><td class="header">Disease State:</td><td><%=thisArray.getDisease_state()%></td></tr>
		<tr><td class="header">Separation Technique:</td><td><%=thisArray.getSeparation_technique()%></td></tr>
		<tr><td class="header">Target Cell Type:</td><td><%=thisArray.getTarget_cell_type()%></td></tr>
		<tr><td class="header">Cell Line:</td><td><%=thisArray.getCell_line()%></td></tr>
		<tr><td class="header">Strain:</td><td><%=thisArray.getStrain()%></td></tr>
		<tr><td class="header">Treatment/Administration Route:</td><td><%=thisArray.getTreatment()%></td></tr>
		<tr><td class="header">Compound:</td><td><%=thisArray.getCompound()%></td></tr>
		<tr><td class="header">Dose:</td><td><%=thisArray.getDose()%></td></tr>
		<tr><td class="header">Duration:</td><td><%=thisArray.getDuration()%></td></tr>
		<tr><td class="header">Additional Clinical Information:</td><td><%=thisArray.getAdditional()%></td></tr>
		<tr><td class="header">Platform:</td><td><%=thisArray.getPlatform()%></td></tr>
		<tr><td class="header">Array Used:</td><td><%=thisArray.getArray_type()%></td></tr>
		<tr><td class="header">Growth Conditions Protocol:</td><td><%=thisArray.getGrowthConditionsProtocol()%></td></tr>
		<tr><td class="header">Growth Conditions Protocol Description:</td><td><%=thisArray.getGrowthConditionsProtocolDescription()%></td></tr>
		<tr><td class="header">Sample Treatment Protocol:</td><td><%=thisArray.getSampleTreatmentProtocol()%></td></tr>
		<tr><td class="header">Sample Treatment Protocol Description:</td><td><%=thisArray.getSampleTreatmentProtocolDescription()%></td></tr>
		  </table>
       
      <br/>
  
    </div>
    
    
    <div id="tab-2" class="modalTabContent">
     
      <table class="sideHeading">
		<tr><td class="header">Submission Description:</td><td><%=thisArray.getExperiment_name()%></td></tr>
		<tr><td class="header">Experiment Description:</td><td><%=thisArray.getExperimentDescription()%></td></tr>
		<tr><td class="header">Submitter:</td><td><%=thisArray.getSubmitter()%></td></tr>
		<tr><td class="header">Experiment Design Type(s):</td><td><%=thisArray.getExperiment_design_types()%></td></tr>
		<tr><td class="header">Experimental Factor(s):</td><td><%=thisArray.getExperimental_factors()%></td></tr>
      </table>
      <br/>       
    </div>
    
    <div id="tab-3" class="modalTabContent">
      
      <table class="sideHeading">
		<tr><td class="header">Extract Name:</td><td><%=thisArray.getTextract_id()%></td></tr>    
		<tr><td class="header">Extract Protocol:</td><td><%=thisArray.getExtractProtocol()%></td></tr>		
		<tr><td class="header">Extract Protocol Description:</td><td><%=thisArray.getExtractProtocolDescription()%></td></tr>
      </table>
      <br/>
       
    </div>
    <div id="tab-4" class="modalTabContent">
      
      <table class="sideHeading">
		<tr><td class="header">Label Extract Name:</td><td><%=thisArray.getTlabel_id()%></td></tr>
		<tr><td class="header">Label Extract Protocol:</td><td><%=thisArray.getLabelExtractProtocol()%></td></tr>
		<tr><td class="header">Label Extract Protocol Description:</td><td><%=thisArray.getLabelExtractProtocolDescription()%></td></tr>
      </table>
      <br/>        	
    </div>
    
    
    <div id="tab-5"  class="modalTabContent">
      
      <table class="sideHeading">
		<tr><td class="header">Hybridization Name:</td><td><%=thisArray.getHybrid_name()%></td></tr>
		<tr><td class="header">Hybridization Protocol:</td><td><%=thisArray.getHybridizationProtocol()%></td></tr><tr></tr>
		<tr><td class="header">Hybridization Protocol Description:</td><td><%=thisArray.getHybridizationProtocolDescription()%></td></tr><tr></tr>
		<tr><td class="header">Scanning Protocol:</td><td><%=thisArray.getScanningProtocol()%></td></tr><tr></tr>
		<tr><td class="header">Scanning Protocol Description:</td><td><%=thisArray.getScanningProtocolDescription()%></td></tr>
      </table>
      <br/>       
    </div>
 
 
     <div id="tab-6"  class="modalTabContent">
      
      <table class="sideHeading" width="100%">
       <tr><td width="33%" class="header">File Name:</td><td width="33%"><%=thisArray.getFile_name()%></td>
		<%
			if ((thisArray.getPublicExpID() != null && 
				!thisArray.getPublicExpID().equals("")) || 
				(loggedIn && myArray.userHasAccess(userID, arrayID, dbConn))) {
					%>
					<td width="33%" class="right">
					<a href="<%=datasetsDir%>arrayDetails.jsp?
					arrayID=<%=arrayID%>&amp;arrayName=<%=thisArray.getSample_name()%>&
					filename=<%=thisArray.getArrayDataFilesLocation(userFilesRoot)%><%=thisArray.getFile_name()%>">
					<img  src="<%= imagesDir %>/icons/download_g.png" style="padding:0 16px 0 0"/>
					<br>
					Download
					</a>
					</td> <%
			} else {
				%><td>&nbsp;</td><%
			}
		%>
		</tr>
      </table>
      <br/>       
    </div>
 
    
    
  </div>
  
</div>

	
<%
	log.info("closing dbConn in arrayDetails.jsp");
	dbConn.close();

%>


<div class="modalWindowClose">
    <div class="closeWindow">Close</div>
</div>
