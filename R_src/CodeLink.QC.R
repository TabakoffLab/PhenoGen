
################ CodeLink.QC.R ####################
#
# This function imports .txt files according to 
# the order specific in the phenoData.txt file
# and perform various Quality Control measure
# on the dataset
#
# Parms:
#    InputDataFile = input Rdata file; i.e. the output of CodeLink.Import.R
#    path = the path where the .txt files reside
#    imagePath = the path where the images should be sent
#    boxplotFile = boxplot graph image file name 
#    cvImageFile = Coefficient of Variation (CV) graph image file name
#    qcTableFile = quality control table filename
#    graphics = TRUE/FALSE indicator for whether residual plots should be generated
#		
# Returns:
#    nothing
#
# Writes Out:
#    PNG files containing QC images and TXT file with QC data
# 
# Sample call: 
#    CodeLink.QC(InputDataFile = "raw.CodeLink.Rdata",path = "/Users/laurasaba/Documents/PhenoGen/Testing R Programs/CodeLink Arrays/Data Files/",
#    imagePath = "/Users/laurasaba/Documents/PhenoGen/Testing R Programs/CodeLink Arrays/Image Files/",boxplotFile = "boxPlot.png",
#    cvImageFile = "cvImage.png",qcTableFile = "qcTable.png",graphics = TRUE)
#
# Function history:
#    02-10-06	Tzu Phang	created
#    04-24-07	Laura Saba	modified: added sample names to boxplot and CV plots; reduced significant digits
#                                     in QC output table
#    03-20-09	Laura Saba	modified: adjusted image size based on number of arrays and increased title size
#    03-11-10	Laura Saba	modified: added parameters for image file names (boxplotFile and cvImageFile), QC
#                                     text file name (qcTableFile), and path for file where images should be 
#                                     stored (imagePath); cleaned up header information to match other programs
#

CodeLink.QC <- function(InputDataFile,path,imagePath,boxplotFile,cvImageFile,qcTableFile,graphics){

	#############################
	# loading required packages
	#
	
	library(limma)
	library(marray)

	fileLoader(c('normalizeMag1.R','tzu.CV.R'))
	fileLoader('read.single.CodeLink.txt.R')


	#############################

	# Reading .txt files and compile
	# data in arrayData object (aD)
	#

	load(InputDataFile)

	num.of.chips = dim(chip.info$exp.value)[2]

	filenames = as.vector(sample.names)

	#################################
	# Plot Boxplot graph
	#

	exp.data = chip.info$exp.value
	exp.data = as.numeric(exp.data)
	exp.data = matrix(exp.data, ncol = num.of.chips)
	exp.data = log(exp.data-min(exp.data)+1)

	bitmap(file = paste(imagePath,boxplotFile,sep=""), type = 'png16m', width = (3.333 + (length(filenames)>30)), height = 3.333 , res = 300)

		par(mar=c(10, 4, 4, 2) + 0.1)
		boxplot(data.frame(exp.data), axes = F, main = 'CodeLink QC Boxplot', ylab = 'log scale')
		axis(1,1:num.of.chips,lab=F)
		axis(2)
		if (max(nchar(filenames))>21) text(1:num.of.chips,par("usr")[3]-0.75,srt=45,adj=1,labels=filenames,xpd=T, cex=0.5)
		  else if (max(nchar(filenames))>15|length(filenames)>30) text(1:num.of.chips,par("usr")[3]-0.50,srt=45,adj=1,labels=filenames,xpd=T, cex=0.7)
		  else if (max(nchar(filenames))>10) text(1:num.of.chips,par("usr")[3]-0.50,srt=45,adj=1,labels=filenames,xpd=T, cex=0.9)
		  else text(1:num.of.chips,par("usr")[3]-0.50,srt=45,adj=1,labels=filenames,xpd=T)
		par(mar=c(5, 4, 4, 2) + 0.1)

	dev.off()

	#################################
	# Plot CV graph
	#

	cv.data = chip.info$exp.value
	cv.data = as.numeric(cv.data)
	cv.data = matrix(cv.data, ncol = num.of.chips)

	test.CV = apply(cv.data, 2, tzu.CV)

	bitmap(file = paste(imagePath,cvImageFile,sep=""), type = 'png16m', width = (3.333 + (length(filenames)>30)), height = 3.333, res = 300)

		par(mar=c(10, 4, 4, 2) + 0.1)
		plot(test.CV, axes = F, main = 'CodeLink CV Plot', ylab = 'CV', xlab = '',ylim=c(0,max(test.CV)))

		for(i in 1:num.of.chips){
			lines(c(i,i), c(test.CV[i],0))
		}

		axis(1, 1:num.of.chips, lab=F)
        axis(2,yaxp=c(0,round(floor(max(test.CV)) + 0.5 + 0.5*((max(test.CV)-floor(max(test.CV))>0.5)),digits=1),5))
		if (max(nchar(filenames))>21) text(1:num.of.chips,par("usr")[3]-0.020,srt=45,adj=1,labels=filenames,xpd=T, cex=0.4)	
		  else if (max(nchar(filenames))>15|length(filenames)>30) text(1:num.of.chips,par("usr")[3]-0.020,srt=45,adj=1,labels=filenames,xpd=T, cex=0.5)	
		  else if (max(nchar(filenames))>10) text(1:num.of.chips,par("usr")[3]-0.006,srt=45,adj=1,labels=filenames,xpd=T, cex=0.9)	
		  else text(1:num.of.chips,par("usr")[3]-0.007,srt=45,adj=1,labels=filenames,xpd=T)	
		par(mar=c(5, 4, 4, 2) + 0.1)

	dev.off()

	#################################
	# Plot Background Image
	#

	if(graphics) {
	  for(i in 1:num.of.chips){
	    data.raw = read.table(file = paste(path,file.names[i],sep="/"), header=TRUE, skip = 6,check.names = FALSE,as.is = TRUE,sep="\t")
		
		nc = max(data.raw$SPOT_COL)
		nr = max(data.raw$SPOT_ROW)
	    layout <-c()	
		
		for(r in 1:max(data.raw$SPOT_ROW)) layout <- rbind(layout,cbind(rep(r,nc),1:nc))
		colnames(layout) <- c("SPOT_ROW","SPOT_COL")
		ordered.data <- merge(data.raw,layout,all.y=TRUE)
		
		z <- matrix(data = log2(ordered.data$SPOTMEAN),nrow=nr,ncol=nc,byrow=FALSE)
		tmp <- (z - mean(z,na.rm=TRUE))/sd(as.numeric(z),na.rm=TRUE)

	    bitmap(file = paste(imagePath,paste(sample.names[i],"png",sep="."),sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
            if (max(nchar(filenames))>18) image(1:nr,1:nc,tmp,col=heat.colors(12),axes=FALSE,xlab="",ylab="",main=sample.names[i],cex.main=1.5)
				else image(1:nr,1:nc,tmp,col=heat.colors(12),axes=FALSE,xlab="",ylab="",main=sample.names[i],cex.main=2)
		dev.off()
        }
	}


	#################################
	# Generate table
	#

	mean.bg = max.bg = min.bg = CodeLink.G = CodeLink.L = CodeLink.C = CodeLink.CL = CodeLink.I = CodeLink.M = CodeLink.S = CodeLink.IS = CodeLink.CI = QC.table = c()

	bg.data = chip.info$bg.mean
	bg.data = as.numeric(bg.data)
	bg.data = matrix(bg.data, ncol = num.of.chips)

	for(i in 1:num.of.chips){
	
		mean.bg = c(mean.bg, mean(bg.data[,i]))
		max.bg = c(max.bg, max(bg.data[,i]))
		min.bg = c(min.bg, min(bg.data[,i]))
		CodeLink.G = c(CodeLink.G, sum(chip.info$codelink.flag[,i] == 'G'))
		CodeLink.L = c(CodeLink.L, sum(chip.info$codelink.flag[,i] == 'L'))
		CodeLink.C = c(CodeLink.C, sum(chip.info$codelink.flag[,i] == 'C'))
		CodeLink.CL = c(CodeLink.CL, sum(chip.info$codelink.flag[,i] == 'CL'))
		CodeLink.I = c(CodeLink.I, sum(chip.info$codelink.flag[,i] == 'I'))
		CodeLink.M = c(CodeLink.M, sum(chip.info$codelink.flag[,i] == 'M'))
		CodeLink.S = c(CodeLink.S, sum(chip.info$codelink.flag[,i] == 'S'))
		CodeLink.IS = c(CodeLink.IS, sum(chip.info$codelink.flag[,i] == 'IS'))
		CodeLink.CI = c(CodeLink.CI, sum(chip.info$codelink.flag[,i] == 'CI'))

	}

	QC.table.header = c('mean.bg', 'max.bg', 'min.bg', 'CodeLink.G', 'CodeLink.L', 'CodeLink.C', 'CodeLink.CL', 'CodeLink.I', 'CodeLink.M', 'CodeLink.S', 'CodeLink.IS', 'CodeLink.CI')
	
	QC.table = cbind(format(mean.bg,nsmall=0,digits=1), format(max.bg,nsmall=0,digits=3), format(min.bg,nsmall=0,digits=1), CodeLink.G, CodeLink.L, CodeLink.C, CodeLink.CL, CodeLink.I, CodeLink.M, CodeLink.S, CodeLink.IS, CodeLink.CI)

	QC.table = rbind(QC.table.header, QC.table)

	write.table(QC.table, file = paste(imagePath,qcTableFile,sep=""), quote = F, sep = '\t', row.names = F, col.names = F)	


}  ## END OF: CodeLink.ImportTxt 
