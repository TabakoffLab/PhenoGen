<div id="page" style="min-height:1100px;">
<span style="text-align:center;">
<%if(genURL.get(0)!=null && !genURL.get(0).startsWith("ERROR:")){%>

	<%
	String[] tissuesList1=new String[1];
	String[] tissuesList2=new String[1];
	
	if(myOrganism.equals("Rn")){
		tissuesList1=new String[4];
		tissuesList2=new String[4];
		tissuesList1[0]="Brain";
		tissuesList2[0]="Whole Brain";
		tissuesList1[1]="Heart";
		tissuesList2[1]="Heart";
		tissuesList1[2]="Liver";
		tissuesList2[2]="Liver";
		tissuesList1[3]="Brown Adipose";
		tissuesList2[3]="Brown Adipose";
	}else{
		tissuesList1[0]="Brain";
		tissuesList2[0]="Whole Brain";
	}
	String tmpURL=genURL.get(0);
	int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
	String folderName=tmpURL.substring(second+1,tmpURL.length()-1);%>

        <div class="geneRegionControl">
      		Zoom In:
          <form id="zoomIn" name="zoomIn" method="post" action="" style="display:inline-block;">
                      <input type="submit" name="action" id="refreshBTN" value="1.5x" onClick="return displayWorking()">
                      <input type="submit" name="action" id="refreshBTN" value="3x" onClick="return displayWorking()">
                      <input type="submit" name="action" id="refreshBTN" value="10x" onClick="return displayWorking()">      
          </form>
         Zoom In:
          <form id="zoomOut" name="zoomOut" method="post" action="" style="display:inline-block;">
                      <input type="submit" name="action" id="refreshBTN" value="1.5x" onClick="return displayWorking()">
                      <input type="submit" name="action" id="refreshBTN" value="3x" onClick="return displayWorking()">
                      <input type="submit" name="action" id="refreshBTN" value="10x" onClick="return displayWorking()">      
          </form>
          </div><!--end RegionControl div -->
    
    <div style="border-color:#CCCCCC; border-width:1px; border-style:inset; width:98%; text-align:center;">
        <div class="geneimageControl">
      		Image Controls:
          <form id="form1" name="form1" method="post" action="" style="display:inline-block;">
              <label style="color:#000000; margin-left:10px;">
                Transcripts:</label>
                <label>
                <input name="radio" type="radio" id="unfilteredRB" value="unfilteredGeneImage" checked="checked" />
                Off</label>
              <label>
              <input type="radio" name="radio" id="filteredRB" value="filteredGeneImage" />
             On</label>
             
          </form>
		 <div class="inpageHelp" style="display:inline-block; margin-left:10px;"><img id="Help2" src="../web/images/icons/help.png" /></div>
         <BR />
			<form id="form2" name="form2" method="post" action="" style="display:inline-block;">
              <label style="color:#000000; margin-left:10px;">
                UCSC/Affymetrix Tissue Expression Data(Source is UCSC Genome Browser):</label>
                <label>
                <input name="radio" type="radio" id="arrayOffRB" value="arrayOff" />
                Off</label>
              <label>
              <input type="radio" name="radio" id="arrayOnRB" value="arrayOn" checked="checked" />
             On</label>
              
          </form>
          
          </div><!--end imageControl div -->
        <div class="geneimage" >
            <div class="inpageHelp" style="display:inline-block;position:relative;float:right;"><img id="Help1" src="../web/images/icons/help.png"  /></div>
    
            <div id="geneimageUnfiltered"  style="display:inline-block;"><a class="fancybox fancybox.iframe" href="<%=ucscURL.get(0)%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.png"%>"/></a></div>
            <div id="geneimageFiltered" style="display:none;"><a class="fancybox fancybox.iframe" href="<%=ucscURLFiltered.get(0)%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.trans.png"%>"/></a></div>
            <%
				String ucscURL_no_array=ucscURL.get(0).replace(".main",".main.noArray");
				String ucscURLFiltered_no_array=ucscURLFiltered.get(0).replace(".main.trans",".main.trans.noArray");
			%>
             <div id="geneimageUnfilteredNoArray"  style="display:none;"><a class="fancybox fancybox.iframe" href="<%=ucscURL_no_array%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.noArray.png"%>"/></a></div>
            <div id="geneimageFilteredNoArray" style="display:none;"><a class="fancybox fancybox.iframe" href="<%=ucscURLFiltered_no_array%>" title="UCSC Genome Browser"><img src="<%= contextRoot+"tmpData/regionData/"+folderName+"/region.main.trans.noArray.png"%>"/></a></div>
    
        </div><!-- end geneimage div -->
    
          </div><!--end Border Div -->

          <BR />
         </span><!-- ends center span -->
          

<div class="cssTab" style="position:relative; text-align:center">
    <ul>
      <li ><a href="#geneList" title="What genes are found in this area?">Genes Physically Located in Region</a></li>
      <li ><a href="#bQTLList" title="What bQTLs occur in this area?">bQTLs<BR />Overlapping Region</a></li>
      <li ><a href="#eQTLListFromRegion" title="What does this region control?">Transcripts Controlled from Region(eQTLs)</a></li>
     </ul>
     
<div id="loadingRegion"  style="text-align:center; position:relative; top:75px; left:-200px;"><img src="<%=imagesDir%>wait.gif" alt="Loading..." /><BR />Loading Region Data...</div>

<!--<div class="title"><span class="trigger" name="geneList" style="text-align:left;">Gene List</span></div>-->
<div id="geneList" class="modalTabContent" style=" display:none; position:relative;top:56px;border-color:#CCCCCC; border-width:1px; border-style:inset;width:995px;">
            <div style=" text-align:center;">
                  Filter Gene List:
                  <form id="form1" name="form1" method="post" action="" >
                      <label style="color:#000000; margin-left:20px;">
                        Exclude single exon RNA-Seq Transcripts:
                        <input name="chkbox" type="checkbox" id="exclude1Exon" value="exclude1Exon" checked="checked" />
                       </label> 
                       <BR />
                       <label style="color:#000000; margin-left:20px;">
                        eQTL P-Value Cut-off:
                        <%
							selectName = "cutoffValue";
							selectedOption = Double.toString(pValueCutoff);
							onChange = "";
							style = "";
							optionHash = new LinkedHashMap();
										optionHash.put("0.10", "0.10");
										optionHash.put("0.01", "0.01");
										optionHash.put("0.001", "0.001");
										optionHash.put("0.0001", "0.0001");
										optionHash.put("0.00001", "0.00001");
							%>
							<%@ include file="/web/common/selectBox.jsp" %>
                       </label>         
                  </form>
            </div>
          
          
          <%
		  	String[] hTissues=new String[0];
			String[] dTissues=new String[0];
		  	if(fullGeneList.size()>0){
		  		edu.ucdenver.ccp.PhenoGen.data.Bio.Gene tmpGene=fullGeneList.get(0);
				/*HashMap hTis=tmpGene.getHeritCounts();
				HashMap dTis=tmpGene.getDabgCounts();
				
				if(hTis!=null && dTis!=null){
					Object[] hTisAr=hTis.keySet().toArray();
					Object[] dTisAr=dTis.keySet().toArray();
					hTissues=new String[hTisAr.length];
					dTissues=new String[dTisAr.length];
					for(int i=0;i<hTisAr.length;i++){
						hTissues[i]=hTisAr[i].toString();
					}
					for(int i=0;i<dTisAr.length;i++){
						dTissues[i]=dTisAr[i].toString();
					}
				}*/
		  %>
          	<TABLE name="items"  id="tblGenes" class="list_base tablesorter" cellpadding="0" cellspacing="0" >
                <THEAD>
                    <tr>
                        <th colspan="6" class="topLine noSort noBox"></th>
                        <th colspan="1" class="center noSort topLine">RNA-Seq Data</th>
                        <th colspan="<%=5+tissuesList1.length*2+tissuesList2.length*2%>"  class="center noSort topLine">Affy Exon 1.0 ST Array Data</th>
                    </tr>
                    <tr>
                        <th colspan="6"  class="topLine noSort noBox"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="<%=tissuesList1.length%>"  class="center noSort topLine">Probesets > 0.33 Heritability</th>
                        <th colspan="<%=tissuesList1.length%>" class="center noSort topLine">Probesets > 1% DABG</th>
                        <th colspan="<%=3+tissuesList2.length*2%>" class="center noSort topLine" title="eQTLs at the Gene Level.  These are calculated for Transcript Clusters which are Gene Level and not individual transcripts.">eQTLs(Gene/Transcript Cluster ID)</th>
                    </tr>
                    <tr>
                        <th colspan="6"  class="topLine noSort noBox"></th>
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
                    <TH>Gene ID</TH>
                    <TH>Gene Symbol<BR />(click for detailed transcription view)</TH>
                    <TH width="10%">Gene Description</TH>
                    <TH>Location</TH>
                    <TH>Strand</TH>
                    <TH># Ensembl Transcripts</TH>
                    <TH>Transcripts (RNA-Seq)</TH>
                    <TH>Total Probesets</TH>
                    
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<BR />(Avg)</TH>
                    <%}%>
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<BR />(Avg)</TH>
                    <%}%>
                    <TH>Transcript Cluster ID</TH>
                    <TH>Annotation Level</TH>
                    <TH>View Genome-Wide Associations</TH>
                    <%for(int i=0;i<tissuesList2.length;i++){%>
                    	<TH>Total # Locations P-Value < <%=pValueCutoff%> </TH>
                        <TH>Minimum<BR /> P-Value<BR />Location</TH>
                    <%}%>
                    </tr>
                </thead>
                
                <tbody>
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
						if(!chr.startsWith("chr")){
							chr="chr"+chr;
						}
                        %>
                        <TR <%if(curGene.getSource().equals("RNA Seq")&&curGene.isSingleExon()){%>class="singleExon"<%}%>>
                            <TD >
							<%if(curGene.getGeneID().startsWith("ENS")){%>
                            	<a href="http://www.ensembl.org/<%=fullOrg%>/Gene/Summary?g=<%=curGene.getGeneID()%>" target="_blank" title="View Ensembl Gene Details"><%=curGene.getGeneID()%></a>
                            <%}else{%>
                            	<%=curGene.getGeneID()%>
                            <%}%>
                            </TD>
                            <TD title="View detailed transcription information for gene in a new window.">
							<%if(curGene.getGeneID().startsWith("ENS")){%>
                            	<a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=curGene.getGeneID()%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank">
                            <%}else{%>
                            	<a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=chr+":"+curGene.getStart()+"-"+curGene.getEnd()%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank">
                            <%}%>
                            <%if(curGene.getGeneSymbol()!=null&&!curGene.getGeneSymbol().equals("")){%>
									<%=curGene.getGeneSymbol()%>
                            <%}else{%>
                                	No Gene Symbol
                            <%}%>
                                </a>
                            </TD>
                            <%	String description=curGene.getDescription();
								String shortDesc=description;
        						String remain="";
								if(description.indexOf("[")>0){
            						shortDesc=description.substring(0,description.indexOf("["));
									remain=description.substring(description.indexOf("[")+1,description.indexOf("]"));
        						}
							%>
                            <TD title="<%=remain%>"><%=shortDesc%></TD>
                            <TD><%=chr+":"+curGene.getStart()+"-"+curGene.getEnd()%></TD>
                            <TD><%=curGene.getStrand()%></TD>
                            <TD><%=curGene.getTranscriptCountEns()%></TD>
                            <TD><%=curGene.getTranscriptCountRna()%></TD>
                            <TD><%=curGene.getProbeCount()%></TD>
                            <!--<TD></TD>-->
                            <%for(int j=0;j<tissuesList1.length;j++){
								Object tmpH=hCount.get(tissuesList1[j]);
								Object tmpHa=hSum.get(tissuesList1[j]);
								if(tmpH!=null){
									int count=Integer.parseInt(tmpH.toString());
									double sum=Double.parseDouble(tmpHa.toString());
									%>
                                	<TD <%if(j==0){%>class="leftBorder"<%}%>><%=count%>
                                    <%if(count>0){%><BR />(<%=df2.format(sum/count)%>)<%}%>
                                    </TD>
                                <%}else{%>
                                	<TD <%if(j==0){%>class="leftBorder"<%}%>>N/A</TD>
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
                                <a href="web/GeneCentric/setupLocusSpecificEQTL.jsp?geneSym=<%=curGene.getGeneSymbol()%>&ensID=<%=curGene.getGeneID()%>&chr=<%=tc.getChromosome()%>&start=<%=tc.getStart()%>&stop=<%=tc.getEnd()%>&level=<%=tc.getLevel()%>&tcID=<%=tc.getTranscriptClusterID()%>" 
                                	target="_blank" title="View the circos plot for transcript cluster eQTLs">
									View Location Plot
                                </a></TD>
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
                                        <!--</TD>
                                        <TD>--><BR /><a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%="chr"+maxEQTL.getMarkerChr()+":"+maxEQTL.getMarker_start()+"-"+maxEQTL.getMarker_end()%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank" title="View Detailed Transcription Information for this region.">
                                        	chr<%=maxEQTL.getMarkerChr()+":"+maxEQTL.getMarker_start()+"-"+maxEQTL.getMarker_end()%>
                                        </a>
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

				 </tbody>
              </table>
          <%}%>

</div><!-- end GeneList-->

<div id="bQTLList" class="modalTabContent" style="display:none; position:relative;top:56px;border-color:#CCCCCC; border-width:1px; border-style:inset;width:995px;">
	<% ArrayList<BQTL> bqtls=gdt.getBQTLs(min,max,chromosome,myOrganism);
	%>
	<TABLE name="items" id="tblBQTL" class="list_base tablesorter" cellpadding="0" cellspacing="0">
                <THEAD>
                	<TR class="col_title">
                    	<TH>
						<%if(myOrganism.equals("Rn")){%>
                        	RGD ID
                        <%}else{%>
                            MGI ID
                        <%}%>
                        </TH>
                    	<TH>QTL Name</TH>
                        <TH>Trait</TH><!-- combine trait-subtrait  and add title= method-->
                        <TH>Phenotype</TH>
                        <TH>Associated Diseases</TH>
                        <TH>References<BR />RGD Ref<HR />PubMed</TH>
                        <TH>Candidate Genes</TH>
                        <TH>Related bQTLs</TH>
                        <TH>Location</TH><!-- add title= location method-->
                    </TR>
                </thead>
                <%if(bqtls!=null&&bqtls.size()>0){%>
                <tbody>
                <%for(int i=0;i<bqtls.size();i++){
					BQTL curBQTL=bqtls.get(i);
					if(curBQTL!=null){%>
                	<tr>
                    	<TD>
						<%if(myOrganism.equals("Rn")){%>
                        	<a href="http://rgd.mcw.edu/rgdweb/report/qtl/main.html?id=<%=curBQTL.getRGDID()%>" target="_blank"> 
							<%=curBQTL.getRGDID()%></a>
                        <%}else{%>
                            <%=curBQTL.getMGIID()%>
                        <%}%>
                        </TD>
                        <TD><%=curBQTL.getName()%></TD>
                        <TD title="<%=curBQTL.getTraitMethod()%>">
						<%=curBQTL.getTrait()%>
						<%if(curBQTL.getSubTrait()!=null){%>
						<%=" - "+curBQTL.getSubTrait()%>
                        <%}%>
                        </TD>
                        <TD><%=curBQTL.getPhenotype()%></TD>
                        <TD><%=curBQTL.getDiseases()%></TD>
                        <TD>
                        	<%	ArrayList<String> ref1=curBQTL.getRGDRef();
							for(int j=0;j<ref1.size();j++){%>
                            	<BR /><a href="http://rgd.mcw.edu/rgdweb/report/reference/main.html?id=<%=ref1.get(j)%>" target="_blank"><%=ref1.get(j)%></a>
                        	<%}%>
                        <HR />
                        
                         <%	ArrayList<String> ref2=curBQTL.getPubmedRef();
							for(int j=0;j<ref2.size();j++){%>
                            	<BR /><a href="http://www.ncbi.nlm.nih.gov/pubmed/<%=ref2.get(j)%>" target="_blank"><%=ref2.get(j)%></a>
                        <%}%>
                        </TD>
                        
                        <TD>
                        <%	ArrayList<String> candidates=curBQTL.getCandidateGene();
							for(int j=0;j<candidates.size();j++){%>
                            	<a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=candidates.get(j)%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank" title="View Detailed Transcription Information for gene."><%=candidates.get(j)%></a><BR />
                        <%}%>
                        </TD>
                        <TD><%	ArrayList<String> relQTL=curBQTL.getRelatedQTL();
							for(int j=0;j<relQTL.size();j++){%>
                            	<a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=bQTL:<%=relQTL.get(j)%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank" title="Click to View bQTL Region in a new window."><%=relQTL.get(j)%></a><BR />
                        <%}%>
                        </TD>
                        <TD title="Click to view QTL region in a new window."><a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%="chr"+curBQTL.getChromosome()+":"+curBQTL.getStart()+"-"+curBQTL.getStop()%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank">
                        chr<%=curBQTL.getChromosome()+":"+curBQTL.getStart()+"-"+curBQTL.getStop()%></a></TD>
                    </tr>
                	<%}
				}%>
                </tbody>
                <%}else{%>
                	No bQTLs to display.
                <%}%>
    </table>
</div><!-- end bQTL List-->






<div id="eQTLListFromRegion" class="modalTabContent" style=" display:none; position:relative;top:56px;border-color:#CCCCCC; border-width:1px; border-style:inset;width:995px;">

		Filter Gene List and Circos Plot:
                  <form id="form1" name="form1" method="post" action="" >
                       <label style="color:#000000; margin-left:10px;">
                        eQTL P-Value Cut-off:
                        <%
							selectName = "cutoffValue";
							selectedOption = Double.toString(pValueCutoff);
							onChange = "";
							style = "";
							optionHash = new LinkedHashMap();
										optionHash.put("0.10", "0.10");
										optionHash.put("0.01", "0.01");
										optionHash.put("0.001", "0.001");
										optionHash.put("0.0001", "0.0001");
										optionHash.put("0.00001", "0.00001");
							%>
							<%@ include file="/web/common/selectBox.jsp" %>
                       </label>         
                  </form>

		<div style="display:inline-block;text-align:left;">
        	Inside of border below, the mouse wheel zooms.  Outside of the border, the mouse wheel scrolls.
     	</div>


	<%
		String shortRegionCentricPath;
		String cutoffTimesTen; 
		if(pValueCutoff == 0.1){
			cutoffTimesTen = "10";
		}
		else if(pValueCutoff == 0.01){
			cutoffTimesTen = "20";
		}
		else if(pValueCutoff == 0.001){
			cutoffTimesTen = "30";
		}
		else if(pValueCutoff == 0.0001){
			cutoffTimesTen = "40";
		}
		else
		{
			cutoffTimesTen = "50";		
		}
		String regionCentricPath= applicationRoot+contextRoot+"tmpData/regionData/"+folderName;
		//String regionCentricPath = "/usr/share/tomcat/webapps/PhenoGen/tmpData/regionData/Rnchr19_54000000_55000000_10242012_175139";
		if(regionCentricPath.indexOf("/PhenoGen/") > 0){
			shortRegionCentricPath = regionCentricPath.substring(regionCentricPath.indexOf("/PhenoGen/"));
		}
		else{
			shortRegionCentricPath = regionCentricPath.substring(regionCentricPath.indexOf("/PhenoGenTEST/"));
		}
		String iframeURL = shortRegionCentricPath + "/circos"+cutoffTimesTen+"/svg/circos_new.svg";
	%>
	


          <div id="iframe_parent" align="center">
               <iframe src=<%=iframeURL%> height=950 width=950  position=absolute scrolling="no" style="border-style:solid; border-color:rgb(139,137,137); border-radius:15px; -moz-border-radius: 15px; border-width:1px">
               </iframe>
          </div>

	<% 
		ArrayList<TranscriptCluster> transOutQTLs=gdt.getTransControllingEQTLs(min,max,chromosome,arrayTypeID,pValueCutoff,"core",myOrganism);//this region controls what genes
		log.debug("Trans Out SIZE:"+transOutQTLs.size());
		if(transOutQTLs!=null && transOutQTLs.size()>0){
			
	%>
	<TABLE name="items" id="tblFrom" class="list_base tablesorter" cellpadding="0" cellspacing="0">
                <THEAD>
               		 <tr>
                        <th colspan="7" class="topLine noSort noBox"></th>
                        <%for(int i=0;i<tissuesList2.length;i++){%>
                        	<th colspan="2" class="center noSort topLine">Tissue:<%=tissuesList2[i]%></th>
                        <%}%>
                    </tr>
                	<TR class="col_title">
                    	<TH>Gene ID</TH>
                    	<TH>Gene Symbol<BR />(click for detailed transcription view)</TH>
                        <TH>Description</TH>
                        <TH>Transcript Cluster ID</TH>
                        <TH>Annotation Level</TH>
                        <TH>Physical Location</TH>
                        <TH>View Genome-Wide Associations</TH>
                    	<%for(int i=0;i<tissuesList2.length;i++){%>
                            <TH title="Highlighted indicates a value less than or equal to the cutoff.">P-Value from region</TH>
                            <TH># other locations P-value<<%=pValueCutoff%></TH>
                            <!--<TH>Max LOD genome-wide</TH>-->
                        <%}%>
                    	
                    </TR>
                </thead>
                <tbody>
					<%DecimalFormat df4 = new DecimalFormat("#.####");
					for(int i=0;i<transOutQTLs.size();i++){
						TranscriptCluster tc=transOutQTLs.get(i);
						
                        %>
                        <TR>
                            <TD ><a href="http://www.ensembl.org/<%=fullOrg%>/Gene/Summary?g=<%=tc.getGeneID()%>" target="_blank" title="View Ensembl Gene Details"><%=tc.getGeneID()%></a></TD>
                            
                            <TD ><a href="<%=request.getContextPath()%>/gene.jsp?geneTxt=<%=tc.getGeneID()%>&speciesCB=<%=myOrganism%>&auto=Y&newWindow=Y" target="_blank" title="View Detailed Transcription Information for gene.">
							<%if(tc.getGeneSymbol().equals("")){%>
								No Gene Symbol
							<%}else{%>
								<%=tc.getGeneSymbol()%>
                            <%}%>
                            </a></TD>
                            <%	String description=tc.getGeneDescription();
								String shortDesc=description;
        						String remain="";
								if(description.indexOf("[")>0){
            						shortDesc=description.substring(0,description.indexOf("["));
									remain=description.substring(description.indexOf("[")+1,description.indexOf("]"));
        						}
							%>
                            
                            <TD title="<%=remain%>"><%=shortDesc%></TD>
                            
                            <TD><%=tc.getTranscriptClusterID()%></TD>
                            <TD><%=tc.getLevel()%></TD>
                            
                            <TD >chr<%=tc.getChromosome()+":"+tc.getStart()+"-"+tc.getEnd()%></TD>
                            <TD ><a href="web/GeneCentric/setupLocusSpecificEQTL.jsp?geneSym=<%=tc.getGeneSymbol()%>&ensID=<%=tc.getGeneID()%>&chr=<%=tc.getChromosome()%>&start=<%=tc.getStart()%>&stop=<%=tc.getEnd()%>&level=<%=tc.getLevel()%>&tcID=<%=tc.getTranscriptClusterID()%>" 
                                	target="_blank" title="View the circos plot for transcript cluster eQTLs">View Location Plot</a></TD>
                            <%
							//String[] curTissues=tc.getTissueList();
							for(int j=0;j<tissuesList2.length;j++){
								//log.debug("TABLE2:"+tissuesList2[j]);
									ArrayList<EQTL> regionQTL=tc.getTissueRegionEQTL(tissuesList2[j]);
									ArrayList<EQTL> qtlList=tc.getTissueEQTL(tissuesList2[j]);
									EQTL regEQTL=null;
									if(regionQTL!=null && regionQTL.size()>0){
										regEQTL=regionQTL.get(0);
									}
									%>
                                        
                                        <%if(regEQTL==null){%>

												<TD class="leftBorder">>0.3</TD>

										<%}else if(regEQTL.getPVal()<0.0001){%>
                                        	<TD class="leftBorder" style="background-color:#6e99bc; color:#FFFFFF;">
                                        	< 0.0001
										<%}else{%>
                                        	<TD class="leftBorder"
                                            <%if(regEQTL.getPVal()<=0.01){%>
                                            	style="background-color:#6e99bc; color:#FFFFFF;"
                                            <%}%>
                                            >
											<%=df4.format(regEQTL.getPVal())%>
                                        <%}%>
                                        </TD>
                                        <TD>
                                        <%if(qtlList!=null && qtlList.size()>0){%>
                                        	<%=qtlList.size()%>
										<%}else{%>
                                        	0
                                        <%}%>
                                        </TD>
                                    
                                <%}%>
                            
                        </TR>
                    <%}%>

				 </tbody>
              </table>
              
      <%}%>
</div><!-- end eQTL List-->



       



</div><!-- ends page div -->



<%}else{%>
    	<div class="error"><%=genURL.get(selectedGene)%><BR />The administrator has been notified of the problem and will investigate the error.  We apologize for any inconvenience.</div><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
<%}%>
    

<div id="Help1Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>UCSC Genome Browser Image</H3>
The main image was generated by the <a target="_blank" href="http://genome.ucsc.edu/">UCSC Genome Browser</a>(click the image to open the browser at the position of the image).  There are a number of tracks which are illustrated in the image below and described in each numbered section following.
<img src="ucsc_example.jpg" />  
<ol>
<li>The first track contains all of the Affymetrix Exon Probesets for the <a target="_blank" href="http://www.affymetrix.com/estore/browse/products.jsp?productId=131474&categoryId=35765&productName=GeneChip-Mouse-Exon-ST-Array#1_1">Mouse</a> or
<a target="_blank" href="http://www.affymetrix.com/estore/browse/products.jsp?productId=131489&categoryId=35748&productName=GeneChip-Rat-Exon-ST-Array#1_1"> Rat</a> Affy Exon 1.0 ST array.  Below the image information about these probesets for a parental strains(Rat only) and <a target="_blank" href="http://www.jax.org/smsr/ristrain.html" >panels of recombinant inbred mice or rats</a> and various tissues will be displayed. </li>

<li>The next track if present contains the numbered exons for the positive strand.  If transcripts exist for the positive strand each unique exon is given a number such that the first exon is 1.  If transcripts have differing overlapping exons then the exons are numbered 1a,1b,etc.</li>
<li>Rat Only-The next track is a reconstruction of the transcriptome from RNA Sequencing.  These are the reconstructed transcripts computed by <a target="_blank" href="http://cufflinks.cbcb.umd.edu/index.html">CuffLinks</a> from RNA Sequencing data of Rat Brain.</li>
<li>This track if present contains the numbered exons for the reverse strand.  If transcripts exist for the reverse strand each unique exon is given a number such that the first exon is 1.  If transcripts have differing overlapping exons then the exons are numbered 1a,1b,etc.</li>
<li>Rat Only-CuffLinks cannot assemble all sequences.  There may be single exon "genes" from CuffLinks that in addition to being a signle gene could not be assigned to a strand.  These are numbered in this track.</li>
<li>These are standard UCSC Tracks for the RefSeq gene(top blue color) and Ensembl transcripts(bottom brown color).</li>
</ol></div></div>

<div id="Help2Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>UCSC Image Controls</H3>
This control allows you to choose between two different versions of the UCSC genome browser image.  Occasionally you may also have the option to select a different gene.  This occurs when iDecoder found more than one Ensembl Gene Identifier associated with your gene.  However the gene most closely related to the identifier you enter is selected first.<BR /><BR />
The unfiltered version of the image displays all the Affymetrix Exon probesets color coded by annotation level.<BR /><BR />
The filtered version has only probesets that were detected above background in 1% or more of the samples.  Detection Above BackGround(DABG)-Calculates the p-value that the intensities in a probeset could have been observed by chance in a background distribution. <a target="_blank" href="http://www.affymetrix.com/partners_programs/programs/developer/tools/powertools.affx">Affymetrix for more information</a>. <BR />  It also has one track per tissue where data is available (Mouse-Brain Rat-Brain,Heart,Liver,Brown Adipose).  While this is a low percentage it filters out all of the probesets that are not detected above background.
</div></div>


<div id="Help3Content" class="inpageHelpContent" title="<center>Help</center>"><div class="help-content">
<H3>Filter/Display Controls</H3>
The filters allow you to control what probesets are displayed.  Check the box next to the filter you would like to apply.  The filter will be immediately applied, unless input is required and then it will be applied as you input a value.<BR /><BR />
The display controls allow you to make choices about how the data is displayed.  Any selections are immediately applied.<BR /><BR />
The Filter and Display controls will have different options as you navigate through different tabs, but any settings will return once you navigate back to a tab.
</div></div>




<script type="text/javascript">


function displayWorking(){
	document.getElementById("wait1").style.display = 'block';
	document.getElementById("inst").style.display= 'none';
	return true;
}

function hideWorking(){
	document.getElementById("wait1").style.display = 'none';
	document.getElementById("inst").style.display= 'none';
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

$(document).ready(function() {
	document.getElementById("loadingRegion").style.display = 'none';
	
	$('#tblGenes').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"sScrollX": "950px",
	"sScrollY": "550px"
	});
	
	$('#tblBQTL').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"sScrollX": "950px",
	"sScrollY": "550px",
	"bDeferRender": true
	});
	
	$('#tblFrom').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"sScrollX": "950px",
	"sScrollY": "550px",
	"bDeferRender": true
	});
	
	 $('.cssTab div.modalTabContent').hide();
    $('.cssTab div.modalTabContent:first').show();
    $('.cssTab ul li a:first').addClass('selected');
	$('#tblGenes').dataTable().fnAdjustColumnSizing();
	

	$('#geneimageFiltered').hide();
	$('#geneimageFilteredNoArray').hide();
	$('#geneimageUnfilteredNoArray').hide();
	
	$('.inpageHelpContent').hide();
	$('.singleExon').hide();
  
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
	$('#Help3').click( function(){  		
		$('#Help3Content').dialog("open").css({'height':300,'font-size':12});
		positionHelp(400);
  	});
	
	$('.fancybox').fancybox({
		width:$(document).width(),
		height:$(document).height(),
		scrollOutside:false,
		afterClose: function(){
			$('body.noPrint').css("margin","5px auto 60px");
			return;
		}
  });
  
  
  
  $('#filteredRB').click( function(){
  		if($('#arrayOnRB').is(":checked")){
			$('#geneimageFiltered').show();
			$('#geneimageUnfiltered').hide();
			$('#geneimageFilteredNoArray').hide();
			$('#geneimageUnfilteredNoArray').hide();
		}else{
			$('#geneimageFilteredNoArray').show();
			$('#geneimageUnfilteredNoArray').hide();
			$('#geneimageFiltered').hide();
			$('#geneimageUnfiltered').hide();
		}
  });
  
  $('#unfilteredRB').click( function(){
  		if($('#arrayOnRB').is(":checked")){
  			$('#geneimageFiltered').hide();
			$('#geneimageUnfiltered').show();
			$('#geneimageFilteredNoArray').hide();
			$('#geneimageUnfilteredNoArray').hide();
		}else{
			$('#geneimageFilteredNoArray').hide();
			$('#geneimageUnfilteredNoArray').show();
			$('#geneimageFiltered').hide();
			$('#geneimageUnfiltered').hide();
		}

  });
  
  
  $('#arrayOnRB').click( function(){
  		if($('#filteredRB').is(":checked")){
			$('#geneimageFiltered').show();
			$('#geneimageUnfiltered').hide();
			$('#geneimageFilteredNoArray').hide();
			$('#geneimageUnfilteredNoArray').hide();
		}else{
			$('#geneimageFilteredNoArray').hide();
			$('#geneimageUnfilteredNoArray').hide();
			$('#geneimageFiltered').hide();
			$('#geneimageUnfiltered').show();
		}
  });
  
  $('#arrayOffRB').click( function(){
  		if($('#filteredRB').is(":checked")){
  			$('#geneimageFiltered').hide();
			$('#geneimageUnfiltered').hide();
			$('#geneimageFilteredNoArray').show();
			$('#geneimageUnfilteredNoArray').hide();
		}else{
			$('#geneimageFilteredNoArray').hide();
			$('#geneimageUnfilteredNoArray').show();
			$('#geneimageFiltered').hide();
			$('#geneimageUnfiltered').hide();
		}

  });
  
  $('#exclude1Exon').click( function(){
  		if($('#exclude1Exon').is(":checked")){
			$('.singleExon').hide();
		}else{
			$('.singleExon').show();
		}
  });
	
   
    $('.cssTab ul li a').click(function() {    

            $('.cssTab ul li a').removeClass('selected');
            $(this).addClass('selected');
            var currentTab = $(this).attr('href'); 
            $('.cssTab div.modalTabContent').hide();       
            $(currentTab).show();
			
			if(currentTab == "#geneList"){
				$('#tblGenes').dataTable().fnAdjustColumnSizing();
			}else if(currentTab == "#bQTLList"){
				$('#tblBQTL').dataTable().fnAdjustColumnSizing();
			}else if(currentTab == "#eQTLListFromRegion"){
				$('#tblFrom').dataTable().fnAdjustColumnSizing();
			}else{
				var table = $.fn.dataTable.fnTables(false);
            	if ( table.length > 0 ) {
                	$(table).dataTable().fnAdjustColumnSizing();
            	}
			}
			
            
			
            return false;
        });
	
}); // end ready

</script>





