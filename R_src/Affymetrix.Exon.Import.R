################### Affymetrix.Exon.Import.R ###################
# [Description]:
#
#  This program imports the normalized expression data and 
# detection calls from Affymetrix Power Tools and transforms
# it into Rdata files to be used for statistical analyses
#
# [Usage]:
#
# Affymetrix.Exon.Import(summaryFile, dabgFile, grouping, OutputFile, output.csv)
#
#
# [Arguments]:
#
# summaryFile: txt file with normalized expression data from APT
#
# dabgFile: txt file with pvalues associated with detection above background calls from APT
#
# FileListing: txt file with a list of CEL files and sample names
#
# grouping: assigning 'group' value to each subject (vector the same length as the number of samples; 0 indicates that the sample should be excluded)
#
# OutputFile: Rdata file to be fed into Affymetrix.filter.genes.R
#		Content:
#			Absdata: present/absent calls based on dabg values < 0.0001
# 			Avgdata: normalized log base 2 transformed expression values
#			Gnames: vector of unique identifiers of transcription units (probe sets or transcript cluster based on normalization)
#			Snames:	vector of unique identifiers of arrays
#			grouping: vector with 'group' value for each subject/array
#			groups: list of group values
#			Procedure: tracking variable for processing
#
# OutputCSVFile: combination of normalized data and present/absent calls output in CSV format
#
# [Details]:
#
# [Value]:
#
# [Author]:
#
# Laura Saba (laura.saba@ucdenver.edu)
#
# [Date]:
#
# created: 06-23-10
# modified: 08-12-10
# modified: 03-22-12
#
# [References]:
#
#
# [Example]:
#  Affymetrix.Exon.Import(summaryFile = "/Users/laurasaba/Documents/Exon Arrays/Data/By Gene/rma.summary.txt",dabgFile = "/Users/laurasaba/Documents/Exon Arrays/Data/By Gene/dabg.summary.txt",grouping <- c(1,1,0,2,2,2),OutputCSVFile <- "/Users/laurasaba/Documents/PhenoGen/Exon Arrays/byGene.csv",OutputFile <- "/Users/laurasaba/Documents/PhenoGen/Exon Arrays/exonImport.Rdata")
#

Affymetrix.Exon.Import <- function(summaryFile, dabgFile, FileListing, grouping, OutputFile, OutputCSVFile){
	
	
	###############################################
	#  Import CEL file and sample names
	#

	fileListing = read.table(FileListing, sep = "\t", header=TRUE)
	fileNames <- unlist(strsplit(rownames(fileListing),"/"))
	fileNames <- fileNames[grep(".CEL",fileNames)]
	

	###############################################
	#  Import expression values and dabg p-values
	#
	
	exprsValues <- read.table(file=summaryFile, header=TRUE, sep="\t",row.names=1,check.names=F)
	dabgValues <- read.table(file=dabgFile,header=TRUE,sep="\t",row.names=1)
	
	arrayInfo = read.table(file=summaryFile,header=FALSE,sep="\t",nrows=25,comment.char="")
	arrayType = strsplit(as.matrix(arrayInfo)[grep("#%affymetrix-algorithm-param-apt-opt-chip-type=",as.matrix(arrayInfo))],"\\=")[[1]][2]
	
	###############################################
	#  Attaching sample names instead of file names
	#
		
	sampleNames <- as.character(fileListing[match(colnames(exprsValues),fileNames),1])
	colnames(exprsValues) <- sampleNames
	colnames(dabgValues) <- sampleNames
	
  	########################################
  	# Create groupings and eliminate excluded samples
  	#

	exprsValues <- exprsValues[,(grouping>0)]
	dabgValues <- dabgValues[,(grouping>0)]
	grouping <- grouping[grouping>0]
	
	groups <- list()
	for(i in 1:max(grouping)) groups[[i]]<-which(grouping==i)
	
	#######################################
    # Creating appropriate variables
    #
	
	Avgdata <- as.matrix(exprsValues)
	Absdata <- (dabgValues<0.0001)*2 - 1
	Gnames = rownames(Avgdata)
	Snames = colnames(Avgdata)
	
    #######################################
    # Output tab delimited file
    #
	
	output.csv = c()
	output.rowname = rownames(Avgdata)
	output.colname = colnames(Avgdata)
	output.colname = rep(output.colname, each = 2)
	output.colname = paste(output.colname,rep(c("",".dabg"),length(Snames)),sep="")

	for(i in 1:dim(Avgdata)[2]){
		output.csv = cbind(output.csv, Avgdata[,i], dabgValues[,i])
	}

	ForOutput = cbind(output.rowname, output.csv)
	colnames(ForOutput)=c("ProbeSetID",output.colname)

	write.table(ForOutput, file = OutputCSVFile, quote = F, sep = ',', row.names = FALSE)

    #######################################
    # Save Rdata sets and initiate procedure variable
    #
    
	Procedure = c(paste("ExonArray=",arrayType,"|",sep=""))
	save(Absdata, Avgdata, Gnames, Snames, grouping, groups, Procedure, file = OutputFile, compress = T)

	}

