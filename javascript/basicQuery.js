/* --------------------------------------------------------------------------------
 *
 *  specific functions for basicQuery.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * * *
 *  this function sets up all the functionality for this page
/*/
function setupPage() {
	//fillOrganismModCombos();
	setupFinalizeDataset();
	//hideGeneticTypeField();
	var mod_options = '<option value="-99">Select an organism</option>';
	$("select[name='organism']").val("-99");
	$("select[name='geneticType']").html(mod_options);
	$("select[name='strain']").html(mod_options);
	$("select[name='cellLine']").html(mod_options);
	$("select[name='genotype']").html(mod_options);
	$("select[name='organismPart']").html(mod_options);
	$("select[name='arrayType']").html(mod_options);
	//hideStrainLineGenotypeField();
	disableField($("select[name='geneticType']"));
	disableField($("select[name='strain']"));
	disableField($("select[name='cellLine']"));
	disableField($("select[name='genotype']"));
	disableField($("select[name='organismPart']"));
	disableField($("select[name='arrayType']"));
}

var organismModCombos = new Array();
var organismModSLGCombos = new Array();
var organismModSLGTissueCombos = new Array();
var organismModSLGTissueChipCombos = new Array();

function organismModCombo(organism, geneticType) {
	this.organism = organism;
        this.geneticType = geneticType;
}

function organismModSLGCombo(organism, geneticType, slg) {
	this.organism = organism;
        this.geneticType = geneticType;
	this.slg = slg;
}

function organismModSLGTissueCombo(organism, geneticType, slg, organismPart) {
	this.organism = organism;
        this.geneticType = geneticType;
	this.slg = slg;
	this.organismPart = organismPart;
}

function organismModSLGTissueChipCombo(organism, geneticType, slg, organismPart, chip) {
	this.organism = organism;
        this.geneticType = geneticType;
	this.slg = slg;
	this.organismPart = organismPart;
	this.chip = chip;
}

function showGeneticTypeField() {
	var organism = $("select[name='organism']").val();
	var mod_options = '<option value="-99">-- Choose a genetic characterization -- </option>';
	for (var i=0; i<organismModCombos.length; i++) {
		if (organismModCombos[i].organism == organism && organismModCombos[i].geneticType != '') {
	        	mod_options += '<option value="' + organismModCombos[i].geneticType + '">' + organismModCombos[i].geneticType + '</option>';
		}
	}
	disableField($("select[name='strain']"));
	disableField($("select[name='cellLine']"));
	disableField($("select[name='genotype']"));
	disableField($("select[name='organismPart']"));
	disableField($("select[name='arrayType']"));
	enableField($("select[name='geneticType']"));
	$("select[name='geneticType']").html(mod_options);
	var slg_options = '<option value="-99">Select a genetic characterization</option>';
	$("select[name='strain']").html(slg_options);
	$("select[name='cellLine']").html(slg_options);
	$("select[name='genotype']").html(slg_options);
	$("select[name='organismPart']").html(slg_options);
	$("select[name='arrayType']").html(slg_options);
}

function showStrainLineGenotypeField() {
	var organism = $("select[name='organism']").val();
	var geneticType = $("select[name='geneticType']").val();
	var slg_options = '';
	//if (geneticType == "Genetically Modified") {
	if (geneticType == "Other") {
		slg_options = '<option value="All">-- Choose a genotype -- </option>';
	} else if (geneticType == "Inbred" || geneticType == "Recombinant Inbred") {
		slg_options = '<option value="All">-- Choose a strain -- </option>';
	} else if (geneticType == "Selectively Bred") {
		slg_options = '<option value="All">-- Choose a line -- </option>';
	}
	
	for (var i=0; i<organismModSLGCombos.length; i++) {
		if (organismModSLGCombos[i].organism == organism && organismModSLGCombos[i].organism != '' &&
			organismModSLGCombos[i].geneticType == geneticType && organismModSLGCombos[i].geneticType != '') {
	        	slg_options += '<option value="' + organismModSLGCombos[i].slg + '">' + organismModSLGCombos[i].slg + '</option>';
		}
	}
	disableField($("select[name='organismPart']"));
	disableField($("select[name='arrayType']"));
	//if (geneticType == "Genetically Modified") {
	$("select[name='strain']").html(slg_options);
	$("select[name='genotype']").html(slg_options);
	$("select[name='cellLine']").html(slg_options);
	if (geneticType == "Other") {
		disableField($("select[name='strain']"));
		disableField($("select[name='cellLine']"));
		enableField($("select[name='genotype']"));
	} else if (geneticType == "Inbred" || geneticType == "Recombinant Inbred") {
		enableField($("select[name='strain']"));
		disableField($("select[name='cellLine']"));
		disableField($("select[name='genotype']"));
	} else if (geneticType == "Selectively Bred") {
		disableField($("select[name='strain']"));
		enableField($("select[name='cellLine']"));
		disableField($("select[name='genotype']"));
	}
	var tissue_options = '';
	//if (geneticType == "Genetically Modified") {
	if (geneticType == "Other") {
		tissue_options = '<option value="All">Select a line</option>';
	} else if (geneticType == "Inbred" || geneticType == "Recombinant Inbred") {
		tissue_options = '<option value="All">Select a strain</option>';
	} else if (geneticType == "Selectively Bred") {
		tissue_options = '<option value="All">Select a genotype</option>';
	}
	
	$("select[name='organismPart']").html(tissue_options);
	$("select[name='arrayType']").html(tissue_options);
}

var slg = "All";
function getSLG() {
	var strain = $("select[name='strain']").val();
	var cellLine = $("select[name='cellLine']").val();
	var genotype = $("select[name='genotype']").val();
	if (strain != "All") {
		slg = strain; 
	} else if (cellLine != "All") {
		slg = cellLine; 
	} else if (genotype != "All") {
		slg = genotype; 
	}
}
function showTissueField() {
	var organism = $("select[name='organism']").val();
	var geneticType = $("select[name='geneticType']").val();
	var tissue_options = '<option value="All">-- Choose a tissue -- </option>';
	disableField($("select[name='arrayType']"));
	getSLG();
	for (var i=0; i<organismModSLGTissueCombos.length; i++) {
		if (organismModSLGTissueCombos[i].organism == organism && organismModSLGTissueCombos[i].organism != '' &&
			organismModSLGTissueCombos[i].geneticType == geneticType && organismModSLGTissueCombos[i].geneticType != '' &&
			organismModSLGTissueCombos[i].slg == slg && organismModSLGTissueCombos[i].slg != '') {
	        	tissue_options += '<option value="' + organismModSLGTissueCombos[i].organismPart + '">' + organismModSLGTissueCombos[i].organismPart + '</option>';
		}
	}
	enableField($("select[name='organismPart']"));
	$("select[name='organismPart']").html(tissue_options);
	var tissue_options = '<option value="All">Select a tissue</option>';
	$("select[name='arrayType']").html(tissue_options);
}

function showChipField() {
	var organism = $("select[name='organism']").val();
	var geneticType = $("select[name='geneticType']").val();
	getSLG();
	var organismPart = $("select[name='organismPart']").val();
	var chip_options = '<option value="All">-- Choose a platform -- </option>';
	for (var i=0; i<organismModSLGTissueChipCombos.length; i++) {
		if (organismModSLGTissueChipCombos[i].organism == organism && organismModSLGTissueChipCombos[i].organism != '' &&
			organismModSLGTissueChipCombos[i].geneticType == geneticType && organismModSLGTissueChipCombos[i].geneticType != '' &&
			organismModSLGTissueChipCombos[i].slg == slg && organismModSLGTissueChipCombos[i].slg != '' &&
			organismModSLGTissueChipCombos[i].organismPart == organismPart && organismModSLGTissueChipCombos[i].organismPart != '') {
	        	chip_options += '<option value="' + organismModSLGTissueChipCombos[i].chip + '">' + organismModSLGTissueChipCombos[i].chip + '</option>';
		}
	}
	enableField($("select[name='arrayType']"));
	$("select[name='arrayType']").html(chip_options);
}

function IsBasicQueryFormComplete(){
        if ($("select[name='organism']").val() == '-99') {
                alert('You must choose an organism.')
                $("select[name='organism']").focus();
                return false;
        } else if ($("select[name='geneticType']").val() == '-99') {
                alert('You must choose a genetic characterization.')
                $("select[name='geneticType']").focus();
                return false;
	}
        return true;
}
