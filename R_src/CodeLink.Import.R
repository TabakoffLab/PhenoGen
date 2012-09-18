
############ CodeLink.Import.R ####################
# [Description]:
#
# This function imports .txt files according to 
# the order specific in the phenoData.txt file
# and return the compilation in "arrayData" object
# from "arrayMagic" package
#
# [Usage]:
#
# CodeLink.ImportTxt(path, phenoDataFile, arrayDataObject)
#
# [Arguments]:
#
# import.path:		the path where the .txt files reside
# export.path:		the path where the experiment specific files will reside
# arrayDataObject:	the name of the Rdata file to output
# phenoDataFile: 		the name of the txt file with the list of file names and sample names
#
#
#	fileName	sampleid	phenotype	sex	slideNumber
#	hybrid682.gpr	Igor682	CLL	m	1
#	hybrid684.gpr	Igor684	CLL	m	2
#	hybrid685.gpr	Igor685	CLL	f	3
#	hybrid686.gpr	Igor686	CLL	f	4
#	hybrid687.gpr	Igor687	DLCL	f	5
#	hybrid688.gpr	Igor688	DLCL	m	6
#	hybrid689.gpr	Igor689	DLCL	NA	7
#
# 	Note1: First row must be headers
# 	Note2: insert "NA" for value unknown (without the quote)
# 	fileName: must match .gpr file names
# 	sampleid: name given to each sample from MIAMExpress
# 	phenotype: sample phenotype from MIAMExpress
# 	sex: sex of sample from MIAMExpress
# 	slideNumber: sequential numbering of chips
# 
# arrayDataObject: A simple class to store raw data, 
# 		annotation information for spots and hybridisations, 
#		as well as weights (see arrayMagic package).
#
#
# [Details]:
#
# [Value]:
# 
# arrayDataObject: A simple class to store raw data, 
# 		annotation information for spots and hybridisations, 
#		as well as weights (see arrayMagic package).
#
#
# 
#
# [Author]:
#
# tzu phang (tzu.phang@uchsc.edu)
#
# [Date]:
#
# created: 06-30-05
# modified: 
#
# [Reference]:
#
#
# [Example]:
# 
# CodeLink.ImportTxt(path = '/Users/tzu/Documents/INIA/Modules/Statistical Analysis/BorisCodeLinkRat/', phenoDataFile = 'CodeLink.PhenoData.txt', arrayDataObject = 'CodeLink.ImportTxt.output.Rdata')

CodeLink.Import <- function(import.path, export.path, phenoDataFile, arrayDataObject){

	#############################
	# loading required packages
	#
	
	library(limma)

	fileLoader('read.CodeLink.txt.R')

	#############################

	# Reading .txt files and compile
	# data in arrayData object (aD)
	#

	chip.info = read.CodeLink.txt(import.path = import.path, export.path= export.path, fileListFile = phenoDataFile)

	phenoDataFile = paste(export.path,phenoDataFile,sep="/")
	sample.names = read.table(file = phenoDataFile, sep="\t", header=FALSE)$V2
	file.names = read.table(file = phenoDataFile, sep="\t", header=FALSE)$V1


	save(sample.names, file.names, chip.info, file = paste(export.path,arrayDataObject,sep="/"), compress = T)



}  ## END OF: CodeLink.ImportTxt 