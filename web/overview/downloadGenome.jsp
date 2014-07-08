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

                	<H2>Strain Specific Genomes</H2>
                    <div style="height:100%;">
                    	<H3>Description</H3>
                        <div>
                        	We have sequenced each of the HXB inbred panel parental strains(BN-Lx/CubPrin and SHR/OlaIpcvPrin).  Sequences were aligned to the reference BN(Rn5) genome.  SNPs and short Indels were identified.  The download currently only contains the alignment with SNPs.
                            <BR /><BR />
                            All identified SNPs/Indels can be displayed when you view a gene or region under <a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp">Detailed Genome/Transcription Information</a>.
                        </div>
                        <BR /><BR />
                        <H3>Files Available</H3>
                        <div>
                        	<ul>
                            	<li>.fasta files with one entry per chromosome.  Aligned to the Rn5 reference(BN strain genome) with strain specific SNPs, but without any identified Indels.</li>
                            </ul>
                        </div>
                        <BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=sysBioDir%>resources.jsp" class="button" style="width:140px;color:#666666;">Go To Download</a>
                        </div>
                    </div>
    
    <script src="javascript/indexGraphAccordion1.0.js">
						</script>						

    