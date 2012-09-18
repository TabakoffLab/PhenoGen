########################## statistics.TwoWay.ANOVA.R ################
#
# This function computes a 2-way ANOVA on the filtered genes in the input data when there are two factors
#
# Parms:
#    OutputFile     	= name of output file containing input info and added statistics info
#    GeneNumberFile 	= name of output file for # of genes 
#    InputFile  		= name of input file containing Absdata, Avgdata,  
#                     		Gnames, grouping, groups, Snames, Procedure
#                     		(OutputFile from Affy.filter.genes)
#    FactorFile 		= name in file with factors for two-way ANOVA	
#    pvalue			= which pvalue is of interest 
#             			"Model" -> overall model p-value (model with both main effects and an interaction effect)
#             			"Factor1" -> significance of Factor1 (model without an interaction effect)
#		  			"Factor2" -> significance of Factor2 (model without an interaction effect)
#		  			"Interaction" -> significance of interaction effect (model with both main effects and an interaction effect)
#
# Returns:
#    nothing
#
# Writes out:
#    .rdata file (OutputFile) containing Absdata, Avgdata, 
#                     Gnames, grouping, groups, Snames, p, Procedure
#    text file (GeneNumberFile) containing gene count
#
# Sample Call:
#    Affy.statistics.TwoWay.ANOVA(InputFile = 'HapLap.filter.genes.output.Rdata', pvalue = "Model", OutputFile = 'HapLap.statistics.output.Rdata', GeneNumberFile = 'HapLap.GeneNumberCount.txt', Run.At.Home = F)
#
#
#  Function History
#	9/27/06	Laura Saba	Created
#	12/7/06	Laura Saba	Modified:	consolidated Affymetrix and CodeLink programs
#	1/8/08	Laura Saba	Modified:	created stipulations for analyzing only one gene
#
####################################################


statistics.TwoWay.ANOVA <- function(InputFile, FactorFile, pvalue, OutputFile, GeneNumberFile, Run.At.Home = F) {

  ###################################################
  ###################################################
  ###### 	 START OF PROGRAM	    ###################
  ###################################################
  ###################################################

  # set up libraries and R functions needed
	library(limma)
	library(car)

  #################################################
  ## process data	
  ##						
	
	load(InputFile)
	
	cat('running Two-Way ANOVA analysis ....\n\n')

	##Reading in phenotype data
	pheno<-read.table(file=FactorFile,sep="\t",header=TRUE,row.names=1)

	##Match sample names between expression data and phenotype data
	if (length(Gnames)>1) pheno<-pheno[colnames(Avgdata),]
	if (length(Gnames)==1) pheno<-pheno[names(Avgdata),]
	
      tmp<-sum(is.na(pheno[,1]))
	if (tmp>0) cat("Error:  Sample Names in phenotype file do not match expression data","\n","Execution Halted","\n\n")

	##Two-Way ANOVA functions (gene-by-bene)

	TwoWayANOVA<-function(Avgdata,pheno,pvalue){
		example<-cbind(pheno,Avgdata)
		colnames(example)<-c("Factor1","Factor2","Expression")

		if (pvalue=="Model"){
			out<-summary(lm(Expression ~ Factor1*Factor2, example))$fstatistic
			coefficients<-lm(Expression ~ Factor1*Factor2, example)$coefficients
			Fstat<-out[1]
			p<-1-pf(Fstat,out[2],out[3])
		}
		if (pvalue=="Interaction"){ 
			out<-anova(lm(Expression ~ Factor1*Factor2, example))
			coefficients<-lm(Expression ~ Factor1*Factor2, example)$coefficients
			Fstat<-out[3,4]
			p<-out[3,5]
		}
		if (pvalue=="Factor1"){ 
			out<-Anova(lm(Expression ~ Factor1 + Factor2, example),type="III")
			coefficients<-lm(Expression ~ Factor1 + Factor2, example)$coefficients
			Fstat<-out[2,3]
			p<-out[2,4]
		}
		if (pvalue=="Factor2"){#need to correct
			out<-Anova(lm(Expression ~ Factor1 + Factor2, example),type="III")
			coefficients<-lm(Expression ~ Factor1 + Factor2, example)$coefficients
			Fstat<-out[3,3]
			p<-out[3,4]
		}

		return(c(coefficients,Fstat,p))
	}

	
	if (length(Gnames)>1) { 
		stats<-apply(Avgdata,1,TwoWayANOVA,pheno=pheno,pvalue=pvalue)

		#Check to make sure model was not over-parameterized
		if (sum(is.na(stats[,1]))>0) cat("Error:  Model is Overparameterized","\n","Execution Halted","\n\n")
		
		#Get correct variable names and transpose data
		rownames(stats)[(nrow(stats)-1):(nrow(stats))]<-c("F.statistic","raw.p.value")
		p<-stats[nrow(stats),]

		#Renaming column headings to match factor names
		names<-rownames(stats)
		original<-colnames(pheno)

		for (i in 1:nrow(stats)){
			numfac<-length(strsplit(names[i],":")[[1]])
			if (names[i]=="(Intercept)") names[i]<-"Intercept"
			else if (substr(names[i],1,7)=="Factor1" && numfac==1) names[i]<-paste(original[1],"(",substring(names[i],8),")",sep="")
			else if (substr(names[i],1,7)=="Factor2" && numfac==1) names[i]<-paste(original[2],"(",substring(names[i],8),")",sep="")
			else if (numfac==2){
				split<-strsplit(names[i],":")
				if (substr(split[[1]][1],1,7)=="Factor1") split[[1]][1]<-paste(original[1],"(",substring(split[[1]][1],8),")",sep="")
				if (substr(split[[1]][2],1,7)=="Factor2") split[[1]][2]<-paste(original[2],"(",substring(split[[1]][2],8),")",sep="")
				names[i]<-paste(split[[1]][1],split[[1]][2],sep=":")
			}
		}

		rownames(stats)<-names
	}

	if (length(Gnames)==1) { 
		stats<-TwoWayANOVA(Avgdata,pheno=pheno,pvalue=pvalue)

		#Check to make sure model was not over-parameterized
		if (sum(is.na(stats))>0) cat("Error:  Model is Overparameterized","\n","Execution Halted","\n\n")
		
		#Get correct variable names and transpose data
		names(stats)[(length(stats)-1):(length(stats))]<-c("F.statistic","raw.p.value")
		p<-stats[length(stats)]

		#Renaming column headings to match factor names
		names<-names(stats)
		original<-colnames(pheno)

		for (i in 1:length(stats)){
			numfac<-length(strsplit(names[i],":")[[1]])
			if (names[i]=="(Intercept)") names[i]<-"Intercept"
			else if (substr(names[i],1,7)=="Factor1" && numfac==1) names[i]<-paste(original[1],"(",substring(names[i],8),")",sep="")
			else if (substr(names[i],1,7)=="Factor2" && numfac==1) names[i]<-paste(original[2],"(",substring(names[i],8),")",sep="")
			else if (numfac==2){
				split<-strsplit(names[i],":")
				if (substr(split[[1]][1],1,7)=="Factor1") split[[1]][1]<-paste(original[1],"(",substring(split[[1]][1],8),")",sep="")
				if (substr(split[[1]][2],1,7)=="Factor2") split[[1]][2]<-paste(original[2],"(",substring(split[[1]][2],8),")",sep="")
				names[i]<-paste(split[[1]][1],split[[1]][2],sep=":")
			}
		}

		names(stats)<-names
	}

	Procedure <- paste(Procedure, 'Function=statistics.TwoWay.ANOVA.R',';','Stat.method = two-way ANOVA',';','pvalue of interest=',pvalue,'|',sep = '')
	cat(file = GeneNumberFile, length(Gnames))


	save(Absdata, Avgdata, Gnames, grouping, groups, Snames, stats, p, Procedure,  file = OutputFile, compress = T)


	
}  #### END 
