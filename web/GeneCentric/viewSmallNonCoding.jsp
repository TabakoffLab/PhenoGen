<%@ include file="/web/common/session_vars.jsp" %>

<%  String[] smncList;
	int smncID=0;

	if(request.getParameter("id")!=null){
		smncID=Integer.parseInt(request.getParameter("id").toString());
	}
	if(request.getParameter()!=null){
		smncList
	}
	
	SmallNonCodingRNA rna=new SmallNonCodingRNA(smncID,dbConn,log);
%>
<script src="/javascript/processing-1.4.1.min.js"></script>


<div style=" text-align:center;">

<H2><%="SMNC_"+rna.getID()+"  chr"+rna.getChromosome()+":"+rna.getStart()+"-"+rna.getStop()%></H2>
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
                                    %>
                                        <%="<BR>"+source+":"+values%>
                                    <%}%>
</div>

<BR />
<BR />
<h2>Sequences</h2>
<table name="items" id="tblViewSMNC" class="list_base" cellpadding="0" cellspacing="0" width="100%">
	<thead>
    	<TR >
        	<TH colspan="3"></TH>
            <TH colspan="2" class="topLine leftBorder rightBorder">Perfect Match to Genome</TH>
        </TR>
    	<TR class="col_title">
        	<TH>Read Sequences</TH>
            <TH>Total Read Counts</TH>
            <TH># Alignments to Genome</TH>
            <TH>BNLX Genome</TH>
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
	var tblSMNC=$('#tblViewSMNC').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"sScrollX": "900px",
	"sScrollY": "350px"
	});
	tblSMNC.dataTable().fnAdjustColumnSizing();
</script>