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

    
                	<H2>RNA-Seq Data</H2>
                    <div id="accordion" style="height:100%;">
                    	<H3>Description</H3>
                        <div>
                        	We have RNA-Seq data from two strains of rat brains, which consists of 3 samples of each of the HXB inbred panel parental strains(BN-Lx/CubPrin and SHR/OlaIpcvPrin). PolyA+ data is available from the Illumina platform and Total RNA from Helicos for both strains.<BR /><BR />
                        	The raw read data is downloadable as a compressed .sam file(Illumina/PolyA+) or .bed(Helicos/Total RNA). 
                            <BR /><BR />
                            More strains will become available so keep checking back.
                            <BR /><BR />
                            This data has been used to create a transcriptome reconstruction for rat brain.  The reconstructed transcripts are displayed alongside Ensembl transcripts with detailed Gene/Transcript inforamtion under <a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp">Detailed Genome/Transcription Information</a>.
                        </div>
                        <H3>Files Available</H3>
                        <div>
                        	<ul>
                            	<li>.sam files containing the raw reads(1 file per sample)(Illumina/PolyA+)</li>
                                <li>.bed files containing the raw reads(1 file per sample)(Helicos/Total RNA)</li>
                            </ul>
                        </div>
                    </div>
    
    <script src="javascript/indexGraphAccordion.js">
						</script>						

    