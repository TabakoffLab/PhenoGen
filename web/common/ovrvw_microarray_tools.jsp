<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<% extrasList.add("index.css"); %>
<%pageTitle="Overview Microarray Analysis Tools";
pageDescription="Overview of available Microarray Analysis Tools";
 %>

<%@ include file="/web/common/basicHeader.jsp" %>
<jsp:useBean id="myArray" class="edu.ucdenver.ccp.PhenoGen.data.Array"> </jsp:useBean>

<%
			int totalPublicArrays = 2130;
			if(dbConn!=null){
				edu.ucdenver.ccp.PhenoGen.data.Array.ArrayCount[] myArrayCounts = myArray.getArrayCount(dbConn);
				totalPublicArrays=myArrayCounts[0].getPublicCount();
			}
%>

        <div id="welcome" style="height:575px; width:980px; overflow:auto;">

	<h2>Microarray Tools</h2>
	
	<div id="overview-wrap" >
                	<div id="overview-content">
				<p>Whether you use your data or ours, this site contains a comprehensive toolbox 
				for microarray analysis.  You can:</p>
				<ul>
				<li> 
					<div class="clicker" name="branch5"> Analyze your own expression data 
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> 
					</div> 
					<span class="branch" id="branch5"> 
					Upload your own raw expression data from Affymetrix or CodeLink mRNA arrays 
					and use our tools to complete quality control, normalization, filtering, and 
					analysis in a few point-and-click steps.
					</span>
				<li> <div class="clicker" name="branch6"> Analyze our public expression data 
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch6">
					Download or analyze any of the <%=totalPublicArrays%> microarrays currently 
					available to the public, including our brain expression data from 20 inbred mouse strains, 89 recombinant inbred
					mouse strains (30 BXD and 59 LXS), 26 recombinant inbred rat strains (HXB/BXH), and our data from liver, heart, 
                    and brown adipose tissue from 21 recombinant inbred rat strains(HXB/BXH). 
					</span>
				<li> <div class="clicker" name="branch7"> Correlate your phenotype data (e.g. blood pressure) with our expression data 
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch7">
					Correlate the expression data from our panels of inbred strains to a 
					phenotype collected in your lab or available from other sources.  Our four panels 
					available for public use consist of whole brains from males 
					for: (a) 20 inbred mouse strains, (b) 30 recombinant inbred mouse strains (BXD),
					(c) 26 recombinant inbred rat strains (HXB/BXH), and (d) 59 recombinant inbred mouse strains(LXS). 
					</span>
				<li> <div class="clicker" name="branch10"> View expression levels of your favorite gene(s)
						&nbsp;&nbsp;&nbsp;<img src="<%=imagesDir%>icons/next.png" alt="more"> </div> 
					<span class="branch" id="branch10">
					Look to see if your favorite gene is differentially expressed in any 
					of our public data sets.  For example, see if Gnb1 is differentially expressed 
					in the whole brain of C57BL/6J and DBA/2J mice or see which of the 
					inbred strains of mice show the highest and lowest expression of Adcy7.
					</span>
				</ul>

				<br/>
				<BR />
                    <BR />
                    <a href="<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>listDatasets.jsp" class="button" style="margin: 0 0 0 40px; width:150px;">Get Started</a>

                	</div> <!-- // end overview-content -->
            	</div> <!-- // end overview-wrap -->
                
                </div> <!-- // end welcome -->
                
 <script type="text/javascript">
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
<%@ include file="/web/common/footer.jsp" %>
