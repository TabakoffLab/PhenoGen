
	<!-- Line 4673 of jquery-1.5.js and jquery-1.7.js(line 5432-5444) jquery1.8.3(7069-7079) has been modified. Do not forget to change in new file -->
	<!--<script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery-1.8.3.js"></script>-->
    <!--<script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery-1.9.1.min.js"></script>-->
    <script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery-1.10.2.min.js">
    <!--<script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery-migrate-1.1.1.min.js"></script>-->
    <script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery-migrate-1.1.1.js"></script>
	<script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery-ui-1.10.3.min.js"></script> 
	<script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery.tooltip.js"></script>

	<script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery.tablesorter.js"></script>
	<script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/main.js"></script>

	<%@ include file="/web/common/includeExtras.jsp" %>

	<script type = "text/javascript" >
        	//var crumbs;
        	var tablesorterSettings;

        	$(document).ready(function(){
            //		prepareCrumbTrail( crumbs );
			 // temporary solution to xml based sitemap 
			//or database page association or session based tracks.
        	
			
			setupIcons('<%=chosenOption%>');

            selectTab();
            /* setTimeout("setupMain()", 100); */

			var tooltipSettings = { showBody : " - ",
                				track : true,
                                        	delay: 250,
                                        	showURL: false,
                                        	top: -45,
                                        	left: 10,
                                        	extraClass: "extra_class"
                                        	};
			$("span.info").tooltip( tooltipSettings );

			tablesorterSettings = { widgets: ['zebra'] };
			$("table.tablesorter").tablesorter(tablesorterSettings);
        	});
	</script>
