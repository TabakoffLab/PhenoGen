    
    <script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery-1.11.2.min.js"></script>
    <script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery-migrate-1.2.1.min.js"></script>
    <script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery-ui-1.11.4.min.js"></script>
    <script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery.tooltipster.min.js"></script>
    <script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/jquery.tablesorter.js"></script>
    <script type = "text/javascript" src = "<%=request.getContextPath()%>/javascript/main1.0.js"></script>

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
			
			$('span.info').tooltipster({
				position: 'top-right',
				maxWidth: 250,
				offsetX: 10,
				offsetY: 5,
				interactive: true,
				interactiveTolerance: 350,
				contentAsHTML:true
			});

			/*var tooltipSettings = { showBody : " - ",
                				track : true,
                                        	delay: 250,
                                        	showURL: false,
                                        	top: -45,
                                        	left: 10,
                                        	extraClass: "extra_class"
                                        	};
			$("span.info").tooltip( tooltipSettings );*/

			tablesorterSettings = { widgets: ['zebra'] };
			$("table.tablesorter").tablesorter(tablesorterSettings);
        	});
	</script>
