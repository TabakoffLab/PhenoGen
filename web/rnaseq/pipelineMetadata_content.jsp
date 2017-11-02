<%--
 *  Author: Spencer Mahaffey
 *  Created: Oct, 2017
 *  Description:  The web page created by this file allows the user to 
 *		view metadata associated with RNASeqDatasets.
 *  Todo: 
 *  Modification Log:
 *      
--%>

<H2>Analysis Steps:</H2>
    <%  
        for(int i=0;i<pipelines.size();i++){
            RNAPipeline rp=pipelines.get(i);
        
    %>
<H3 style="text-align: center;">Pipeline: <%=rp.getTitle()%></H3><BR>
<div style="font-size:12px;text-align: center;"><%=rp.getDescription()%></div>
    <div>
    <table name="items" class="list_base tablesorter analysis">
    <thead><TR class="col_title">
            <TH> Analysis Step</TH>
            <TH> Type</TH>
            <TH> Description</TH>
            <TH>Programs/Commands/Versions</TH>
        </TR>
    </thead>
    <TBODY>
        <%  ArrayList<RNAPipelineSteps> steps=rp.getSteps();
            for(int j=0;j<steps.size();j++){
                RNAPipelineSteps rps=steps.get(j);
                String programs="";
                if(rps.getProgram()!=null){
                    programs=programs+" Program: "+rps.getProgram();
                }
                if(rps.getScriptFile()!=null){
                    programs=programs+" Script: "+rps.getScriptFile();
                }
                if(rps.getCommand()!=null){
                    programs=programs+" Command: "+rps.getCommand();
                }
                if(rps.getVersion()!=null){
                    programs=programs+" Version: "+rps.getVersion();
                }
    %>
            <TR>
                <TD><%=(j+1)%></TD>
                <TD><%=rps.getType()%></TD>
                <TD><%=rps.getName()%></TD>
                <TD><%=programs%></TD>
            </TR>
        <%}%>
    </TBODY>
    </table>
    </div>
    <%}%>
</div>
    <script>
        tableRows = getRowsFromNamedTable($("table.analysis"));
	stripeAndHoverTable( tableRows );
   </script>
