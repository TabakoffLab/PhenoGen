########################## statistics.OneWay.ANOVA.R ################
#
# This function computes the statistics on the filtered genes in the input data when there is more than two groups or more than one factor
#
# Parms:
#    OutputFile     = name of output file containing input info and added statistics info
#    GeneNumberFile = name of output file for # of genes 
#    InputFile  = name of input file containing Absdata, Avgdata,  
#                     Gnames, grouping, groups, Snames, Procedure
#                     (OutputFile from Affy.filter.genes)	
#    pvalue = which pvalue is of interest (when 4 or less groups)
#             "Model" -> overall model p-value (factor effect)
#             "Group 1 - Group 2" -> difference between group 1 and group 2 (smaller number is always on the left)
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
#    statistics.OneWay.ANOVA(InputFile = 'HapLap.filter.genes.output.Rdata', pvalue = "Model", OutputFile = 'HapLap.statistics.output.Rdata', GeneNumberFile = 'HapLap.GeneNumberCount.txt', Run.At.Home = F)
#
#
#  Function History
#	6/27/06		Laura Saba	Created
#	12/4/06		Laura Saba	Modified:  consolidated affymetrix and codelink programs
#	3/30/07		Laura Saba	Modified:  added row names to stats matrix and changed spaces to '.' for group names
#	11/20/07		Laura Saba	Modified:  corrected error in calculating contrasts caused by updated version of R 2.6.0
#	1/08/07		Laura Saba	Modified:  made changes for when there is only one gene analyzed
#
####################################################


statistics.OneWay.ANOVA <- function(InputFile, pvalue, OutputFile, GeneNumberFile, Run.At.Home = F) {

  ###################################################
  ###################################################
  ###				          ###################
  ### 	START OF PROGRAM	    ###################
  ###				          ###################
  ###################################################
  ###################################################

  # set up libraries and R functions needed
	library(limma)
	library(MASS)
      fileLoader('CreateContrasts.R')

  #################################################
  ## process data	
  ##						
	
	load(InputFile)
	
	n <- length(Gnames) 
	p <- rep(0,n)

	cat('running ANOVA analysis ....\n\n')

      new.grouping<-grouping[grouping!=0]
	if (n>1) new.Avgdata<-Avgdata[,grouping!=0]
	else if (n==1) new.Avgdata <- Avgdata[grouping!=0]

	tmp<-new.grouping[order(new.grouping)]
	if (n>1) Avgdata.tmp<-new.Avgdata[,order(new.grouping)]
	else if (n==1) Avgdata.tmp<-new.Avgdata[order(new.grouping)]

	design<-model.matrix(~ -1 + factor(tmp, levels = unique(tmp)))
	colnames(design)<-unique(tmp)
	contrast.matrix <- design.pairs(unique(tmp))

	if (n>1) {
		fit<-lmFit(Avgdata.tmp,design = design)
		fit2<-contrasts.fit(fit,contrast.matrix)
		fit2<-eBayes(fit2)
	}
	else if (n==1) {
		fit<-lm(Avgdata.tmp ~ design - 1,contrasts=contrast.matrix)
		fit2 = c()
		StdErr = (summary(fit)$sigma^2*t(contrast.matrix)^2%*%matrix(colSums(design),ncol=1)^-1)^0.5
		Estimates = colSums(coef(fit)*contrast.matrix)
		fit2$F<-summary(lm(Avgdata.tmp ~ design))$fstatistic[1]
		fit2$F.p.value <- 1-pf(summary(lm(Avgdata.tmp ~ design))$fstatistic[1],summary(lm(Avgdata.tmp ~ design))$fstatistic[2],summary(lm(Avgdata.tmp ~ design))$fstatistic[3])
		fit2$t <- Estimates / StdErr
		fit2$p.value <- (1 - pt(abs(fit2$t),sum(design)-ncol(design)))*2
	}

	title.groups <- paste("Group",unique(tmp),sep=".")
	Group.Means<-fit$coefficients
	
	if (pvalue=="Model") {
		p <- fit2$F.p.value
		if (n>1) {
			stats <- t(cbind(Group.Means,fit2$F,fit2$F.p.value))
			rownames(stats)<-c(title.groups,'F.statistic','raw.p.value')
		}
		if (n==1) {
			stats <- c(Group.Means,fit2$F,fit2$F.p.value)
			names(stats)<-c(title.groups,'F.statistic','raw.p.value')
		}
	}
	else if(pvalue=="Group 1 - Group 2") {
		if (n>1) {
			p <- fit2$p.value[,colnames(fit2)=="1-2"]
			stats <- t(cbind(Group.Means,fit2$t[,colnames(fit2)=="1-2"],fit2$p.value[,colnames(fit2)=="1-2"]))
			rownames(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
		if (n==1) {
			p <- fit2$p.value["1-2",]
			stats <- c(Group.Means,fit2$t["1-2",],fit2$p.value["1-2",])
			names(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
	}
	else if(pvalue=="Group 1 - Group 3") {
		if (n>1) {
			p <- fit2$p.value[,colnames(fit2)=="1-3"]
			stats <- t(cbind(Group.Means,fit2$t[,colnames(fit2)=="1-3"],fit2$p.value[,colnames(fit2)=="1-3"]))
			rownames(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
		if (n==1) {
			p <- fit2$p.value["1-3",]
			stats <-c(Group.Means,fit2$t["1-3",],fit2$p.value["1-3",])
			names(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
	}
	else if(pvalue=="Group 1 - Group 4") {
		if (n>1) {
			p <- fit2$p.value[,colnames(fit2)=="1-4"]
			stats <- t(cbind(Group.Means,fit2$t[,colnames(fit2)=="1-4"],fit2$p.value[,colnames(fit2)=="1-4"]))
			rownames(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
		if (n==1) {
			p <- fit2$p.value["1-4",]
			stats <- c(Group.Means,fit2$t["1-4",],fit2$p.value["1-4",])
			names(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
	}
	else if(pvalue=="Group 2 - Group 3") {
		if (n>1) {
			p <- fit2$p.value[,colnames(fit2)=="2-3"]
			stats <- t(cbind(Group.Means,fit2$t[,colnames(fit2)=="2-3"],fit2$p.value[,colnames(fit2)=="2-3"]))
			rownames(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
		if (n==1) {
			p <- fit2$p.value["2-3",]
			stats <- c(Group.Means,fit2$t["1-2",],fit2$p.value["2-3",])
			names(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
	}
	else if(pvalue=="Group 2 - Group 4") {
		if (n>1) {
			p <- fit2$p.value[,colnames(fit2)=="2-4"]
			stats <- t(cbind(Group.Means,fit2$t[,colnames(fit2)=="2-4"],fit2$p.value[,colnames(fit2)=="2-4"]))
			rownames(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
		if (n==1) {
			p <- fit2$p.value["2-4",]
			stats <- c(Group.Means,fit2$t["2-4",],fit2$p.value["2-4",])
			names(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
	}
	else if(pvalue=="Group 3 - Group 4") {
		if (n>1) {
			p <- fit2$p.value[,colnames(fit2)=="3-4"]
			stats <- t(cbind(Group.Means,fit2$t[,colnames(fit2)=="3-4"],fit2$p.value[,colnames(fit2)=="3-4"]))
			rownames(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
		if (n==1) {
			print(title.groups)
			p <- fit2$p.value["3-4",]
			stats <- c(Group.Means,fit2$t["3-4",],fit2$p.value["3-4",])
			names(stats)<-c(title.groups,'t.statistic','raw.p.value')
		}
	}
	Procedure <- paste(Procedure, 'Function=statistics.OneWay.ANOVA.R',';','Stat.method = one-way ANOVA',';','pvalue of interest=',pvalue,'|',sep = '')
	cat(file = GeneNumberFile, length(Gnames))


	save(Absdata, Avgdata, Gnames, grouping, groups, Snames, stats, p, Procedure,  file = OutputFile, compress = T)


	
}  #### END 
