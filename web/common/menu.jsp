


<div id="page_header">
    <div id="header_title"><a href="<%=request.getContextPath()%>">PhenoGen Informatics</a></div>
  </div> <!-- page_header -->
  
<div id='cssmenu'>
   		<ul>
        
		<!-- HOME -->
		<% if(!loggedIn||userLoggedIn.getUser_name().equals("anon")){%>
        	<li class="has-sub"><a href='<%=contextRoot%>index.jsp' class="public"><span class="menu1line">Overview</span></a>
        		<ul>
                    <li><a href="<%=commonDir%>ovrvw_whats_new.jsp"><span>What's New</span></a></li>
                    <li><a href="<%=commonDir%>ovrvw_transcript_details.jsp"><span>Transcription Details</span></a></li>
                    <li><a href="<%=commonDir%>ovrvw_downloads.jsp"><span>Downloads</span></a></li>
                    <li><a href="<%=commonDir%>ovrvw_microarray_tools.jsp"><span>Microarray Analysis Tools</span></a></li>
                    <li><a href="<%=commonDir%>ovrvw_genelist_tools.jsp"><span>Gene List Analysis Tools</span></a></li>
                    <li><a href="<%=commonDir%>ovrvw_qtl_tools.jsp"><span>QTL Tools</span></a></li>
            	</ul>
         	</li>
        <%}else{%>
        	<li><a href='<%=commonDir%>startPage.jsp'><span class="menu1line">Home</span></a></li>
        <%}%>
   		

       		<li><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp" <%if(!loggedIn||userLoggedIn.getUser_name().equals("anon")){%> class="public" <%}%>><span class="menu3line">Detailed Transcription Information</span></a></li>
       		<li><a href='<%=accessDir%>createAnnonymousSession.jsp?url=<%=sysBioDir%>resources.jsp' <%if(!loggedIn||userLoggedIn.getUser_name().equals("anon")){%> class="public" <%}%>><span class="menu1line">Downloads</span></a></li>
       
       <li class='has-sub'><a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>listDatasets.jsp"><span class="menu2line">Microarray Analysis Tools</span></a>
          <ul>
          	 <li><a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>listDatasets.jsp"><span>Analyze precompiled datasets</span></a>
             <li><a href="<%=accessDir%>checkLogin.jsp?url=<%=experimentsDir%>listExperiments.jsp"><span>Upload your own data</span></a></li>
             <li><a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>basicQuery.jsp"><span>Create a dataset from public and private arrays</span></a></li>
             <li><a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>geneData.jsp"><span>View expression values for a list of genes in a dataset</span></a></li>
          </ul>
       </li>
       <li class='has-sub'><a href='<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp'><span class="menu2line">Gene List Analysis Tools</span></a>
          <ul>
          	 <li><a href='<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp'><span>View Gene Lists</span></a>
             <li><a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>createGeneList.jsp?fromMain=Y">Upload or create a new list of genes to use for an analysis</a></li>
             <li><a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>listDatasets.jsp?">Derive a list of genes from a microarray analysis</a></li>
          </ul>
       </li>
       <li class='has-sub'><a href='<%=accessDir%>checkLogin.jsp?url=<%=qtlsDir%>qtlMain.jsp'><span class="menu1line">QTL Tools</span></a>
       			<ul>
                	<li><a href="<%=accessDir%>checkLogin.jsp?url=<%=qtlsDir%>defineQTL.jsp?fromMain=Y&fromQTL=Y"><span>Enter phenotypic QTL information</span></a></li>
                    <li><a href="<%=accessDir%>checkLogin.jsp?url=<%=qtlsDir%>calculateQTLs.jsp">Calculate QTLs for phenotype</a></li>
            		<li><a href="<%=accessDir%>checkLogin.jsp?url=<%=qtlsDir%>downloadMarker.jsp">Download marker set used in eQTL calculations</a></li>
            		<li><a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp?fromQTL=Y">View physical location and eQTL information about specific genes from a gene list</a></li>
                </ul>
       </li>
       <li class='has-sub'><a href='#' <%if(!loggedIn||userLoggedIn.getUser_name().equals("anon")){%> class="public" <%}%>><span class="menu1line">About</span></a>
            	<ul>
                	<li><a href="<%=contextRoot%>CurrentDataSets.jsp"><span>Current Datasets</span></a></li>
                	<li><a href="<%=commonDir%>publications.jsp"><span>Recent Publications</span></a></li>
                    <li><a href="<%=commonDir%>siteVersion.jsp"><span>Version Information</span></a></li>
                    <li><a href="<%=commonDir%>citation.jsp"><span>Citations</span></a></li>
                    <li><a href="<%=commonDir%>usefulLinks.jsp"><span>Useful Links</span></a></li>
                </ul>
       </li>
       <%@ include file="/web/common/helpFileURL.jsp"%>
       <li class='has-sub'><a href="<%=helpFileURL%>" target="_blank" <%if(!loggedIn||userLoggedIn.getUser_name().equals("anon")){%> class="public" <%}%>><span class="menu1line">Help</span></a>
            	<ul>
                	<%if(!helpFileURL.equals(request.getContextPath()+"/helpdocs/PhenoGen_Overview_CSH.htm#Phenogen_Overview.htm")){ %>
                	<li><a href="<%=helpFileURL%>" target="_blank"><span>Page Specific Help</span></a></li>
                    <%}%>
                    <li><a href="<%=request.getContextPath()%>/helpdocs/PhenoGen_Overview_CSH.htm#Phenogen_Overview.htm#Overview" target="_blank"><span>Help Overview</span></a></li>
                	<li><a href="<%=commonDir%>PhenoGen.pdf" target="_blank"><span>Download Manual</span></a></li>
                    <!--<li><a href="<%=commonDir%>PhenoGenDemo.ppt"><span>Demo</span></a></li>-->
                    <li><a href="<%=commonDir%>siteRequirements.jsp"><span>Browser Support/Software Requirments</span></a></li>
                    <!--<li><a href="<%=commonDir%>how_do_i.jsp"><span>How do I?</span></a></li>-->
                    <li><a href="<%=commonDir%>contact.jsp"><span>Contact Us</span></a></li>
                </ul>
       </li>
       
   <% if(!loggedIn||userLoggedIn.getUser_name().equals("anon")){%>
   		<li><a href='#' class="end login_btn" ><span class="menu1line">Login</span></a></li>
   <%} else {%>
   		<li><a href='#' class="end login_btn" ><span class="menu1line">Account</span></a></li>
   <% } %>
   		
       
</ul>
</div>
<%@ include file="/web/access/include/accountBox.jsp" %>



  <!--<div id="crumb_trail"></div>-->
  
  <script>
  	var mouse_is_inside = false;
  
  	$(document).ready(function() {
    	$(".login_btn").click(function() {
        	var loginBox = $("#login_box");
        	if (loginBox.is(":visible")){
            	loginBox.fadeOut("fast");
				$(".triangle_up").removeClass('triangle_up').addClass('triangle_down');
        	}else{
            	loginBox.fadeIn("fast");
				$(".triangle_down").removeClass('triangle_down').addClass('triangle_up');
			}
        	return false;
    	});
		$("#login_box").hover(function(){ 
       		mouse_is_inside=true; 
    	}, function(){ 
        	mouse_is_inside=false; 
    	});
		$("body").click(function(){
        	if(! mouse_is_inside) $("#login_box").fadeOut("fast");
   		 });
	});
	</script>