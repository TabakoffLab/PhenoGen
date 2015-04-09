<%@ include file="/web/common/anon_session_vars.jsp" %>


<%
	int level=0;
	String type="gene";
	String myOrganism="Rn";
	if(request.getParameter("level")!=null){
		level=Integer.parseInt(request.getParameter("level"));
	}
	
	if(request.getParameter("type")!=null){
		type=request.getParameter("type");
	}
	
	if(request.getParameter("organism")!=null){
		myOrganism=request.getParameter("organism");
	}
%>


<style>
	.ui-accordion .ui-accordion-content {
		padding:1em 0.5em;
	}
	table#trackListTbl<%=level%> tr{
		vertical-align:middle;
	}
</style>

    <div class="viewsLevel<%=level%>"  style="display:none;width:600px;border:solid;border-color:#000000;border-width:1px; z-index:999; position:absolute; top:50px; left:-98px; background-color:#FFFFFF; min-height:550px; text-align:center;">
        	<div style="display:block;width:100%;color:#000000; text-align:left; background:#EEEEEE; font-weight:bold;"><span id="viewMenuLbl<%=level%>">Select/Edit Views</span><span class="closeBtn" id="close_viewsLevel<%=level%>" style="position:relative;top:2px;left:461px;"><img src="<%=imagesDir%>icons/close.png"></span></div>
        	<div id="toolbar<%=level%>"></div>
			<div id="selection<%=level%>" style=" text-align:left;">
                <table style="width:100%;">
                	<%if(loggedIn&&userLoggedIn.getUser_name().equals("anon")){%>
                    	<TR>
                    		<TD><img src="<%=imagesDir%>icons/alert_24.png"><span style="font-weight:bold;color:#000000;position:relative;top:-7px;">Sign in to see views/tracks not created on this computer.  <span class="viewtooltip<%=level%>" title="If you sign in views and tracks are saved to the server so that you may use them on any device that you use to login to the website.  If you don't login views and tracks that you create are only stored locally using cookies and will not be available if you disable/clear cookies or use another computer."><img src="<%=imagesDir%>icons/info.gif"></span></span></TD>
                    	</TR>
                    <%}%>
                    <TR>
                    	<TD style="vertical-align:middle">
                        <span class="control<%=level%>" style="display:inline-block;" id="addView<%=level%>" ><img src="<%=imagesDir%>icons/add_flat.png" style="position:relative;top:-3px;left:-2px;"></span>
                        <span class="control<%=level%>" style="display:inline-block;" id="copyView<%=level%>" ><img src="<%=imagesDir%>icons/copy_flat.png" style="position:relative;top:-3px;left:-2px;"></span>
                        <span class="control<%=level%>" style="display:inline-block;" id="saveView<%=level%>" ><img src="<%=imagesDir%>icons/save_flat.png" style="position:relative;top:-3px;left:-2px;"></span>
                        <!--<span class="control" style="display:inline-block;height:38px;"><img src="<%=imagesDir%>icons/disk.png"></span>-->
                        <span class="control<%=level%>" style="display:inline-block;" id="deleteView<%=level%>"  ><img src="<%=imagesDir%>icons/del_flat_48.png" style="position:relative;top:-3px;left:-2px;"></span>
                        
                        <span style="float:right;position:relative;top:-5px;"><a class="fancybox" rel="fancybox-thumbview" href="web/GeneCentric/help2.jpg" title="Controls to select and edit views."><img src="<%=imagesDir%>icons/help.png" /></a></span>
                        <span id="topcontrolInfo<%=level%>" style="float:right;position:relative;top:20px;"></span>
                        </TD>
                        
                    </TR>
                    <TR>
                    <TD>
					View types:
                            <select name="viewTypeSelect" class="viewTypeSelect" id="viewTypeSelect<%=level%>">
                            	<option value="all" selected="selected">All Views</option>
                            	<option value="predefined" >Predefined Views</option>
                         		<!--<option value="genome" >Predefined Genome Views</option>
                                <option value="trxome" >Predefined Transcriptome Views</option>
                                <option value="function">Predefined Functional Views</option>-->
                                <option value="custom" >Custom Views</option>
                            </select>
                            <span class="applyView<%=level%> button" style="float:right;">Apply View</span>
                    </TD>
                    </TR>
                    <TR>
                    <TD style=" vertical-align:top;">
                    Select a view below (click apply to display the view and return to the browser):
                    <select id="viewSelect<%=level%>" size="8" style="width:100%;">
                    </select>
                    </TD>
                    </TR>
                   
                    <TR>
                    <TD>
                    	<div style="font-size:16px; font-weight:bold; background-color:#FFFFFF; color:#000000; text-align:left; width:100%; padding-top:3px;">
                            <span class="viewDetailTab<%=level%> selected" id="viewdescOuter<%=level%>" >Description/Preview</span>
                            <!--<span class="viewDetailTab<%=level%>" id="viewpreviewOuter<%=level%>" >Preview</span>-->
                            <span class="viewDetailTab<%=level%>" id="viewtrackOuter<%=level%>" >View/Edit Track List</span>
                            
                            </div>
                         <div id="descOuter<%=level%>" style="border-color:#DEDEDE;border:solid;border-width: 2px 1px 1px 1px; font-size:16px;width:98%; text-align:left;">
                            <div id="descContent" style="margin:5px 5px 5px 5px;width:98%;">
                            	Select a view above to see details.  Click Apply to change the browser view to the selected view.
                            </div>
                            <H2>Preview</h2>
                            <div id="previewOuter<%=level%>" style="overflow:auto;border-color:#DEDEDE;border:solid;border-width: 2px 1px 1px 1px;font-size:16px;width:100%;text-align:left;">
                                <div id="previewContent" style="margin:5px 5px 5px 5px;width:98%;"></div>
                            </div>
                         </div>
                         <!--<div id="previewOuter<%=level%>" style="height:500px;display:none;border-color:#DEDEDE;border:solid;border-width: 2px 1px 1px 1px;font-size:16px;width:100%;text-align:left;">
                         	<div id="previewContent" style="margin:5px 5px 5px 5px;width:98%;">
                            	
                            </div>
                         </div>-->
                         <div id="trackOuter<%=level%>" style="height:500px; overflow:auto;display:none;border-color:#DEDEDE;border:solid;border-width: 2px 1px 1px 1px;font-size:16px;width:98%;">
                         	<div>
                            	<span class="control<%=level%>" id="addTrack<%=level%>" style="display:inline-block;"><img src="<%=imagesDir%>icons/add_track_flat.png"></span>
                        		<span id="controlInfo<%=level%>" style="float:right;position:relative;top:20px;"></span>
                            </div>
                         	<div id="trackContent" style="margin:5px 5px 5px 5px;width:98%;text-align:left;">
                            	<table id="trackListTbl<%=level%>" class="list_base" style="width:100%" col>
                                	<thead>
                                        <TR class="col_title" style="text-align:left;">
                                            <TH >Order</TH>
                                            <TH >Track Name</TH>
                                            <TH >Organism</TH>
                                            <TH >Edit</TH>
                                        </TR>
                                    </thead>
                                    <tbody>
                                    	
                                    </tbody>
                                </table>
                            </div>
                         </div>
                    </TD>
                    </TR>
                    <TR>
                    <TD>
                    	 <span class="applyView<%=level%> button" style="float:right;">Apply View</span>
                    </TD>
                    </TR>
               </table>   
                   
           </div>
           <div id="nameView<%=level%>" style="width:100%;display:none;border:solid; border-color:#000000; border-width:1px 1px 1px 1px;text-align:left;">
           		<div id="predefinedSaveAs<%=level%>" style="display:none;">
                	The modified view is a predefined view and cannot be saved, but you can save the modified view as a new track.  Complete the form below to save the modified view.
                </div>
            <form method="post" 
                action="createBrowserViews.jsp"
                enctype="application/x-www-form-urlencoded"
                name="createViewForm" id="createViewForm">
                View Name: <input type="text" name="viewNameTxt" id="viewNameTxt<%=level%>" size="30" value=""><BR />
                View Description:<BR /><textarea rows="5" cols="65" name="viewDescTxt" id="viewDescTxt<%=level%>" ></textarea>
                <div id="createViewBtn<%=level%>">
                        <span style="float:left;">
                        <input type="button" name="cancelCreateView" id="cancelCreateView<%=level%>" value="Cancel" onClick="return viewMenu[<%=level%>].cancelView()">
                        </span>
                        <span style="float:right;">
                        <input type="button" name="createView" id="createView<%=level%>" value="Create View" onClick="return viewMenu[<%=level%>].createNewView(<%=level%>)">
                        </span>
                        <input type="hidden" id="createType<%=level%>" value="blank" />
                       	<input type="hidden" id="function<%=level%>" value="create" />
               </div>
           </form>
        </div>
        <div id="confirmDeleteView<%=level%>" style="width:100%;display:none;border:solid; border-color:#000000; border-width:1px 1px 1px 1px;text-align:left;">
          	Are you sure you would like to delete the following view?<BR />
            <BR />
            <span id="deleteViewName<%=level%>">
            
            </span>
            
				<BR /><BR />
                        <span style="float:left; padding-bottom:5px;">
                        <input type="button" id="cancelDeleteView<%=level%>" value="No" onClick="return viewMenu[<%=level%>].cancelDeleteView(<%=level%>)">
                        </span>
                        <span style="float:right;padding-bottom:5px;">
                        <input type="button" name="createView" id="createView<%=level%>" value="Yes" onClick="return viewMenu[<%=level%>].deleteView(<%=level%>)">
                        </span>
                        <BR />
                        <BR />
                       
       </div>

</div>

<script type="text/javascript">
        viewMenu[<%=level%>]=ViewMenu(<%=level%>);
        $(".viewtooltip<%=level%>").tooltipster({
                position: 'top-right',
                maxWidth: 250,
                offsetX: 10,
                offsetY: 5,
                contentAsHTML:true,
                //arrow: false,
                interactive: true,
                interactiveTolerance: 350
        });

        $(".viewDetailTab<%=level%>").on("click", function(){
                                var oldID=new String($('.viewDetailTab<%=level%>.selected').attr("id"));
                                $("#"+oldID.substr(4)).hide();
                                $('.viewDetailTab<%=level%>.selected').removeClass("selected");
                                $(this).addClass("selected");
                                var id=new String($(this).attr("id"));
                                $("#"+id.substr(4)).show();
        });
</script>