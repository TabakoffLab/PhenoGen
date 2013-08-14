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
                    <div id="accordion" style="height:100%;">
                    	<H3>Description</H3>
                        <div>
                        	We have RNA-Seq data from two strains of rat brains, which consists of 3 samples of each of the HXB inbred panel parental strains(BN-Lx/CubPrin and SHR/OlaIpcvPrin). PolyA+, Total RNA (>200 nt) after ribosomal RNA depletion, and Small RNA data is available from the Illumina platform and Total RNA from Helicos for both strains.<BR /><BR />
                        	The raw read data is downloadable as a  .bam file(Illumina/PolyA+,Totatl RNA, Small RNA) or .bed(Helicos/Total RNA). 
                            <BR /><BR />
                            More strains will become available so keep checking back.
                            <BR /><BR />
                            The data is summarized in new graphics. <BR />
                            <a href="web/graphics/genome.jsp">View Genome Coverage<BR /><img src="<%=imagesDir%>rnaseq_genome.gif" width="200px"/></a><BR />
                        	<a href="web/graphics/transcriptome.jsp">View Reconstructed Long RNA Genes(Rat Brain Transcriptome)<BR /><img src="<%=imagesDir%>rnaseq_transcriptome.gif" width="200px"/></a>
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
                    </div>
    
    <script src="javascript/indexGraphAccordion.js">
						</script>						

    