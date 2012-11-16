<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<div class="whats_new version"><p><h3>Version: v2.8</h3><BR /> Updated:12/1/2012</p></div>

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
                        
                    </ul>
				<li>
					<span class="highlight-dark">Demos:</span> View the video demo of our new features, with more demos coming soon.
                </li>                
				</ul>

				<br/>
            			
                        
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


 
