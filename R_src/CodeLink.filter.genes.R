########################## CodeLink.filter.genes.R ################
#
# This function filters the genes in the InputDataFile
#
# Parms:
#    OutputFile     = output file name for updated input with filter added to Procedure  
#    OriginalFile     = output file name for updated input with filter added to Procedure  
#    GeneNumberFile = output file name for # of genes
#    InputDataFile  = name of input file containing Avgdata, Absdata, GS.call, Snames, and Gnames (if 2nd filter procedure, the OutputFile from previous filter)
#    OriginalFile = name of original input file before ANY filtering is done (OutputFile from CodeLink.ExportOutBioC)	
#
#    filter.method  = type of filter to apply (see details below)
#    filter.parameter1 = options for filter method (see details below)
#    filter.parameter2 = options for filter method (see details below)
#
#         Values for filter.method, filter.parameter1, and filter.parameter2:
#         filter.method Choices:
#             -- codelink.control.genes [Discovery: D]
#             -- absolute.call.filter [Absdata: L,G]
#             ----- filter.parameter1 = c(7,8)
#	      ---------- all 7 or more "G" in groupA, all 8 or more "G" in groupB
#             ----- filter.parameter2 = 1 (keep)
#             ----- filter.parameter2 = 2 (remove)
#             -- gs.call.filter [GS.call: A, P]
#             ----- filter.parameter1 = c(7,8)
#	      ---------- all 7 or more "P" in groupA, all 8 or more "P" in groupB
#             ----- filter.parameter2 = 1 (keep)
#             ----- filter.parameter2 = 2 (remove)
#             -- median.filter
#             ----- filter.parameter1 = filter threshold [1:90]
#             ----- filter.parameter2 = fdr threshold [0.0..1:0.9]
#             -- coefficient.variation
#             ----- filter.parameter1 = rep(0.03, 9)
#             ----- filter.parameter2 = 1 (or)
#             ----- filter.parameter2 = 2 (and)
#             -- negative.control
#             ----- filter.parameter1 = c(7,8)
#	      ---------- 7 or more "above detection limits" in groupA, 8 or more "above detection limits" in groupB
#             ----- filter.parameter2 = 1 (keep)
#             ----- filter.parameter2 = 2 (remove)
#             ----- filter.parameter3 = % to trim off either end of ordered distribution [0 to 0.5]
#	      -- gene.list
#	      ----- filter.parameter1 = filename of probe set list
#             ----- filter.parameter2 = 1 (keep)
#             ----- filter.parameter2 = 2 (remove)
#             ----- filter.parameter3 = -99 (none needed)
#             -- variation
#             ----- filter.parameter1 = proportion or number of "top" probe sets to keep
#             ----- filter.parameter2 = -99 (none needed)
#             ----- filter.parameter3 = -99 (none needed)
#             -- fold.change
#             ----- filter.parameter1 = proportion or number of "top" probe sets to keep
#             ----- filter.parameter2 = -99 (none needed)
#             ----- filter.parameter3 = -99 (none needed)
#             -- heritability
#             ----- filter.parameter1 = location and file name of heritability data
#             ----- filter.parameter2 = heritability criteria (probes with heritability above this threshold will be retained, e.g. 0.50, 0.60 - must be between 0 and 1)
#             ----- filter.parameter3 = -99 (none needed)
#
# Returns:
#    nothing
#
# Writes out:
#    .Rdata file (OutputFile) containing Absdata, Avgdata, GS.call
#           Gnames, grouping, groups, Snames, Procedure updated with gene filter
#    text file (GeneNumberFile) containing gene count 
#
# Sample Call:
#    CodeLink.filter.genes.Clustering(InputDataFile = 'CodeLink.ExportOutBioC.output.Rdata', OriginalFile = 'CodeLink.ExportOutBioC.output.Rdata', filter.method = 'codelink.control.genes', filter.parameter1 = -99, filter.parameter2 = -99, OutputFile='CodeLink.filter.genes.output.Rdata', GeneNumberFile = 'CodeLink.GeneNumberCount.txt')
#
#
#  Function History
#     7/14/2005	Tzu Phang	Created      
#     4/13/2006	Laura Saba	Updated (added negative control filter and adjusted filter for discovery genes)
#     6/30/2005	Laura Saba	Modified: added capabilities for more than two groups
#     12/8/2006	Laura Saba	Modified: corrected error in absolute call filter and genespring call filter
#     1/5/2007	Laura Saba	Modified: changed negative control filter to have options like absolute call filter
#     4/19/2007	Laura Saba	Modified: need to update groups due to correlation analysis
#     8/24/2007	Laura Saba	Modified: included filtering needed for clustering
#	  8/14/2009	Laura Saba	Modified: added heritability filter
#	  9/2/2010	Laura Saba	Modified: updated code for Median Filter because multi-argument returns are no longer permitted in R
#
####################################################


CodeLink.filter.genes<-function(InputDataFile, OriginalFile, filter.method = 'codelink.control.genes', filter.parameter1, filter.parameter2, filter.parameter3, OutputFile, GeneNumberFile){

	################# Housekeeping ############################
      # set up logging

	fileLoader(c('medianfilter.R','fdr.R','tzu.CV.R','upper.conf.limit.R'))
	library(marray)
	library(genefilter)
	library(Biobase)
	
      #######################################
      ## load data and apply filters
      ##

	load(OriginalFile)
	orig.chip.info<-chip.info
	orig.Avgdata<-Avgdata

	load(InputDataFile)

	cat('Discovery has ', dim(Discovery)[1], ' row and ', dim(Discovery)[2], ' columns\n')
	cat('Avgdata has ', dim(Avgdata)[1], ' row and ', dim(Avgdata)[2], ' columns\n')
	cat('Absdata has ', dim(Absdata)[1], 'rows and ', dim(Absdata)[2], ' columns\n')
	cat('GS call has ', dim(GS.call)[1], 'rows and ', dim(GS.call)[2], ' columns\n')
	

	## END OF:Transfer variables
	########################################

	
	###################################################
	###################################################
	### 	START OF PROGRAM	###################
	###				###################
	###################################################
	###################################################

		cat('\n\n\n')
	
		cat('Avgdata is ',dim(Avgdata),'\n')
		cat('Gene numbers is ', length(Gnames), '\n')
		cat('Sample numbers is ', length(Snames), '\n')

      #######################################
      ## create temporary 'groups' variable to account for correlation data
      ##

	tmp.groups <- groups
	orig.NumGroups <-length(tmp.groups)
	for (i in 1:orig.NumGroups){
		j = orig.NumGroups - i + 1
		if (length(tmp.groups[[j]])==0) tmp.groups[[j]]<-NULL
	}
	
		

################## control gene filter ###############

	if(filter.method == 'codelink.control.genes'){

		cat('Running control gene filter function ....\n')
		filter.index = rep(0,dim(Discovery)[1])
		filter.parameter1 = c()
		filter.parameter2 = 1  ## always keep "D" genes

		for(i in 1:dim(Discovery)[1]){
			filter.index[i] = Discovery[i,1]
		}

		filter.index = as.logical(filter.index)

		cat('sum of filter index is ', sum(filter.index), '\n')
		
################## Absolute Call filter ###############

	}else if(filter.method == 'absolute.call.filter'){

		cat('Running absolute call filter function ....\n')
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
						if((sum(Absdata[i,tmp.groups[[j]]])/length(tmp.groups[[j]])) <= filter.parameter1){
							pass.flag[j] = 1
						}
					}
					if (filter.parameter1>0){
						if((sum(Absdata[i,tmp.groups[[j]]])/length(tmp.groups[[j]])) >= filter.parameter1){
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

		cat('sum of filter index is ', sum(filter.index),'\n')

################## GeneSpring call filter ###############

	}else if(filter.method == 'gs.call.filter'){

		cat('Running GeneSpring call filter function ....\n')
		filter.index = rep(0,dim(Absdata)[1])
		pass.flag = rep(0,length(tmp.groups))	

		if (length(tmp.groups)==2){	
			for(i in 1:dim(GS.call)[1]){
				for(j in 1:length(filter.parameter1)){
					if(filter.parameter1[j]<0 && sum(GS.call[i,tmp.groups[[j]]]==-1)>=abs(filter.parameter1[j])) pass.flag[j] = 1
					else if(filter.parameter1[j]>0 && sum(GS.call[i,tmp.groups[[j]]]==1)>=abs(filter.parameter1[j])) pass.flag[j] = 1
				}

				if(sum(pass.flag) == length(pass.flag)){
					filter.index[i] = 1
				}

				pass.flag = rep(0,length(filter.parameter1))
			}
		}
		if (length(tmp.groups)>2){
			for(i in 1:dim(GS.call)[1]){
				for(j in 1:length(tmp.groups)){
					if (filter.parameter1<0){
						if((sum(GS.call[i,tmp.groups[[j]]])/length(tmp.groups[[j]])) <= filter.parameter1){
							pass.flag[j] = 1
						}
					}
					if (filter.parameter1>0){
						if(sum(GS.call[i,tmp.groups[[j]]])/length(tmp.groups[[j]]) >= filter.parameter1){
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

		cat('sum of filter index is ', sum(filter.index) ,'\n')


################## median filter ###############

	}else if(filter.method == 'median.filter'){

		cat('Running median filter function ....\n')

		p = medianfilter(t(Avgdata), filter.parameter1)           

		H = fdr(1-p,filter.parameter2,'stepup')
		filter.index = H

################## CV filter ###############

	}else if(filter.method == 'coefficient.variation'){

		cat('Running CV filter function ....\n')

		filter.index = rep(0,dim(Avgdata)[1])
		pass.flag = rep(0,length(tmp.groups))	
		Avgdata.CV = c()

		for(i in 1:length(tmp.groups)){
			temp = apply(Avgdata[,tmp.groups[[i]]],1,tzu.CV)
			Avgdata.CV = cbind(Avgdata.CV,temp)
		}

		Avgdata.CV[is.nan(Avgdata.CV)]<-0
	
		if (length(tmp.groups)==2){
			for(i in 1:dim(Avgdata.CV)[1]){
				for(j in 1:length(filter.parameter1)){
					if(Avgdata.CV[i,j] <= filter.parameter1[j]){
						pass.flag[j] = 1
					}
				}

				if(filter.parameter2 == 1){ ## OR
					if(sum(pass.flag) >= 1){
						filter.index[i] = 1
					}
				}
				else if(filter.parameter2 == 2){ ## AND
					if(sum(pass.flag) == length(pass.flag)){
						filter.index[i] = 1
					}
				}

				pass.flag = rep(0,length(filter.parameter1))
			}
		}
		else if (length(tmp.groups)>2){
			for(i in 1:dim(Avgdata.CV)[1]){
				for(j in 1:length(tmp.groups)){
					if(Avgdata.CV[i,j]<=filter.parameter1){
						pass.flag[j] = 1
					}
				}

				if(filter.parameter2 == 1){ 
					if(sum(pass.flag) >= 1){
						filter.index[i] = 1
					}
				}
				else if(filter.parameter2 == 2){ 
					if(sum(pass.flag) == length(pass.flag)){
						filter.index[i] = 1
					}
				}

				pass.flag = rep(0,length(tmp.groups))
			}
		}


		filter.index = as.logical(filter.index)

		cat('sum of filter index is ', sum(filter.index),'\n')
		
############### Negative Control Gene Filter ##################

	}else if(filter.method == 'negative.control'){

		cat('Running negative control filter function ....\n')

		Neg.Probes = orig.Avgdata[(orig.chip.info$type.flag[,1] == 'N'),]
		lower<-ceiling(dim(Neg.Probes)[1]*filter.parameter3)
		upper<-floor(dim(Neg.Probes)[1]*(1-filter.parameter3))
 		data.sorted<-apply(Neg.Probes,2,sort)
		data.trimmed<-data.sorted[lower:upper,]

		Upper.Limit = apply(data.trimmed,2,upper.conf.limit)

		filter.index = rep(0,dim(Discovery)[1])
	
		for (i in 1:dim(Avgdata)[1]){
			if (length(tmp.groups)==2){
				pass.flag = rep(0,length(tmp.groups))
				if (filter.parameter1[1]>0) pass.flag[1]=(sum(Upper.Limit[tmp.groups[[1]]]<Avgdata[i,tmp.groups[[1]]])>=filter.parameter1[1]) 
				if (filter.parameter1[1]<0) pass.flag[1]=(sum(Upper.Limit[tmp.groups[[1]]]>Avgdata[i,tmp.groups[[1]]])>=abs(filter.parameter1[1])) 
				if (filter.parameter1[2]>0) pass.flag[2]=(sum(Upper.Limit[tmp.groups[[2]]]<Avgdata[i,tmp.groups[[2]]])>=filter.parameter1[2]) 
				if (filter.parameter1[2]<0) pass.flag[2]=(sum(Upper.Limit[tmp.groups[[2]]]>Avgdata[i,tmp.groups[[2]]])>=abs(filter.parameter1[2])) 

				filter.index[i] = (sum(pass.flag)==2)
			}

			if (length(tmp.groups)>2){
				pass.flag = rep(0,length(tmp.groups))
				if (filter.parameter1>0) {
					for (j in 1:length(tmp.groups)){
						pass.flag[j]=(sum(Upper.Limit[tmp.groups[[j]]]<Avgdata[i,tmp.groups[[j]]])/length(tmp.groups[[j]])>=filter.parameter1) 
					}
				}
				if (filter.parameter1<0) {
					for (j in 1:length(tmp.groups)){
						pass.flag[j]=(sum(Upper.Limit[tmp.groups[[j]]]>Avgdata[i,tmp.groups[[j]]])/length(tmp.groups[[j]])>=abs(filter.parameter1)) 
					}
				}
				filter.index[i] = (sum(pass.flag)==length(tmp.groups))
			}
		}

		if(filter.parameter2 == 2) filter.index = !filter.index

		cat('sum of filter index is ', sum(filter.index),'\n')

		filter.index<-as.logical(filter.index)
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

	else if(filter.method == 'heritability'){
		
		load(filter.parameter1)
  		keep.genes <- names(r.square)[(r.square > filter.parameter2)]
  		filter.index <- !is.na(match(Gnames,keep.genes))

	}
	#################################
	#################################
	## REMOVING GENES		#
	##				#
	#################################

	#writelog(flag=logflag,'Running Remove.genes function ....')
	cat('Running Remove.genes function ....\n')


	if(sum(filter.index) != 0){
		if(is.logical(filter.index)){
			
				#writelog(flag=logflag,'logical filter index was called')
				cat('logical filter index was called\n')
				
				Discovery = Discovery[filter.index,]
				Avgdata = Avgdata[filter.index,]
				Gnames = Gnames[filter.index]
				Absdata = Absdata[filter.index,]
				GS.call = GS.call[filter.index,]
		}
		else{

				#writelog(flag=logflag,'nonlogical filter index was called')
				cat('nonlogical filter index was called\n')


				Discovery = Discovery[-filter.index,]
				Avgdata = Avgdata[-filter.index,]
				Gnames = Gnames[-filter.index]
				Absdata = Absdata[-filter.index,]
				GS.call = GS.call[-filter.index,]
		}
	}
	else{
		#writelog(flag=logflag,'No modifications on Avgdata, Gnames, and Absdata were made, try other selections')
		cat('No modifications on Avgdata, Gnames, and Absdata were made, try other selections\n')
	}


	#writelog(flag=logflag,'Avgdata is ',dim(Avgdata))
	#writelog(flag=logflag,'Gene numbers is ', length(Gnames))
	#writelog(flag=logflag,'Sample numbers is ', length(Snames))
	
	cat('Avgdata is ',dim(Avgdata),'\n')
	cat('Gene numbers is ', length(Gnames), '\n')
	cat('Sample numbers is ', length(Snames), '\n')
	

	########################################
	# Constructing instruction string for
	# "Procedure" variable
	#
	########################################
	

	#writelog(flag=logflag,'Ready to build instruction string for Procedure var')
	cat('Ready to build instruction string for Procedure var\n')

	temp = c()

	if(length(filter.parameter1) > 1){
		for(i in 1:length(filter.parameter1)){
			temp = paste(temp, filter.parameter1[i], sep = ' ')
		}
		filter.parameter1 = temp
	}


	#writelog(flag=logflag,'parameter1 is ', filter.parameter1)
	cat('parameter1 is ', filter.parameter1,'\n')

	temp = c()

	if(length(filter.parameter2) > 1){
		for(i in 1:length(filter.parameter2)){
			temp = paste(temp, filter.parameter2[i], sep = ' ')
		}
		filter.parameter2 = temp
	}

	#writelog(flag=logflag,'parameter2 is ', filter.parameter2)
	cat('parameter2 is ', filter.parameter2, '\n')
			
	temp = c()

	if(length(filter.parameter3) > 1){
		for(i in 1:length(filter.parameter3)){
			temp = paste(temp, filter.parameter3[i], sep = ' ')
		}
		filter.parameter3 = temp
	}

	#writelog(flag=logflag,'parameter3 is ', filter.parameter3)
	cat('parameter3 is ', filter.parameter3, '\n')

	Procedure <- paste(Procedure, 'Function=filter.genes.R;','filter.method=',filter.method,';','filter.parameter1=',filter.parameter1,';','filter.parameter2=',filter.parameter2,';','filter.parameter3=',filter.parameter3,'|',sep = '')

	###############################################
	# saving variables for the next round
	#
	###############################################


	cat(file = GeneNumberFile, length(Gnames))        # write GeneNumberFile

	save(Absdata, Avgdata, GS.call, Discovery, Gnames, grouping, groups, Snames, Procedure, file = OutputFile)

	#writelog(flag=logflag,'END')



}  ## END OF: CodeLink.filter.genes
