<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<%
	
    gdt.setSession(session);
	ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList=new ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene>();
	DecimalFormat dfC = new DecimalFormat("#,###");
	String myOrganism="";
	String fullOrg="";
	String panel="";
	String chromosome="";
	String folderName="";
	String type="";
	String source="";
        String genomeVer="";
	LinkGenerator lg=new LinkGenerator(session);
	double forwardPValueCutoff=0.01;
	int rnaDatasetID=0;
	int arrayTypeID=0;
	int min=0;
	int max=0;
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
	if(request.getParameter("forwardPvalueCutoff")!=null){
		forwardPValueCutoff=Double.parseDouble(request.getParameter("forwardPvalueCutoff"));
	}
	if(request.getParameter("rnaDatasetID")!=null){
		rnaDatasetID=Integer.parseInt(request.getParameter("rnaDatasetID"));
	}
	if(request.getParameter("arrayTypeID")!=null){
		arrayTypeID=Integer.parseInt(request.getParameter("arrayTypeID"));
	}
	if(request.getParameter("chromosome")!=null){
		chromosome=request.getParameter("chromosome");
	}
	
	if(request.getParameter("minCoord")!=null){
		min=Integer.parseInt(request.getParameter("minCoord"));
	}
	if(request.getParameter("maxCoord")!=null){
		max=Integer.parseInt(request.getParameter("maxCoord"));
	}
	if(request.getParameter("type")!=null){
		type=request.getParameter("type");
	}
	if(request.getParameter("source")!=null){
		source=request.getParameter("source");
	}
        if(request.getParameter("genomeVer")!=null){
                genomeVer=request.getParameter("genomeVer");
        }
	if(min<max){
			if(min<1){
				min=1;
			}
			fullGeneList =gdt.getRegionData(chromosome,min,max,panel,myOrganism,genomeVer,rnaDatasetID,arrayTypeID,forwardPValueCutoff,true);					
			String tmpURL =gdt.getGenURL();//(String)session.getAttribute("genURL");
			int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
			if(second>-1){
				folderName=tmpURL.substring(second+1,tmpURL.length()-1);
			}
	}
			
	
%>




<div id="geneList"  style="position:relative;top:56px;border-color:#CCCCCC; border-width:1px 0px 0px 0px; border-style:inset;">

                <table class="geneFilter">
                	<thead>
                    	<TR>
                    	<TH style="width:50%"><span class="trigger triggerEC" id="geneListFilter1" name="geneListFilter" style=" position:relative;text-align:left;">Filter List</span><span class="geneListToolTip" title="Click the + icon to view filtering Options."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        <TH style="width:50%"><span class="trigger triggerEC" id="geneListFilter2" name="geneListFilter" style=" position:relative;text-align:left;">View Columns</span><span class="geneListToolTip" title="Click the + icon to view Columns you can show/hide in the table below."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        
                        </TR>
                        
                    </thead>
                	<tbody id="geneListFilter" style="display:none;">
                    	<TR>
                        	<td>
                            <%if(myOrganism.equals("Rn")){%>
                                
                            	<input name="chkbox" type="checkbox" id="exclude1Exon" value="exclude1Exon" /> Exclude single exon RNA-Seq Transcripts <span class="geneListToolTip" title="This will hide the single exon transcripts from the table when selected."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                        	<%}%>
                        
                            				eQTL P-Value Cut-off:
                                             <select name="pvalueCutoffSelect1" id="pvalueCutoffSelect1">
                                            		<option value="0.1" <%if(forwardPValueCutoff==0.1){%>selected<%}%>>0.1</option>
                                                    <option value="0.01" <%if(forwardPValueCutoff==0.01){%>selected<%}%>>0.01</option>
                                                    <option value="0.001" <%if(forwardPValueCutoff==0.001){%>selected<%}%>>0.001</option>
                                                    <option value="0.0001" <%if(forwardPValueCutoff==0.0001){%>selected<%}%>>0.0001</option>
                                                    <option value="0.00001" <%if(forwardPValueCutoff==0.00001){%>selected<%}%>>0.00001</option>
                                            </select> 
                                            <span class="geneListToolTip" title="This will filter out eQTL with lower confidence than the selected threshold.(will not remove rows from the table just the entries in the eQTL columns)"><img src="<%=imagesDir%>icons/info.gif"></span>
                                            <!--<input name="chkbox" type="checkbox" id="rqQTLCBX" value="rqQTLCBX"/>Require an eQTL below cut-off<span title=""><img src="<%=imagesDir%>icons/info.gif"></span>-->
                            </td>
                        	<td>
                            	<div class="columnLeft">
                                	<%if(myOrganism.equals("Rn")){%>
                                    <input name="chkbox" type="checkbox" id="matchesCBX" value="matchesCBX" checked="checked"/> RNA-Seq Transcript Matches <span class="geneListToolTip" title="Shows/Hides a description of the reason the RNA-Seq transcript was matched to the Ensembl Gene/Transcript."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    <%}%>
                                	
                                    <input name="chkbox" type="checkbox" id="geneIDCBX" value="geneIDCBX" checked="checked" /> Gene ID <span class="geneListToolTip" title="Shows/Hides the Gene ID column containing the Ensembl Gene ID and links to external Databases when available."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="geneDescCBX" value="geneDescCBX" checked="checked" /> Description <span class="geneListToolTip" title="Shows/Hides Gene Description column whichcontains the Ensembl Description or any annotations for RNA-Seq transcripts not associated with an Ensembl Gene/Transcript"><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                <input name="chkbox" type="checkbox" id="geneLocCBX" value="geneLocCBX" checked="checked" /> Location and Strand <span class="geneListToolTip" title="Shows/Hides the Chromosome, Start base pair, End base pair, and strand columns for the feature."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                   
                                </div>
                                <div class="columnRight">
                               		
                                   
                                 	
                                    <input name="chkbox" type="checkbox" id="heritCBX" value="heritCBX" checked="checked" /> Heritability <span class="geneListToolTip" title="Shows/Hides all of the Affymetrix Probeset Heritability data."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                	
                                	<input name="chkbox" type="checkbox" id="dabgCBX" value="dabgCBX" checked="checked" /> Detection Above Background <span class="geneListToolTip" title="Shows/Hides all of the Affymetrix Probeset Detection Above Background data."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="eqtlAllCBX" value="eqtlAllCBX" checked="checked" /> eQTLs All <span class="geneListToolTip" title="Shows/Hides all of the eQTL columns."><img src="<%=imagesDir%>icons/info.gif"></span><BR />
                                    
                                    <input name="chkbox" type="checkbox" id="eqtlCBX" value="eqtlCBX" checked="checked" />eQTLs Tissues <span class="geneListToolTip" title="Shows/Hides all of the eQTL tissue specific columns while preserving a list of transcript clusters with a link to the circos plot."><img src="<%=imagesDir%>icons/info.gif"></span>
                                </div>

                            </TD>
                        
                        </TR>
                        </tbody>
                        
                  </table>
                  
          
          
          <%
		  	String[] hTissues=new String[0];
			String[] dTissues=new String[0];
		  	if(fullGeneList.size()>0){
		  		edu.ucdenver.ccp.PhenoGen.data.Bio.Gene tmpGene=fullGeneList.get(0);
				%>
		 	
          	<TABLE name="items"  id="tblGenes<%=type%>" class="list_base" cellpadding="0" cellspacing="0"  >
                <THEAD>
                    <tr>
                        <th 
                        	<%if(myOrganism.equals("Rn")){%>
                        		colspan="8"
                        	<%}else{%>
                        	colspan="6"
                        	<%}%> 
                        	class="topLine noSort noBox" style="text-align:left;"><!--<span class="legendBtn"><img src="../web/images/icons/legend_7.png"><span style="position:relative;top:-7px;">Legend</span></span>--></th>
                        <th 
                        	<%if(myOrganism.equals("Rn")){%>
                        		colspan="2"
                        	<%}else{%>
                        		colspan="2"
                        	<%}%> 
                        class="center noSort topLine">Transcript Information</th>
                        <th colspan="<%=4+tissuesList1.length*2+tissuesList2.length*2%>"  class="center noSort topLine" title="Dataset is available by going to Microarray Analysis Tools -> Analyze Precompiled Dataset or Downloads.">Affy Exon 1.0 ST PhenoGen Public Dataset(
							<%if(myOrganism.equals("Mm")){%>
                            	Public ILSXISS RI Mice
                            <%}else{%>
                            	Public HXB/BXH RI Rats (Tissue, Exon Arrays)
                            <%}%>
                            )<div class="inpageHelp" style="display:inline-block; "><img id="HelpAffyExon" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                    </tr>
                    <tr style="text-align:center;">
                        <th 
                        <%if(myOrganism.equals("Rn")){%>
                        	colspan="8"
                        <%}else{%>
                        	colspan="6"
                        <%}%>   
                        class="topLine noSort noBox"></th>
                        <th colspan="1"  class="leftBorder noSort"></th>
                        <th colspan="1"  class="rightBorder noSort"></th>
                        <th colspan="1"  class="leftBorder rightBorder noSort"></th>
                        <th colspan="<%=tissuesList1.length%>"  class="center noSort topLine">Probe Sets > 0.33 Heritability
                          <div class="inpageHelp" style="display:inline-block; "><img id="HelpProbeHerit" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                        <th colspan="<%=tissuesList1.length%>" class="center noSort topLine">Probe Sets > 1% DABG
                          <div class="inpageHelp" style="display:inline-block; "><img id="HelpProbeDABG" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                        <th colspan="<%=3+tissuesList2.length*2%>" class="center noSort topLine" >eQTLs(Gene/Transcript Cluster ID)<div class="inpageHelp" style="display:inline-block; "><img id="HelpeQTL" class="helpImage" src="../web/images/icons/help.png" /></div></th>
                    </tr>
                    <tr style="text-align:center;">
                        <th 
                        <%if(myOrganism.equals("Rn")){%>
                        	colspan="5"
                        <%}else{%>
                        	colspan="4"
                        <%}%>  
                        class="topLine noSort noBox"></th>
                        
                        <th 
                        <%if(myOrganism.equals("Rn")){%>
                        	colspan="3"
                        <%}else{%>
                        	colspan="2"
                        <%}%>  
                        class="topLine noSort noBox"></th>
                        <th 
                        <%if(myOrganism.equals("Rn")){%>
                        colspan="2"
                        <%}else{%>
                        colspan="1"
                        <%}%>  
                        class="topLine leftBorder rightBorder noSort"># Transcripts <span class="geneListToolTip" title="The number of transcripts assigned to this gene.  Ensembl is the number of ensembl annotated transcripts.  RNA-Seq is the number of RNA-Seq transcripts assigned to this gene.  The RNA-Seq Transcript Matches column contains additional details about why transcripts were or were not matched to a particular gene."><img src="<%=imagesDir%>icons/info.gif"></span></th>
                        
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
                    <TH>Image ID (Transcript/Feature ID) <span class="geneListToolTip" title="Feature IDs that correspond to features in the various image tracks above.<%if(myOrganism.equals("Rn")){%> In addition to Ensembl transcripts, RNA-Seq transcripts, that begin with the tissue where they were identified, will be listed in this column, when they partially or fully match to an Ensembl transcript.  If none are listed there was not a match that met our matching criteria. Please refer to the next column for a description of matching criteria.<%}%>"><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <%if(myOrganism.equals("Rn")){%>
                    <TH>RNA-Seq Transcript Matches <span class="geneListToolTip" title="Information about how a RNA-Seq transcript was matched to an Ensembl Gene/Transcript.  Click if a + icon is present to view the remaining transcripts.<BR><BR>Any partial matches first list the percentage of exons matched and the transcript that was the closest match.<BR> An exon for exon match to a transcript lists the Ensembl Transcript ID and then the # of exons matching each rule. <BR><BR> Rules:<BR>-Perfect Match-the start and stop base pairs exactly align.<BR>-Fuzzy Match-the start and stop base pairs are within 5bp.<BR>-3'/5' Extended/truncated the 3'/5' end of the RNA-Seq transcript is extended or truncated.<BR>-Internal Exon extended/shifted exons not at the begining or end of the transcript and are noted as either extended at a single end or both ends or shifted in one direction.<BR><BR>Additional Rules:<BR>Cufflinks assigns transcripts to genes and on occassion transcripts in the same Cufflinks gene will match to transcripts from different genes.  In this instance the message will reflect that the transcript was assigned to a different gene but changed assignment based on another transcript belonging to the same Cufflinks gene matching a different Ensembl gene.<BR>In other instances Cufflinks created a transcript that spans multiple genes.  It can either be assigned to a specific gene based on other transcripts in the Cufflinks gene or not assigned to a gene.  In either instance it will be noted that the transcript spans multiple genes."><img src="<%=imagesDir%>icons/info.gif"></span></th>
                    <%}%>
                    <TH>Gene Symbol<span class="geneListToolTip" title="The Gene Symbol from Ensembl if available.  Click to view detailed information for that gene."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Gene ID</TH>
                    <TH width="10%">Gene Description <span class="geneListToolTip" title="The description from Ensembl or annotations from various sources if the feature is not found in Ensembl."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Location</TH>
                    <TH>Strand</TH>
                    <%if(myOrganism.equals("Rn")){%>
                    <TH  >Exon SNPs / Indels <span class="geneListToolTip" title="A count of SNPs and indels identified in the DNA-Seq data for the BN-Lx and SHR strains that fall within an exon (including untranslated regions) of at least one transcript.  Number of SNPs is on the left side of the / number of indels is on the right.  Counts are summarized for each strain when compared to the BN reference genome (Rn5).  When the same SNP/indel occurs in both, a count of the common SNPs/indels is included.  When these common counts occur they have been subtracted from the strain specific counts."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <%}%>
                    <TH>Ensembl</TH>
                    <%if(myOrganism.equals("Rn")){%>
                    	<TH>RNA-Seq</TH>
                    <%}%>
                    
                    <TH>Total Probe Sets <span class="geneListToolTip" title="The total number of non-masked probesets that overlap with any region of an Ensembl transcript<%if(myOrganism.equals("Rn")){%> or an RNA-Seq transcript<%}%>."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<HR />(Avg)</span></TH>
                    <%}%>
                    <%for(int i=0;i<tissuesList1.length;i++){%>
                    	<TH><%=tissuesList1[i]%> Count<HR />(Avg)</span></TH>
                    <%}%>
                    <TH>Transcript Cluster ID <span class="geneListToolTip" title="Transcript Cluster ID- The unique ID assigned by Affymetrix.  eQTLs are calculated for this annotation at the gene level by combining probe set data across the gene."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>Annotation Level <span class="geneListToolTip" title="The annotation level of the Transcript Cluster.  This denotes the confidence in the annotation by Affymetrix.  The confidence decreases from highest to lowest in the following order: Core,Extended,Full,Ambiguous."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <TH>View Genome-Wide Associations<span class="geneListToolTip" title="Genome Wide Associations- Shows all the locations with a P-value below the cutoff selected.  Circos is used to create a plot of each region in each tissue associated with expression of the gene selected."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                    <%for(int i=0;i<tissuesList2.length;i++){%>
                    	<TH># of eQTLs with p-value < <%=forwardPValueCutoff%> <span class="geneListToolTip" title="The number of regions in the genome significantly associated with transcript cluster expression (p-value < currently selected cut-off(see Filter List)), i.e. the number of eQTL."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
                        <TH>Minimum<BR /> P-Value<HR />Location <span class="geneListToolTip" title="The genomic location of the most significant eQTL for this transcript clusters.  Click the location to view that region."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
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
                        
						if(	(curGene.getBioType().equals("protein_coding") && curGene.getLength()>=200 && type.equals("coding")) ||
							(!curGene.getBioType().equals("protein_coding") && curGene.getLength()>=200 && type.equals("noncoding")) ||
							(type.equals("all"))
						){
						
						
							if( (source.equals("ensembl")&&curGene.getGeneID().startsWith("ENS")) ||	//ensembl track
								(source.equals("brain")&&(curGene.getGeneID().toLowerCase().startsWith("brain")||curGene.containsTranscripts("brain")))||	//Brain track
								(source.equals("liver")&&(curGene.getGeneID().toLowerCase().startsWith("liver")||curGene.containsTranscripts("liver")))||	//Liver track
								(source.equals("heart")&&(curGene.getGeneID().toLowerCase().startsWith("heart")||curGene.containsTranscripts("heart")))
							){%>
                        
                            <TR class="
                            <% String geneID="";
                            if(curGene.getSource().equals("RNA Seq")&&curGene.isSingleExon()){%>
                                singleExon
                            <%}
                            if(tc!=null){%>
                                eqtl
                            <%}
                            if(curGene.getBioType().equals("protein_coding") && curGene.getLength()>=200){%>
                                coding
                            <%}else if(!curGene.getBioType().equals("protein_coding") && curGene.getLength()>=200){
									if(curGene.getGeneID().toLowerCase().startsWith("liver")){%>
										liver
									<%}else if(curGene.getGeneID().toLowerCase().startsWith("heart")){%>
										heart
									<%}else{
                                    	viewClass="longRNA";%>
                                    	noncoding
                                    <%}%>
                             <%}else if(curGene.getLength()<200){
                                    viewClass="smallRNA";%>
                                    smallnc
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
                                                            tmpList=tmpList+tmpTrx.get(l).getIDwToolTip()+"<BR>";
                                                    }else if(l==5){
                                                        tmpList=tmpList+"</span><span id=\"fg_"+i+"\" style=\"display:none;\">"+tmpTrx.get(l).getIDwToolTip()+"<BR>";
                                                    }else{
                                                        tmpList=tmpList+tmpTrx.get(l).getIDwToolTip()+"<BR>";
                                                    }
                                            }
                                            tmpList=tmpList+"</span>";
                                        }else{
                                            for(int l=0;l<tmpTrx.size();l++){
                                                    if(l==0){
                                                            tmpList=tmpTrx.get(l).getIDwToolTip()+"<BR>";
                                                    }else{
                                                            tmpList=tmpList+tmpTrx.get(l).getIDwToolTip()+"<BR>";
                                                    }
                                            }
                                        }%>
                                        <%=tmpList%>
                                </TD>
                                <%if(myOrganism.equals("Rn")){%>
                                <TD>
                                    <%	String tmpList2="";
                                            if(curGene.getGeneID().startsWith("ENS")){
                                                    tmpList2="";
                                                    int idx=0;
                                                    for(int l=0;l<tmpTrx.size();l++){
                                                        if(!tmpTrx.get(l).getID().startsWith("ENS")){
                                                            tmpList2=tmpList2+"<B>"+tmpTrx.get(l).getID()+"</B> - <BR>"+tmpTrx.get(l).getMatchReason()+"<BR>";
                                                            idx++;
                                                        }
                                                    }
                                                    if(idx>1){
                                                        tmpList2="<span class=\"tblTrigger\" name=\"rg_"+i+"\">"+tmpList2;
                                                        int ind1=tmpList2.indexOf("<BR>");
                                                        int ind2=tmpList2.indexOf("<BR>",ind1+4);
                                                        String newTmp=tmpList2.substring(0,ind2);
                                                        tmpList2=newTmp+"</span><BR><span id=\"rg_"+i+"\" style=\"display:none;\">"+tmpList2.substring(ind2+4);
                                                        tmpList2=tmpList2+"</span>";
                                                    }
                                                
                                            }
                                        %>
                                        <%=tmpList2%>
                                </TD>
                                <%}%>
                                <TD title="View detailed transcription information for gene in a new window."><!--Gene Symbol-->
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
                                <TD ><!--Gene ID-->
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
                                  HashMap displayed=new HashMap();
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
                                %>
                                <TD title="<%=remain%>"><!--DEscription -->
									<%=shortDesc.trim().replaceAll("-","&nbsp;")%>
									<%while(itr.hasNext()){
										String sourceItr=itr.next().toString();
										String values=bySource.get(sourceItr).toString();%>
                                        <BR>
                                        <%=sourceItr.trim()+":"+values.trim()%>
									<%}%>
                                </TD>
                                
                                <TD><%=chr+": "+dfC.format(curGene.getStart())+"-"+dfC.format(curGene.getEnd())%></TD><!--location-->
                                <TD><%=curGene.getStrand()%></TD><!--Strand-->
                                <%if(myOrganism.equals("Rn")){%>
                                <TD><!--SNPS-->
                                    <%if(curGene.getSnpCount("common","SNP")>0 || curGene.getSnpCount("common","Indel")>0 ){%>
                                        Common:<BR /><%=curGene.getSnpCount("common","SNP")%> / <%=curGene.getSnpCount("common","Indel")%><BR />
                                    <%}%>
                                    <%if(curGene.getSnpCount("BNLX","SNP")>0 || curGene.getSnpCount("BNLX","Indel")>0 ){%>
                                        BN-Lx:<BR /><%=curGene.getSnpCount("BNLX","SNP")%> / <%=curGene.getSnpCount("BNLX","Indel")%><BR />
                                    <%}%>
                                    <%if(curGene.getSnpCount("SHRH","SNP")>0 || curGene.getSnpCount("SHRH","Indel")>0){%>
                                        SHR:<BR /><%=curGene.getSnpCount("SHRH","SNP")%> / <%=curGene.getSnpCount("SHRH","Indel")%><BR />
                                    <%}%>
                                    <%if(curGene.getSnpCount("SHRJ","SNP")>0 || curGene.getSnpCount("SHRJ","Indel")>0){%>
                                        SHRJ:<BR /><%=curGene.getSnpCount("SHRJ","SNP")%> / <%=curGene.getSnpCount("SHRJ","Indel")%><BR />
                                    <%}%>
                                    <%if(curGene.getSnpCount("F344","SNP")>0 || curGene.getSnpCount("F344","Indel")>0){%>
                                        F344:<BR /><%=curGene.getSnpCount("F344","SNP")%> / <%=curGene.getSnpCount("F344","Indel")%><BR />
                                    <%}%>
                                </TD>
                                <%}%>
                                <TD class="leftBorder"><%=curGene.getTranscriptCountEns()%></TD><!--#transcripts-->
                                <%if(myOrganism.equals("Rn")){%>
                                <TD><!--RNA Transcript count-->
                                    <%=curGene.getTranscriptCountRna()%>
                                </TD>
                                
                                <%}%>
                            
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
                                <%	if(tc!=null){%>
                                    <TD class="leftBorder"><%=tc.getTranscriptClusterID()%></TD>
                                    <TD><%=tc.getLevel()%></TD>
                                    <TD><a href="web/GeneCentric/setupLocusSpecificEQTL.jsp?geneSym=<%=curGene.getGeneSymbol()%>&ensID=<%=curGene.getGeneID()%>&chr=<%=tc.getChromosome()%>&start=<%=tc.getStart()%>&stop=<%=tc.getEnd()%>&level=<%=tc.getLevel()%>&tcID=<%=tc.getTranscriptClusterID()%>&curDir=<%=folderName%>" target="_blank" title="View the circos plot for transcript cluster eQTLs">View Location Plot</a>
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
                                    <TD class="leftBorder"></TD>
                                    <TD></TD>
                                    <TD></TD>
                                    <%for(int j=0;j<tissuesList2.length;j++){%>
                                        <TD class="leftBorder"></TD>
                                        <TD></TD>
                                    <%}%>
                         <%}%>
                        </TR>
                     <%}%>
                     <%}%>
                 <%}%>
					
				 </tbody>
              </table>
<script type="text/javascript">
	var spec="<%=myOrganism%>";
	
	/*
	$('.viewSMNC').click( function(event){
		var tmpID=$(this).attr('id');
		var id=tmpID.substr(0,tmpID.indexOf(":"));
		var name=tmpID.substr(tmpID.indexOf(":")+1);
		openSmallNonCoding(id,name);
		$('#viewTrxDialog').dialog( "option", "position",{ my: "center bottom", at: "center top", of: $(this) });
		$('#viewTrxDialog').dialog("open").css({'font-size':12});
	});*/
	
	//var geneTargets=[1];
	var sortCol=5;
	if(spec =="Mm"){
		sortCol=4;
	}
	
	
	var tblGenes=$('#tblGenes<%=type%>').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"bStateSave": false,
	"bAutoWidth": true,
	"bDeferRender": true,
	"sScrollX": $(this).parent().width()-5,
	"sScrollY": "500px",
	"aaSorting": [[ sortCol, "desc" ]],
	/*"aoColumnDefs": [
      { "bVisible": false, "aTargets": geneTargets }
    ],*/
	"sDom": '<"leftSearch"fr><t>'
	/*"oTableTools": {
			"sSwfPath": "/css/swf/copy_csv_xls_pdf.swf"
		}*/

	});

	$('#tblGenes_wrapper').css({position: 'relative', top: '-56px'});

	$('#heritCBX').click( function(){
			var tmpCol=11;
			if(spec=="Mm"){
				tmpCol=7;
			}
			displayColumns(tblGenes, tmpCol,tisLen,$('#heritCBX').is(":checked"));
	  });
	  $('#dabgCBX').click( function(){
	  		var tmpCol=11+tisLen;
			if(spec=="Mm"){
				tmpCol=7+tisLen;
			}
			displayColumns(tblGenes, tmpCol ,tisLen,$('#dabgCBX').is(":checked"));
	  });
	  $('#eqtlAllCBX').click( function(){
	  		var tmpCol=11+tisLen*2;
			if(spec=="Mm"){
				tmpCol=7+tisLen*2;
			}
			displayColumns(tblGenes, tmpCol,tisLen*2+3,$('#eqtlAllCBX').is(":checked"));
	  });
		$('#eqtlCBX').click( function(){
			var tmpCol=11+tisLen*2+3;
			if(spec=="Mm"){
				tmpCol=7+tisLen*2+3;
			}
			displayColumns(tblGenes, tmpCol,tisLen*2,$('#eqtlCBX').is(":checked"));
	  });
	  $('#matchesCBX').click( function(){
			displayColumns(tblGenes,1,1,$('#matchesCBX').is(":checked"));
	  });
	   $('#geneIDCBX').click( function(){
	   		var tmpCol=3;
			if(spec=="Mm"){
				tmpCol=2;
			}
			displayColumns(tblGenes,tmpCol,1,$('#geneIDCBX').is(":checked"));
	  });
	  $('#geneDescCBX').click( function(){
	  		var tmpCol=4;
			if(spec=="Mm"){
				tmpCol=3;
			}
			displayColumns($(tblGenes).dataTable(),tmpCol,1,$('#geneDescCBX').is(":checked"));
	  });
	  
	  
	  $('#geneLocCBX').click( function(){
	  		var tmpCol=5;
			if(spec=="Mm"){
				tmpCol=4;
			}
			displayColumns($(tblGenes).dataTable(),tmpCol,2,$('#geneLocCBX').is(":checked"));
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
	
	$('.geneListToolTip').tooltipster({
		position: 'top-right',
		maxWidth: 450,
		offsetX: 8,
		offsetY: 5,
		contentAsHTML:true,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
	});
	
	//below fixes a bug in IE9 where some whitespace may cause an extra column in random rows in large tables.
	//simply remove all whitespace from html in a table and put it back.
	if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)){ //test for MSIE x.x;
 		var ieversion=new Number(RegExp.$1) // capture x.x portion and store as a number
		if (ieversion<10){
			var expr = new RegExp('>[ \t\r\n\v\f]*<', 'g');
			var tbhtml = $('#tblGenes<%=type%>').html();
			$('#tblGenes<%=type%>').html(tbhtml.replace(expr, '><'));
			
		}	
	}
	
	tblGenes.fnAdjustColumnSizing();
	//tblGenes.fnDraw();
	
	/*$(window).resize(function(){
			tblGenes.
		});*/
</script>


          <%}else{%>
          	No genes found in this region.  Please expand the region and try again.
          <%}%>

</div><!-- end GeneList-->


