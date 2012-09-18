<%

String experimentName = (String) request.getParameter("experimentName");
String experimentID   = (String) request.getParameter("experimentID");

//extrasList.add("chooseUser.js");

%>
<center>
<br/>
<br/>	

This will grant open access to the arrays in experiment <br/>
<b><%= experimentName %></b>
<br/>
<br>
<form action="publishExperiment.jsp" name="confirmGrantAccessToPublic" method="post" >
	
Are You sure?
	
	<input type="hidden" name="experimentID" value="<%= experimentID %>" />
	
	<br><br>
	
	
	<input type="submit" value="  Yes  "/>
	
	<div class="closeWindow">Close</div> 
	

</form>

</center>
