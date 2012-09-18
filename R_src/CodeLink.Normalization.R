################### CodeLink.Normalization.R ###################
# [Description]:
#
# A wrapper function for normalizing CodeLink microarray
# data and exporting and R data set consistent with the data
# set exported from Affymetrix processing.  
#
# [Usage]:
#
# CodeLink.Normalization(Input.arrayDataObject, grouping, norm.method = 'none', norm.para1, OutputFile, output.csv)
#
#
# [Arguments]:
#
# Input.arrayDataObject: arrayData object from CodeLink.ImportTxt.R function
#
# grouping: assigning 'group' value to each subject (vector the same length as the number of samples; 0 indicates that the sample should be excluded)
#
# norm.method: 
#	none = use raw data
#	loess = normalize.loess
#	vsn = vsn		
#	limma = normalizeBetweenArrays
#
# norm.para1
#	normalize.loess	: family.loess
#			  'guassian','symmetric'
#
#	vsn: none
#	normalizeBetweenArrays: method
#				'scale','quantile'
#
# OutputFile: BioC binary file to be fed into the next CodeLink function
#		Content:
#			geneNames : gene name identifiers
#			sampleNames : sampel names
#
# output.csv: data output in CSV format
#
# [Details]:
#
# [Value]:
#
# [Author]:
#
# Tzu Phang (tzu.phang@uchsc.edu)
#
# [Date]:
#
# created: 06-30-05
# modified: 03-28-06 by Laura Saba
# modified: 04-09-09 by Laura Saba
#
# [References]:
#
#
# [Example]:
#
# CodeLink.Normalization(Input.arrayDataObject = 'CodeLink.ImportTxt.output.Rdata', norm.method = 'none', norm.para1 = 'T', OutputFile = 'CodeLink.Normalization.output.Rdata', output.csv = 'CodeLink.Normalization.output.csv')
#


CodeLink.Normalization <- function(Input.arrayDataObject, grouping, norm.method = 'none', norm.para1, OutputFile, output.csv){


	#############################
	# loading required packages
	#

	library(affy)	
	library(vsn)
	library(limma)
	library(marray)

	##############################
	# helper functions
	#

	convert.dis.flag<-function(vector){

		vector[vector == 'D'] = 1
		vector[vector == 'P'] = 0
		vector[vector == 'N'] = 0

		return(as.numeric(vector))

	}

	convert.gs.flag<-function(vector){

		vector[vector == 'A'] = -1
		vector[vector == 'P'] = 1
		vector[vector == 'M'] = 0
		vector[vector == 'U'] = 0
		
		return(as.numeric(vector))

	}

	convert.codelink.flag<-function(vector){

		vector[vector == 'G'] = 1
		vector[vector == 'L'] = -1
		vector[vector == 'C'] = 0
		vector[vector == 'I'] = 0
		vector[vector == 'M'] = 0
		vector[vector == 'S'] = 0
		vector[vector == 'X'] = 0
		vector[vector == 'CL'] = 0
		vector[vector == 'CI'] = 0
		vector[vector == 'CS'] = 0
		vector[vector == 'IS'] = 0
		vector[vector == 'IL'] = 0
		vector[vector == 'LS'] = 0
		vector[vector == 'CIS'] = 0


		return(as.numeric(vector))

	}


	NA.to.0<-function(element){

		if(is.na(element)){
			element = 0
		}
		return(element)

	}
	

	##############################
	# load input data set
	#

	load(Input.arrayDataObject)

	#############################
	# Data extraction and eliminated of 'excluded' samples
	# 
	
	array.data = apply(chip.info$exp.value,2,as.numeric)
	array.data = array.data[,grouping!=0]
	sample.names = sample.names[grouping!=0]

	#############################
	# Data normalization
	# 
	#


	if(norm.method == 'none'){

		array.data[array.data<1] = 1

		array.norm.data = log2(array.data)
	
	}else if(norm.method == 'loess'){
	
		norm.para1 = as.character(norm.para1)
		
		array.data[array.data<1] = 1

		array.data = log2(array.data)
		
		array.norm.data = normalize.loess(array.data, log.it = F, family.loess = norm.para1)
		
	}else if(norm.method == 'vsn'){

		fit = vsn2(array.data)

		array.norm.data = predict(fit,newdata=array.data)

	}else if(norm.method == 'limma'){

		norm.para1 = as.character(norm.para1)

		if (norm.para1!='vsn'){
			array.data[array.data<1] = 1
			array.data = log2(array.data)
		}

		array.norm.data = normalizeBetweenArrays(array.data, method = norm.para1)

	}else{

		cat('No known normalization method was selected \n')
	
	}


	#############################
	# output normalized data values
	# 

	geneNames = chip.info$geneid
	tmp = cbind(geneNames,array.norm.data)
	tmp = rbind(c("ProbeID",as.vector(sample.names)),tmp)
	write.table(tmp, file = output.csv, quote = F, sep = ',', row.names = FALSE, col.names = FALSE)


      ########################################
	## Transfer variables
	##
		Chip.version = c()

		Avgdata = array.norm.data
		chip.info$type.flag= chip.info$type.flag[,grouping!=0]
		Discovery = chip.info$type.flag
		Absdata = chip.info$codelink.flag[,grouping!=0]
		GS.call = chip.info$gs.flag[,grouping!=0]
		Gnames = chip.info$geneid
		Snames = sample.names

		colnames(Avgdata)<-Snames
		rownames(Avgdata)<-Gnames

		cat('Avgdata has ',dim(Avgdata)[1], ' rows and ', dim(Avgdata)[2], ' columns \n')

		grouping = grouping[grouping!=0]
		groups<-list()
    		for(i in 1:max(grouping)) groups[[i]]<-which(grouping==i)
			

	## END OF:Transfer variables
	########################################


	########################################
	# Converting character to numeric
	#
	# Discovery	D	-> 1
	#		P	-> 0
	#		N	-> 0
	#
	# Absdata: 	A 	-> -1
	#		P 	-> 1
	#		M, U 	-> 0
	# GS.call:	L 	-> -1
	#		G 	-> 1
	# 		C,CL,I,M,S,IS,CI -> 0

	Discovery = apply(Discovery,2,convert.dis.flag)	

	Absdata = apply(Absdata,2,convert.codelink.flag)
	Absdata[is.na(Absdata)] = 0

	GS.call = apply(GS.call,2,convert.gs.flag)	
		
	Procedure = c()

	save(chip.info, Avgdata, Discovery, Absdata, GS.call, Gnames, Snames, grouping, groups, Procedure, Chip.version, file = OutputFile)

}  ## END OF:  CodeLink.Normalization