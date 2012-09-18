########################## Affymetrix.QC.R ################
#
# This function reads an AffyBatch object binary file and normalize
# the data and perform quality control calculation.  The results are
# displayed and summary in three different figures.  The goal is to give users an
# overview of the integrity of the data, as well as picking out outliers
#
# Parms:
#    Input.combine.BioC	= input file; i.e. the output of Affy.ImportBioC.R) 
#    imagePath			= path where images should be stored (should end with a "/")
#    Summary.Figure   	= file name of the summary figure from simpleaffy package
#    RLE.Figure	      = file name of the RLE figure from affyPLM pacakge
#    NUSE.Figure      	= file name of the NUSE figure from affyPLM package
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
#    Affymetrix.QC(Input.combine.BioC = "Combine.BioC.Binary.Rdata",imagePath = "/Users/laurasaba/Documents/PhenoGen/Testing R Programs/QC Images/Image File/",
#     Summary.Figure = "summaryFigure.png",RLE.Figure = "rleFigure.png",NUSE.Figure = "nuseFigure.png",graphics = T,MAplotStats = "MAplotsStats.txt",Run.At.Home = T)
#
#  Function History
#     12/12/05  Tzu Phang   Created   
#  	  06/09/06	Laura Saba	Updated
#	  03/22/07	Laura Saba	Updated - replaces Affy.simpleaffy.R, Affy.affyPLM.r, Affy.MAplots.R, and Affy.Image.R
#	  11/15/07	Laura Saba	Modified: refined plots so that sample names were not cut off
#	  03/13/09	Laura Saba	Modified: increased font size on residual/weight plots
#     03/15/10	Laura Saba	Modified: added imagePath variable to send images to a separate file
#
####################################################


Affymetrix.QC <- function(Input.combine.BioC, imagePath, Summary.Figure, RLE.Figure, NUSE.Figure, graphics, MAplotStats, Run.At.Home = T){

	################# Housekeeping ############################

      # set up libraries and R functions needed
	library(simpleaffy)
	library(affyPLM)

	# Load data from ImportBioC
	load(Input.combine.BioC)

	# save number of files
	filenames = colnames(exprs(All.ReadCell))
	numfiles = length(filenames)	
	
	if(cleancdfname(cdfName(All.ReadCell))=="moe430bcdf") setQCEnvironment(cleancdfname(cdfName(All.ReadCell)), G_SrcDir)
	################# Use SimpleAffy to get basics ############################

	# Get Calls for Data
	cat('Performing call.exprs ........\n')
	start.time = proc.time()
	  eset = call.exprs(All.ReadCell, algorithm = 'mas5')
	end.time = proc.time()
	cat('Time spent is ', end.time[3]-start.time[3], ' seconds\n')

	# Calculate QC Measures
	cat('Performing qc ........\n')
	start.time = proc.time()
	qc.data = qc(All.ReadCell, eset)
	end.time = proc.time()
	cat('Time spent is ', end.time[3]-start.time[3], ' seconds\n')

	# Output graphic in png format
	bitmap(file = paste(imagePath,Summary.Figure,sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
		if (max(nchar(colnames(exprs(All.ReadCell)))) > 30) plot(qc.data,cex=0.60)
		  else if (max(nchar(colnames(exprs(All.ReadCell)))) > 20) plot(qc.data,cex=0.80)
		  else plot(qc.data)
	dev.off()

	################# Use Probe Level Modeling to Get Additional QC Measures #################

	# calculate probe level model
	cat('Performing fitPLM ........\n')
	start.time = proc.time()
		pset = fitPLM(All.ReadCell)
	end.time = proc.time()
	cat('Time spent is ', end.time[3]-start.time[3], ' seconds\n')

	# output png file with RLE graphic
	bitmap(file = paste(imagePath,RLE.Figure,sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
		par(mar=c(10, 7, 7, 2) + 0.1)
		RLE(pset, main = 'Relative Log Expressions', xaxt='n')
		axis(1,1:numfiles,lab=F)
		if (max(nchar(colnames(exprs(All.ReadCell)))) > 30) text(1:numfiles,par("usr")[3]-0.10,srt=45,adj=1,labels=filenames,xpd=T, cex=0.5)	
  		  else if (max(nchar(colnames(exprs(All.ReadCell)))) > 20) text(1:numfiles,par("usr")[3]-0.10,srt=45,adj=1,labels=filenames,xpd=T, cex=0.6)
  		  else text(1:numfiles,par("usr")[3]-0.10,srt=45,adj=1,labels=filenames,xpd=T, cex=0.8)
		par(mar=c(5, 4, 4, 2) + 0.1)
	dev.off()

	# output png file with NUSE graphic
	bitmap(file = paste(imagePath,NUSE.Figure,sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
		par(mar=c(10, 7, 7, 2) + 0.1)
		NUSE(pset, main = 'Normalized Unscaled Standard Errors', xaxt='n')
		axis(1,1:numfiles,lab=F)
		if (max(nchar(colnames(exprs(All.ReadCell)))) > 30) text(1:numfiles,par("usr")[3]-0.02,srt=45,adj=1,labels=filenames,xpd=T, cex=0.5)	
		  else if (max(nchar(colnames(exprs(All.ReadCell)))) > 20) text(1:numfiles,par("usr")[3]-0.02,srt=45,adj=1,labels=filenames,xpd=T, cex=0.7)	
		  else text(1:numfiles,par("usr")[3]-0.02,srt=45,adj=1,labels=filenames,xpd=T, cex=0.8)	
		par(mar=c(5, 4, 4, 2) + 0.1)
	dev.off()

	# output residual plots and MA plots
	if (graphics){
		for(i in 1:numfiles){
			SampleName = filenames[i]

			bitmap(file = paste(imagePath,paste(SampleName,"MAplot.png",sep="_"),sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
				if (max(nchar(colnames(exprs(All.ReadCell)))) > 30) MAplot(eset, which = i, cex.main=2, ref.title="")
				  else MAplot(eset, which = i, cex.main=3, ref.title="")
			dev.off()

			bitmap(file = paste(imagePath,paste(SampleName,"Image.weights.png",sep="_"),sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
				if (max(nchar(colnames(exprs(All.ReadCell)))) > 30) image(pset, which = i, type = 'weights',main=list(SampleName, cex = 2))
				  else image(pset, which = i, type = 'weights',main=list(SampleName, cex = 3))
			dev.off()

			bitmap(file = paste(imagePath,paste(SampleName,"Image.resids.png",sep="_"),sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
				if (max(nchar(colnames(exprs(All.ReadCell)))) > 30) image(pset, which = i, type = 'resids',main=list(SampleName, cex = 2))
				  else image(pset, which = i, type = 'resids',main=list(SampleName, cex = 3))
			dev.off()

			bitmap(file = paste(imagePath,paste(SampleName,"Image.pos.resids.png",sep="_"),sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
				if (max(nchar(colnames(exprs(All.ReadCell)))) > 30) image(pset, which = i, type = 'pos.resids',main=list(SampleName, cex = 2))
				  else image(pset, which = i, type = 'pos.resids',main=list(SampleName, cex = 3))
			dev.off()

			bitmap(file = paste(imagePath,paste(SampleName,"Image.neg.resids.png",sep="_"),sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
				if (max(nchar(colnames(exprs(All.ReadCell)))) > 30) image(pset, which = i, type = 'neg.resids',main=list(SampleName, cex = 2))
				  else image(pset, which = i, type = 'neg.resids',main=list(SampleName, cex = 3))
			dev.off()

			bitmap(file = paste(imagePath,paste(SampleName,"Image.sign.resids.png",sep="_"),sep=""), type = 'png16m', width = 4, height = 4, res = 300)
				if (max(nchar(colnames(exprs(All.ReadCell)))) > 30) image(pset, which = i, type = 'sign.resids',main=list(SampleName, cex = 2))
				  else image(pset, which = i, type = 'sign.resids',main=list(SampleName, cex = 3))
			dev.off()
		}
	} 	

	################# Output stats from MA plot to separate table #################

	num.probes<-length(featureNames(eset))
	Median.Ref<-matrix(data=0, nr=num.probes, nc=1)
	Fold.Change<-matrix(data=0, nr=num.probes, nc=numfiles)

	for(i in 1:num.probes){
 		Median.Ref[i]<-median(exprs(eset)[i,])
  		for(j in 1:numfiles){
    			Fold.Change[i,j]<-(exprs(eset)[i,j]-Median.Ref[i])
		}
	}

	for.table<-matrix(data=0, nr=numfiles, nc=3)
	for(i in 1:numfiles){
		for.table[i,1]<-sampleNames(eset)[i]
		for.table[i,2]<-format(median(Fold.Change[,i]),nsmall=3,digits=4)
		for.table[i,3]<-format(IQR(Fold.Change[,i]),nsmall=2,digits=3)
	}

	header.row<-c("Sample.Name", "Median", "IQR")
	for.table<-rbind(header.row,for.table)
	write.table(for.table, file = paste(imagePath,MAplotStats,sep=""), append = FALSE, sep = '\t',row.names = FALSE,quote=FALSE,col.names=FALSE)	

}  ###END
