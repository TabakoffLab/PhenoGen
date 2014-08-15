<%@ include file="/web/common/anon_session_vars.jsp" %>


<%
	int level=0;
	String myOrganism="Rn";
	if(request.getParameter("level")!=null){
		level=Integer.parseInt(request.getParameter("level"));
	}
	
	if(request.getParameter("organism")!=null){
		myOrganism=request.getParameter("organism");
	}
%>


<style>
	.ui-accordion .ui-accordion-content {
		padding:1em 0.5em;
	}
	.rightSearch{
		float:right;
		position:relative;
		top:-4px;
	}
</style>

    <div class="trackLevel<%=level%>"  style="display:none;width:600px;border:solid;border-color:#000000;border-width:1px; z-index:999; position:absolute; top:0px; left:0px; background-color:#FFFFFF; min-height:780px; text-align:center;">
        	<div style="display:block;width:100%;color:#000000; text-align:left; background:#EEEEEE; font-weight:bold;height:23px;"><span style="position:relative;top:3px;">Select a Track to add to <span id="selectedViewName"></span></span><span class="closeBtn" id="close_trackLevel<%=level%>" style="position:relative;top:2px; float:right;"><img src="<%=imagesDir%>icons/close.png"></span>
            </div>
        	<table style="width:98%;">
                	<%if(loggedIn&&userLoggedIn.getUser_name().equals("anon")){%>
                    	<TR>
                    		<TD><span style="font-weight:bold;color:#000000;">Sign in to see tracks not saved to this computer. (Any tracks created will only be saved locally)  <span class="viewtooltip<%=level%>" title="If you sign in views and tracks are saved to the server so that you may use them on any computer that you use to login to the website.  If you don't login views and tracks are stored locally using cookies and will not be available if you disable/clear cookies or use another computer."><img src="<%=imagesDir%>icons/info.gif"></span></span></TD>
                    	</TR>
                    <%}%>
                    <TR>
                    	<TD style="vertical-align:middle">
                            <span class="control<%=level%>" style="display:inline-block;" title="Create a new custom track."><img src="<%=imagesDir%>icons/add_flat.png" ></span>
                            <span class="addTrack<%=level%> button" style="float:right;">Add Track</span>
                        </TD>
                        
                    </TR>
                    <TR>
                    	<TD style="width:100%;" >
                           <div style="font-size:16px;width:100%; text-align:left;background:#EEEEEE;">Available Tracks:</div>
                        </TD>
                    </TR>
                    <TR>
                    <TD>
						View types:
                            <select name="trackTypeSelect" class="trackTypeSelect" id="trackTypeSelect<%=level%>">
                            	<option value="all">All Tracks</option>
                            	<option value="allpublic" selected="selected">All Public Tracks</option>
                                <option value="custom" >All Custom Tracks</option>
                         		<option value="genome" >  Genomic Tracks</option>
                                <option value="trxome" >  Transcriptome Tracks</option>
                            </select>
                            
                    </TD>
                    </TR>
                    <TR>
                    <TD style=" vertical-align:top;">
                    	<div id="trkSelList<%=level%>"  style="margin:5px 5px 5px 5px;width:585px;text-align:left;position:relative;top:-23px;">
                            	<table id="trkSelList<%=level%>" class="trkSelList list_base" style="width:100%">
                                	<thead>
                                        <TR class="col_title" style="text-align:left;">
                                            <TH >Track Name</TH>
                                            <TH >Organism</TH>
                                            <TH >Genome / Transcriptome</TH>
                                            <TH >Category</TH>
                                            <TH> Public / Custom</TH>
                                        </TR>
                                    </thead>
                                    <tbody>
                                    	
                                    </tbody>
                                </table>
                            </div>
                    </TD>
                    </TR>
                   
                    <TR >
                    <TD id="selectedTrack<%=level%>" style="display:none;position:relative;top:-15px;">
                         <div id="trackHeaderOuter<%=level%>" style="font-size:16px;width:100%; text-align:left;background:#EEEEEE;">
                         	<div id="trackHeaderContent" style="margin:5px 5px 5px 5px;width:100%;">
                            </div>
                         </div>
                         
                         <div id="trackOuter<%=level%>" style="font-size:16px;width:98%;">
                         	Track Settings:
                         	<div id="trackContent" style="margin:5px 5px 5px 5px;width:98%;text-align:left;margin-left:10px;">
                            	<table id="trackListTbl<%=level%>" style="width:98%;">
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                         </div>
                         <div id="trackPreviewOuter<%=level%>" style="font-size:16px;width:98%;text-align:left;">
                         	Preview:
                         	<div id="trackPreviewContent" style="margin:5px 5px 5px 5px;width:100%;">
                            	
                            </div>
                         </div>
                    </TD>
                    </TR>
                    <TR>
                    <TD>
                    	 <span class="addTrack<%=level%> button" style="float:right;">Add Track</span>
                    </TD>
                    </TR>
               </table>   
                   
                </div>
            </div>
            </div>
            
            
	</div>
    
    <script type="text/javascript">
		$("span.addTrack<%=level%>").on("click",function(){
			viewMenu[<%=level%>].addTrackToView(trackMenu[<%=level%>].findSelectedTrack());
			trackMenu[<%=level%>].removeTrack(trackMenu[<%=level%>].findSelectedTrack());
		});
		$("#trackTypeSelect<%=level%>").on("change",function(){
			trackMenu[<%=level%>].generateTrackTable();
		});
	</script>