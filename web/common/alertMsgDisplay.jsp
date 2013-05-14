<% 
	log.debug("alertMsgExists = "+alertMsgExists);
	if (alertMsgExists) { 
		String screenSize = (session.getAttribute("screenSize") != null ? 
				(String) session.getAttribute("screenSize") : "");
		int width = (!screenSize.equals("") && screenSize.equals("big") ? 850 : 500); 
		int height = (!screenSize.equals("") && screenSize.equals("big") ? 600 : 300); 
		String position = (!screenSize.equals("") && screenSize.equals("big") ? "150,80" : "250,150");
	
		//log.debug("alertMsgExists");
%>
		<script>
			var msgDialog;
			$(document).ready(function() {
				msgDialog = createDialog("div.alertMsg", 
					{autoOpen:true, 
					width: <%=width%>,
					height: <%=height%>,
					title: "Message", 
					position: [<%=position%>]}).dialog("open");
				closeDialog(msgDialog);
			});
		</script>

		<div class="alertMsg"> 
			<%=alertMsg%>
			<div class="closeWindow">Close</div>
		</div>
<% 
		session.removeAttribute("screenSize");
		session.removeAttribute("successMsg");
		session.removeAttribute("additionalInfo");
		session.removeAttribute("errorMsg");
	} 
%>

