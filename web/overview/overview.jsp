



<style>
	div.header_status{display:none;}
</style>

<%
       String url="";
	   if(request.getParameter("ovwPage")!=null){
			url=request.getParameter("ovwPage");
	   }
%>
			
			

	
	<div id="index">
    	        

    	<!--<div id="primary-content">-->
        <div id="welcome" style="height:1125px; width:996px;">
			<h1 id="index" class="homePage">Welcome to PhenoGen Informatics</h1>    
            <H2> The site for quantitative genetics of the transcriptome.</h2>
            <div>
            	<%if(url.equals("glPathway.jsp")){%>
                	<%@ include file="/web/overview/glPathway.jsp" %>
                <%}else if(url.equals("glValues.jsp")){%>
                	<%@ include file="/web/overview/glValues.jsp" %>
                <%}else if(url.equals("glCorr.jsp")){%>
                	<%@ include file="/web/overview/glCorr.jsp" %>
                <%}else if(url.equals("glAnnot.jsp")){%>
                	<%@ include file="/web/overview/glAnnot.jsp" %>
                <%}else if(url.equals("glPromoter.jsp")){%>
                	<%@ include file="/web/overview/glPromoter.jsp" %>
                <%}else if(url.equals("glShare.jsp")){%>
                	<%@ include file="/web/overview/glShare.jsp" %>
                <%}else if(url.equals("glHomolog.jsp")){%>
                	<%@ include file="/web/overview/glHomolog.jsp" %>
                <%}else if(url.equals("glMultiMir.jsp")){%>
                	<%@ include file="/web/overview/glMultiMir.jsp" %>
                <%}else if(url.equals("microAnalysis.jsp")){%>
                	<%@ include file="/web/overview/microAnalysis.jsp" %>
                <%}else if(url.equals("microUpload.jsp")){%>
                	<%@ include file="/web/overview/microUpload.jsp" %>
                <%}else if(url.equals("microShare.jsp")){%>
                	<%@ include file="/web/overview/microShare.jsp" %>
                <%}else if(url.equals("microPublic.jsp")){%>
                	<%@ include file="/web/overview/microPublic.jsp" %>
                <%}else if(url.equals("browseGene.jsp")){%>
                	<%@ include file="/web/overview/browseGene.jsp" %>
                <%}else if(url.equals("browseRegion.jsp")){%>
                	<%@ include file="/web/overview/browseRegion.jsp" %>
                <%}else if(url.equals("browseTranslate.jsp")){%>
                	<%@ include file="/web/overview/browseTranslate.jsp" %>
                <%}else if(url.equals("downloadMarker.jsp")){%>
                	<%@ include file="/web/overview/downloadMarker.jsp" %>
                <%}else if(url.equals("downloadHumanSNP.jsp")){%>
                	<%@ include file="/web/overview/downloadHumanSNP.jsp" %>
                <%}else if(url.equals("downloadMicroarray.jsp")){%>
                	<%@ include file="/web/overview/downloadMicroarray.jsp" %>
                <%}else if(url.equals("downloadRNASeq.jsp")){%>
                	<%@ include file="/web/overview/downloadRNASeq.jsp" %>
                <%}else if(url.equals("downloadGenome.jsp")){%>
                	<%@ include file="/web/overview/downloadGenome.jsp" %>
                <%}else if(url.equals("qtlViz.jsp")){%>
                	<%@ include file="/web/overview/qtlViz.jsp" %>
                <%}else if(url.equals("qtlCalc.jsp")){%>
                	<%@ include file="/web/overview/qtlCalc.jsp" %>
                <%}else if(url.equals("qtlList.jsp")){%>
                	<%@ include file="/web/overview/qtlList.jsp" %>
                <%}else if(url.equals("announce.jsp")){%>
                	<%@ include file="/web/overview/announce.jsp" %>
                <%}else if(url.equals("curVer.jsp")){%>
                	<%@ include file="/web/overview/curVer.jsp" %>
                <%}else if(url.equals("whats_new.jsp")){%>
                	<%@ include file="/web/overview/whats_new.jsp" %>
                <%}%>
           </div>
             <div id="ack">
                       <h3 style="margin:10px;">Acknowledgements</h3>
                        <H4 style="margin:10px;">Funding</H4>
                        <p>We would like to thank the National Institue on Alcohol Abuse and Alcoholism (<a href="http://www.niaaa.nih.gov/">NIAAA</a>) for continued funding to develop and support this site.  The Banbury Fund for supporting the development of this site.</p>
                        <h4 style="margin:10px;">Recombinant Inbred Panels</h4>
                        <p>We are grateful to the following investigators for providing the recombinant inbred panels found on the site.<BR />
                        HXB/BXH Rat RI Panel was provided by <a href="http://pharmacology.ucsd.edu/faculty/printz.html">Morton Printz</a>(UC San Diego).<BR />
                        ILSXISS Mouse RI Panel was provided by <a href="http://ibgwww.colorado.edu/tj-lab/">Thomas Johnson</a>(CU Boulder) and John DeFries (CU Boulder).</p>
           </div>
		</div>
    	<!--</div>--> <!-- // end primary-content -->
        

  	</div> <!-- end index -->
	
	</div> <!-- // end site-wrap -->
    
    </div>
    </div>

    	<script type="text/javascript">
			$("#closeBTN").on("click",function(){
				$('div#indexDesc').hide();
			});
        	$(document).ready(function(){	
            		$("div.clicker").click(function(){
                		var thisHidden = $( "span#" + $(this).attr("name") ).is(":hidden");
                		var tabTriggers = $(this).parents("ul").find("span.branch").hide();
                		var baseName = $(this).attr("name");
				$("span#" + baseName).removeClass("clickerLess");
                		if ( thisHidden ) {
					$("span#" + baseName).show().addClass("clickerLess");
				}
				$("div."+baseName).removeClass("clicker");
				$("div."+baseName).addClass("clickerLess");
            		});
					
        	});
		
	</script>

