<%@ include file="/web/common/anon_session_vars.jsp" %>

<jsp:useBean id="myAnonUser" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser"> </jsp:useBean>
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session"> </jsp:useBean>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2016
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>
<%
    extrasList.add("d3.v4.8.0.min.js");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setDateHeader("Expires", 0);
    
    String uuid="";
    if(request.getParameter("uuid")!=null){
            uuid=FilterInput.getFilteredInput(request.getParameter("uuid"));
    }
    
    AnonGeneList myAnonGL=new AnonGeneList();    
    AnonGeneList[] glList=myAnonGL.getGeneListsForAllDatasetsForUser(uuid,pool);
    
    String urlPrefix=(String)session.getAttribute("mainURL");
    urlPrefix=urlPrefix.substring(0,urlPrefix.lastIndexOf("/")+1)+"web/geneLists/listGeneLists.jsp";
    
    
%>

<%pageTitle="Recover Anonymous Session";%>

<%@ include file="/web/common/header_adaptive_menu.jsp"%>

<script type="text/javascript">
    var contextRoot="<%=contextRoot%>";
    <%@ include file="/javascript/Anon_session.js" %>
    <%@ include file="/javascript/Anon_Genelists.js" %>
</script>
<div style="margin: 25px 25px 25px 25px;">
<div>
    <H3>Recover Session with the following Gene Lists:</H3>
    <span id="recoverLists" style="text-align:center;">
        <table id="listRecoverGeneList" name="items" class="list_base tablesorter" cellpadding="0" cellspacing="2" width="98%">
        		<thead>
        		<tr class="col_title">
				<th>Gene List Name</th>
				<th>Date Created</th>
				<th>Number of Genes</th>
				<th>Organism</th>
				<th>List Source
                        		<span class="info" title="Either the dataset that was analyzed to create this gene list, or it's origin.">
                        		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        		</span>
				</th>
        		</tr>
        		</thead>
        		<tbody>

			<%
        		for ( int i = 0; i < glList.length; i++ ) {
                		GeneList gl = (GeneList) glList[i];  %>
                		<tr id="<%=gl.getGene_list_id()%>" parameterGroupID="<%=gl.getParameter_group_id()%>">
                			<td><%=gl.getGene_list_name()%></td>
                			<td><%=gl.getCreate_date_as_string().substring(0, gl.getCreate_date_as_string().indexOf(" "))%></td>
                			<td><%=gl.getNumber_of_genes()%></td>
                			<td><%=gl.getOrganism()%></td>
                			<td><%=gl.getGene_list_source()==null?"":gl.getGene_list_source()%></td>
				</tr>
			<% } %>
			</tbody>
		</table>
    </span>
</div>
                        <BR>
<div >
    <H3>Your current session is linked to these lists:</H3>
    <span id="currentLists">
        <table id="listCurrentGeneList" name="items" class="list_base tablesorter" cellpadding="0" cellspacing="2" width="98%">
        		<thead>
        		<tr class="col_title">
				<th>Gene List Name</th>
				<th>Date Created</th>
				<th>Number of Genes</th>
				<th>Organism</th>
				<th>List Source
                        		<span class="info" title="Either the dataset that was analyzed to create this gene list, or it's origin.">
                        		<img src="<%=imagesDir%>icons/info.gif" alt="Help">
                        		</span>
				</th>
        		</tr>
        		</thead>
        		<tbody>
                            <tr><td colspan="5">Loading...</td></tr>
			
			</tbody>
		</table>
    </span>
</div><BR><BR>
<div style="text-align: center;">
    <span>Redirecting in <span id="countDown">15</span> seconds. If you do not automatically advance please click the button below.</span><BR>
    <span id="replSessionBtn" class="button replaceSession" style="width:175px;">Replace Current Session</span>
    <span id="mergeSessionBtn" class="button mergeSession" style="width:150px;">Merge Both Sessions</span>    
</div>
<BR>
<div style="padding-bottom: 70px;">
    <UL>
        <li class="replaceSession"><b>Replace Current Session</B> - You will replace the current session so when you return 
            you will return to the recovered session. This is the default when the current session 
            does not have any gene lists.</li>
        <BR>
        <li class="mergeSession"><b>Merge Sessions</b> - Lists from the current session are copied 
            to the recovered session so you will have all the gene lists in one session. Note: if you 
            received multiple links you can merge them together by clicking on them one at a time 
            and selecting merge on this page each time. This is the default when the current session does not
            have any gene lists.</li>
        <BR>
        <!--<li class="currentSession"><b>Temporarily Use Recovered Session</b> - You will only access 
            the recovered session while on this page. Once you leave and come back you will return 
            to the current session.</li>-->
    </UL>
</div>
</div>
<script type="text/javascript">
    var recoverUUID="<%=uuid%>";
    
    $("#replSessionBtn").on("click",replaceSession);
    $("#mergeSessionBtn").on("click",mergeSession);
    
    function setupGeneLists(){
        geneListjs.callBack=function(data){
            if(data.length>0){
                $(".replaceSession").hide();
                setTimeout(function(){
                    mergeSession();
                },10000);
            }else{
                $(".mergeSession").hide();
                setTimeout(function(){
                   replaceSession();
                },14000);
            }
            setTimeout(function(){
                    countDown(14);
                },1000);
        }
        geneListjs.getListGeneLists(true,"#listCurrentGeneList","short");
        
    }
    function countDown(num){
        $("#countDown").html(num);
        if(num > 0){
            setTimeout(function(){
                    countDown(num-1);
                },1000);
        }
    }
    function replaceSession(){
        PhenogenAnonSession.UUID=recoverUUID;
        PhenogenAnonSession.saveUUID();
        setTimeout(function(){
                   window.location.replace("<%=urlPrefix%>");
            },800);
    }
    function mergeSession(){
        $.ajax({
            url: contextRoot+"web/access/mergeSession.jsp",
            type: 'GET',
            cache: false,
            data: {uuidSource:recoverUUID,uuidDest:PhenogenAnonSession.UUID},
            dataType: 'json',
            success: function(data2){
               	console.log(data2);
               	if(data2.status==="success"){
                    //window.location.replace("<%=urlPrefix%>");
                }else{
                    
                }
            },
            error: function(xhr, status, error) {
                console.log("ERROR:"+error);
                
            }
        });
    }
    var PhenogenAnonSession=SetupAnonSession();
    PhenogenAnonSession.setupSession(setupGeneLists);
</script>

<%@ include file="/web/common/footer_adaptive.jsp"%>