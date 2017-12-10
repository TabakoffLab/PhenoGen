<%
    gdt.setSession(session);
    String gene="";
        String heat="";
        String ident="";
        String rDataFile="'"+session.getAttribute("userFilesRoot");
        String dbName="";
        String version="";
        String firstEnsemblID="";
        String panel="";
        String fullOrg="";
        String chromosome="";
        String geneSymbol="";
        String genURL="";
        int rnaDatasetID=0;
	int arrayTypeID=0;
        int min=0;
	int max=0;
        int selectedGene=0;
        int viewID=10;

        iDecoderAnswer = (Set) session.getAttribute("iDecoderAnswer");
        ExonDataTools edt=new ExonDataTools();
        edt.setSession(session);
        List myIdentifierList=null;
        ArrayList<String> myEnsemblIDs=new ArrayList<String>();
        ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> fullGeneList;

	

        if(myOrganism.equals("Rn")){
                panel="BNLX/SHRH";
                fullOrg="Rattus_norvegicus";
        }else{
                panel="ILS/ISS";
                fullOrg="Mus_musculus";
        }

        if(iDecoderAnswer!=null){
                myIdentifierList = Arrays.asList(iDecoderAnswer.toArray((Identifier[]) new Identifier[iDecoderAnswer.size()]));
        }/*else{
                log.debug("iDecoder Answer is NULL");
        }*/
        if(myOrganism!=null){
                if(myOrganism.equals("Mm")){
                        rDataFile=rDataFile+"public/Datasets/PublicILSXISSRIMice_Master/Affy.NormVer.h5'";
                        dbName="Public ILSXISS RI Mice";
                        //version="v3";
                        version="v6";  //mm10
                }else if(genomeVer.equals("rn5")){
                        if(myTissue.equals("Brain")){
                                rDataFile=rDataFile+"public/Datasets/PublicHXB_BXHRIRats(Brain,ExonArrays)_Master/Affy.NormVer.h5'";
                                dbName="Public HXB/BXH RI Rats (Brain, Exon Arrays)";
                                version="v6";
                        }else if(myTissue.equals("Heart")){
                                rDataFile=rDataFile+"public/Datasets/PublicHXB_BXHRIRats(Heart,ExonArrays)_Master/Affy.NormVer.h5'";
                                dbName="Public HXB/BXH RI Rats (Heart, Exon Arrays)";
                                version="v6";
                        }else if(myTissue.equals("Liver")){
                                rDataFile=rDataFile+"public/Datasets/PublicHXB_BXHRIRats(Liver,ExonArrays)_Master/Affy.NormVer.h5'";
                                dbName="Public HXB/BXH RI Rats (Liver, Exon Arrays)";
                                version="v6";
                        }else if(myTissue.equals("BAT")){
                                rDataFile=rDataFile+"public/Datasets/PublicHXB_BXHRIRats(BrownAdipose,ExonArrays)_Master/Affy.NormVer.h5'";
                                dbName="Public HXB/BXH RI Rats (Brown Adipose, Exon Arrays)";
                                version="v6";
                        }
                }else if(genomeVer.equals("rn6")){
                        if(myTissue.equals("Brain")){
                                rDataFile=rDataFile+"public/Datasets/PublicHXB_BXHRIRats(Brain,ExonArrays)_Master/Affy.NormVer.h5'";
                                dbName="Public HXB/BXH RI Rats (Brain, Exon Arrays)";
                                version="v9";
                        }else if(myTissue.equals("Heart")){
                                rDataFile=rDataFile+"public/Datasets/PublicHXB_BXHRIRats(Heart,ExonArrays)_Master/Affy.NormVer.h5'";
                                dbName="Public HXB/BXH RI Rats (Heart, Exon Arrays)";
                                version="v9";
                        }else if(myTissue.equals("Liver")){
                                rDataFile=rDataFile+"public/Datasets/PublicHXB_BXHRIRats(Liver,ExonArrays)_Master/Affy.NormVer.h5'";
                                dbName="Public HXB/BXH RI Rats (Liver, Exon Arrays)";
                                version="v9";
                        }else if(myTissue.equals("BAT")){
                                rDataFile=rDataFile+"public/Datasets/PublicHXB_BXHRIRats(BrownAdipose,ExonArrays)_Master/Affy.NormVer.h5'";
                                dbName="Public HXB/BXH RI Rats (Brown Adipose, Exon Arrays)";
                                version="v9";
                        }
                }
        }
	
        if(iDecoderAnswer!=null){
            //log.debug("iDecoderAnswer not null, length:"+myIdentifierList.size());
            if(myIdentifierList!=null&&myIdentifierList.size()>0){
                Identifier thisIdentifier = (Identifier)myIdentifierList.get(0);
                HashMap linksHash = thisIdentifier.getTargetHashMap();
                Set homologSet = myIDecoderClient.getIdentifiersForTargetForOneID(linksHash, new String[] {"Ensembl ID"});
                List homologList = myObjectHandler.getAsList(homologSet);

                for (int i=0; i< homologList.size(); i++) {
                    Identifier homologIdentifier = (Identifier) homologList.get(i);
                    if(homologIdentifier.getIdentifier().indexOf("T0")!=6){
                        myEnsemblIDs.add(homologIdentifier.getIdentifier());
                        if(ident.equals("")){
                            ident=homologIdentifier.getIdentifier();
                            firstEnsemblID=ident;
                        }else{
                            ident=ident+","+homologIdentifier.getIdentifier();
                        }

                    }
                }
                if(!ident.equals("")){
                    edt.getExonHeatMapData(ident,rDataFile,version,myOrganism,genomeVer,dbName);
                    gene =(String)session.getAttribute("exonCorGeneFile");
                    heat =(String)session.getAttribute("exonCorHeatFile");
                    int[] tmp=gdt.getOrganismSpecificIdentifiers(myOrganism,genomeVer);
                    if(tmp!=null&&tmp.length==2){
                            rnaDatasetID=tmp[1];
                            arrayTypeID=tmp[0];
                    }
                    ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Gene> tmpGeneList=gdt.getGeneCentricData(ident,firstEnsemblID,panel,myOrganism,genomeVer,rnaDatasetID,arrayTypeID,false);
                    String tmpURL =gdt.getGenURL();//(String)session.getAttribute("genURL");
                    String tmpGeneSymbol=gdt.getGeneSymbol();//(String)session.getAttribute("geneSymbol");
                    log.debug(tmpURL+"\n"+tmpGeneSymbol);
                    String tmpUcscURL =gdt.getUCSCURL();
                    
                    min=gdt.getMinCoord();
                    max=gdt.getMaxCoord();
                    chromosome=gdt.getChromosome();
                    fullGeneList=tmpGeneList;

                    if(tmpURL!=null){
                            genURL=tmpURL;
                            if(tmpGeneSymbol==null && !tmpURL.startsWith("ERROR:")){
                                    geneSymbol="";
                            }else if(tmpURL.startsWith("ERROR:")){
                                    geneSymbol="ERROR GENERATING";
                            }else{
                                    geneSymbol=tmpGeneSymbol;
                            }
                            if(tmpGeneSymbol!=null && tmpGeneSymbol.equals(myGene)){
                                    selectedGene=0;
                                    min=gdt.getMinCoord();
                                    max=gdt.getMaxCoord();
                                    chromosome=gdt.getChromosome();
                                    fullGeneList=tmpGeneList;
                            }
                    }
                }else{
                        gene="No Ensembl ID";
                        heat="No Ensembl ID";
                }

            }
        String tmpoutputDir = applicationRoot+contextRoot+ "tmpData/geneData/" + firstEnsemblID + "/";
	String[] loc=null;
        try{
                loc=myFH.getFileContents(new File(tmpoutputDir+"location.txt"));
        }catch(IOException e){
                log.error("Couldn't load location for gene.",e);
        }
        if(loc!=null){
                chromosome=loc[0];
                min=Integer.parseInt(loc[1]);
                max=Integer.parseInt(loc[2]);
        }
	String tmpOutput=gdt.getImageRegionData(chromosome, min, max, panel, myOrganism, genomeVer, rnaDatasetID, arrayTypeID, 0.001,false);
	int startInd=tmpOutput.lastIndexOf("/",tmpOutput.length()-2);
	String folderName=tmpOutput.substring(startInd+1,tmpOutput.length()-1);
	
	/*String genURL="";
	String urlPrefix=(String)session.getAttribute("mainURL");
        if(urlPrefix.endsWith(".jsp")){
             urlPrefix=urlPrefix.substring(0,urlPrefix.lastIndexOf("/")+1);
        }
        if(request.getServerPort()!=80 && urlPrefix.indexOf("https")<0){
            urlPrefix=urlPrefix.replace("http","https");
        }
	genURL=urlPrefix+ "tmpData/geneData/" +selectedID+"/";*/
        String urlPrefix=(String)session.getAttribute("mainURL");
	String regionURL=urlPrefix+"tmpData/browserCache/"+genomeVer+"/regionData/"+folderName+"/";
        %>



<%if (gene.equals("failed")){
        //log.debug("Gene=FAILED");
%>

        <div class="error">
            <p>An error occurred while generating the heatmap.  The administrator has been notified.  Please try again later.</p>
        </div>
        <div class="brClear"></div>
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />

<% }else if (gene.equals("No Ensembl ID")){%>
        <div class="error">
            <p>The identifier entered could not be translated to an Ensembl ID.  Please try a different identifier for your gene of interest and/or report the identifier so we can improve the method used to translate identifiers to Ensembl IDs.</p>
        </div>
        <div class="brClear"></div>
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />

<%}else{
                //log.debug("gene <> FAILED");
                if(ident.equals("")){
                                //log.debug("Ident is empty.");
%>
                        <div class="error">
                            <p>No ensembl gene identifier was found.</p>
                        </div>
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <script type="text/javascript">
                            document.getElementById("wait1").style.display = 'none';
                        </script>
    <% }else{ %>
                        
    
    
                        <!--<BR />
                        <BR />
                        <script>
                            var gene="<%=gene%>";
                            var heat="<%=heat%>";
                            var ensembl="<%=firstEnsemblID%>";
                        </script>
                        <script src="http://java.com/js/deployJava.js"></script>
                        <script>
                            var attributes = {
                                code:       "edu.ucdenver.ccp.phenogen.applets.ExonCorrelationView",
                                archive:    "ExonCorrelationViewer2.jar, lib/swing-layout-1.0.4.jar",
                                width:      960,
                                height:     1200
                            };
                            var parameters = {jnlp_href:"/web/exons/launch.jnlp",
                                gene_data:gene,
                                heatmap_data:heat,
                                main_ensembl_id:ensembl
                            }; 
                            var version = "1.5"; 
                            deployJava.runApplet(attributes, parameters, version);
                        </script>-->
                        
            <%@ include file="/web/GeneCentric/browserCSS.jsp" %>
<style>
	.ui-widget { font-size:0.8em;}
</style>
<script type="text/javascript">
	$('#wait1').hide();
        var gene="<%=gene%>";
        var heat="<%=heat%>";
        var ensembl="<%=firstEnsemblID%>";
	var urlprefix="<%=host+contextRoot%>";
	var selectedID="<%=firstEnsemblID%>";
	var genURL="<%=genURL%>";
	var regionURL="";
	var minCoord=<%=min%>;
	var maxCoord=<%=max%>;
	var initMin=<%=min%>;
	var initMax=<%=max%>;
	var panel="<%=panel%>";

	var chr="<%=chromosome%>";
	var rnaDatasetID=<%=rnaDatasetID%>;
	var arrayTypeID=<%=arrayTypeID%>;
	var pValueCutoff=0.001;
	var forwardPValueCutoff=0.001;

	var organism="<%=myOrganism%>";
	var ucsctype="region";
	var ucscgeneID="";
	var defaultView="viewAll";
	var selectGene="";
	var folderName="<%=folderName%>";
	var pathPrefix="web/GeneCentric/";
	var dataPrefix="../../";
	var regionfolderName="<%=folderName%>";
	var skipSetSelection=1;
	var iconPath="<%=imagesDir%>icons/";
	var trackMenu=[];
	var viewMenu=[];
	<%if(userLoggedIn.getUser_name().equals("anon")){%>
		var uid=0;
	<%}else{%>
		var uid=<%=userLoggedIn.getUser_id()%>;
	<%}%>
        var genomeVer="<%=genomeVer%>";
	//Bugsense.addExtraData('page', 'geneApplet.jsp');
	//Bugsense.addExtraData( 'region','<%=firstEnsemblID+"::"+chromosome+":"+min+"-"+max%>');
</script>
<div id="imageMenu"></div>
<div id="viewMenu"></div>
<div id="trackMenu"></div>
    <!--<div style="font-size:18px; font-weight:bold; background-color:#FFFFFF; color:#000000; text-align:center; width:100%; padding-top:3px;">
    		View:
    		<span class="viewMenu" name="viewGenome" >Genome<div class="inpageHelp" style="display:inline-block; "><img id="HelpImageGenomeView" class="helpImage" src="<%=imagesDir%>icons/help.png" /></div></span>
    		<span class="viewMenu" name="viewTrxome" >Transcriptome<div class="inpageHelp" style="display:inline-block; "><img id="HelpImageTranscriptomeView" class="helpImage" src="<%=imagesDir%>icons/help.png" /></div></span>
            <span class="viewMenu" name="viewAll" >Both<div class="inpageHelp" style="display:inline-block; "><img id="HelpImageAllView" class="helpImage" src="<%=imagesDir%>icons/help.png" /></div></span>
            <!--<span style="font-size:12px; font-weight:normal; float:right;">
            	Saved Views:
                <select name="viewSelect" id="viewSelect">
                		<option value="0" >------Login to use saved views------</option>
                </select>
            </span>-->
    <!--</div>-->
    
    
    <input type="hidden" id="defaultView" value="<%=viewID%>" />
    <div style="font-size:18px; font-weight:bold; background-color:#DEDEDE; color:#000000; text-align:left; width:100%;">
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
                        <span class="trigger less" name="collapsableImage" >Transcript Image</span>
                        <div class="inpageHelp" style="display:inline-block; "><img id="HelpRegionImage" class="helpImage" src="<%=imagesDir%>icons/help.png" /></div>
                  	</TD>
                    <TD style="background-color:#DEDEDE; text-align:center; width:50%;font-size:18px; font-weight:bold; vertical-align: middle;">
                        <span id="viewLbl0">View:</span><span id="viewModifiedCtl0" style="display:none;">(Modified <span class="Imagetooltip" title="This view has been modified.  To save this change you should use the arrow next to Select/Edit Views to Save or Save As..  Otherwise your change will persist only while this window is not refreshed and not left inactive for more than 59 minutes."><img src="<%=imagesDir%>icons/info.gif" />)</span>
                    </TD>
                    <TD style="background-color:#DEDEDE;">
                        <div id="imageHeader" style=" font-size:12px; float:right;"></div>
            		</TD>
               </TR>
               </tbody>
            </table>
    		<!--<span class="trigger less" name="collapsableImage" >Transcripts Image</span>
    		<div class="inpageHelp" style="display:inline-block; "><img id="HelpRegionImage" class="helpImage" src="<%=imagesDir%>icons/help.png" /></div>
            <div id="imageHeader" style=" font-size:12px; float:right;"></div>-->
            <!--<span style="font-size:12px; font-weight:normal; float:right;">
            	Saved Views:
                <select name="viewSelect" id="viewSelect">
                		<option value="0" >------Login to use saved views------</option>
                </select>
            </span>-->
    </div>
    <script type="text/javascript">
	//Setup View Menu
	var defviewList=[];
	var filterViewList=[];
	
	function getMainViewData(shouldUpdate){
		var tmpContext=contextPath +"/"+ pathPrefix;
		if(pathPrefix===""){
			tmpContext="";
		}	
		d3.json(tmpContext+"getBrowserViews.jsp",function (error,d){
			if(error){
				setTimeout(function(){getMainViewData(shouldUpdate);},2000);
				d3.select("#defaultView").html("<option>Error: reloading</option>");
			}else{
				console.log("getViewData()");
				defviewList=d;
				//readCookieViews();
				if(shouldUpdate===1){
					setupDefaultView();
				}
			}
		});
	};
	
	function readCookieViews(){
		console.log("readCookieViews()");
		var viewString="";
		if(isLocalStorage() === true){
			var cur=localStorage.getItem("phenogenCustomViews");
			if(cur!=undefined){
				viewString=cur;
			}
		}else{
			if($.cookie("phenogenCustomViews")!=null){
				viewString=$.cookie("phenogenCustomViews");
			}
		}
		if(viewString!=null&&viewString.indexOf("<///>")>-1){
			var viewStrings=viewString.split("<///>");
			for(var j=0;j<viewStrings.length;j++){
				var params=viewStrings[j].split("</>");
				var obj={};
				for(k=0;k<params.length;k++){
					var values=params[k].split("=");
					if(values[0]=="TrackSettingList"){
						var trList=values[1].split(";");
						obj.TrackList=[];
						for(var m=0;m<trList.length;m++){
							if(trList[m].length>0){
								var tc=trList[m].substr(0,trList[m].indexOf(","));
								var set=trList[m].substr(trList[m].indexOf(",")+1);
								var track={};
								track.TrackClass=tc;
								track.Settings=set;
								track.Order=m;
								obj.TrackList.push(track);
							}
						}
					}else if(values.length<=2){
						obj[values[0]]=values[1];
					}else if(values.length>2){
						var name=params[k].substr(0,params[k].indexOf("="));
						var value=params[k].substr(params[k].indexOf("=")+1);
						obj[name]=value;
					}
				}
				obj.Source="local";
				if(params.length>3){					
					obj.orgCount=obj.TrackList.length;
					defviewList.push(obj);
				}
			}
		}
	}
	
	
	function setupDefaultView(){
		console.log("setupDefaultView()");
		d3.select("#defaultView").html("");
		filterViewList=[];
		for(var i=0;i<defviewList.length;i++){
			if(defviewList[i].Organism=="AA"||defviewList[i].Organism.toLowerCase()==$('#speciesCB').val().toLowerCase()){
				filterViewList.push(defviewList[i]);
			}
		}
		var opt=d3.select("#defaultView").selectAll('option').data(filterViewList);
		opt.enter().append("option")
					.attr("value",function(d){return d.ViewID;})
					.text(function(d){
						var ret=d.Name;
						if(d.UserID==0){
							ret=ret+"    (Predefined)";
						}else{
							ret=ret+"   (Custom)";
						}
						if(d.Organism!="AA"){
							if(d.Organism=="RN"){
								ret=ret+"      (Rat Only)";
							}else if(d.Organism=="MM"){
								ret=ret+"     (Mouse Only)";
							}
						}
						
						return ret;
					});
		opt.exit().remove();
	}
	</script>
<div style="border-color:#CCCCCC; border-width:1px; border-style:inset; text-align:center;">
    	<span id="mouseHelp">Navigation Hints: Hold mouse over areas of the image for available actions.</span>    
        <div id="collapsableImage" class="geneimage" >
       		<div id="imgLoad" style="display:none;"><img src="<%=imagesDir%>ucsc-loading.gif" /></div>

            <div id="geneImage" class="ucscImage"  style="display:inline-block;width:100%;">

            <script src="<%=contextRoot%>javascript/GenomeDataBrowser2.6.9.js" type="text/javascript"></script>
            <script src="<%=contextRoot%>javascript/GenomeReport2.6.0.js" type="text/javascript"></script>
            <script src="<%=contextRoot%>javascript/GenomeViewMenu2.6.0.js" type="text/javascript"></script>
            <script src="<%=contextRoot%>javascript/GenomeTrackMenu2.6.0.js" type="text/javascript"></script>

				
            <script type="text/javascript">
				function isLocalStorage(){
					var test = 'test';
					try {
						localStorage.setItem(test, test);
						localStorage.removeItem(test);
						return true;
					} catch(e) {
						return false;
					}
				}
			
                    setTimeout(function(){
                        var gs=new GenomeSVG(".ucscImage",$(window).width()-25,minCoord,maxCoord,0,chr,"gene",false);
                        gs.forceDrawAs("Trx");
                        //loadStateFromCookie(0);
                        gs.xMax=maxCoord;
                        gs.xMin=minCoord;
                        //trackMenu[0].applyView();
                    },10);
					
					
					$("span[name='"+defaultView+"']").addClass("selected");
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
                </script>
           </div>
        </div>

</div><!--end Border Div -->
    <BR />
    <div id="newunsupportedChrome" style="display:none;color:#FF0000;">
        New versions of Chrome 42+ may not work for now with the Java Plugin.  If you can setup and activate the plugin it should work but the current Java version 1.8.0_45 does not seem to work.  Please use Firefox or Safari.
    </div>
    
    <div id="unsupportedChrome" style="display:none;color:#FF0000;"><BR /><BR />A Java plug in is required to view this page.  Older versions of Chrome are 32-bit applications and require a 32-bit plug-in which is unavailable for Mac OS X.  
            	Please try using Safari or FireFox with the Java Plug in installed.  Note: In browsers that support the 64-bit plug in you will be prompted to install Java if it is not already installed.  Chrome 39-41 is 64-bit on Mac OS X so you should be able to use chrome with the plug-in installed.</div>
                
                
			<span id="disabledJava" style="display:none;margin-left:40px;"><BR /><BR />
                <span style="color:#FF0000;">Java has been disabled in your browser.</span><BR />
                            To enable Java in your browser or operating system, see:<BR><BR> 
                            Firefox: <a href="http://support.mozilla.org/en-US/kb/unblocking-java-plugin" target="_blank">http://support.mozilla.org/en-US/kb/unblocking-java-plugin</a><BR><BR>
                            Internet Explorer: <a href="http://java.com/en/download/help/enable_browser.xml" target="_blank">http://java.com/en/download/help/enable_browser.xml</a><BR><BR>
                            Safari: <a href="http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html" target="_blank">http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html</a><BR><BR>
                            Chrome: <a href="http://java.com/en/download/faq/chrome.xml" target="_blank">http://java.com/en/download/faq/chrome.xml</a><BR /><BR />
            </span>
            <span id="noJava" style="color:#FF0000;display:none;"><BR /><BR /> No Java Plug-in is installed or a newer version is required click the Install button for the latest version.<BR /></span>
            <span id="oldJava" style="color:#00AA00;display:none;"><BR /><BR />A newer Java version may be available click the Install button for the latest version.(You may still use all functions even if you see this message.)<BR /></span>
            <span id="installJava" style="display:none;" class="button">Install Java</span>
                            


<div id="macBugDesc" style="display:none;color:#FF0000;"><BR /><BR />The applet below is fully functional.  However, with your current combination of Mac OS X and Java plug-in the display is not optimal due to a bug.  This bug has been fixed if you update to Java plug-in version 1.7.0_51 or higher the display will be improved.  We are very sorry for any inconvenience.  This bug is not found in Windows, Linux, Mac OS X 10.6 or lower if you have any of them available.</div>
        <BR /><BR /><BR />
        <div style="margin-left:10px;margin-right:10px;"><p><span style="color:#FF0000">Note:</span>If you don't see the applet below try adjusting security settings as directed <a href="http://java.com/en/download/help/enable_browser.xml" target="_blank">here</a>. You will be asked if you want to allow the applet to run, please select "Run" or "Yes" if prompted.  We are now providing a signed applet that will say it has been signed by the University of Colorado Denver.  We are also working to provide similar expression data that is not dependent on Java at some point in the future.</p>
            <%if(request.getServerPort()!=80){%>
            <BR><BR><p style="color:#FF0000;">Using the secure site(https), you may first be prompted with a message stating that the server cannot be verified and is not trusted.  This is due to differences between how Java and browsers handle the validation of SSL certificates used to verify the server.  If you see in your browser that the site is trusted and connection is encrypted you should click Continue.  If your browser indicates a problem then you should be very careful about clicking continue.  We are trying to find a way to prevent the additional warning and will update the page as soon as an option exists.</p>
            <%}%>
        </div>
        <BR /><BR />
        <div style="text-align:center; padding-bottom: 70px;">
        <%if(request.getServerPort()==80){%>
            <script type="text/javascript" src="http://www.java.com/js/deployJava.js"></script>
        <%}else{%>
            <script type="text/javascript" src="https://www.java.com/js/deployJava.js"></script>
        <%}%>
        <script type="text/javascript">
			var ensembl=selectedID;
			var appletWidth=960;
			var appletHeight=1200;
			var jre=deployJava.getJREs();
			var bug=0;
			var bugString='false';
			var unsupportedChrome=0;
                        var newUnsupportedChrome=0;
			if(!navigator.javaEnabled()){
                            $('#javaError').css("display","inline-block");
                            $('#disabledJava').css("display","inline-block");
                        }else if (deployJava.versionCheck('1.6.0+') == false) {
                            $('#javaError').css("display","inline-block");
                            $('#noJava').css("display","inline-block");                  
                            $('#installJava').css("display","inline-block");
                        }else{
                            if (deployJava.versionCheck('1.7.0+') == false) {                   
                                $('#oldJava').css("display","inline-block");
                                $('#installJava').html("Update Java");
                                $('#installJava').css("display","inline-block");
                            }
                        }
           $('#installJava').click(function (){
                    // Set deployJava.returnPage to make sure user comes back to 
                    // your web site after installing the JRE
                    deployJava.returnPage = location.href;
                            
                    // Install latest JRE or redirect user to another page to get JRE
                    deployJava.installLatestJRE(); 
           });	
           
                        if(/Chrome\/(\d+)/.test(navigator.userAgent)){
                            //console.log(RegExp.$1);
                            var chromeVer=new Number(RegExp.$1);
                            if(chromeVer>=42){
                                    newUnsupportedChrome=1;
                                    $('#newunsupportedChrome').show();
                            }
			}
                        //console.log(navigator.userAgent);
			if (/Mac OS X[\/\s](\d+[_\.]\d+)/.test(navigator.userAgent)){
 					//var macVersion=new Number(RegExp.$1); // capture x.x portion and store as a number
					var tmpAgent=new String(navigator.userAgent);
					//alert("Detected Mac OS X:"+tmpAgent);
					if(/Chrome\/(\d+)/.test(tmpAgent)){
                                                //console.log(RegExp.$1);
                                                var chromeVer=new Number(RegExp.$1);
                                                //alert("chrome ver:"+chromeVer);
						var update=new String(jre);
						//alert("chrome update:"+update);
						if(chromeVer<39 && update.length==0){
							//alert("unsupported");
							unsupportedChrome=1;
						}
					}
					else if (/10[_\.](d+)/.test(tmpAgent)){
                                                var osXVer=new Number(RegExp.$1);
						//alert("Mac Ver ="+osXVer);
                                                if(oxXVer>=7){//if OS X 10.7 or higher
                                                    var tmpUp=new String(jre);
                                                    if(/^1\.7/.test(tmpUp)){//make sure we only do this for JRE 1.7_10-1.7_51
                                                        var update=tmpUp.substr((tmpUp.indexOf("_")+1));
                                                        //alert("update:"+update);
                                                        if(update>=10 && update <51){//bug occurred between update 10 and 51 of the Oracle 1.7 Mac OSX JRE.
                                                                //alert("update >10");
                                                                /*if(deployJava.versionCheck('1.7.0_51+')){//This version no longer has the bug so if newer mac OS X and JRE update 51 or higher don't actually change the applet

                                                                }else{*/
                                                                        bug=1;
                                                                        appletHeight=700;
                                                                        bugString='true';
                                                                //}
                                                        }
                                                    }
                                                }
					}
			}
			if(unsupportedChrome===0 && newUnsupportedChrome===0){
                                //code:       "edu.ucdenver.ccp.phenogen.applets.ExonCorrelationView",
                                //archive:    "ExonCorrelationViewer2.jar, lib/swing-layout-1.0.4.jar",
				var attributes = {
					id:	'exonApplet',
					code:       "edu.ucdenver.ccp.phenogen.applets.exonviewer.ExonCorrelationView",
					archive:    "<%=contextRoot%>web/exons/ExonCorrelationViewer2.jar",
					width:      appletWidth,
					height:     appletHeight
				};
                                console.log("gene:"+gene);
                                console.log("heat:"+heat);
				var parameters = {
					java_status_events: 'true',
					jnlp_href:"<%=contextRoot%>web/exons/launch.jnlp",
					gene_data:gene,
                                        heatmap_data:heat,
                                        main_ensembl_id:ensembl
				}; 
				var version = "1.7"; 
                                deployJava.runApplet(attributes, parameters, version);
			}else if(unsupportedChrome===1){
				$('#unsupportedChrome').show();
			}
			if(bug===1){
				$('div#macBugDesc').show();
			}
       
		</script>

	</div>
                        
                        

    <% } %>
<% } %>
<% 
} else {
%>
            <div id="exonDirections">
            <BR />
            <%if(myGeneArray!=null){%>
            <ol type="1" style="padding-left:40px; color:#000000; list-style: outside decimal;">

                <li>Choose a Gene, Species, and Tissue.</li>
                <li>Get the Exon Correlations.</li>
            </ol>
            <% } else { %>
            <ol type="1" style="padding-left:40px; color:#000000; list-style: outside decimal;">
                <li>Enter a Gene Symbol, Probeset ID, Ensembl ID, etc. in the Gene field.</li>
                <li>Choose a Species and Tissue.</li>
                <li>Get the Exon Correlations.</li>
            </ol>

            <% } %>

            You can view the exon-exon correlation heat map for any transcripts associated with the corresponding Ensembl ID provided by iDecoder.<BR />
            <b>Note: </b>You may be prompted to choose an Ensembl ID if more than one Ensembl ID corresponds to the gene entered.
            <BR />
            <BR />
            <BR />
            <script>
                if(!navigator.javaEnabled()){
                    document.write("<B>Error:</B>This feature requires the Java Plug-in which is either disabled or not installed.  Recent operating system and browser changes can disable java automatically.");
                    document.write("  This was done because the old versions are vulnerable to an attack which could take over your computer without your knowledge and access files or steal critical information like banking credentials.<BR><BR>Please first update or install Java from <a href=\"http://www.Java.com\">Java.com</a><BR><BR>To enable Java in your browser or operating system, see:<BR><BR> Firefox: <a href=\"http://support.mozilla.org/en-US/kb/unblocking-java-plugin\">http://support.mozilla.org/en-US/kb/unblocking-java-plugin</a><BR><BR>Internet Explorer: <a href=\"http://java.com/en/download/help/enable_browser.xml\">http://java.com/en/download/help/enable_browser.xml</a><BR><BR>Safari: <a href=\"http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html\">http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html</a><BR><BR>Chrome: <a href=\"http://java.com/en/download/faq/chrome.xml\">http://java.com/en/download/faq/chrome.xml</a><BR>");
                }
            </script>
            </div>
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />

<% 
} %> 