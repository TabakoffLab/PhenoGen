
function show_species_tissue(selSpecies) {
    document.exonCor.tissueCB.options.length=0;
    document.exonCor.genomeVer.options.length=0;
	
    if (selSpecies == 1) {
		document.exonCor.tissueCB.options[0]=new Option("Whole Brain","Brain");
		document.exonCor.tissueCB.options[1]=new Option("Heart","Heart");
		document.exonCor.tissueCB.options[2]=new Option("Liver","Liver");
		document.exonCor.tissueCB.options[3]=new Option("Brown Adipose","BAT");
                document.exonCor.genomeVer.options[0]=new Option("rn6","rn6");
                document.exonCor.genomeVer.options[1]=new Option("rn5","rn5");
    } else if (selSpecies == 0) {
		document.exonCor.tissueCB.options[0]=new Option("Whole Brain","Brain");
                document.exonCor.genomeVer.options[0]=new Option("mm10","mm10");
    } 

}

function displayWorking(){
	document.getElementById("wait1").style.display = 'block';
	document.getElementById("exonDirections").style.display = 'none';
	//CallJS('Demo(document.exonCor)');
	return true;
}

