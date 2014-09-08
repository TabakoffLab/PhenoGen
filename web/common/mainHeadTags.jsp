<!DOCTYPE html>
<html>
  <head>
  	<meta charset="UTF-8">
    <title>PhenoGen <%if(pageTitle!=null && !pageTitle.equals("")){%>- <%=pageTitle%> <%}%></title>
    <meta http-equiv="content-language" content="en-us">
    <meta http-equiv="expires" content="<%= new java.util.Date()%>">
    <meta http-equiv="Cache-Control" content="no-cache">
    <%if(pageDescription!=null && !pageDescription.equals("")){%> 
    	<meta name="description" content="<%=pageDescription%>"> 
	<%}%>
	<script type = "text/javascript" >
		var contextPath = "<%=request.getContextPath()%>";
	</script>

