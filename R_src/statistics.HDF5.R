########################## statistics.R ################
#
# This function computes the statistics on the filtered genes in the input data
#
# Parms:
#    InputFile  = name of input file containing Absdata, Avgdata,  
#                     Gnames, grouping, groups, Snames, Procedure
#                     (OutputFile from Affy.filter.genes)
#	 VersionPath = Version/Date/Time of dataset to use since .h5 files will have multiple versions per file and multiple filter/statistics results per version.
#	 SampleFile= File with Sample Names so that they can be read in--Unfortunately h5r has problems reading strings in.
#    GeneNumberFile = name of output file for # of genes 
#    	
#    Stat.method  = 'parametric' | 'nonparametric'
#
# Returns:
#    nothing
#
# Writes out:
#    .h5 file (OutputFile) containing Absdata, Avgdata, 
#                     Gnames, grouping, groups, Snames, p, Procedure
#    text file (GeneNumberFile) containing gene count
#
# Sample Call:
#    statistics.HDF5(InputFile = 'Affy.NormVer.h5', Version='v1', Stat.method = 'parametric', GeneNumberFile = 'HapLap.GeneNumberCount.txt', Run.At.Home = F)
#
#
#  Function History
#     ?????????   Tzu Phang   Created      
#     3/21/2005   Diane Birks Modified: added logging via writelog
#	5/1/06	Laura Saba	Modified: added group means and pvalues (both raw and adjusted to output)
#	12/5/06	Laura Saba	Modified: consolidated Affymetrix and CodeLink programs
#	3/30/07	Laura Saba	Modified: added row names to stat output
#	12/14/07	Laura Saba	Modified: added code for when only one gene is passed to this program as input
#	12/31/07	Laura Saba	Modified: created temporary group variable to create groups labeled 1 and 2 (problem in renormalized public experiments)
#	3/1/12	Spencer Mahaffey Modified: Read/Write to .h5 file
#
####################################################


statistics.HDF5 <- function(InputFile, VersionPath, SampleFile, Stat.method, GeneNumberFile, Run.At.Home = F) {


  ###################################################
  ###################################################
  ###				          ###################
  ### 	START OF PROGRAM	    ###################
  ###				          ###################
  ###################################################
  ###################################################

  ################# Housekeeping ############################

        # set up libraries and R functions needed

  library(coin)
  fileLoader(c('tzu.wilcox.test.R','tzu.t.test.R'))

	# set up logging

  if(!Run.At.Home) logflag=G_WriteLogAffyStats

  #################################################
  ## Import data	
  ##						
	
  #load(InputFile)
  
  vPath<-strsplit(x=VersionPath,split='/',fixed=TRUE)
	Version<-vPath[[1]][1]
	Day<-vPath[[1]][2]
	exactTime<-vPath[[1]][3]
	#load(InputFile)
	
	require(h5r)
	h5 <- H5File(InputFile, mode = "w")
	gVersion<-getH5Group(h5, Version)
	gFilters<-getH5Group(gVersion, "Filters")
	gDay<-getH5Group(gFilters,Day)
	gFVer<-getH5Group(gDay,exactTime)
	ds <- getH5Dataset(gFVer, "fData")
	Avgdata<-array(dim=c(dim(ds)[1],dim(ds)[2]))
	Avgdata[,]<-ds[1:dim(ds)[1],1:dim(ds)[2]]
	ps <- getH5Dataset(gFVer, "fProbeset")
	Gnames<-ps[]

	ins <- scan(SampleFile, list(""))
	Snames<-ins[[1]]
	rownames(Avgdata)<-Gnames
	colnames(Avgdata)<-Snames
	gs <- getH5Dataset(gVersion, "Grouping")
	grouping<-gs[1:attr(gs,"dims")[1]]
	#Don't need to load as it is not being used
	groups <- list()
	for(i in 1:max(grouping)) groups[[i]]<-which(grouping==i)
	#dabg <- getH5Dataset(gVersion, "DABGPval")
	#DabgVal<-array(dim=c(dim(d)[1],dim(d)[2]))
	#DabgVal[,]<-dabg[1:dim(d)[1],dim(d)[2]]
	#Absdata <- (DabgVal<0.0001)*2 - 1
	
	
  #################################################
  ## Change group numbering to be 1 and 2	(only applicable when a renormalized data set)
  ##	

  a<-sort(unique(grouping)[unique(grouping)!=0])

  tmp.grouping<-grouping
  tmp.grouping[tmp.grouping==a[1]] <- 1
  tmp.grouping[tmp.grouping==a[2]] <- 2	

  tmp.groups<-list()
  for(i in 1:max(tmp.grouping)) tmp.groups[[i]]<-which(tmp.grouping==i)
				
  #################################################
  ## Statistical Analysis
  ##	

  if(length(Gnames) != 1){

	n <- dim(Avgdata)[1] 
	p <- rep(0,n)

	if(Stat.method == 'parametric'){
		if(!Run.At.Home){
			writelog(flag=logflag,'running t.test analysis ....')
		}else{
			cat('running t.test analysis ....\n\n')
		}
		stats<- apply(Avgdata, 1, tzu.t.test, agroup=tmp.groups[[1]], bgroup=tmp.groups[[2]])
		p<-stats[3,]	
	}
	else if(Stat.method == 'nonparametric'){
		if(!Run.At.Home){
			writelog(flag=logflag,'running ranksum analysis ....')
		}else{
			cat('running ranksum analysis ....\n\n')
		}
		stats<- apply(Avgdata, 1, tzu.wilcox.test, tmp.grouping)
		p<-stats[3,]
	}
	else{
		if(!Run.At.Home){
			writelog(flag=logflag,'ERROR - invalid statistical option of ',Stat.method,'must be parametric or nonparametric !')
		}else{
			cat('ERROR - invalid statistical option of ',Stat.method,'must be parametric or nonparametric !\n\n')
		}
	}

	rownames(stats)<-c(paste("Group",a[1],".means",sep=""),paste("Group",a[2],".means",sep=""),"raw.p.value")
	
  }

  else if(length(Gnames)==1){

	n <- 1 
	p <- 0

	if(Stat.method == 'parametric'){
		stats<- tzu.t.test(Avgdata, agroup=tmp.groups[[1]], bgroup=tmp.groups[[2]])
		p<-stats[3]	
	}
	else if(Stat.method == 'nonparametric'){
		stats<- tzu.wilcox.test(Avgdata, tmp.grouping)
		p<-stats[3]
	}
	else{
		if(!Run.At.Home){
			writelog(flag=logflag,'ERROR - invalid statistical option of ',Stat.method,'must be parametric or nonparametric !')
		}else{
			cat('ERROR - invalid statistical option of ',Stat.method,'must be parametric or nonparametric !\n\n')
		}
	}
	names(stats)<-c(paste("Group",a[1],".means",sep=""),paste("Group",a[2],".means",sep=""),"raw.p.value")

  }


  Procedure <- paste('Function=statistics.R',';','Stat.method=',Stat.method,sep = '')
  createH5Attribute(gFVer, "statMethod", Procedure, overwrite = TRUE)
  cat(file = GeneNumberFile, length(Gnames))
  RowNames<-""
	for( tmp in rownames(stats)){
		RowNames<-paste(RowNames,tmp,sep=",")
	}
	createH5Attribute(gFVer, "statRowNames",RowNames, overwrite = TRUE)

	createH5Dataset(gFVer,"Statistics",stats,dType="double",chunkSizes=c(dim(stats)[1],dim(stats)[2]),overwrite=T)
	createH5Dataset(gFVer,"Pval",p,dType="double",chunkSizes=c(length(p)),overwrite=T)

  ##save(Absdata, Avgdata, Gnames, grouping, groups, Snames, stats, p, Procedure,  file = OutputFile, compress = T)
	
}  #### END 
