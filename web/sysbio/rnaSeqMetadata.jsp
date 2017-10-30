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
%>
<div id="metaDataDetails">
<H2>Samples:</H2>
<table id="samples" name="items" class="list_base tablesorter">
    <thead><TR class="col_title">
            <TH> Sample Name</TH>
            <TH> Strain</TH>
            <TH> Age</TH>
            <TH> Sex</TH>
            <TH> Tissue</th>
            <TH> Source</th>
            <TH> Associated Disease</TH>
            <TH> Misc Details</TH>
        </TR>
    </thead>
    <TBODY>
        <% for(int i=0;i<samples.size();i++){
            String srcInfo="";
            if(samples.get(i).getSrcType()!=null){
                srcInfo=srcInfo+samples.get(i).getSrcType();
            }
            if(samples.get(i).getSrcName()!=null){
                srcInfo=srcInfo+" from "+samples.get(i).getSrcName();
            }
            if(samples.get(i).getSrcDate().getTime()!=0){
                srcInfo=srcInfo+" on "+samples.get(i).getSrcDate();
            }
        %>
        <TR>
            <TD><%=samples.get(i).getSampleName()%></TD>
            <TD><%=samples.get(i).getStrain()%></TD>
            <TD><%=samples.get(i).getAge()%></TD>
            <TD><%=samples.get(i).getSex()%></TD>
            <TD><%=samples.get(i).getTissue()%></TD>
            <TD><%=srcInfo%></td>
            <TD><%=samples.get(i).getDisease()%></td>
            <TD><%=samples.get(i).getMiscDetail()%></td>
        </TR>
        <%}%>
    </TBODY>
</table>
<BR><BR>
<H2>Experimental Protocols:</H2>
    <table id="protocols" name="items" class="list_base tablesorter">
    <thead><TR class="col_title">
            <TH> Step</TH>
            <TH> Protocol Type</TH>
            <TH> Name</TH>
            <TH> Description</TH>
            <TH> Version</th>
            <TH> Download Protocol</TH>
        </TR>
    </thead>
    <TBODY>
        <%  ArrayList<ArrayList<RNAProtocol>> prtcl=thisData.getProtocols();
        log.debug("after get Protocols");
            for(int i=0;i<prtcl.size();i++){
                    if(prtcl.get(i).size()>1){
                        ArrayList<RNAProtocol> list=prtcl.get(i);
                        for(int j=0;j<list.size();j++){
                    %>
                            <TR id="<%=prtcl.get(i).get(0).getRnaProtocolID()%>">
                                <TD><%=(i+1)+"."+j%></TD>
                                <TD><%=prtcl.get(i).get(j).getType()%></TD>
                                <TD><%=prtcl.get(i).get(j).getTitle()%></TD>
                                <TD><%=prtcl.get(i).get(j).getDescription()%></TD>
                                <TD><%=prtcl.get(i).get(j).getVersion()%></TD>
                                <td class="actionIcons">
                                        <%if(prtcl.get(i).get(j).getFileName()!=null){%>
                                            <div class="linkedImg download" type="protocol"><div>
                                        <%}%>
                                </td>
                            </TR>
                        <%}%>
                    <%}else if(prtcl.get(i).size()==1){
                        %>
            
                        <TR id="<%=prtcl.get(i).get(0).getRnaProtocolID()%>">
                            <TD><%=i+1%></TD>
                            <TD><%=prtcl.get(i).get(0).getType()%></TD>
                            <TD><%=prtcl.get(i).get(0).getTitle()%></TD>
                            <TD><%=prtcl.get(i).get(0).getDescription()%></TD>
                            <TD><%=prtcl.get(i).get(0).getVersion()%></TD>
                            <td class="actionIcons">
                                    <%if(prtcl.get(i).get(0).getFileName()!=null){%>
                                        <div class="linkedImg download" type="protocol"><div>
                                    <%}%>
                            </td>
                        </TR>
                    <%}%>
        <%}%>
    </TBODY>
</table>
<BR><BR>
<H2>Analysis Steps:</H2>
<table id="analysis" name="items" class="list_base tablesorter">
    <thead><TR class="col_title">
            <TH> Sample Name</TH>
            <TH> Strain</TH>
            <TH> Age</TH>
            <TH> Sex</TH>
            <TH> Tissue</th>
            <TH> Additional Info</TH>
        </TR>
    </thead>
    <TBODY>
        
    </TBODY>
</table>
</div>
    <script>
        var tableRows = getRowsFromNamedTable($("div#metaDataDetails table#samples"));
	stripeAndHoverTable( tableRows );
        tableRows = getRowsFromNamedTable($("div#metaDataDetails table#protocols"));
	stripeAndHoverTable( tableRows );
        tableRows = getRowsFromNamedTable($("div#metaDataDetails table#analysis"));
	stripeAndHoverTable( tableRows );
        //$("div#metaDataDetails table#samples").find("tr.col_title").find("th").slice(1,2).addClass("headerSortDown");
   </script>
