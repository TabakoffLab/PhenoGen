function IsCreateGeneListFormComplete(formName){
	
        if (jQuery.trim(formName.gene_list_name.value) == '') {        
                alert('You must name the gene list.')
                formName.gene_list_name.focus();
                return false;
        }
		
        if (jQuery.trim(formName.description.value) == '') {
                alert('You must provide a description of the gene list.')
                formName.description.focus();
                return false;
        }
		
        var regExp = new RegExp("[/]");
        if (regExp.test(formName.gene_list_name.value)) {
                alert('A gene list name cannot contain forward slashes ("/")')
                formName.gene_list_name.focus();
                return false;
        }
		
        return true;
}

