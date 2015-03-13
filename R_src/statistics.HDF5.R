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
# 3/13/15   Spencer Mahaffey Modified: Changed HDF5 methods to rHDF5 methods from h5r due to dropped support of h5r
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
  require(rhdf5)
  h5 <- H5Fopen (InputFile,flags = h5default("H5F_ACC"))
  gVersion<-H5Gopen(h5, Version)
  gFVer<-H5Gopen(h5, VersionPath)
  did <- H5Dopen(gFVer,  "fData")
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
	
  did <- H5Dopen(gFVer,  "fProbeset")
  sid <- H5Dget_space(did)
  ps <- H5Dread(did)
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
  RowNames<-""
  for( tmp in rownames(stats)){
    RowNames<-paste(RowNames,tmp,sep=",")
  }
  cat(file = GeneNumberFile, length(Gnames))
  
  if(H5Aexists (gFVer, "statMethod")){
    H5Adelete (gFVer, "statMethod")
  }
  gSM <- h5createAttribute (gFVer, "statMethod")
  H5Awrite(gSM,Procedure)
  H5Aclose(gSM)
  #createH5Attribute(gFVer, "statMethod", Procedure, overwrite = TRUE)
  if(H5Aexists (gFVer, "statRowNames")){
    H5Adelete (gFVer, "statRowNames")
  }
  gSM <- h5createAttribute (gFVer, "statRowNames")
  H5Awrite(gSM,RowNames)
  H5Aclose(gSM)
	#createH5Attribute(gFVer, "statRowNames",RowNames, overwrite = TRUE)
  stats=t(stats)
  sid <- H5Screate_simple (dim(stats)[1],dim(stats)[2] )
  did <- H5Dcreate (gFVer,"Statistics", "H5T_IEEE_F64LE", sid)
  H5Dwrite(did,stats)
  H5Dclose(did)
  H5Sclose(sid)
	#createH5Dataset(gFVer,"Statistics",stats,dType="double",chunkSizes=c(dim(stats)[1],dim(stats)[2]),overwrite=T)
  sid <- H5Screate_simple (length(p))
  did <- H5Dcreate (gFVer,"Pval", "H5T_IEEE_F64LE", sid)
  H5Dwrite(did,p)
  H5Dclose(did)
  H5Sclose(sid) 
	#createH5Dataset(gFVer,"Pval",p,dType="double",chunkSizes=c(length(p)),overwrite=T)
  H5Gclose(gVersion)
  H5Gclose(gFVer)
  H5Fclose(h5)
  ##save(Absdata, Avgdata, Gnames, grouping, groups, Snames, stats, p, Procedure,  file = OutputFile, compress = T)
	
}  #### END 
