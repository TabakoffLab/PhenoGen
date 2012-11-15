<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>


    <div id="welcome" style="height:575px; width:980px; overflow:auto;">
		<h2 class="homePage">Welcome to PhenoGen Informatics</h2>
	<div id="overview-wrap" class="welcomeContent descContent">
                	<div id="overview-content">
            			<p>The PhenoGen Informatics web site is not only a microarray repository
				but also a comprehensive toolbox for analyzing microarray data and 
				researching candidate genes.  </p>
				<p>The site is organized into five major sections: </p>
				<ul>
                	<li><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp">Detailed Transcription Information</a></li>
                    <li><a href='<%=accessDir%>createAnnonymousSession.jsp?url=<%=sysBioDir%>resources.jsp'>Downloads </a></li>
                    <li><a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>listDatasets.jsp">Microarray Analysis Tools (login required)</a></li>
                    <li><a href='<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp'>Gene Analysis Tools (login required)</a></li>
                    <li><a href='<%=accessDir%>checkLogin.jsp?url=<%=qtlsDir%>qtlMain.jsp'>QTL Tools (login required)</a></li>
                </ul>
                
                
                
                <br/>
				<p>Click the Overview option above to see examples of what you can do on our site.  The options to the right of the Overview are the main areas of the site.  The functions with a <span style=" background-color:#2d7a32; color:#FFFFFF;">green background</span> indicate publicly accessible parts of the site, while the remaining functions with the <span style="background-color:#436f93; color:#FFFFFF;">blue background</span> require a login.</p>

            			<p>View the <a href="<%=commonDir%>PhenoGenDemo.ppt"  
				title="Getting Started with PhenoGen Informatics Demo">Getting 
				Started With PhenoGen Informatics Demo</a> to learn how to get started.</p>

				<BR>
            			<p>Review the <a href="CurrentDataSets.jsp"  
				title="Current Datasets">current datasets</a> that we have available for public use.</p>
            
                        <H3 style="margin:10px;"> Why do we require a login?</H3>
                        <p>For many of the tools that require a login, there are multiple intermediate steps in the analisys or steps that may take a long time to complete.  Logging in, allows you to start a step and come back to the analysis/results at a later time.  A login also allows you to upload data to the site and keep it private or to share it with individuals you approve.</p>
                        
                        
                
                	</div> <!-- // end overview-content -->
            	</div> <!-- // end overview-wrap -->
						<div class="demoVideo" style="float:right;position:relative;top:-450px; padding-right:20px;">
                        	<h3>Overview Video</h3>
                        	<video width="420" height="300" controls="controls">
                                <source src="<%=contextRoot%>web/demo/test.mp4" type="video/mp4">
                                <source src="<%=contextRoot%>web/demo/test.webm" type="video/webm">
                            
                              	<object data="<%=contextRoot%>web/demo/test.mp4" width="400" height="280">
                              	</object>
                        	</video>
                            <H3><a href="<%=contextRoot%>web/demo/mainDemo.jsp?file=<%=contextRoot%>web/demo/test." target="_blank">Open in a new Window</a></H3><BR />
                            <H3><a href="<%=contextRoot%>web/demo/mainDemo.jsp" target="_blank">View other demo videos</a></H3> 
                        </div>
            	
	</div><!-- // end welcome -->
    