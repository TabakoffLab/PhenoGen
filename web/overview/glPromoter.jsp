<%@ include file="/web/access/include/login_vars.jsp" %>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
                	<H2>Promoter Analysis</H2>
                    <div id="accordion" style="height:100%;">
                    	<H3>Feature List</H3>
                        <div>
                        	Analyze promoters for all the genes in a gene list. PhenoGen supports the following 3 methods for promoter analysis.
                              <ul>
                            	<li><a href="http://burgundy.cmmt.ubc.ca/oPOSSUM/" target="_blank">oPOSSUM v2</a> (Mouse Only)</li>
                                <li><a href="http://meme.nbcr.net/meme/cgi-bin/meme.cgi" target="_blank">MEME v4.9 patch 2</a></li>
                                <li>upstream sequence extraction to a downloadable .fasta file for your own analysis</li>
                           </ul>
                            
                             
                        </div>
                        <h3>Sample Screen Shots</h3>
                        <div style="text-align:center">
                   			Overview of promoter page
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glPromoter_ovrvw.jpg" title="Overview of promotor page"><img src="web/overview/glPromoter_ovrvw.jpg"  style="width:100%;" title="Click to view a larger image"/></a>
                            Example of oPOSSUM output
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glPromoter_opossum.jpg" title="Example of oPOSSUM output"><img src="web/overview/glPromoter_opossum.jpg"  style="width:100%;" title="Click to view a larger image"/></a>
                            Example of MEME output
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glPromoter_meme.jpg" title="Example of MEME output"><img src="web/overview/glPromoter_meme.jpg"  style="width:100%;" title="Click to view a larger image"/></a>
                            Example of upstream extraction output
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/glPromoter_upstream.jpg" title="Example of upstream extraction output"><img src="web/overview/glPromoter_upstream.jpg"  style="width:100%;" title="Click to view a larger image"/></a>
                        </div>
                    </div>
    
    <script src="javascript/indexGraphAccordion.js">
						</script>