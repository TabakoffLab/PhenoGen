
<script type="text/javascript">
var trackString="probe,numExonPlus,numExonMinus,refseq";
var minCoord=<%=min%>;
var maxCoord=<%=max%>;
var chr="<%=chromosome%>";
var filterExpanded=0;
var organism="<%=myOrganism%>";
var ucscgeneID="<%=selectedEnsemblID%>";
var ucsctype="Gene";
</script>


<% 
//ERROR SECTION: NO ENSEMBL ID
	HashMap skipSMRNA=new HashMap();
	ArrayList<SmallNonCodingRNA> smncRNA=gdt.getSmallNonCodingRNA(min,max,chromosome,rnaDatasetID,myOrganism);
	
	//Match smncRNA to ensembl based on annotations
	
	for(int m=0;m<smncRNA.size();m++){
		SmallNonCodingRNA tmpRNA=smncRNA.get(m);
		ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation> tmpAnnot=tmpRNA.getAnnotationBySource("Ensembl");
		if(tmpAnnot!=null&&tmpAnnot.size()>0){
			boolean found=false;
			String smncEnsID=tmpAnnot.get(0).getEnsemblGeneID();
			for(int n=0;n<fullGeneList.size()&&!found;n++){
				if(fullGeneList.get(n).getGeneID().equals(smncEnsID)){
					fullGeneList.get(n).addTranscript(tmpRNA);
					//smncRNA.remove(m);
					skipSMRNA.put(tmpRNA.getID(),1);
					found=true;
					//m--;
				}
			}
		}
	}
	
	String tmpURL=genURL.get(0);
	int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
	String folderName=tmpURL.substring(second+1,tmpURL.length()-1);
	DecimalFormat dfC = new DecimalFormat("#,###");
	String gcPath=applicationRoot + contextRoot+"tmpData/geneData/" +firstEnsemblID.get(selectedGene) + "/";
if(displayNoEnsembl){ %>
	<BR /><div> The Gene ID entered could not be translated to an Ensembl ID so that we can pull up gene information.  Please try an alternate Gene ID.  This gene ID has been reported so that we can improve the translation of many Gene IDs to Ensembl Gene IDs.  <BR /><BR /><b>Note:</b> at this time if there is no annotation in Ensembl for a gene we will not currently be able to display information about it, however if you have found your gene of interest on Ensembl and cannot enter a different Gene ID above entering the Ensembl Gene ID should work.</div>
<% } %>

<%if(genURL.size()>0){%>
<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000;text-align:center; width:100%;">
    	<span class="triggerImage less" name="collapsableImage" >UCSC Genome Browser Image</span>
    	<div class="inpageHelp" style="display:inline-block;"><img id="Help2" class="helpImage" src="../web/images/icons/help.png" /></div>
        <span style="font-size:12px; font-weight:normal;">
        <input name="imageSizeCbx" type="checkbox" id="imageSizeCbx" checked="checked" /> Scroll Image - Viewable Size:
        <select name="imageSizeSelect" id="imageSizeSelect">
        		<option value="200" >Smaller</option>
            	<option value="400" selected="selected">Normal</option>
                <option value="600" >Larger</option>
                <option value="800" >Largest</option>
            </select>
        </span>
    </div>
    <div style="border-color:#CCCCCC; border-width:1px; border-style:inset; text-align:center;">
        
        <div id="collapsableImage" class="geneimage" >
       		<div id="imgLoad" style="display:none;"><img src="<%=imagesDir%>ucsc-loading.gif" /></div>
            <div id="geneImage" class="ucscImage"  style="display:inline-block; height:400px; width:980px; overflow:auto;">
            	<a class="fancybox fancybox.iframe" href="<%=ucscURL.get(0)%>" title="UCSC Genome Browser">
            	<img src="<%= contextRoot+"tmpData/geneData/"+selectedEnsemblID+"/ucsc.probe.numExonPlus.numExonMinus.refseq.png"%>"/></a>
            </div>
        </div><!-- end geneimage div -->
    	<div class="geneimageControl">
      		
          	<form>
            <table style="text-align:left; width:100%;">
            	<TR><TD colspan="3">
            Image Tracks/Table Filter:<div class="inpageHelp" style="display:inline-block; margin-left:10px;"><img id="Help1" class="helpImage" src="../web/images/icons/help.png" /></div><BR />
            	</TD></TR>
               	<TR>
                <TD>
                <input name="trackcbx" type="checkbox" id="probeCBX" value="probe" checked="checked" /> All Non-Masked Probesets
                <select name="trackSelect" id="probeSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                </TD>
                <TD colspan="2">
                <input name="trackcbx" type="checkbox" id="filterprobeCBX" value="filterprobe" />Probsets Detected Above Background >1% of samples
                <select name="trackSelect" id="filterprobeSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                </TD>
            </TR>
            <TR>
                <TD>
                <input name="trackcbx" type="checkbox" id="exonPlusCBX" value="numExonPlus" checked="checked" />+ Strand Protein Coding/PolyA+
                <select name="trackSelect" id="exonPlusSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                </TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="exonMinusCBX" value="numExonMinus" checked="checked" />- Strand Protein Coding/PolyA+
                <select name="trackSelect" id="exonMinusSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                </TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="exonUkwnCBX" value="numExonUkwn" />Unknown Strand Protein Coding/PolyA+
                <select name="trackSelect" id="exonUkwnSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                </TD>
            </TR>
            <TR>
                <TD>
                <input name="trackcbx" type="checkbox" id="noncodingCBX" value="noncoding" />Long Non-Coding/NonPolyA+
                <select name="trackSelect" id="noncodingSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select>
                </TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="smallncCBX" value="smallnc" /> Small RNA
                <select name="trackSelect" id="smallncSelect">
                    <option value="1" >Dense</option>
                    <option value="3" selected="selected">Pack</option>
                    <option value="2" >Full</option>
                </select> 
                </TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="snpCBX" value="snp" /> SNPs/Indels:
                 <select name="trackSelect" id="snpSelect">
                    <option value="1" selected="selected">Dense</option>
                    <option value="3" >Pack</option>
                    <option value="2" >Full</option>
                </select>
                </TD>
            </TR>
            <TR>
                <TD>
                <input name="trackcbx" type="checkbox" id="helicosCBX" value="helicos" /> Helicos Data:
                <select name="trackSelect" id="helicosSelect">
                    <option value="1" selected="selected">Dense</option>
                    <option value="2" >Full</option>
                </select>
                </TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="bqtlCBX" value="qtl" /> bQTLs
                </TD>
                <TD>
                <input name="trackcbx" type="checkbox" id="refseqCBX" value="refseq" checked="checked" /> RefSeq Transcripts
                 </TD>
             </TR>
             </table>   
             </form>
         
		 
          </div><!--end imageControl div -->
    </div><!--end Border Div -->
    <BR />
<script type="text/javascript">
	hideWorking();
	//Setup Fancy box for UCSC link
	$('.fancybox').fancybox({
		width:$(document).width(),
		height:$(document).height(),
		scrollOutside:false,
		afterClose: function(){
			$('body.noPrint').css("margin","5px auto 60px");
			return;
		}
  });
  	$('#imageSizeCbx').change( function(){
		if($(this).is(":checked")){
			$('#geneImage').css({"height":"400px","overflow":"auto"});
			$('#imageSizeSelect').prop('disabled', false);
		}else{
			$('#geneImage').css({"height":"","overflow":""});
			$('#imageSizeSelect').prop('disabled', 'disabled');
		}
		
	});
	
	$('#imageSizeSelect').change( function(){
		if($('#imageSizeCbx').is(":checked")){
			var size=$(this).val()+"px";
			$('#geneImage').css({"height":size,"overflow":"auto"});
		}
	});
	
	$("span.triggerImage").click(function(){
							var baseName = $(this).attr("name");
									var thisHidden = $("div#" + baseName).is(":hidden");
									$(this).toggleClass("less");
									if (thisHidden) {
								$("div#" + baseName).show();
									} else {
								$("div#" + baseName).hide();
									}
							});
</script>

    <BR />

<div class="cssTab" id="mainTab" >
    <ul>
      <li ><a id="geneTabID" href="#geneList" title="What genes are found in this area?" style="top:-30px; z-index:10;">Features<BR />Physically Located Gene Region</a><div class="inpageHelp" style="float:right;position: relative; top: -84px; left:-2px;z-index:11;"><img id="Help3" class="helpImage" src="../web/images/icons/help.png" /></div></li>
      <li ><a id="qtlTabID" href="#qtlList" title="" style="top:-30px; z-index:10;width:75px;">eQTL</a><div class="inpageHelp" style="float:right;position: relative; top: -84px; left:-2px;z-index:11;"><img id="Help3" class="helpImage" src="../web/images/icons/help.png" /></div></li>
      <li ><a id="affyTabID" href="#affyExon" title="" style="top:-30px;z-index:10;">Affy Exon<BR />Probeset Details</a><div class="inpageHelp" style="float:right;position: relative; top: -84px; left:-2px;z-index:11;"><img id="Help7" class="helpImage" src="../web/images/icons/help.png" /></div></li>
      
     </ul>
<div id="geneList" class="modalTabContent" style=" display:none; position:relative;top:27px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:1000px;">
 <table class="geneFilter">
                	<thead>
                    	<TR>
                    	<TH style="width:50%"><span class="trigger" id="geneListFilter1" name="geneListFilter" style=" position:relative;text-align:left; z-index:100;">Filter List</span></TH>
                        <TH style="width:50%"><span class="trigger" id="geneListFilter2" name="geneListFilter" style=" position:relative;text-align:left; z-index:100;">View Columns</span></TH>
                        <div class="inpageHelp" style="display:inline-block; position:relative;float:right; z-index:999; top:4px; left:-3px;"><img id="Help4" class="helpImage" src="../web/images/icons/help.png" /></div>
                        </TR>
                        
                    </thead>
                	<tbody id="geneListFilter" style="display:none;">
                    	<TR>
                        	<td>
                            <%if(myOrganism.equals("Rn")){%>
                                Exclude single exon RNA-Seq Transcripts
                            	<input name="chkbox" type="checkbox" id="exclude1Exon" value="exclude1Exon" /><BR />
                        	<%}%>
                        
                            eQTL P-Value Cut-off:
                                             <select name="pvalueCutoffSelect1" id="pvalueCutoffSelect1">
                                            		<option value="0.1" <%if(forwardPValueCutoff==0.1){%>selected<%}%>>0.1</option>
                                                    <option value="0.01" <%if(forwardPValueCutoff==0.01){%>selected<%}%>>0.01</option>
                                                    <option value="0.001" <%if(forwardPValueCutoff==0.001){%>selected<%}%>>0.001</option>
                                                    <option value="0.0001" <%if(forwardPValueCutoff==0.0001){%>selected<%}%>>0.0001</option>
                                                    <option value="0.00001" <%if(forwardPValueCutoff==0.00001){%>selected<%}%>>0.00001</option>
                                            </select>
                                            Require an eQTL below cut-off<input name="chkbox" type="checkbox" id="rqQTLCBX" value="rqQTLCBX"/>
                            </td>
                        	<td>
                            	<div class="columnLeft">
                                	Gene ID
                                    <input name="chkbox" type="checkbox" id="geneIDCBX" value="geneIDCBX" checked="checked" /><BR />
                                    Description
                                    <input name="chkbox" type="checkbox" id="geneDescCBX" value="geneDescCBX" checked="checked" /><BR />
                                    BioType
                                    <input name="chkbox" type="checkbox" id="geneBioTypeCBX" value="geneBioTypeCBX" checked="checked" /><BR />
                                    Tracks
                                    <input name="chkbox" type="checkbox" id="geneTracksCBX" value="geneTracksCBX" checked="checked" /><BR />
                                    Location and Strand
                                    <input name="chkbox" type="checkbox" id="geneLocCBX" value="geneLocCBX" checked="checked" /><BR />
                                   
                                </div>
                                <div class="columnRight">
                                 	Heritability
                                    <input name="chkbox" type="checkbox" id="heritCBX" value="heritCBX" checked="checked" /><BR />
                                	Detection Above Background
                                	<input name="chkbox" type="checkbox" id="dabgCBX" value="dabgCBX" checked="checked" /><BR />
                                    eQTLs All
                                    <input name="chkbox" type="checkbox" id="eqtlAllCBX" value="eqtlAllCBX" checked="checked" /><BR />
                                    eQTLs Tissues
                                    <input name="chkbox" type="checkbox" id="eqtlCBX" value="eqtlCBX" checked="checked" />
                                </div>

                            </TD>
                        
                        </TR>
                        </tbody>
                        
                  </table>
                  <script type="text/javascript">
				            $("span.triggerImage").click(function(){
							var baseName = $(this).attr("name");
									var thisHidden = $("div#" + baseName).is(":hidden");
									$(this).toggleClass("less");
									if (thisHidden) {
								$("div#" + baseName).show();
									} else {
								$("div#" + baseName).hide();
									}
							});
				</script>
          
          
          <%
		  	String[] hTissues=new String[0];
			String[] dTissues=new String[0];
		  	if(fullGeneList.size()>0){
		  		edu.ucdenver.ccp.PhenoGen.data.Bio.Gene tmpGene=fullGeneList.get(0);
				%>
		 
          	<TABLE name="items"  id="tblGenes" class="list_base" cellpadding="0" cellspacing="0"  >
                <THEAD>
                    <tr>
                        <th colspan="11" class="topLine noSort noBox"></th>
                        <th colspan="4" class="center noSort topLine">Transcript Information</th>
                        <th colspan="<%=5+tissuesList1.length*2+tissuesList2.length*2%>"  class="center noSort topLine" title="Dataset is available by going to Microarray Analysis Tools -> Analyze Precompiled Dataset or Downloads.">Affy Exon 1.0 ST PhenoGen Public Dataset(
							<%if(myOrganism.equals("Mm")){%>
                            	Public ILSXISS RI Mice
                            <%}else{%>
                            	Public HXB/BXH RI Rats (Tissue, Exon Arrays)
                            <%}%>
                            )<div class="inpageHelp" style="display:inline-block; "><img id="Help5b" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                    </tr>
                    <tr style="text-align:center;">
                        <th colspan="11"  class="topLine noSort noBox"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="2"  class="leftBorder rightBorder topLine noSort">RNA-Seq<div class="inpageHelp" style="display:inline-block;"><img id="Help5a" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="<%=tissuesList1.length%>"  class="center noSort topLine">Probesets > 0.33 Heritability<div class="inpageHelp" style="display:inline-block; "><img id="Help5c" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                        <th colspan="<%=tissuesList1.length%>" class="center noSort topLine">Probesets > 1% DABG<div class="inpageHelp" style="display:inline-block; "><img id="Help5d" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                        <th colspan="<%=3+tissuesList2.length*2%>" class="center noSort topLine" title="eQTLs at the Gene Level.  These are calculated for Transcript Clusters which are Gene Level and not individual transcripts.">eQTLs(Gene/Transcript Cluster ID)<div class="inpageHelp" style="display:inline-block; "><img id="Help5e" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                    </tr>
                    <tr style="text-align:center;">
                        <th colspan="5"  class="topLine noSort noBox"></th>
                        <th colspan="3"  class="topLine leftBorder rightBorder noSort" title="The tracks in the image above that are represented in this table.  Each item is in one of the 4 tracks.">Image Tracks Represented in Table</th>
                        <th colspan="3"  class="topLine noSort noBox"></th>
                        <th colspan="2"  class="topLine leftBorder rightBorder noSort"># Transcripts</th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="<%=tissuesList1.length%>"  class="leftBorder rightBorder noSort noBox"></th>
                        <th colspan="<%=tissuesList1.length%>"  class="leftBorder rightBorder noSort noBox"></th>
                        <th colspan="1"  class="leftBorder noSort"></th>
                        <th colspan="2"  class="noBox noSort"></th>
                        <%for(int i=0;i<tissuesList2.length;i++){%>
                    		<TH colspan="2" class="center noSort topLine"><%=tissuesList2[i]%></TH>
                    	<%}%>
                    </tr>
                    <tr class="col_title">
                    <TH>Image ID (Transcript/Feature ID)</TH>
                    <TH>Gene Symbol<BR />(click for detailed transcription view)</TH>
                    <TH>Gene ID</TH>
                    <TH width="10%">Gene Description</TH>
                    <TH>BioType</TH>
                    <TH>Protein Coding / PolyA+</TH>
                    <TH>Long Non-Coding / Non PolyA+</TH>
                    <TH>Small RNA</TH>
                    <TH>Location</TH>
                    <TH>Strand</TH>
                    <TH title="SNPs and Indels that fall in an exon of at least one transcript." >Exon SNPs / Indels</TH>
                    <TH>Ensembl</TH>
                    <TH>RNA-Seq</TH>
                    <TH>Total Reads<HR />Read Sequences</TH>
                    <TH>View Details</TH>
                    <TH>Total Probesets</TH>
                    
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<HR />(Avg)</TH>
                    <%}%>
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<HR />(Avg)</TH>
                    <%}%>
                    <TH>Transcript Cluster ID <div class="inpageHelp" style="display:inline-block; "><img id="Help5f" class="helpImage" src="../web/images/icons/help.png" /></div></TH>
                    <TH>Annotation Level</TH>
                    <TH>View Genome-Wide Associations<div class="inpageHelp" style="display:inline-block; "><img id="Help5g" class="helpImage" src="../web/images/icons/help.png" /></div></TH>
                    <%for(int i=0;i<tissuesList2.length;i++){%>
                    	<TH>Total # Locations P-Value < <%=forwardPValueCutoff%> </TH>
                        <TH>Minimum<BR /> P-Value<HR />Location</TH>
                    <%}%>
                    </tr>
                </thead>
                
                <tbody style="text-align:center;">
					<%DecimalFormat df2 = new DecimalFormat("#.##");
					DecimalFormat df0 = new DecimalFormat("###");
					DecimalFormat df4 = new DecimalFormat("#.####");
						
					for(int i=0;i<fullGeneList.size();i++){
                        edu.ucdenver.ccp.PhenoGen.data.Bio.Gene curGene=fullGeneList.get(i);
						TranscriptCluster tc=curGene.getTranscriptCluster();
                        HashMap hCount=curGene.getHeritCounts();
                        HashMap dCount=curGene.getDabgCounts();
						HashMap hSum=curGene.getHeritAvg();
                        HashMap dSum=curGene.getDabgAvg();
						String chr=curGene.getChromosome();
						String viewClass="codingRNA";
						ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Transcript> tmpTrx=curGene.getTranscripts();
						if(!chr.startsWith("chr")){
							chr="chr"+chr;
						}
                        %>
                        <TR class="
						<% String geneID="";
						if(curGene.getSource().equals("RNA Seq")&&curGene.isSingleExon()){%>
                        	singleExon
						<%}
						if(tc!=null){%>
                        	eqtl
                        <%}
						if(curGene.getBioType().equals("protein_coding")){%>
                        	coding
						<%}else{
							if(curGene.getLength()>=350){
								viewClass="longRNA";%>
                        		noncoding
                            <%}else{
								viewClass="smallRNA";%>
                            	smallnc
                            <%}%>
						<%}%>
                        <%if(curGene.getGeneID().startsWith("ENS")){%>
                        	ensembl
                        <%}%>
                        ">
                        	<TD>
                            	<%	String tmpList="";
									if((curGene.getTranscriptCountRna()+curGene.getTranscriptCountEns()) > 5){
										tmpList="<span class=\"tblTrigger\" name=\"fg_"+i+"\">";
										for(int l=0;l<tmpTrx.size();l++){
												if(l<5){
														tmpList=tmpList+tmpTrx.get(l).getID()+"<BR>";
												}else if(l==5){
													tmpList=tmpList+"</span><span id=\"fg_"+i+"\" style=\"display:none;\">"+tmpTrx.get(l).getID()+"<BR>";
												}else{
													tmpList=tmpList+tmpTrx.get(l).getID()+"<BR>";
												}
										}
										tmpList=tmpList+"</span>";
									}else{
										for(int l=0;l<tmpTrx.size();l++){
												if(l==0){
														tmpList=tmpTrx.get(l).getID()+"<BR>";
												}else{
														tmpList=tmpList+tmpTrx.get(l).getID()+"<BR>";
												}
										}
									}%>
                                	<%=tmpList%>
                            </TD>
                            <TD title="View detailed transcription information for gene in a new window.">
							<%if(curGene.getGeneID().startsWith("ENS")){%>
                            	<a href="<%=lg.getGeneLink(curGene.getGeneID(),myOrganism,true,true,false)%>" target="_blank">
                            <%}else{%>
                            	<a href="<%=lg.getRegionLink(chr,curGene.getStart(),curGene.getEnd(),myOrganism,true,true,false)%>" target="_blank">
                            <%}%>
                            <%if(curGene.getGeneSymbol()!=null&&!curGene.getGeneSymbol().equals("")){
								geneID=curGene.getGeneSymbol();%>
									<%=curGene.getGeneSymbol()%>
                            <%}else{
								geneID=curGene.getGeneID();%>
                                	No Gene Symbol
                            <%}%>
                                </a>
                            </TD>
                            <%String description=curGene.getDescription();
									String shortDesc=description;
									String remain="";
									if(description.indexOf("[")>0){
										shortDesc=description.substring(0,description.indexOf("["));
										remain=description.substring(description.indexOf("[")+1,description.indexOf("]"));
									}
							%>
                            <TD >
                           
							<%if(curGene.getGeneID().startsWith("ENS")){%>
                            	<a href="<%=LinkGenerator.getEnsemblLinkEnsemblID(curGene.getGeneID(),fullOrg)%>" target="_blank" title="View Ensembl Gene Details"><%=curGene.getGeneID()%></a><BR />	
                                <span style="font-size:10px;">
								<%
																
									String tmpGS=curGene.getGeneID();
									String shortOrg="Mouse";
									String allenID="";
									if(myOrganism.equals("Rn")){
                                    	shortOrg="Rat";
									}
									if(curGene.getGeneSymbol()!=null&&!curGene.getGeneSymbol().equals("")){
										tmpGS=curGene.getGeneSymbol();
										allenID=curGene.getGeneSymbol();
                            		}
									if(allenID.equals("")&&!shortDesc.equals("")){
										allenID=shortDesc;
									}%>
                                    All Organisms:<a href="<%=LinkGenerator.getNCBILink(tmpGS)%>" target="_blank">NCBI</a> |
                                    <a href="<%=LinkGenerator.getUniProtLinkGene(tmpGS)%>" target="_blank">UniProt</a> <BR />
                                   <%=shortOrg%>: <a href="<%=LinkGenerator.getNCBILink(tmpGS,myOrganism)%>" target="_blank">NCBI</a> | <a href="<%=LinkGenerator.getUniProtLinkGene(tmpGS,myOrganism)%>" target="_blank">UniProt</a> | 
                                    <%if(myOrganism.equals("Mm")){%>
                                        <a href="<%=LinkGenerator.getMGILink(tmpGS)%>" target="_blank">MGI</a> 
                                        <%if(!allenID.equals("")){%>
                                        	| <a href="<%=LinkGenerator.getBrainAtlasLink(allenID)%>" target="_blank">Allen Brain Atlas</a>
                                        <%}%>
                                    <%}else{%>
                                        <a href="<%=LinkGenerator.getRGDLink(tmpGS,myOrganism)%>" target="_blank">RGD</a>
                                    <%}%>
                                 </span>
                            <%}else{%>
                            	<%=curGene.getGeneID()%>
                            <%}%>
                            </TD>
                             
                            <%String bioType=curGene.getBioType();
							  
							%>
                            <TD title="<%=remain%>">
								<%=shortDesc%>
                                <% HashMap displayed=new HashMap();
								HashMap bySource=new HashMap();
								for(int k=0;k<tmpTrx.size();k++){
                                	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation> annot=tmpTrx.get(k).getAnnotation();
									if(annot!=null&&annot.size()>0){
										for(int j=0;j<annot.size();j++){
											if(!annot.get(j).getSource().equals("AKA")&&!annot.get(j).getSource().equals("AlignedSequences")){
												String tmpHTML=annot.get(j).getDisplayHTMLString(true);
												if(!displayed.containsKey(tmpHTML)){
													displayed.put(tmpHTML,1);
													if(bySource.containsKey(annot.get(j).getSource())){
														String list=bySource.get(annot.get(j).getSource()).toString();
														list=list+", "+tmpHTML;
														bySource.put(annot.get(j).getSource(),list);
													}else{
														bySource.put(annot.get(j).getSource(),tmpHTML);
													}
                                            		
                                                }
                                        	}
                                    	}
                                	}
								}
								Set keys=bySource.keySet();
                				Iterator itr=keys.iterator();
								while(itr.hasNext()){
									String source=itr.next().toString();
									String values=bySource.get(source).toString();
								%>
                                	<%="<BR>"+source+":"+values%>
                                <%}%>
                            </TD>
                            
                            <TD>
                            	<%if(!curGene.getGeneID().startsWith("ENS")){
									String tmpTitle="Based on detection in PolyA+";
									if(!bioType.equals("protein_coding")){
										tmpTitle="Based on detection in Non-PolyA+";
									}%>
                                	<span title="<%=tmpTitle%>">
                                	<%=bioType%>*
                                    </span>
                                <%}else{%>
									<%=bioType%>
                            	<%}%>
                            </TD>
                            <%if(bioType.equals("protein_coding")){%>
                                <TD class="leftBorder">X</TD>
                                <TD class="leftBorder"></TD>
                                <TD class="leftBorder rightBorder"></TD>
                            <%}else{
								if(curGene.getLength()>=350){%>
                                    <TD class="leftBorder"></TD>
                                    <TD class="leftBorder">X</TD>
                                    <TD class="leftBorder rightBorder"></TD>
                                <%}else{%>
                                	<TD class="leftBorder"></TD>
                                    <TD class="leftBorder"></TD>
                                    <TD class="leftBorder rightBorder">X</TD>
                                <%}%>
                            <%}%>
                            
                            <TD><%=chr+": "+dfC.format(curGene.getStart())+"-"+dfC.format(curGene.getEnd())%></TD>
                            <TD><%=curGene.getStrand()%></TD>
                            <TD>
                            	<%if(curGene.getSnpCount("common","SNP")>0 || curGene.getSnpCount("common","Indel")>0 ){%>
                            		Common: <%=curGene.getSnpCount("common","SNP")%> / <%=curGene.getSnpCount("common","Indel")%><BR />
                                <%}%>
                            	<%if(curGene.getSnpCount("BNLX","SNP")>0 || curGene.getSnpCount("BNLX","Indel")>0 ){%>
                            		BNLX: <%=curGene.getSnpCount("BNLX","SNP")%> / <%=curGene.getSnpCount("BNLX","Indel")%><BR />
                                <%}%>
                                <%if(curGene.getSnpCount("SHRH","SNP")>0 || curGene.getSnpCount("SHRH","Indel")>0){%>
                                	SHRH: <%=curGene.getSnpCount("SHRH","SNP")%> / <%=curGene.getSnpCount("SHRH","Indel")%>
                                <%}%>
                            </TD>
                            <TD class="leftBorder"><%=curGene.getTranscriptCountEns()%></TD>
                            <TD>
								<%=curGene.getTranscriptCountRna()%>
                            </TD>
                            <TD>
                            	<%if(curGene.getTranscriptCountRna()>0 && !bioType.equals("protein_coding") && curGene.getLength()<350 ){
									ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Transcript> smRNAList=curGene.getSMNCTranscripts();
									String tmpIDList="";
									String tmpNameList="";
									for(int n=0;n<smRNAList.size();n++){
										SmallNonCodingRNA tmpRNA=(SmallNonCodingRNA)smRNAList.get(n);
										if(n==0){
											tmpIDList=Integer.toString(tmpRNA.getNumberID());
											tmpNameList=tmpRNA.getID();
										}else{
											tmpIDList=tmpIDList+","+tmpRNA.getNumberID();
											tmpNameList=tmpNameList+","+tmpRNA.getID();
										}
									}%>
                            		<span id="<%=tmpIDList+":"+tmpNameList%>" class="viewSMNC">View RNA-Seq</span>
                                <%}%>
                            </TD>
                            <TD><span id="<%=chr+":"+(curGene.getMinMaxCoord()[0]-500)+"-"+(curGene.getMinMaxCoord()[1]+500)%>" name="<%=viewClass%>:<%=geneID%>" class="viewTrx">View</span></TD>
                            <TD class="leftBorder"><%=curGene.getProbeCount()%></TD>
                            
                            <%for(int j=0;j<tissuesList1.length;j++){
								Object tmpH=hCount.get(tissuesList1[j]);
								Object tmpHa=hSum.get(tissuesList1[j]);
								if(tmpH!=null){
									int count=Integer.parseInt(tmpH.toString());
									double sum=Double.parseDouble(tmpHa.toString());
									%>
                                	<TD <%if(j==0){%>class="leftBorder"<%}%>>
										<%=count%>
                                    	<%if(count>0){%>
                                        	<BR />
                                            (<%=df2.format(sum/count)%>)
										<%}%>
                                    </TD>
                                <%}else{%>
                                	<TD <%if(j==0){%>class="leftBorder"<%}%>>
                                    N/A
                                    </TD>
                                <%}%>
                            <%}%>
                            <%for(int j=0;j<tissuesList1.length;j++){
								Object tmpD=dCount.get(tissuesList1[j]);
								Object tmpDa=dSum.get(tissuesList1[j]);
								if(tmpD!=null){
									int count=Integer.parseInt(tmpD.toString());
									double sum=Double.parseDouble(tmpDa.toString());
								%>
                                	<TD <%if(j==0){%>class="leftBorder"<%}%>><%=count%>
                                    <%if(count>0){%><BR />(<%=df0.format(sum/count)%>%)<%}%>
                                    </TD>
                                <%}else{%>
                                	<TD <%if(j==0){%>class="leftBorder"<%}%>>N/A</TD>
                                <%}%>
                            <%}%>
                            <%	if(tc!=null){	
								//String[] curTissues=tc.getTissueList();%>
                            	
                                <TD class="leftBorder"><%=tc.getTranscriptClusterID()%></TD>
                            	
                                <TD><%=tc.getLevel()%></TD>
                                <TD>
                                	<a href="web/GeneCentric/setupLocusSpecificEQTL.jsp?geneSym=<%=curGene.getGeneSymbol()%>&ensID=<%=curGene.getGeneID()%>&chr=<%=tc.getChromosome()%>&start=<%=tc.getStart()%>&stop=<%=tc.getEnd()%>&level=<%=tc.getLevel()%>&tcID=<%=tc.getTranscriptClusterID()%>&curDir=<%=folderName%>" 
                                	target="_blank" title="View the circos plot for transcript cluster eQTLs">
										View Location Plot
                                	</a>
                                </TD>
                                <%for(int j=0;j<tissuesList2.length;j++){
									//log.debug("TABLE1:"+tissuesList2[j]);
									ArrayList<EQTL> qtlList=tc.getTissueEQTL(tissuesList2[j]);
									if(qtlList!=null){
										EQTL maxEQTL=qtlList.get(0);
									%>
                                        <TD class="leftBorder"><%=qtlList.size()%></TD>
                                        <TD>
                                        	<%if(maxEQTL.getPVal()<0.0001){%>
                                        		< 0.0001
											<%}else{%>
												<%=df4.format(maxEQTL.getPVal())%>
                                        	<%}%>
                                        	<BR />
                                        	<%if(maxEQTL.getMarker_start()!=maxEQTL.getMarker_end()){%>
                                                <a href="<%=lg.getRegionLink(maxEQTL.getMarkerChr(),maxEQTL.getMarker_start(),maxEQTL.getMarker_end(),myOrganism,true,true,false)%>" target="_blank" title="View Detailed Transcription Information for this region.">
                                                    chr<%=maxEQTL.getMarkerChr()+":"+dfC.format(maxEQTL.getMarker_start())+"-"+dfC.format(maxEQTL.getMarker_end())%>
                                                </a>
                                            <%}else{
												long start=maxEQTL.getMarker_start()-500000;
												long stop=maxEQTL.getMarker_start()+500000;
												if(start<1){
													start=1;
												}%>
                                            	<a href="<%=lg.getRegionLink(maxEQTL.getMarkerChr(),start,stop,myOrganism,true,true,false)%>" target="_blank" title="View Detailed Transcription Information for a region +- 500,000bp around the SNP location.">
                                            		chr<%=maxEQTL.getMarkerChr()+":"+dfC.format(maxEQTL.getMarker_start())%>
                                                 </a>
                                            <%}%>
                                        </TD>
                                    <%}else{%>
                                        <TD class="leftBorder"></TD>
                                        <TD></TD>
                                    <%}%>
                                <%}%>
                             <%}else{%>
                             	<TD class="leftBorder"></TD><TD></TD><TD></TD>
                                <%for(int j=0;j<tissuesList2.length;j++){%>
                                	<TD class="leftBorder"></TD><TD></TD>
                                <%}%>
                             <%}%>
                        </TR>
                    <%}%>
					<%if(smncRNA!=null){
						for(int i=0;i<smncRNA.size();i++){
							SmallNonCodingRNA rna=smncRNA.get(i);
							if(!skipSMRNA.containsKey(rna.getID())){
							%>
                        	<tr class="smallnc">
                            	<TD><%=rna.getID()%></TD>
                                <TD></TD>
                                <TD><% ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation> ens=rna.getAnnotationBySource("Ensembl");
									if(ens!=null&&ens.size()>0){
										for(int k=0;k<ens.size();k++){%>
											<%=ens.get(k).getEnsemblLink()%>
                                        <%}%>
                                        <BR />	
                                		<span style="font-size:10px;">
											<%                
                                                String tmpGS=ens.get(0).getDisplayHTMLString(false);
												if(tmpGS.indexOf("-")>0){
													tmpGS=tmpGS.substring(0,tmpGS.indexOf("-"));
												}
                                                String shortOrg="Mouse";
                                                String allenID="";
                                                if(myOrganism.equals("Rn")){
                                                    shortOrg="Rat";
                                                }
                                                %>
                                                All Organisms:<a href="<%=LinkGenerator.getNCBILink(tmpGS)%>" target="_blank">NCBI</a> |
                                                <a href="<%=LinkGenerator.getUniProtLinkGene(tmpGS)%>" target="_blank">UniProt</a> <BR />
                                               <%=shortOrg%>: <a href="<%=LinkGenerator.getNCBILink(tmpGS,myOrganism)%>" target="_blank">NCBI</a> | <a href="<%=LinkGenerator.getUniProtLinkGene(tmpGS,myOrganism)%>" target="_blank">UniProt</a> | 
                                                <%if(myOrganism.equals("Mm")){%>
                                                    <a href="<%=LinkGenerator.getMGILink(tmpGS)%>" target="_blank">MGI</a> 
                                                    <%if(!allenID.equals("")){%>
                                                        | <a href="<%=LinkGenerator.getBrainAtlasLink(allenID)%>" target="_blank">Allen Brain Atlas</a>
                                                    <%}%>
                                                <%}else{%>
                                                    <a href="<%=LinkGenerator.getRGDLink(tmpGS,myOrganism)%>" target="_blank">RGD</a>
                                                <%}%>
                                             </span>
									<%}%>
                                </TD>
                                <TD>
									<% HashMap displayed=new HashMap();
                                    HashMap bySource=new HashMap();
									ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation> annot=rna.getAnnotations();
									if(annot!=null&&annot.size()>0){
										for(int j=0;j<annot.size();j++){
											
												String tmpHTML=annot.get(j).getDisplayHTMLString(true);
												if(!displayed.containsKey(tmpHTML)){
													displayed.put(tmpHTML,1);
													if(bySource.containsKey(annot.get(j).getSource())){
														String list=bySource.get(annot.get(j).getSource()).toString();
														list=list+", "+tmpHTML;
														bySource.put(annot.get(j).getSource(),list);
													}else{
														bySource.put(annot.get(j).getSource(),tmpHTML);
													}
													
												}
										}
									}
                                    
                                    Set keys=bySource.keySet();
                                    Iterator itr=keys.iterator();
                                    while(itr.hasNext()){
                                        String source=itr.next().toString();
                                        String values=bySource.get(source).toString();
                                    %>
                                        <%="<BR>"+source+":"+values%>
                                    <%}%>
                                </TD>
                                <TD><span title="<350bp includes Coding and Non-Coding RNA">Small RNA*</span></TD>
                                <TD class="leftBorder"></TD>
                                <TD class="leftBorder"></TD>
                                <TD class="leftBorder rightBorder">X</TD>
                                <TD>chr<%=rna.getChromosome()+":"+dfC.format(rna.getStart())+"-"+dfC.format(rna.getStop())%></TD>
                                <TD><%=rna.getStrand()%></TD>
                                <TD>
    							
                                <%if(rna.getSnpCount("common","SNP")>0 || rna.getSnpCount("common","Indel")>0 ){%>
                            		Common: <%=rna.getSnpCount("common","SNP")%> / <%=rna.getSnpCount("common","Indel")%><BR />
                                <%}%>
                            	<%if(rna.getSnpCount("BNLX","SNP")>0 || rna.getSnpCount("BNLX","Indel")>0 ){%>
                            		BNLX: <%=rna.getSnpCount("BNLX","SNP")%> / <%=rna.getSnpCount("BNLX","Indel")%><BR />
                                <%}%>
                                <%if(rna.getSnpCount("SHRH","SNP")>0 || rna.getSnpCount("SHRH","Indel")>0){%>
                                	SHRH: <%=rna.getSnpCount("SHRH","SNP")%> / <%=rna.getSnpCount("SHRH","Indel")%>
                                <%}%>
                                </TD>
                                <TD class="leftBorder"></TD>
                                <TD></TD>

                                
                                <TD>
									<%=rna.getTotalReads()%><BR />
									<%=rna.getSeq().size()%><BR />
                                    <span id="<%=rna.getNumberID()+":"+rna.getID()%>" class="viewSMNC">View RNA-Seq</span>
                                </TD>
                                <TD>
                                    <span id="chr<%=rna.getChromosome()+":"+(rna.getStart()-20)+"-"+(rna.getStop()+20)%>" name="smallRNA:<%=rna.getID()%>" class="viewTrx">View</span>                               
                                 </TD>
                                <TD class="leftBorder"></TD>
                                
                                <%for(int j=0;j<tissuesList1.length;j++){%>
                                   <TD <%if(j==0){%>class="leftBorder"<%}%>></TD>
                                <%}%>
                                <%for(int j=0;j<tissuesList1.length;j++){%>
                                    <TD <%if(j==0){%>class="leftBorder"<%}%>></TD>
                                <%}%>
                                <TD class="leftBorder"></TD>
                                <TD></TD>
                                <TD></TD>
                                <%for(int j=0;j<tissuesList2.length;j++){%>
                                    <TD class="leftBorder"></TD>
                                    <TD></TD>
                                <%}%>
                        </tr>
                    <%}
					}
					}%>
				 </tbody>
              </table>
          <%}else{%>
          	No genes found in this region.  Please expand the region and try again.
          <%}%>
 <div id="viewTrxDialog" class="trxDialog"></div>

<div id="viewTrxDialogOriginal"  style="display:none;"><div class="waitTrx"  style="text-align:center; position:relative; top:0px; left:0px;"><img src="<%=imagesDir%>wait.gif" alt="Loading..." /><BR />Please wait loading transcript data...</div></div>
</div>

<script type="text/javascript">
	var spec="<%=myOrganism%>";
	
	$('#viewTrxDialog').dialog({
		autoOpen: false,
		dialogClass: "transcriptDialog",
		width: 960,
		height: 400,
		zIndex: 999
	});
	
	$('.viewTrx').click( function(event){
		var id=$(this).attr('id');
		var name=$(this).attr('name');
		$('.waitTrx').show();
		$('#viewTrxDialog').html($('#viewTrxDialogOriginal').html());
		$('#viewTrxDialog').dialog( "option", "position",{ my: "center bottom", at: "center top", of: $(this) });
		$('#viewTrxDialog').dialog("open").css({'font-size':12});
		openTranscriptDialog(id,spec,name);
	});
	
	$('.viewSMNC').click( function(event){
		var tmpID=$(this).attr('id');
		var id=tmpID.substr(0,tmpID.indexOf(":"));
		var name=tmpID.substr(tmpID.indexOf(":")+1);
		openSmallNonCoding(id,name);
		$('#viewTrxDialog').dialog( "option", "position",{ my: "center bottom", at: "center top", of: $(this) });
		$('#viewTrxDialog').dialog("open").css({'font-size':12});
	})
	
	var tblGenes=$('#tblGenes').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"bStateSave": true,
	"bAutoWidth": true,
	"sScrollX": "950px",
	"sScrollY": "650px",
	"aaSorting": [[ 5, "desc" ]],
	"sDom": '<"leftSearch"fr><t>'
	/*"oTableTools": {
			"sSwfPath": "/css/swf/copy_csv_xls_pdf.swf"
		}*/

	});
	
	
	
	$('#mainTab div.modalTabContent:first').show();
	$('#mainTab ul li a:first').addClass('selected');
	$('#geneTabID').click(function() {    
			$('div#changingTabs').show(10);
				//change the tab
				$('#mainTab ul li a').removeClass('selected');
				$(this).addClass('selected');
				var currentTab = $(this).attr('href'); 
				$('#mainTab div.modalTabContent').hide();       
				$(currentTab).show();
				//adjust row and column widths if needed(only needs to be done once)
				//setFilterTableStatus("geneListFilter");
				$('div#changingTabs').hide(10);
			return false;
        });
	$('#tblGenes').dataTable().fnAdjustColumnSizing();

	$('#tblGenes_wrapper').css({position: 'relative', top: '-56px'});
	//$('.singleExon').hide();
	
	$('#heritCBX').click( function(){
			displayColumns(tblGenes, 16,tisLen,$('#heritCBX').is(":checked"));
	  });
	  $('#dabgCBX').click( function(){
			displayColumns(tblGenes, 16+tisLen,tisLen,$('#dabgCBX').is(":checked"));
	  });
	  $('#eqtlAllCBX').click( function(){
			displayColumns(tblGenes, 16+tisLen*2,tisLen*2+3,$('#eqtlAllCBX').is(":checked"));
	  });
		$('#eqtlCBX').click( function(){
			displayColumns(tblGenes, 16+tisLen*2+3,tisLen*2,$('#eqtlCBX').is(":checked"));
	  });
	  
	   $('#geneIDCBX').click( function(){
			displayColumns(tblGenes,2,1,$('#geneIDCBX').is(":checked"));
	  });
	  $('#geneDescCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),3,1,$('#geneDescCBX').is(":checked"));
	  });
	  
	  $('#geneBioTypeCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),4,1,$('#geneBioTypeCBX').is(":checked"));
	  });
	  $('#geneTracksCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),5,3,$('#geneTracksCBX').is(":checked"));
	  });
	  
	  $('#geneLocCBX').click( function(){
			displayColumns($(tblGenes).dataTable(),8,2,$('#geneLocCBX').is(":checked"));
	  });
	  
	  $('#pvalueCutoffSelect1').change( function(){
	  			$("#wait1").show();
				$('#forwardPvalueCutoffInput').val($(this).val());
				//alert($('#pvalueCutoffInput').val());
				//$('#geneCentricForm').attr("action","Get Transcription Details");
				$('#geneCentricForm').submit();
			});
	 $('#exclude1Exon').click( function(){
  		if($('#exclude1Exon').is(":checked")){
			$('.singleExon').hide();
		}else{
			$('.singleExon').show();
		}
 	 });
	 
	 $("input[name='trackcbx']").change( function(){
	 		var type=$(this).val();
			updateTrackString();
			updateUCSCImage();
			//if(type=="coding" || type=="noncoding" || type=="smallnc"){
				/*if($('#rqQTLCBX').is(":checked")){
					$('tr.'+type).hide();
					type=type+".eqtl";
				}*/
			//	if($(this).is(":checked")){
			//		$('tr.'+type).show();
			//	}else{
			//		$('tr.'+type).hide();
			//	}
			//	tblGenes.fnDraw();
			//}
			
	 });
	 
	 $("select[name='trackSelect']").change( function(){
	 	var id=$(this).attr("id");
		var cbx=id.replace("Select","CBX");
		if($("#"+cbx).is(":checked")){
			updateTrackString();
			updateUCSCImage();
		}
	 });
	 
	 $("span.tblTrigger").click(function(){
		var baseName = $(this).attr("name");
                var thisHidden = $("span#" + baseName).is(":hidden");
                $(this).toggleClass("less");
                if (thisHidden) {
			$("span#" + baseName).show();
                } else {
			$("span#" + baseName).hide();
                }
	});
</script>
<div id="qtlList" class="modalTabContent" style=" display:none; position:relative;top:27px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:1000px;">
	<%@ include file="/web/GeneCentric/geneEQTLPart.jsp" %>
</div>

<script type="text/javascript">
	$('#qtlTabID').click(function() {    
			$('div#changingTabs').show(10);
				//change the tab
				$('#mainTab ul li a').removeClass('selected');
				$(this).addClass('selected');
				var currentTab = $(this).attr('href'); 
				$('#mainTab div.modalTabContent').hide();       
				$(currentTab).show();
				$('div#changingTabs').hide(10);
			return false;
        });
</script>

<div id="affyExon" class="modalTabContent" style="display:none; position:relative;top:27px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;width:100%;">   
	 
    <div class="hidden"><a class="hiddenLink fancybox.iframe" href="web/GeneCentric/LocusSpecificEQTL.jsp?hiddenGeneSymbol=<%=geneSymbol.get(selectedGene)%>&hiddenGeneCentricPath=<%=gcPath%>" title="eQTL"></a></div>
    <div id="macBugDesc" style="display:none;color:#FF0000;">On your Mac OS X version and Java version the applet below is not being displayed correctly.  This problem is a result of the last update from Oracle and will hopefully be fixed with the next version at which point we will update the applet.  We are very sorry for any inconvenience.  If you would like to use windows or Mac OS X 10.6 the applet will be displayed correctly.  We have done what we can to improve the applets appearance until Oracle fixes this bug, and we are very sorry for any inconvenience.</div>
    
    <div id="unsupportedChrome" style="display:none;color:#FF0000;">A Java plugin is required to view this page.  Chrome is a 32-bit browser and requires a 32-bit plug-in which is unavailable for Mac OS X.  Please try using Safari or FireFox with the Java Plugin installed.  Note: In browsers that support the 64-bit plugin you will be prompted to install Java if it is not already installed.</div>
    
	<%if(genURL.get(selectedGene)!=null && !genURL.get(selectedGene).startsWith("ERROR:")){%>
    	<script type="text/javascript" src="http://www.java.com/js/deployJava.js"></script>
		<script type="text/javascript">
            var ensembl="<%=selectedEnsemblID%>";
            var genURL="<%=genURL.get(selectedGene)%>";
			var appletWidth=1000;
			var appletHeight=1200;
			var jre=deployJava.getJREs();
			var bug=0;
			var bugString='false';
			var unsupportedChrome=0;
			//
			//alert("Initial:"+jre+":"+navigator.userAgent);
			if (/Mac OS X[\/\s](\d+[_\.]\d+)/.test(navigator.userAgent)){ //test for Firefox/x.x or Firefox x.x (ignoring remaining digits);
 					//var macVersion=new Number(RegExp.$1); // capture x.x portion and store as a number
					var tmpAgent=new String(navigator.userAgent);
					//alert("Detected Mac OS X:"+tmpAgent);
					if(/Chrome/.test(tmpAgent)){
						var update=new String(jre);
						//alert("chrome update:"+update);
						if(update.length==0){
							//alert("unsupported");
							unsupportedChrome=1;
						}
					}
					else if (/10[_\.][789]/.test(tmpAgent)){
						//alert("Mac Ver >=10.7:");
						var tmpUp=new String(jre);
						var update=tmpUp.substr((tmpUp.indexOf("_")+1));
						//alert("update:"+update);
						if(update>=10){
							//alert("update >10");
								bug=1;
								appletHeight=700;
								bugString='true';
								$('div#macBugDesc').show();
						}
					}
			}
        </script>
        <div style="position:relative;top:-75px; z-index:0;">
        <script type="text/javascript">
			if(unsupportedChrome==0){
				var attributes = {
					id:			'geneApplet',
					code:       "genecentricviewer.GeneCentricViewer",
					archive:    "/web/GeneCentric/GeneCentricViewer.jar",
					width:      appletWidth,
					height:     appletHeight
				};
				var parameters = {
					java_status_events: 'true',
					jnlp_href:"/web/GeneCentric/launch.jnlp",
					main_ensembl_id:ensembl,
					genURL:genURL,
					macBug:bugString
				}; 
				var version = "1.6"; 
            	deployJava.runApplet(attributes, parameters, version);
			}else{
				$('#unsupportedChrome').show();
			}

        </script>
        </div>
        
    <%}else{%>
    	<div class="error"><%=genURL.get(selectedGene)%><BR />The administrator has been notified of the problem and will investigate the error.  We apologize for any inconvenience.</div><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
    <%}%>
<%}else{%>
	<BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
<%}%>
</div><!-- end affyExon-->
<script type="text/javascript">
	$('#affyTabID').click(function() {    
			//$('div#changingTabs').show(10);
				//change the tab
				$('#mainTab ul li a').removeClass('selected');
				$(this).addClass('selected');
				var currentTab = $(this).attr('href'); 
				$('#mainTab div.modalTabContent').hide();       
				$(currentTab).show();
				//adjust row and column widths if needed(only needs to be done once)
			
				//setFilterTableStatus("bqtlListFilter");
				
			//$('div#changingTabs').hide(10);
			return false;
        });
</script>

</div><!-- end MainTab-->

<div id="Help1Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>UCSC Genome Browser Image</H3>
The main image was generated by the <a target="_blank" href="http://genome.ucsc.edu/">UCSC Genome Browser</a>(click the image to open a window in your browser at the position of the image).  The image that follows shows numbered tracks.  Below the image, each numbered section describes the associated track.
<img src="ucsc_example.jpg" />  
<ol>
<li>The first track contains all of the Affymetrix Exon Probe Sets for the <a target="_blank" href="http://www.affymetrix.com/estore/browse/products.jsp?productId=131474&categoryId=35765&productName=GeneChip-Mouse-Exon-ST-Array#1_1">Mouse</a> or
<a target="_blank" href="http://www.affymetrix.com/estore/browse/products.jsp?productId=131489&categoryId=35748&productName=GeneChip-Rat-Exon-ST-Array#1_1"> Rat</a> Affy Exon 1.0 ST array.  Below the image, information about these probe sets for parental strains and <a target="_blank" href="http://www.jax.org/smsr/ristrain.html" >panels of recombinant inbred mice or rats</a> and various tissues are displayed. </li>

<li>The second track (if present) contains the numbered exons for the positive strand.  If transcripts exist for the positive strand, each unique exon is given a number such that the first exon is 1.  If transcripts have differing, overlapping exons, then the exons are numbered 1a, 1b, etc.</li>
<li>Rat Only: The third track is a reconstruction of the transcriptome from RNA Sequencing computed by <a target="_blank" href="http://cufflinks.cbcb.umd.edu/index.html">CuffLinks</a> from RNA Sequencing data of Rat Brain.</li>
<li>This fourth track (if present) contains the numbered exons for the reverse strand.  If transcripts exist for the reverse strand, each unique exon is given a number such that the first exon is 1.  If transcripts have differing, overlapping exons, then the exons are numbered 1a, 1b, etc.</li>
<li>Rat Only: The fifth track contains single exon transcripts from CuffLinks that are numbered in the same manner as other exon number tracks.  However in addition to being single exon "genes" they were not able to be assigned to a strand.</li>
<li>The sixth track shows standard UCSC Tracks for the RefSeq gene(top, blue color) and Ensembl transcripts(bottom, brown color).</li>
</ol></div></div>

<div id="Help2Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>UCSC Image Controls</H3>
This control allows you to choose between two different versions of the UCSC genome browser image.  Occasionally you may also have the option to select a different gene.  This occurs when iDecoder found more than one Ensembl Gene Identifier associated with your gene.  However the gene most closely related to the identifier you enter is selected first.<BR /><BR />
The unfiltered version of the image displays all the Affymetrix Exon probesets color coded by annotation level.<BR /><BR />
The filtered version has only probesets that were detected above background in 1% or more of the samples.  Detection Above BackGround(DABG)-Calculates the p-value that the intensities in a probeset could have been observed by chance in a background distribution. <a target="_blank" href="http://www.affymetrix.com/partners_programs/programs/developer/tools/powertools.affx">Affymetrix for more information</a>. <BR />  It also has one track per tissue where data is available (Mouse-Brain Rat-Brain,Heart,Liver,Brown Adipose).  While this is a low percentage it filters out all of the probesets that are not detected above background.
</div></div>


<div id="Help3Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Filter/Display Controls</H3>
The filters allow you to control the probe sets that are displayed.  Check the box next to the filter you want to apply.  The filter is immediately applied, unless input is required, and then it is applied after you input a value.<BR /><BR />
The display controls allow you to choose how the data is displayed.  Any selections are immediately applied.<BR /><BR />
The Filter and Display controls will have different options as you navigate through different tabs.  However, any selections you make on a tab will be preserved when you navigate back to a tab.
</div></div>
<div id="Help4Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Parental Expression</H3>
This tab has heat maps for the expression and fold difference between the Parental Strains(Rat BN-Lx/SHR or Mouse ILS/ISS).  To switch between the two heatmaps use the Display: Mean Values and Fold Difference options.<BR /><BR />
Use the buttons at the top left to control the size of the rows and columns.<BR /><BR />
The legend can be found next to the column and row size buttons and provides a reference for the range of the values displayed.<BR /><BR />
The Probeset IDs along the left side are color coded to match the UCSC genome browser graphic above.<BR /><BR />

</div></div>
<div id="Help5Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Heritability</H3>
Heritability is calculated from individual expression values in the panel of recombinant inbred rodents. The broad sense heritability is calculated from a 1-way ANOVA model comparing the within-strain variance to the between-strain variance. A higher heritability indicates more of the variance in expression and is determined by genetic factors rather than non-genetic factors in this particular RI panel. This tab allows you to view the heritability of unambiguous probesets.  For Affymetrix exon arrays, a probeset typically consist of 4 unique probes.  Prior to analysis, we eliminated (masked) individual probes if their sequence did not align uniquely to the genome or if the probe targeted a region of the genome that harbored a known single nucleotide polymorphism (SNP) between the two parental strains of the RI panel.  Entire probesets were eliminated if less than three probes within the probeset remained after masking.   Probes that target a region with a known SNP may indicate dramatic differences in expression when expression levels are similar but hybridization efficiency differ.
<BR /><BR />
If a probeset of interest is missing, adjust the filtering to allow additional probes (allow introns, opposite strand, make sure all other filters are unchecked, etc.) If it still does not display, it means that the probeset was masked and there is no heritability data because the probeset data would be inaccurate.

</div></div>

<div id="Help6Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Panel Expression</H3>
These are the normalized log transformed expression values.  This tab shows expression values for each probeset accross all strains in the panel.  Note: Because of the normalization, do not compare normalized values between different probesets, but you can compare them accross strains.  <BR /><BR />

There are three ways to view the data.  The default produces a separate graph for each probeset.  Notice the range and size varies with each probeset.  The size varies directly with the range of values so you can quickly scan for more variable or consistent probesets. <BR /><BR />

The next method, if you view probesets grouped into one graph by tissue, shows the variability by strain in a single graph.  This allows you to look for probesets that vary significantly between strains.   Do not compare expression between probesets along the X-axis because the normalization does not allow comparison of expression values between probesets.  <BR /><BR />

The last method displays probesets in a series accross strains.  Again, it is important that you do not use this to compare expression values between probesets.  The best way to compare expression is to use the Exon Correlation Tab.<BR /><BR />

Masking: Probesets have been masked because the sequence for the probe set does not match the strain of mice or rats and as a result, the data from the probe set would be misleading or inaccurate.  If a probeset of interest is missing, adjust the filtering to allow additional probes(allow introns, opposite strand, make sure all other filters are unchecked, etc.) If it still does not display it means that the probeset was masked and there is no heritability data because the probeset data would be inaccurate.

</div></div>
<div id="Help7Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Exon Correlation</H3>
This tab allows you to compare probeset expression, which should not be done directly in the expression tab.  This heatmap shows a selected transcript accross the top and draws exons that are represented by probesets along the top of the heatmap.  Exons that are excluded are color-coded to match the legend at the bottom of the page that shows why the exon was excluded from the heatmap.  Some exons may have multiple probesets representing them.<BR /><BR />

The heatmap is colored according to the correlation of one probeset to another across the strains in the panel.
</div></div>





<script type="text/javascript">
	var ie=false;
</script>

<!--[if IE]>
<script type="text/javascript">
	ie=true;
</script>
<![endif]-->

<script type="text/javascript">
var auto="<%=auto%>";


function openeQTL(){
	//$(".hidden").css('display','block');
	$(".hiddenLink").eq(0).trigger('click');
	
}



function positionHelp(vertPos){
	if(ie){
			if(vertPos>300){
				$('.helpDialog').css({'top':300,'left':$(window).width()*0.3,'width':$(window).width()*0.3});
			}else{
				$('.helpDialog').css({'top':vertPos,'left':$(window).width()*0.3,'width':$(window).width()*0.3});
			}
	}else{
			$('.helpDialog').css({'top':vertPos,'left':$(window).width()*0.47,'width':$(window).width()*0.3});
	}
}

function openFilterDisplay(){
		$('#Help3Content').dialog("open").css({'height':300,'font-size':12});
		positionHelp(650);
}

function openParental(){
		$('#Help4Content').dialog("open").css({'height':300,'font-size':12});
		positionHelp(850);
}

function openHerit(){
		$('#Help5Content').dialog("open").css({'height':300,'font-size':12});
		positionHelp(850);
}

function openPanelExpression(){
		$('#Help6Content').dialog("open").css({'height':300,'font-size':12});
		positionHelp(850);
}
function openExonCorr(){
		$('#Help7Content').dialog("open").css({'height':300,'font-size':12});
		positionHelp(850);
}

/*var READY = 2;
function registerAppletStateHandler() {
        // register onLoad handler if applet has
        // not loaded yet
	if (geneApplet.status < READY)  {                 
            geneApplet.onLoad = onLoadHandler;
	} else if (geneApplet.status >= READY) {
           	
	}
}
    
    function onLoadHandler() {
        if(geneApplet.getDownloadFinished()){
			
		}else{
		
		}
    }*/


$(document).ready(function() {
	
	/*if(auto=="true"){
  		displayWorking();
		auto="false";
  	}*/
	//$('#geneimageFiltered').hide();

	//registerAppletStateHandler();
	//if(genURL!=null){
  	//	document.getElementById("inst").style.display= 'none';
		
  	//}
  
  setupExpandCollapse();
  
  $('.fancybox').fancybox({
		width:$(document).width(),
		height:$(document).height(),
		scrollOutside:false,
		afterClose: function(){
			$('body.noPrint').css("margin","5px auto 60px");
			return;
		}
  });
  
  $('.hiddenLink').fancybox({
		width:$(document).width(),
		height:$(document).height(),
		scrollOutside:false
  });
  
  $('#filteredRB').click( function(){
			$('#geneimageFiltered').show();
			$('#geneimageUnfiltered').hide();
  });
  
  $('#unfilteredRB').click( function(){
  			$('#geneimageFiltered').hide();
			$('#geneimageUnfiltered').show();

  });
  
  $('.inpageHelpContent').hide();
  
  $('.inpageHelpContent').dialog({ 
  		autoOpen: false,
		dialogClass: "helpDialog"
	});
  $('#Help1').click( function(){  		
		$('#Help1Content').dialog("open").css({'height':500,'font-size':12});
		positionHelp(211);
  });
  $('#Help2').click( function(){  		
		$('#Help2Content').dialog("open").css({'height':300,'font-size':12});
		positionHelp(400);
  });
  
  
  
  
	
}); // end ready

</script>




