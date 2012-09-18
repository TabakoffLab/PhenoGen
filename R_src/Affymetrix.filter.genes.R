########################## Affymetrix.filter.genes.R ################
#
# This function filters the genes in the InputDataFile
#
# Parms:
#    OutputFile     = output file name for updated input with filter added to Procedure  
#    GeneNumberFile = output file name for # of genes
#    InputDataFile  = name of input file containing Avgdata, Absdata, Snames, and Gnames 
#                     (OutputFile from Affy.ExportOutBioC)	
#    filter.method  = type of filter to apply (see details below)
#    filter.parameter1 = options for filter method (see details below)
#    filter.parameter2 = options for filter method (see details below)
#
#         Values for filter.method, filter.parameter1, and filter.parameter2:
#         filter.method Choices:
#             -- affy.control.genes
#             -- absolute.call.filter
#             ----- filter.parameter1 = rep(-4,9)
#             ----- filter.parameter2 = 1 (keep)
#             ----- filter.parameter2 = 2 (remove)
#             -- negative.probe.filter
#             ----- filter.parameter1 = rep(-4,9)
#             ----- filter.parameter2 = 1 (keep)
#             ----- filter.parameter2 = 2 (remove)
#		  	  -- gene.list
#		  	  ----- filter.parameter1 = filename of probe set list
#             ----- filter.parameter2 = 1 (keep)
#             ----- filter.parameter2 = 2 (remove)
#             -- variation
#             ----- filter.parameter1 = proportion or number of "top" probe sets to keep
#             ----- filter.parameter2 = -99 (none needed)
#             -- fold.change
#             ----- filter.parameter1 = proportion or number of "top" probe sets to keep
#             ----- filter.parameter2 = -99 (none needed)
#             -- herit
#             ----- filter.parameter1 = name and location of heritability file 
#             ----- filter.parameter2 = heritability criteria (probes with heritabilities above this criteria will be retained, e.g. 0.50, 0.75)
#
# Returns:
#    nothing
#
# Writes out:
#    .rdata file (OutputFile) containing Absdata, Avgdata, 
#           Gnames, grouping, groups, Snames, Procedure updated with gene filter
#    text file (GeneNumberFile) containing gene count 
#
# Sample Call:
#    Affymetrix.filter.genes.Clusterinig(InputDataFile = 'ExportOutBioC.output.Rdata', OriginalFile = 'ExportOutBioC.output.Rdata', filter.method = 'affy.control.genes', filter.parameter1 = -99, filter.parameter2 = -99, OutputFile='filter.genes.output.Rdata', GeneNumberFile = 'GeneNumberCount.txt')
#
#
#  Function History
#     	?????????   Tzu Phang     Created      
#     	3/21/2005	Diane Birks   Modified: added logging via #writelog
#     	6/29/2006	Laura Saba	Modified: changed to incorporate more than two rungroups
#     	7/11/2006	Laura Saba	Modified: incorporate negative control filter
#     	12/8/2006	Laura Saba 	Modified: corrected error in absolute call filter
#     	1/2/2007	Laura Saba	Modified: changed negative control filter to have options like absolute call filter
#     	4/19/2007	Laura Saba	Modified: created a temporary 'groups' variable because of issues with correlation data
#     	08/09/07		Laura Saba	Modified: added filters specific to clustering
#     	11/15/07	Laura Saba	Modified: changed name of program and function
#		08/14/09	Laura Saba	Modified: Added heritability filter
#		07/21/10	Laura Saba	Modified: Added control filter for exon arrays
#		09/20/10	Laura Saba	Modified: corrected error in absolute call filter when identifying 'absent' probesets
#											when there are more than 2 groups
#
####################################################


Affymetrix.filter.genes<-function(InputDataFile, OriginalFile, filter.method, filter.parameter1, filter.parameter2, OutputFile, GeneNumberFile){

  ################# Housekeeping ############################

        # set up libraries and R functions needed
	fileLoader(c('tzu.CharToNum.R','medianfilter.R','fdr.R','tzu.CV.R'))
	library(affy)
	library(marray)
	library(genefilter)
	
  #######################################
  ## load data and apply filters
  ##

	load(OriginalFile)
	orig.Gnames<-Gnames
	orig.Avgdata<-Avgdata

	load(InputDataFile)

	## END OF:Transfer variables
	########################################

	
	###############################################
	###############################################
	###				            ###################
	### 	START OF PROGRAM	###################
	###				            ###################
	###############################################
	###############################################

      #######################################
      ## create temporary 'groups' variable to account for correlation data
      ##

	tmp.groups <- groups
	orig.NumGroups <-length(tmp.groups)
	for (i in 1:orig.NumGroups){
		j = orig.NumGroups - i + 1
		if (length(tmp.groups[[j]])==0) tmp.groups[[j]]<-NULL
	}

 ################# control gene filter ######################
	
	if(filter.method == 'affy.control.genes'){

		cat('Running control filter function ....\n\n')
		filter.index = grep('AFFX', Gnames)
		
		## Exception for Mouse Exon Array
		if(!is.null(Procedure)){
		if(regexpr("MoEx-1_0-st-v1",Procedure)>0) {
			library(MoExExonProbesetLocation)
			controls <- MoExExonProbesetLocation[MoExExonProbesetLocation$ANNLEVEL=="---","EPROBESETID"]
			filter.index <- match(controls,Gnames)
			filter.index <- filter.index[!is.na(filter.index)]
			}

		## Exception for Rat Exon Array
		if(regexpr("RaEx-1_0-st-v1",Procedure)>0) {
			library(RaExExonProbesetLocation)
			controls <- RaExExonProbesetLocation[RaExExonProbesetLocation$ANNLEVEL=="---","EPROBESETID"]
			filter.index <- match(controls,Gnames)
			filter.index <- filter.index[!is.na(filter.index)]
			}
		}	
		## Exception for Human Exon Array - Will implement soon
		#if(Procedure=="ExonArray=MoEx-1_0-st-v1;") {
			#library(MoExExonProbesetLocation)
			#controls <- MoExExonProbesetLocation[MoExExonProbesetLocation$ANNLEVEL=="---","EPROBESETID"]
			#filter.index <- match(controls,Gnames)
			#filter.index <- filter.index[!is.na(filter.index)]
			#}
			

		cat('number of control probe sets ', length(filter.index),'\n\n')
		
	}

  ################# Absolute Call filter ######################

	else if(filter.method == 'absolute.call.filter'){
	
		cat('Running absolute call filter function ....\n\n')

		filter.index = rep(0,dim(Absdata)[1])
		pass.flag = rep(0,length(tmp.groups))

		if (length(tmp.groups)==2){	
			for(i in 1:dim(Absdata)[1]){
				for(j in 1:length(filter.parameter1)){
					if(filter.parameter1[j]<0 && sum(Absdata[i,tmp.groups[[j]]]==-1)>=abs(filter.parameter1[j])) pass.flag[j] = 1
					else if(filter.parameter1[j]>0 && sum(Absdata[i,tmp.groups[[j]]]==1)>=abs(filter.parameter1[j])) pass.flag[j] = 1
				}

				if(sum(pass.flag) == length(pass.flag)){
					filter.index[i] = 1
				}

				pass.flag = rep(0,length(filter.parameter1))
			}
		}
		if (length(tmp.groups)>2){
			for(i in 1:dim(Absdata)[1]){
				for(j in 1:length(tmp.groups)){
					if (filter.parameter1<0){
						if((sum(Absdata[i,tmp.groups[[j]]]==-1)/length(tmp.groups[[j]])) >= abs(filter.parameter1)){
							pass.flag[j] = 1
						}
					}
					if (filter.parameter1>0){
						if(sum(Absdata[i,tmp.groups[[j]]]==1)/length(tmp.groups[[j]]) >= filter.parameter1){
							pass.flag[j] = 1
						}
					}
					if(sum(pass.flag) == length(pass.flag)){
						filter.index[i] = 1
					}
				}
					pass.flag = rep(0,length(tmp.groups))
			}
		}
		
		if(filter.parameter2 == 2){
			filter.index = !filter.index
		}


		filter.index = as.logical(filter.index)

		cat('sum of filter index is ', sum(filter.index),'\n\n')

	}


  ################# Negative Probe (Poly A) filter ######################

	else if(filter.method == 'negative.probe.filter'){


		cat('Running negative probe filter function ....\n\n')
		
		Limits<-rep(0,length(Snames))
		individual.index = matrix(data=0, nc=ncol(Avgdata), nr=nrow(Avgdata))
		filter.index = rep(0,nrow(Avgdata))
		pass.flag = rep(0,length(tmp.groups))

		if (length(grep('AFFX-r2-Bs-lys',orig.Gnames))>0){
			neg.controls1<-rowMeans(t(orig.Avgdata[grep('AFFX-r2-Bs-lys',orig.Gnames),]))
			neg.controls2<-rowMeans(t(orig.Avgdata[grep('AFFX-r2-Bs-phe',orig.Gnames),]))
			neg.controls3<-rowMeans(t(orig.Avgdata[grep('AFFX-r2-Bs-thr',orig.Gnames),]))
			neg.controls4<-rowMeans(t(orig.Avgdata[grep('AFFX-r2-Bs-dap',orig.Gnames),]))

			neg.controls<-cbind(neg.controls1, neg.controls2, neg.controls3, neg.controls4)

			for(k in 1:length(Snames)){
				if (which.max(neg.controls[k,])==1){
					Limits[k] = rowMeans(t(orig.Avgdata[grep('AFFX-r2-Bs-lys',orig.Gnames),]))[k]+(2*rowSds(t(orig.Avgdata[grep('AFFX-r2-Bs-lys',orig.Gnames),]))[k])
				}
				else if (which.max(neg.controls[k,])==2){
					Limits[k] = rowMeans(t(orig.Avgdata[grep('AFFX-r2-Bs-phe',orig.Gnames),]))[k]+(2*rowSds(t(orig.Avgdata[grep('AFFX-r2-Bs-phe',orig.Gnames),]))[k])
				}
				else if (which.max(neg.controls[k,])==3){
					Limits[k] = rowMeans(t(orig.Avgdata[grep('AFFX-r2-Bs-thr',orig.Gnames),]))[k]+(2*rowSds(t(orig.Avgdata[grep('AFFX-r2-Bs-thr',orig.Gnames),]))[k])
				}
				else if (which.max(neg.controls[k,])==4){
					Limits[k] = rowMeans(t(orig.Avgdata[grep('AFFX-r2-Bs-dap',orig.Gnames),]))[k]+(2*rowSds(t(orig.Avgdata[grep('AFFX-r2-Bs-dap',orig.Gnames),]))[k])
				}
				individual.index[,k] = Avgdata[,k]>Limits[k]
			}
		
		}

		else if (length(grep('AFFX-LysX',orig.Gnames))>0){
			neg.controls1<-rowMeans(t(orig.Avgdata[grep('AFFX-LysX',orig.Gnames),]))
			neg.controls2<-rowMeans(t(orig.Avgdata[grep('AFFX-PheX',orig.Gnames),]))
			neg.controls3<-rowMeans(t(orig.Avgdata[grep('AFFX-ThrX',orig.Gnames),]))
			neg.controls4<-rowMeans(t(orig.Avgdata[grep('AFFX-DapX',orig.Gnames),]))
			
			neg.controls<-cbind(neg.controls1, neg.controls2, neg.controls3, neg.controls4)

			for(k in 1:length(Snames)){
				if (which.max(neg.controls[k,])==1){
					Limits[k] = rowMeans(t(orig.Avgdata[grep('AFFX-LysX',orig.Gnames),]))[k]+(2*rowSds(t(orig.Avgdata[grep('AFFX-LysX',orig.Gnames),]))[k])
				}
				else if (which.max(neg.controls[k,])==2){
					Limits[k] = rowMeans(t(orig.Avgdata[grep('AFFX-PheX',orig.Gnames),]))[k]+(2*rowSds(t(orig.Avgdata[grep('AFFX-PheX',orig.Gnames),]))[k])
				}
				else if (which.max(neg.controls[k,])==3){
					Limits[k] = rowMeans(t(orig.Avgdata[grep('AFFX-ThrX',orig.Gnames),]))[k]+(2*rowSds(t(orig.Avgdata[grep('AFFX-ThrX',orig.Gnames),]))[k])
				}
				else if (which.max(neg.controls[k,])==4){
					Limits[k] = rowMeans(t(orig.Avgdata[grep('AFFX-DapX',orig.Gnames),]))[k]+(2*rowSds(t(orig.Avgdata[grep('AFFX-DapX',orig.Gnames),]))[k])
				}
				individual.index[,k] = Avgdata[,k]>Limits[k]
			}
		}

		else {
			cat("Chip type not recognized .... \n\n")
		}



 		if (length(tmp.groups)==2){	
			for(i in 1:dim(individual.index)[1]){
				for(j in 1:length(filter.parameter1)){

					if (filter.parameter1[j]>0){
						if(sum(individual.index[i,tmp.groups[[j]]]) >= filter.parameter1[j]) pass.flag[j] = 1
					}

					if (filter.parameter1[j]<0){
						if((length(tmp.groups[[j]])-sum(individual.index[i,tmp.groups[[j]]])) >= abs(filter.parameter1[j])) pass.flag[j] = 1
					}


				}

				if(sum(pass.flag) == length(pass.flag)){
					filter.index[i] = 1
				}

				pass.flag = rep(0,length(filter.parameter1))
			}
		}

		if (length(tmp.groups)>2){
			for(i in 1:dim(individual.index)[1]){
				for(j in 1:length(tmp.groups)){

					if(filter.parameter1>0){
						if(sum(individual.index[i,tmp.groups[[j]]])/length(tmp.groups[[j]]) >= filter.parameter1){
							pass.flag[j] = 1
						}
					}

					if(filter.parameter1<0){
						if( (1-sum(individual.index[i,tmp.groups[[j]]])/length(tmp.groups[[j]])) >= abs(filter.parameter1)){
							pass.flag[j] = 1
						}
					}


				}
				if(sum(pass.flag) == length(pass.flag)){
					filter.index[i] = 1
				}
				pass.flag = rep(0,length(tmp.groups))
			}
		}
		
		if(filter.parameter2 == 2){
			filter.index = !filter.index
		}


		filter.index = as.logical(filter.index)

		cat('sum of filter index is ', sum(filter.index),'\n\n')

	}



  ################# From Gene List ######################

	else if(filter.method == 'gene.list'){
		
		gene.list <- read.table(file=filter.parameter1,header=FALSE,as.is=TRUE)
		filter.index <- !is.na(match(Gnames,as.vector(as.matrix(gene.list))))
		if(filter.parameter2 == 2) filter.index = !filter.index

	}


  ################# Based on Variation in Expression ######################

	else if(filter.method == 'variation'){
		
		ExprsVar <- apply(Avgdata,1,var)
		gene.list <- stat.gnames(ExprsVar,gnames=labels(ExprsVar),crit=filter.parameter1)$gnames
		filter.index <- !is.na(match(Gnames,gene.list))

	}


  ################# Based on Difference Between Max and Min ######################

	else if(filter.method == 'fold.change'){
		
		Difference <- rowMax(Avgdata) - rowMin(Avgdata)
		gene.list <- stat.gnames(Difference,gnames=Gnames,crit=filter.parameter1)$gnames
		filter.index <- !is.na(match(Gnames,gene.list))

	}

  ################# Heritability filter ######################
  	
  	else if (filter.method == 'heritability'){

  		load(filter.parameter1)
  		keep.genes <- names(r.square)[(r.square > filter.parameter2)]
  		filter.index <- !is.na(match(Gnames,keep.genes))
  		
	}

	#################################
	#################################
	## REMOVING GENES		#
	##				#
	#################################

	cat('Running Remove.genes function ....\n')

	if(sum(filter.index) != 0){
		if(is.logical(filter.index)){
				
				Avgdata = Avgdata[filter.index,]
				Gnames = Gnames[filter.index]
				Absdata = Absdata[filter.index,]
		}
		else{

				Avgdata = Avgdata[-filter.index,]
				Gnames = Gnames[-filter.index]
				Absdata = Absdata[-filter.index,]
		}
	}
	else{
		cat('No modifications on Avgdata, Gnames, and Absdata were made, try other selections \n')
	}


	cat('Avgdata is ',dim(Avgdata),'\n')
	cat('Gene numbers is ', length(Gnames),' \n')
	cat('Sample numbers is ', length(Snames), "\n")
	

	########################################
	# Constructing instruction string for
	# "Procedure" variable
	#
	########################################
	
	temp = c()

	if(length(filter.parameter1) > 1){
		for(i in 1:length(filter.parameter1)){
			temp = paste(temp, filter.parameter1[i], sep = ' ')
		}
		filter.parameter1 = temp
	}


	#writelog(flag=logflag,'parameter1 is ', filter.parameter1)

	temp = c()

	if(length(filter.parameter2) > 1){
		for(i in 1:length(filter.parameter2)){
			temp = paste(temp, filter.parameter2[i], sep = ' ')
		}
		filter.parameter2 = temp
	}

	#writelog(flag=logflag,'parameter2 is ', filter.parameter2)
			

	Procedure <- paste(Procedure, 'Function=filter.genes.R;','filter.method=',filter.method,';','filter.parameter1=',filter.parameter1,';','filter.parameter2=',filter.parameter2,'|',sep = '')

	###############################################
	# saving variables for the next round
	#
	###############################################


	cat(file = GeneNumberFile, length(Gnames))        # write GeneNumberFile

	save(Absdata, Avgdata, Gnames, grouping, groups, Snames, Procedure, file = OutputFile)



}  ## END OF: Function block
