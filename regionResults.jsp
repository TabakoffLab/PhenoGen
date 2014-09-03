<script type="text/javascript">
//Bugsense.addExtraData( 'gene', '<%=selectedEnsemblID%>' );
//Bugsense.addExtraData( 'region', '<%=chromosome+":"+min+"-"+max%>' );
var urlprefix="<%=host+contextRoot%>";
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


var ucsctype="region";
var ucscgeneID="";
var defaultView="<%=defView%>";
<%if(region){%>
var selectGene="";
<%}else{%>
var selectGene="<%=selectedEnsemblID%>";
<%}%>

var dataPrefix="";

</script>

<style>
  #trackListDiv{
    display: inline-block;
	vertical-align:text-top;
    width: 20%;
  }
  #regionTableDiv{
    display: inline-block;
	vertical-align:text-top;
    width: 79%;
  }
  #trackContent{
  	text-align:center;
  }
  @media screen and (max-width:1450px){
    #trackListDiv{
      width: 100%;
	  text-align:left;
    }
	#trackList{
		display: inline-block;
		vertical-align:text-top;
		width:48%;
	}
	#trackContent{
		display: inline-block;
		vertical-align:text-top;
		width:47%;
	}
    #regionTableDiv{
      width: 100%;
    }
	#mouseHelp{
  		font-size:12px;
  	}
  }

.ui-widget { font-size:0.8em;}
	ul#viewSelectMenu0 li,ul#viewSelectMenu1 li{
		cursor:pointer;
	}
</style>


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
		var regionfolderName="<%=folderName%>";
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
			event.stopPropagation();
			//return false;
		}
		);
		
		$(document).on('click','.legendBtn', function(event){
			$('#legendDialog').dialog( "option", "position",{ my: "left top", at: "left bottom", of: $(this) });
			$('#legendDialog').dialog("open");
		});
    </script>
    <script type="text/javascript" src="http://www.java.com/js/deployJava.js"></script>
<div id="page" style="min-height:1050px;text-align:center;">
	<div style="width:100%;text-align:left;">
	<a href="web/demo/largerDemo.jsp?demoPath=web/demo/BrowserNavDemo" target="_blank">Not sure where to start? Watch a quick navigation demonstration</a>
    </div>
    
    <div id="imageMenu"></div>
    <div id="viewMenu"></div>
    <div id="trackMenu"></div>
    <!--<div style="font-size:18px; font-weight:bold; background-color:#FFFFFF; color:#000000; text-align:center; width:100%; padding-top:3px;">
    		View:
    		<span class="viewMenu" name="viewGenome" >Genome<div class="inpageHelp" style="display:inline-block; "><img id="HelpImageGenomeView" class="helpImage" src="../web/images/icons/help.png" /></div></span>
    		<span class="viewMenu" name="viewTrxome" >Transcriptome<div class="inpageHelp" style="display:inline-block; "><img id="HelpImageTranscriptomeView" class="helpImage" src="../web/images/icons/help.png" /></div></span>
            <span class="viewMenu" name="viewAll" >Both<div class="inpageHelp" style="display:inline-block; "><img id="HelpImageAllView" class="helpImage" src="../web/images/icons/help.png" /></div></span>
            <!--<span style="font-size:12px; font-weight:normal; float:right;">
            	Saved Views:
                <select name="viewSelect" id="viewSelect">
                		<option value="0" >------Login to use saved views------</option>
                </select>
            </span>-->
    <!--</div>-->
    <div style=" background-color:#DEDEDE; color:#000000; text-align:left; width:100%;">
    		<table style="width:100%;" cellpadding="0" cellspacing="0">
            <tbody>
            <!--<TR>
            	<TD colspan="2" style="text-align:center; width:100%;">
                <span style="background-color:#DEDEDE;font-size:18px; font-weight:bold;padding:2px 15px 2px 15px;">
                    	<span id="viewLbl0"   >View:</span><span id="viewModifiedCtl">(Modified) <img src="../web/images/icons/save_flat.png" /></span>
                </span>
                </TD>
            </TR>-->
            	<TR>
                	<TD style="background-color:#DEDEDE;font-size:18px; font-weight:bold;">
                        <span class="trigger less" name="collapsableImage" >Region Image</span>
                        <div class="inpageHelp" style="display:inline-block; "><img id="HelpRegionImage" class="helpImage" src="../web/images/icons/help.png" /></div>
                  	</TD>
                    <TD style="background-color:#DEDEDE; text-align:center; width:50%;font-size:18px; font-weight:bold; vertical-align: middle;">
                        <span id="viewLbl0">View:</span><!--<span id="viewModifiedCtl" style="display:none;">(Modified) <span class="control0" ><img src="../web/images/icons/save_24.png" style="position:relative;top:5px;"/></span></span>-->
                    </TD>
                    <TD style="background-color:#DEDEDE;">
                        <div id="imageHeader" style=" font-size:12px; float:right;"></div>
            		</TD>
               </TR>
               </tbody>
            </table>
            <!--<span style="font-size:12px; font-weight:normal; float:right;">
            	Saved Views:
                <select name="viewSelect" id="viewSelect">
                		<option value="0" >------Login to use saved views------</option>
                </select>
            </span>-->
    </div>
    
    <div style="border-color:#CCCCCC; border-width:1px; border-style:inset; text-align:center;">
    	<span id="mouseHelp" style=" min-height:20px;">Navigation Hints: Hold mouse over areas of the image for available actions.</span> <BR />
        <!--<span id="saveBtn" style="display:inline-block;cursor:pointer;"><img src="/web/images/icons/download_g.png"></span>-->
        <div id="collapsableImage" class="geneimage" >
       		<!--<div id="imgLoad" style="display:none;"><img src="<%=imagesDir%>ucsc-loading.gif" /></div>-->

            <div id="geneImage" class="ucscImage"  style="display:inline-block;width:100%;">
            <script src="javascript/GenomeDataBrowser2.0.0.js" type="text/javascript"></script>
            <script src="javascript/GenomeReport2.0.js" type="text/javascript"></script>
            <script src="javascript/GenomeViewMenu2.0.js" type="text/javascript"></script>
            <script src="javascript/GenomeTrackMenu2.0.js" type="text/javascript"></script>
            
            
                <script type="text/javascript">
                    var gs=GenomeSVG(".ucscImage",$(window).width()-25,minCoord,maxCoord,0,chr,"gene");
					
					//loadStateFromCookie(0);		
                    //$( "ul, li" ).disableSelection();
                </script>
           </div>
        </div>

    </div><!--end Border Div -->

    
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
    
    
    
    <div id="regionDiv">
    <BR />
    <div style="width:100%;">
            	<div style="font-size:18px; font-weight:bold;  color:#FFFFFF; text-align:center; width:100%; padding-top: 3px; ">
                    <span id="detail1" class="detailMenu selected" name="regionSummary">Track Details<div class="inpageHelp" style="display:inline-block; "><img id="HelpTrackDetails" class="helpImage" src="../web/images/icons/help.png" /></div></span>
                    <span id="detail2" class="detailMenu" name="regionEQTLTable">Genes with an eQTL in this region<div class="inpageHelp" style="display:inline-block; "><img id="HelpeQTLTab" class="helpImage" src="../web/images/icons/help.png" /></div></span>
				</div>
    </div>
    <div style="font-size:18px; font-weight:bold; background-color:#3f92d2; color:#FFFFFF; text-align:left; width:100%;">
    		<span class="trigger less triggerEC" name="collapsableReport" >Region Summary</span>
    		<div class="inpageHelp" style="display:inline-block; "><img id="HelpRegionSummary" class="helpImage" src="../web/images/icons/help.png" /></div>
    </div>
    <div id="collapsableReport" style="width:100%;">
        <div style="display:inline-block;width:100%;" id="regionSummary">
            <div id="trackListDiv">
                <div id="trackList" style="text-align:left;">
                	<span style="color:#000000; font-weight:bold;">Track List:</span>
                    <UL id="collapsableReportList" style="list-style:none; margin:10px;">
                    </UL>
                </div>
                <div id="trackContent">
                    <span style="font-weight:bold;">Break down of track count*</span><BR /><BR />
                    <div id="trackGraph">
                    </div>
                    <span>*Note: Depending on the track settings some features may not be displayed and will not be reflected in the image above.</span>
                </div>
            </div>
               <div id="regionTableDiv">
                   <div id="regionTableSubHeader" class="regionSubHeader" style="font-size:18px; font-weight:bold; text-align:left; width:100%; ">
                        <!--<span class="trigger triggerRegionTable" name="regionTable"  style="margin-left:30px;"></span>-->
                        <span style="margin-left:30px;">Features in Selected Track<div class="inpageHelp" style="display:inline-block; "><img id="HelpUCSCImage" class="helpImage" src="../web/images/icons/help.png" /></div></span>
                   </div>
                   <div id="regionTable" style="display:none;">
                        
                        
                   </div>
               </div>
          </div>
          <div style="display:none;" id="regionEQTLTable">
         
          </div>
    </div><!--collapsableReport end-->
    </div>

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
    <div style="display:none">
		<a id="helpExampleNav" class="fancybox fancybox.iframe" href="web/GeneCentric/example.jsp" title="Browser Navigation"></a>
    </div>
    
    <BR /><BR /><BR />
    
    <a href="" target="_blank" style="display:none;" id="fileDownload"></a>
    
</div><!-- ends page div -->

<script type="text/javascript">
	$("span[name='"+defaultView+"']").addClass("selected");
	
	$(document).on('click','span.closeDetail', function(){
			$('div#selectedDetail').hide();
			$('div#selectedDetailHeader').hide();
			svgList[0].clearSelection();
			if(!$('div#collapsableReport').is(':visible')){
						$('div#collapsableReport').show();
						$("span[name='collapsableReport']").addClass("less");
			}
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
	
	$(".Imagetooltip").tooltipster({
		position: 'top-right',
		maxWidth: 250,
		offsetX: 24,
		offsetY: 5,
		contentAsHTML:true,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
	});
	
	
	//Setup Fancy box for example
     $('.fancybox').fancybox({
                width:"800px",
                height:$(document).height(),
                scrollOutside:false
                /*afterClose: function(){
                        $('body.noPrint').css("margin","5px auto 60px");
                        return;
                }*/
  	});
	displayHelpFirstTime();
	
	/*$('#saveBtn').click( function(){
		var content=$("div#Level0").html();
		content+"\n";
		$.ajax({
				url: pathPrefix+"saveBrowserImage.jsp",
   				type: 'POST',
				contentType: 'text/html',
				data: content,
				processData: false,
				dataType: 'json',
    			success: function(data2){ 
        			console.log(data2.imageFile);
					var url="http://<%=host+contextRoot%>/tmpData/download/"+data2.imageFile;
					 var filename = data2.imageFile;
					  var xhr = new XMLHttpRequest();
					  xhr.responseType = 'blob';
					  xhr.onload = function() {
						var a = document.createElement('a');
						a.href = window.URL.createObjectURL(xhr.response); // xhr.response is a blob
						a.download = filename; // Set the file name.
						a.style.display = 'none';
						document.body.appendChild(a);
						a.click();
						delete a;
					  };
					  xhr.open('GET', url);
					  xhr.send();
    			},
    			error: function(xhr, status, error) {
        			console.log(error);
    			}
			});
	});*/
	
	/*$('#saveBtn').click( function(){
		html2canvas($('div#Level0'), {
			background: "#ffffff",
			timeout: 15000,
  			onrendered: function(canvas) {
    		document.body.appendChild(canvas);
  		}
		});
	});*/
	
</script>


<%}else{%>
    	<div class="error"><%=genURL.get(selectedGene)%><BR />The administrator has been notified of the problem and will investigate the error.  We apologize for any inconvenience.</div><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR />
<%}%>
    
  






