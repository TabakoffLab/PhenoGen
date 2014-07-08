
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


		$(".tooltip").tooltipster({
				position: 'top-left',
				maxWidth: 350,
				offsetX: 0,
				offsetY: 80,
				contentAsHTML:true,
				//arrow: false,
				interactive: true,
				interactiveTolerance: 550
			});