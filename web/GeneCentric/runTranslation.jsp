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

<%@ include file="/web/common/session_vars.jsp"  %>


<%
	//get parameters
	String targetSpecies="Mm";
	String targetChainFile="hg19ToMm9.over.chain";
	String humanRegion="";
	String chromosome="";
	long start=0,stop=0;
	double minRatio=0.1;
	double minLenPerc=0.5;
	double origLen=0;
	long minLen=0;
	if(request.getParameter("region")!=null){
		humanRegion=request.getParameter("region");
		int colonInd=humanRegion.indexOf(":");
		int dashInd=humanRegion.indexOf("-");
		if(colonInd<dashInd && colonInd>-1 && dashInd>-1){
			chromosome=humanRegion.substring(0,colonInd);
			String startTmp=humanRegion.substring(colonInd+1,dashInd);
			String stopTmp=humanRegion.substring(dashInd+1);
			start=Long.parseLong(startTmp);
			stop=Long.parseLong(stopTmp);
			if(start>0 && stop > 0){
				origLen=stop-start;
			}
		}
	}
	if(request.getParameter("targetSpecies")!=null){
		targetSpecies=request.getParameter("targetSpecies");
		if(targetSpecies.equals("Mm")){
			targetChainFile="hg19ToMm9.over.chain";
		}else if(targetSpecies.equals("Rn")){
			targetChainFile="hg19ToRn4.over.chain";
		}
	}
	if(request.getParameter("minLen")!=null){
		minLenPerc=Integer.parseInt(request.getParameter("minLen"))/100.0;
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
         new FileHandler().writeFile(contents,inputFile);
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
		log.error("In Exception of run liftOver.", e);
		e.printStackTrace(System.err);
		Email myAdminEmail = new Email();
		myAdminEmail.setSubject("Exception thrown in Exec_session");
		myAdminEmail.setContent("There was an error while running "
				+ execArgs[0] + " " + execArgs[1] + " " + execArgs[2] + " " + execArgs[3] + " " + execArgs[4] + " " + execArgs[5] + " " + execArgs[6] + " "+  execArgs[7] + " " + execArgs[8] + "\n\n"+myExec_session.getErrors());
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
         lines=new FileHandler().getFileContents(new File(outputFile));
    }catch(IOException e){
         log.error("Error writing "+inputFile,e);
    }
	
%>

<!-- Format Results-->
<table name="items" id="tblTranslate" class="list_base tablesorter" cellpadding="0" cellspacing="2">
	<thead>
    	<TR class="col_title">
        	<TH>Target Chromosome</TH>
            <TH>Target Start</TH>
            <TH>Target Stop</TH>
            <TH>Target Size</TH>
            <TH>% of original length</TH>
        </TR>
    </thead>
    <tbody>
    	<%for(int i=0;i<lines.length;i++){
			String[] col=lines[i].split("\t");
            if(col.length>4){
				long len=Long.parseLong(col[2])-Long.parseLong(col[1]);
				double perc=len/origLen*100;%>
                <TR>
                    <TD><%=col[0]%></TD>
                    <TD><%=col[1]%></TD>
                    <TD><%=col[2]%></TD>
                    <TD><%=len%></TD>
                    <TD><%=perc%></TD>
                </TR>
            <%}%>
        <%}%>
    </tbody>
</table>
<script type="text/javascript">
	$('#waitTranslate').hide();
</script>