########################## outputGeneList.R ################
#
# This function runs the specified test on the data
#
# Parms:
#    OutputGeneList = name of output file for gene count
#    InputFile      = name of input file containing Absdata, Avgdata, 
#                         Gnames, grouping, groups, Snames, p, Procedure, 
#                         GenebankID, kw.p, ttest.p, adjp
#                         (OutputFile from Affy.multipleTest)
#
# Returns:
#    nothing
#
# Writes out:
#    text file   (GeneNumberFile) containing gene count
#    .html file  (OutputHTML)     web page containing gene list
#    .png file   (OutputHeatMap)  graphics file containing heat map
#    .rdata file (OutputRawData)  containing Avgdata
#
# Sample Call:
#    outputGeneList(InputFile = 'AffyMAS5.multipleTest.output.Rdata', InputChipInfoFile = 'ChipInfo.Rdata',OutputGeneList = 'HapLap.genetext.output.txt', Run.At.Home = F)
#
#
#  Function History
#     ?????????   Tzu Phang    Created      
#     3/21/2005   Diane Birks  Modified: Chip.version was hardcoded to 'mgu74av2',
#                                changed to use attr(ChipInfo,'annotation') instead
#                                (from InputChipInfoFile), added MaxHeatMapGenes, added logging via writelog
#	5/1/06	Laura Saba	Modified: added group means and pvalues (both raw and adjusted to output)
#	12/4/06	Laura Saba	Modified: added condition that if two-way ANOVA was used, export column headers
#						    and eliminated separate programs for affymetrix and codelink
#	3/13/07	Laura Saba	Modified: added condition that if Eaves test or correlation was used, export column headers
#	9/25/07	Laura Saba	Modified: added input of group names and export column headers with all data, regardless of statisics used
#	11/20/07	Laura Saba	Modified: corrected coding for situations when there is only one gene in the gene list
#
####################################################


outputGeneList <- function(InputFile, GroupNames, OutputGeneList, Run.At.Home = F){


  ###################################################
  ###################################################
  ###				          ###################
  ### 	START OF PROGRAM	    ###################
  ###				          ###################
  ###################################################
  ###################################################


  #################################################
  ## process data
  ##	

	##  Load Rdata file with stats					
	load(InputFile)

	##  Read in group names
	group.names <- read.table(file=GroupNames,sep="\t",header=TRUE)

	##  Finding statistics method

	tmp<-unlist(strsplit(Procedure,"|",fixed=TRUE))

	for (i in 1:length(tmp)){
  		if (substr(tmp[i],1,32)=="Function=statistics.Clustering.R") method = "cluster"
  		if (substr(tmp[i],1,34)=="Function=statistics.Correlations.R") method = "correlation"
  		if (substr(tmp[i],1,31)=="Function=statistics.EavesTest.R") method = "eaves"
  		if (substr(tmp[i],1,21)=="Function=statistics.R") method = "twogroup"
  		if (substr(tmp[i],1,34)=="Function=statistics.TwoWay.ANOVA.R") method = "twowayanova"
  		if (substr(tmp[i],1,34)=="Function=statistics.OneWay.ANOVA.R") method = "onewayanova"
	}

	##  Adjustments to labels - Two Group Analyses

	if (method == "twogroup"){
		if (length(Gnames)>1){
			row.names<-rownames(stats)
			for (i in 1:length(row.names)){
  				if (substr(row.names[i],1,5)=="Group"){ 
    					tmp.num = substr(unlist(strsplit(row.names[i],"\\."))[1],6,1000)
    					row.names[i]<-paste(group.names$grp.name[group.names$grp.number==tmp.num],".Mean",sep="")
  				}
			}
			rownames(stats) <- row.names
		}
		else if (length(Gnames==1)){
			row.names<-names(stats)
			for (i in 1:length(row.names)){
  				if (substr(row.names[i],1,5)=="Group"){ 
    					tmp.num = substr(unlist(strsplit(row.names[i],"\\."))[1],6,1000)
    					row.names[i]<-paste(group.names$grp.name[group.names$grp.number==tmp.num],".Mean",sep="")
  				}
			}
			names(stats) <- row.names
		}	
	}

	##  Adjustments to labels - Eaves Test

	if (method == "eaves" && length(Gnames)>0){
		row.names<-rownames(stats)
		for (i in 1:length(row.names)){
			if (row.names[i]=="Line1Exp1-Mean") row.names[i]<-paste(group.names$grp.name[group.names$grp.number==1],".Mean",sep="")
			if (row.names[i]=="Line2Exp1-Mean") row.names[i]<-paste(group.names$grp.name[group.names$grp.number==2],".Mean",sep="")
			if (row.names[i]=="Line1Exp2-Mean") row.names[i]<-paste(group.names$grp.name[group.names$grp.number==3],".Mean",sep="")
			if (row.names[i]=="Line2Exp2-Mean") row.names[i]<-paste(group.names$grp.name[group.names$grp.number==4],".Mean",sep="")
		}
		stats <- rbind(round(as.numeric(stats[1,]),digits=3),round(as.numeric(stats[2,]),digits=3),round(as.numeric(stats[3,]),digits=3),round(as.numeric(stats[4,]),digits=3),round(as.numeric(stats[5,]),digits=2),round(as.numeric(stats[6,]),digits=2),stats[7,])
		rownames(stats) <- row.names
	}

	##  Adjustments to labels - Two Way ANOVA

	if (method == "twowayanova"){
		if (length(Gnames)==1) names(stats) <- gsub("()","",names(stats),fixed=TRUE)
		  else rownames(stats) <- gsub("()","",rownames(stats),fixed=TRUE)
	}

	##  Adjustments to labels - One Way ANOVA

	if (method == "onewayanova"){
		if (length(Gnames)>1){
			row.names<-rownames(stats)
			for (i in 1:length(row.names)){
				if (substr(row.names[i],1,5)=="Group") row.names[i] <- as.character(group.names$grp.name[group.names$grp.number==unlist(strsplit(row.names[i],".",fixed=TRUE))[2]])
			}
			rownames(stats) <- row.names
		}
		else if (length(Gnames)==1){
			row.names<-names(stats)
			for (i in 1:length(row.names)){
				if (substr(row.names[i],1,5)=="Group") row.names[i] <- as.character(group.names$grp.name[group.names$grp.number==unlist(strsplit(row.names[i],".",fixed=TRUE))[2]])
			}
			names(stats) <- row.names
		}
	}

	##  Output Gene List

	if (method=="cluster") {
		for.text<-t(stats)
		colnames(for.text)[1]<-"Probe.ID"
		write.table(for.text, file = OutputGeneList, append = FALSE, sep = '\t',row.names = FALSE,col.names=TRUE,quote=FALSE)	
	}

	if (method == "eaves"){
		for.text<-cbind(Gnames,t(format(stats,nsmall=3,digits=4)))
		colnames(for.text)[1]<-"Probe.ID"
		write.table(for.text, file = OutputGeneList, append = FALSE, sep = '\t',row.names = FALSE,col.names=TRUE,quote=FALSE)	
	}
	if (method != "cluster" && method != "eaves"){
		for.text<-cbind(Gnames,t(format(stats,nsmall=3,digits=4)),format(adjp,nsmall=3,digits=4,scientific=TRUE))
		colnames(for.text)[ncol(for.text)]<-"adjusted.p.value"
		colnames(for.text)[1]<-"Probe.ID"
		write.table(for.text, file = OutputGeneList, append = FALSE, sep = '\t',row.names = FALSE,col.names=TRUE,quote=FALSE)	
	}



	################################
	# else: length of Gnames == 0

	if (length(Gnames)<1){
		
		stats = 'No statistically significant gene was selected'
			
		
		cat(stats, file = OutputGeneList, append = FALSE, sep = '\n')	
		
	}


	
} ## END       
	
