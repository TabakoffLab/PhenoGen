#    function findXMLProbes(InputXMLFileName)
# 	  Returns a list of Probeset ID's
#
# Example Call:
# testXML = findXMLProbes("/Users/clemensl/LaurensR/Combine/Test1XML.xml")
#
# 3/13/15   Spencer Mahaffey Modified: Changed HDF5 methods to rHDF5 methods from h5r due to dropped support of h5r
#

Affymetrix.HeatMap.output.Specific.Gene.HDF5 <- function(InputFile,VersionPath,SampleFile, XMLFileName, plotFileName,GeneList, Platform, OutputFileIndiv, OutputFileGroup) {

	###########################################
	#   Load Packages & Setup Working Space   #
	###########################################

	library(gplots)

	#####################
	#    Load Data      #
	#####################
	require(rhdf5)
	h5 <- H5Fopen (InputDataFile,flags = h5default("H5F_ACC"))
	gVersion<-H5Gopen(h5, VersionPath)
	did <- H5Dopen(gVersion,  "Data")
	sid <- H5Dget_space(did)
	ds <- H5Dread(did)
  ds=t(ds)
	H5Dclose(did)
	H5Sclose(sid)
	
	Avgdata<-array(dim=c(dim(ds)[1],dim(ds)[2]))
	Avgdata[,]<-ds[1:dim(ds)[1],1:dim(ds)[2]]
	
	did <- H5Dopen(gVersion,  "Probeset")
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
  #grouping<-gs[1:attr(gs,"dims")[1]]
	groups <- list()
	for(i in 1:max(grouping)) groups[[i]]<-which(grouping==i)
  
	did <- H5Dopen(gVersion,  "DABGPval")
	sid <- H5Dget_space(did)
	dabgds <- H5Dread(did)
  dabgds=t(dabgds)
	H5Dclose(did)
	H5Sclose(sid)
	DabgVal<-array(dim=c(dim(dabgds)[1],dim(dabgds)[2]))
	DabgVal[,]<-dabgds[1:dim(dabgds)[1],1:dim(dabgds)[2]]
	Absdata <- (DabgVal<0.0001)*2 - 1
	rownames(Absdata)<-Gnames
	colnames(Absdata)<-Snames
  
  
	H5Gclose(gVersion)
	H5Fclose(h5)
		
	objects()
	dim(Avgdata)
	
	####Old method that used xml file except a probeset list file is created and read later so there is no reason to do that.
	#ps <- as.matrix(findXMLProbes(XMLFileName))
	#print(ps)
	
	#Sig_list <- c()
	#for(i in ps){
	#	Sig_list = c(Sig_list, which(rownames(Avgdata)==i))
	#}
	#length(ps)
	#length(Sig_list)
	
	tmpGeneList <- scan(GeneList)
	tmpMatrixGL <- as.matrix(tmpGeneList)
	Sig_list <- c()
	for(i in tmpMatrixGL){
		Sig_list = c(Sig_list, which(rownames(Avgdata)==i))
	}
	length(Sig_list)


	Cd36 <- Avgdata[Sig_list,]
	dim(Cd36)

	########################
	#   Correlation Plot   #
	########################
	Cd36_4plot_corr = t(Cd36)
	K <- cor(Cd36_4plot_corr)
	dim(K)
	#heatmap.2(K, Colv = NA, Rowv = NA, cexRow = 1, cexCol = 1, symm = TRUE, trace = "none", symkey=TRUE, col = redgreen(100), breaks = seq(-1, 1, 0.02), main = "Cd36 Exon Probeset Correlation", dend="none") 


	# Open plot file and write out heat map data
	
	plotFile <- file(plotFileName,"w")
	write.csv(K, file=plotFileName)
	close(plotFile)
	
	#DONE WITH HEATMAP STARTING EXPRESSION VALUE EXTRACTION
	
	
		
	fileLoader('tzu.NumToChar.R')
	
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

# findXMLProbes <- function(InputXMLFileName) {

	# ###########################################
	# #   Load Packages & Setup Working Space   #
	# ###########################################

	# library(XML)


	# doc = xmlParse(InputXMLFileName)
	# allExonProbeNodes = getNodeSet(doc,"/GeneList/Gene/TranscriptList/Transcript/exonList/exon/ProbesetList/Probeset")
	# allIntronProbeNodes = getNodeSet(doc,"/GeneList/Gene/TranscriptList/Transcript/intronList/intron/ProbesetList/Probeset")
	# probeNameListe <- sapply(allExonProbeNodes, xmlGetAttr, "ID")
	# probeNameListi <- sapply(allIntronProbeNodes, xmlGetAttr, "ID")
	# probeNames <-c(probeNameListe,probeNameListi)
	# uniqueProbeNames <- noquote(unique(probeNames))
	
# }

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




