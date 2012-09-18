########################## outputGeneList.WithRaw.R ################
#
# This function outputs to a file the raw data associated with the probe
#   sets in the current gene list
#
# Parms:
#    
#    InputFile      = name of HDF5 input file containing Absdata, Avgdata, 
#                         Gnames, grouping, groups, Snames, p, Procedure, 
#                         GenebankID, kw.p, ttest.p, adjp
#                         (OutputFile from Affy.multipleTest)
#    VersionPath = Version/Date/Time of dataset to use since .h5 files will have multiple versions per file and multiple filter/statistics results per version.
#	 SampleFile = name of file containing a list of samples(1/line)
#	OutputRawData  = name of output file for raw data
#
# Returns:
#    nothing
#
# Writes out:
#    text file   (OutputRawData) containing expression data for data in gene list
#
# Sample Call:
#    outputGeneList.withRaw(InputFile = 'Affy.NormVer.h5', Version='v1',OutputGeneList = 'HapLap.genetext.output.withRaw.txt', Run.At.Home = F)
#
#  Function History
#	6/9/06	Laura Saba	Created
#	12/4/06	Laura Saba	Modified: consolidated separate CodeLink and Affymetrix programs
#	3/1/12	Spencer Mahaffey Modified: Read/Write HDF5 files.
#	3/8/12		Spencer Mahaffey Modified: Support multiple filters/stats per version.
#	7/18/12		Spencer Mahaffey Modified: Now gets MultiTest param with gene count if <=0 skips rest of script to avoid errors.
#
####################################################


 outputGeneList.withRaw.HDF5 <- function(InputFile, VersionPath, SampleFile, OutputGeneList, Run.At.Home = F){


  ###################################################
  ###################################################
  ###				          ###################
  ### 	START OF PROGRAM	    ###################
  ###				          ###################
  ###################################################
  ###################################################


  #################################################
  ## process data
  #################################################

	##load(InputFile)
	vPath<-strsplit(x=VersionPath,split='/',fixed=TRUE)
	Version<-vPath[[1]][1]
	Day<-vPath[[1]][2]
	exactTime<-vPath[[1]][3]
	
	require(h5r)
	h5 <- H5File(InputFile, mode = "w")
	gVersion<-getH5Group(h5, Version)
	gFilters<-getH5Group(gVersion, "Filters")
	gDay<-getH5Group(gFilters,Day)
	gFVer<-getH5Group(gDay,exactTime)
	gMulti<-getH5Group(gFVer,"Multi")
	count<-getH5Attribute(gMulti,"count")
	# if count=0 don't need to output anything.
	if(count[1]>0){
		ins <- scan(SampleFile, list(""))
		Snames<-ins[[1]]
		
		ps <- getH5Dataset(gMulti, "mProbeset")
		Gnames<-ps[]
		
		ds <- getH5Dataset(gMulti, "mData")
		Avgdata<-array(dim=c(dim(ds)[1],dim(ds)[2]))
		Avgdata[,]<-ds[1:dim(ds)[1],1:dim(ds)[2]]
		rownames(Avgdata)<-Gnames
		colnames(Avgdata)<-Snames
	
	
		gs <- getH5Dataset(gVersion, "Grouping")
		grouping<-gs[1:attr(gs,"dims")[1]]
		groups <- list()
		for(i in 1:max(grouping)) groups[[i]]<-which(grouping==i)
		
		pvs <- getH5Dataset(gMulti, "mPval")
		p<-pvs[]
		
		ss <- getH5Dataset(gMulti, "mStatistics")
		stats<-array(dim=c(dim(ss)[1],dim(ss)[2]))
		stats[,]<-ss[1:dim(ss)[1],1:dim(ss)[2]]
		
		srn<-getH5Attribute(gFVer,"statRowNames")
		namelist=strsplit(x=srn[1],split=',',fixed=TRUE)
		adjnamelist<-namelist[[1]]
		rownames(stats)<-adjnamelist[2:length(adjnamelist)]
		colnames(stats)<-Gnames	
		
		adjpvs <- getH5Dataset(gMulti, "adjp")
		adjp<-adjpvs[]
	
		if(length(Gnames)>1){
	
	            header.row<-c("ProbeID",as.character(Snames))
			for.text<-rbind(header.row,cbind(Gnames,format(Avgdata,nsmall=3,digits=4)))
			write.table(for.text, file = OutputGeneList, append = FALSE, sep = '\t',row.names = FALSE,quote=FALSE,col.names=FALSE)	
	
			
		}
	
		else if(length(Gnames)==1){
	
	            header.row<-c("ProbeID",as.character(Snames))
			for.text<-rbind(header.row,cbind(Gnames,t(format(Avgdata,nsmall=3,digits=4))))
			write.table(for.text, file = OutputGeneList, append = FALSE, sep = '\t',row.names = FALSE,quote=FALSE,col.names=FALSE)	
			
		}
	
		################################
		# else: length of Gnames == 0
	
		else{
			
			stats = 'No statistically significant gene was selected'
				
			
			cat(stats, file = OutputGeneList, append = FALSE, sep = '\n')	
			
		}

	}#End if(count[1]>0)

	
} ## END       
	
