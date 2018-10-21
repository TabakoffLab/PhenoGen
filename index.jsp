<%@ include file="/web/access/include/login_vars.jsp" %>
<%

	session.setAttribute("mainMenuSelected","");
	session.setAttribute("mainFunction","");
	session.setAttribute("mainFunctionStep","");
	
	//loggedIn = false;
	extrasList.add("landing.js");
	extrasList.add("d3.v3.5.16.min.js");
	extrasList.add("fancyBox/jquery.fancybox.js");
	extrasList.add("fancyBox/helpers/jquery.fancybox-thumbs.js");
	//extrasList.add("smoothness/jquery-ui.1.11.3.min.css");
	extrasList.add("jquery.fancybox.css");
	extrasList.add("jquery.fancybox-thumbs.css");
    request.setAttribute( "extras", extrasList);
%>

<%pageDescription="The site for quantitative genetics of the transcriptome";%>

<%@ include file="/web/common/basicHeader.jsp" %>



<%
        String msg = "";
        String callerMsg = "";
 
        	/*
			//May need to add back this is to keep user from opening another window
			if (contextRoot.equals("/PhenoGen/") || contextRoot.equals("/PhenoGenTEST/")) {
                	if ((String) session.getAttribute("userID") != null) {
                        	log.debug("user already logged in.  Invalidating session");
                        	mySessionHandler.setSession_id(session.getId());
                        	mySessionHandler.logoutSession(dbConn);
                        	session.invalidate();
                	}
        	}
			*/

        	callerMsg = "";
        	//log.debug("caller = " + caller);
        	//log.debug("this = " + "http://" + host + contextRoot + "index.jsp");

        	if (caller == null) {
                	//log.debug("caller is null");
        	} else if (caller.equals("http://" + host + contextRoot + "index.jsp") ||
                	caller.equals("http://" + host + contextRoot) ||
                	caller.equals("http://" + host + "/")) {
                	log.debug("caller is " + caller + " - possibly typed incorrect username/password combination");
        	} else if (caller.equals("http://" + host + helpDir + "gettingStarted.jsp") ||
                        	caller.equals("http://" + host + accessDir + "registration.jsp") ||
                        	caller.equals("http://" + host + commonDir + "successMsg.jsp") ||
                        	caller.equals("http://" + host + accessDir + "loginError.jsp") ||
                        	caller.equals("http://" + host + accessDir + "emailPassword.jsp") ||
                        	caller.equals("http://" + host + webDir + "iniaHome.jsp") ||
                        	caller.equals("http://" + host + commonDir + "iniaPartners.jsp") ||
                        	caller.equals("http://" + host + commonDir + "contact.jsp") ||
                        	!caller.startsWith("http://phenogen.uchsc.edu") ||
                        	caller.equals("http://" + host + accessDir + "logout.jsp")) {
                	callerMsg = "";
        	} else {
                	log.debug("session had expired");
                	//callerMsg = "Due to inactivity, your session has expired.  Please login again.";
                	session.setAttribute("loginErrorMsg", "Expired");
                	response.sendRedirect(accessDir + "loginError.jsp");
        	}
        	log.debug("caller = "+  caller + ", and callerMsg = "+ callerMsg);        
		formName = "index.jsp";
		actionForm = "index.jsp";
        	%>
			
			
        <div style="text-align:center;">
                 <!--Download the slides from the Informatics Workshop <a href="<%=webDir%>overview/PhenoGen.workshop.16Apr15.pdf">here</A>.-->
            Download the recent NIDA Meeting poster <a href="<%=webDir%>overview/NIDA_Jan_2018.pdf">here</a> .
        </div>
	
	<div id="index">
    	        

    	<!--<div id="primary-content">-->
        <div id="welcome" style="height:1690px; width:996px;">
			<h1 id="index" class="homePage">Welcome to PhenoGen Informatics</h1>    
            <H2> The site for quantitative genetics of the transcriptome.</h2>
            <div>
            	<%@ include file="/web/common/indexGraph.jsp" %>
           </div>
            <div id="survey" style="float:left;display:inline-block;width:600px;">
                <script>(function(t,e,s,n){var o,a,c;t.SMCX=t.SMCX||[],e.getElementById(n)||(o=e.getElementsByTagName(s),a=o[o.length-1],c=e.createElement(s),c.type="text/javascript",c.async=!0,c.id=n,c.src=["https:"===location.protocol?"https://":"http://","widget.surveymonkey.com/collect/website/js/tRaiETqnLgj758hTBazgdwCxF5qGs6PKZhZvk_2FUQJnw5h9X4UcSXH32_2BrHvLUSRg.js"].join(""),a.parentNode.insertBefore(c,a))})(window,document,"script","smcx-sdk");</script>
                <a style="font: 12px Helvetica, sans-serif; color: #999; text-decoration: none;" href=https://www.surveymonkey.com> Create your own user feedback survey </a>
            </div>
             <div style="float:right;display:inline-block;width:350px;" id="ack">
                 
                       <h3 style="margin:10px;">Acknowledgements</h3>
                        <H4 style="margin:10px;">Funding</H4>
                        <p>We would like to thank the National Institue on Alcohol Abuse and Alcoholism (<a href="http://www.niaaa.nih.gov/">NIAAA</a>) for continued funding to develop and support this site.  The Banbury Fund for supporting the development of this site.</p>
                        <H4 style="margin:10px;">Computational Resources</H4>
                        <p>We would like acknowledge the UNLV National Supercomputing Institute (<a href="https://www.nscee.edu/">UNLV NSI</a>) for access to 
                            supercomputing resources to support analysis of sequencing data.</p>
                        <h4 style="margin:10px;">Recombinant Inbred Panels</h4>
                        <p>We are grateful to the following investigators for providing the recombinant inbred panels found on the site.<BR />
                        <p>HXB/BXH Rat RI Panel was provided by <a href="http://www.fgu.cas.cz/en/departments/genetics-of-model-diseases">Michal Pravenec</a> (Czech Academy of Sciences) and <a href="http://pharmacology.ucsd.edu/faculty/printz.html">Morton Printz</a>(UC San Diego).<BR>
                            F344/LE Rat RI Panel was provided by <a href="http://www.med.kyoto-u.ac.jp/en/organization-staff/research/doctoral_course/r-022/">Masahide Asano</a>(National BioResource Project for the Rat in Japan).<BR>
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
                $(".search").css("top","4px");
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

    <%@ include file="/web/common/basicFooter.jsp" %>

