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

    

                	<H2>WGCNA</H2>
                        <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:25%;width:100%;">
                            <table>
                            <TR>
                                <TD>
                            	<span class="tooltip"  title="Example Module view showing the transcripts/genes in a module and the correlation between their expression.<BR>Click to view a larger image.">
                                <a class="fancybox" rel="fancybox-thumb" href="web/overview/browseWGCNA.png" title="Example Module view showing the transcripts/genes in a module and the correlation between their expression.">
                                    <img src="web/overview/browseWGCNA_150.png" title="Click to view a larger image" /></a></span>
                                </TD>
                                <TD>
                                    <span class="tooltip"  title="Example Eigengene eQTL view showing the locci correlated with expression.<BR>Click to view a larger image.">
                                <a class="fancybox" rel="fancybox-thumb" href="web/overview/browseWGCNA_eQTL.png" title="Example Eigengene eQTL view showing the locci correlated with expression.">
                                    <img src="web/overview/browseWGCNA_eQTL_150.png" title="Click to view a larger image" /></a></span>
                                </TD>
                                <TD>
                                    <span class="tooltip"  title="Example Gene Ontology sunburst plot.  Showing a variable number of levels of the GO term tree for one of the three domains.<BR>Click to view a larger image.">
                                <a class="fancybox" rel="fancybox-thumb" href="web/overview/browseWGCNA_go.png" title="Example Gene Ontology sunburst plot.  Showing a variable number of levels of the GO term tree for one of the three domains.">
                                    <img src="web/overview/browseWGCNA_go_150.png"  title="Click to view a larger image" /></a></span>
                                </TD>
                                <TD>
                                    <span class="tooltip"  title="Example miRNA image summarizing multiMiR results which indicate miRNAs predicted or validated to target genes in the module.<BR>Click to view a larger image.">
                                <a class="fancybox" rel="fancybox-thumb" href="web/overview/browseWGCNA_mir.png" title="Example miRNA image summarizing multiMiR results which indicate miRNAs predicted or validated to target genes in the module.">
                                    <img src="web/overview/browseWGCNA_mir_150.png"  title="Click to view a larger image" /></a></span>
                                </TD>
                            </TR>
                            </table>
                            </div>
                        Weighted Gene Co-expression Network Analysis (WGCNA)<BR><BR>
                    	<H3>Feature List</H3>
                        <div>
                            
                                                    <ul>
                                                        <li>Available as a new tab under any gene list for both Mouse and Rat Brain</li>
                                                        <li>Module View:
                                                            <ul>
                                                                <li>Transcripts both Ensembl Annotated and RNA-Seq reconstructed</li>
                                                                <li>Transcripts connectedness showing positive and negative correlation of transcript expression.</li>
                                                                <li>View graphic form and CSV exportable table form.</li>
                                                            </ul>
                                                        </li>
                                                        <li>eQTL Module View:
                                                            <ul>
                                                                <li>View CIRCOS plot:
                                                                    <ul>
                                                                        <li>Genome with regions below the selected P-value cutoff highlighted.</li>
                                                                        <li>Customizable with include/exclude chromosomes and adjust P-value cutoff.</li>
                                                                        <li>View graphic form and CSV exportable table form.</li>
                                                                    </ul>
                                                                </li>
                                                                <li>CSV exportable table form with SNP name/location and P-value.</li>
                                                            </ul>
                                                        </li>
                                                        <li>Gene Ontology View:
                                                            <ul>
                                                                <li>View an interactive expandable sunburst plot of each GO Domain(Biological Process, Molecular Function, and Cellular Component). Provides a summary of all the GO terms assigned to genes in the module.</li>
                                                                <li>View graphic form and CSV exportable table form.  Both are interactive and can be used to explore the GO term tree.</li>
                                                            </ul>
                                                        </li>
                                                        <li>miRNA targeting (multiMiR) View:
                                                            <ul>
                                                                <li>View/Filter miRNAs that target genes in the module.  Visualize targets of miRNAs and the correlation between genes targeted.  Filter to look at specific miRNAs or miRNAs targeting specific genes.</li>
                                                                <li>View graphic form and CSV exportable table form.</li>
                                                            </ul>
                                                        </li>
                                                    </ul>
                        </div>
                        <BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp" class="button" style="width:170px;color:#666666;">Login to View Gene Lists</a><BR />or<BR /><a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                        
                    </div>

    
<%@ include file="/web/overview/ovrvw_js.jsp" %>