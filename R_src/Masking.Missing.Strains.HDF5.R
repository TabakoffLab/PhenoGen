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
# 3/13/15   Spencer Mahaffey Modified: Changed HDF5 methods to rHDF5 methods from h5r due to dropped support of h5r
#
#
####################################################


Masking.Missing.Strains.HDF5<-function(InputDataFile,VersionPath,SampleFile, InputPhenoFile, OutputFileHDF,OutputFileSamples){

	#load(InputDataFile)	
	
	#open HDF5 file
	require(h5r)
	h5 <- H5File(InputDataFile, mode = "w")
	gVersion<-getH5Group(h5, VersionPath)
	ds <- getH5Dataset(gVersion, "Data")
	Avgdata<-array(dim=c(dim(ds)[1],dim(ds)[2]))
	Avgdata[,]<-ds[1:dim(ds)[1],1:dim(ds)[2]]
	ps <- getH5Dataset(gVersion, "Probeset")
	Gnames<-ps[]

	ins <- scan(SampleFile, list(""))
	Snames<-ins[[1]]
	rownames(Avgdata)<-Gnames
	colnames(Avgdata)<-Snames
	gs <- getH5Dataset(gVersion, "Grouping")
	grouping<-gs[1:attr(gs,"dims")[1]]
	groups <- list()
	for(i in 1:max(grouping)) groups[[i]]<-which(grouping==i)
	dabg <- getH5Dataset(gVersion, "DABGPval")
	DabgVal<-array(dim=c(dim(dabg)[1],dim(dabg)[2]))
	DabgVal[,]<-dabg[1:dim(dabg)[1],dim(dabg)[2]]
	Absdata <- (DabgVal<0.0001)*2 - 1
	rownames(Absdata)<-Gnames
	colnames(Absdata)<-Snames

	
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
	
		#save(Absdata, Avgdata, Gnames, Snames, grouping, groups, Procedure, file = OutputFile, compress = T)
	}

	#if (sum(index)!=length(index) && exists('Discovery')){

	#	Avgdata<-Avgdata[,as.logical(index)]
	#	Absdata<-Absdata[,as.logical(index)]
	#	Discovery<-Discovery[,as.logical(index)]
	#	GS.call<-GS.call[,as.logical(index)]
	#	Snames<-Snames[as.logical(index)]
	#	grouping<-grouping[as.logical(index)]

	#	groups<-list()
	#	for(i in 1:Orig.Num.Strains) groups[[i]]<-which(grouping==i)

		#save(chip.info, Avgdata, Discovery, Absdata, GS.call, Gnames, Snames, grouping, groups, Procedure, file = OutputFile)
	#}

	#if (sum(index)==length(index) && !exists('Discovery')){
	#	save(Absdata, Avgdata, Gnames, Snames, grouping, groups, Procedure, file = OutputFile, compress = T)
	#}

	#if (sum(index)==length(index) && exists('Discovery')){
	#	save(chip.info, Avgdata, Discovery, Absdata, GS.call, Gnames, Snames, grouping, groups, Procedure, file = OutputFile)
	#}
	
	
	
	h5out <- H5File(OutputFileHDF, mode = "w")
	gVersionOut<-createH5Group(h5out, VersionPath,overwrite=T)
	gFilterOut<-createH5Group(gVersionOut, "Filters",overwrite=T)
	createH5Dataset(gVersionOut,"DABGPval",DabgVal,dType="double",chunkSizes=c(dim(DabgVal)[1],dim(DabgVal)[2]),overwrite=T)
	createH5Dataset(gVersionOut,"Data",Avgdata,dType="double",chunkSizes=c(dim(Avgdata)[1],dim(Avgdata)[2]),overwrite=T)
	createH5Dataset(gVersionOut,"Grouping",grouping,dType="integer",chunkSizes=(length(grouping)),overwrite=T)
	createH5Dataset(gVersionOut,"Probeset",Gnames,dType="integer",chunkSizes=c(length(Gnames)),overwrite=T)
	createH5Dataset(gVersionOut,"Samples",Snames,dType="character",chunkSizes=c(length(Snames)),overwrite=T)

	sampFile <- file(OutputFileSamples,"w")
	write(Snames, file=sampFile)
	close(sampFile)

}  ## END OF: Function block
