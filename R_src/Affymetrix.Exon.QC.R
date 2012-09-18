########################## Affymetrix.Exon.QC.R ##########################
#
# This function reads in txt files from APT for quality control
#   of Exon Arrays
#
# Parms:
#    qcPath				= path where input data is stored (created by APT) 
#    FileListing 		= txt file with a list of CEL files to be imported
# 	 imagePath			= path where images should be stored (should end with a "/")
#    Summary.Figure   	= file name of the summary figure 
#    RLE.Figure	     	= file name of the RLE figure 
#    MAD.Figure      	= file name of the MAD residuals figure 
#    graphics	    	= TRUE/FALSE indicator for whether residual plots and MA plots 
#                       should be created
#    MAplotStats 		= file name of the output file for median and IQR from MA plot
#
# Returns:
#    nothing
#
# Writes Out:
#    PNG files containing QC images 
#
# Sample Call:
#
#  Function History
#     08/10/10  Laura Saba   Created   
#
####################################################


Affymetrix.Exon.QC <- function(qcPath, FileListing, imagePath, Summary.Figure, RLE.Figure, MAD.resid.Figure, graphics, MAplotStats){

	#################  Housekeeping  #################

    # set up libraries and R functions needed
    
    library(affy)
    
    fileLoader("plotExonQC.R")

	#################  Import QC Report and Summary  #################
	
	qc.checks <- read.table(file=paste(qcPath,"rma-sketch.report.txt",sep=""),sep="\t",header=TRUE)
	dabg.checks <- read.table(file=paste(qcPath,"dabg.report.txt",sep=""),sep="\t",header=TRUE,fill=TRUE)
	dabgData <- read.table(file=paste(qcPath,"dabg.summary.txt",sep=""),sep="\t",header=TRUE,fill=TRUE)
	rmaData <- read.table(file=paste(qcPath,"rma-sketch.summary.txt",sep=""),sep="\t",header=TRUE,fill=TRUE,row.names=1)
	
	fileListing <- read.table(file=FileListing,sep="\t",header=TRUE)
	
	numfiles = nrow(qc.checks)
	celNames = unlist(strsplit(rownames(fileListing),"/"))[grep(".CEL",unlist(strsplit(rownames(fileListing),"/")))]
	fileNames <- as.character(fileListing[match(celNames,as.character(qc.checks[,"cel_files"])),"cel_files"])

	#################  Create Summary Graphic of Affy QC  #################

	# Output graphic in png format
	bitmap(file = paste(imagePath,Summary.Figure,sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
		if (max(nchar(fileNames)) > 30) plotExonQC(qc.checks=qc.checks,dabg.checks=dabg.checks,cex=0.60,label = fileNames)
		  else if (max(nchar(fileNames)) > 20) plotExonQC(qc.checks=qc.checks,dabg.checks=dabg.checks,cex=0.80,label = fileNames)
		  else plotExonQC(qc.checks=qc.checks,dabg.checks=dabg.checks,label = fileNames)
	dev.off()
	
	
	###################  RLE and MAD Graphics  #################


	error.bar <- function(x,y,upper,lower=upper,length=0.1,...){
		if(length(x) != length(y) | length(y) != length(lower) | length(lower) != length(upper)) stop("vectors must be same length")
		arrows(x,y+upper,x,y, angle=90, code=3, length=length,...)
		}
	
	bitmap(file = paste(imagePath,RLE.Figure,sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
		par(mar=c(10, 7, 7, 2) + 0.1) 
		rlePlot <- barplot(qc.checks[,"all_probeset_rle_mean"], ylim=c(0,0.1+max(qc.checks[,"all_probeset_rle_mean"]+qc.checks[,"all_probeset_rle_stdev"])), main="Absolute Relative Log Expression",cex.names=0.8,las=2,axis.lty=1)
		error.bar(rlePlot,qc.checks[,"all_probeset_rle_mean"],qc.checks[,"all_probeset_rle_stdev"])
		axis(1,rlePlot,lab=F)
		if (max(nchar(fileNames)) > 30) text(rlePlot,par("usr")[3]-0.03,srt=45,adj=1,labels=fileNames,xpd=T, cex=0.5)	 		else if (max(nchar(fileNames)) > 20) text(rlePlot,par("usr")[3]-0.03,srt=45,adj=1,labels=fileNames,xpd=T, cex=0.6)
  			else text(rlePlot,par("usr")[3]-0.03,srt=45,adj=1,labels=fileNames,xpd=T, cex=0.8)
		par(mar=c(5, 4, 4, 2) + 0.1)
	dev.off()
	
	
	bitmap(file = paste(imagePath,MAD.resid.Figure,sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
		par(mar=c(10, 7, 7, 2) + 0.1) 
		madPlot <- barplot(qc.checks[,"all_probeset_mad_residual_mean"], ylim=c(0,0.1+max(qc.checks[,"all_probeset_mad_residual_mean"]+qc.checks[,"all_probeset_mad_residual_stdev"])), main="Absolute Deviation of Residuals from Median",cex.names=0.8,las=2,plt=c(5,1,1,1),axis.lty=1)
		error.bar(madPlot,qc.checks[,"all_probeset_mad_residual_mean"],qc.checks[,"all_probeset_mad_residual_stdev"])
		axis(1,madPlot,lab=F)
		if (max(nchar(fileNames)) > 30) text(madPlot,par("usr")[3]-0.03,srt=45,adj=1,labels=fileNames,xpd=T, cex=0.5)	 		else if (max(nchar(fileNames)) > 20) text(madPlot,par("usr")[3]-0.03,srt=45,adj=1,labels=fileNames,xpd=T, cex=0.6)
  			else text(madPlot,par("usr")[3]-0.03,srt=45,adj=1,labels=fileNames,xpd=T, cex=0.8)
		par(mar=c(5, 4, 4, 2) + 0.1)
	dev.off()
	
	
	
	################# Individual MA Plots #################

	pseudoRef <- apply(rmaData,1,median)
	fold.change <- apply(rmaData,2,function(a) a-pseudoRef)
	average <- apply(rmaData,2,function(a) (a+pseudoRef)/2)
	
	if (graphics){
		for(i in 1:numfiles){
			bitmap(file = paste(imagePath,paste(fileNames[i],"MAplot.png",sep="_"),sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
				if (max(nchar(fileNames)) > 25) ma.plot(M = fold.change[,i], A = average[,i], pch=46, main=fileNames[i])
				  else ma.plot(M = fold.change[,i], A = average[,i], pch=46, main=fileNames[i],cex.main=2)
			dev.off()
		}
	} 	

	################# Output stats from MA plot to separate table #################


	for.table<-matrix(data=0, nr=numfiles, nc=3)
	for(i in 1:numfiles){
		for.table[i,1]<-fileNames[i]
		for.table[i,2]<-format(median(fold.change[,i]),nsmall=3,digits=4)
		for.table[i,3]<-format(IQR(fold.change[,i]),nsmall=2,digits=3)
	}

	header.row<-c("Sample.Name", "Median", "IQR")
	for.table<-rbind(header.row,for.table)
	write.table(for.table, file = paste(imagePath,MAplotStats,sep=""), append = FALSE, sep = '\t',row.names = FALSE,quote=FALSE,col.names=FALSE)	

}  ###END