########################## statistics.Correlations.R ################
#
# This function computes correlations on the filtered genes in the input data and the user input for phenotype
#
# Parms:
#    InputFile  = name of input file containing Absdata, Avgdata, Gnames, grouping, groups, Snames, Procedure
#                     (OutputFile from Affy.filter.genes)
#    PhenoFile = Rdata file with phenotype data 	
#    CorrType = type of correlation to calculate
#             "pearson" -> Pearson correlation that assumes normality in both variables
#             "spearman" -> Spearman rank correlation does NOT assume normality in either variable (based on ranks)
#    OutputFile     = name of output file containing expression info and added statistics info
#    GeneNumberFile = name of output file for # of genes 
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
#    statistics.Correlations(InputFile = 'filter.genes.output.Rdata', PhenoFile="", CorrType = "pearson", OutputFile = 'HapLap.statistics.output.Rdata', GeneNumberFile = 'HapLap.GeneNumberCount.txt')
#
#
#  Function History
#	7/5/06	Laura Saba	Created
#	12/4/06	Laura Saba	Modified:  consolidated Affymetrix and CodeLink programs
#	3/12/07	Laura Saba	Modified:  report all strain means in stat file
#	8/24/07	Laura Saba	Modified:  updated to fit with new correlation format
#	12/22/08	Laura Saba	Modified: added code to handle groups when no samples are assigned to a group
#
####################################################


statistics.Correlations <- function(InputFile, PhenoFile, CorrType, OutputFile, GeneNumberFile) {

  ###################################################
  ###################################################
  ###				          ###################
  ### 	START OF PROGRAM	    ###################
  ###				          ###################
  ###################################################
  ###################################################

  library(limma)

  #################################################
  ## process expression data	
  ##						
	
  	load(InputFile)
	
  # Calculate Strain Means

  	NumProbes <- length(Gnames) 
  	if (NumProbes > 1) NumSubjects <- dim(Avgdata)[2]
  	if (NumProbes == 1) NumSubjects <- length(Avgdata)


  	cat('running Correlation analysis ....\n\n')
  	cat(NumProbes,'probes to be analyzed \n\n')
  	cat(NumSubjects,'subjects to be analyzed \n\n')

  	design<-model.matrix(~ -1 + factor(grouping, levels = unique(grouping)[order(unique(grouping))]))
	if (NumProbes>1) fit<-lmFit(Avgdata,design = design)
    if (NumProbes==1) fit<-lm(Avgdata ~ design - 1)

	Strain.means<-fit$coefficients
	colnames(Strain.means) = gsub("factor(grouping, levels = unique(grouping)[order(unique(grouping))])","",colnames(Strain.means),fixed=TRUE)

  # Load Phenotype data

  	load(PhenoFile)

	phenotype<-phenotype[!is.na(phenotype$phenotype),]

  # Accounting for groups with no subjects included
	if(dim(phenotype)[2]>=3) {
		included.groups <- as.data.frame(unique(grouping))
		colnames(included.groups) = "grp.number"
		phenotype <- merge(phenotype,included.groups,by="grp.number")
		Strain.means <- Strain.means[,as.character(phenotype$grp.number)]
				}

  	cat(sum(!is.na(phenotype$phenotype)),'groups with phenotype and expression data \n\n')
	
  # Calculate Correlation Coefficients

	stats<-matrix(data=0, nr=sum(!is.na(phenotype$phenotype))+2, nc=NumProbes)
	p<-matrix(data=0, nr=NumProbes, nc=1)
	for (i in 1:NumProbes){
		if(NumProbes>1) gene<-Strain.means[i,]
		if(NumProbes==1) gene<-Strain.means
		tmp<-cor.test(gene,as.numeric(as.vector(phenotype$phenotype)),method=CorrType,use="complete.obs")
	   	stats[,i]<-c(gene[!is.na(phenotype$phenotype)],tmp$estimate,tmp$p.value)
		p[i]<-stats[sum(!is.na(phenotype$phenotype))+2,i]
	}

	# Correction for when all expression estimates are equal
	p[is.na(p)] = 1
	
	
    labels<-phenotype$grp.name[!is.na(phenotype$phenotype)]
	labels<-c(as.vector(labels),"correlation.coefficient","raw.p.value")
	rownames(stats)<-labels
	
	if(NumProbes==1) colnames(stats)<-Gnames

	cat(file = GeneNumberFile, length(Gnames))

	Procedure <- paste(Procedure, 'Function=statistics.Correlations.R',';','Stat.method = Correlation',';','Corr.Type = ',CorrType,'|',sep = '')

	save(Absdata, Avgdata, Gnames, grouping, groups, Snames, stats, p, Procedure,  file = OutputFile, compress = T)


	
}  #### END 
