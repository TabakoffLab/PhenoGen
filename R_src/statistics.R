########################## statistics.R ################
#
# This function computes the statistics on the filtered genes in the input data
#
# Parms:
#    OutputFile     = name of output file containing input info and added statistics info
#    GeneNumberFile = name of output file for # of genes 
#    InputFile  = name of input file containing Absdata, Avgdata,  
#                     Gnames, grouping, groups, Snames, Procedure
#                     (OutputFile from Affy.filter.genes)	
#    Stat.method  = 'parametric' | 'nonparametric'
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
#    statistics(InputFile = 'HapLap.filter.genes.output.Rdata', Stat.method = 'parametric', OutputFile = 'HapLap.statistics.output.Rdata', GeneNumberFile = 'HapLap.GeneNumberCount.txt', Run.At.Home = F)
#
#
#  Function History
#     ?????????   Tzu Phang   Created      
#     3/21/2005   Diane Birks Modified: added logging via writelog
#	5/1/06	Laura Saba	Modified: added group means and pvalues (both raw and adjusted to output)
#	12/5/06	Laura Saba	Modified: consolidated Affymetrix and CodeLink programs
#	3/30/07	Laura Saba	Modified: added row names to stat output
#	12/14/07	Laura Saba	Modified: added code for when only one gene is passed to this program as input
#	12/31/07	Laura Saba	Modified: created temporary group variable to create groups labeled 1 and 2 (problem in renormalized public experiments)
#
####################################################


statistics <- function(InputFile, Stat.method, OutputFile, GeneNumberFile, Run.At.Home = F) {


  ###################################################
  ###################################################
  ###				          ###################
  ### 	START OF PROGRAM	    ###################
  ###				          ###################
  ###################################################
  ###################################################

  ################# Housekeeping ############################

        # set up libraries and R functions needed

  library(coin)
  fileLoader(c('tzu.wilcox.test.R','tzu.t.test.R'))

	# set up logging

  if(!Run.At.Home) logflag=G_WriteLogAffyStats

  #################################################
  ## Import data	
  ##						
	
  load(InputFile)

  #################################################
  ## Change group numbering to be 1 and 2	(only applicable when a renormalized data set)
  ##	

  a<-sort(unique(grouping)[unique(grouping)!=0])

  tmp.grouping<-grouping
  tmp.grouping[tmp.grouping==a[1]] <- 1
  tmp.grouping[tmp.grouping==a[2]] <- 2	

  tmp.groups<-list()
  for(i in 1:max(tmp.grouping)) tmp.groups[[i]]<-which(tmp.grouping==i)
				
  #################################################
  ## Statistical Analysis
  ##	

  if(length(Gnames) != 1){

	n <- dim(Avgdata)[1] 
	p <- rep(0,n)

	if(Stat.method == 'parametric'){
		if(!Run.At.Home){
			writelog(flag=logflag,'running t.test analysis ....')
		}else{
			cat('running t.test analysis ....\n\n')
		}
		stats<- apply(Avgdata, 1, tzu.t.test, agroup=tmp.groups[[1]], bgroup=tmp.groups[[2]])
		p<-stats[3,]	
	}
	else if(Stat.method == 'nonparametric'){
		if(!Run.At.Home){
			writelog(flag=logflag,'running ranksum analysis ....')
		}else{
			cat('running ranksum analysis ....\n\n')
		}
		stats<- apply(Avgdata, 1, tzu.wilcox.test, tmp.grouping)
		p<-stats[3,]
	}
	else{
		if(!Run.At.Home){
			writelog(flag=logflag,'ERROR - invalid statistical option of ',Stat.method,'must be parametric or nonparametric !')
		}else{
			cat('ERROR - invalid statistical option of ',Stat.method,'must be parametric or nonparametric !\n\n')
		}
	}

	rownames(stats)<-c(paste("Group",a[1],".means",sep=""),paste("Group",a[2],".means",sep=""),"raw.p.value")
	
  }

  else if(length(Gnames)==1){

	n <- 1 
	p <- 0

	if(Stat.method == 'parametric'){
		stats<- tzu.t.test(Avgdata, agroup=tmp.groups[[1]], bgroup=tmp.groups[[2]])
		p<-stats[3]	
	}
	else if(Stat.method == 'nonparametric'){
		stats<- tzu.wilcox.test(Avgdata, tmp.grouping)
		p<-stats[3]
	}
	else{
		if(!Run.At.Home){
			writelog(flag=logflag,'ERROR - invalid statistical option of ',Stat.method,'must be parametric or nonparametric !')
		}else{
			cat('ERROR - invalid statistical option of ',Stat.method,'must be parametric or nonparametric !\n\n')
		}
	}
	names(stats)<-c(paste("Group",a[1],".means",sep=""),paste("Group",a[2],".means",sep=""),"raw.p.value")

  }


  Procedure <- paste(Procedure, 'Function=statistics.R',';','Stat.method=',Stat.method,'|',sep = '')
  cat(file = GeneNumberFile, length(Gnames))

  save(Absdata, Avgdata, Gnames, grouping, groups, Snames, stats, p, Procedure,  file = OutputFile, compress = T)
	
}  #### END 
