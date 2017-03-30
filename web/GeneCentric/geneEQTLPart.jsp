	<style type="text/css">
		/* Recommended styles for two sided multi-select*/
		.tsmsselect {
			width: 40%;
			float: left;
		}
		
		.tsmsselect select {
			width: 100%;
		}
		
		.tsmsoptions {
			width: 20%;
			float: left;
		}
		
		.tsmsoptions p {
			margin: 2px;
			text-align: center;
			font-size: larger;
			cursor: pointer;
		}
		
		.tsmsoptions p:hover {
			color: White;
			background-color: Silver;
		}
	</style>
	<script type="text/javascript">
                var source="<%=source%>";
		function displayWorkingCircos(){
			document.getElementById("wait2").style.display = 'block';
			//document.getElementById("circosError1").style.display = 'none';
		}
		function hideWorkingCircos(){
			document.getElementById("wait2").style.display = 'none';
			//document.getElementById("circosError1").style.display = 'none';		
		}
		function runCircos(){
			$('#wait2').show();
			var chrList = "";
                        $("#chromosomesMS option").each(function () {
                            chrList += $(this).val() + ";";
                        });

			var tisList = "";
                        $("#tissuesMS option").each(function () {
                            tisList += $(this).val() + ";";
                        });
			
			var pval=$('#cutoffValue').val();
			var tcID=$('#transcriptClusterID').val();
                        if(source==="seq"){
                            tcID=idStr;
                        }
			var path="<%=gcPath%>";
                        
			var geneSymbol="<%=geneSymbol.get(selectedGene)%>";
                        console.log("before AJAX");
			$.ajax({
				url: contextPath + "/web/GeneCentric/runCircos.jsp",
   				type: 'GET',
                                cache: false,
				data: {cutoffValue:pval,transcriptClusterID:tcID,tissues:tisList,chromosomes:chrList,geneCentricPath:path,hiddenGeneSymbol:geneSymbol,genomeVer:genomeVer,source:source},
				dataType: 'html',
				beforeSend: function(){
				},
				complete: function(){
                                    displayType="RNA-Seq";
                                    if(source==="array"){
                                        displayType="Microarray";
                                    }
                                    $('span#typeLabel').html(displayType);
                                    $('#wait2').hide();
                                    $('#forIframe').show();
				},
                                success: function(data2){ 
                                        $('#forIframe').html(data2);
                                },
                                error: function(xhr, status, error) {
                                        $('#forIframe').html("<div>An error occurred generating this image.  Please try back later.</div>");
                                }
			});
                        console.log("after AJAX");
			//$('.allowChromSelection').show();
		}
                function changeSource(){
                    console.log("changeSource");
                    tmpSrc=$('#sourceCB').val();
                    if(tmpSrc==="seq"){
                        $("#tissuesMS option[value='Heart']").remove();
                        $("#tissuesMStsms option[value='Heart']").remove();
                        $("#tissuesMS option[value='BAT']").remove();
                         $("#tissuesMStsms option[value='BAT']").remove();
                    }else{
                        $("#tissuesMS").append('<option value="Heart" selected>Heart</option>');
                        $("#tissuesMS").append('<option value="BAT" selected>Brown Adipose</option>');
                    }
                    //$("#tissuesMS").twosidedmultiselect();
                }
	</script>
    <%
		String selectedCutoffValue = null;
		String transcriptClusterFileName = null;
		String geneSymbolinternal= geneSymbol.get(selectedGene);
		String geneCentricPath = gcPath;
		String[] selectedChromosomes = null;
			String[] selectedTissues = null;
			String chromosomeString = null;
			String tissueString = null;
			String[] transcriptClusterArray = null;
			int[] transcriptClusterArrayOrder = null;
			Boolean transcriptError = null;
			String species = myOrganism;
			String selectedTranscriptValue = null;
			Boolean selectedChromosomeError = null;
			Boolean selectedTissueError = null;
			Boolean circosReturnStatus = null;
			Boolean allowChromosomeSelection = false; // This variable now controls both tissue and chromosome selection
			String iframeURL = null;
			String svgPdfFile = null;
		if(request.getParameter("cutoffValue")!=null){
			selectedCutoffValue = FilterInput.getFilteredInput(request.getParameter("cutoffValue"));
			log.debug(" Selected Cutoff Value " + selectedCutoffValue);
			
		}
		transcriptClusterFileName = geneCentricPath.concat("tmp_psList_transcript.txt");
		//
			// Read in transcriptClusterID information from file
			// Also get the chromosome that corresponds to the gene symbol
			//
		boolean fileError=false;
		try{
                log.debug("readFile:"+transcriptClusterFileName);
          	transcriptClusterArray = myFileHandler.getFileContents(new File(transcriptClusterFileName));
                log.debug("TranscriptClusterArray:\n"+transcriptClusterArray.length);
		}catch(IOException e){
			fileError=true;
		}
          	String[] columns;
			log.debug("transcriptClusterArray length = "+transcriptClusterArray.length);
			// If the length of the transcript Cluster Array is 0, return an error.
			if(transcriptClusterArray==null || transcriptClusterArray.length == 0){
				log.debug(" the transcript cluster file is empty ");
				transcriptClusterArray = new String[1];
				transcriptClusterArray[0]="No Available	xx	xxxxxxxx	xxxxxxxx	Transcripts";
				log.debug(transcriptClusterArray[0]);
				transcriptError = true;
			}
			else{
				transcriptError = false;
                                // Need to change the transcript Cluster Array
				// Only include ambiguous if there are no other transcript clusters
				// Order the transcript cluster array so core is first, full is next, then extended, then ambiguous
				transcriptClusterArrayOrder = new int[transcriptClusterArray.length];
				for(int i=0; i < transcriptClusterArray.length; i++){
					transcriptClusterArrayOrder[i] = -1;
				}
				int numberOfTranscriptClusters = 0;
				for(int i=0; i < transcriptClusterArray.length; i++){
					columns = transcriptClusterArray[i].split("\t");
					if(columns[4].equals("core")){
						transcriptClusterArrayOrder[numberOfTranscriptClusters]=i;
						numberOfTranscriptClusters++;
					}
				}
				for(int i=0; i < transcriptClusterArray.length; i++){
					columns = transcriptClusterArray[i].split("\t");
					if(columns[4].equals("extended")){
						transcriptClusterArrayOrder[numberOfTranscriptClusters]=i;
						numberOfTranscriptClusters++;
					}
				}
				for(int i=0; i < transcriptClusterArray.length; i++){
					columns = transcriptClusterArray[i].split("\t");
					if(columns[4].equals("full")){
						transcriptClusterArrayOrder[numberOfTranscriptClusters]=i;
						numberOfTranscriptClusters++;
					}
				}
				if(numberOfTranscriptClusters < 1){
					for(int i=0; i < transcriptClusterArray.length; i++){
						columns = transcriptClusterArray[i].split("\t");
						if(columns[4].equals("ambiguous")){
							transcriptClusterArrayOrder[numberOfTranscriptClusters]=i;
							numberOfTranscriptClusters++;
						}
					}
					for(int i=0; i < transcriptClusterArray.length; i++){
						columns = transcriptClusterArray[i].split("\t");
						if(columns[4].equals("free")){
							transcriptClusterArrayOrder[numberOfTranscriptClusters]=i;
							numberOfTranscriptClusters++;
						}
					}
				}
			}
            // Populate the variable geneChromosome with the chromosome in the first line
			// The chromosome should always be the same for every line in this file
			String geneChromosome = "Y";			
            columns = transcriptClusterArray[0].split("\t");
            geneChromosome = columns[1];
			if(geneChromosome.toLowerCase().startsWith("chr")){
				geneChromosome.substring(3);
			}
            log.debug(" geneChromosome "+geneChromosome);
            String speciesGeneChromosome = species.toLowerCase() + geneChromosome;
            
			//
			// Create chromosomeNameArray and chromosomeSelectedArray 
			// These depend on the species
			//
			
			int numberOfChromosomes;
			String[] chromosomeNameArray = new String[25];

			String[] chromosomeDisplayArray = new String[25];
			String doubleQuote = "\"";
			String isSelectedText = " selected="+doubleQuote+"true"+doubleQuote;
			String isNotSelectedText = " ";
			String chromosomeSelected = isNotSelectedText;

			if(species.equals("Mm")){
				numberOfChromosomes = 20;
				for(int i=0;i<numberOfChromosomes-1;i++){
					chromosomeNameArray[i]="mm"+Integer.toString(i+1);
					chromosomeDisplayArray[i]="Chr "+Integer.toString(i+1);
				}
				chromosomeNameArray[numberOfChromosomes-1] = "mmX";
				chromosomeDisplayArray[numberOfChromosomes-1]="Chr X";
			}
			else{
				numberOfChromosomes = 21;
				// assume if not mouse that it's rat
				for(int i=0;i<numberOfChromosomes-1;i++){
					chromosomeNameArray[i]="rn"+Integer.toString(i+1);
					chromosomeDisplayArray[i]="Chr "+Integer.toString(i+1);
				}
				chromosomeNameArray[numberOfChromosomes-1] = "rnX";
				chromosomeDisplayArray[numberOfChromosomes-1]="Chr X";
			}
			
			//
			// Create tissueNameArray and tissueSelectedArray
			// These are only defined for Rat
			//
			int numberOfTissues;
			String[] tissueNameArray = new String[4];

			String[] tissueDisplayArray = new String[4];

			String tissueSelected = isNotSelectedText;

			if(species.equals("Mm")){
				numberOfTissues = 1;
				tissueNameArray[0]="Brain";
				tissueDisplayArray[0]="Whole Brain";
			}
			else{
                            
                            if(source.equals("seq")){
                                numberOfTissues = 2;
				// assume if not mouse that it's rat
				tissueNameArray[0]="Brain";
				tissueDisplayArray[0]="Whole Brain";
				tissueNameArray[1]="Liver";
				tissueDisplayArray[1]="Liver";
                            }else{
				numberOfTissues = 4;
				// assume if not mouse that it's rat
				tissueNameArray[0]="Brain";
				tissueDisplayArray[0]="Whole Brain";
				tissueNameArray[1]="Heart";
				tissueDisplayArray[1]="Heart";
				tissueNameArray[2]="Liver";
				tissueDisplayArray[2]="Liver";
				tissueNameArray[3]="BAT";
				tissueDisplayArray[3]="Brown Adipose";
                            }
			}	
			
		
    %>
    
    
	<div style="text-align:center;">
    <%if(fileError){%>
            	
            </tbody>
			</table>
			<div style="display:block; color:#FF0000;">There was an error retrieving transcripts for <%=geneSymbolinternal%>.  Try refreshing the page.  The website administrator has been informed of the error. </div>
    <%}else if(transcriptError==null){ // check before adding the transcript cluster id to the form.  If there is an error, end the form here.%>
            </tbody>
			</table>
			<div style="display:block; color:#FF0000;">There was an error retrieving transcripts for <%=geneSymbolinternal%>.  The website administrator has been informed.</div>
    <%}else if(transcriptError){ // check before adding the transcript cluster id to the form.  If there is an error, end the form here.%>
            </tbody>
			</table>
			<div style="display:block; color:#FF0000;">There are no available transcript cluster IDs for <%=geneSymbolinternal%>.  Please choose a different gene to view eQTL.</div>
		<%} else{ // go ahead and make the rest of the form for entering options%>
                    <div style="font-size:18px; font-weight:bold; background-color:#47c647; color:#FFFFFF;width:100%;text-align:left;">
                        <span class="trigger less triggerEC" id="circosOption1" name="circosOption" >eQTL Image Options</span>
                        <span class="eQTLtooltip" title="The controls in this section allow you to change the chromosomes and tissues included in the image as well as the P-value threshold.  If you can't see them click on the + icon.  Once you make changes click on the Click to Run Circos button."><img src="<%=imagesDir%>icons/info.gif"></span>
                    </div>
      	<table id="circosOptTbl" name="items" class="list_base" cellpadding="0" cellspacing="3" style="width:100%;text-align:left;" >
        <tbody id="circosOption">
 		
		<tr>
                    <TD><strong>Data Source:</strong><%
				selectName = "sourceCB";
				
                                selectedOption =source;
				onChange = "changeSource()";
				style = "";
				optionHash = new LinkedHashMap();
                        	optionHash.put("seq", "RNA-Seq");
                        	optionHash.put("array", "Microarrays");
				%><%@ include file="/web/common/selectBox.jsp" %>
                    </td>
			<td style="text-align:center;">
				<strong>P-value Threshold for Highlighting:</strong> 
				<span class="eQTLtooltip" title="Loci with p-values below the chosen threshold are highlighted on the Circos plot in yellow; a line connects the significant loci with the physical location of the gene. All p-values are displayed on the Circos graphic as the negative log base 10 of the p-value."><img src="<%=imagesDir%>icons/info.gif"></span>	
			
				<%
				selectName = "cutoffValue";
				if(selectedCutoffValue!=null){
					selectedOption = selectedCutoffValue;
				}
				else{
					selectedOption = "2.0";					
				}
				onChange = "";
				style = "";
				optionHash = new LinkedHashMap();
                        	optionHash.put("1.0", "0.10");
                        	optionHash.put("2.0", "0.01");
                        	optionHash.put("3.0", "0.001");
                        	optionHash.put("4.0", "0.0001");
                        	optionHash.put("5.0", "0.00001");
				%>
				<%@ include file="/web/common/selectBox.jsp" %>
            </td>
		<%if(source.equals("seq")){%>
                <td style="text-align:center;">
                    <input type="hidden" id="transcriptClusterID" name="transcriptClusterID" value=<%=id%> />
                </td>
                <%}else{%>
                
                    <td style="text-align:center;">
                               <strong>Transcript Cluster ID:</strong>
                                <span class="eQTLtooltip" title="On the Affymetrix Exon Array, gene level expression summaries are labeled as transcript clusters.  
    Each gene may have more than one transcript cluster associated with it, due to differences in annotation among databases and therefore, differences in which individual exons (probe sets) are included in the transcript cluster.  <BR><BR>
    Transcript clusters given the designation of &ldquo;core&rdquo; are based on well-curated annotation on the gene.  
    &ldquo;Extended&rdquo; and &ldquo;full&rdquo; transcript clusters are based on gene properties that are less thoroughly curated and more putative, respectively.  
    Transcript clusters labeled as &ldquo;free&rdquo; or &ldquo;ambiguous&rdquo; have are highly putative for several reasons and therefore are only included in the drop-down menu if no other transcript clusters are available."><img src="<%=imagesDir%>icons/info.gif"></span>
                                                            <!--<div class="inpageHelp" style="display:inline-block;">
                                                            <img id="Help9b" src="/web/images/icons/help.png"/>
                                                            </div>-->

                            <%
                                    // Set up the select box:
                                    selectName = "transcriptClusterID";
                                    if(selectedTranscriptValue!=null){
                                            log.debug(" selected Transcript Value "+selectedTranscriptValue);
                                            selectedOption = selectedTranscriptValue;
                                    }
                                    onChange = "";
                                    style = "";
                                    optionHash = new LinkedHashMap();	
                                    String transcriptClusterString = null;
                                    for (int i=0; i<transcriptClusterArray.length; i++) {

                                            if(transcriptClusterArrayOrder[i] >-1){


                                    columns = transcriptClusterArray[transcriptClusterArrayOrder[i]].split("\t");
                                    transcriptClusterString = transcriptClusterArray[transcriptClusterArrayOrder[i]];
                                                    String tmpGeneSym="";
                                                    if(columns.length>5){
                                                            tmpGeneSym=" ("+columns[5]+")";
                                                    }
                                    optionHash.put(transcriptClusterString,columns[0]+ " " + columns[4] +tmpGeneSym );
                            }
                                    }
                                    //log.debug(" optionHash for Transcript Cluster ID: "+optionHash);

                            %>
                            <%@ include file="/web/common/selectBox.jsp" %>
                </td>
            <%}%>
					
		</tr>

		<input type="hidden" id="hiddenGeneCentricPath" name="hiddenGeneCentricPath" value=<%=geneCentricPath%> />
		<input type="hidden" id="hiddenGeneSymbol" name="hiddenGeneSymbol" value=<%=geneSymbolinternal%> />

		
		
		

		
		<TR class="allowChromSelection" >
                                       <%if(myOrganism.equals("Rn")){%>
                                            <TD colspan="2" style="text-align:left; width:50%;">
                                                <table style="width:100%;">
                                                    <tbody>
                                                        <tr>
                                                            <td style="text-align:center;">
                                                                <strong>Tissues: Include at least one tissue.</strong>
                                                                <span class="eQTLtooltip" title="Select tissues to be displayed in Circos plot by using arrows to move tissues to the box on the right.  
Moving tissues to the box on the left will eliminate them from the Circos plot.  
At least one tissue MUST be included in the Circos plot."><img src="<%=imagesDir%>icons/info.gif"></span>
                                                            </td>
                                                        </tr>
                                                        <TR>
                                                            <td style="text-align:center;">
                                                                <strong>Excluded</strong><%=tenSpaces%><%=twentyFiveSpaces%><%=twentySpaces%><strong>Included</strong>
                                                            </td>
                                                        </TR>
                                                        <tr>
                                                            <td>
                                                                
                                                                <select name="tissuesMS" id="tissuesMS" class="genemultiselect" size="6" multiple="true">
                                                                
                                                                    <% 
                                                                    
                                                                    for(int i = 0; i < numberOfTissues; i ++){
                                                                        tissueSelected=isNotSelectedText;
                                                                        if(selectedTissues != null){
                                                                            for(int j=0; j< selectedTissues.length ;j++){
                                                                                if(selectedTissues[j].equals(tissueNameArray[i])){
                                                                                    tissueSelected=isSelectedText;
                                                                                }
                                                                            }
                                                                        }
                                                
                                                
                                                                    %>
                                                                    
                                                                        <option value="<%=tissueNameArray[i]%>" selected><%=tissuesList1[i]%></option>
                                                                    
                                                                    <%} // end of for loop
                                                                    %>
                                                
                                                                </select>
                                                
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                             </TD>
                                        <%} // end of checking species is Rn %>
                                        <TD style="text-align:left; width:50%;">
                                            <table style="width:100%;">
                                                <tbody>
                                                    <tr>
                                                        <td style="text-align:center;">
                                                            <strong>Chromosomes: (<%=chromosome%> must be included)</strong>
                                                           <span class="eQTLtooltip" title="Select chromosomes to be displayed in Circos plot by using arrows to move chromosomes to the box on the right.
Moving chromosomes to the box on the left will eliminate them from the Circos plot.  
The chromosome where the gene is physically located MUST be included in the Circos plot."><img src="<%=imagesDir%>icons/info.gif"></span>
                                                        </td>
                                                        
                                                    </tr>
                                                    <tr>
                                                        <td style="text-align:center;">
                                                            <strong>Excluded</strong><%=tenSpaces%><%=twentyFiveSpaces%><%=twentySpaces%><strong>Included</strong>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            
                                                            <select name="chromosomesMS" id="chromosomesMS" class="genemultiselect" size="6" multiple="true">
                                                            
                                                                <% 
                                                                
                                                                for(int i = 0; i < numberOfChromosomes; i ++){
                                                                    chromosomeSelected=isNotSelectedText;
                                                                    if(chromosomeDisplayArray[i].substring(4).equals(chromosome)){
                                                                        chromosomeSelected=isSelectedText;
                                                                    }
                                                                    else {
                                                                        if(selectedChromosomes != null){
                                                                            for(int j=0; j< selectedChromosomes.length ;j++){
                                                                                //log.debug(" selectedChromosomes element "+selectedChromosomes[j]+" "+chromosomeNameArray[i]);
                                                                                if(selectedChromosomes[j].equals(chromosomeNameArray[i])){
                                                                                    chromosomeSelected=isSelectedText;
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                            
                                            
                                                                %>
                                                                
                                                                    <option value="<%=chromosomeNameArray[i]%>" selected><%=chromosomeDisplayArray[i]%></option>
                                                                
                                                                <%} // end of for loop
                                                                %>
                                            
                                                            </select>
                                            
                                                        </td>
                                                    </tr>	
                                                  </tbody>
                                              </table>		
                                         </TD>
          </TR>		
		<tr>	
                                
				<td colspan="3" style="text-align:center;">
                                    <INPUT TYPE="submit" NAME="action" id="clickToRunCircos" Value="Click to run Circos" onClick="return runCircos()" style="display:inline-block;">
                                    <div style="float: right;display:inline-block"><a href="http://genome.cshlp.org/content/early/2009/06/15/gr.092759.109.abstract" target="_blank" style="text-decoration: none">Circos: an Information Aesthetic for Comparative Genomics.</a></div>
				</td>
				
					
				
		</tr>
        </tbody>
      	</table>


<BR>
<BR /><BR /><BR />
	
	

<%
} // end of if(transcriptError)
%>


<div id="wait2" align="center" style="position:relative;top:-50px;"><img src="<%=imagesDir%>wait.gif" alt="Working..." text-align="center" >
	<BR />Preparing to run Circos...</div>


	<script>
			document.getElementById("wait2").style.display = 'none';
	</script>
        <div style="position:relative;top:-50px;width:100%;"><h2><span id="typeLabel">RNA-Seq</span> Based Gene Level eQTLs</h2></div>	
<div id="forIframe" style="position:relative;top:-50px;width:100%;">
</div>
	

</div>




<script>
	
	$(document).ready(function() {	
		
		$(".genemultiselect").twosidedmultiselect();
        var selectedChromosomes = $("#chromosomes")[0].options;
		//document.getElementById("circosError1").style.display = 'none';
		/*$(".triggerEQTL").click(function(){
		var baseName = $(this).attr("name");
		$(this).toggleClass("less");
        expandCollapse(baseName);      
	});*/
		
		$('.eQTLtooltip').tooltipster({
                        position: 'top-right',
                        maxWidth: 350,
                        offsetX: 8,
                        offsetY: 5,
                        contentAsHTML:true,
                        //arrow: false,
                        interactive: true,
                        interactiveTolerance: 350
                });

		if($('#transcriptClusterID').length===1){
                    runCircos();
		}else if(source==="seq"){
                    runCircos();
                }
		$('#circosIFrame').attr('width',$(window).width()-50);
		$(window).resize(function (){
			$('#circosIFrame').attr('width',$(window).width()-50);
		});
	});

</script>


 
