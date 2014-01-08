<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

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


 
