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

    
                	<H2>RNA-Seq Data</H2>
                    <div  style="overflow:auto;height:92%;">
                    	<H3>Data Summary Graphics</H3>
                        <div style="overflow:auto;display:inline-block;height:34%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                            <span class="tooltip" title="Interactive Genome Coverage Graphic">
                            <a href="<%=contextRoot%>web/graphics/genome.jsp"><img src="<%=imagesDir%>rnaseq_genome_150.gif"/></a>
                            </span>
                            </TD>
                            <TD>
                            <span class="tooltip" title="Interactive Reconstructed Long RNA Genes(Rat Brain Transcriptome)">
                            <a href="<%=contextRoot%>web/graphics/transcriptome.jsp"><img src="<%=imagesDir%>rnaseq_transcriptome_150.gif" /></a>
                            </span>
                            </TD>
                            </TR>
                            </table>
                         </div>
                    	<H3>Description</H3>
                        <div>
                        	We have RNA-Seq data from two strains of rat brains, which consists of 3 samples of each of the HXB inbred panel parental strains(BN-Lx/CubPrin and SHR/OlaIpcvPrin). PolyA+, Total RNA (>200 nt) after ribosomal RNA depletion, and Small RNA data is available from the Illumina platform and Total RNA from Helicos for both strains.<BR /><BR />
                        	The raw read data is downloadable as a  .bam file(Illumina/PolyA+,Total RNA, Small RNA) or .bed(Helicos/Total RNA). 
                            <BR /><BR />
                            More strains will become available so keep checking back.
                            <BR /><BR />
                            This data has been used to create a transcriptome reconstruction for rat brain.  The reconstructed transcripts are displayed alongside Ensembl transcripts with detailed gene/transcript information under <a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp">Detailed Genome/Transcription Information</a>.
                        </div>
                        <H3>Files Available</H3>
                        <div>
                        	<ul>
                            	<li>.bam files containing the raw reads(1 file per sample)(Illumina/PolyA+)</li>
                                <li>.bed files containing the raw reads(1 file per sample)(Helicos/Total RNA)</li>
                            </ul>
                        </div>
                        <BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=sysBioDir%>resources.jsp" class="button" style="width:140px;color:#666666;">Go To Download</a><BR />
                            or View:<BR />
                            <span class="tooltip" title="Interactive Genome Coverage Graphic"><a href="<%=contextRoot%>web/graphics/genome.jsp"><img src="<%=imagesDir%>rnaseq_genome_150.gif" width="125px"/></a></span>
                        	<span class="tooltip" title="Interactive Reconstructed Long RNA Genes(Rat Brain Transcriptome)"><a href="<%=contextRoot%>web/graphics/transcriptome.jsp"><img src="<%=imagesDir%>rnaseq_transcriptome_150.gif" width="125px"/></a></span>
                        </div>
                    </div>
    
<%@ include file="/web/overview/ovrvw_js.jsp" %>					

    