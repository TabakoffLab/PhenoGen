	<%@ include file="/web/common/anon_session_vars.jsp" %>
    <jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<% 
			//
			// Initialize some variables
			//
			String iframeURL = null;
			String svgPdfFile = null;
			String geneSymbolinternal= null;
			String geneCentricPath = null;			
			String ensemblIdentifier = null;
			String transcriptClusterFileName = null;			
			String species = null;
			String longSpecies = null;
			String selectedTranscriptValue = null;
			String transcriptClusterID = null;
			String transcriptClusterChromosome= null;
			String transcriptClusterStart=null;
			String transcriptClusterStop=null;		
			String selectedCutoffValue = null;
			String[] selectedChromosomes = null;
			String[] selectedTissues = null;
			String chromosomeString = null;
			String tissueString = null;
			String[] transcriptClusterArray = null;
			int[] transcriptClusterArrayOrder = null;
			Boolean transcriptError = null;
			Boolean selectedChromosomeError = null;
			Boolean selectedTissueError = null;
			Boolean circosReturnStatus = null;
			String timeStampString = null;

			//
			//Configure Inputs from session variables, unless they are already defined on the page.
			//
			
			LinkedHashMap inputHash = new LinkedHashMap();
			if(request.getParameter("hiddenGeneSymbol")!=null){
				// The top of the form has already been filled in so get information from form
				geneSymbolinternal =(String)request.getParameter("hiddenGeneSymbol");
				geneCentricPath =(String)request.getParameter("geneCentricPath");	
				log.debug("Got geneCentricPath and geneSymbol from form "+ geneSymbolinternal + "  " + geneCentricPath);
			}
			

			inputHash.put("geneSymbol",geneSymbolinternal);
			inputHash.put("geneCentricPath",geneCentricPath);
			Integer tmpIndex = geneCentricPath.substring(1,geneCentricPath.length()-1).lastIndexOf('/');			
			inputHash.put("length",tmpIndex);

			ensemblIdentifier = geneCentricPath.substring(tmpIndex+2,geneCentricPath.length()-1);
			inputHash.put("ensemblIdentifier",ensemblIdentifier);
			inputHash.put("transcriptClusterFileName",geneCentricPath+"tmp_psList_transcript.txt");
			transcriptClusterFileName = geneCentricPath.concat("tmp_psList_transcript.txt");
			
			if(ensemblIdentifier.substring(0,7).equals("ENSRNOG")){
				species="Rn";
				longSpecies = "Rattus norvegicus";
			}
			else if (ensemblIdentifier.substring(0,7).equals("ENSMUSG")){
				species="Mm";
				longSpecies="Mus musculus";
			}
			
			//
			// Read in transcriptClusterID information from file
			// Also get the chromosome that corresponds to the gene symbol
			//

          	transcriptClusterArray = myFileHandler.getFileContents(new File(transcriptClusterFileName));
          	String[] columns;
			log.debug("transcriptClusterArray length = "+transcriptClusterArray.length);
			// If the length of the transcript Cluster Array is 0, return an error.
			if(transcriptClusterArray.length == 0){
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
			
			
	//boolean auto=false;
	//////////////////////////////////////////////////////////////////////////////////
	//
	// Evaluate entries on form	
	//
	//////////////////////////////////////////////////////////////////////////////////
	
	


		// Get information about the transcript cluster

		if(request.getParameter("transcriptClusterID")!=null){
			selectedTranscriptValue = request.getParameter("transcriptClusterID");
			String[] transcriptArray = selectedTranscriptValue.split("\t");
			transcriptClusterID=transcriptArray[0];
			transcriptClusterChromosome = species.toLowerCase() + transcriptArray[1];
			transcriptClusterStart=transcriptArray[2];
			transcriptClusterStop=transcriptArray[3];
			log.debug(" Transcript Cluster ID: "+transcriptClusterID);
			log.debug(" Transcript Cluster Chromosome: "+transcriptClusterChromosome);
			log.debug(" Transcript Cluster Start: "+transcriptClusterStart);
			log.debug(" Transcript Cluster Stop: "+transcriptClusterStop);
		}
		// Get information about the cutoff value
		if(request.getParameter("cutoffValue")!=null){
			selectedCutoffValue = request.getParameter("cutoffValue");
			log.debug(" Selected Cutoff Value " + selectedCutoffValue);
			
		}
		
		// Get information about which tissues to view -- easier for mouse
		
		if(species.equals("Mm")){
			tissueString = "Brain;";
			selectedTissueError = false;
		}
		else{
			// we assume if not mouse that it's rat
			if(request.getParameter("tissues")!=null){			
				String tmpSelectedTissues =request.getParameter("tissues");
				selectedTissues = tmpSelectedTissues.split(";");
				log.debug("Getting selected tissues");
				tissueString = "";
				selectedTissueError = true;
				for(int i=0; i< selectedTissues.length; i++){
					selectedTissueError = false;
					tissueString = tissueString + selectedTissues[i] + ";";
				}
				log.debug(" Selected Tissues: " + tissueString);
				log.debug(" selectedTissueError: " + selectedTissueError);
				// We insist that the tissue string be at least one long
			}
			else{
				//log.debug("could not get selected tissues");
				//log.debug("and we did not previously allow chromosome selection");
				//log.debug("therefore include all tissues");
				// we are not allowing chromosome/tissue selection.  Include all tissues.
				selectedTissues = new String[numberOfTissues];
				selectedTissueError=false;
				tissueString = "";
				for(int i=0; i< numberOfTissues; i++){
					tissueString = tissueString + tissueNameArray[i] + ";";
					selectedTissues[i]=tissueNameArray[i];
				}
			}
		}
		
		
		// Get information about which chromosomes to view

		if(request.getParameter("chromosomes")!=null){			
			String tmpSelectedChromosomes = request.getParameter("chromosomes");
			selectedChromosomes=tmpSelectedChromosomes.split(";");
			log.debug("Getting selected chromosomes");
			chromosomeString = "";
			selectedChromosomeError = true;
			for(int i=0; i< selectedChromosomes.length; i++){
				log.debug("chr: "+selectedChromosomes[i]+"::"+speciesGeneChromosome);
				chromosomeString = chromosomeString + selectedChromosomes[i] + ";";
				if(selectedChromosomes[i].equals(speciesGeneChromosome)){
					selectedChromosomeError=false;
				}
			}
			log.debug(" Selected Chromosomes: " + chromosomeString);
			log.debug(" selectedChromosomeError: " + selectedChromosomeError);
			// We insist that the chromosome string include speciesGeneChromosome 
		}
		else{
			//log.debug("could not get selected chromosomes");
			//log.debug("and we did not previously allow chromosome selection");
			//log.debug("therefore include all chromosomes");
			// we are not allowing chromosome selection.  Include all chromosomes.
			selectedChromosomes = new String[numberOfChromosomes];
			selectedChromosomeError=false;
			chromosomeString = "";
			for(int i=0; i< numberOfChromosomes; i++){
				chromosomeString = chromosomeString + chromosomeNameArray[i] + ";";
				selectedChromosomes[i]=chromosomeNameArray[i];
			}
		}
		
		if((!selectedChromosomeError)&&(!selectedTissueError)){
			//
			// Initialize variables for calling perl scripts (which will call Circos executable)
			//
		
			String perlScriptDirectory = (String)session.getAttribute("perlDir")+"scripts/";
			String perlEnvironmentVariables = (String)session.getAttribute("perlEnvVar");

 			String hostName=request.getServerName();

			if(hostName.equals("amc-kenny.ucdenver.pvt")){
				perlEnvironmentVariables += ":/bin:/usr/bin:/usr/bin/perl:/usr/share/tomcat/webapps/PhenoGen/perl/lib/circos-0.60/lib:/usr/share/tomcat/webapps/PhenoGen/perl/lib/circos-0.60/bin";
			}
			else if(hostName.equals("compbio.ucdenver.edu")){
				perlEnvironmentVariables += ":/usr/bin/perl5.10:/usr/local/circos-0.62-1/lib:/usr/local/circos-0.62-1/bin";
			}
			else if(hostName.equals("phenogen.ucdenver.edu")){
				perlEnvironmentVariables += ":/usr/bin/perl5.10:/usr/local/circos-0.62-1/lib:/usr/local/circos-0.62-1/bin";
			}
			else if(hostName.equals("stan.ucdenver.pvt")){
				perlEnvironmentVariables += ":/bin:/usr/bin:/usr/bin/perl:/usr/local/circos-0.62-1/lib:/usr/local/circos-0.62-1/bin";
			}
			else{
				perlEnvironmentVariables += ":/usr/bin/perl5.10:/usr/local/circos-0.62-1/lib:/usr/local/circos-0.62-1/bin";
			}
			log.debug("Host Name "+hostName);
			String filePrefixWithPath="";			
			if(request.getParameter("geneCentricPath")!=null){
				filePrefixWithPath = (String)request.getParameter("geneCentricPath")+transcriptClusterID+"_circos";
			}
			// create the short svg directory name which incoporates the date for uniqueness
			java.util.Date dNow = new java.util.Date( );
   			SimpleDateFormat ft = new SimpleDateFormat ("yyyyMMddhhmmss");
			timeStampString = ft.format(dNow);
            //
            // Get the database connection properties
            //
            Properties myProperties = new Properties();
            File myPropertiesFile = new File(dbPropertiesFile);
            myProperties.load(new FileInputStream(myPropertiesFile));
            String dsn = "dbi:"+ myProperties.getProperty("PLATFORM")+ ":" + myProperties.getProperty("DATABASE");
            String OracleUserName = myProperties.getProperty("USER");
            String password = myProperties.getProperty("PASSWORD");			
     		String[] perlScriptArguments = new String[18];
     		// the 0 element in the perlScriptArguments array must be "perl" ??
     		perlScriptArguments[0] = "perl";
     		// the 1 element in the perlScriptArguments array must be the script name including path
     		perlScriptArguments[1]=perlScriptDirectory+"callCircos.pl";
     		perlScriptArguments[2]=ensemblIdentifier;
     		perlScriptArguments[3]=geneSymbolinternal;
     		perlScriptArguments[4]=transcriptClusterID;
     		perlScriptArguments[5]="transcript";
     		perlScriptArguments[6]=transcriptClusterChromosome;
     		perlScriptArguments[7]=transcriptClusterStart;
     		perlScriptArguments[8]=transcriptClusterStop;
     		perlScriptArguments[9]=selectedCutoffValue;
     		perlScriptArguments[10]=species;
     		perlScriptArguments[11]=chromosomeString;
     		perlScriptArguments[12]=geneCentricPath;
     		perlScriptArguments[13]=timeStampString;
     		perlScriptArguments[14]=tissueString;
     		//perlScriptArguments[14]="All";
     		perlScriptArguments[15]=dsn;
            perlScriptArguments[16]=OracleUserName;
            perlScriptArguments[17]=password;

			log.debug(" Calling createCircosFiles from GeneDataTools");
			//log.debug(" filePrefixWithPath "+filePrefixWithPath);
			//
			// call perl script
			//
     		//GeneDataTools gdtCircos=new GeneDataTools();
			//gdtCircos.setSession(session);
        	circosReturnStatus = gdt.createCircosFiles(perlScriptDirectory,perlEnvironmentVariables,perlScriptArguments,filePrefixWithPath);
        	if(circosReturnStatus){
        		log.debug("Circos run completed successfully");       		
				String shortGeneCentricPath;
				if(geneCentricPath.indexOf("/PhenoGen/") > 0){
					shortGeneCentricPath = geneCentricPath.substring(geneCentricPath.indexOf("/PhenoGen/"));
				}
				else{
					shortGeneCentricPath = geneCentricPath.substring(geneCentricPath.indexOf("/PhenoGenTEST/"));
				}
				String svgFile = shortGeneCentricPath+transcriptClusterID+"_"+timeStampString+"/svg/circos_new.svg";
				svgPdfFile = shortGeneCentricPath+transcriptClusterID+"_"+timeStampString+"/svg/circos_new.pdf";
				iframeURL = svgFile;
			}
			else{
				log.debug("Circos run failed");
				// be sure iframeURL is still null
				iframeURL = null;
			} // end of if(circosReturnStatus)
			
		} // end of if((!selectedChromosomeError)&&(!selectedTissueError)){
	
	// This is the end of the first big scriptlet
%>




<%
if((circosReturnStatus!=null)&&(!circosReturnStatus)){
%>
	<div style="color:#FF0000;">There was an error running Circos.  The website administrator has been informed.</div>=
<%
   } // end of checking circosReturnStatus 
%>

<%
if((selectedTissueError!=null)&&(selectedTissueError)){
%>
	<div style="color:#FF0000;">Select at least one tissue.</div>
<%
} // end of checking selectedTissueError 

else if((selectedChromosomeError!=null)&&(selectedChromosomeError)){
%>
	<div style="color:#FF0000;">Chromosome <%=geneChromosome%> must be selected.</div>
<%
} // end of checking selectedChromosomeError 
%>

	
<%
	if(iframeURL!=null){
%>
		<div align="center">
		 Inside of border below, the mouse wheel zooms.  Outside of the border, the mouse wheel scrolls.
          Download Circos image:
			<a href="<%=svgPdfFile%>" target="_blank">
			<img src="/web/images/icons/download_g.png">
			</a>
          <div id="iframe_parent" align="center">
               <iframe id="circosIFrame" src=<%=iframeURL%> height=950 width=950  position=absolute scrolling="no" style="border-style:solid; border-color:rgb(139,137,137); border-radius:15px; -moz-border-radius: 15px; border-width:1px">
               </iframe>
          </div>
          </div>
<%
}// end of if iframeURL != null
%>	
	


 
