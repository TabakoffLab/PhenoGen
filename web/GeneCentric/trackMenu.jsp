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
	/*.rightSearch{
		float:right;
		position:relative;
		top:-4px;
	}*/
</style>

    <div class="trackLevel<%=level%>"  style="display:none;width:600px;border:solid;border-color:#000000;border-width:1px; z-index:999; position:absolute; top:0px; left:0px; background-color:#FFFFFF; min-height:450px;  text-align:center;">
        	<div style="display:block;width:100%;color:#000000; text-align:left; background:#EEEEEE; font-weight:bold;height:23px;"><span style="position:relative;top:3px;">Select a Track to add to <span id="selectedViewName"></span></span><span class="closeBtn" id="close_trackLevel<%=level%>" style="position:relative;top:2px; float:right;"><img src="<%=imagesDir%>icons/close.png"></span>
            </div>
            <div id="selectTrack<%=level%>">
        	<table style="width:98%;">
                	<%if(loggedIn&&userLoggedIn.getUser_name().equals("anon")){
						limitation="<li>Since you are not logged in track information is currently saved to cookies and thus are not portable between computers.  If you register/login tracks can be saved to the database allowing portability and prevent loss if cookies are cleared.</li>";
						%>
                    	<TR>
                    		<TD><img src="<%=imagesDir%>icons/alert_24.png"><span style="font-weight:bold;color:#000000;position:relative;top:-7px;">Sign in to see tracks not saved to this computer. (Any tracks created will only be saved locally)  <span class="tracktooltip<%=level%>" title="If you sign in views and tracks are saved to the server so that you may use them on any device as long as you login to the website.  If you don't login views and tracks are stored locally using cookies and will not be available if you disable/clear cookies or use another computer."><img src="<%=imagesDir%>icons/info.gif"></span></span></TD>
                    	</TR>
                    <%}%>
                    <TR>
                    	<TD style="vertical-align:middle">
                            <span class="control<%=level%>" style="float:left;display:inline-block;" id="addCustomTrack<%=level%>" title="Create a new custom track."><img src="<%=imagesDir%>icons/add_flat.png"style="position:relative;top:-3px;left:-2px;" ></span>
                            <span class="control<%=level%>" style="display:inline-block;" id="deleteCustomTrack<%=level%>" title="Delete a custom track."><img src="<%=imagesDir%>icons/del_flat_48.png"style="position:relative;top:-3px;left:-2px;" ></span>
                            <span style="float:right;position:relative;top:0px;"><a class="fancybox" rel="fancybox-thumbtrack" href="web/GeneCentric/help3.jpg" title="Controls to select and edit tracks."><img src="<%=imagesDir%>icons/help.png" /></a></span>
                            <span class="addTrack<%=level%> button" style="float:right; position:relative; top:25px;left:15;">Add Track</span>
                            
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
                            	<option value="all" selected="selected">All Tracks</option>
                            	<option value="allpublic" >All Public Tracks</option>
                                <option value="custom" >All Custom Tracks</option>
                         		<option value="genome" >  Genome Tracks</option>
                                <option value="trxome" >  Transcriptome Tracks</option>
                            </select>
                            
                    </TD>
                    </TR>
                    <TR>
                    <TD style=" vertical-align:top;">
                    	<div id="trkSelList<%=level%>"  style="margin:5px 5px 5px 5px;width:585px;text-align:left;/*position:relative;top:-23px;*/">
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
                           <div class="notSignedIn" id="notSignedIn1" style="display:none;">You are not signed in.  If you were signed in when you created custom tracks you must sign in to view them.  If you don't have a login and you created a custom track you must be on the same computer where you created the track and cookies must be enable and must not have been cleared since you created the track.  Otherwise you will have to create the track again.</div>
                           <BR />
                           <div id="noCustomTracks" style="display:none;">If you have created custom tracks you may not have been logged in so the tracks were saved locally to a cookie.  If cookies are enabled and have not been cleared the custom tracks should have still appeared here, so you may have to reload them.  We highly recommend creating an account to use custom tracks to help avoid loss of custom tracks.  When you are signed in track data is saved to the server and available anywhere you sign in.</div>
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
                                    <option value="bb" >.BigBed (remotely hosted large sizes supported)</option>
                                    <option value="bw" >.BigWig (remotely hosted large sizes supported)</option>
                                </select>
                                <span class="tracktooltip<%=level%>" title="We support of number of standard <a href=&quot;http://genome.ucsc.edu/&quot; target=&quot_blank;&quot;>UCSC Genome Browser</a> file types(file format info is available <a href=&quot;http://genome.ucsc.edu/FAQ/FAQformat.html#format1&quot; target=&quot_blank;&quot;>here</a>).  Part of these file types are supported by the utillities the <a href=&quot;http://genome.ucsc.edu/&quot; target=&quot_blank;&quot;>UCSC Genome Browser</a> maintains and has made available.<BR><BR>If you run into the size limit on the .bed or .bedGraph files, you can use the UCSC Genome Browser Utilities available <a href=&quot;http://hgdownload.cse.ucsc.edu/admin/exe/&quot; target=&quot_blank;&quot;>here</a> to convert them to either .bigBed or .bigWig files which can be hosted remotely and the browser will load relevant data on demand."><img src="<%=imagesDir%>icons/info.gif"></span>
                        <BR /><BR />
                        
                        <div id="uploadSelection<%=level%>" style="display:inline-block;">
                        	<span id="uploadLbl<%=level%>">BED File:</span><input type="file" id="customUploadFile<%=level%>">
                        </div>
                        <div id="remoteSelection<%=level%>" style="display:none;">
                        	<span id="remoteURLLbl<%=level%>">File URL:</span><input type="text" id="customFileURL<%=level%>" size="60">
                            <BR />
                            Example: http://phenogen.ucdenver.edu/path/to/your/file<BR />
                            or
                            http://username:password@something.edu/path/to/your/file<BR />
                            
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
                            Gradient(min-max):<input type="Color" class="color" id="usrtrkColorMin<%=level%>" size="5" value="#FFFFFF"> - <input type="Color" class="color" id="usrtrkColorMax<%=level%>" size="5" value="#000000">
                            <BR />
                            *Data outside this range will be assigned to the corresponding min or max color.<BR /><BR />
                        </div>
  						
                        <div style="width:100%;">
                        	<div id="uploadBtn<%=level%>">
                            	<span style="float:left;">
                        		<input type="button" name="cancelCreateTrack" id="cancelCreateTrack<%=level%>" value="Cancel" >
                                </span>
                            	<span style="float:right;">
                            	<input type="button" name="uploadTrack" id="uploadTrack<%=level%>" value="Create Track" onClick="return trackMenu[<%=level%>].confirmUpload(<%=level%>)">
                                </span>
                            </div>
                            <div id="confirmUpload<%=level%>" style="display:none;border:solid; border-color:#000000; border-width:2px 2px 2px 2px;">
                            <ul style="list-style-type:circle;margin-left:20px;">
                            	<li>Please Confirm that this track is for <B><%if(myOrganism.equals("Rn")){%>Rat<%}else{%>Mouse<%}%></B> and has coordinates for <B><%if(myOrganism.equals("Rn")){%>rn5<%}else{%>mm10<%}%></B>.  Coordinates must match this genome version, as coordinates <B>will not</B> be converted.</li><BR /><BR />
                                <li id="uploadDataConf" >Please acknowledge that this is not a repository for the browser/track data.  <B>There is no way for you to retreive any files you upload so please keep a copy of your data in a safe location with a backup.</B>  Track files older than a year not associated with an active account may eventually be removed to make space for active users.</li>
                                <li id="remoteDataConf" style="display:none;">Please acknowledge that your data must continue to be available at the URL specified above.   Partial data files are only temporarily saved on PhenoGen.  <B>There is no way for you to retreive any of this data from PhenoGen other than through the browser, so please keep a copy of your data in a safe location with a backup.</B> </li>
                                </ul>
                                <BR /><BR />
                                <input type="button" name="confirmuploadTrack" id="confirmuploadTrack<%=level%>" value="Continue" onClick="return trackMenu[<%=level%>].createCustomTrack(<%=level%>)">
                                <input type="button" name="canceluploadTrack" id="canceluploadTrack<%=level%>" value="Cancel" onClick="return trackMenu[<%=level%>].cancelUpload(<%=level%>)">
                            </div>
                            <div id="confirmBed<%=level%>" style="display:none;">
                            	This file is missing a .<span class="fileType">bed</span> extension.  Is this a .<span class="fileType">bed</span> file fitting the standard format(<a href="http://genome.ucsc.edu/FAQ/FAQformat.html#format1" target="_blank">UCSC Genome <span class="fileTypeLong">BED</span> Format</a>)?<BR /><BR />
                                <input type="button" name="confirmbedTrack" id="confirmbedTrack<%=level%>" value="Yes/Continue" onClick="return trackMenu[<%=level%>].confirmBed(<%=level%>)">
                                <input type="button" name="cancelbedTrack" id="cancelbedTrack<%=level%>" value="No/Cancel" onClick="return trackMenu[<%=level%>].cancelUpload(<%=level%>)">
                                <input type="hidden" id="hasconfirmBed<%=level%>" value="0" />
                            </div>
                        	<div class="progressInd" style="display:none;">
                        		<progress></progress>
                        	</div>
                            <div class="uploadStatus"></div>
                            <div id="finished<%=level%>" style="display:none;float:right;">
                                <input type="button" name="addAnother" id="addAnother<%=level%>" value="Create a New Track" onClick="return createNew()">
                                <input type="button" name="done" id="done<%=level%>" value="Done" onClick="return done()">
                            </div>
          </div>
           
	</div>
    <div id="deleteUsrTrack<%=level%>" style="width:100%;display:none;border:solid; border-color:#000000; border-width:1px 1px 1px 1px;text-align:left;">
           		<span>Deleting the track will automatically remove it from any view and it will no longer be avaialble.  Are you sure you want to delete the following custom track?</span>
                <BR /><BR />
                <span id="customTrackInfo<%=level%>"></span>
                <BR /><BR />
                        <span style="float:left; padding-bottom:5px;">
                        <input type="button" id="cancelDeleteTrack<%=level%>" value="No" onClick="return trackMenu[<%=level%>].cancelDeleteTrack(<%=level%>)">
                        </span>
                        <span style="float:right;padding-bottom:5px;">
                        <input type="button"  id="deleteTrack<%=level%>" value="Yes" onClick="return trackMenu[<%=level%>].deleteTrack(<%=level%>)">
                        </span>
                        <BR />
                        <BR />
           </div>

    <script type="text/javascript">
		trackMenu[<%=level%>]=TrackMenu(<%=level%>);
		$("span#deleteCustomTrack<%=level%>").hide();
                $("#cancelCreateTrack<%=level%>").on("click",function(){
                    $("div#selectTrack<%=level%>").show();
                    $("div#addUsrTrack<%=level%>").hide();
                });
		$("span.addTrack<%=level%>").on("click",function(){
                    if(!trackMenu[<%=level%>].standalone){
			var tmpTrack=trackMenu[<%=level%>].findSelectedTrack();
			tmpTrack.Settings=trackMenu[<%=level%>].previewSVG.getTrack(tmpTrack.TrackClass).generateTrackSettingString();
			tmpTrack.Settings=tmpTrack.Settings.substr(tmpTrack.Settings.indexOf(",")+1);
			viewMenu[<%=level%>].addTrackToView(tmpTrack);
			trackMenu[<%=level%>].removeTrack(tmpTrack);
                        $("td#selectedTrack<%=level%> table tbody tr").remove();
                    }else{
                        var tmpTrack=trackMenu[<%=level%>].findSelectedTrack();
                        trackMenu[<%=level%>].previewSVG.getTrack(tmpTrack.TrackClass).updateSettingsFromUI();
			tmpTrack.Settings=trackMenu[<%=level%>].previewSVG.getTrack(tmpTrack.TrackClass).generateTrackSettingString();
			tmpTrack.Settings=tmpTrack.Settings.substr(tmpTrack.Settings.indexOf(",")+1);
                        console.log(tmpTrack.Settings);
                        var tmp=tmpTrack.Settings.replace(/;/g,"");
                        var tmp2=tmp.split(",");
                        var additional="";
                        if(tmpTrack.Settings.indexOf(",")>-1){
                            additional=tmpTrack.Settings.substr(tmpTrack.Settings.indexOf(",")+1);
                        }
                        var id=svgList[<%=level%>].currentView.ViewID;
			viewMenu[<%=level%>].addTrackToViewWithID(id,tmpTrack);
                        
                        svgList[<%=level%>].addTrack(tmpTrack.TrackClass,tmp2[0],additional,0);
                        $(".trackLevel<%=level%>").fadeOut("fast");
                        $("td#selectedTrack<%=level%> table tbody tr").remove();
                    }
		});
		$("span#deleteCustomTrack<%=level%>").on("click",function(){
			trackMenu[<%=level%>].confirmdeleteCustomTrack();
		});
		$("#trackTypeSelect<%=level%>").on("change",function(){
			trackMenu[<%=level%>].generateTrackTable();
		});
		$("#usrtrkFileTypeSelect<%=level%>").on("change",function(){
			var fileType=$("#usrtrkFileTypeSelect<%=level%>").val();
			if(fileType=="bed"){
				$("#uploadLbl<%=level%>").html("Bed File:");
				$("#uploadSelection<%=level%>").show();
				$("#remoteSelection<%=level%>").hide();
				$("#uploadDataConf").show();
				$("#remoteDataConf").hide();
				$("span.fileType").html("bed");
				$("span.fileTypeLong").html("Bed");
			}else if(fileType=="bg"){
				$("#uploadLbl<%=level%>").html("BedGraph File:");
				$("#uploadSelection<%=level%>").show();
				$("#remoteSelection<%=level%>").hide();
				$("#uploadDataConf").show();
				$("#remoteDataConf").hide();
				$("span.fileType").html("bg");
				$("span.fileTypeLong").html("BedGraph");
			}else if(fileType=="bb"){
				$("#remoteURLLbl<%=level%>").html("BigBed URL:");
				$("#uploadSelection<%=level%>").hide();
				$("#remoteSelection<%=level%>").show();
				$("#uploadDataConf").hide();
				$("#remoteDataConf").show();
				$("span.fileType").html("bb");
				$("span.fileTypeLong").html("BigBed");
			}else if(fileType=="bw"){
				$("#remoteURLLbl<%=level%>").html("BigWig URL:");
				$("#uploadSelection<%=level%>").hide();
				$("#remoteSelection<%=level%>").show();
				$("#uploadDataConf").hide();
				$("#remoteDataConf").show();
				$("span.fileType").html("bw");
				$("span.fileTypeLong").html("BigWig");
			}
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
			
		function cancel(){
			$("div#selectTrack<%=level%>").show();
			$("div#addUsrTrack<%=level%>").hide();
		}
		
		function done(){
			$("div#uploadBtn<%=level%>").show();
			$(".progressInd").hide();
			$(".uploadStatus").hide();
			$("#finished<%=level%>").hide();
			//saveToCookie(customTrackLevel);
			$("div#addUsrTrack<%=level%>").hide();
			$("div#selectTrack<%=level%>").show();
		}
		function createNew(){
			$("div#uploadBtn<%=level%>").show();
			$(".progressInd").hide();
			$(".uploadStatus").hide();
			$("#finished<%=level%>").hide();
		}
		
		
		if(testIE||testSafari){//Change for IE and Safari
			$("#usrtrkColorMin<%=level%>").spectrum();
			$("#usrtrkColorMax<%=level%>").spectrum();
		}
		
		
	</script>