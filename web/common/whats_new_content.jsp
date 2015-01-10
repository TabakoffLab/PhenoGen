<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<style>
span.control{
		background:#DCDCDC;
		margin-left:2px;
		margin-right:2px;
		height:24px;
		/*padding:2px;*/
		display:inline-block;
		width:35px;
		border-style:solid;
		border-width:1px;
		border-color:#777777;
		-webkit-border-radius: 5px;
		-khtml-border-radius: 5px;
		-moz-border-radius: 5px;
		border-radius: 5px;
	}
	span.control:hover{
		background:#989898;
	}
</style>
<div class="whats_new version">
    <p><h3>Version: v2.14.0</h3><BR /> Updated:1/11/2015</p></div>
                                 <ul>
                                    <li><span class="highlight-dark">Weighted Gene Co-expression Network Analysis(WGCNA) Results</span>.
                                                    <ul>
                                                        <li>Available for both Mouse and Rat Brain.</li>
                                                        <li>Module View:
                                                            <ul>
                                                                <li>Transcripts both Ensembl Annotated and RNA-Seq reconstructed</li>
                                                                <li>Transcripts connectedness showing positive and negative correlation of transcript expression.</li>
                                                                <li>View graphic form and CSV exportable table form.</li>
                                                            </ul>
                                                        </li>
                                                        <li>eQTL Module View:
                                                            <ul>
                                                                <li>View CIRCOS plot:
                                                                    <ul>
                                                                        <li>Genome with regions below the selected P-value cutoff highlighted.</li>
                                                                        <li>Customizable with include/exclude chromosomes and adjust P-value cutoff.</li>
                                                                        <li>View graphic form and CSV exportable table form.</li>
                                                                    </ul>
                                                                </li>
                                                                <li>CSV exportable table form with SNP name/location and P-value.</li>
                                                            </ul>
                                                        </li>
                                                    </ul>
                                    </li>
                                    <li><span class="highlight-dark">Where to find WGCNA Data</span>
                                        <UL>
                                        <li> <span class="highlight-dark">Genome/Transcriptome Data Browser</span> - Modules can be viewed for all genes in a region of interest or for a single gene.</li>
                                        <li> <span class="highlight-dark">Gene Lists</span> - Modules can be viewed for all genes in the gene list along with a summary of modules containing the most genes from the list.</li>
                                        </ul>
                                    </li>
                                </ul>
				
    <hr/>
<div class="whats_new version">        
    <p><h3>Version: v2.13.0</h3><BR /> Updated:9/27/2014</p></div>
				<ul>
					<li> <span class="highlight-dark">Genome/Transcriptome Data Browser</span>
                    	<ul>
                        	<li><span class="highlight-dark">Views have been completely updated</span> to allow us to offer multiple views that change based on the species viewed, and now you can <span class="highlight-dark">build your own view</span>.
                            	<ul>
                                	<li>Easily view different types of data in the same region by switching between views with only 3 clicks.</li>
                                    <li>Build your own view by from a blank view or copy a view and modify it.  You can control the included tracks, track settings, and track order.</li>
                                    <li>Bring in your own data and include custom tracks in views.  Now supporting Bed, BedGraph, BigBed, and BigWig files.</li>
                                    <li>Save views/tracks to the server for portability.(See below for more information)</li>
                                </ul>
                            </li>
                            <li><span class="highlight-dark">Updated Data:</span>
                            	<ul>
                                <li><span class="highlight-dark">Mouse Brain RNA-Seq</span> - We've added a transcriptome reconstruction, splice junctions, and stranded RNA-Seq read depth tracks for the parental strains of the LXS panel(ILS/ISS).</li>
                                <li><span class="highlight-dark">Rat Heart RNA-Seq</span> - Splice juctions, stranded RNA-Seq read depth tracks are available now for the parental strains of the HXB/BXH panel(BN-Lx/SHR).  The transcriptome reconstruction will be available later.</li>
                                <li><span class="highlight-dark">Rat Brain/Liver RNA-Seq</span> -Updated splice juctions and stranded(Liver) or polyA+/total(Brain)  RNA-Seq read depth tracks are available now.  Updated transcriptome reconstructions will be available later.</li>
                                </li>
                                </ul>
                            </li>
                            <li><span class="highlight-dark">New custom track file support:</span>
                            	<ul>
                                	<li><span class="highlight-dark">bedGraph</span> - uploaded 20MB size limit</li>
                                    <li><span class="highlight-dark">bigBed</span> - remotely hosted, no size limit</li>
                                    <li><span class="highlight-dark">bigWig</span> - remotely hosted, no size limit</li>
                                    <li>bed - we still support bed files, uploaded, 20MB size limit</li>
                                </ul>
                            </li>
                            <li><span class="highlight-dark">Custom View/Tracks will save to the server</span> if you login to the site before creating them.  If you have logged into the site any views or tracks will save to the server so you can view them on any device that you login from and can reduce the risk of loosing them.</li>
                            <li><span class="highlight-dark">Don't want to register or login, don't worry everything will still work</span>, custom tracks and views are saved locally via one of two mechanisms, either local storage or cookies in older browsers.  If you clear these you will loose your custom views or tracks.</li>
                            
                    	</ul>
                	</li>         
				</ul>
				<hr/>
<div class="whats_new version"><p><h3>Version: v2.12.3</h3><BR /> Updated:7/17/2014</p></div>
				<ul>
					<li> <span class="highlight-dark">Genome/Transcriptome Data Browser</span>
                    	<ul>
                        	<li>Rearranged Ensembl and Rat Brain Transcriptome Reconstruction Tracks into a seperate track for each source.
                            	<ul>
                                	<li>Brain transcripts were removed from Ensembl tracks and added to their own track to mirror the additional tissue tracks to be added in the next few months.</li>
                                    <li>Region summary tables now include Liver transcripts</li>
                                </ul>
                            </li>
                            <li>Improved the feature selection
                            	<ul>
                                	<li>Changed how sections are displayed and now hide the region section completely when a feature is selected</li>
                                    <li>Now the selected area is highlighted in the top graphic.</li>
                                </ul>
                            </li>
                            <li>Improved navigation by adding a back button to step back through zooming and panning allowing better control than just resetting to the original region when the page loaded.</li>
                            <li>Improved tool tip images for RNA-Seq read depth count tracks- the image will now refresh with higher resolution count data if you pause for a fraction of a second.
                            </li>
                            
                    	</ul>
                	</li>         
				</ul>
				<hr/>
<div class="whats_new version"><p><h3>Version: v2.12.2</h3><BR /> Updated:6/27/2014</p></div>
				<ul>
					<li> <span class="highlight-dark">Gene List Analysis</span>
                    	<ul>
                        	<li>Incorporated multiMiR(an R package available <a href="http://multimir.ucdenver.edu/" target="_blank">here</a>) to summarize validated and predicted targets of miRNA from 14 databases.
                            	<ul>
                                	<li>After selecting a mouse Gene List (support for Rat will be available in the future), you will see a new miRNA Targeting Gene(multiMiR) tab.</li>
                                    <li>You may run a new analysis</li>
                                    <li>Select a previous analysis:
                                    <UL>
                                    	<li>
                                        	View:
                                            <UL>
                                                <li>a small table sumarizing the number of validated/predicted genes targeted.</li>
                                                <li>a larger table with further detail about all the validated/predicted genes and databases.</li>
                                            </UL>
                                        </li>
                                    	<li>Select an miRNA to view details:
                                            <UL>
                                                <li>view a list of all predicted database hits and scores</li>
                                                <li>view a list of all validated database hits with experiment details and pubmed reference</li>
                                            </UL>
                                        </li>
                                    </li>
                                    </UL>
                                    <li>Future additions:
                                    	<UL>
                                        	<li>run multiMiR with disease/drug targeting</li>
                                            <li>in the browser run multiMiR on genes or miRNA in a region of interest</li>
                                        </UL>
                                    </li>
                                </ul>
                            </li>
                    	</ul>
                	</li>         
				</ul>
				<hr/>
<div class="whats_new version"><p><h3>Version: v2.12</h3><BR /> Updated:6/11/2014</p></div>
				<ul>
					<li> <span class="highlight-dark">Genome/Transcriptome Data Browser:</span>
                    	<ul>
                        	<li>Incorporated multiMiR(an R package available <a href="http://multimir.ucdenver.edu/" target="_blank">here</a>) to summarize validated and predicted targets of miRNA from 14 databases.
                            	<ul>
                                	<li>To use start with a mouse gene (rat will be available in the future) in the Genome/Transcriptome Browser.  You will see a new miRNA Targeting Gene(multiMiR) tab.</li>
                                    <li>View a list of validated and predicted miRNAs targeting the selected gene.</li>
                                    <li>Select a miRNA:
                                    	<UL>
                                        	<li>view a list of all predicted database hits and scores</li>
                                            <li>view a list of all validated database hits with experiment details and pubmed reference</li>
                                        	<li>view a list of all genes targeted by that miRNA</li>
                                        </UL>
                                    </li>
                                    <li>Future additions:
                                    	<UL>
                                        	<li>run multiMiR on a Gene List</li>
                                            <li>run multiMiR on genes or miRNA in a region of interest</li>
                                        	<li>run multiMiR with disease/drug targeting</li>
                                        </UL>
                                    </li>
                                </ul>
                            </li>
                            
                        	<li style="list-style-type:none;"><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp" class="button" style="width:140px;">Try it out</a>
                    	</ul>
                	</li>         
				</ul>
				<hr/>
<div class="whats_new version"><p><h3>Version: v2.11</h3><BR /> Updated:5/11/2014</p></div>
				<ul>
					<li> <span class="highlight-dark">Genome/Transcriptome Data Browser:</span>
                    	<ul>
                        	<li>Liver RNA-Seq Data
                            	<ul>
                                	<li>Added Liver RNA-Seq transcriptome reconstruction track (BN-Lx only for now - SHR will be added soon)</li>
                                    <li>Added Liver RNA-Seq splice junction track (BN-Lx only for now - SHR will be added soon)</li>
                                    <li>Added Liver RNA-Seq stranded read depth count track (BN-Lx only for now - SHR will be added soon)</li>
                                </ul>
                            </li>
                            <li>PolyA sites
                            	<ul><li style="list-style-type:none;">
                                	A new track indicating polyadenylation sites.  For now only known sites are included, but soon predicted sites will be included.
                                </li></ul>
                            </li>
                            <li>Other changes since v2.10:
                            	<ul>
                                	<li> Previews of many features in the information windows that open when you hover over a feature.</li>
                                    <li> Saving an browser image directly to your computer is now possible look for the <span class="saveImage control" style="display: inline-block; cursor: pointer;"><img src="/web/images/icons/savePic_dark.png" cursor="pointer"></span> icon.</li>	
                                    <li> Improved navigation.  This tool bar <div class="defaultMouse" style="display:inline-block;"><span style="height: 24px; display: inline-block; cursor: pointer; background-color: rgb(220, 220, 220); background-position: initial initial; background-repeat: initial initial;"><img class="mouseOpt dragzoom" src="/web/images/icons/dragzoom_dark.png" pointer-events="all"></span><span id="pan0" style="height: 24px; display: inline-block; cursor: pointer; background-color: rgb(152, 152, 152); background-position: initial initial; background-repeat: initial initial;"><img class="mouseOpt pan" src="/web/images/icons/pan_white.png" pointer-events="all"></span><span id="reorder0" style="height: 24px; display: inline-block; cursor: pointer; background-color: rgb(220, 220, 220); background-position: initial initial; background-repeat: initial initial;"><img class="mouseOpt pan" src="/web/images/icons/reorder_dark.png" pointer-events="all"></span></div> now allows you to control the default mouse function when you click making it easier to move along the genome, zoom by selecting a region, and reorder tracks without moving left or right.</li>
                                    <li> Support for small custom tracks.  You may upload small <20MB custom track files and display them along with changing the display type and coloring.</li>
                                    <li> Added Rat/Mouse RefSeq tracks.</li>
                                    <li> The browser adjusts to the size of the window.  Before you were limited to 1000pixel width, now it will redraw to fit any width window including spanning monitors.</li>
                                    <li> Transcripts from Ensembl/RefSeq now indicate any annotated untranslated region.</li>
                                    <li> Detailed probe set view had a bug on Mac OS X, now that is fixed in the Oracle runtime environment.  If you update Java this bug will be corrected.</li>
                                    <li> In large regions transcripts are grouped into genes.  In smaller regions transcripts are drawn separately, but the user can force drawing transcripts if desired.</li>
                                    <li> View genome sequence and 3 possible amino acid sequences when zoomed in below 3000bp.</li>
                                </ul>
                            </li>
                        	<li style="list-style-type:none;"><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp" class="button" style="width:140px;">Try it out</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="<%=contextRoot%>web/demo/largerDemo.jsp?demoPath=web/demo/BrowserNavDemo" class="button" style="width:140px;" target="_blank">View Demonstration</a></li>
                    	</ul>
                	</li>         
				</ul>
				<hr/>

<div class="whats_new version"><p><h3>Version: v2.10</h3><BR /> Updated:12/1/2013</p></div>
				<ul>
                <li>
					<span class="highlight-dark">New Mouse Genome:</span> Our public data has been updated to Mm10.  Probes were aligned to the mouse genome version 10 and then new masks were generated.  The Public LXS data uses a strain specific mask with only Parental ILS and ISS SNPs included. All of three versions of the dataset were renormalized to use the new masks.  Previous results are still available, but new analyses will use the new versions of the dataset. 
                </li><BR /> 
				<li> 
                    <span class="highlight-dark">Detailed Transcription Information renamed to Genome/Transcriptome Data Browser</span>
                    <ul >
                    	<li>The page is now centered around a new D3/SVG graphic that makes the page more like a genome browser:
                        	<ul style="padding-left:30px;">
                                        <li><div class="clicker" name="branch7">The graphics are interactive &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch7">
                                        	You can easily zoom and move along the genome to browse features.  You can select a feature to pull up a detailed another detailed interactive image of that feature or a report summarizing the data available for the feature.
                                        </span>
                                        <li><div  class="clicker" name="branch8">Three different customizable views&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch8">
                                        	You can view Genomic Features<BR />
                                            	<ul>
                                                </ul>
                                            You can view Transcriptome Features
                                            	<ul>
                                                </ul>
                                            You can view a combination of both types of features.<BR />
                                            With all views the tracks displayed are saved so you can move around the genome viewing with the same view or you can flip between two or three views looking at different tracks.
                                        </span>
                                        
                                     </ul>
                        </li>
                        <li>The Gene and Region views have been unified to provide a similar interface whether you enter a gene or browse a region.</li>
                        <li>New Demos:
                        	<UL>
                            	<li>A new short demonstration of navigating using the Genome/Transcriptome Data Browser</li>
                                <li>A new version of the previous demonstration showing how to use the Genome/Trascriptome Data Browser to look at regions of interest</li>
                            </UL>
                        </li>
                        <li style="list-style-type:none;"><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp" class="button" style="width:140px;">Try it out</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="<%=contextRoot%>web/demo/largerDemo.jsp?demoPath=web/demo/BrowserNavDemo" class="button" style="width:140px;" target="_blank">View Demonstration</a></li>
                    </ul>
                </li>         
				</ul>


				<hr/>


<div class="whats_new version"><p><h3>Version: v2.9</h3><BR /> Updated:5/21/2013</p></div>
				<ul>
                <li>
					<span class="highlight-dark">New Rat Genome:</span> All of our public data has been updated to Rn5.  Probes were aligned to the rat genome version 5 and then new masks were generated.  All of the datasets were renormalized to use the new masks.  Previous results are still available, but new analyses will use the new versions of the datasets. 
                </li><BR /> 
				<li> 
                    <span class="highlight-dark">Detailed Transcription Information:</span>
                    <ul >
                    	<li>Regions have been updated to include more RNA-Seq data(Rat only):
                        	<ul style="padding-left:30px;">
                                        <li><div class="clicker" name="branch7">UCSC Image allows control of individual tracks  &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch7">
                                        	The image now allows you to turn tracks off and on individually as well as gives you control of the density of the track.
                                        </span>
                                        <li><div  class="clicker" name="branch8">Several New Image Tracks(Rat only)&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch8">
                                        	There are new tracks available for the Rat:
                                            	<ul>
                                                	<li>Small RNAs from Brain RNA-Seq.</li>
                                                    <li>Long Non-Coding RNAs from Brain RNA-Seq</li>
                                                    <li>SNP/Indels- from DNA Sequencing of the BN-Lx and SHR strains.</li>
                                                    <li>Helicos Read Counts - Read Counts from the Helicos Brain RNA-Seq</li>
                                                </ul>
                                        </span>
                                        <li><div  class="clicker" name="branch9">Features located in region table includes additional information &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch9">
                                        	The table includes the following changes:
                                            <ol type="1">
                                            	<li>IDs used in the image are listed in the table</li>
                                                <li>Columns were added to allow the user to sort the table based on tracks in the image.</li>
                                                <li>Rows in the table are color coded to match the track in the image.</li>
                                                <li>SNP/indel counts within an exon for each gene (rat only) were added.</li>
                                                <li>Small RNA information such as read sequence and total read counts were added (rat only).</li>
                                                <li>Links have been added for NCBI, UniProt, RGD, MGI, and Allen Brain Atlas for each gene listed in the table.</li>
                                            </ol>
                                       </span>
                                        
                                     </ul>
                        </li>
                        <li>Gene views have been updated to include the following:
                        	<ul style="padding-left:30px;">
                            			<li><div class="clicker" name="branch10">The list of features in a region is now displayed for the region of a gene. &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch10">
                                        	All features within the genomic region of the gene will be listed in the table.  This includes long non-coding RNAs and small RNA.  
                                        </span>
                                        <li><div class="clicker" name="branch11">UCSC Image allows control of individual tracks  &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch11">
                                        	The image now allows you to turn tracks off and on individually as well as gives you control of the density of the track.
                                        </span>
                                        <li><div  class="clicker" name="branch12">New Several Image Tracks(Rat only)&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch12">
                                        	There are new tracks available for the Rat:
                                            	<ul>
                                                	<li>Small RNAs from Brain RNA-Seq.</li>
                                                    <li>Long Non-Coding RNAs from Brain RNA-Seq</li>
                                                    <li>SNP/Indels- from DNA Sequencing of the BN-Lx and SHR strains.</li>
                                                    <li>Helicos Read Counts - Read Counts from the Helicos Brain RNA-Seq</li>
                                                </ul>
                                        </span>
                                        <li><div  class="clicker" name="branch13">eQTLs for a gene are displayed on the same page&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch13">
                                        	Instead of opening in a seperate page you can now navigate between features found in the gene region, eQTLs and Detailed Affy Probeset information using tabs on the page.
                                        </span>
                                     </ul>
                        </li>
                        <li style="list-style-type:none;"><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp" class="button" style="width:140px;">Try it out</a></li>
                    </ul>
                </li><BR />
                
                <li>
					<span class="highlight-dark">Rat Parental Strian DNA Sequence Available:</span> DNA sequence information from parental strain (BN-Lx and SHR) of the HXB/BXH recombinant inbred panel is available:  The strain-specific genome of parental strains of the Public Rat Array/RNA-Seq datasets is available for download and the SNPs/indels can be displayed in the image on the Detailed Transcriptome Information page. <a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=sysBioDir%>resources.jsp" class="button" style="width:180px;">View in downloads</a>
                </li><BR />           
				</ul>


				<hr/>

<div class="whats_new version"><p><h3>Version: v2.8</h3><BR /> Updated:12/16/2012</p></div>

				<ul>
				<li> 
					<span class="highlight-dark">Detailed Transcription Information:</span>
                    <ul >
                    	<li>Now you can view regions too(instead of entering a gene symbol, enter a region chr1:1-50,000)
                        	<ul style="padding-left:50px;">
                                        <li><div class="clicker" name="branch1">View UCSC Image of region  &nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch1">
                                        	The image shows genes in the region and bQTLs.  Optionally you may view additional information such as Ensembl transcripts and RNA-Seq transcripts(Rat only), UCSC/Affymetrix exon expression data, and homologus human chromosome regions and proteins.
                                        </span>
                                        <li><div  class="clicker" name="branch2">For Rat RNA-Seq transcripts from Brain are included<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch2">
                                        	RNA-Seq data(Available in the downloads section) was used to create a reconstructed transcriptome.  Those transcripts can be displayed and the number of transcripts found can be compared to the Ensembl transcript annotations.  When viewing Detailed Transcription Information at the gene level more information is available.
                                        </span>
                                        <li><div  class="clicker" name="branch3">View Heritability and Detection Above Background across tissues availble for genes in the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch3">
                                        	We have exon array data for 2 recombinant inbred panels and various tissues (ILSXISS Mice(Whole Brain) and HXB/BXH Rats(Whole Brain, Heart, Liver, Brown Adipose).  This data is summarized for each region to include the # and avgerage heritability of probesets with a significant heritability and # and average percentage of samples where probesets were detected above background.  These are summarized for each gene in each tissue.                                         </span>
                                        <li><div  class="clicker" name="branch4">View eQTLs for genes in the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch4">
                                        	For genes in the region eQTL with the minimum P-value and its location is summarized across tissues.  All locations and tissues can be summarized in a circos plot.
                                        </span>
                                        <li><div  class="clicker" name="branch5">View bQTLs overlapping the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch5">
                                            All public bQTLs from MGI and RGD with a defined location that overlaps the current region are displayed in summary table that also links to the associated databases.
                                        </span>
                                        <li><div  class="clicker" name="branch6">View genes controlled from the region&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"></li>
                                        <span class="branch" id="branch6">
                                        	eQTLs are calculated for the recombinant inbred panels at the Gene level(Affy Exon Transcript Clusters having a core annotation)).  This is used to return a list of genes that have a core transcript cluster and an eQTL that overlaps the region.
                                        </span>
                                     </ul>
                        </li>
                        
                        <li>Translate a region of interest from Human/Mouse/Rat to Mouse/Rat to view PhenoGen data.</li>
                        <li style="list-style-type:none;"><a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=contextRoot%>gene.jsp" class="button" style="width:140px;">Try it out</a></li>
                        
                    </ul>
                </li><BR />
				<li>
					<span class="highlight-dark">Demos:</span> View the video demo of our Detailed Transcription Information features, with more demos coming soon. <a href="<%=contextRoot%>web/demo/largerDemo.jsp?demoPath=web/demo/detailed_transcript_fullv3" class="button" style="width:100px;" target="_blank" >View Demo</a>
                </li><BR />
                <li>
					<span class="highlight-dark">MEME Updated to v4.9:</span> MEME v4.9 is now available.  Old results are still avialable, but new analysis will use 4.9 which will also have better graphics display and will link to the main meme server for further analysis.  Available in <a href="<%=accessDir%>checkLogin.jsp?url=<%=geneListsDir%>listGeneLists.jsp" class="button" style="width:180px;">Gene List Analysis</a>  
                </li><BR />
                <li>
					<span class="highlight-dark">Human Genotyping Data Available:</span> Affymetrix Genome-Wide Human SNP Array 6.0 data for alcohol dependent subjects receiving outpatient treatment at the Medical University of Vienna (Austria). <a href="<%=accessDir%>createAnnonymousSession.jsp?url=<%=sysBioDir%>resources.jsp" class="button" style="width:180px;">View in downloads</a>
                </li><BR />           
				</ul>

				<hr/>
            			
                        
<div class="whats_new version"><p><h3>Version: v2.7</h3><BR /> Updated:9/1/2012</p></div>

				<ul>
				<li> 
					<span class="highlight-dark">Detailed Transcription Information:</span>
                    <ul >
                    	<li><div>View Parental Strain Differential Expression</li>
                        
                        <li><div  >View Parental Strain(Rat) Transcriptome Reconstruction</li>
                        
                        <li><div  >View Panel Heritability/Detection Above Background accross tissues</li>
                        
                        <li><div >View Panel Expression accross tissues</li>
                        
                        <li><div >View Exon Correlation Tool</li>
                        	
                        	<ul	 style="padding-left:50px;">
                                <li>Identify exons within a gene that are not expressed</li>
                                <li>Identify exons within a gene with low heritability</li>
                                <li>Use correlation patterns among exons to identify expressed isoforms.</li>
                            </ul>
                            </span>
                        <li><div >View eQTL information</li>
                        
                    </ul>
				<li>
					<span class="highlight-dark">New Menu Navigation:</span> The new Menu system allows users to easily get between functions that previously required clicking through multiple pages.  
				
				<li> 
					<span class="highlight-dark">Download Resources without Logging in:</span> Resources that used to require a login are now available without logging in.
                
				</ul>

				<br/>
                        
<div class="whats_new version"><p><h3>Version: v2.6</h3><BR /> Updated:5/22/2012</p></div>

				<ul>
				<li> 
					<span class="highlight-dark">Exon level analysis tools:</span>Analyze probeset-level data for the public exon arrays.
				<li>
					<span class="highlight-dark">Exon-exon correlation heatmaps:</span> Perform exon-exon correlation within a gene:  	
                    <ol type="a">
                    <li> Select a gene (from a gene list or enter your own). and 
                    <li> Select an exon dataset (from Rats or Mice).
                    <li> Select Brain(Mouse or Rat), Heart(Rat), Liver(Rat), or Brown Adipose tissues(Rat). 
                    <li> View any Ensembl transcript for the gene, or compare two 
                    transcripts side by side.
                    </ol>
				
				<li> 
					<span class="highlight-dark">Download RNA-sequencing:</span>SAM files from three replicates of polyA+ 
                    RNA from whole brain of two rat strains and three replicates of total RNA from whole
                    brain of the same two rat strains can now be downloaded in the Download Resources tab.
                <li> 
					<span class="highlight-dark">Data storage format:</span>A new system for storing data in the database and HDF5 files speeds up normalization, filtering, and statistics.  This is currently implemented 
                    to support analysis on Affymetrix Exon arrays, but future updates will implement the new storage methods for the 
                    remaining array types.
				</ul>

				<br/>


 
