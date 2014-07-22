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
                         	<div id="trackContent" style="margin:5px 5px 5px 5px;width:98%;text-align:left;">
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
		  		var  viewList=[];
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
				
				
				$(".viewDetailTab").on("click", function(){
							var oldID=new String($('.viewDetailTab.selected').attr("id"));
							$("#"+oldID.substr(4)).hide();
							$('.viewDetailTab.selected').removeClass("selected");
							$(this).addClass("selected");
							var id=new String($(this).attr("id"));
							$("#"+id.substr(4)).show();
				});
				
				function getViewData(){
					var tmpContext=contextPath +"/"+ pathPrefix;
					if(pathPrefix==""){
						tmpContext="";
					}
					
					d3.json(tmpContext+"getBrowserViews.jsp",function (error,d){
						if(error){
							
						}else{
							viewList=d;
							var opt=d3.select("#viewSelect<%=level%>").on("change",selectChange).selectAll('option').data(d);
							opt.enter().append("option").attr("value",function(d){return d.ViewID;}).text(function(d){
									var ret=d.Name;
									if(d.UserID==0){
										ret=ret+"      (Predefined)";
									}else{
										ret=ret+"     (Custom)";
									}
									ret=ret+"     ("+d.TrackList.length+" tracks)";
									
									return ret;
								});
						}
					});
				}
				
				function selectChange(){
					var id=$("#viewSelect<%=level%>").val();
					var d=NaN;
					for(var i=0;i<viewList.length&&isNaN(d);i++){
						if(viewList[i].ViewID==id){
							d=viewList[i];
						}
					}
					$("#descContent").html(d.Description);
					generatePreview(d);
					generateTrackList(d);
				}
				
				function generatePreview(d){
					
				}
				function generateTrackList(d){
					var list="<OL style=&quot;text-align:left;&quot;>";
					for(var i=0;i<d.TrackList.length;i++){
						var species="";
						if(d.TrackList[i].Organism!="AA"){
							var shortOrg=d.TrackList[i].Organism;
							if(shortOrg=="RN"){
								shortOrg="Rat";
							}else if(shortOrg=="MM"){
								shortOrg="Mouse";
							}
							species="( "+shortOrg+" only )";
						}
						list=list+"<LI>"+d.TrackList[i].Name+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+species+"&nbsp;&nbsp;<span class=listtooltip<%=level%> title="+d.TrackList[i].Description+"><img src=<%=imagesDir%>icons/info.gif></span></LI>";
						
					}
					list=list+"</OL>";
					$("#trackContent").html(list);
					$(".listtooltip<%=level%>").tooltipster({
						position: 'top-right',
						maxWidth: 250,
						offsetX: 10,
						offsetY: 5,
						contentAsHTML:true,
						//arrow: false,
						interactive: true,
						interactiveTolerance: 350
					});
				}
				
				//setup data
				getViewData();
		  </script>