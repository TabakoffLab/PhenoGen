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

    
	<div style="width:100%; height:100%;">
                	<H2>Promoter Analysis</H2>
                    <div id="accordion" style="height:100%;">
                    	<H3>Feature List</H3>
                        <div>
                        	Analyze promoters for all the genes in a gene list.  Support for oPOSSUM v2 and MEME v4.9 patch2 or extract upstream sequence for your own analsysis to a downloadable .fasta file.
                            
                            <ul>
                            	<li>oPOSSUM v2 (Mouse Only)</li>
                                <li>MEME v4.9 patch 2</li>
                                <li>upstream sequence extraction</li>
                           </ul>
                            
                             
                        </div>
                        <h3>Sample Screen Shots</h3>
                        <div style="text-align:center">
                   			Overview of promotor page
                        	<img src="web/overview/glPromoter_ovrvw.jpg"  style="width:100%;"/>
                            Example of oPOSSUM output
                        	<img src="web/overview/glPromoter_opossum.jpg"  style="width:100%;"/>
                            Example of MEME output
                        	<img src="web/overview/glPromoter_meme.jpg"  style="width:100%;"/>
                            Example of upstream extraction output
                        	<img src="web/overview/glPromoter_upstream.jpg"  style="width:100%;"/>
                        </div>
                    </div>
    </div> <!-- // end overview-wrap -->
    
    <script type="text/javascript">
		$('#accordion').accordion({ heightStyle: "fill" });
	</script>