        <div id="legend_box">
        		<table class="list_base">
                    <tbody>
                    <%if(!region){%>
                             <TR ><TD colspan="2" style="margin-top:15px;">Tracks - All Non-Masked Probesets and Probsets Detected Above Background >1% of samples</TD></TR>
                            <TR>
                                <TD class="corePS"></TD>
                                <TD>Core</TD>
                            </TR>
                            <TR>
                                <TD class="extendedPS"></TD>
                                <TD>Extended</TD>
                            </TR>
                            <TR>
                                <TD class="fullPS"></TD>
                                <TD>Full</TD>
                            </TR>
                            <TR>
                                <TD class="ambPS"></TD>
                                <TD>Ambiguous</TD>
                            </TR>
                	<%}%>   
                 <TR><TD colspan="2" <%if(!region){%>style="padding-top:15px;"<%}%>>Track - Protein Coding<%if(myOrganism.equals("Rn")){%>/PolyA+<%}%></TD></TR>
                <TR >
                	<TD class="coding ensembl odd" width="15%"></TD>
                    <TD>Ensembl Transcripts</TD>
                </TR>
                <TR>
                	<TD class="coding odd"></TD>
                    <TD>Phenogen RNA-Seq (CuffLinks) Transcripts</TD>
                </TR>
                
                <TR ><TD colspan="2" style="padding-top:15px;">Track - Long Non-Coding<%if(myOrganism.equals("Rn")){%>/NonPolyA+<%}%></TD></TR>
                <TR>
                	<TD class="noncoding ensembl odd"></TD>
                    <TD>Ensembl Long Non-Coding</TD>
                </TR>
                <TR>
                	<TD class="noncoding odd"></TD>
                    <TD>Non-PolyA+ PhenoGen RNA-Seq</TD>
                </TR>
         
                <TR ><TD colspan="2" style="padding-top:15px;">Track - Small RNA</TD></TR>
                <TR>
                	<TD class="smallnc odd"></TD>
                    <TD>Ensembl Small RNA <200bp</TD>
                </TR>
                <TR>
                	<TD class="smallnc ensembl odd"></TD>
                    <TD>PhenoGen Small RNA <200bp</TD>
                </TR>
                
      
                <TR ><TD colspan="2" style="padding-top:15px;">Track - SNPs/Indels (Image only)</TD></TR>
                <TR>
                	<TD class="snp bnlx"></TD>
                    <TD>SNP BN-Lx</TD>
                </TR>
                <TR>
                	<TD class="indel bnlx"></TD>
                    <TD>Indel BN-Lx</TD>
                </TR>
                <TR>
                	<TD class="snp shrh"></TD>
                    <TD>SNP SHR</TD>
                </TR>
                <TR>
                	<TD class="indel shrh"></TD>
                    <TD>Indel SHR</TD>
                </TR>
                
                <TR  ><TD colspan="2" style="padding-top:15px;">Track - Helicos (Image only)</TD></TR>
                <TR>
                	<TD class="helicos"></TD>
                    <TD>Read Depth from Helicos</TD>
                </TR>
                
                
                </tbody>
                </table>
        </div> <!-- // end legend -->

