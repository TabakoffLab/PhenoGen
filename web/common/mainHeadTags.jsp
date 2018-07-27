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
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script >
        var contextPath = "<%=contextPath%>";
    </script>

