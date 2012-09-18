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


statistics.EavesTest.HDF5 <- function(InputFile, Version, GeneNumberFile, pvalue) {

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
	
	#load(InputFile)
	require(h5r)
	h5 <- H5File(InputFile, mode = "w")
	version<-getH5Group(h5, Version)
	filters<-getH5Group(version, "Filters")
	d <- getH5Dataset(filters, "fData")
	Avgdata<-array(dim=c(dim(d)[1],dim(d)[2]))
	Avgdata[,]<-d[1:dim(d)[1],dim(d)[2]]
	ps <- getH5Dataset(filters, "fProbeset")
	Gnames<-ps[1:dim(d)[1]]
	s <- getH5Dataset(version, "Samples")
	Snames<-s[1:attr(s,"dims")[1]]
	rownames(Avgdata)<-Gnames
	colnames(Avgdata)<-Snames
	gr <- getH5Dataset(version, "Grouping")
	grouping<-gr[1:attr(gr,"dims")[1]]
	
	#Don't need to load as it is not being used
	groups <- list()
	for(i in 1:max(grouping)) groups[[i]]<-which(grouping==i)
	#dabg <- getH5Dataset(version, "DABGPval")
	#DabgVal<-array(dim=c(dim(d)[1],dim(d)[2]))
	#DabgVal[,]<-dabg[1:dim(d)[1],dim(d)[2]]
	#Absdata <- (DabgVal<0.0001)*2 - 1




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
	
	createH5Attribute(filters, "statMethod", Procedure, overwrite = TRUE)
	cat(file = GeneNumberFile, length(Gnames))
	
	
	createH5Dataset(filters,"fData",Avgdata,dType="double",chunkSizes=c(dim(Avgdata)[1],dim(Avgdata)[2]),overwrite=T)
	createH5Dataset(filters,"fProbeset",Gnames,dType="integer",chunkSizes=c(length(Gnames)),overwrite=T)
	createH5Dataset(filters,"statistics",stats,dType="double",chunkSizes=c(dim(stats)[1],dim(stats)[2]),overwrite=T)
	createH5Dataset(filters,"pval",p,dType="double",chunkSizes=c(length(p)),overwrite=T)
	#may need to output adjp but none of the others do and it is either empty or p so shouldn't need to output it.  MultipleTest.R seems to use p only
	#createH5Dataset(multitest,"adjp",adjp,dType="double",chunkSizes=c(length(adjp)))

	##save(Absdata, Avgdata, Gnames, grouping, groups, Snames, stats, p, Procedure, adjp,  file = OutputFile)


	
}  #### END 
