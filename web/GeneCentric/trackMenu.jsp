<%@ include file="/web/common/anon_session_vars.jsp" %>


<%
	int level=0;
	String myOrganism="Rn";
	String limitation="";
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
            <div id="selectTrack<%=level%>">
        	<table style="width:98%;">
                	<%if(loggedIn&&userLoggedIn.getUser_name().equals("anon")){
						limitation="<li>Since you are not logged in track information is currently saved to cookies and thus are not portable between computers.  If you register/login tracks can be saved to the database allowing portability and prevent loss if cookies are cleared.</li>";
						%>
                    	<TR>
                    		<TD><span style="font-weight:bold;color:#000000;">Sign in to see tracks not saved to this computer. (Any tracks created will only be saved locally)  <span class="tracktooltip<%=level%>" title="If you sign in views and tracks are saved to the server so that you may use them on any computer that you use to login to the website.  If you don't login views and tracks are stored locally using cookies and will not be available if you disable/clear cookies or use another computer."><img src="<%=imagesDir%>icons/info.gif"></span></span></TD>
                    	</TR>
                    <%}%>
                    <TR>
                    	<TD style="vertical-align:middle">
                            <span class="control<%=level%>" style="display:inline-block;" id="addCustomTrack<%=level%>" title="Create a new custom track."><img src="<%=imagesDir%>icons/add_flat.png" ></span>
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


            
            <div id="addUsrTrack<%=level%>" style="width:100%;display:none;border:solid; border-color:#000000; border-width:1px 1px 1px 1px;text-align:left;">
            		<H2>Create Custom Track<span class="tracktooltip<%=level%>" id="UserDefTrkInfoDesc<%=level%>" title="Use the form in this section to create your own track with your own data. Please note the limitations listed below. <BR><BR><div style='text-align:left;'><B>Current Limitations:</B><ol><%=limitation%><li>Tracks are currently limited to bed, bedGraph, bigBed, and bigWig files.  Support is coming soon for additional files.</li><li>Uploaded Files(bed,bedGraph) are limited to 20MB.  Convert larger files to bigBed or bigWig files and host them on your own web server.</li></ol></div>"><img src="<%=imagesDir%>icons/info.gif"></span></H2>
                    	Track Name:<input type="text" name="usrtrkNameTxt" id="usrtrkNameTxt<%=level%>" size="50" value="">
                        <BR /><BR />
                        Track Description:
                        <BR /><textarea rows="5" cols="65" name="usrtrkDescTxt" id="usrtrkDescTxt<%=level%>" ></textarea>
                        <BR /><BR />
                         Organism:<select name="usrtrkOrg" class="usrtrkOrg" id="usrtrkOrgSelect<%=level%>">
                                    <option value="Rn" >Rat (Rn5)</option>
                                    <option value="Mm" >Mouse (Mm10)</option>
                                </select>
                        <BR /><BR />
                        Generic Category:<select name="usrtrkGenCat" class="usrtrkGenCat" id="usrtrkGenCatSelect<%=level%>">
                                    <option value="Genome" >Genome</option>
                                    <option value="Transcriptome" >Transcriptome</option>
                                    <option value="Other" >Other</option>
                                </select>
                        <BR /><BR />
                        Specific Category: <input type="text" name="usrtrkCatTxt" id="usrtrkCatTxt<%=level%>" size="20" value="">
                        <BR /><BR />
                        File Type: <select name="usrtrkFileType" class="usrtrkFileType" id="usrtrkFileTypeSelect<%=level%>">
                                    <option value="bed" >.Bed (<20MB uploaded)</option>
                                    <option value="bg" >.BedGraph (<20MB uploaded)</option>
                                    <option value="bb" >.BigBed (remotely hosted GB sizes supported)</option>
                                    <option value="bw" >.BigWig (remotely hosted GB sizes supported)</option>
                                </select>
                        <BR /><BR />
                        <div id="uploadSelection<%=level%>" style="display:inline-block;">
                        	BED File:<input type="file" id="customUploadFile<%=level%>">
                        </div>
                        <div id="remoteSelection<%=level%>" style="display:none;">
                        	File URL:<input type="text" id="customFileURL<%=level%>">
                        </div>
                        <BR /><BR />
                        Color Track by:<select name="usrtrkColor" class="usrtrkColor" id="usrtrkColorSelect<%=level%>">
                                    <option value="Score" >Score based scale</option>
                                    <option value="Color" selected="selected">Feature defined</option>
                                </select>
                        <BR /><BR />
                        <div id="usrtrkGrad<%=level%>" style="display:none;">
                        	Scale Definition:<BR />
                        	Data(min-max)*:<input type="text" name="usrtrkScoreMinTxt" id="usrtrkScoreMinTxt<%=level%>" size="5" value="0"> - <input type="text" name="usrtrkScoreMaxTxt" id="usrtrkScoreMaxTxt<%=level%>" size="5" value="1000">
                            <BR />
                            Gradient(min-max):<input class="color" id="usrtrkColorMin<%=level%>" size="5" value="#FFFFFF"> - <input class="color" id="usrtrkColorMax<%=level%>" size="5" value="#000000">
                            <BR />
                            *Data outside this range will be assigned to the corresponding min or max color.<BR /><BR />
                        </div>
  						
                        <div style="width:100%;">
                        	<div id="uploadBtn<%=level%>">
                            	<span style="float:left;">
                        		<input type="button" name="cancelCreateTrack" id="cancelCreateTrack<%=level%>" value="Cancel" onClick="return cancel(<%=level%>">
                                </span>
                            	<span style="float:right;">
                            	<input type="button" name="uploadTrack" id="uploadTrack<%=level%>" value="Create Track" onClick="return confirmUpload(<%=level%>)">
                                </span>
                            </div>
                            <div id="confirmUpload<%=level%>" style="display:none;">
                            	Please Confirm that this track is for <B><%if(myOrganism.equals("Rn")){%>Rat<%}else{%>Mouse<%}%></B> and has coordinates for <B><%if(myOrganism.equals("Rn")){%>rn5<%}else{%>mm10<%}%></B>.  Coordinates must match this genome version, coordinates <B>will not</B> be converted.<BR /><BR />
                                <input type="button" name="confirmuploadTrack" id="confirmuploadTrack<%=level%>" value="Continue" onClick="return createCustomTrack(<%=level%>)">
                                <input type="button" name="canceluploadTrack" id="canceluploadTrack<%=level%>" value="Cancel" onClick="return cancelUpload(<%=level%>)">
                            </div>
                            <div id="confirmBed<%=level%>" style="display:none;">
                            	This file is missing a .bed extension.  Is this a .bed file fitting the standard format(<a href="http://genome.ucsc.edu/FAQ/FAQformat.html#format1" target="_blank">UCSC Genome BED Format</a>)?<BR /><BR />
                                <input type="button" name="confirmbedTrack" id="confirmbedTrack<%=level%>" value="Yes/Continue" onClick="return confirmBed(<%=level%>)">
                                <input type="button" name="cancelbedTrack" id="cancelbedTrack<%=level%>" value="No/Cancel" onClick="return cancelUpload(<%=level%>)">
                                <input type="hidden" id="hasconfirmBed<%=level%>" value="0" />
                            </div>
                        	<div class="progressInd" style="display:none;">
                        		<progress></progress>
                        	</div>
                            <div class="uploadStatus"></div>
          </div>
            
	</div>
    <script type="text/javascript" src="<%=mainURL.substring(0,mainURL.length()-10)%>/javascript/jscolor/jscolor.js"></script>
    <script type="text/javascript">
		$("span.addTrack<%=level%>").on("click",function(){
			viewMenu[<%=level%>].addTrackToView(trackMenu[<%=level%>].findSelectedTrack());
			trackMenu[<%=level%>].removeTrack(trackMenu[<%=level%>].findSelectedTrack());
		});
		$("#trackTypeSelect<%=level%>").on("change",function(){
			trackMenu[<%=level%>].generateTrackTable();
		});
		$("span#addCustomTrack<%=level%>").on("click",function(){
			$("div#selectTrack<%=level%>").hide();
			$("div#addUsrTrack<%=level%>").show();
		});
		$(".tracktooltip<%=level%>").tooltipster({
					position: 'top-right',
					maxWidth: 250,
					offsetX: 10,
					offsetY: 5,
					contentAsHTML:true,
					//arrow: false,
					interactive: true,
					interactiveTolerance: 350
				});
				
		$("#usrtrkColorSelect<%=level%>").on("change",function(){
				if($("#usrtrkColorSelect<%=level%>").val()=="Score"){
					$("div#usrtrkGrad<%=level%>").show();
				}else{
					$("div#usrtrkGrad<%=level%>").hide();
				}
			});
	</script>