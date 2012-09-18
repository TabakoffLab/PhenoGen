/* --------------------------------------------------------------------------------
 *
 *  specific functions for grantArrayAccess.jsp
 *
 * -------------------------------------------------------------------------------- */

function setupGrantAccessPage() {
   
	stripeTable($("table[name='grantAccessitems']").find("tr").not(".title, .col_title"));
	hoverRows($("table[name='grantAccessitems']").find("tr").not(".title, .col_title"));
 
	var tablesorterSettings = { widgets: ['zebra'], headers: { 0: { sorter: false } }  };
  
	$("table[id='grantAccessitems']").tablesorter(tablesorterSettings);
          
	$("tr.clickable").click(function() {
		if ($(this).find("td:first input").is(":checked")){
			$(this).find("td:first input").removeAttr("checked");
			$("input[type='checkbox']").val(0);
		} else {
			$("input[type='checkbox']").val(-1);
			$(this).find("td:first input").attr("checked","checked");
		} 
	});
   
	$("#grantAll").click(function(){
		$("input[type='checkbox']").each(function() {
			//the check for form name is to prevent the chechboxes in publishExperiment.jsp from being selected					  
			if (this.form.name == 'grantArrayAccess') {
				if (this.checked) {
					this.value = 0;
					this.checked = false;
					$("#grantAll").attr('checked', false);
				} else {
					this.value = -1; 
					this.checked = true;
					$("#grantAll").attr('checked', true);
				}
			}
		});
	});
}

