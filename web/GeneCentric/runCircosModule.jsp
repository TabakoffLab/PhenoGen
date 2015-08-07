	<%@ include file="/web/common/anon_session_vars.jsp" %>
    <jsp:useBean id="gdt" class="edu.ucdenver.ccp.PhenoGen.tools.analysis.GeneDataTools" scope="session"> </jsp:useBean>
<% 
            
            //
            // Initialize some variables
            //
            String iframeURL = null;
            String species="Mm";
            String selectedCutoffValue="2";
            String module="";
            String moduleColor="0,0,0";//r,g,b color - default black
            String chromosomeString="";
            String dataset="ds1";
            String message="";
            String tissueString="";

            //String contextRoot = (String) session.getAttribute("contextRoot");
            //String host = (String) session.getAttribute("host");
            //String appRoot = (String) session.getAttribute("applicationRoot");
            String fullPath = applicationRoot + contextRoot;
            
            log.debug("FULL PATH:"+fullPath);

            // Get parameters
            if(request.getParameter("cutoffValue")!=null){
			selectedCutoffValue = request.getParameter("cutoffValue");
            }
            if(request.getParameter("organism")!=null){
			species = request.getParameter("organism");
            }
            if(request.getParameter("module")!=null){
			module = request.getParameter("module");
            }
            if(request.getParameter("modColor")!=null){
			moduleColor = request.getParameter("modColor");
            }
            if(request.getParameter("chrList")!=null){
			chromosomeString = request.getParameter("chrList");
            }

            //For now tissue is static.  Will need to update later in Rat.
            if(species.equals("Mm")){
			tissueString = "Brain";
            }
            else{
                    // we assume if not mouse that it's rat
                    tissueString = "Brain";
            }
            
            String modPath=fullPath+"tmpData/circos/"+dataset+"/"+module+"/";
		
            String perlScriptDirectory = (String)session.getAttribute("perlDir")+"scripts/";
            String perlEnvironmentVariables = (String)session.getAttribute("perlEnvVar");

            String hostName=request.getServerName();

            if(hostName.equals("phenogen.ucdenver.edu")){
                    perlEnvironmentVariables += ":/usr/bin/perl:/usr/local/circos-0.67-7/lib:/usr/local/circos-0.67-7/bin";
            }
            else if(hostName.equals("stan.ucdenver.pvt")){
                    perlEnvironmentVariables += ":/bin:/usr/bin:/usr/bin/perl:/usr/local/circos-0.67-7/lib:/usr/local/circos-0.67-7/bin";
            }
            else{
                    perlEnvironmentVariables += ":/usr/bin/perl5.10:/usr/local/circos-0.67-7/lib:/usr/local/circos-0.67-7/bin";
            }
	    log.debug(perlEnvironmentVariables);	
            // create the short svg directory name which incoporates the date for uniqueness
            java.util.Date dNow = new java.util.Date( );
            SimpleDateFormat ft = new SimpleDateFormat ("yyyyMMddhhmmss");
            String timeStampString = ft.format(dNow);
            //timeStampString="20141212044050";
            //
            // Get the database connection properties
            //
            //String dbPropertiesFile=(String)session.getAttribute("dbPropertiesFile");
            Properties myProperties = new Properties();
            File myPropertiesFile = new File(dbPropertiesFile);
            myProperties.load(new FileInputStream(myPropertiesFile));
            String dsn = "dbi:"+ myProperties.getProperty("PLATFORM")+ ":" + myProperties.getProperty("DATABASE");
            String OracleUserName = myProperties.getProperty("USER");
            String password = myProperties.getProperty("PASSWORD");	

		
            String[] perlScriptArguments = new String[13];
            // the 0 element in the perlScriptArguments array must be "perl" ??
            perlScriptArguments[0] = "perl";
            // the 1 element in the perlScriptArguments array must be the script name including path
            perlScriptArguments[1]=perlScriptDirectory+"callFromJavaCircosModule.pl";
            perlScriptArguments[2]=module;
            perlScriptArguments[3]=selectedCutoffValue;
            perlScriptArguments[4]=species;
            perlScriptArguments[5]=chromosomeString;
            perlScriptArguments[6]=tissueString;
            perlScriptArguments[7]=modPath;
            perlScriptArguments[8]=timeStampString;
            perlScriptArguments[9]=moduleColor;
            perlScriptArguments[10]=dsn;
            perlScriptArguments[11]=OracleUserName;
            perlScriptArguments[12]=password;

			//
			// call perl script
			//
            String filePrefixWithPath=fullPath+"tmpData/circos/"+dataset+"/"+module+"/"+timeStampString;
            boolean circosReturnStatus = gdt.createCircosFiles(perlScriptDirectory,perlEnvironmentVariables,perlScriptArguments,filePrefixWithPath);
        	if(circosReturnStatus){
        		log.debug("Circos run completed successfully");       		
				
                        String svgFile = contextRoot+"tmpData/circos/"+dataset+"/"+module+"/"+module+"_"+timeStampString+"/svg/circos_new.svg";
                        iframeURL = svgFile;
                }
                else{
                        log.debug("Circos run failed");
                        // be sure iframeURL is still null
                        iframeURL = null;
                        message="There was an error running Circos.  Please try again later.  The administrator has been notified of the error.";
                } // end of if(circosReturnStatus)
			
response.setContentType("application/json");
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setDateHeader("Expires", 0);
%>


{
    "URL":"<%=iframeURL%>",
    "Message":"<%=message%>"
}


	


 
