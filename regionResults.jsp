<script type="text/javascript">
var trackString="coding,noncoding,snp,smallnc";
var minCoord=<%=min%>;
var maxCoord=<%=max%>;

var initMin=<%=min%>;
var initMax=<%=max%>;

var chr="<%=chromosome%>";
var rnaDatasetID=<%=rnaDatasetID%>;
var arrayTypeID=<%=arrayTypeID%>;
var panel="<%=panel%>";
var forwardPValueCutoff=<%=forwardPValueCutoff%>;
var pValueCutoff=<%=pValueCutoff%>;
var filterExpanded=0;
var tblBQTLAdjust=false;
var tblFromAdjust=false;

var organism="<%=myOrganism%>";
var ucsctype="region";
var ucscgeneID="";
var defaultView="<%=defView%>";
</script>



<%if(genURL.get(0)!=null && !genURL.get(0).startsWith("ERROR:")){%>


<%
	
	
	String tmpURL=genURL.get(0);
	int second=tmpURL.lastIndexOf("/",tmpURL.length()-2);
	String folderName=tmpURL.substring(second+1,tmpURL.length()-1);
	DecimalFormat dfC = new DecimalFormat("#,###");
	
	
	
		
		
%>
    
    <script>
		hideWorking();
		var tisLen=<%=tissuesList1.length%>;
		var folderName="<%=folderName%>";
		$('#inst').hide();
		$(document).on('click','.triggerEC',function(event){
			var baseName = $(this).attr("name");
			$(this).toggleClass("less");
			if($("#"+baseName).is(":hidden")){
				$("#"+baseName).show();
			}else{
				$("#"+baseName).hide();
			}	
			
		});
		
		$(document).on('click','.helpImage', function(event){
			var id=$(this).attr('id');
			$('#'+id+'Content').dialog( "option", "position",{ my: "right top", at: "left bottom", of: $(this) });
			$('#'+id+'Content').dialog("open").css({'font-size':12});
		}
		);
		
		$(document).on('click','.legendBtn', function(event){
			$('#legendDialog').dialog( "option", "position",{ my: "left top", at: "left bottom", of: $(this) });
			$('#legendDialog').dialog("open");
		});
    </script>
<div id="page" style="min-height:1050px;text-align:center;">

	<div id="imageMenu"></div>
    <div style="font-size:18px; font-weight:bold; background-color:#FFFFFF; color:#000000; text-align:center; width:100%; padding-top:3px;">
    		View:
    		<span class="viewMenu" name="viewGenome" >Genome<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
    		<span class="viewMenu" name="viewTrxome" >Transcriptome<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
            <span class="viewMenu" name="viewAll" >Both<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
            <!--<span style="font-size:12px; font-weight:normal; float:right;">
            	Saved Views:
                <select name="viewSelect" id="viewSelect">
                		<option value="0" >------Login to use saved views------</option>
                </select>
            </span>-->
    </div>
    <div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%;">
    		<span class="trigger less" name="collapsableImage" >Region Image</span>
    		<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
            <div id="imageHeader" style=" font-size:12px; float:right;"></div>
            <!--<span style="font-size:12px; font-weight:normal; float:right;">
            	Saved Views:
                <select name="viewSelect" id="viewSelect">
                		<option value="0" >------Login to use saved views------</option>
                </select>
            </span>-->
    </div>
    
    <div style="border-color:#CCCCCC; border-width:1px; border-style:inset; text-align:center;">    
        <div id="collapsableImage" class="geneimage" >
       		<div id="imgLoad" style="display:none;"><img src="<%=imagesDir%>ucsc-loading.gif" /></div>

            <div id="geneImage" class="ucscImage"  style="display:inline-block;width:980px;">
            <script src="javascript/GenomeDataBrowser0.1.js" type="text/javascript"></script>
            	<script src="javascript/GenomeReport0.1.js" type="text/javascript"></script>
				
                <script type="text/javascript">
                    var gs=new GenomeSVG(".ucscImage",970,minCoord,maxCoord,0,chr,"gene");
					loadState(0);
                    $( "ul, li" ).disableSelection();
                </script>
           </div>
        </div>

    </div><!--end Border Div -->
    <BR />
    
<script type="text/javascript">
  $('#legendDialog').dialog({
		autoOpen: false,
		dialogClass: "legendDialog",
		width: 350,
		height: 380,
		zIndex: 999
	});
  	
	
	/*$('.legendBtn').click( function(){
		$('#legendDialog').dialog( "option", "position",{ my: "left top", at: "left bottom", of: $(this) });
		$('#legendDialog').dialog("open");
	});*/
	
	/*$('.Imagetooltip').tooltipster({
		position: 'top-right',
		maxWidth: 250,
		offsetX: 24,
		offsetY: 5,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
	});*/
	
	
	/*$('.helpImage').click( function(event){
		var id=$(this).attr('id');
		$('#'+id+'Content').dialog( "option", "position",{ my: "right top", at: "left bottom", of: $(this) });
		$('#'+id+'Content').dialog("open").css({'font-size':12});
	});*/
</script>    
     

<div id="legendDialog"  title="UCSC Image/Table Rows Color Code Key" class="legendDialog" style="display:none">
                <%@ include file="/web/GeneCentric/legendBox.jsp" %>
    </div>
    
    <div style="width:100%;">
            	<div style="font-size:18px; font-weight:bold;  color:#FFFFFF; text-align:center; width:100%; padding-top: 3px; ">
                    <span id="detail1" class="detailMenu selected" name="regionSummary">Track Details<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
                    <span id="detail2" class="detailMenu" name="regionEQTLTable">Genes with an EQTL in region<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
				</div>
    </div>
    <div style="font-size:18px; font-weight:bold; background-color:#3f92d2; color:#FFFFFF; text-align:left; width:100%;">
    		<span class="trigger less triggerEC" name="collapsableReport" >Region Summary</span>
    		<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
    </div>
    <div id="collapsableReport" style="width:100%;">
    		

        <div style="display:inline-block;width:100%;" id="regionSummary">
            <table style="width:100%;" cellspacing="0">
            <TR><TD style="vertical-align:top;   " class="layout">
            <div id="list" style="text-align:left; overflow:auto;">
            <span style="color:#000000; font-weight:bold;">Track List:</span>
            <UL id="collapsableReportList" style="list-style:none; margin:10px;">
            </UL>
            </div>
            </TD>
            <TD style="text-align:center;" class="layout">
            <div id="trackContent">
                <span>Break down of track count</span><BR /><BR />
                <div id="trackGraph">
                </div>
            </div>
            </TD>
            </TR>
            <TR><TD colspan="2">
                <div class="regionSubHeader" style="font-size:18px; font-weight:bold; text-align:left; width:100%; ">
                    <span class=" trigger triggerRegionTable" name="regionTable"  style="margin-left:30px;"></span>
                    <span>Track Feature Table<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
                </div>
                <div id="regionTable" style="display:none;">
                    
                    
                </div>
            </TD>
            </TR>
            </table>
          </div>
          <div style="display:none;" id="regionEQTLTable">
         
          </div>
    </div><!--collapsableReport end-->
    <BR />
	<div id="selectedDetailHeader" style=" display:none; font-size:18px; font-weight:bold; background-color:#00992D; color:#FFFFFF; text-align:left; width:100%;">
    		<span class="trigger less triggerEC" name="selectedDetail" >Selected Feature Image</span>
    		<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div>
            <span class="closeDetail" style="float:right;"><img src="../web/images/icons/close.png" /></span>
    </div>
    <div id="selectedDetail" style="display:none;">
    	<div id="selectedImage" style="text-align:center;">
        </div>
        <div id="selectedReport">
        </div>
    </div>

</div><!-- ends page div -->

<script type="text/javascript">
	$("span[name='"+defaultView+"']").addClass("selected");
	
	$(document).on('click','span.closeDetail', function(){
			$('div#selectedDetail').hide();
			$('div#selectedDetailHeader').hide();
		});
		
	$('.regionDetailMenu').click(function (){
		var oldID=$('.regionDetailMenu.selected').attr("name");
		$("#"+oldID).hide();
		$('.regionDetailMenu.selected').removeClass("selected");
		$(this).addClass("selected");
		var id=$(this).attr("name");
		$("#"+id).show();
		if(id=="geneEQTL"){
			var jspPage="web/GeneCentric/geneEQTLAjax.jsp";
			var params={
				species: organism,
				geneSymbol: selectedGeneSymbol,
				chromosome: chr,
				id:selectedID
			};
			loadDivWithPage("div#geneEQTL",jspPage,params,
					"<span style=\"text-align:center;width:100%;\"><img src=\"web/images/ucsc-loading.gif\"><BR>Loading...</span>");
		}
		
	});
	
	
</script>


<%}else{%>
    	<div class="error"><%=genURL.get(selectedGene)%><BR />The administrator has been notified of the problem and will investigate the error.  We apologize for any inconvenience.</div><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
<%}%>
    
  






