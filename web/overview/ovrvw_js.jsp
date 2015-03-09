<script type="text/javascript">
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
                $(".tooltip2").tooltipster({
                        position: 'top-right',
                        maxWidth: 350,
                        offsetX: 5,
                        offsetY: 5,
                        contentAsHTML:true,
                        //arrow: false,
                        interactive: true,
                        interactiveTolerance: 550
                });
</script>