<%@ include file="/web/common/session_vars.jsp" %>


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
        	<div style="display:block;width:100%;color:#000000; text-align:left; background:#EEEEEE; font-weight:bold;">Select/Edit Views<span class="closeBtn" id="close_viewsLevel<%=level%>" style="position:relative;top:2px;left:461px;"><img src="<%=imagesDir%>icons/close.png"></span></div>
        	<div id="toolbar<%=level%>">
            
            </div>
			<div id="selection<%=level%>" style=" text-align:left;">
                <table style="width:100%;">
                	<%if(loggedIn&&userLoggedIn.getUser_name().equals("anon")){%>
                    	<TR>
                    		<TD><span style="font-weight:bold;color:#000000;">Sign in to see views/tracks not saved to this computer.  <span class="viewtooltip<%=level%>" title="If you sign in views and tracks are saved to the server so that you may use them on any computer that you use to login to the website.  If you don't login views and tracks are stored locally using cookies and will not be available if you disable/clear cookies or use another computer."><img src="<%=imagesDir%>icons/info.gif"></span></span></TD>
                    	</TR>
                    <%}%>
                    <TR>
                    	<TD style="vertical-align:middle"><span style="height:38px;position:relative;top:-13;">View Controls:</span>
                        <span class="control<%=level%>" style="display:inline-block;position:relative;top:-3px;height:38px;width:36px;" title="Create a new view with no tracks."><img src="<%=imagesDir%>icons/createNew.png" style="position:relative;top:2px;left:2px;"></span>
                        <span class="control<%=level%>" style="display:inline-block;position:relative;top:-3px;height:38px;width:36px;" title="Create a new view copied from the selected view."><img src="<%=imagesDir%>icons/copy.png" style="position:relative;top:2px;left:2px;"></span>
                        <!--<span class="control" style="display:inline-block;height:38px;"><img src="<%=imagesDir%>icons/disk.png"></span>-->
                        <span class="control<%=level%>" style="display:inline-block;position:relative;top:-3px;height:38px;width:36px;" title="Delete the selected view."><img src="<%=imagesDir%>icons/delete_lg.png" style="position:relative;top:2px;left:2px;"></span>
                        </TD>
                        
                    </TR>
                    <TR>
                    <TD>
					View types:
                            <select name="viewTypeSelect" class="viewTypeSelect" id="viewTypeSelect<%=level%>">
                            	<option value="all">All Views</option>
                            	<option value="predefined" selected="selected">Predefined Views</option>
                         		<!--<option value="genome" >Predefined Genome Views</option>
                                <option value="trxome" >Predefined Transcriptome Views</option>
                                <option value="function">Predefined Functional Views</option>-->
                                <option value="custom" >Custom Views</option>
                            </select>
                            <span class="viewtooltip<%=level%>" title="Click apply to change the current view and return to the browser.  Want to cancel click the close button(<img src=&quot;<%=imagesDir%>icons/close.png&quot;>)"><span class="applyView button" style="float:right;">Apply</span></span>
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
                            <span class="viewDetailTab selected" id="viewdescOuter<%=level%>" >Description</span>
                            <span class="viewDetailTab" id="viewpreviewOuter<%=level%>" >Preview</span>
                            <span class="viewDetailTab" id="viewtrackOuter<%=level%>" >Track List</span>
                            
                            </div>
                         <div id="descOuter<%=level%>" style="height:500px; overflow:auto;border-color:#DEDEDE;border:solid;border-width: 2px 1px 1px 1px; font-size:16px;width:98%; text-align:left;">
                         	<div id="descContent" style="margin:5px 5px 5px 5px;width:98%;">
                            </div>
                         </div>
                         <div id="previewOuter<%=level%>" style="height:500px; overflow:auto;display:none;border-color:#DEDEDE;border:solid;border-width: 2px 1px 1px 1px;font-size:16px;width:98%;text-align:left;">
                         	<div id="previewContent" style="margin:5px 5px 5px 5px;width:98%;">
                            	
                            </div>
                         </div>
                         <div id="trackOuter<%=level%>" style="height:500px; overflow:auto;display:none;border-color:#DEDEDE;border:solid;border-width: 2px 1px 1px 1px;font-size:16px;width:98%;">
                         	<div>
                            	Track Controls:
                            	<span class="control<%=level%>" style="display:inline-block;position:relative;top:-3px;height:38px;width:36px;" title="Add a track to the current view."><img src="<%=imagesDir%>icons/createNew.png" style="position:relative;top:2px;left:2px;"></span>
                        		<span class="control<%=level%>" style="display:inline-block;height:38px;"  title="Save changes to the current view. Save track settings."><img src="<%=imagesDir%>icons/disk.png"></span>
                            </div>
                         	<div id="trackContent" style="margin:5px 5px 5px 5px;width:98%;text-align:left;">
                            	<table id="trackListTbl<%=level%>" class="list_base" style="width:100%">
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
                    	 <span class="viewtooltip<%=level%>" title="Click apply to change the current view and return to the browser.  Want to cancel click the close button(<img src=&quot;<%=imagesDir%>icons/close.png&quot;>)"><span class="applyView button" style="float:right;">Apply</span></span>
                    </TD>
                    </TR>
               </table>   
                   
                </div>
            </div>
            </div>
            
            
</div>

          <script type="text/javascript">
		  		viewMenu[<%=level%>]=ViewMenu(<%=level%>);
				var iconPath="<%=imagesDir%>icons/";
		  		
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
				$(".control<%=level%>").tooltipster({
					position: 'top-right',
					maxWidth: 250,
					offsetX: 10,
					offsetY: 5,
					//arrow: false,
					interactive: false
				});
				
				$(".viewDetailTab").on("click", function(){
							var oldID=new String($('.viewDetailTab.selected').attr("id"));
							$("#"+oldID.substr(4)).hide();
							$('.viewDetailTab.selected').removeClass("selected");
							$(this).addClass("selected");
							var id=new String($(this).attr("id"));
							$("#"+id.substr(4)).show();
				});
				
				$(".applyView").on("click", function(){
						var id=$("#viewSelect<%=level%>").val();
						viewMenu[<%=level%>].applyView(id);
				});
				
				
		  </script>