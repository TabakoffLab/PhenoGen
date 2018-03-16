<%--
 *  Author: Spencer Mahaffey
 *  Created: November, 2012
 *  Description:  This file takes the input from an ajax request and returns a table with results.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ page language="java"
        import="java.util.GregorianCalendar"
		import="java.util.Date" %>

<%@ include file="/web/common/anon_session_vars.jsp"  %>


<%
	//get parameters
	boolean exception=false;
	String sourceVersion="hg19";
	String fullSourceSpecies="Human";
	String targetSpecies="Mm10";
	String fullSpecies="Mouse";
	String targetChainFile="hg19ToMm10.over.chain";
	String srcRegion="";
	String displayHumanRegion="";
	String chromosome="";
	long start=0,stop=0;
	double minRatio=0.1;
	double minLenPerc=0.5;
	double origLen=0;
	long minLen=0;
	DecimalFormat df1 = new DecimalFormat("#.#");
	DecimalFormat df0 = new DecimalFormat("#,###");
	FileHandler fh= new FileHandler();
	if(request.getParameter("region")!=null){
		srcRegion=request.getParameter("region");
		srcRegion=srcRegion.replaceAll(",","");
		int colonInd=srcRegion.indexOf(":");
		if(colonInd>0){
			chromosome=srcRegion.substring(0,colonInd);
			if(srcRegion.indexOf("+-")>0){
					String minCoord=srcRegion.substring(srcRegion.indexOf(":")+1,srcRegion.indexOf("+-"));
					String maxCoord=srcRegion.substring(srcRegion.indexOf("+-")+2);
					int tmpInt=Integer.parseInt(maxCoord);
					start=Long.parseLong(minCoord)-tmpInt;
					stop=Long.parseLong(minCoord)+tmpInt;
			}else if(srcRegion.indexOf("-+")>0){
					String minCoord=srcRegion.substring(srcRegion.indexOf(":")+1,srcRegion.indexOf("-+"));
					String maxCoord=srcRegion.substring(srcRegion.indexOf("-+")+2);
					int tmpInt=Integer.parseInt(maxCoord);
					start=Long.parseLong(minCoord)-tmpInt;
					stop=Long.parseLong(minCoord)+tmpInt;
			}else if (srcRegion.indexOf("+")>0){
					String minCoord=srcRegion.substring(srcRegion.indexOf(":")+1,srcRegion.indexOf("+"));
					String maxCoord=srcRegion.substring(srcRegion.indexOf("+")+1);
					start=Long.parseLong(minCoord);
					stop=start+Long.parseLong(maxCoord);
			}else if(srcRegion.indexOf("-")>0){
					String minCoord=srcRegion.substring(srcRegion.indexOf(":")+1,srcRegion.indexOf("-"));
					String maxCoord=srcRegion.substring(srcRegion.indexOf("-")+1);
					start=Long.parseLong(minCoord);
					stop=Long.parseLong(maxCoord);
			}
			if(start>stop){
				long tmp=start;
				start=stop;
				stop=tmp;
			}
			if(start>0 && stop > 0){
					origLen=stop-start;
			}
			displayHumanRegion=chromosome+":"+df0.format(start)+"-"+df0.format(stop);
		}
	}
	if(request.getParameter("sourceSpecies")!=null){
		sourceVersion=request.getParameter("sourceSpecies");
		if(sourceVersion.startsWith("mm")){
			fullSourceSpecies="Mouse";
		}else if(sourceVersion.startsWith("rn")){
			fullSourceSpecies="Rat";
		}else if(sourceVersion.startsWith("hg")){
			fullSourceSpecies="Human";
		}
	}
	if(request.getParameter("targetSpecies")!=null){
		targetSpecies=request.getParameter("targetSpecies");
		if(targetSpecies.substring(0,2).equals("Mm")){
			fullSpecies="Mouse";
		}else if(targetSpecies.substring(0,2).equals("Rn")){
			fullSpecies="Rat";
		}
	}
	targetChainFile=sourceVersion+"To"+targetSpecies+".over.chain";
	if(request.getParameter("minLen")!=null){
		minLenPerc=Double.parseDouble(request.getParameter("minLen"))/100.0;
		minLen=(long)(origLen*minLenPerc);
	}
	if(request.getParameter("minRatio")!=null){
		minRatio=Double.parseDouble(request.getParameter("minRatio"));
	}
	
	Date startDate = new Date();
    GregorianCalendar gc = new GregorianCalendar();
    gc.setTime(startDate);
    String datePart=Integer.toString(gc.get(gc.MONTH)+1)+
                Integer.toString(gc.get(gc.DAY_OF_MONTH))+
                Integer.toString(gc.get(gc.YEAR))+"_"+
                Integer.toString(gc.get(gc.HOUR_OF_DAY))+
                Integer.toString(gc.get(gc.MINUTE))+
                Integer.toString(gc.get(gc.SECOND));
	
	String outputDir=applicationRoot+contextRoot+"tmpData/regionData/translate_"+datePart;
	String liftOverDir=applicationRoot+contextRoot+"web/GeneCentric/liftOver/";
	File outDir=new File(outputDir);
	if(!outDir.exists()){
		outDir.mkdirs();
	}
	
	//write inputFile
	String outputFile=outputDir+"/out.bed";
	String unMappedOutputFile=outputDir+"/upMapped.bed";
	String inputFile=outputDir+"/in.bed";
	
	String contents=chromosome+"\t"+start+"\t"+stop+"\tregionInitial\t0\t.\n";
	try{
         fh.writeFile(contents,inputFile);
    }catch(IOException e){
         log.error("Error writing "+inputFile,e);
    }
	
	//run liftOver
	String[] execArgs = new String[9];
    execArgs[0] = liftOverDir+"liftOver";
	execArgs[1] = inputFile;
	execArgs[2] = liftOverDir+targetChainFile;
	execArgs[3] = outputFile;
	execArgs[4] = unMappedOutputFile;
	execArgs[5] = "-minMatch="+minRatio;
	execArgs[6] = "-multiple";
	execArgs[7] = "-minChainT="+minLen;
	execArgs[8] = "-minChainQ="+minLen;
	//./liftOver in.bed hg19ToRn4.over.chain out.bed unMapped.bed -minMatch=0.5 -multiple -minChainT=10000 -minChainQ=10000
 
	String[] envVar=new String[0];

	//construct ExecHandler which is used instead of Perl Handler because environment variables were needed.
	ExecHandler myExec_session = new ExecHandler(liftOverDir, execArgs, envVar, outputDir+"/translate");

	try {

		myExec_session.runExec();

	} catch (ExecException e) {
		exception=true;
		log.error("In Exception of run liftOver.", e);
		e.printStackTrace(System.err);
		Email myAdminEmail = new Email();
		myAdminEmail.setSubject("Exception thrown in Exec_session");
		myAdminEmail.setContent("There was an error while running "
				+ execArgs[0] + " " + execArgs[1] + " " + execArgs[2] + " " + execArgs[3] + " " + execArgs[4] + " " + execArgs[5] + " " + execArgs[6] + " "+  execArgs[7] + " " + execArgs[8] +"\n\nRegion:"+contents+ "\n\n"+myExec_session.getErrors());
		try {
			myAdminEmail.sendEmailToAdministrator((String) session.getAttribute("adminEmail"));
		} catch (Exception mailException) {
			log.error("error sending message", mailException);
			throw new RuntimeException();
		}
	}
	//read results
	String[] lines=new String[0];
	try{
         lines=fh.getFileContents(new File(outputFile));
    }catch(IOException e){
         log.error("Error writing "+inputFile,e);
    }
	
%>

<!-- Format Results-->
<div style="text-align:center;">
<H3><%=fullSourceSpecies%> <%=displayHumanRegion%> -> <%=fullSpecies%></H3>
Min Ratio: <%=minRatio%> Min Length:<%=minLenPerc*100%>% (<%=minLen%> bp)
<%if(lines.length>0){%>
<table name="items" id="tblTranslate" class="list_base tablesorter translateTable" cellpadding="0" cellspacing="2">
	<thead>
    	<TR class="col_title">
        	<TH><%=fullSpecies%> Chromosome</TH>
            <TH><%=fullSpecies%> Start</TH>
            <TH><%=fullSpecies%> Stop</TH>
            <TH><%=fullSpecies%> Region Size</TH>
            <TH>% of <%=fullSourceSpecies%> Region Length</TH>
            <TH>View Region Transcription Information</TH>
        </TR>
    </thead>
    <tbody>
    	<%for(int i=0;i<lines.length;i++){
			String[] col=lines[i].split("\t");
            if(col.length>4){
				
				long len=Long.parseLong(col[2])-Long.parseLong(col[1]);
				double perc=len/origLen*100;
				double tmpStart=Double.parseDouble(col[1]);
				double tmpStop=Double.parseDouble(col[2]);
				
				%>
                <TR id="<%=col[0]+":"+col[1]+"-"+col[2]+":::"+targetSpecies.substring(0,2)%>">
                    <TD><%=col[0]%></TD>
                    <TD><%=df0.format(tmpStart)%></TD>
                    <TD><%=df0.format(tmpStop)%></TD>
                    <TD><%=df0.format(len)%></TD>
                    <TD><%=df1.format(perc)%></TD>
                    <TD><a href="<%=contextPath%>/gene.jsp?geneTxt=<%=col[0]+":"+df0.format(tmpStart)+"-"+df0.format(tmpStop)%>&speciesCB=<%=targetSpecies.substring(0,2)%>&auto=Y&newWindow=Y" target="_blank">View Region in New Window</a></TD>
                </TR>
            <%}%>
        <%}%>
    </tbody>
</table>
Click on a row above to view the region in the current page.
<%}else{%>
	<BR /><BR />No Regions matching criteria.  Try decreasing the minimum length or minimum ratio.
<%}%>
</div>
<script type="text/javascript">
	$('#waitTranslate').hide();
</script>

<%
	if(!exception){//If an exception occurs leave files so error can be found.
		//clean up files
	 	fh.deleteAllFilesPlusDirectory(new File(outputDir));
	 }
%>