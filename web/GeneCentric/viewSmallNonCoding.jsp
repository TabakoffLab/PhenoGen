<%@ include file="/web/common/session_vars.jsp" %>

<%  String[] smncList=null;
	String[] nameList=null;
	String name="";
	String smnc="";
	int smncID=0;
	SmallNonCodingRNA rna;

	if(request.getParameter("id")!=null){
		smncID=Integer.parseInt(request.getParameter("id").toString());
	}
	if(request.getParameter("idList")!=null){
		smnc=request.getParameter("idList");
		smncList=smnc.split(",");
		if(request.getParameter("id")==null){
			smncID=Integer.parseInt(smncList[0]);
		}
		if(request.getParameter("name")!=null){
			name=request.getParameter("name");
			nameList=name.split(",");
		}
	}
	rna=new SmallNonCodingRNA(smncID,dbConn,log);
	
%>
<script type="text/javascript">
	var idList="<%=smnc%>";
	var nameList="<%=name%>";
	var id=<%=smncID%>;
</script>
<script src="<%=contextRoot%>javascript/processing-1.4.1.min.js"></script>
<div id="smncContent" style=" text-align:center;">
<%if(smncList!=null&&smncList.length>0){%>
	<div style="text-align:left;">
    RNA-Seq Small RNA to View:
    <select name="smrnaSelect" id="smrnaSelect">
        <%for(int i=0;i<smncList.length;i++){%>
            <option value="<%=smncList[i]%>" <%if(Integer.toString(smncID).equals(smncList[i])){%>selected<%}%>><%=nameList[i]%></option>
        <%}%>
    </select>
    </div>
<%}%>

<H2 ><%="SMNC_"+rna.getID()%></H2> 

<BR />
<canvas id="sketch"></canvas>

<script type="text/javascript">
						var fileRequest = new window.XMLHttpRequest();
                        fileRequest.open("GET", "/web/GeneCentric/test2.pde", false);
                        fileRequest.send(null);
                        var canvas = document.getElementById("sketch");
                        var p = new Processing(canvas, fileRequest.responseText);
						p.setRefSeq("<%=rna.getRefSeq().toUpperCase()%>");
						p.setGenomeCoord(<%=rna.getStart()%>,<%=rna.getStop()%>,<%=rna.getChromosome()%>);
						<% ArrayList<RNASequence> seqList=rna.getSeq();
							for(int i=0;i<seqList.size();i++){
								RNASequence s=seqList.get(i);%>
								p.addSequence(<%=s.getOffsetFromReference()%>,"<%=s.getSequence()%>",<%=i%>);
						<%}%>
						<% ArrayList<SequenceVariant> vList=rna.getVariant();
							for(int i=0;i<vList.size();i++){
								SequenceVariant v=vList.get(i);%>
								p.addVariant(<%=v.getStart()%>,"<%=v.getStrainSeq()%>","<%=v.getStrain()%>");
						<%}%>
						p.draw();

</script>
<div>


<h2>Annotations</h2>
<% HashMap displayed=new HashMap();
                                    HashMap bySource=new HashMap();
									ArrayList<edu.ucdenver.ccp.PhenoGen.data.Bio.Annotation> annot=rna.getAnnotations();
									if(annot!=null&&annot.size()>0){
										for(int j=0;j<annot.size();j++){
												String tmpHTML=annot.get(j).getLongDisplayHTMLString(true);
												if(!displayed.containsKey(tmpHTML)){
													displayed.put(tmpHTML,1);
													if(bySource.containsKey(annot.get(j).getSource())){
														String list=bySource.get(annot.get(j).getSource()).toString();
														list=list+", "+tmpHTML;
														bySource.put(annot.get(j).getSource(),list);
													}else{
														bySource.put(annot.get(j).getSource(),tmpHTML);
													}
													
												}
										}
									}
                                    
                                    Set keys=bySource.keySet();
                                    Iterator itr=keys.iterator();
                                    while(itr.hasNext()){
                                        String source=itr.next().toString();
                                        String values=bySource.get(source).toString();
										if(!source.equals("mirDeep")){
                                    %>
                                        <%="<BR>"+source+":"+values%>
                                    <%}
									}
									if(bySource.get("mirDeep")!=null){%>
										<%="<BR>mirDeep:"+bySource.get("mirDeep").toString()%>
									<%}%>
</div>

<BR />
<BR />
<h2>Sequences</h2>
<table name="items" id="tblViewSMNC" class="list_base" cellpadding="0" cellspacing="0" width="100%">
	<thead>
    	<TR >
        	<TH colspan="3"></TH>
            <TH colspan="2" class="topLine leftBorder rightBorder">Perfect Match to Genome<span class="smncToolTip" title="An 'X' indicates that the base sequence aligns exactly (i.e. without any mismatches between bases) to the strain-specific genome."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
        </TR>
    	<TR class="col_title">
        	<TH>Read Sequences <span class="smncToolTip" title="Base sequences from reads generated using RNA-Seq of small (<200 nucleotide) RNA."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
            <TH>Total Read Counts <span class="smncToolTip" title="Number of reads with this base sequence generated from brain samples of 3 BN-Lx/CubPrin rats and 3 SHR/OlaPrin rats."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
            <TH># Alignments to Genome <span class="smncToolTip" title="The number of physical locations in the strain-specific genome to which this base sequence aligns."><img src="<%=imagesDir%>icons/info.gif"></span></TH>
            <TH>BN-Lx Genome</TH>
            <TH>SHRH Genome</TH>
        </TR>
    </thead>
    <tbody>
    	<% 
		for(int i=0;i<seqList.size();i++){
			RNASequence s=seqList.get(i);%>
            <TR>
                <TD><%=s.getSequence()%></TD>
                <TD><%=s.getReadCount()%></TD>
                <TD><%if(s.getUniqueAlignment()<=10){%>
						<%=s.getUniqueAlignment()%>
					<%}else{%>
                    	>10
					<%}%>
                </TD>
                <TD>
                	<%if(s.getStrainMatch("BNLX")){%>
                    	X
                    <%}%>
                </TD>
                <TD><%if(s.getStrainMatch("SHRH")){%>
                    	X
                    <%}%>
                </TD>
            <TR>
        <%}%>
        
    </tbody>
</table>


</div>

<script type="text/javascript">
function updateSmallNonCoding(idList,nameList,id){
			var params={idList: idList,name: nameList, id: id};
			$.ajax({
				url: contextPath + "/web/GeneCentric/viewSmallNonCoding.jsp",
   				type: 'GET',
				data: params,
				dataType: 'html',
    			success: function(data2){ 
        			$('#smncContent').html(data2);
    			},
    			error: function(xhr, status, error) {
        			$('#viewTrxDialog').html("<div>An error occurred generating this page.  Please try back later.</div>");
    			}
			});
}

	$('#smrnaSelect').change( function (){
		id=$(this).val();
		//alert(id);
		updateSmallNonCoding(idList,nameList,id)
	});
	
	$('.smncToolTip').tooltipster({
		position: 'top-right',
		maxWidth: 250,
		offsetX: 24,
		offsetY: 5,
		//arrow: false,
		interactive: true,
   		interactiveTolerance: 350
	});
	
	var tblSMNC=$('#tblViewSMNC').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"sScrollX": "900px",
	"sScrollY": "350px"
	});
	//tblSMNC.dataTable().fnAdjustColumnSizing();
	
	
	
	
</script>