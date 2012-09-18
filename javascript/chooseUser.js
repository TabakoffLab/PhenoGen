/* --------------------------------------------------------------------------------
 *
 *  specific functions for chooseUser.jsp
 *
 * -------------------------------------------------------------------------------- */

function setupChooseUserPage(){
        $("#findUser").click(function(){
           
            $piFirstName = document.getElementById("piFirstName").value;
            $piLastName = document.getElementById("piLastName").value;
            $('#detailsDisplay').html("");
            
            $.get("../../UserLookupServlet", {piFirstName:$piFirstName, piLastName:$piLastName}, function(xml) {
                   $("#userID").val($("userID",xml).text());
                   if ($("multipleMatches", xml).text() == 'true') {
                        $("#userDetails").html("Multiple matches were found. Please refine your search");
                   }
                   else if ($("userID", xml).text() <= 0) {
                        $("#userDetails").html("No user found with that name");
                   }
                   else {								   
                        $("#userDetails").html("User found. <div><a href='#'>Choose " + $("firstName", xml).text() + " " + $("lastName", xml).text() + "</a></div>");
                   }
            });            
        });
		
		
	$("#userDetails").click(function(){
		$("#userDetails").html("");
		$('#detailsDisplay').load( '/PhenoGen/web/experiments/grantArrayAccess.jsp', 
			{ userId: $("#userID").val(), 
                        experimentID: $("#experimentID").val(), 
                        experimentName : $("#experimentName").val()});
        });
		
}

