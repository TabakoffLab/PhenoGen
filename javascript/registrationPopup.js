//SETTING UP OUR POPUP
//0 means disabled; 1 means enabled;
var popupStatus = 0;

//loading popup with jQuery magic!
function loadPopup(){
	//loads popup only if it is disabled
	if(popupStatus==0){
		$("#backgroundPopup").css({
			"opacity": "0.7"
		});
		$("#backgroundPopup").fadeIn("slow");
		$("#popupContact").fadeIn("slow");
		popupStatus = 1;
	}
}

//disabling popup with jQuery magic!
function disablePopup(){
	//disables popup only if it is enabled
	if(popupStatus==1){
		$("#backgroundPopup").fadeOut("slow");
		$("#popupContact").fadeOut("slow");
		popupStatus = 0;
	}
	 $('#selfPIRadio1').attr('checked', true);
}

//centering popup
function centerPopup(){
	//request data for centering
	var windowWidth = document.documentElement.clientWidth;
	var windowHeight = document.documentElement.clientHeight;
	var popupHeight = $("#popupContact").height();
	var popupWidth = $("#popupContact").width();
	//centering
	
	
}

//CONTROLLING EVENTS IN jQuery
$(document).ready(function(){
	
	//LOADING POPUP
	//Click the button event!
	$("#button").click(function(){
		//centering with css
		centerPopup();
		//load popup
		loadPopup();
		 $("#piReport").html("");
		 document.getElementById("piFirstName").value="";
		 document.getElementById("piLastName").value="";
		 
	});
	
	
	$("#getPI").click(function(){
		$piFirstName = document.getElementById("piFirstName").value;
		$piLastName = document.getElementById("piLastName").value;			
			
		$('#selfPIRadio2').attr('checked', true);
           
		$.get("../../UserLookupServlet", {piFirstName:$piFirstName, piLastName:$piLastName}, function(xml) {
			if ($("multipleMatches",xml).text() == 'true') {
				$("#piReport").html("Multiple matches were found. Please refine your search");
					
			} else if ($("userID", xml).text() <= 0) {
				$("#piReport").html("No Principal Investigator found with that name");
			} else {			        
				$("#piReport").html(" ").append(
					"PI found. <div><a>Choose "+
					$("firstName",xml).text() + " " + 
					$("lastName",xml).text() +"</a></div>").
					click(function () { 
						$("#selectedPI").html($("firstName",xml).text() + " " +$("lastName",xml).text() ); 
						$('#selfPIRadio1').attr('checked', true);disablePopup();
					});	
				document.getElementById("pi_user_id").value = $("userID", xml).text();
			}
		});
	});
		
		
	$("#useSelf").click(function(){
		$("#selectedPI").html("Self");
		document.getElementById("pi_user_id").value = "-99";
		$('#selfPIRadio1').attr('checked', true);
		disablePopup();
	});
		
		
	$("#useSelfOnUpdate").click(function(){
		$("#selectedPI").html("Self");
		document.getElementById("pi_user_id").value = document.getElementById("initial_pi_user_id").value;
		   
		$('#selfPIRadio1').attr('checked', true);
		disablePopup();
	});
		
	$("#termscheckbox").click(function(){
		if ($('#termscheckbox').is(':checked')){		   
			$("#registerSubmitBtn").removeAttr("disabled");
		} else {
			$("#registerSubmitBtn").attr("disabled", "disabled"); 
		}
	});
				
	//CLOSING POPUP
	//Click the x event!
	$("#popupContactClose").click(function(){
		disablePopup();
	});
	//Click out event!
	$("#backgroundPopup").click(function(){
		disablePopup();
	});
	//Press Escape event!
	$(document).keypress(function(e){
		if(e.keyCode==27 && popupStatus==1){
			disablePopup();
		}
	});

});
