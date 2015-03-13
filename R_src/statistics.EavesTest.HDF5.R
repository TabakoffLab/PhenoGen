########################## statistics.EavesTest.R ################
#
# This function computes the Eaves test with duplicate experiments
#	on the filtered genes in the input data 
#
# Parms:
#    InputFile  	= name of input file containing Absdata, Avgdata,  
#                     Gnames, grouping, groups, Snames, Procedure
#                     (OutputFile from Affy.filter.genes)	
#	 Version = Version of dataset to use since .h5 file will have multiple versions per file.
#
#    pvalue		= alpha threshold for significance
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
#    statistics.EavesTest.HDF5(InputFile = 'Affy.NormVer.h5', Version='v1',GeneNumberFile='', pvalue=0.5)
#
#
#  Function History
#	3/13/2007	Laura Saba	Created
#	11/20/2007	Laura Saba	Modified: Corrected error when either no genes met significance criteria or only one gene met 
# 					  significance criteria
#	3/1/12		Spencer Mahaffey Modified: Read/Write HDF5 files.
#
####################################################


statistics.EavesTest.HDF5 <- function(InputFile, SampleFile, VersionPath, GeneNumberFile, pvalue) {

  ###################################################
  ###################################################
  ###				          ###################
  ### 	START OF PROGRAM	    ###################
  ###				          ###################
  ###################################################
  ###################################################

  # set up libraries and R functions needed

	fileLoader('basic.stats.R')

  #################################################
  ## process data	
  ##						
	
  vPath<-strsplit(x=Version,split='/',fixed=TRUE)
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

	cat('running Eaves Test ....\n\n')

	#Create Basic Statistics By Group
	GroupMeans <- cbind(rowMeans(Avgdata[,groups[[1]]],na.rm=TRUE),rowMeans(Avgdata[,groups[[2]]],na.rm=TRUE),rowMeans(Avgdata[,groups[[3]]],na.rm=TRUE),rowMeans(Avgdata[,groups[[4]]],na.rm=TRUE))
	GroupVar <- t(apply(Avgdata,1,summary.var,groups=groups))
	GroupN <- t(apply(Avgdata,1,summary.n,groups=groups))

	#Calculate Local Variance
	local.var1<-matrix(0,nr=nrow(Avgdata),nc=1)
	local.var2<-matrix(0,nr=nrow(Avgdata),nc=1)
	local.var3<-matrix(0,nr=nrow(Avgdata),nc=1)
	local.var4<-matrix(0,nr=nrow(Avgdata),nc=1)

	order.GroupVar1 <- GroupVar[order(GroupMeans[,1]),]
	order.GroupVar2 <- GroupVar[order(GroupMeans[,2]),]
	order.GroupVar3 <- GroupVar[order(GroupMeans[,3]),]
	order.GroupVar4 <- GroupVar[order(GroupMeans[,4]),]

	for (i in 1:nrow(Avgdata)){
		local.var1[i,1]<-mean(order.GroupVar1[max(1,(i-251)):min(nrow(Avgdata),(i+250)),1],na.rm=TRUE)
		local.var2[i,1]<-mean(order.GroupVar2[max(1,(i-251)):min(nrow(Avgdata),(i+250)),2],na.rm=TRUE)
		local.var3[i,1]<-mean(order.GroupVar3[max(1,(i-251)):min(nrow(Avgdata),(i+250)),3],na.rm=TRUE)
		local.var4[i,1]<-mean(order.GroupVar4[max(1,(i-251)):min(nrow(Avgdata),(i+250)),4],na.rm=TRUE)
	}

	rownames(local.var1)<-rownames(order.GroupVar1)
	rownames(local.var2)<-rownames(order.GroupVar2)
	rownames(local.var3)<-rownames(order.GroupVar3)
	rownames(local.var4)<-rownames(order.GroupVar4)

	local.var<-merge(local.var1,local.var2,by="row.names")
	rownames(local.var)<-local.var[,1]
	local.var<-local.var[,2:3]

	local.var<-merge(local.var,local.var3,by="row.names")
	rownames(local.var)<-local.var[,1]
	local.var<-local.var[,2:4]

	local.var<-merge(local.var,local.var4,by="row.names")
	rownames(local.var)<-local.var[,1]
	local.var<-local.var[,2:5]

	#Merge Statistics
	colnames(GroupMeans)<-c('Line1Exp1-Mean','Line2Exp1-Mean','Line1Exp2-Mean', 'Line2Exp2-Mean')
	colnames(GroupVar)<-c('Line1Exp1-Var','Line2Exp1-Var','Line1Exp2-Var', 'Line2Exp2-Var')
	colnames(GroupN)<-c('Line1Exp1-N','Line2Exp1-N','Line1Exp2-N', 'Line2Exp2-N')
	colnames(local.var)<-c('Line1Exp1-LocalVar','Line2Exp1-LocalVar','Line1Exp2-LocalVar', 'Line2Exp2-LocalVar')

	For.t.test<-merge(GroupMeans,GroupVar,by="row.names")
	rownames(For.t.test)<-For.t.test[,1]
	For.t.test<-For.t.test[,2:9]

	For.t.test<-merge(For.t.test,GroupN,by="row.names")
	rownames(For.t.test)<-For.t.test[,1]
	For.t.test<-For.t.test[,2:13]

	For.t.test<-merge(For.t.test,local.var,by="row.names")
	rownames(For.t.test)<-For.t.test[,1]
	For.t.test<-For.t.test[,2:17]

	#Calculate Pooled Variance
	pooled.var<-t(apply(For.t.test,1,pooled.var.func))
	colnames(pooled.var)<-c('Line1Exp1-PooledVar','Line2Exp1-PooledVar','Line1Exp2-PooledVar', 'Line2Exp2-PooledVar')

	For.t.test<-merge(For.t.test,pooled.var,by="row.names")
	rownames(For.t.test)<-For.t.test[,1]
	For.t.test<-For.t.test[,2:21]

	#Calculate modified t-statistic
	t.stats<-t(apply(For.t.test,1,modified.t))

	#Separate Probes that show t-stats in the same direction
	index<-array(0,dim=nrow(t.stats))

	for(i in 1:length(index)){
		if (t.stats[i,1]<0 && t.stats[i,2]>0) index[i]=1
		if (t.stats[i,1]>0 && t.stats[i,2]<0) index[i]=1
	}

	null<-t.stats[as.logical(index),]
	test<-t.stats[!as.logical(index),]

	#Identify Significant Genes 
	n <- nrow(test)

	quant = (2*pvalue)^0.5
	criteria1 <- quantile(abs(null[,1]),1-quant)
	criteria2 <- quantile(abs(null[,2]),1-quant)

	sig.results <- rep(0,nrow(test))

	for(i in 1:length(sig.results)){
		if (abs(test[i,1])>criteria1 && abs(test[i,2])>criteria2) sig.results[i]<-1
	}

	if (sum(sig.results)>1) {
		sig.genes<-test[as.logical(sig.results),]

		#Create Appropriate Data Sets For Output From multipleTest.R

		Avgdata<-merge(Avgdata,sig.genes,by="row.names")
		rownames(Avgdata)<-Avgdata[,1]
		Avgdata<-Avgdata[,2:(ncol(Avgdata)-2)]

		#Absdata<-merge(Absdata,sig.genes,by="row.names")
		#rownames(Absdata)<-Absdata[,1]
		#Absdata<-Absdata[,2:(ncol(Absdata)-2)]

		names<-rownames(sig.genes)
		Gnames<-as.vector(merge(Gnames,names)[,1])

		p <- rep(pvalue,nrow(sig.genes))
		pvalue.threshold <- p
		adjp <- p

		Means<-For.t.test[,1:4]
		Means<-merge(Means,sig.genes,by="row.names")
		row.names(Means)<-Means[,"Row.names"]
		Means<-Means[,2:ncol(Means)]
		colnames(Means)[5:6]<-c('t.stat1','t.stat2')
		stats<-rbind(t(Means),pvalue.threshold)
	}

	else if (sum(sig.results)==1) {

		sig.genes <- test[as.logical(sig.results),]
		Gnames <- rownames(test)[which.max(sig.results)]

		#Create Appropriate Data Sets For Output From multipleTest.R

		Avgdata<-Avgdata[Gnames,]
		#Absdata<-Absdata[Gnames,]
		
		p <- pvalue
		pvalue.threshold <- p
		adjp <- p

		Means<-For.t.test[Gnames,1:4]
		Means<-cbind(Means,t(sig.genes))
		colnames(Means)[5:6]<-c('t.stat1','t.stat2')
		stats<-rbind(t(Means),pvalue.threshold)
	}

	else if (sum(sig.results)==0) {

		Gnames <- c()
		Avgdata<-c()
		#Absdata<-c()
		p <- c()
		adjp <- c()
		stats<-c()
	}


	Procedure <- paste('Function=statistics.EavesTest.R',';','Stat.method = Eaves Test',';','pvalue threshold=',pvalue,sep = '')
  cat(file = GeneNumberFile, length(Gnames))
  
  if(H5Aexists (gFVer, "statMethod")){
    H5Adelete (gFVer, "statMethod")
  }
  gSM <- h5createAttribute (gFVer, "statMethod")
  H5Awrite(gSM,Procedure)
  H5Aclose(gSM)
	#createH5Attribute(filters, "statMethod", Procedure, overwrite = TRUE)
	
  #Did not output the following seems to be a mistake that has been missed up until now.  Need to double check with testing.
	#createH5Dataset(filters,"fData",Avgdata,dType="double",chunkSizes=c(dim(Avgdata)[1],dim(Avgdata)[2]),overwrite=T)
	#createH5Dataset(filters,"fProbeset",Gnames,dType="integer",chunkSizes=c(length(Gnames)),overwrite=T)
  stats=t(stats)
  sid <- H5Screate_simple (dim(stats)[1],dim(stats)[2] )
  did <- H5Dcreate (gFVer,"Statistics", "H5T_IEEE_F64LE", sid)
  H5Dwrite(did,stats)
  H5Dclose(did)
  H5Sclose(sid)
	#createH5Dataset(filters,"Statistics",stats,dType="double",chunkSizes=c(dim(stats)[1],dim(stats)[2]),overwrite=T)
  sid <- H5Screate_simple (length(p))
  did <- H5Dcreate (gFVer,"Pval", "H5T_IEEE_F64LE", sid)
  H5Dwrite(did,p)
  H5Dclose(did)
  H5Sclose(sid) 
	#createH5Dataset(filters,"pval",p,dType="double",chunkSizes=c(length(p)),overwrite=T)
  H5Gclose(gVersion)
  H5Gclose(gFVer)
  H5Fclose(h5)
  
  
	#may need to output adjp but none of the others do and it is either empty or p so shouldn't need to output it.  MultipleTest.R seems to use p only
	#createH5Dataset(multitest,"adjp",adjp,dType="double",chunkSizes=c(length(adjp)))
	##save(Absdata, Avgdata, Gnames, grouping, groups, Snames, stats, p, Procedure, adjp,  file = OutputFile)
}  #### END 
