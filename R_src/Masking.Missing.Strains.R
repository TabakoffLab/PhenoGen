########################## Masking.Missing.Strains.R ################
#
# This function creates an RData file containing the grouped absolute call and
#   normalized information as well as species info
# 
# Parms:
#    InputDataFile = input file name of normalization rdata 
#                    (Data that has already been normalized with all strains)
#    InputPhenoFile = input file name of phenotype rdata 
#                    (data from Phenotype.ImportTxt)
#    OutputFile = output file name for grouped combined data 
#
# Returns:
#    nothing
#
# Writes out:
#    .rdata file (OutputFile) of grouped combined data containing
#              Avgdata, Absdata, Snames, Gnames
#
# Sample Call:
#    Masking.Missing.Strains(InputDataFile = 'Inbred.RMA.Rdata', InputPhenoFile = 'Phenotype.output.Rdata', OutputFile = 'ExportOutBioC.output.Rdata')
#
#
#  Function History
#     	4/18/07	Laura Saba	Created 
#	8/7/07	Laura Saba 	Modified:  Changes made to allow for new structure of phenotype file  
#	8/22/07	Laura Saba	Modified:  Renamed from ExportBioC.Corr.R 
#	9/10/07	Laura Saba	Modified:  Removed "stray" code?  
#	8/10/09	Laura Saba	Modified:  Removed assignment of 'Correlation' to procedure variable
#
####################################################


Masking.Missing.Strains<-function(InputDataFile, InputPhenoFile, OutputFile){

	load(InputDataFile)
	load(InputPhenoFile)

	index <- (grouping==phenotype$grp.number[1])
	for(i in 2:length(phenotype$grp.number)){
  		index <- index + (grouping==phenotype$grp.number[i])
  	}

	Orig.Num.Strains <- max(grouping)

	if (sum(index)!=length(index) && !exists('Discovery')){

		Avgdata<-Avgdata[,as.logical(index)]
		Absdata<-Absdata[,as.logical(index)]
		Snames<-Snames[as.logical(index)]
		grouping<-grouping[as.logical(index)]

		groups<-list()
		unique<-unique(grouping)
		for(i in 1:Orig.Num.Strains) groups[[i]]<-which(grouping==i)
	
		save(Absdata, Avgdata, Gnames, Snames, grouping, groups, Procedure, file = OutputFile, compress = T)
	}

	if (sum(index)!=length(index) && exists('Discovery')){

		Avgdata<-Avgdata[,as.logical(index)]
		Absdata<-Absdata[,as.logical(index)]
		Discovery<-Discovery[,as.logical(index)]
		GS.call<-GS.call[,as.logical(index)]
		Snames<-Snames[as.logical(index)]
		grouping<-grouping[as.logical(index)]

		groups<-list()
		for(i in 1:Orig.Num.Strains) groups[[i]]<-which(grouping==i)

		save(chip.info, Avgdata, Discovery, Absdata, GS.call, Gnames, Snames, grouping, groups, Procedure, file = OutputFile)
	}

	if (sum(index)==length(index) && !exists('Discovery')){
		save(Absdata, Avgdata, Gnames, Snames, grouping, groups, Procedure, file = OutputFile, compress = T)
	}

	if (sum(index)==length(index) && exists('Discovery')){
		save(chip.info, Avgdata, Discovery, Absdata, GS.call, Gnames, Snames, grouping, groups, Procedure, file = OutputFile)
	}




}  ## END OF: Function block
