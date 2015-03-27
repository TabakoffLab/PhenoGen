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
# 3/13/15   Spencer Mahaffey Modified: Changed HDF5 methods to rHDF5 methods from h5r due to dropped support of h5r
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
	
  
  require(rhdf5)
  h5 <- H5Fopen (InputFile)
  gVersion<-H5Gopen(h5, Version)
  gFilter<-H5Gopen(gVersion,"Filters")
  gDay<-H5Gopen(gFilter,Day)
  gFVer<-H5Gopen(gDay, exactTime)
  gMulti<-H5Gopen(gFVer, "Multi")
  aCount<-H5Aopen(gMulti,"count")
  count<-H5Aread(aCount)
  H5Aclose(aCount)
  
	if(count[1]>0){
		ins <- scan(SampleFile, list(""))
		Snames<-ins[[1]]
		
		did <- H5Dopen(gMulti,  "mProbeset")
		sid <- H5Dget_space(did)
		ps <- H5Dread(did)
		H5Dclose(did)
		H5Sclose(sid)
		Gnames<-ps[]
		
		did <- H5Dopen(gMulti,  "mData")
		sid <- H5Dget_space(did)
		ds <- H5Dread(did)
		H5Dclose(did)
		H5Sclose(sid)
		# transpose matrix as rhdf5 reads in datasets in the opposite orientation from h5r.  This prevents needing 
		# to change the rest of the code to use columns as probesets and rows as samples.  But this should be fixed
		# in the future as it wastes CPU time and Memory
		ds=t(ds)
		Avgdata<-array(dim=c(dim(ds)[1],dim(ds)[2]))
		Avgdata[,]<-ds[1:dim(ds)[1],1:dim(ds)[2]]
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
		
		did <- H5Dopen(gMulti,  "mPval")
		sid <- H5Dget_space(did)
		pvs <- H5Dread(did)
		H5Dclose(did)
		H5Sclose(sid)
		p<-pvs[]
		
		did <- H5Dopen(gMulti,  "mStatistics")
		sid <- H5Dget_space(did)
		ss <- H5Dread(did)
		H5Dclose(did)
		H5Sclose(sid)
		# transpose matrix as rhdf5 reads in datasets in the opposite orientation from h5r.  This prevents needing 
		# to change the rest of the code to use columns as probesets and rows as samples.  But this should be fixed
		# in the future as it wastes CPU time and Memory\
		ss=t(ss)
		stats<-array(dim=c(dim(ss)[1],dim(ss)[2]))
		stats[,]<-ss[1:dim(ss)[1],1:dim(ss)[2]]
		
		statRowName<-H5Aopen(gFVer,"statRowNames")
		srn<-H5Aread(statRowName)
		H5Aclose(statRowName)
    
		#srn<-getH5Attribute(gFVer,"statRowNames")
		namelist=strsplit(x=srn[1],split=',',fixed=TRUE)
		adjnamelist<-namelist[[1]]
		rownames(stats)<-adjnamelist[2:length(adjnamelist)]
		colnames(stats)<-Gnames	
		
		did <- H5Dopen(gMulti,  "adjp")
		sid <- H5Dget_space(did)
		adjpvs <- H5Dread(did)
		H5Dclose(did)
		H5Sclose(sid)
		#adjpvs <- getH5Dataset(gMulti, "adjp")
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
  
  
  H5Gclose(gMulti)
  H5Gclose(gFVer)
  H5Gclose(gDay)
  H5Gclose(gFilter)
  H5Gclose(gVersion)  
  H5Fclose(h5)
	
} ## END       
	
