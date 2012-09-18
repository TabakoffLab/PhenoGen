########################## QTL.summary.R ################
#
# This function collects summary information for selected
#	markers
#
# Parms:
#	InputFile	= name of input Rdata file created by QTL.analysis.R with genotype and phenotype information and QTL results
#	method 		= type of QTL method to execute (to be implemented later)
#					"em" -> EM algorithm
#					"imp" -> Imputation
#					"hk" -> Haley-Knott regression
#					"mr" -> marker regression
#	select.type	= type of criteria used to select displayed results
#					"LOD" ->
#					"pvalue" ->
#					"location" ->
#	select.crit	= threshold for displaying selected results 
#	conf.type	= method used to calculate confidence interval
#					"none" ->
#					"bootstrap" ->
#					"lod"	->
#					"bayesian" ->
#	conf.crit = parameters needed for determining confidence interval
#		for conf.type = "none"
#			- no parameter is needed (NULL)
#		for conf.type = "bootstrap"
#			- probability converage (0.90, 0.95, or 0.99)
#		for conf.type = "lod"
#			- number of LOD units to drop (1, 1.2, 1.5, or 2)
#		for conf.type = "bayesian"
#			- probability converage (0.90, 0.95, or 0.99) 
#   OutputTXTFile	= name of output txt file containing LOD info for selected SDP
#
# Returns:
#    nothing
#
# Writes out:
#	text file (OutputTXTFile) containing
#
# Sample Call:
#
#
#  Function History
#	11/9/09		Laura Saba	Created
#
####################################################

QTL.summary <- function(InputFile,select.type,select.crit,conf.type,conf.crit,OutputTXTFile){
	
	####################
	##  Housekeeping  ##
	####################
	
	## libraries needed
	library(qtl)
	library(gdata)
	
	## load data
	load(InputFile)
	
	#######################################
	##  Select markers to be summarized  ##
	#######################################

	if(select.type == "LOD"){
		selected.markers <- output[output$LOD > select.crit,]
		}
	else if(select.type == "pvalue"){
		selected.markers <- output[output$p.value < select.crit,]
		}
	else if(select.type == "location"){
		select.new = unlist(strsplit(unlist(strsplit(select.crit,c(":"))),"\\-"))
		selected.markers <- output[(output$chr==select.new[1] & output$pos>as.numeric(select.new[2]) & output$pos<as.numeric(select.new[3])),]
		}
	
	######################################
	##  Calculate confidence intervals  ##
	######################################
	
	if(nrow(selected.markers)>0){
	unique.chr <- as.character(unique(selected.markers$chr))
	
	intervals <- c()
	if(conf.type == "lod"){
		for(i in 1:length(unique.chr)){
			lod.int <- lodint(resultsChr,chr=unique.chr[i],drop=conf.crit)
			lower.limit <- by.SDP[by.SDP$min.SNP == rownames(lod.int)[1],"min.bp"]
			upper.limit <- by.SDP[by.SDP$min.SNP == rownames(lod.int)[nrow(lod.int)],"max.bp"]
			intervals <- rbind(intervals,c(chr=unique.chr[i],lower.limit = lower.limit,upper.limit = upper.limit))
			}
		}
	else if (conf.type == "bayesian"){
		for(i in 1:length(unique.chr)){
			bayes.int <- bayesint(resultsChr,chr=unique.chr[i],prob=conf.crit)
			lower.limit <- by.SDP[by.SDP$min.SNP == trim(rownames(bayes.int)[1]),"min.bp"]
			upper.limit <- by.SDP[by.SDP$min.SNP == trim(rownames(bayes.int)[nrow(bayes.int)]),"max.bp"]
			intervals <- rbind(intervals,c(chr=unique.chr[i],lower.limit = lower.limit ,upper.limit = upper.limit))
			}
		}
	else if(conf.type == "bootstrap"){
		for(i in 1:length(unique.chr)){
			boot <- scanoneboot(reducedChr.cross,chr = unique.chr[i],method="mr",n.boot=1000, weights=weights)
			lower.limit = as.numeric(quantile(boot,(1-conf.crit)/2)) 
			upper.limit = by.SDP[(by.SDP$chr == unique.chr[i] & by.SDP$min.bp == as.numeric(quantile(boot,conf.crit + (1-conf.crit)/2))),"max.bp"]
			intervals <- rbind(intervals,c(chr=as.character(unique.chr[i]),lower.limit = lower.limit,upper.limit = upper.limit))
			}
		}	
	}
	
	#######################################
	##  Calculate selected results file  ##
	#######################################
	
	
	##  Attach Significance Information  ##
	results.SDP <- merge(by.SDP,selected.markers,by.x="min.SNP",by.y=0)
	colnames(results.SDP)[colnames(results.SDP)=="chr.x"] <- "chr"
	
	## attach confidence intervals to max SDP by chr
	if(nrow(results.SDP)<1){
		results.output <- "No markers met selection criteria"
		write.table(results.output,file=OutputTXTFile,quote=FALSE,sep="\t",row.names=FALSE,col.names=FALSE,na=" ")
		}
	else if(conf.type!="none"){

		max.SDP <- aggregate(data.frame(results.SDP$LOD),by=list(as.character(results.SDP$chr)),max)
		colnames(max.SDP) <- c("chr","LOD")
		max.SDP <- merge(max.SDP,intervals,by="chr")
		
		results.output <- merge(results.SDP,max.SDP,all.x=TRUE)
		results.output <- results.output[order(as.numeric(levels(results.output$num.chr)[as.numeric(results.output$num.chr)]),results.output$min.bp),]
		results.output <- results.output[,c("chr","min.bp","max.bp","min.SNP","max.SNP","LOD","LRS","p.value","effect.size","lower.limit","upper.limit")]
		write.table(results.output,file=OutputTXTFile,quote=FALSE,sep="\t",row.names=FALSE,col.names=TRUE,na=" ")
		}
	else if(conf.type=="none"){
		results.output = results.SDP
		results.output <- results.output[,c("chr","min.bp","max.bp","min.SNP","max.SNP","LOD","LRS","p.value","effect.size")]
		results.output <- results.output[order(results.output$chr,results.output$min.bp),]
		write.table(results.output,file=OutputTXTFile,quote=FALSE,sep="\t",row.names=FALSE,col.names=TRUE,na=" ")
		}
		
	
	}