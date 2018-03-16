	<%@ include file="adaptive_headTags.jsp" %>
    
	<body>
		<div id="page_header_wide">
    		<div id="header_title" style="width:100%;">
            	<a href="<%=contextPath%>">PhenoGen Informatics</a>
            	<div style=" font-size:12px;">The site for quantitative genetics of the transcriptome.</div>
                <div class="header_status">
                        <div class="search" style="width:350px;float:right;position:relative;top:-74px;">
                                        <script>
                                        (function() {
                                          var cx = '002251072100941693273:nciuczz1ipg';
                                          var gcse = document.createElement('script');
                                          gcse.type = 'text/javascript';
                                          gcse.async = true;
                                          gcse.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') +
                                              '//cse.google.com/cse.js?cx=' + cx;
                                          var s = document.getElementsByTagName('script')[0];
                                          s.parentNode.insertBefore(gcse, s);
                                        })();
                                      </script>
                                      <gcse:search></gcse:search>
                        </div>
                    </div>
            </div>
	  	</div> <!-- page_header -->
		
		<div id="body_wrapper_plain">
       

	<%@ include file="/web/common/alertMsgDisplay.jsp"  %>
	<%@ include file="/web/common/toolbarStuff.jsp" %>

