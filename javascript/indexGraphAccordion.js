
		$('#accordion').accordion({ heightStyle: "fill" });
		console.log("selected index:"+selectedSection);
		if(selectedSection && selectedSection>-1){
			$( "#accordion" ).accordion( "option", "active", selectedSection );
		}