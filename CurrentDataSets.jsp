<%@ include file="/web/access/include/login_vars.jsp" %>
<%  pageTitle="Current Datasets";
    pageDescription="A list of public datasets available for download or analysis";
    extrasList.add("jquery.dataTables.js");
%>
<%@ include file="/web/common/header.jsp" %>
<div style="margin:10px;">
    <H2>Current Datasets</h2>
    <table id="datasets" name="items" class="list_base" cellpadding="0" cellspacing="0">
        <thead>
            <TR class="col_title">
                <TH>Species</TH>
                <TH>Animal Type</TH>
                <TH>Source Details</TH>
                <TH>Panel</TH>
                <TH>Tissue</TH>
                <TH>Array</TH>
                <TH>Number of Strains <span class="tooltip" title="Clink on the + icon to see a complete list of strains."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                <TH>Samples per Strain</TH>
            </TR>
        </thead>
        <tbody>
            <TR>
                <TD>Rat</td>
                <TD>Inbred Strains</TD>
                <TD>Adult Male</TD>
                <TD>HXB progenitors</td>
                <TD>Whole Brain</td>
                <TD>CodeLink Whole Genome</td>
                <TD><span class="trigger" name="str1"></span>3<BR>
                    <span id="str1" style="display:none">BN-Lx/CubPrin, SHR/OlaPrin, SHR-Lx/CubPrin</span>
                </TD>
                <TD>4-6</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Inbred Strains</TD>
                <TD>Adult Male</TD>
                <TD>6 Inbred Strains</td>
                <TD>Whole Brain</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str2"></span>6<BR>
                    <span id="str2" style="display:none">BN-Lx/CubPrin, PD/CubPrin, SHR/NCrlPrin, SHR/OlaPrin, SHR-Lx/CubPrin, WKY/NCrlPrin</span>
                </TD>
                <TD>4</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Inbred Strains</TD>
                <TD>Adult Male</TD>
                <TD>6 Inbred Strains</td>
                <TD>Heart - left ventrical</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str3"></span>6<BR>
                    <span id="str3" style="display:none">BN-Lx/CubPrin, PD/CubPrin, SHR/NCrlPrin, SHR/OlaPrin, SHR-Lx/CubPrin, WKY/NCrlPrin</span>
                </TD>
                <TD>4</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Inbred Strains</TD>
                <TD>Adult Male</TD>
                <TD>6 Inbred Strains</td>
                <TD>Liver</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str4"></span>6<BR>
                    <span id="str4" style="display:none">BN-Lx/CubPrin, PD/CubPrin, SHR/NCrlPrin, SHR/OlaPrin, SHR-Lx/CubPrin, WKY/NCrlPrin</span>
                </TD>
                <TD>4</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Inbred Strains</TD>
                <TD>Adult Male</TD>
                <TD>6 Inbred Strains</td>
                <TD>Brown fat</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str5"></span>6<BR>
                    <span id="str5" style="display:none">BN-Lx/CubPrin, PD/CubPrin, SHR/NCrlPrin, SHR/OlaPrin, SHR-Lx/CubPrin, WKY/NCrlPrin</span>
                </TD>
                <TD>4</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Inbred Strains</TD>
                <TD>Kupffer cells(fresh/cultured/MACS)</TD>
                <TD>4 Inbred Strains</td>
                <TD>Liver (cells)</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str6"></span>4<BR>
                    <span id="str6" style="display:none">BN-Lx/CubPrin, PD/CubPrin, SHR/NCrlPrin, SHR/OlaPrin</span>
                </TD>
                <TD>4</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Inbred Strains</TD>
                <TD>Hepatic Stellate cells (fresh)</TD>
                <TD>4 Inbred Strains</td>
                <TD>Liver (cells)</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str7"></span>4<BR>
                    <span id="str7" style="display:none">BN-Lx/CubPrin, PD/CubPrin, SHR/NCrlPrin, SHR/OlaPrin</span></TD>
                <TD>4</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Inbred Strains</TD>
                <TD>Hepatocyte cells (fresh/cultured)</TD>
                <TD>4 Inbred Strains</td>
                <TD>Liver (cells)</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str8"></span>4<BR>
                    <span id="str8" style="display:none">BN-Lx/CubPrin, PD/CubPrin, SHR/NCrlPrin, SHR/OlaPrin</span>
                </TD>
                <TD>4</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Inbred Strains</TD>
                <TD>Sinusoidal endothelial cells (fresh/cultured)</TD>
                <TD>4 Inbred Strains</td>
                <TD>Liver (cells)</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str9"></span>4<BR>
                    <span id="str9" style="display:none">BN-Lx/CubPrin, PD/CubPrin, SHR/NCrlPrin, SHR/OlaPrin</span>
                </TD>
                <TD>4</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Recombinant Inbred Panels</TD>
                <TD>Adult Male</TD>
                <TD>HXB RI</td>
                <TD>Whole Brain</td>
                <TD>CodeLink Whole Genome</td>
                <TD><span class="trigger" name="str10"></span>28<BR>
                    <span id="str10" style="display:none">BN-Lx/CubPrin, BXH08, BXH10, BXH11, BXH12, BXH13, BXH5, BXH6, BXH8, BXH9, HXB1, HXB10, HXB13, HXB15, HXB17, HXB18, HXB2, HXB20, HXB23, HXB25, HXB26, HXB27, HXB29, HXB3, HXB31, HXB4, HXB7, SHR/OlaPrin</span>
                </TD>
                <TD>4-6</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Recombinant Inbred Panels</TD>
                <TD>Adult Male</TD>
                <TD>HXB RI</td>
                <TD>Whole Brain</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str11"></span>23<BR>
                    <span id="str11" style="display:none">BN-Lx/CubPrin, BXH08, BXH10, BXH11, BXH13, BXH6, HXB1, HXB10, HXB13, HXB15, HXB17, HXB18, HXB2, HXB23, HXB25, HXB26, HXB27, HXB29, HXB3, HXB31, HXB4, HXB7, SHR/OlaPrin</span>
                </TD>
                <TD>3-4</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Recombinant Inbred Panels</TD>
                <TD>Adult Male</TD>
                <TD>HXB RI</td>
                <TD>Heart - left ventrical</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str12"></span>23<BR>
                    <span id="str12" style="display:none">BN-Lx/CubPrin, BXH08, BXH10, BXH11, BXH13, BXH6, HXB1, HXB10, HXB13, HXB15, HXB17, HXB18, HXB2, HXB23, HXB25, HXB26, HXB27, HXB29, HXB3, HXB31, HXB4, HXB7, SHR/OlaPrin</span>
                </TD>
                <TD>3-4</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Recombinant Inbred Panels</TD>
                <TD>Adult Male</TD>
                <TD>HXB RI</td>
                <TD>Liver</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str13"></span>23<BR>
                    <span id="str13" style="display:none">BN-Lx/CubPrin, BXH08, BXH10, BXH11, BXH13, BXH6, HXB1, HXB10, HXB13, HXB15, HXB17, HXB18, HXB2, HXB23, HXB25, HXB26, HXB27, HXB29, HXB3, HXB31, HXB4, HXB7, SHR/OlaPrin</span>
                </TD>
                <TD>3-4</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Recombinant Inbred Panels</TD>
                <TD>Adult Male</TD>
                <TD>HXB RI</td>
                <TD>Brown Fat</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str14"></span>21<BR>
                    <span id="str14" style="display:none">BN-Lx/CubPrin, BXH08, BXH10, BXH11, BXH13, BXH6, HXB10, HXB13, HXB15, HXB17, HXB18, HXB2, HXB23, HXB25, HXB26, HXB27, HXB29, HXB3, HXB4, HXB7, SHR/OlaPrin</span>
                </TD>
                <TD>3-4</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Selected Lines</TD>
                <TD>Adult Male</TD>
                <TD>8 pairs</td>
                <TD>Whole Brain</td>
                <TD>CodeLink Whole Genome</td>
                <TD><span class="trigger" name="str15"></span>8<BR>
                    <span id="str15" style="display:none">AA/ANA, HAD1/LAD1, HAD2/LAD2, IHAS1/ILAS1, IHAS2/ILAS2, P/NP, sP/sNP, UChB/UChA</span>
                </TD>
                <TD>4-6</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>Selected Lines</TD>
                <TD>Adult Male</TD>
                <TD>6 pairs</td>
                <TD>Whole Brain</td>
                <TD>Affymetrix Rat Exon Array</td>
                <TD><span class="trigger" name="str16"></span>6<BR>
                    <span id="str16" style="display:none">AA/ANA, HAD1/LAD1, HAD2/LAD2, P/NP, sP/sNP, UChB/UChA</span>
                </TD>
                <TD>4-6</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>HXB progenitors</TD>
                <TD>Adult Male</TD>
                <TD></td>
                <TD>Whole Brain</td>
                <TD>RNA-Seq of total RNA(Helicos)</td>
                <TD>BN-Lx and SHR</TD>
                <TD>3/strain (70M reads/sample)</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>HXB progenitors</TD>
                <TD>Adult Male</TD>
                <TD></td>
                <TD>Whole Brain</td>
                <TD>RNA-Seq of total RNA(Illumina)</td>
                <TD>BN-Lx and SHR</TD>
                <TD>3/strain (100M reads/sample)</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>HXB progenitors</TD>
                <TD>Adult Male</TD>
                <TD></td>
                <TD>Whole Brain</td>
                <TD>RNA-Seq of PolyA+ RNA(Illumina)</td>
                <TD>BN-Lx and SHR</TD>
                <TD>3/strain (50M reads/sample)</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>HXB progenitors</TD>
                <TD>Adult Male</TD>
                <TD></td>
                <TD>Whole Brain</td>
                <TD>RNA-Seq of small RNA(Illumina)</td>
                <TD>BN-Lx and SHR</TD>
                <TD>3/strain</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>HXB progenitors</TD>
                <TD>Adult Male</TD>
                <TD></td>
                <TD>Liver</td>
                <TD>RNA-Seq of total RNA(Illumina)</td>
                <TD>BN-Lx and SHR</TD>
                <TD>3/strain (80M reads/sample)</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>HXB progenitors</TD>
                <TD>Adult Male</TD>
                <TD></td>
                <TD>Liver</td>
                <TD>RNA-Seq of small RNA(Illumina)</td>
                <TD>BN-Lx and SHR</TD>
                <TD>2-3/strain</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>HXB progenitors</TD>
                <TD>Adult Male</TD>
                <TD></td>
                <TD>Heart</td>
                <TD>RNA-Seq of total RNA(Illumina)</td>
                <TD>BN-Lx and SHR</TD>
                <TD>4/strain (90M reads/sample)</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>HXB progenitors</TD>
                <TD>Adult Male</TD>
                <TD></td>
                <TD>Heart</td>
                <TD>RNA-Seq of small RNA(Illumina)</td>
                <TD>BN-Lx and SHR</TD>
                <TD>3/strain</TD>
            </TR>
            <TR>
                <TD>Rat</td>
                <TD>HXB progenitors</TD>
                <TD>Adult Male</TD>
                <TD></td>
                <TD>Liver</td>
                <TD>Full genome sequencing</td>
                <TD><span class="trigger" name="str17"></span>4<BR>
                    <span id="str17" style="display:none">BN-Lx/CubPrin, SHR/OlaIpcvPrin, SHR/NCrlPrin, presumptive F344</span>
                </TD>
                <TD>2/strain</TD>
            </TR>
            <TR>
                <TD>Mouse</td>
                <TD>Inbred Strains</TD>
                <TD>Adult Male</TD>
                <TD>28 inbred strains</td>
                <TD>Whole Brain</td>
                <TD>Affymetrix Mouse 430 v2</td>
                <TD><span class="trigger" name="str18"></span>28<BR>
                    <span id="str18" style="display:none">129P3/J, 129S1/SvImJ, 129X1/SvJ, A/J, AKR/J, Balb/cJ, BTBR T+tf/J, Balb/cByJ, C3H/HeJ, C57BL/6J, C58/J, CAST/EiJ, CBA/J, DBA/2J, FVB/NJ, ILS, ISS, KK/H1J, LP/J, Molf/EiJ, NOD/LtJ, NZO/HILtJ, NZW/LacJ, PWD/PhJ, PWK/PhJ, SJL/J, SPRET/EiJ, WSB/EiJ</span>
                </TD>
                <TD>4-6</TD>
            </TR>
            <TR>
                <TD>Mouse</td>
                <TD>Inbred Strains</TD>
                <TD>Adult Male</TD>
                <TD>4 inbred strains</td>
                <TD>Whole Brain</td>
                <TD>Affymetrix Mouse Exon Array</td>
                <TD><span class="trigger" name="str19"></span>4<BR>
                    <span id="str19" style="display:none">C57BL/6J, DBA/2J, ILS, ISS</span></TD>
                <TD>3-36</TD>
            </TR>
            <TR>
                <TD>Mouse</td>
                <TD>Recombinant Inbred Panels</TD>
                <TD>Adult Male</TD>
                <TD>BXD RI</td>
                <TD>Whole Brain</td>
                <TD>Affymetrix Mouse 430 v2</td>
                <TD><span class="trigger" name="str20"></span>32<BR>
                    <span id="str20" style="display:none">BXD1, BXD2, BXD5, BXD6, BXD8, BXD9, BXD11, BXD12, BXD13, BXD14, BXD15, BXD16, BXD18, BXD19, BXD21, BXD22, BXD23, BXD24, BXD27, BXD28, BXD29, BXD31, BXD32, BXD33, BXD34, BXD36, BXD38, BXD39, BXD40, BXD42, DBA, C57</span></TD>
                <TD>4-7</TD>
            </TR>
            <TR>
                <TD>Mouse</td>
                <TD>Recombinant Inbred Panels</TD>
                <TD>Adult Male</TD>
                <TD>LXS RI</td>
                <TD>Whole Brain</td>
                <TD>Affymetrix Mouse Exon Array</td>
                <TD><span class="trigger" name="str21"></span>61<BR>
                    <span id="str21" style="display:none">LXS100, LXS101, LXS102, LXS103, LXS107, LXS110, LXS112, LXS114, LXS115, LXS122, LXS123, LXS13, LXS14, LXS16, LXS19, LXS22, LXS23, LXS24, LXS25, LXS26, LXS28, LXS3, LXS32, LXS34, LXS36, LXS39, LXS41, LXS42, LXS43, LXS46, LXS48,  LXS5, LXS50, LXS52, LXS60, LXS64, LXS66, LXS7, LXS70, LXS72, LXS73, LXS75, LXS76, LXS78, LXS8, LXS80, LXS84, LXS86, LXS87, LXS89, LXS9, LXS90, LXS92, LXS93, LXS94, LXS96, LXS97, LXS98, LXS99, ILS, ISS</span></TD>
                <TD>4-6</TD>
            </TR>
            <TR>
                <TD>Mouse</td>
                <TD>Selected Lines</TD>
                <TD>Adult Male</TD>
                <TD>7 pairs</td>
                <TD>Whole Brain</td>
                <TD>Affymetrix Mouse 430 v2</td>
                <TD><span class="trigger" name="str22"></span>7<BR>
                    <span id="str22" style="display:none">HAFT1/LAFT1, HAFT2/LAFT2, HAP1/LAP1, HAP2/LAP2, HAP3/LAP3, iHAFT/iLAFT, ILS/ISS</span></TD>
                <TD>4-6</TD>
            </TR>
            <TR>
                <TD>Mouse</td>
                <TD>Genetically Modified</TD>
                <TD>Adult Male</TD>
                <TD>8 pairs</td>
                <TD>multiple</td>
                <TD>Affymetrix Mouse 430 v2</td>
                <TD><span class="trigger" name="str23"></span>8 pairs<BR>
                    <span id="str23" style="display:none">Fyn KO, Maob KO, Maoa KO, Maoa and Maob KO, P14TCR transgenic, Spinophilin KO, AC7 transgentic, AC7 KO</span></TD>
                <TD>3-6</TD>
            </TR>
            <TR>
                <TD>Mouse</td>
                <TD>LXS progenitors</TD>
                <TD>Adult Male</TD>
                <TD></td>
                <TD>Whole Brain</td>
                <TD>RNA-Seq of total RNA(Illumina)</td>
                <TD>ILS and ISS</TD>
                <TD>3/strain (70M reads/sample)</TD>
            </TR>
        </tbody>
    </table>
</div>
<script type="text/javascript">
    var tblData=$('#datasets').dataTable({
        "bPaginate": false,
	"sScrollX": "100%",
	"sScrollY": "100%",
	"sDom": '<"leftSearch"fr><t>'
	});
        
    $(".trigger").on("click",function(){
            $(this).toggleClass("less");
            var id=$(this).attr("name");
            if($("#"+id).is(":visible")){
                $("#"+id).hide();
            }else{
                $("#"+id).show();
            }
    });
    $(".tooltip").tooltipster({
		position: 'top-right',
		maxWidth: 250,
		offsetX: 5,
		offsetY: 5,
		contentAsHTML:true,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
	});
</script>
	<%@ include file="/web/common/basicFooter.jsp" %>
