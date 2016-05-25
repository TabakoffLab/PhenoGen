<%
	optionChoices = new Toolbar(session).getAllOptions();

	optionsList = (ArrayList)request.getAttribute("optionsList");
	optionsListModal = (ArrayList)request.getAttribute("optionsListModal");

	if ((optionsList != null && optionsList.size() > 0) || (optionsListModal != null && optionsListModal.size() > 0)) { 
	   %>
		<div id="iconsDiv">
                <%if(userLoggedIn.getUser_name().equals("anon")){%>   
                    <div style="display:block;float:right;margin-bottom: 5px;">
                        <img src="<%=imagesDir%>/icons/alert_24.png" style="position:relative;top:5px;">Gene lists will only be available on this browser / computer.
                        <span class="info" 
                              title="You are currently not signed in.<BR><BR><UL><LI>-If you register or sign in your current Gene Lists will be migrated to your user account and will be portable when you login elsewhere.</li><BR>
                              <li>-Note that clearing your browsers cache may cause loss of your lists.</li><BR>
                              <li><B>-Alternatively you can add your email address which would allow you to recieve an email with links to recover a lost session.</B></li><BR>
                              </UL>">

                            <img src="<%=imagesDir%>/icons/info.gif" /></span>
                    </div>
                <%}%>
		<div class="optionIcons" >
		<%
		if (optionsList != null && optionsList.size() > 0) {
			//log.debug("optionsList is not null");
			//myDebugger.print(optionsList);
			for (int i=0; i<optionsList.size(); i++) {
				String optionName = (String) optionsList.get(i); 
				//log.debug("optionName = "+optionName);
				%>
				<% if (optionName.equals("experimentDetails")) { %>
					<div class="toolbarPicture icons">
						<span class="details" experimentID="<%=selectedExperiment.getExp_id()%>">
							<img src="<%=imagesDir%>icons/magnifyingGlass.png" alt="Experiment Details">
							<br/>Experiment Details
						</span>
					</div>
				<% } else if (optionName.equals("datasetDetails")) { %>
					<div class="toolbarPicture icons">
						<span class="details" datasetID="<%=selectedDataset.getDataset_id()%>">
							<img src="<%=imagesDir%>icons/magnifyingGlass.png" alt="Dataset Details">
							<br/>Dataset Details
						</span>
					</div>
				<% } else if (optionName.equals("datasetVersionDetails")) { %>
					<div class="toolbarPicture icons">
						<span class="details" datasetID="<%=selectedDataset.getDataset_id()%>" datasetVersion="<%=selectedDatasetVersion.getVersion()%>">
							<img src="<%=imagesDir%>icons/magnifyingGlass.png" alt="Dataset Version Details">
							<br/>Dataset Version Details
						</span>
					</div>
				<% } else if (optionName.equals("geneListDetails")) { %>
					<div class="toolbarPicture icons">
						<span class="details" geneListID="<%=selectedGeneList.getGene_list_id()%>" parameterGroupID="<%=selectedGeneList.getParameter_group_id()%>">
							<img src="<%=imagesDir%>icons/magnifyingGlass.png" alt="Gene List Details">
							<br/>Gene List Details
						</span>
					</div>
				<% } else if (optionName.equals("phenotypeDetails")) { %>
					<div class="toolbarPicture icons">
						<span class="details">
							<img src="<%=imagesDir%>icons/magnifyingGlass.png" alt="Phenotype Details">
							<br/>Phenotype Details
						</span>
					</div>
                                
				<% } else { 
					Toolbar.Option thisOption = new Toolbar().new Option().getOptionFromMyOptions(optionChoices, optionName);
					String landing_page = thisOption.getLinkTo(); 
					String icon = thisOption.getIcon(); 
					String altText = thisOption.getAltText(); 
					//log.debug("option = "+option);
					//log.debug("landing_page = "+landing_page);
					//log.debug("icon = "+icon);
					%>
					<div id="<%=optionName%>" class="toolbarPicture icons" data-landingPage="<%=landing_page%>"> 
						<img src="<%=imagesDir%>icons/<%=icon%>" alt="" /> 
						<br/><%=altText%>
					</div>
				<% } %>
			<% } 

		}
		if (optionsListModal != null && optionsListModal.size() > 0) {
			//log.debug("optionsListModal is not null");
			for (int i=0; i<optionsListModal.size(); i++) {
				String optionName = (String) optionsListModal.get(i); 
				Toolbar.Option thisOption = new Toolbar().new Option().getOptionFromMyOptions(optionChoices, optionName);
				String icon = thisOption.getIcon(); 
				String altText = thisOption.getAltText(); 
                        	%><div id="<%=optionName%>" name="<%=optionName%>" class="toolbarPicture icons">
					<img src="<%=imagesDir%>icons/<%=icon%>" alt="" /> 
					<br/><%=altText%>
				</div><%
			} 
		} else {
			//log.debug("optionsListModal is null");
	
		}%>
		</div> <!-- end optionIcons -->
                
		</div> <!-- end div#iconsDiv -->
		<%
	} else {
		//log.debug("optionsList and optionsListModal are both null");
        }
%>

