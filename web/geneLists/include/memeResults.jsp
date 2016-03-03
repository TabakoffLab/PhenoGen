<%--
 *  Author: Cheryl Hornbaker
 *  Created: Nov, 2006
 *  Description:  This file formats the MEME files.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%@ include file="/web/common/anon_session_vars.jsp" %>
<jsp:useBean id="myGeneListAnalysis" class="edu.ucdenver.ccp.PhenoGen.data.GeneListAnalysis"/>
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />

<% 	formName = "promoter.jsp";
	request.setAttribute( "selectedTabId", "promoter" );

	optionsList.add("geneListDetails");
	optionsList.add("chooseNewGeneList");

	int itemID = (request.getParameter("itemID") != null ? Integer.parseInt((String) request.getParameter("itemID")) : -99);
	
	log.debug("in memeResults. itemID = " + itemID);

        GeneListAnalysis thisGeneListAnalysis =null;
        if(userLoggedIn.getUser_name().equals("anon")){
                thisGeneListAnalysis = myGeneListAnalysis.getAnonGeneListAnalysis(itemID, pool);
        }else{
                thisGeneListAnalysis = myGeneListAnalysis.getGeneListAnalysis(itemID, pool);
        }
	ParameterValue[] myParameterValues = thisGeneListAnalysis.getParameterValues();
	int upstreamLength = Integer.parseInt(thisGeneListAnalysis.getThisParameter("Sequence Length"));
			
	GeneList thisGeneList = thisGeneListAnalysis.getAnalysisGeneList();
	
	String tmpMemeDir=thisGeneListAnalysis.getThisParameter("MEME Dir");
	String memeDir = thisGeneList.getMemeDir(thisGeneList.getGeneListAnalysisDir(userLoggedIn.getUserMainDir()));
        if(userLoggedIn.getUser_name().equals("anon")){
                        memeDir=userLoggedIn.getUserGeneListsDir() +"/" + anonU.getUUID()+"/"+thisGeneList.getGene_list_id()+"/MEME/";
        }
        String memeFileName = 
		thisGeneList.getMemeFileName(memeDir, thisGeneListAnalysis.getCreate_date_for_filename()) + 
		".html";
	if(tmpMemeDir!=null){
		memeDir=tmpMemeDir;
		memeFileName=memeDir+"meme.html";
        
	}

	log.debug("memeDir = "+memeDir);


	String[] memeResultsOld = new String[0];
	String memeResults="";
	if(memeFileName.contains("meme.html")){
		memeResults=myFileHandler.getFileMemeContents(new File(memeFileName));
	}else{
		memeResultsOld=myFileHandler.getFileContents(new File(memeFileName), "withSpaces");
	}
    mySessionHandler.createGeneListActivity("Viewed MEME Results for gene list", pool);
%>

	<div class="dataContainer" style="padding-bottom: 70px;">

        <div class="title"> Parameters Used:</div>
        <table class="list_base" cellpadding="0" cellspacing="3">
            <tr class="col_title">
                <th class="noSort">Parameter Name</th>
                <th class="noSort">Value</th>
            </tr>
            <% for (int i=0; i<myParameterValues.length; i++) {
                String value = (myParameterValues[i].getValue().equals("zoops") ? "Zero or one per sequence" : 
                    (myParameterValues[i].getValue().equals("oops") ? "One per sequence" : 
                        (myParameterValues[i].getValue().equals("tcm") ? "Any number of repetitions" : 
                        myParameterValues[i].getValue())));
                 %>
                <tr>
                <td width=30%><b><%=myParameterValues[i].getParameter()%>:</b> </td>
                <td width=70%><%=value%></td>
                </tr>
            <% } %>
        </table>
        
        <!--<div><a href="http://meme.nbcr.net/meme4_4_0/meme-intro.html" target="_blank">MEME Reference</a></div>-->
	<div class="title"> MEME Output:</div>
<% if(memeResultsOld.length>0){
	for (int i=0; i<memeResultsOld.length; i++) {
		%> <%=memeResultsOld[i]%> <%
	}
}else{%>
<%=memeResults%>
    <script type="text/javascript">
	post_load_setup();
    </script>
<%}%>

