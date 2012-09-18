#    function findXMLProbes(InputXMLFileName)
# 	  Returns a list of Probeset ID's
#
# Example Call:
# testXML = findXMLProbes("/Users/clemensl/LaurensR/Combine/Test1XML.xml")
#
#
#

findXMLProbes <- function(InputXMLFileName) {

	###########################################
	#   Load Packages & Setup Working Space   #
	###########################################

	library(XML)


	doc = xmlParse(InputXMLFileName)
	allExonProbeNodes = getNodeSet(doc,"/GeneList/Gene/TranscriptList/Transcript/exonList/exon/ProbesetList/Probeset")
	allIntronProbeNodes = getNodeSet(doc,"/GeneList/Gene/TranscriptList/Transcript/intronList/intron/ProbesetList/Probeset")
	probeNameListe <- sapply(allExonProbeNodes, xmlGetAttr, "ID")
	probeNameListi <- sapply(allIntronProbeNodes, xmlGetAttr, "ID")
	probeNames <-c(probeNameListe,probeNameListi)
	uniqueProbeNames <- noquote(unique(probeNames))
	
}

#testXML = findXMLProbes("/Users/clemensl/LaurensR/Combine/Test1XML.xml")


#				HeatMapCorrData.R
#
# This function reads an RData file and a list of probesets
# Output is a file containing a correlation matrix to be input to draw heatmaps
#
# There are 3 arguments:
#
#	RData input file name including path
#	XML input file name including path
#   Heat Map data output file name including path
#
#
# The function returns the correlation matrix and writes the data to a file
#
# Example Call:
# 
#
#TestHeatMapData <- HeatMapCorrData("/Users/clemensl/LaurensR/InputData/HXB_means_precollapse_onlyRI.Rdata", 
#    "/Users/clemensl/LaurensR/Combine/Test1XML.xml", 
#    "/Users/clemensl/LaurensR/Output/Cd36_ExonAligned_4plot.csv" )
#

Affymetrix.Exon.HeatMap <- function(InputFile,Version,SampleFile, XMLFileName, plotFileName) {

	###########################################
	#   Load Packages & Setup Working Space   #
	###########################################

	library(gplots)

	#RdataFileName <- "/Users/clemensl/LaurensR/InputData/HXB_means_precollapse_onlyRI.Rdata"
	#ps_exonFileName <- "/Users/clemensl/LaurensR/InputData/Cd36_ps_exon_align.txt"
	#plotFileName <- "/Users/clemensl/LaurensR/Output/Cd36_ExonAligned_4plot.csv" 

	#####################
	#    Load Data      #
	#####################

	#load(RdataFileName)
	require(h5r)
	h5 <- H5File(InputFile, mode = "r")
	gVersion<-getH5Group(h5, Version)
	ds <- getH5Dataset(gVersion, "Data")
	Avgdata<-array(dim=c(dim(ds)[1],dim(ds)[2]))
	Avgdata[,]<-ds[1:dim(ds)[1],1:dim(ds)[2]]
	ps <- getH5Dataset(gVersion, "Probeset")
	Gnames<-ps[]
	ins <- scan(SampleFile, list(""))
	Snames<-ins[[1]]
	rownames(Avgdata)<-Gnames
	colnames(Avgdata)<-Snames
	
		
	objects()
	dim(Avgdata)
	
	
	ps <- as.matrix(findXMLProbes(XMLFileName))
	
	
	Sig_list <- c()
	for(i in ps){
		Sig_list = c(Sig_list, which(rownames(Avgdata)==i))
	}
	length(ps)
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
	
}

#testHeatMapData <- HeatMapCorrData("/Users/clemensl/LaurensR/InputData/HXB_means_precollapse_onlyRI.Rdata", "/Users/clemensl/LaurensR/Combine/Gene.xml", "/Users/clemensl/LaurensR/Output/Cd36_ExonAligned_4plot.csv" )
#testHeatMapData <- HeatMapCorrData("/userFiles/public/Datasets/PublicILSXISSRIMice_Master/v3/Affymetrix.ExportOutBioC.output.Rdata", "/Users/clemensl/LaurensR/Combine/Gene.xml", "/Users/clemensl/LaurensR/Output/Cd36_ExonAligned_4plot.csv" )
