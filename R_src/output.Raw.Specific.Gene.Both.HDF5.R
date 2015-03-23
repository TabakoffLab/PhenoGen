########################## output.Raw.Specific.Gene.R ################
#
# This function outputs to a file the raw data associated with the probe
#   sets in the user defined set of probe set IDs
#
# Parms:
#    InputFile      = name of input file containing Absdata, Avgdata, 
#                         Gnames, grouping, groups, Snames, Procedure, 
#                         (OutputFile from Affy.ExportOutBioC.R or
#                          CodeLink.ExportOutBioC.R)
#	 VersionPath	= Version/Date/Time of dataset to use since .h5 files will have multiple versions per file and multiple filter/statistics results per version.
#	 SampleFile		= name of file containing a list of samples(1/line)
#    GeneList	  = name of txt file with list of genes of interest
#    Platform	  = which platform was used ('CodeLink' 'Affymetrix')
#    OutputFile  = name of output file for raw data
#    TypeOutput	  = individual values or means ('Individual' 'Group')
#
# Returns:
#    nothing
#
# Writes out:
#    text file   (OutputRawData) containing expression data for data in gene list
#
# Sample Call:
#    output.Raw.Specific.Gene(InputFile = 'ExportOutBioC.output.Rdata',GeneList="GenesOfInterest.txt",Platform="CodeLink",OutputFile = 'SpecificGene.output.withRaw.txt',TypeOutput="Individual")
#
#  Function History
#	3/16/07	Laura Saba	Created
#	4/12/07	Laura Saba	Modified:  Added ability to get group means/standard
#						errors instead of individual values
#	4/18/07	Laura Saba	Modified: 	Adjusted calculation of standard error to
#							to accomodate data from correlation
#	8/24/07	Laura Saba	Modified:	Updated to account for groups variable in preset experiments
#	12/17/08	Laura Saba	Modified:	Updated code for when only one sample per group
#	08/24/10	Laura Saba	Modified:	Corrected error in matching group names
#	10/29/10	Laura Saba	Modified:	Corrected grouping error when a group has no members
#	11/3/10		Laura Saba	Modified:	Corrected error when the input GOI list doesn't completely match data
#	3/1/12	Spencer Mahaffey Modified: Read/Write HDF5 files.
#	3/8/12		Spencer Mahaffey Modified: Support multiple filters/stats per version.
# 3/13/15   Spencer Mahaffey Modified: Changed HDF5 methods to rHDF5 methods from h5r due to dropped support of h5r
#
####################################################


 output.Raw.Specific.Gene.Both.HDF5 <- function(InputFile, VersionPath, SampleFile, GeneList, Platform, OutputFileIndiv, OutputFileGroup){


  ###################################################
  ###################################################
  ###				          ###################
  ### 	START OF PROGRAM	    ###################
  ###				          ###################
  ###################################################
  ###################################################

	###  Function needed to calculate group standard errors
	summary.stderr<-function(Avgdata,groups){
		StdErr=c()
		for (g in 1:length(groups)){
			if (length(groups[[g]])>0){
				StdErr <- cbind(StdErr,sd(as.numeric(Avgdata[groups[[g]]]),na.rm=TRUE)/sqrt(length(groups[[g]])))
			}
		}
		return(StdErr)
	}

	summary.means<-function(Avgdata,groups){
		Means=c()
		for (g in 1:length(groups)){
			if (length(groups[[g]])>0){
				Means <- cbind(Means,mean(as.numeric(Avgdata[groups[[g]]]),na.rm=TRUE))
			}
		}
		return(Means)
	}

  #################################################
  ## process data
  #################################################

	fileLoader('tzu.NumToChar.R')

	#load(InputFile)
	
	#vPath<-strsplit(x=VersionPath,split='/',fixed=TRUE)
	Version<-VersionPath
	#Day<-vPath[[1]][2]
	#exactTime<-vPath[[1]][3]
	
  require(rhdf5)
  h5 <- H5Fopen (InputFile)
  gVersion<-H5Gopen(h5, Version)
  
  ins <- scan(SampleFile, list(""))
  Snames<-ins[[1]]
  
  did <- H5Dopen(gVersion, "Probeset")
  sid <- H5Dget_space(did)
  ps <- H5Dread(did,bit64conversion='double')
  H5Dclose(did)
  H5Sclose(sid)
  Gnames<-ps[]
  
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
  dabgds <- H5Dread(did)
  H5Dclose(did)
  H5Sclose(sid)
  dabgds=t(dabgds)
  DabgVal<-array(dim=c(dim(dabgds)[1],dim(dabgds)[2]))
  DabgVal[,]<-dabgds[1:dim(dabgds)[1],1:dim(dabgds)[2]]
  Absdata <- (DabgVal<0.0001)*2 - 1
  rownames(Absdata)<-Gnames
  colnames(Absdata)<-Snames

	

	###  Read in list of Genes
	GOI <- read.table(GeneList,sep="\t")
	row.names(GOI)<-GOI[,1]

	

	###  Attach appropriate sample names to CodeLink data and remove non-Discovery probes	
	if(Platform=="CodeLink"){
		samples <- unlist(strsplit(as.character(Snames),"/"))
		pickoff <- length(samples)/length(Snames)*c(1:length(Snames))
		samples <- samples[pickoff]
		Snames<-samples
     	 	colnames(Absdata)<-Snames
     		rownames(Absdata)<-Gnames

		filter.index = rep(0,dim(Discovery)[1])
		for(i in 1:dim(Discovery)[1]){
			filter.index[i] = Discovery[i,1]
		}
		filter.index = as.logical(filter.index)
		Avgdata <- Avgdata[filter.index,]
		Absdata <- Absdata[filter.index,]
	}

	###  Pull raw data for genes of interest
	WithRaw <- merge(GOI,Avgdata,by="row.names")
	rownames(WithRaw) <- WithRaw[,1]
	WithRaw <- WithRaw[,3:ncol(WithRaw)]
	
	###  Output individual intensity values and present/absent calls
		###  Pull present/absent calls for genes of interest
		Calls <- merge(GOI,Absdata,by="row.names")
		rownames(Calls) <- Calls[,1]
		Calls <- Calls[,3:ncol(Calls)]
		colnames(Calls)<-paste(Snames,"Call",sep=".")
		Calls <- t(apply(Calls, 1, tzu.NumToChar))

		###  Format Expression Data
		WithRaw<-format(WithRaw,digits=2,nsmall=2)
		
		###  Attach calls to raw data
		WithCalls <- merge(WithRaw,Calls,by="row.names")
		colnames(WithCalls)[1]<-"ProbeID"

		###  Output txt file with individual values and calls
		write.table(WithCalls,file=OutputFileIndiv,sep="\t",row.names=FALSE,quote=FALSE)

	
	###  Output Group Means and Standard Errors

		group.list <- sort(unique(grouping))
		
		###  Calculate Group Means
		GroupMeans <- apply(WithRaw,1,summary.means,groups=groups)
		
		###  Calculate Group Standard Errors
		GroupStdErr <- apply(WithRaw,1,summary.stderr,groups=groups)

		###  Create a file with mean and standard error together for each group
		GroupSpecific = labels = c()
		for(k in 1:length(group.list)){
			GroupSpecific <- cbind(GroupSpecific,GroupMeans[k,],GroupStdErr[k,])
			labels<-cbind(labels,paste("Group",group.list[k],"Mean",sep="."),paste("Group",group.list[k],"StdErr",sep="."))
			}
		
		###  Remove Groups with No Observations
		labels <- labels[,!is.na(GroupSpecific[1,])]
		GroupSpecific <- matrix(GroupSpecific[,!is.na(GroupSpecific[1,])],byrow=FALSE,nrow=nrow(GroupSpecific))

		###  Format Means and Standard Errors
		GroupSpecific<-format(GroupSpecific,digits=2,nsmall=2)

		###  Attach label
		GroupSpecific<-cbind(colnames(GroupStdErr),GroupSpecific)
		colnames(GroupSpecific)<-c("ProbeID",labels)

		###  Output txt file with Group Means and Standard Errors
		write.table(GroupSpecific,file=OutputFileGroup,sep="\t",row.names=FALSE,quote=FALSE)

}
## END
