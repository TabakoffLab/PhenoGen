########################## statistics.OneWay.ANOVA.R ################
#
# This function computes the statistics on the filtered genes in the input data when there is more than two groups or more than one factor
#
# Parms:
#    InputFile  = name of input file containing Absdata, Avgdata,  
#                     Gnames, grouping, groups, Snames, Procedure
#                     (OutputFile from Affy.filter.genes)
#	 VersionPath = Version/Date/Time of dataset to use since .h5 files will have multiple versions per file and multiple filter/statistics results per version.
#	 SampleFile= File with Sample Names so that they can be read in--Unfortunately h5r has problems reading strings in.
#    GeneNumberFile = name of output file for # of genes 
#    	
#    pvalue = which pvalue is of interest (when 4 or less groups)
#             "Model" -> overall model p-value (factor effect)
#             "Group 1 - Group 2" -> difference between group 1 and group 2 (smaller number is always on the left)
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
#    statistics.OneWay.ANOVA.HDF5(InputFile = 'Affy.NormVer.h5', Version='v1', pvalue = "Model", GeneNumberFile = 'HapLap.GeneNumberCount.txt', Run.At.Home = F)
#
#
#  Function History
#	6/27/06		Laura Saba	Created
#	12/4/06		Laura Saba	Modified:  consolidated affymetrix and codelink programs
#	3/30/07		Laura Saba	Modified:  added row names to stats matrix and changed spaces to '.' for group names
#	11/20/07		Laura Saba	Modified:  corrected error in calculating contrasts caused by updated version of R 2.6.0
#	1/08/07		Laura Saba	Modified:  made changes for when there is only one gene analyzed
#	3/1/12		Spencer Mahaffey Modified: Read/Write HDF5 files.
#	3/8/12		Spencer Mahaffey Modified: Support multiple filters/stats per version.
# 3/13/15   Spencer Mahaffey Modified: Changed HDF5 methods to rHDF5 methods from h5r due to dropped support of h5r
#
####################################################


statistics.OneWay.ANOVA.HDF5 <- function(InputFile, VersionPath, SampleFile, pvalue, GeneNumberFile, Run.At.Home = F) {

  ###################################################
  ###################################################
  ###				          ###################
  ### 	START OF PROGRAM	    ###################
  ###				          ###################
  ###################################################
  ###################################################

  # set up libraries and R functions needed
	library(limma)
	library(MASS)
      fileLoader('CreateContrasts.R')

  #################################################
  ## process data	
  ##
	vPath<-strsplit(x=VersionPath,split='/',fixed=TRUE)
	Version<-vPath[[1]][1]
	Day<-vPath[[1]][2]
	exactTime<-vPath[[1]][3]
  require(rhdf5)
  h5 <- H5Fopen (InputFile,flags = h5default("H5F_ACC_RDWR"))
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
  
  
	

##########################################
	n <- length(Gnames) 
	p <- rep(0,n)
	cat('running ANOVA analysis ....\n\n')

      new.grouping<-grouping[grouping!=0]
	if (n>1) new.Avgdata<-Avgdata[,grouping!=0]
	else if (n==1) new.Avgdata <- Avgdata[grouping!=0]

	tmp<-new.grouping[order(new.grouping)]
	if (n>1) Avgdata.tmp<-new.Avgdata[,order(new.grouping)]
	else if (n==1) Avgdata.tmp<-new.Avgdata[order(new.grouping)]

	design<-model.matrix(~ -1 + factor(tmp, levels = unique(tmp)))
	colnames(design)<-unique(tmp)
	contrast.matrix <- design.pairs(unique(tmp))

	if (n>1) {
		fit<-lmFit(Avgdata.tmp,design = design)
		fit2<-contrasts.fit(fit,contrast.matrix)
		fit2<-eBayes(fit2)
	}
	else if (n==1) {
		fit<-lm(Avgdata.tmp ~ design - 1,contrasts=contrast.matrix)
		fit2 = c()
		StdErr = (summary(fit)$sigma^2*t(contrast.matrix)^2%*%matrix(colSums(design),ncol=1)^-1)^0.5
		Estimates = colSums(coef(fit)*contrast.matrix)
		fit2$F<-summary(lm(Avgdata.tmp ~ design))$fstatistic[1]
		fit2$F.p.value <- 1-pf(summary(lm(Avgdata.tmp ~ design))$fstatistic[1],summary(lm(Avgdata.tmp ~ design))$fstatistic[2],summary(lm(Avgdata.tmp ~ design))$fstatistic[3])
		fit2$t <- Estimates / StdErr
		fit2$p.value <- (1 - pt(abs(fit2$t),sum(design)-ncol(design)))*2
	}

	title.groups <- paste("Group",unique(tmp),sep=".")
	Group.Means<-fit$coefficients
	
	if (pvalue=="Model") {
		p <- fit2$F.p.value
		if (n>1) {
			stats <- t(cbind(Group.Means,fit2$F,fit2$F.p.value))
			rownames(stats)<-c(title.groups,'F.statistic','raw.p.value')
		}
		if (n==1) {
			stats <- c(Group.Means,fit2$F,fit2$F.p.value)
			names(stats)<-c(title.groups,'F.statistic','raw.p.value')
		}
	}
	else if(pvalue=="Group 1 - Group 2") {
		if (n>1) {
			p <- fit2$p.value[,colnames(fit2)=="1-2"]
			stats <- t(cbind(Group.Means,fit2$t[,colnames(fit2)=="1-2"],fit2$p.value[,colnames(fit2)=="1-2"]))
			rownames(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
		if (n==1) {
			p <- fit2$p.value["1-2",]
			stats <- c(Group.Means,fit2$t["1-2",],fit2$p.value["1-2",])
			names(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
	}
	else if(pvalue=="Group 1 - Group 3") {
		if (n>1) {
			p <- fit2$p.value[,colnames(fit2)=="1-3"]
			stats <- t(cbind(Group.Means,fit2$t[,colnames(fit2)=="1-3"],fit2$p.value[,colnames(fit2)=="1-3"]))
			rownames(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
		if (n==1) {
			p <- fit2$p.value["1-3",]
			stats <-c(Group.Means,fit2$t["1-3",],fit2$p.value["1-3",])
			names(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
	}
	else if(pvalue=="Group 1 - Group 4") {
		if (n>1) {
			p <- fit2$p.value[,colnames(fit2)=="1-4"]
			stats <- t(cbind(Group.Means,fit2$t[,colnames(fit2)=="1-4"],fit2$p.value[,colnames(fit2)=="1-4"]))
			rownames(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
		if (n==1) {
			p <- fit2$p.value["1-4",]
			stats <- c(Group.Means,fit2$t["1-4",],fit2$p.value["1-4",])
			names(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
	}
	else if(pvalue=="Group 2 - Group 3") {
		if (n>1) {
			p <- fit2$p.value[,colnames(fit2)=="2-3"]
			stats <- t(cbind(Group.Means,fit2$t[,colnames(fit2)=="2-3"],fit2$p.value[,colnames(fit2)=="2-3"]))
			rownames(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
		if (n==1) {
			p <- fit2$p.value["2-3",]
			stats <- c(Group.Means,fit2$t["1-2",],fit2$p.value["2-3",])
			names(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
	}
	else if(pvalue=="Group 2 - Group 4") {
		if (n>1) {
			p <- fit2$p.value[,colnames(fit2)=="2-4"]
			stats <- t(cbind(Group.Means,fit2$t[,colnames(fit2)=="2-4"],fit2$p.value[,colnames(fit2)=="2-4"]))
			rownames(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
		if (n==1) {
			p <- fit2$p.value["2-4",]
			stats <- c(Group.Means,fit2$t["2-4",],fit2$p.value["2-4",])
			names(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
	}
	else if(pvalue=="Group 3 - Group 4") {
		if (n>1) {
			p <- fit2$p.value[,colnames(fit2)=="3-4"]
			stats <- t(cbind(Group.Means,fit2$t[,colnames(fit2)=="3-4"],fit2$p.value[,colnames(fit2)=="3-4"]))
			rownames(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
		if (n==1) {
			print(title.groups)
			p <- fit2$p.value["3-4",]
			stats <- c(Group.Means,fit2$t["3-4",],fit2$p.value["3-4",])
			names(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
	}

	#replaced with attributes see next line below
	
	Procedure <- paste('Function=statistics.OneWay.ANOVA.R',';','Stat.method = one-way ANOVA',';','pvalue of interest=',pvalue,sep = '')
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
	#createH5Dataset(gFVer,"Statistics",stats,dType="double",chunkSizes=c(dim(stats)[1],dim(stats)[2]),dim=c(dim(stats)[1],dim(stats)[2]),overwrite=T)
  sid <- H5Screate_simple (length(p))
  did <- H5Dcreate (gFVer,"Pval", "H5T_IEEE_F64LE", sid)
  H5Dwrite(did,p)
  H5Dclose(did)
  H5Sclose(sid)
	#createH5Dataset(gFVer,"Pval",p,dType="double",chunkSizes=c(length(p)),overwrite=T)
  H5Gclose(gVersion)
  H5Gclose(gFVer)
  H5Fclose(h5)
	#save(Absdata, Avgdata, Gnames, grouping, groups, Snames, stats, p, Procedure,  file = OutputFile, compress = T)
	
}  #### END 
