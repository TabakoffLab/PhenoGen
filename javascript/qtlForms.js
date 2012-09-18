        var qtlArray = new Array();
        function IsFormComplete(form) {
                if (form.qtlListID.value == '-99') {
                        alert('Select a QTL list.')
                        form.qtlListID.focus();
                        return false;
                }
        }

        function displayQTLs(form) {
                var output = "";
                qtl_list_id = form.qtlListID.value;
                for (var i=0; i<qtlArray.length; i++) {
                        if (qtlArray[i].qtl_list_id == qtl_list_id) {
                                output = output + "Locus ID: " + qtlArray[i].locus_name +
                                                ", Chromosome: " + qtlArray[i].chromosome +
                                                ", " + qtlArray[i].range_start + " bp - " +
                                                qtlArray[i].range_end + " bp" + "\n";
                        }
                }
                form.qtlOutput.value = output;
        }

        function displayQTLsByQTLListID(qtl_list_id) {
                var output = "";
                for (var i=0; i<qtlArray.length; i++) {
                        if (qtlArray[i].qtl_list_id == qtl_list_id) {
                                output = output + "Locus ID: " + qtlArray[i].locus_name +
                                                ", Chromosome: " + qtlArray[i].chromosome +
                                                ", " + qtlArray[i].range_start + " bp - " +
                                                qtlArray[i].range_end + " bp" + "\n";
                        }
                }
        }

        function qtl(qtl_list_id, locus_name, chromosome, range_start, range_end) {
                this.qtl_list_id = qtl_list_id;
                this.locus_name = locus_name;
                this.chromosome = chromosome;
                this.range_start = range_start;
                this.range_end = range_end;
        }

function AreYouSureToDelete(){
	if (confirm('Are you sure you want to delete the selected items?')) { 
		return true;
	} else {
		return false;
	}
}

