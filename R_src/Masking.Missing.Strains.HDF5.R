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
# 10/30/14  Spencer Mahaffey Modified: Move from h5r to rhdf5 support since h5r has been discontinued.
#
#
####################################################


Masking.Missing.Strains.HDF5<-function(InputDataFile,VersionPath,SampleFile, InputPhenoFile, OutputFileHDF,OutputFileSamples){

	#load(InputDataFile)	
	
	#open HDF5 file
	require(rhdf5)
	h5 <- H5Fopen (InputDataFile, flags = h5default("H5F_ACC_RD"))
	gVersion<-H5Gopen(h5, VersionPath)

	did <- H5Dopen(gVersion,  "Data")
	sid <- H5Dget_space(did)
	ds <- H5Dread(did)
	H5Dclose(did)
	H5Sclose(sid)
	
	# transpose matrix as rhdf5 reads in datasets in the opposite orientation from h5r.  This prevents needing 
	# to change the rest of the code to use columns as probesets and rows as samples.  But this should be fixed
	# in the future as it wastes CPU time and Memory
	ds<-t(ds)
	Avgdata<-array(dim=c(dim(ds)[1],dim(ds)[2]))
	Avgdata[,]<-ds[1:dim(ds)[1],1:dim(ds)[2]]
  
  
  
	did <- H5Dopen(gVersion, "Probeset")
	sid <- H5Dget_space(did)
	ps <- H5Dread(did,bit64conversion='double')
	H5Dclose(did)
	H5Sclose(sid)
	Gnames<-ps[]

	ins <- scan(SampleFile, list(""))
	Snames<-ins[[1]]
	rownames(Avgdata)<-Gnames
	colnames(Avgdata)<-Snames
	
	did <- H5Dopen(gVersion,  "Grouping")
	sid <- H5Dget_space(did)
	gs <- H5Dread(did)
	H5Dclose(did)
	H5Sclose(sid)
	
	grouping<-gs[1:dim(gs)[1]]
	groups <- list()
	for(i in 1:max(grouping)) groups[[i]]<-which(grouping==i)
  
	did <- H5Dopen(gVersion,  "DABGPval")
	sid <- H5Dget_space(did)
	dabg <- H5Dread(did)
	H5Dclose(did)
	H5Sclose(sid)
	
	dabg <- t(dabgds)

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
	
	
	h5out <- H5Fcreate (OutputFileHDF, flags = h5default("H5F_ACC"))
	#h5out <- H5File(OutputFileHDF, mode = "w")
	gVersionOut <- H5Gcreate (h5out, VersionPath)
	#gVersionOut<-createH5Group(h5out, VersionPath,overwrite=T)
	gFilterOut <- H5Gcreate (gVersionOut, "Filters")
	#gFilterOut<-createH5Group(gVersionOut, "Filters",overwrite=T)
  sid <- H5Screate_simple (dim(DabgVal), dim(DabgVal) )
	H5Dcreate (gVersionOut, "DABGPval", "H5T_IEEE_F64LE", sid)
	#createH5Dataset(gVersionOut,"DABGPval",DabgVal,dType="double",chunkSizes=c(dim(DabgVal)[1],dim(DabgVal)[2]),overwrite=T)
	createH5Dataset(gVersionOut,"Data",Avgdata,dType="double",chunkSizes=c(dim(Avgdata)[1],dim(Avgdata)[2]),overwrite=T)
	createH5Dataset(gVersionOut,"Grouping",grouping,dType="integer",chunkSizes=(length(grouping)),overwrite=T)
	createH5Dataset(gVersionOut,"Probeset",Gnames,dType="integer",chunkSizes=c(length(Gnames)),overwrite=T)
	createH5Dataset(gVersionOut,"Samples",Snames,dType="character",chunkSizes=c(length(Snames)),overwrite=T)

	sampFile <- file(OutputFileSamples,"w")
	write(Snames, file=sampFile)
	close(sampFile)

}  ## END OF: Function block
