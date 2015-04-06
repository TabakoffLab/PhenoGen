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
    .dataTables_filter{
        display:inline-block;
    }
    .dataTables_info{
        display:inline-block;
        float:right;
    }
</style>

<div style="text-align:center;">
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
    <div id="wgcnaGeneImage" style="/*width:99%;*/border:1px solid;text-align: center;">
        <div id="waitCircos" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Working..." text-align="center" ><BR>Loading...</div>
    </div>
    <div id="tableExportCtl" style="float:right;"></div>
    <div id="wgcnaModuleTable" style="display:none;/*width:99%;*/border:1px solid;text-align: center;">
        <div id="waitModuleTable" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Loading..." text-align="center" ><BR>Loading...</div>
        <H2>Transcripts in <span id="modTableName">Selected</span> Module</h2><BR>
        <div style="text-align:left;">
            <table class="list_base" id="moduleTable" width="100%">
                <thead>
                    <TR class="col_title">
                        <TH>Gene Symbol</TH>
                        <TH>Gene ID</th>
                        <TH>Transcript</th>
                        <TH>Probe Sets</th>
                        <TH>Link Total<!--<span class="" id=""><img src="/web/images/icons/info.png"></span>--></th>
                        <TH>Link Rank</th>
                    </TR>
                </thead>
                <tbody>

                </tbody>
            </table>
        </div>
    </div>
    <div id="wgcnaMirTable" style="display:none;/*width:99%;*/border:1px solid;text-align: center;">
        <div id="waitMirTable" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Loading..." text-align="center" ><BR>Loading...</div>
        <H2>Transcripts in <span id="mirTableName">Selected</span> Module</h2><BR>
        <div style="text-align:left;">
            <table class="list_base" id="mirTable" width="100%">
                <thead>
                    <TR class="col_title">
                        <TH>miRNA ID</TH>
                        <TH>Mature miRNA Accession</th>
                        <!--<TH>Location</th>-->
                        <TH>Predicted Gene Targets<span class="mirEC" name="triggerpL" title="Expand All" id="mirPExpand" style="float:left;pointer-events:all;"><img src="<%=imagesDir%>icons/add.png"></span><span class="mirEC" name="triggerpL" title="Close All" id="mirPClose" style="float:left;pointer-events:all;"><img src="<%=imagesDir%>icons/min.png"></span></th>
                        <TH>Validated Gene Targets<span class="mirEC" name="triggervL" title="Expand All" id="mirVExpand" style="float:left;pointer-events:all;"><img src="<%=imagesDir%>icons/add.png"></span><span class="mirEC" name="triggervL" title="Close All" id="mirVClose" style="float:left;pointer-events:all;"><img src="<%=imagesDir%>icons/min.png"></span></th>
                        <TH>Total Gene Targets<span class="mirEC" name="triggerMiL" title="Expand All" id="mirSExpand" style="float:left;pointer-events:all;"><img src="<%=imagesDir%>icons/add.png"></span><span class="mirEC" name="triggerMiL" title="Close All" id="mirSClose" style="float:left;pointer-events:all;"><img src="<%=imagesDir%>icons/min.png"></span></th>
                    </TR>
                </thead>
                <tbody>

                </tbody>
            </table>
        </div>
    </div>
    <div id="wgcnaMirGeneTable" style="display:none;/*width:99%;*/border:1px solid;text-align: center;">
        <div id="waitMirGeneTable" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Loading..." text-align="center" ><BR>Loading...</div>
        <H2>Transcripts in <span id="mirGeneTableName">Selected</span> Module</h2><BR>
        <div style="text-align:left;">
        <table class="list_base" id="mirGeneTable" width="100%">
            <thead>
                <TR class="col_title">
                    <TH>Gene Symbol</th>
                    <TH>Ensembl ID</TH>
                    <!--<TH>Location</th>-->
                    <TH>Predicted miRNAs targeting gene<span class="mirGEC" name="triggerpL" title="Expand All" id="mirGPExpand" style="float:left;pointer-events:all;"><img src="<%=imagesDir%>icons/add.png"></span><span class="mirGEC" name="triggerpL" title="Close All" id="mirGPClose" style="float:left;pointer-events:all;"><img src="<%=imagesDir%>icons/min.png"></span></th>
                    <TH>Validated miRNAs targeting gene<span class="mirGEC" name="triggervL" title="Expand All" id="mirGVExpand" style="float:left;pointer-events:all;"><img src="<%=imagesDir%>icons/add.png"></span><span class="mirGEC" name="triggervL" title="Close All" id="mirGVClose" style="float:left;pointer-events:all;"><img src="<%=imagesDir%>icons/min.png"></span></th>
                    <TH>Total miRNAs targeting gene<span class="mirGEC" name="triggerMiL" title="Expand All" id="mirGSExpand" style="float:left;pointer-events:all;"><img src="<%=imagesDir%>icons/add.png"></span><span class="mirGEC" name="triggerMiL" title="Close All" id="mirGSClose" style="float:left;pointer-events:all;"><img src="<%=imagesDir%>icons/min.png"></span></th>
                </TR>
            </thead>
            <tbody>
                
            </tbody>
        </table>
        </div>
    </div>
    <div id="wgcnaGoTable" style="display:none;/*width:99%;*/border:1px solid;text-align: center;">
        <div id="waitGoTable" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Loading..." text-align="center" ><BR>Loading...</div>
        <H2>Gene Ontology Terms for Genes in the <span id="GoTableName">Selected</span> Module</h2><BR>
        Click on any row to make it the root of the table and image.
        <div style="text-align:left;">
        <table  id="GoTable" width="100%">
            <thead>
                <TR class="col_title">
                    <TH>Name<span title="Expand All" id="goExpand" style="float:left;"><img src="<%=imagesDir%>icons/add.png"></span><span title="Close All" id="goClose" style="float:left;"><img src="<%=imagesDir%>icons/min.png"></span><span title="Go up a level (set root to the parent term)" id="goUp" style="float:left;"><img width="14" height="14" src="<%=imagesDir%>icons/up_flat.png"></span></TH>
                    <TH>Definition</th>
                    <TH>Genes<span title="Expand All" id="goGLExpand" style="float:left;"><img src="<%=imagesDir%>icons/add.png"></span><span title="Close All" id="goGLClose" style="float:left;"><img src="<%=imagesDir%>icons/min.png"></span></th>
                </TR>
            </thead>
            <tbody>
                
            </tbody>
        </table>
        </div>
    </div>
    <div id="wgcnaEqtlTable" style="display:none;/*width:99%;*/border:1px solid;text-align: center;">
        <div id="waitEqtlTable" align="center" ><img src="<%=imagesDir%>wait.gif" alt="Loading..." text-align="center" ><BR>Loading...</div>
        <H2>eQTL locations for <span id="eqtlTableName">Selected</span> Module</h2><BR>
        <div style="text-align:left;">
            <table class="list_base" id="eqtlTable" width="100%">
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
    $("#goUp").on("click",function(){
        var par=that.singleImage.selectedNode.parent;
        if(typeof par !=='undefined' && typeof par.name !=='undefined'){
            that.singleImage.selectedNode=par;
            that.singleImage.draw();
        }
    });
    $("#goExpand").on("click",function(){
        $("#GoTable tbody tr").each(function(){
           $(this).show();
        });
        $("span.trigger").addClass("less");
        event.stopPropagation();
    });
    $("#goClose").on("click",function(){
        $("#GoTable tbody tr").each(function(){
           $(this).hide();
        });
        $("span.trigger").removeClass("less");
        $("tr.d0").show();
        $("tr.d1").show();
        event.stopPropagation();
    });
    
    $("#goGLExpand").on("click",function(){
        $("#GoTable span.triggerGL:visible").each(function(){
           var name=this.getAttribute("name");
           $(this).addClass("less");
           $("span#"+name).show();
        });
        event.stopPropagation();
    });
    
    $("#goGLClose").on("click",function(){
        $("#GoTable span.triggerGL:visible").each(function(){
           var name=this.getAttribute("name");
           $(this).removeClass("less");
           $("span#"+name).hide();
        });
        event.stopPropagation();
    });
    
    
    $(".mirGEC").on("click",function(event){
        var ec=$(this).attr("title");
        var trClass=$(this).attr("name");
        if(ec==='Expand All'){//expand
            $("#mirGeneTable span."+trClass+":visible").each(function(){
                var name=this.getAttribute("name");
                $(this).addClass("less");
                $("span#"+name).show();
            });
        }else{//collapse
            $("#mirGeneTable span."+trClass+":visible").each(function(){
                var name=this.getAttribute("name");
                $(this).removeClass("less");
                $("span#"+name).hide();
            });
        }
        event.stopPropagation();
    });
    
    $(".mirEC").on("click",function(event){
        var ec=$(this).attr("title");
        var trClass=$(this).attr("name");
        if(ec==='Expand All'){//expand
            $("#mirTable span."+trClass+":visible").each(function(){
                var name=this.getAttribute("name");
                $(this).addClass("less");
                $("span#"+name).show();
            });
        }else{//collapse
            $("#mirTable span."+trClass+":visible").each(function(){
                var name=this.getAttribute("name");
                $(this).removeClass("less");
                $("span#"+name).hide();
            });
        }
        event.stopPropagation();
    });
    
</script>