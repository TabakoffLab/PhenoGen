<%@ include file="/web/access/include/login_vars.jsp" %>
<%
	String whichHelp = (request.getParameter("which") == null ? "None" : request.getParameter("which"));
	String fileName = "/helpdocs/";
        if (whichHelp.equals("moreMATools")) {
                fileName=fileName + "MoreMicroarrayTools.htm";
        } else if (whichHelp.equals("moreGLTools")) {
                fileName=fileName + "MoreGeneListTools.htm";
        } else {
                fileName=fileName + "None.htm";
	}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en-US">
<head>
    <title>PhenoGen Informatics Help</title>

    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />

    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/main.css" type="text/css" media="screen" />
</head>

<body>

<style>
    div.printPage {
        font-size: 12pt;
        letter-spacing: 2px;
        float: left;
    }

    div.printPage b b b{
        background: transparent url("<%=imagesDir%>icons/printer.gif") no-repeat scroll left center;
        padding-left: 23px;
    }
</style>

  <div class="printPage button" onclick="window.print()" title="Print this page"><b><b><b>Print</b></b></b></div>

    <div style="clear: left;">

    <table cellspacing="0" cellpadding="0" border="0" width="100%">
      <tr>

        <td style="padding: 15px;" width="100%">
		<jsp:include page="<%=fileName%>" flush="true"/>
	</td>

      </tr>
    </table>

  </div>

</body>
</html>
