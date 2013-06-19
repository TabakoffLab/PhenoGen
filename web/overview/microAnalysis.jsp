<%@ include file="/web/common/headerOverview.jsp" %>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

    
	<H2>Normalize->Statistics->Gene List</H2>
                    <div id="accordion" style="height:100%;">
                    	<H3>Feature List</H3>
                        <div>
                        	General analysis flow chart
                   			<img src="web/overview/microAnalysis_flowchart.jpg"  style="width:100%;"/>
                        <ul>
                        	<li>Create Dataset</li>
                            	<ul>
                                	<li>Datasets can be created from any public arrays on the site</li>
                                    <li>Datasets can be created from any private arrays that you have been given access to.</li>
                                </ul> 
                            <li>Run Quality Control</li>
                            	<ul>
                                	<li>Quality Control allows you the opportunity to evaluate each array included in the dataset</li>
                                    <li>Once you approve you may continue to normalization</li>
                                    <li>This is the only point where you may remove arrays if you wish at which time you'll need to rerun QC.</li>
                                </ul> 
                            <li>Normalize</li>
                            	<ul>
                                	<li>You need to create at least one normalized version.  This lets you choose the normalization method.</li>
                                    <li>You may always create additional normalized versions.  For analysis you will be able to choose from any normalized version.</li>
                                    <li>You will also need to decide how to group the arrays.  For example you might group a dataset made up of different strains by strain.  Although you may always create another grouping and normalized version.</li>
                                    <li>For some arrays you may have to decide on the level of probes you want to include and/or what level of them to include.  For example the Affy Rat or Mouse Exon array can be analyzed at the Gene or Exon level and including probesets with varying levels of confidence in their annotation.</li>
                                </ul> 
                            <li>Filter</li>
                            	<ul>
                                	<li>To save time and reduce the list of probes at the end of the analysis it is recommended to perform some filtering.</li>
                                    <li>Filters vary based on the type of array used however they generally include:</li>
                                    	<ul>
                                        	<li>Control Probe Filter - Remove control probes</li>
                                            <li>Detection Above Background Filter - Keep/Remove probes not detected above background in a combination of samples you can specify</li>
                                            <li>Heritability Filter - If available removes probes below a given threshold of heritability in one of the available Recombinant Inbred Panels.</li>
                                            <li>Gene List Filter - Removes probes not found in a given gene list.</li>
                                            <li>bQTL Filter - If available removes probes not located in the bQTL regions of the list.</li>
                                        </ul>
                                </ul> 
                            <li>Statistics</li>
                            	<ul>
                                	<li>Correlation-Correlation of expression to phenotype data.</li>
                                    <li>Differential Expression-Differential expression between groups used for normalization.</li>
                                    <li>Clustering-Supports a number of clustering methods so you can find clusters of interest.</li>
                                </ul> 
                            <li>Gene List</li>
                            	<ul>
                                	<li>Finally from the results of the statistical analysis you can save gene lists.</li>
                                    <li>From gene lists a number of additional tools are available.  Please see the gene list section for a detailed description.</li>
                                </ul>                            
                        </ul>
                        </div>
                    	<h3>Sample Screen Shots</h3>
                        <div style="text-align:center">
                        	<a class="fancybox" rel="fancybox-thumb" href="web/overview/" title=""><img src="web/overview/"  style="width:100%;" title="Click to view a larger image"/></a>
                        </div>
                        
                   </div>

<script src="javascript/indexGraphAccordion.js">
						</script>