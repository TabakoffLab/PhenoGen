<%--
 *  Author: Spencer Mahaffey
 *  Created: Oct, 2017
 *  Description:  The web page created by this file allows the user to 
 *		view metadata associated with RNASeqDatasets.
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/sysbio/include/sysBioHeader.jsp"  %>

<%
    int resource = (request.getParameter("resource") == null ? -99 : Integer.parseInt((String) request.getParameter("resource")));
    String type = (request.getParameter("type") == null ? "" : (String) request.getParameter("type"));
    RNADataset myRNA=new RNADataset();
    RNADataset thisData=myRNA.getRNADataset(resource,pool);
    ArrayList<RNASample> samples=thisData.getSamples();
    ArrayList<RNAResult> results=thisData.getResults();
%>
<%if(type.equals("rnaseqRaw")){%>
    <H2>Raw Data Files:</H2>
    <table id="rawDataFile" name="items" class="list_base tablesorter">
    <thead><TR class="col_title">
            <TH> Sample Name</TH>
            <TH> Filename</TH>
            <TH> Checksum</TH>
            <TH> Download</TH>
        </TR>
    </thead>
    <TBODY>
        <% for(int i=0;i<samples.size();i++){
                ArrayList<RNARawDataFile> files=samples.get(i).getRawFiles();
                for(int j=0;j<files.size();j++){
        %>
                    <TR>
                        <TD><%=samples.get(i).getSampleName()%></TD>
                        <TD><%=files.get(j).getOrigFileName()%></TD>
                        <TD><%=files.get(j).getChecksum()%></TD>
                        <td class="actionIcons">
					<center>
						<a href="downloadLink.jsp?url=<%=files.get(j).getPath()+files.get(j).getFileName()%>" target="_blank" > <img src="../images/icons/download_g.png" /></a>
					</center>
                        </td>
                    </TR>
                <%}
        }%>
    </TBODY>
</table>
<%}else if(type.equals("rnaseqResults")){%>

    <H2>Result Data Files:</H2>
    <table id="resultDataFile" name="items" class="list_base tablesorter">
    <thead><TR class="col_title">
            <TH> Result Type</TH>
            <TH> Genome Version</TH>
            <TH> Version</TH>
            <TH> Date</TH>
            <TH> Filename</TH>
            <TH> Checksum</TH>
            <TH>Analysis Details</TH>
            <TH> Download</TH>
        </TR>
    </thead>
    <TBODY>
        <% for(int i=0;i<results.size();i++){
                ArrayList<RNAResultFile> files=results.get(i).getRNAResultFiles();
                for(int j=0;j<files.size();j++){
        %>
                    <TR id="<%=results.get(i).getRnaDatasetResultID()%>">
                        <TD><%=results.get(i).getType()%></TD>
                        <TD><%=results.get(i).getGenomeVer()%></TD>
                        <TD><%=results.get(i).getVersion()%></TD>
                        <TD><%=results.get(i).getVersionDate()%></TD>
                        <TD><%=files.get(j).getOrigFileName()%></TD>
                        <TD><%=files.get(j).getChecksum()%></TD>
                        <td class="actionIcons"><div class="linkedImg info" type="rnaseqMeta"><div></td>
                        <td class="actionIcons">
					<center>
						<a href="downloadLink.jsp?url=<%=files.get(j).getPath()+files.get(j).getFileName()%>" target="_blank" > <img src="../images/icons/download_g.png" /></a>
					</center>
                        </td>
                    </TR>
                <%}
        }%>
    </TBODY>
<%}%>

<script>
        var tableRows = getRowsFromNamedTable($("table#rawDataFile"));
	stripeAndHoverTable( tableRows );
        var tableRows = getRowsFromNamedTable($("table#resultDataFile"));
	stripeAndHoverTable( tableRows );
        
        
        if($("table#resultDataFile").size()>0){
            $("table#resultDataFile").find("td div.info").click(function() {
                    var id = $(this).parents("tr").attr("id");
                    var theType = $(this).attr("type");

                    var dataParams = { resource:id, type: theType };

                    // send to .jsp to handle download
                    $.ajax({
                            type: "POST",
                            url: contextPath + "/web/sysbio/pipelineMetadata.jsp",
                            dataType: "html",
                            data: dataParams,
                            async: true,
                            success: function( html ){
                                pipelineModal.html( html ).dialog( "open" );
                            },
                            error: function(XMLHttpRequest, textStatus, errorThrown) {
                                    alert( "there was an error processing this request: " + textStatus + " " + errorThrown );
                            }
                    });
            });
        }
</script>
