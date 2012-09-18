<!--  

GOOGLE ANALYTICS SCRIPT 
Delete to remove google analytics.

This is the only file with Google Analytics

-->
<script type="text/javascript">

  var _gaq = _gaq || [];
  //production
  //_gaq.push(['_setAccount', 'UA-28815410-1']);
  //test
  _gaq.push(['_setAccount', 'UA-28815411-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>


</head>

<%
    String selectedMain = request.getAttribute( "selectedMain" ) == null ? 
		"" : (String) request.getAttribute( "selectedMain" );

%>
