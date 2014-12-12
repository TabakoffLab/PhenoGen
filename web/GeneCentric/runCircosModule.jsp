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
			String species = null;
			String longSpecies = null;		
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
				numberOfTissues = 1;
				// assume if not mouse that it's rat
				tissueNameArray[0]="Brain";
				tissueDisplayArray[0]="Whole Brain";
				/*tissueNameArray[1]="Heart";
				tissueDisplayArray[1]="Heart";
				tissueNameArray[2]="Liver";
				tissueDisplayArray[2]="Liver";
				tissueNameArray[3]="BAT";
				tissueDisplayArray[3]="Brown Adipose";*/
			}			
			
			
	//boolean auto=false;
	//////////////////////////////////////////////////////////////////////////////////
	//
	// Evaluate entries on form	
	//
	//////////////////////////////////////////////////////////////////////////////////
	
	
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
			tissueString = "Brain;";
			selectedTissueError = false;
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
     		perlScriptArguments[1]=perlScriptDirectory+"callCircosModule.pl";
     		perlScriptArguments[2]=module;
     		perlScriptArguments[3]=selectedCutoffValue;
     		perlScriptArguments[4]=species;
     		perlScriptArguments[5]=chromosomeString;
     		perlScriptArguments[6]=tissueString;
     		perlScriptArguments[7]=modPath;
     		perlScriptArguments[8]=timeStampString;
     		perlScriptArguments[9]="null";
     		perlScriptArguments[10]=dsn;
                perlScriptArguments[11]=OracleUserName;
                perlScriptArguments[12]=password;

			//
			// call perl script
			//
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
	


 
