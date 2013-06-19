
		$('#accordion').accordion({ heightStyle: "fill" });
		//console.log("selected index:"+selectedSection);
		if(selectedSection && selectedSection>-1){
			$( "#accordion" ).accordion( "option", "active", selectedSection );
		}
		$('.fancybox').fancybox({
    helpers : {
        title: {
            type: 'inside',
            position: 'top'
        },
		thumbs	: {
				width	: 200,
				height	: 100
			}
    },
    nextEffect: 'fade',
    prevEffect: 'fade'
});