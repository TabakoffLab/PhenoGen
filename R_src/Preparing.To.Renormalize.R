########################## Preparing.To.Renormalize.R ################
#
#  This function eliminates strains from preset data sets that do not 
#    have an associated phenotype in preparation to be renormalized
#
# Parms:
#    InputPhenoFile	= name of Rdata file that contains phenotype data (from Phenotype.ImportTxt.R)
#    InputRawDataFile	= name of Rdata file that has raw data for preset strain collection 
#    OutputRawDataFile  = name of Rdata file that will be sent to normalization program
#
# Returns:
#    nothing
#
# Writes Out:
#    .Rdata file (OutputRawDataFile) containing All.ReadCell object  
#
# Sample Call:
#    Preparing.To.Renormalize(InputPhenoFile = 'PhenoData.Rdata', InputRawDataFile = 'Combine.BioC.Binary.BXD.Rdata', OutputRawDataFile = 'New.Combine.BioC.Binary.Rdata')
#
#
#  Function History
#     8/21/2007   Laura Saba  Created
#
####################################################


Preparing.To.Renormalize<-function(InputPhenoFile, InputRawDataFile, OutputRawDataFile){

  ################# Housekeeping ############################

        # set up libraries and R functions needed
	library(affy)

  #######################################
  # Load Input Files
  #
	load(InputPhenoFile)
	load(InputRawDataFile)

  #######################################
  # Limit data to only groups with phenotype information
  #

	index <- (grouping==phenotype$grp.number[1])
	for(i in 2:length(phenotype$grp.number)){
  		index <- index + (grouping==phenotype$grp.number[i])
  	}

	if (exists('All.ReadCell')){
		All.ReadCell <- All.ReadCell[,as.logical(index)]
		save(All.ReadCell,file=OutputRawDataFile)
	}

	if (exists('chip.info')){
		chip.info$type.flag <- chip.info$type.flag[,as.logical(index)]
		chip.info$exp.value <- chip.info$exp.value[,as.logical(index)]
		chip.info$norm.exp.value <- chip.info$norm.exp.value[,as.logical(index)]
		chip.info$gs.flag <- chip.info$gs.flag[,as.logical(index)]
		chip.info$codelink.flag <- chip.info$codelink.flag[,as.logical(index)]
		chip.info$bg.mean <- chip.info$bg.mean[,as.logical(index)]
		sample.names <- sample.names[as.logical(index)]
		save(sample.names, chip.info, file =OutputRawDataFile)
	}
	
		

} ## END OF: function block
