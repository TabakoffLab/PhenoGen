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

    

                	<H2>Statistics/Expression Values</H2>
                    <div id="accordion" style="height:100%;">
                    	<H3>Feature List</H3>
                        <div>
                        	Available only for gene lists created from analysis of arrays on PhenoGen.
                            <BR /><BR />
                            <ul>
                            	<li>Retreive the analysis statistics for the analysis that created the list.</li>
                            	<li>Retreive expression values for any dataset that uses the same arrays.  An example of this is a gene list created from the HXB/BXH panel in Brain will allow you to retreive expression values for the same probesets in the other tissues available.</li>
                            </ul>
                        </div>
                        <h3>Sample Screen Shots</h3>
                        <div style="text-align:center">
                   			Example output for analysis statistics from analysis that generated this list.
                            <img src="web/overview/glValues_stats.jpg"  style="width:100%;"/>
                   			Example of method to view expression values.   Unlike analysis statistics you may extract expression values from any dataset using the same arrays.
                        	<img src="web/overview/glValues_dataset.jpg"  style="width:100%;"/>
                            Example output for expression value from the selected dataset.
                        	<img src="web/overview/glValues_expression.jpg"  style="width:100%;"/>
                        </div>
                    </div>

    
    <script src="javascript/indexGraphAccordion.js">
						</script>