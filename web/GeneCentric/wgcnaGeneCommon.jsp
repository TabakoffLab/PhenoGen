<%
    String geneID="";
    String org="";
    String dispType="single";
    String viewType="gene";
    String region="";
    String geneListID="";
    if(request.getParameter("id")!=null){
            geneID=request.getParameter("id");
    }
    if(request.getParameter("region")!=null){
            region=request.getParameter("region");
    }
    if(selectedGeneList!=null){
        geneListID=Integer.toString(selectedGeneList.getGene_list_id());
    }
%>

<style>
    .leftTable{
        float:left;
    }
    .rightTable{
        float:right;
    }
</style>

<div style="text-align:center;"
    <div id="wgcnaImageControls" style="display:inline-block;width:100%;">
        <table style="width:100%;">
            <TR>
                <TD style="text-align: left;" id="imageControl"></TD>
                <TD style="text-align: center;" id="dataControl"></TD>
                <TD style="text-align: right;" id="viewControl"></TD>
            </TR>
        </table>
    </div>
    <BR>
    <div id="wgcnaMouseHelp" style="display:inline-block;width:100%;text-align:center;">
        Navigation Hints: Hold mouse over areas of the image for available actions.
    </div>
    <div id="wgcnaGeneImage" style="width:99%;border:1px solid;text-align: center;">
        <div id="waitCircos" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Working..." text-align="center" ><BR>Loading...</div>
    </div>
    <div id="tableExportCtl" style="float:right;"></div>
    <div id="wgcnaModuleTable" style="display:none;width:99%;border:1px solid;text-align: center;">
        <div id="waitModuleTable" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Loading..." text-align="center" ><BR>Loading...</div>
        <H2>Transcripts in <span id="modTableName">Selected</span> Module</h2><BR>
        <table class="list_base" id="moduleTable" width="98%">
            <thead>
                <TR class="col_title">
                    <TH>Gene Symbol</TH>
                    <TH>Gene ID</th>
                    <TH>Transcript</th>
                    <TH>Probe Sets</th>
                    <TH>Link Total<!--<span class="" id=""><img src="/web/images/icons/info.png"></span>--></th>
                </TR>
            </thead>
            <tbody>
                
            </tbody>
        </table>
    </div>
    <div id="wgcnaMirTable" style="display:none;width:99%;border:1px solid;text-align: center;">
        <div id="waitMirTable" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Loading..." text-align="center" ><BR>Loading...</div>
        <H2>Transcripts in <span id="mirTableName">Selected</span> Module</h2><BR>
        <table class="list_base" id="mirTable" width="98%">
            <thead>
                <TR class="col_title">
                    <TH>miRNA ID</TH>
                    <TH>Mature miRNA Accession</th>
                    <TH>Location</th>
                    <TH>Predicted Gene Targets</th>
                    <TH>Validated Gene Targets</th>
                    <TH>Total Gene Targets</th>
                </TR>
            </thead>
            <tbody>
                
            </tbody>
        </table>
    </div>
    <div id="wgcnaMirGeneTable" style="display:none;width:99%;border:1px solid;text-align: center;">
        <div id="waitMirGeneTable" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Loading..." text-align="center" ><BR>Loading...</div>
        <H2>Transcripts in <span id="mirGeneTableName">Selected</span> Module</h2><BR>
        <table class="list_base" id="mirGeneTable" width="98%">
            <thead>
                <TR class="col_title">
                    <TH>Gene Symbol</th>
                    <TH>Ensembl ID</TH>
                    <TH>Location</th>
                    <TH>Predicted miRNAs targeting gene</th>
                    <TH>Validated miRNAs targeting gene</th>
                    <TH>Total miRNAs targeting gene</th>
                </TR>
            </thead>
            <tbody>
                
            </tbody>
        </table>
    </div>
    <div id="wgcnaGoTable" style="display:none;width:99%;border:1px solid;text-align: center;">
        <div id="waitGoTable" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Loading..." text-align="center" ><BR>Loading...</div>
        <H2>Transcripts in <span id="GoTableName">Selected</span> Module</h2><BR>
        <table  id="GoTable" width="98%">
            <thead>
                <TR class="col_title">
                    <TH>Name<span title="Expand All" style="float:left;"><img src="<%=imagesDir%>icons/add.png"></span><span title="Close All" style="float:left;"><img src="<%=imagesDir%>icons/min.png"></span></TH>
                    <TH>Definition</th>
                    <TH>Genes<span title="Expand All" id="goGLExpand" style="float:left;"><img src="<%=imagesDir%>icons/add.png"></span><span title="Close All" id="goGLClose" style="float:left;"><img src="<%=imagesDir%>icons/min.png"></span></th>
                </TR>
            </thead>
            <tbody>
                
            </tbody>
        </table>
    </div>
    <div id="wgcnaEqtlTable" style="display:none;width:99%;border:1px solid;text-align: center;">
        <div id="waitEqtlTable" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Loading..." text-align="center" ><BR>Loading...</div>
        <H2>eQTL locations for <span id="eqtlTableName">Selected</span> Module</h2><BR>
        <table class="list_base" id="eqtlTable" width="98%">
            <thead>
                <TR class="col_title">
                    <TH>Chromosome</TH>
                    <TH>Position (Mbp)</TH>
                    <TH>SNP ID</th>
                    <TH>-log(P-value)</th> 
                </TR>
            </thead>
            <tbody>
                
            </tbody>
        </table>
    </div>
</div>

<script type="text/javascript">
    var disptype="<%=dispType%>";
    var viewtype="<%=viewType%>";
    var wgcnaid="<%=geneID%>";
    var wgcnaregion="<%=region%>";
    var genelist="<%=geneListID%>";
    var tissue="Whole Brain";
    var modulePrefix="";
    
    var wgcna=WGCNABrowser(wgcnaid,wgcnaregion,genelist,disptype,viewtype,tissue);
    wgcna.setup();
    
    $("#goGLExpand").on("click",function(){
        console.log("expand");
        $("#GoTable span.triggerGL:visible").each(function(){
            console.log($(this));
           var name=this.getAttribute("name");
           $(this).addClass("less");
           $("span#"+name).show();
        });
    });
    
    $("#goGLClose").on("click",function(){
        
        $("#GoTable span.triggerGL:visible").each(function(){
           var name=this.getAttribute("name");
           $(this).removeClass("less");
           $("span#"+name).hide();
        });
    });
</script>