<%--
 *  Author: Cheryl Hornbaker
 *  Created: Dec, 2010
 *  Description:  The web page created by this file allows the user to 
 *		download files useful for doing systems biology
 *  Todo: 
 *  Modification Log:
 *      
--%>


<%@ include file="/web/sysbio/include/sysBioHeader.jsp"  %>
<%
	log.info("in resources.jsp. user =  "+ user);
	
	log.debug("action = "+action);
        extrasList.add("tooltipster.css");
        extrasList.add("tabs.css");
	extrasList.add("resources.js");
	extrasList.add("jquery.tooltipster.js");
        extrasList.add("d3.v3.min.js");
        extrasList.add("jquery.dataTables.min.js");
	
	mySessionHandler.createSessionActivity(session.getId(), "Looked at download systems biology resources page", dbConn);

	Resource[] myExpressionResources = myResource.getExpressionResources();
	Resource[] myMarkerResources = myResource.getMarkerResources();
	Resource[] myRNASeqResources = myResource.getRNASeqResources();
	Resource[] myDNASeqResources = myResource.getDNASeqResources();
	Resource[] myGenotypeResources = myResource.getGenotypingResources();
	// Sort by organism first, dataset second (seems backwards!)
	myExpressionResources = myResource.sortResources(myResource.sortResources(myExpressionResources, "dataset"), "organism");
	ArrayList checkedList = new ArrayList();
	
%>
<style>
        span.detailMenu{
		border-color:#CCCCCC;
		border:solid;
		border-width: 1px 1px 0px 1px;
		border-radius:5px 5px 0px 0px;
		padding-top:2px;
		padding-bottom:2px;
		padding-left:15px;
		padding-right:15px;
		cursor:pointer;
                color:#000000;
	}
        span.detailMenu{
		background-color:#AEAEAE;
		border-color:#000000;
		
	}
	span.detailMenu.selected{
		background-color:#FEFEFE;
		/*background:#86C3E2;*/
		color:#000000;
	}
	span.detailMenu:hover{
		background-color:#FEFEFE;
		/*background:#86C3E2;*/
		color:#000000;
	}
        div#public,div#members{
            border-color:#CCCCCC;
            border:solid;
            border-width: 1px 1px 1px 1px;
            background: #FEFEFE;
            padding-left: 5px;
            padding-right: 5px;
        }
        span.action{
            cursor: pointer;
        }
</style>
<%pageTitle="Download Resources";
pageDescription="Data resources available for downloading includes Microarrays, Sequencing, and GWAS data";%>

<%@ include file="/web/common/header_noBorder.jsp"  %>
<% if(loggedIn && !(userLoggedIn.getUser_name().equals("anon")) ){%>
<div style="width:100%;">
        <div style="font-size:18px; font-weight:bold;  color:#FFFFFF; text-align:center; width:100%; padding-top: 3px; ">
            <span id="detail1" class="detailMenu selected" name="public">Public Files</span>
            
            <span id="detail2" class="detailMenu" name="members">Members' Files</span>
            
        </div>
</div>
<%}%>
<script>
    $("#wait1").hide();
</script>
<div id="public">
<h2>Select the download icon(<img src="<%=imagesDir%>icons/download_g.png" />) to download data from any of the datasets below.  For some data types multiple options may be available. For these types, a window displays that allows you to choose specific files.</h2>

	<form	method="post" 
		action="resources.jsp" 
		enctype="application/x-www-form-urlencoded"
		name="resources">
		<BR>
		<div class="brClear"></div>

		<div class="title"> Expression Data Files</div>
		      <table id="expressionFiles" name="items" class="list_base tablesorter" cellpadding="0" cellspacing="3" width="98%">
            		<thead>
                               <tr class="col_title">
					<th>Organism</th>
					<th>Dataset</th>
					<th>Tissue</th>
					<th>Array</th>
					<th>Expression Values</th>
					<th>eQTL</th>
					<th>Heritability</th>
                    <TH>Masks <span class="toolTip" title="For Affymetrix exon array masks, individual probes were masked if they did not align uniquely to the rat/mouse genome (rn5/mm10) or if they aligned to a region that harbored a SNP between the reference genome and either of the RI panels parental strains(SHR/BN-Lx or ILS/ISS).  Entire probe sets were eliminated if less than three probes remained after masking.  To create masked transcript clusters, masked probe sets were removed from transcript clusters.  Remaining probe sets new locations were verified by checking that the location was still on the same strand, and within 1,000,000 base pairs of each other.  Transcript clusters with no probe sets remaining were masked."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
					<!-- <th>Details</th> -->
				</tr>
			</thead>
			<tbody>
			<% for (Resource resource: myExpressionResources) { 
			%> 
				<tr id="<%=resource.getID()%>">  
				<td> <%=resource.getOrganism()%> </td>
				<td> <%=resource.getDataset().getName()%></td> 
				<td> <%=resource.getTissue()%></td>
				<td> <%=resource.getArrayName()%></td>
                <% if(resource.getDataset().getVisible()){%>
				<% if (resource.getExpressionDataFiles() != null && resource.getExpressionDataFiles().length > 0) { %>
                                	<td class="actionIcons">
						<div class="linkedImg download" type="expression"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				<% if (resource.getEQTLDataFiles() != null && resource.getEQTLDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="eQTL"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				<% if (resource.getHeritabilityDataFiles() != null && resource.getHeritabilityDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="heritability"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
                <% if (resource.getMaskDataFiles() != null && resource.getMaskDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="mask">
                        <%if(resource.getDataset().getName().contains("Exon")&&resource.getOrganism().equals("Rat")){%>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*
                        <%}%>
                        <div>
						
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
                <%}else{%>
                           <td colspan="4"><%= resource.getDataset().getVisibleNote() %></td>    
				<% } %>	
                        </tr>
			<% } %>
			</tbody>
		</table> 
		<BR>
        *The mask files are the same for all of these datasets.
		<BR>
		<div class="title"> Genomic Marker Data Files</div>
		      <table id="markerFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
            		<thead>
                               <tr class="col_title">
					<th>Organism</th>
                    <th>Panel</th>
					<th>Source</th>
					<th>Markers</th>
					<th>eQTL</th>
				</tr>
			</thead>
			<tbody>
			<% for (Resource resource: myMarkerResources) { %> 
				<tr id="<%=resource.getID()%>">  
				<td> <%=resource.getOrganism()%> </td>
                <td> <%=resource.getPanelString()%> </td>
				<td> <%=resource.getSource()%></td> 
				<% if (resource.getMarkerDataFiles() != null && resource.getMarkerDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="marker"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				<% if (resource.getEQTLDataFiles() != null && resource.getEQTLDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="eQTL"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				</tr> 
			<% } %>
			</tbody>
		</table> 
        
        <BR>
		<BR>
		<div class="title"> RNA Sequencing BED/BAM Data Files</div>
		      <table id="rnaFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
            		<thead>
                               <tr class="col_title">
					<th>Organism</th>
					<th>Strain</th>
                    <th>Tissue</th>
                    <th>Seq. Tech.</th>
                    <th>RNA Type</th>
                    <th>Read Type</th>
					<th>.BED/.BAM Files</th>
				</tr>
			</thead>
			<tbody>
			<% for (Resource resource: myRNASeqResources) { %> 
				<tr id="<%=resource.getID()%>">  
				<td> <%=resource.getOrganism()%> </td>
				<td> <%=resource.getSource()%></td>
                <td> <%=resource.getTissue()%></td>
                <td> <%=resource.getTechType()%></td>
                <td> <%=resource.getRNAType()%></td>
                <td> <%=resource.getReadType()%></td>     
				<% if (resource.getSAMDataFiles() != null && resource.getSAMDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="rnaseq"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				</tr> 
			<% } %>
			</tbody>
		</table>
        
        
        <BR>
		<BR>
        <div class="title"> Strain-specific Rat Genomes (Rn5) <span class="toolTip" title="SNPs between the reference genome and the strain have been replaced with the nucleotide from the strain."><img src="<%=imagesDir%>icons/info.gif"></span></div>
		      <table id="dnaFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3">
            		<thead>
                               <tr class="col_title">
					<th>Organism</th>
					<th>Strain</th>
                    <th>Seq. Tech.</th>
					<th>.fasta Files</th>
				</tr>
			</thead>
			<tbody>
			<% for (Resource resource: myDNASeqResources) { %> 
				<tr id="<%=resource.getID()%>">  
				<td> <%=resource.getOrganism()%> </td>
				<td> <%=resource.getSource()%></td>
                <td> <%=resource.getTechType()%></td>  
				<% if (resource.getSAMDataFiles() != null && resource.getSAMDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="rnaseq"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				</tr> 
			<% } %>
            
			</tbody>
		</table>
        <div style="text-align:center; padding-top:5px;">
        Links to Reference Rat Genome(Strain BN) Rn5: <a href="ftp://ftp.ncbi.nlm.nih.gov/genomes/R_norvegicus/" target="_blank">FTP NCBI</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <a href="ftp://ftp.ensembl.org/pub/release-71/fasta/rattus_norvegicus/dna/" target="_blank">FTP Ensembl</a>
       	</div>
        
        <BR>
		<BR>
		<div class="title">Human Genotype Data Files</div>
		      <table id="genotypingFiles" class="list_base tablesorter" name="items" cellpadding="0" cellspacing="3" width="98%">
            	<thead>
                    <tr class="col_title">
					<th >Organism</th>
					<th >Population</th>
                    <th >Ancestry</th>
                    <th >Array Type</th>
					<th >.CEL Files</th>
					</tr>
				</thead>
			<tbody>
			<% for (Resource resource: myGenotypeResources) { %> 
				<tr id="<%=resource.getID()%>">  
				<td> <%=resource.getOrganism()%> </td>
				<td> <%=resource.getPopulation()%></td>
                <td> <%=resource.getAncestry()%></td>
                <td> <%=resource.getTechType()%></td>    
				<% if (resource.getGenotypeDataFiles() != null && resource.getGenotypeDataFiles().length > 0) { %>
					<td class="actionIcons">
						<div class="linkedImg download" type="genotype"><div>
					</td>
				<% } else { %>
                                	<td>&nbsp;</td>
				<% } %>
				</tr> 
			<% } %>
			</tbody>
		</table>
                        <BR>
        
        
	</form>
</div><!-- END PUBLIC DIV-->
<div id="members" style="display:none;min-height: 780px;">
    <H2>My Files</h2>
    <div style="text-align: center;height: 350px;overflow:auto;">
    <table id="myFiles" name="items" style="width:100%;text-align: center;" class="list_base"  cellpadding="0" cellspacing="0">
        <thead>
            <TR class="col_title">
                <TH>File Name(click to download)</TH>
                
                <TH>Description</TH>
                <TH>Date Uploaded</TH>
                <TH>Shared<BR>(click to edit)</TH>
                <TH>Shared with All<BR>Registered Users<BR>(click to edit)</TH>
                <TH>Delete</TH>
            </TR>
        </thead>
        <tbody>
            <TR id="myloading"><TD colspan="6">Loading...</TD></tr>
        </tbody>
    </table>
    </div>
    <BR><BR>
    <H2>Files Shared with Me</h2>
    <div style="text-align: center;height: 350px;overflow:auto;">
    <table id="sharedFiles" name="items" style="width:100%;text-align: center;" class="list_base"  cellpadding="0" cellspacing="0">
        <thead>
            <TR class="col_title">
                <TH>File Owner</TH>
                <TH>File Name<BR>(click to download)</TH>
                <TH>Description</TH>
                <TH>Date Uploaded</TH>
            </TR>
        </thead>
        <tbody>
            <TR id="sharedloading"><TD colspan="4">Loading...</TD></tr>
        </tbody>
    </table>
    </div>
</div><!-- END MEMBERS DIV-->

<div class="downloadItem"></div>
<%@ include file="/web/common/footer.jsp"  %>
<script type="text/javascript">
	$(document).ready(function() {
		$('.toolTip').tooltipster({
		position: 'top-right',
		maxWidth: 250,
		offsetX: 24,
		offsetY: 5,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
		});
		setupPage();
                setTimeout("setupMain()", 100);
                setTimeout(getMyFiles, 50);
                setTimeout(getSharedFiles, 50);
                $(".detailMenu").on("click",function(){
                    var prev=$(".detailMenu.selected").attr("name");
                    $(".detailMenu.selected").removeClass("selected");
                    $("div#"+prev).hide();
                    $(this).addClass("selected");
                    var cur=$(this).attr("name");
                    $("div#"+cur).show();
                });
                
	});
        
        
        
        
        var myFileDataTable;
        var shareFileDataTable;
        
        function key(d){return d.FileID;}
        
        function getMyFiles(){
            $.ajax({
				url: "getFiles.jsp",
   				type: 'GET',
				data: {type:"myFiles"},
				dataType: 'json',
                                success: function(data2){
                                        try{
                                            myFileDataTable.destroy();
                                        }catch(err){
                                            
                                        }
                                        d3.select("table#myFiles").select("tbody").select('tr#myloading').remove();
                                        var tracktbl=d3.select("table#myFiles").select("tbody").selectAll('tr').data(data2,key);
                                        tracktbl.enter().append("tr")
                                                        .attr("id",function(d){return "fid"+d.FileID;})
                                                        .attr("class",function(d,i){var ret="odd";if(i%2===0){ret="even";} return ret;});
                                        tracktbl.exit().remove();
                                        tracktbl.each(function(d,i){
                                                d3.select(this).selectAll("td").remove();
                                                var ind=d.Path.lastIndexOf("/");
                                                var file=d.Path.substr(ind+1);
                                                var fileLink="<a href=\""+d.Path+"\"> "+file+ " </a>";
                                                var timeShort=d.Time.substr(0,d.Time.lastIndexOf(":"));
                                                var shared="<span class=\"action shared\" id=\"share"+d.FileID+"\"><img src=\"../images/success.png\"></span>"
                                                    +"<span class=\"action sharedUsers\" id=\"shareUser"+d.FileID+"\"><img src=\"../images/icons/user_32.png\"></span>";
                                                if(d.Shared==="false"){
                                                    shared="<span class=\"action shared\" id=\"share"+d.FileID+"\"><img src=\"../images/error.png\"></span>"
                                                        +"<span class=\"action sharedUsers\" style=\"display:none;\" id=\"shareUser"+d.FileID+"\"><img src=\"../images/icons/user_32.png\"></span>";
                                                }
                                                
                                                var shareAll="<span class=\"action shareAll\" id=\"shareAll"+d.FileID+"\"><img src=\"../images/success.png\"></span>";
                                                if(d.ShareAll==="false"){
                                                    shareAll="<span class=\"action shareAll\" id=\"shareAll"+d.FileID+"\"><img src=\"../images/error.png\"></span>";
                                                }
                                                        d3.select(this).append("td").html(fileLink);
                                                        d3.select(this).append("td").html(d.Description);
                                                        d3.select(this).append("td").html(timeShort);
                                                        d3.select(this).append("td").html(shared);
                                                        d3.select(this).append("td").html(shareAll);
                                                        d3.select(this).append("td").html("<span class=\"action delete\"><img src=\"../images/icons/delete_lg.png\"></span>");
                                        });
                                        
                                        myFileDataTable=$('table#myFiles').DataTable({
                                            "bPaginate": false,
                                            "aaSorting": [[ 2, "desc" ]],
                                            "sDom": '<"rightSearch"fr><t>'
                                        });
                                        
                                        //setup action buttons
                                       
                                        //changes the sharing status
                                        $(".action.shared").on("click",function(){
                                            var fullID=$(this).attr("id");
                                            var id=fullID.substr(5);
                                            var type=fullID.substr(0,5);
                                            updateFiles(id,fullID,type);
                                        });
                                        
                                        //changes the share with all registered users
                                        $(".action.shareAll").on("click",function(){
                                            var fullID=$(this).attr("id");
                                            var id=fullID.substr(8);
                                            var type=fullID.substr(0,8);
                                            updateFiles(id,fullID,type);
                                        });
                                        //lets user share with selected users
                                        $(".action.shareUsers").on("click",function(){
                                            
                                        });
                                        //deletes the file
                                        $(".action.delete").on("click",function(){
                                            alert("delete");
                                        });
                                        
                                        //run again to keep file list up to date
                                        setTimeout(getMyFiles, 30000);
                                },
                                error: function(xhr, status, error) {
                                        console.log(error);
                                        setTimeout(getMyFiles, 240000);
                                }
            });
            
        }
        function updateFiles(id,fullID, type){
            $.ajax({
                    url: "updateFiles.jsp",
                    type: 'GET',
                    data: {type:type,fid:id},
                    dataType: 'json',
                    beforeSend: function(){
                        $("span#"+fullID).html("<img src=\"../images/icons/busy.gif\">");
                        //d3.select("span#"+fullID).append("img").attr("src","../images/icons/busy.gif");
                    },
                    success: function(data2){
                        if(data2.success==="true"){
                            var img="<img src=\"../images/success.png\">";
                            if(data2.status==="false"){
                                img="<img src=\"../images/error.png\">";   
                            }
                            $("span#"+fullID).html(img);
                            if(type="share"){
                                if(data2.status==="false"){
                                    $("span#shareUser"+id).hide();
                                }else{
                                    $("span#shareUser"+id).show();
                                }
                            }
                        }else{
                            d3.select("span#"+fullID).append("text").text(data2.Message);
                        }
                    },
                    error: function(xhr, status, error) {
                            console.log(error);

                    }
                });
        }
        function getSharedFiles(){
            $.ajax({
				url: "getFiles.jsp",
   				type: 'GET',
				data: {type:"sharedFiles"},
				dataType: 'json',
                                success: function(data2){
                                        try{
                                            shareFileDataTable.destroy();
                                        }catch(err){
                                            
                                        }
                                        d3.select("table#sharedFiles").select("tbody").select('tr#sharedloading').remove();
                                        var tracktbl=d3.select("table#sharedFiles").select("tbody").selectAll('tr').data(data2,key);
                                        tracktbl.enter().append("tr")
                                                        .attr("id",function(d){return "fid"+d.FileID;})
                                                        .attr("class",function(d,i){var ret="odd";if(i%2===0){ret="even";} return ret;});
                                        tracktbl.exit().remove();
                                        tracktbl.each(function(d,i){
                                                d3.select(this).selectAll("td").remove();
                                                var ind=d.Path.lastIndexOf("/");
                                                var file=d.Path.substr(ind+1);
                                                var fileLink="<a href=\""+d.Path+"\"> "+file+ " </a>";
                                                var timeShort=d.Time.substr(0,d.Time.lastIndexOf(":"));
                                                        d3.select(this).append("td").html(d.Owner);
                                                        d3.select(this).append("td").html(fileLink);
                                                        d3.select(this).append("td").html(d.Description);
                                                        d3.select(this).append("td").html(timeShort);
                                                        
                                        });
                                        
                                        shareFileDataTable=$('table#sharedFiles').DataTable({
                                            "bPaginate": false,
                                            "aaSorting": [[ 3, "desc" ]],
                                            "sDom": '<"rightSearch"fr><t>'
                                        });
                                        setTimeout(getSharedFiles, 30000);
                                },
                                error: function(xhr, status, error) {
                                        console.log(error);
                                        setTimeout(getSharedFiles, 240000);
                                }
            });
            
        }
</script>

