<%@ include file="/web/common/session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<%
	
    gdt.setSession(session);
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList=new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
	String myOrganism="";
	String id="";
	String chromosome="";
	
	String[] selectedLevels=null;
	String levelString="core;extended;full";
	String fullOrg="";
		String panel="";
	String gcPath="";
	int selectedGene=0;
	ArrayList<String>geneSymbol=new ArrayList<String>();
	LinkGenerator lg=new LinkGenerator(session);
	
	
	
	if(request.getParameter("levels")!=null && !request.getParameter("levels").equals("")){			
				String tmpSelectedLevels = request.getParameter("levels");
				selectedLevels=tmpSelectedLevels.split(";");
				log.debug("Getting selected levels:"+tmpSelectedLevels);
				levelString = "";
				//selectedLevelError = true;
				for(int i=0; i< selectedLevels.length; i++){
					//selectedLevelsError = false;
					levelString = levelString + selectedLevels[i] + ";";
				}
	}else{
		log.debug("Getting selected levels: NULL Using defaults.");
		selectedLevels=levelString.split(";");
	}
	if(request.getParameter("species")!=null){
		myOrganism=request.getParameter("species").trim();
		if(myOrganism.equals("Rn")){
			panel="BNLX/SHRH";
			fullOrg="Rattus_norvegicus";
		}else{
			panel="ILS/ISS";
			fullOrg="Mus_musculus";
		}
	}
	if(request.getParameter("chromosome")!=null){
		chromosome=request.getParameter("chromosome");
	}
	
		
	if(request.getParameter("geneSymbol")!=null){
		geneSymbol.add(request.getParameter("geneSymbol"));
	}else{
		geneSymbol.add("None");
	}
	if(request.getParameter("id")!=null){
		id=request.getParameter("id");
	}
	
	gcPath=applicationRoot + contextRoot+"tmpData/geneData/" +id+"/";
	
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
	int rnaDatasetID=0;
	int arrayTypeID=0;
	
	int[] tmp=gdt.getOrganismSpecificIdentifiers(myOrganism,dbConn);
							if(tmp!=null&&tmp.length==2){
								rnaDatasetID=tmp[1];
								arrayTypeID=tmp[0];
							}
	String genURL="";
	String urlPrefix=(String)session.getAttribute("mainURL");
    if(urlPrefix.endsWith(".jsp")){
         urlPrefix=urlPrefix.substring(0,urlPrefix.lastIndexOf("/")+1);
    }
	genURL=urlPrefix+ "tmpData/geneData/" +id+"/";
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> tmpGeneList=gdt.getGeneCentricData(id,id,panel,myOrganism,rnaDatasetID,arrayTypeID,true);
	edu.ucdenver.ccp.PhenoGen.data.Bio.Gene curGene=null;
	for(int i=0;i<tmpGeneList.size();i++){
		log.debug("check:"+tmpGeneList.get(i).getGeneID()+":"+id);
		if(tmpGeneList.get(i).getGeneID().equals(id)){
			log.debug("found:"+tmpGeneList.get(i).getGeneID());
			curGene=tmpGeneList.get(i);
		}
	}
%>


<!--<a href="web/GeneCentric/geneApplet.jsp?selectedID=<%=id%>" target="_blank">View Affy Probe Set Details</a>
<BR /><BR />
<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%; ">
    <span class="trigger less" name="geneReport"  style="margin-left:30px;">Gene Details</span>
    <div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
</div>
<div id="geneReport" >
Add report here.
</div>
<BR /><BR />
<div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%; ">
    <span class="triggerNoAction" name="geneReportEQTL"  style="margin-left:30px;">Gene EQTLs (Circos Plot)</span>
    <div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
</div>
<div id="geneReportEQTL" style="display:none;"></div>
            
<BR /><BR />-->

<!--<script type="text/javascript">
	$("span[name='geneReportEQTL']").click(function (){
        var thisHidden = $("div#geneReportEQTL").is(":hidden");
        if (thisHidden) {
			$("div#geneReportEQTL").show();
			$(this).addClass("less");
			var jspPage="web/GeneCentric/geneEQTLAjax.jsp";
			var params={
				species: organism,
				geneSymbol: selectedGeneSymbol,
				chromosome: chr,
				id:selectedID
			};
			loadDivWithPage("div#geneReportEQTL",jspPage,params,
					"<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Laoding...</span>");
        } else {
			$("div#geneReportEQTL").hide();
			$(this).removeClass("less");
        }
		});
</script>-->

<div style="font-size:18px; font-weight:bold; background-color:#FFFFFF; color:#000000; text-align:center; width:100%; padding-top:3px;">
            <span class="selectdetailMenu selected" name="geneDetail">Gene Details<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
    		<span class="selectdetailMenu" name="geneEQTL">Gene eQTLs<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
    		<span class="selectdetailMenu" name="geneApp">Probe Set Level Data<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
</div>

<div style="font-size:18px; font-weight:bold; background-color:#47c647; color:#FFFFFF; text-align:left; width:100%; ">
    <span class="trigger triggerEC less" name="geneDiv"  style="margin-left:30px;">Selected Feature Summary</span>    
</div>

<div id="geneDiv" style="display:inline-block;text-align:left; width:100%;">
	<div style="display:inline-block; text-align:left;width:100%;" id="geneDetail">
    	
        <% 	DecimalFormat df2 = new DecimalFormat("#.##");
			DecimalFormat df0 = new DecimalFormat("###");
			DecimalFormat df4 = new DecimalFormat("#.####");
			DecimalFormat dfC = new DecimalFormat("#,###");

			TranscriptCluster tc=curGene.getTranscriptCluster();
            
			HashMap hCount=curGene.getHeritCounts();
            HashMap dCount=curGene.getDabgCounts();
			HashMap hSum=curGene.getHeritAvg();
            HashMap hMin=curGene.getHeritMin();
			HashMap hMax=curGene.getHeritMax();
			HashMap dSum=curGene.getDabgAvg();
			HashMap dMin=curGene.getDabgMin();
			HashMap dMax=curGene.getDabgMax();
			
			String chr=curGene.getChromosome();
			ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Transcript> tmpTrx=curGene.getTranscripts();
			if(!chr.startsWith("chr")){
				chr="chr"+chr;
			}
            %>
            <table class="geneReport" style="width:100%;">
            <TR>
            <TD style="min-width:150px;">
             Gene Symbol: 
             </TD>
             <TD>
            <%if(curGene.getGeneSymbol()!=null && !curGene.getGeneSymbol().equals("")){%>
                                        <%=curGene.getGeneSymbol()%>
            <%}else{%>
                                        No Gene Symbol Found
           	<%}%>
            </TD>
            </TR>
            <TR>
            	<TD>
            		Location:  
					</TD>
				<TD>
					<%=chr+": "+dfC.format(curGene.getStart())+"-"+dfC.format(curGene.getEnd())%>
                    </TD>
            </TR>
            <TR>
                <TD>
                	Strand:
                </TD> 
				<TD>
					<%=curGene.getStrand()%>
                    </TD>
             </TR>
                
            <TR>
            	<TD > Description:</TD>
                <TD >
                	
					<%String description=curGene.getDescription();
                                        String shortDesc=description;
                                        String remain="";
                                        if(description.indexOf("[")>0){
                                            shortDesc=description.substring(0,description.indexOf("["));
                                            remain=description.substring(description.indexOf("[")+1,description.indexOf("]"));
                                        }
                                %>
                                <span title="Description <%=remain%>">
                                	<%String bioType=curGene.getBioType();%>
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
                                    </span>
                                    
                                </TD>
            </TR>
            <TR></TR>
            <TR>
            	<TD> Links:</TD>
                <TD>
                	
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
                 
            </TR>
            <TR>
            	<TD></TD>
                <TD></TD>
            </TR>
            
            
                               
                                 
                                
                               
            <%if(myOrganism.equals("Rn")){%>
   			<TR>
            	<TD>Exonic SNPs:</TD>
                
                                <TD>
                                    <%if(curGene.getSnpCount("common","SNP")>0 || curGene.getSnpCount("common","Indel")>0 ){%>
                                        Common:<BR /><%=curGene.getSnpCount("common","SNP")%> / <%=curGene.getSnpCount("common","Indel")%><BR />
                                    <%}%>
                                    <%if(curGene.getSnpCount("BNLX","SNP")>0 || curGene.getSnpCount("BNLX","Indel")>0 ){%>
                                        BN-Lx:<BR /><%=curGene.getSnpCount("BNLX","SNP")%> / <%=curGene.getSnpCount("BNLX","Indel")%><BR />
                                    <%}%>
                                    <%if(curGene.getSnpCount("SHRH","SNP")>0 || curGene.getSnpCount("SHRH","Indel")>0){%>
                                        SHR:<BR /><%=curGene.getSnpCount("SHRH","SNP")%> / <%=curGene.getSnpCount("SHRH","Indel")%>
                                    <%}%>
                                </TD>
                                
            </TR>
            <%}%>
            <TR>
            <TD>
			Transcripts:
            </TD>
            <TD>
                <%	                       
                for(int l=0;l<tmpTrx.size();l++){%>
					<B><%=tmpTrx.get(l).getIDwToolTip()%></B>
					<%if(myOrganism.equals("Rn") && curGene.getGeneID().startsWith("ENS")){
						if(!tmpTrx.get(l).getID().startsWith("ENS")){%>
							 - <%=tmpTrx.get(l).getMatchReason()%>
						<%}
					}%>
					<BR>
					
               	<%}%>
            </TD>
            </TR>
            <TR>
            	<TD class="header">Affy Probe Set Data</TD>
                <TD class="header">Overlapping Probe Set Count:<%=curGene.getProbeCount()%></TD>
            </TR>
            <%if(curGene.getProbeCount()>0){%>
            <TR>
            	<TD colspan="2"><B>Probe sets detected above background:</B></TD>
            </TR>
            <TR>
            	<TD colspan="2">
                	<table id="tblGeneDabg"  name="items" class="list_base" style="width:100%; text-align:center;">
                                        <thead>
                                        <tr class="col_title">
                                        	<TH style="color:#000000;">Tissue</TH>
                                            <TH style="color:#000000;">Number of probe sets detected above background in more than 1% of samples (out of <%=curGene.getProbeCount()%> probe sets for this gene)</TH>
                                            <TH style="color:#000000;">Avg % of samples DABG</TH>
                                            <TH style="color:#000000;">Range</TH>
                                            
                                        </tr>
                                        </thead>
                                        <tbody>
										<%for(int j=0;j<tissuesList1.length;j++){
                                                        Object tmpD=dCount.get(tissuesList1[j]);
                                                        Object tmpDa=dSum.get(tissuesList1[j]);
														Object tmpDl=dMin.get(tissuesList1[j]);
														Object tmpDh=dMax.get(tissuesList1[j]);
														%>
                                                        <TR>
														<%if(tmpD!=null){
                                                            int count=Integer.parseInt(tmpD.toString());
                                                            double sum=Double.parseDouble(tmpDa.toString());
															double min=Double.parseDouble(tmpDl.toString());
															double max=Double.parseDouble(tmpDh.toString());
                                                        %>
                                                            <TD><%=tissuesList1[j]%></TD>
															<TD><%=count%></TD> 
															<%if(count>0){%>
																<TD><%=df0.format(sum/count)%> %</TD>
                                                                <TD><%=df2.format(min)%> - <%=df2.format(max)%> %</TD>
															<%}else{%>
                                                            	<TD>0</TD>
                                                                <TD></TD>
                                                                <TD></TD>
                                                            <%}%>
                                                           
                                                        <%}else{%>
                                                            <TD><%=tissuesList1[j]%></TD><TD></TD><TD></TD><TD></TD><TD></TD>
                                                        <%}%>
                                                        </TR>
                                       <%}%>
                                       </tbody>
                      </table>
                </TD>
            </TR>
             <TR>
            	<TD colspan="2"><B>Probe Set Heritability >0.33:</B></TD>
                
            </TR>
            <TR>
            	<TD colspan="2">
                	<table id="tblGeneHerit" name="items" class="list_base" style="width:100%; text-align:center;">
                                        <thead>
                                        
                                        <tr class="col_title">
                                        	<TH style="color:#000000;">Tissue</TH>
                                            <TH style="color:#000000;">Number of probe sets with a heritability greater than 0.33 (out of <%=curGene.getProbeCount()%> probe sets for this gene)</TH>
                                            <TH style="color:#000000;">Avg Herit</TH>
                                            <TH style="color:#000000;">Range</TH>
                                        </tr>
                                        </thead>
                                        <tbody>
										<%for(int j=0;j<tissuesList1.length;j++){
                                                        Object tmpH=hCount.get(tissuesList1[j]);
                                                        Object tmpHa=hSum.get(tissuesList1[j]);
														Object tmpHl=hMin.get(tissuesList1[j]);
														Object tmpHh=hMax.get(tissuesList1[j]);%>
                                                        <TR>
                                                        <%if(tmpH!=null){
                                                            int count=Integer.parseInt(tmpH.toString());
                                                            double sum=Double.parseDouble(tmpHa.toString());
															double min=Double.parseDouble(tmpHl.toString());
															double max=Double.parseDouble(tmpHh.toString());
                                                        %>
                                                        
                                                            <TD><%=tissuesList1[j]%></TD>
															<TD><%=count%></TD>
															<%if(count>0){%>
                                                            	<TD><%=df2.format(sum/count)%></TD>
                                                                <TD><%=df2.format(min)%> - <%=df2.format(max)%></TD>
															<%}else{%>
                                                            	<TD>0</TD>
                                                                <TD></TD>
                                                                
                                                             <%}%>
                                                        <%}else{%>
                                                            <TD><%=tissuesList1[j]%></TD><TD></TD><TD></TD><TD></TD>
                                                        <%}%>
                                                        </TR>
                                       <%}%>
                                       </tbody>
                	</table>
                </TD>
            </TR>
            <%}%>
            
            <%	if(tc!=null){	
                                    //String[] curTissues=tc.getTissueList();%>
                                    <TR>
                                         <TD class="header">EQTLs</TD>
                                         <TD class="header">Affymetrix Transcript Cluster(Confidence Level): <%=tc.getTranscriptClusterID()%> (<%=tc.getLevel()%>)</TD>
                                     </TR>
                                     
                                    <TR>
                                    <TD colspan="2">
                                    	<table id="tblGeneEQTL"  name="items" class="list_base" style="width:100%; text-align:center;">
                                        <thead>
                                        <tr class="col_title">
                                        	<TH colspan="2"></TH>
                                            <TH colspan="2" style="color:#000000;">Minimum P-value EQTL</TH>
                                        </tr>
                                        <tr class="col_title">
                                        	<TH style="color:#000000;">Tissue</TH>
                                            <TH style="color:#000000;">Number of eQTLs</TH>
                                            <TH style="color:#000000;">P-value</TH>
                                            <TH style="color:#000000;">Location</TH>
                                        </tr>
                                        </thead>
                                        <tbody>
										<%for(int j=0;j<tissuesList2.length;j++){
                                            //log.debug("TABLE1:"+tissuesList2[j]);
                                            ArrayList<EQTL> qtlList=tc.getTissueEQTL(tissuesList2[j]);
                                            if(qtlList!=null){
                                                EQTL maxEQTL=qtlList.get(0);
                                            %>
                                                <TR>
                                                    <TD><%=tissuesList2[j]%></TD>
                                                <TD><%=qtlList.size()%></TD>
    
                                                    <TD>
                                                        <%if(maxEQTL.getPVal()<0.0001){%>
                                                            < 0.0001
                                                        <%}else{%>
                                                            <%=df4.format(maxEQTL.getPVal())%>
                                                        <%}%>
                                                    </TD>
                                                    <TD>
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
                                                </TR>
                                            <%}else{%>
                                               <TR>
                                                    <TD><%=tissuesList2[j]%></TD>
                                                    <TD></TD>
                                                    <TD></TD>
                                                    <TD></TD>
                                               </TR>
                                            <%}%>
                                        <%}%>
                                        </tbody>
                                        </table>
                                    </TD>
                                    </TR>
             <%}%>
                                    
          </table>              
                                
    </div>
    <div style="display:none;" id="geneEQTL">
    </div>
    <div style="display:none;" id="geneApp">
    		<div style="text-align:center;">
                <div id="javaError" style="display:none;">
                    <BR /><BR /><br />
                    <span style="color:#FF0000;">Error:</span>Java is required for the Detailed Transcription Information results for this page.  Please correct the error listed below.  <BR />
                    <BR />
                </div>
        		<div id="unsupportedChrome" style="display:none;color:#FF0000;">A Java plug in is required to view this page.  Chrome is a 32-bit browser and requires a 32-bit plug-in which is unavailable for Mac OS X.  
            	Please try using Safari or FireFox with the Java Plug in installed.  Note: In browsers that support the 64-bit plug in you will be prompted to install Java if it is not already installed.</div>
                <span id="disabledJava" style="display:none;margin-left:40px;">
                <span style="color:#FF0000;">Java has been disabled in your browser.</span><BR />
                            To enable Java in your browser or operating system, see:<BR><BR> 
                            Firefox: <a href="http://support.mozilla.org/en-US/kb/unblocking-java-plugin" target="_blank">http://support.mozilla.org/en-US/kb/unblocking-java-plugin</a><BR><BR>
                            Internet Explorer: <a href="http://java.com/en/download/help/enable_browser.xml" target="_blank">http://java.com/en/download/help/enable_browser.xml</a><BR><BR>
                            Safari: <a href="http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html" target="_blank">http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html</a><BR><BR>
                            Chrome: <a href="http://java.com/en/download/faq/chrome.xml" target="_blank">http://java.com/en/download/faq/chrome.xml</a><BR /><BR /></span>
                
                <span id="noJava" style="color:#FF0000;display:none;"> No Java Plug-in is installed or a newer version is required click the Install button for the latest version.<BR /></span>
                <span id="oldJava" style="color:#00AA00;display:none;">A newer Java version may be available click the Install button for the latest version.(You may still use all functions even if you see this message.)<BR /></span>
                <span id="installJava" style="display:none;" class="button">Install Java</span>
			</div>


	
            <!--<script>
                
    </script>-->
            
                <script type="text/javascript">
				var bug=0;
				var jre=deployJava.getJREs();
				var unsupportedChrome=0;
				// check if current JRE version is greater than 1.6.0 
                if(!navigator.javaEnabled()){
                        $('#javaError').css("display","inline-block");
                        $('#disabledJava').css("display","inline-block");
                }else if (deployJava.versionCheck('1.6.0+') == false) {
                     $('#javaError').css("display","inline-block");
                    $('#noJava').css("display","inline-block");                  
                    $('#installJava').css("display","inline-block");
                }else{
                    if (deployJava.versionCheck('1.7.0+') == false) {                   
                        $('#oldJava').css("display","inline-block");
                        $('#installJava').html("Update Java");
                        $('#installJava').css("display","inline-block");
                    }
                }
                $('#installJava').click(function (){
                    // Set deployJava.returnPage to make sure user comes back to 
                    // your web site after installing the JRE
                    deployJava.returnPage = location.href;
                            
                    // Install latest JRE or redirect user to another page to get JRE
                    deployJava.installLatestJRE(); 
                });	
				//alert("Initial:"+jre+":"+navigator.userAgent);
				if (/Mac OS X[\/\s](\d+[_\.]\d+)/.test(navigator.userAgent)){ //test for Firefox/x.x or Firefox x.x (ignoring remaining digits);
						//var macVersion=new Number(RegExp.$1); // capture x.x portion and store as a number
						var tmpAgent=new String(navigator.userAgent);
						//alert("Detected Mac OS X:"+tmpAgent);
						if(/Chrome/.test(tmpAgent) && /10[_\.][789]/.test(tmpAgent)){
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
							if(update>=10){
									bug=1;
							}
						}
				}
				if(unsupportedChrome==0){
					
				}else{
					$('#unsupportedChrome').show();
				}
				if(bug==1){
					$('div#macBugDesc').show();
				}
				</script>
        <div >
                        This feature requires Java which will open in a seperate window, when you click the button below.  If any problems were detected with your version of Java instructions would appear above.  Please continue if you do not see an error with instructions for fixing the error.<BR /><BR />
                        <span class="button" style="width:200px;"><a href="web/GeneCentric/geneApplet.jsp?selectedID=<%=id%>" target="_blank">View Affy Probe Set Details</a></span>
        </div>
 	</div>
 </div>
            




<script type="text/javascript">
	var idStr="<%=id%>";
	
	var rows=$("table#tblGeneDabg tr");
	stripeTable(rows);
	rows=$("table#tblGeneHerit tr");
	stripeTable(rows);
	rows=$("table#tblGeneEQTL tr");
	stripeTable(rows);
	
	$('.selectdetailMenu').click(function (){
		var oldID=$('.selectdetailMenu.selected').attr("name");
		$("#"+oldID).hide();
		$('.selectdetailMenu.selected').removeClass("selected");
		$(this).addClass("selected");
		var id=$(this).attr("name");
		$("#"+id).show();
		if(id=="geneEQTL"){
			var jspPage="web/GeneCentric/geneEQTLAjax.jsp";
			var params={
				species: organism,
				geneSymbol: selectedGeneSymbol,
				chromosome: chr,
				id:selectedID
			};
			loadDivWithPage("div#geneEQTL",jspPage,params,
					"<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
		}else if(id=="geneApp"){
			$.ajax({
					url: "web/GeneCentric/callPanelExpr.jsp",
	   				type: 'GET',
					data: {id:idStr,organism: organism,chromosome: chr,minCoord:svgList[1].xScale.domain()[0],maxCoord:svgList[1].xScale.domain()[1],rnaDatasetID:rnaDatasetID,arrayTypeID: arrayTypeID},
					dataType: 'json',
	    			error: function(xhr, status, error) {console.log(error);}
	    			});
		}
		
	});
</script>

