function initializeArrayDetailsTab(){
       //setting up the default setting and event handlers for tabbed navigation in arrayDetails.jsp
       $('#arrayDetailsTab div').hide();
       $('#arrayDetailsTab div:first').show();
       $('#arrayDetailsTab ul li:first').addClass('active');
       $('#arrayDetailsTab ul li:first').addClass('selected');
   
       $('#arrayDetailsTab ul li a').click(function() {    
            $('#arrayDetailsTab ul li').removeClass('active');
            $('#arrayDetailsTab ul li').removeClass('selected');
       
            $(this).parent().addClass('active'); 
            $(this).parent().addClass('selected');
            var currentTab = $(this).attr('href'); 
            $('#arrayDetailsTab div').hide();
       
            $(currentTab).show();
			
            return false;
        });
}
