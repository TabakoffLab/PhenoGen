<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>


    <div id="welcome" style="height:750px; width:980px; overflow:auto;">
		<h2 class="homePage">Welcome to PhenoGen Informatics</h2>
	<div id="overview-wrap" class="welcomeContent descContent">
                	<div id="overview-content-wide">
            			<p>The PhenoGen Informatics web site is not only a microarray repository
				but also a comprehensive toolbox for analyzing microarray data and 
				researching candidate genes and QTLs.  </p>
				<p>The site is organized into five major sections which are explained in detail in the corresponding Overview Section: </p>
				<ul>
                	<li><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp">Detailed Transcription Information</a>-View exon/probest level data for a gene or gene level data for a genomic region.</li>
                    <li><a href='<%=accessDir%>createAnnonymousSession.jsp?url=<%=sysBioDir%>resources.jsp'>Downloads</a>-Download any public data</li>
                    <li><a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>listDatasets.jsp">Microarray Analysis Tools (login required)</a>-Tools to normalize, filter, differential expression, cluster, correlate array data.</li>
                    <li><a href='<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp'>Gene Analysis Tools (login required)</a>-Tools to help gain insight into gene annotaion, expression, promoters, exon correlation, homology.</li>
                    <li><a href='<%=accessDir%>checkLogin.jsp?url=<%=qtlsDir%>qtlMain.jsp'>QTL Tools (login required)</a>-Tools to calculate QTLs, create QTL lists, view QTLs associated with genes.</li>
                </ul>
                
                
                
                <br/>
				<p>Click the Overview option above to see examples of what you can do on our site.  The options to the right of the Overview are the main areas of the site.  The functions with a <span style=" background-color:#2d7a32; color:#FFFFFF;">green background</span> indicate publicly accessible parts of the site, while the remaining functions with the <span style="background-color:#436f93; color:#FFFFFF;">blue background</span> require a login.</p>

            			<!--<p>View the <a href="<%=commonDir%>PhenoGenDemo.ppt"  
				title="Getting Started with PhenoGen Informatics Demo">Getting 
				Started With PhenoGen Informatics Demo</a> to learn how to get started.</p>

				<BR>-->
            			<p>Review the <a href="CurrentDataSets.jsp"  
				title="Current Datasets">current datasets</a> that we have available for public use.</p>
            
                        <H3 style="margin:10px;"> Why do we require a login?</H3>
                        <p>For many of the tools that require a login, there are multiple intermediate steps in the analisys or steps that may take a long time to complete.  Logging in, allows you to start a step and come back to the analysis/results at a later time.  A login also allows you to upload data to the site and keep it private or to share it with individuals you approve.</p>
                        
                       <h3 style="margin:10px;">Acknowledgements</h3>
                        <H4 style="margin:10px;">Funding</H4>
                        <p>We would like to thank the National Institue on Alcohol Abuse and Alcoholism (<a href="http://www.niaaa.nih.gov/">NIAAA</a>) for continued funding to develop and support this site.  The Banbury Fund for supporting the development of this site.</p>
                        <h4 style="margin:10px;">Recombinant Inbred Panels</h4>
                        <p>We are grateful to the following investigators for providing the recombinant inbred panels found on the site.<BR />
                        HXB/BXH Rat RI Panel was provided by <a href="http://pharmacology.ucsd.edu/faculty/printz.html">Morton Printz</a>(UC San Diego).<BR />
                        ILSXISS Mouse RI Panel was provided by <a href="http://ibgwww.colorado.edu/tj-lab/">Thomas Johnson</a>(CU Boulder) and <a href="http://profiles.ucdenver.edu/ProfileDetails.aspx?From=SE&Person=568">John DeFries</a>(CU Boulder).</p>
                
                	</div> <!-- // end overview-content -->
            	</div> <!-- // end overview-wrap -->
						
            	 <!--<div class="demoVideo" style="display:inline-block;float:right;position:relative;top:-450px; padding-right:10px;">
                        	<h3>Overview Video</h3>
                        	<video width="400" height="300" controls="controls">
                                <source src="<%=contextRoot%>web/demo/test.mp4" type="video/mp4">
                                <source src="<%=contextRoot%>web/demo/test.webm" type="video/webm">
                            
                              	<object data="<%=contextRoot%>web/demo/test.mp4" width="400" height="280">
                              	</object>
                        	</video>
                            <H3><a href="<%=contextRoot%>web/demo/mainDemo.jsp?file=<%=contextRoot%>web/demo/test." target="_blank">Open in a new Window</a></H3><BR />
                            <H3><a href="<%=contextRoot%>web/demo/mainDemo.jsp" target="_blank">View other demo videos</a></H3> 
                        </div>-->
	</div><!-- // end welcome -->
    