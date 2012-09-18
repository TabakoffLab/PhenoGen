########################## Affymetrix.Normalization.R ################
#
# This function combines PMs and MMs from each
# gene into one value by using various background
# correction and normalization methods
#
# Parms:
#    OutputFile 		= output file name for normalized data for all files in FileListing
#    OutputCSVFile 	= comma-delimited output file name for absolute call (MAS5 only) and normalized values 
#    normalize.method	= 'mas5' | 'dchip' | 'rma' | 'pdnn' | 'vsn' | 'gcrma' | 'plier' 
#    energy.file.path 	= path to pdnn energy files
#    InputDataFile	= input raw expression data as.RData file; i.e. the output of Affy.ImportCELExportBioC 
#    grouping		= vector with a group number for each subject starting with 1 where 0 indicates that the sample should be dropped
#    mask			= T/F should probe mask be implemented (only applicable for Affymetrix Mouse 430 Version 2 arrays
#    mask.file 		= location and name of txt file with probe indices that should be deleted
#
# Returns:
#    nothing
#
# Writes Out:
#    .Rdata file (OutputCombinedBioCFile) containing 
#                   All.estReadCell object
#    tab-delimited text file (OutputTabDelimitedFile) containing 
#                 All.estReadCell and All.AbsCall in table form
#    excel (.xls) file (OutputExcelFile), same as text file but in .xls
#    
#
# Sample Call:
#    Affymetrix.Normalization(OutputCombinedBioCFile = 'HapLap.Normalization.output.Rdata',OutputTabDelimitedFile = 'HapLap.Normalization.output.tab', OutputExcelFile = 'HapLap.Normalization.output.xls', normalize.method = 'mas5', energy.file.path = '/home/tzu/INIA_PROJECTS/INIA_R_CODES/Affymetrix/pdnnEnergy/', gcrma.option = T, FilesFileListing = 'HapLap.CEL.Rdata.files.txt', mask = T)
#
#
#  Function History
#     	?????????   	Tzu Phang	Created      
#     	3/21/2005   	Diane Birks	Modified: removed SpeciesFile output 
#                              			(done by previous step - Affy.ImportCELExportBioC now),
#                               		and logging via writelog
#     	3/24/2006   	Laura Saba 	Modified: added log base 2 transformations to MAS5 and dChip;
#                                       	inactivated code for pdnn and plier since not yet available on website
#     	7/11/2006   	Laura Saba  Modified: implemented pdnn and plier
#     	8/22/2007   	Laura Saba  Modified: eliminate the need to read in data file by file and removed ABScall.Rdata file
#	     11/15/2007		Laura Saba	Modified: prior to normalization, eliminated samples marked for exclusion when 
#							specifying run groups; combined with ExportOutBioC
#		8/11/2009		Laura Saba	Modified: added probe mask based on SNPs from the Imputed Genotype Resource from The Center for Genome Dynamics at 
#							The Jackson Laboratory (positions based on NCBI m36 mouse assembly) and alignment from NCBI m36 mouse assemble genome
#							obtained from the UCSC Genome Browser (version mm8)
#                                             removed option from gcRMA so that all normalization uses the more accurate Bayes estimation
#											  
####################################################


Affymetrix.Normalization<-function(OutputFile, OutputCSVFile, normalize.method, energy.file.path, InputDataFile, grouping, mask, mask.file){

  #######################################
  # Set up libraries and R functions needed
  #
	library(affy)
	library(vsn)
	library(marray)
	library(gcrma)
	library(mouse4302cdf)
	library(altcdfenvs)

	#library(plier)
	#library(affypdnn)
		
	fileLoader('tzu.CharToNum.R')

  #######################################
  # Import files
  #
	load(InputDataFile)
		
  ########################################
  # Create groupings and eliminate excluded samples
  #
	All.ReadCell <- All.ReadCell[,(grouping>0)]
	protocolData(All.ReadCell) <- phenoData(All.ReadCell)
	grouping <- grouping[grouping>0]

	groups<-list()
	for(i in 1:max(grouping)) groups[[i]]<-which(grouping==i)

  ########################################
  # Implement Probe Mask 
  #
	if(mask){
		to.be.deleted <- read.table(file=mask.file, sep="\t")
		index.to.be.deleted <- 1002*to.be.deleted$V3 + to.be.deleted$V2 + 1
		newcdf <- wrapCdfEnvAffy(mouse4302cdf,1002,1002,"mouse4302cdf")
		newcdf <- removeIndex(newcdf,as.integer(index.to.be.deleted))
		envnewcdf <- newcdf@envir
		All.ReadCell@cdfName <- "envnewcdf"
		assign("envnewcdf",envnewcdf,envir = .GlobalEnv)
	}
		
  #######################################
  # Normalization
  #

    ##############  MAS 5.0  ##############
	if(normalize.method == 'mas5'){

		cat('Running MAS5 normalization procedure ....\n\n')
		
		All.estReadCell = mas5(All.ReadCell)
		exprs(All.estReadCell) = log2(exprs(All.estReadCell))
	}

    ##############  RMA  ##############

	else if(normalize.method == 'rma'){

		cat('Running RMA normalization procedure ....\n\n')

		All.estReadCell = rma(All.ReadCell)
		
	}

    ##############  dChip  ##############

	else if(normalize.method == 'dchip'){

		cat('Running dChip normalization procedure ....\n\n')
		
		All.estReadCell = expresso(All.ReadCell, bgcorrect.method = 'none', normalize.method = 'invariantset', pmcorrect.method = 'pmonly', summary.method = 'liwong')
		exprs(All.estReadCell) = log2(exprs(All.estReadCell))
	}

    ##############  VSN  ##############

	else if(normalize.method == 'vsn'){
		
		cat('Running VSN normalization procedure ....\n\n')
		
		#All.estReadCell = expresso(All.ReadCell, bgcorrect.method = 'none', normalize.method = 'vsn', pmcorrect.method = 'pmonly', summary.method = 'medianpolish')
		All.estReadCell = vsnrma(All.ReadCell)
	}

    ##############  gcRMA  ##############

	else if(normalize.method == 'gcrma'){

		cat('Running gcRMA normalization procedure ....\n\n')
		
		All.estReadCell = gcrma(All.ReadCell, fast = F)

	}


##############  PDNN  ##############

#	else if(normalize.method == 'pdnn'){

#		cat('Running PDNN normalization procedure ....\n\n')
#
#		energy.parameter.file = c()		
#
#		if(chipCdf == 'MG_U74Av2'){
#			energy.parameter.file = paste(energy.file.path, 'PDNN-energy-parameter_MG_u74av2.txt', sep = '')
#			params.chiptype = pdnn.params.chiptype(energy.parameter.file, probes.pack = 'mgu74av2probe')
#		}		
#		else if(chipCdf == 'Mouse430_2'){
#			energy.parameter.file = paste(energy.file.path, 'PDNN-energy-parameter_Mouse430_2.txt', sep = '')
#			params.chiptype = pdnn.params.chiptype(energy.parameter.file, probes.pack = 'mouse4302probe')
#		}
#		else if(chipCdf == 'Mouse430A_2'){
#			energy.parameter.file = paste(energy.file.path, 'PDNN-energy-parameter_Mouse430A_2.txt', sep = '')
#			params.chiptype = pdnn.params.chiptype(energy.parameter.file, probes.pack = 'mouse430A2probe')
#		}
#		else if(chipCdf == 'HG-U133_Plus_2'){
#			energy.parameter.file = paste(energy.file.path, 'PDNN-energy-parameter_hg_u133_plus_2.txt', sep = '')
#			params.chiptype = pdnn.params.chiptype(energy.parameter.file, probes.pack = 'hgu133plus2probe')
#		}
#		else {
#			cat("PDNN not available for this chip type...\n")
#		}
#		All.estReadCell = expressopdnn(All.ReadCell, eset.normalize = 'quantiles', findparams.param  =list(params.chiptype = params.chiptype))
#		
#	}

    ##############  PLIER  ##############

	else if(normalize.method == 'plier'){
		cat('Running PLIER normalization procedure ....\n\n')
		
		All.estReadCell = justPlier(All.ReadCell,normalize=TRUE)
	}


	else{

		cat('Unknown normalization procedure ....\n\n')
			
	}
		

	x = exprs(get('All.estReadCell',inherit = T))
	
	cat('After normalization, dimension is ', dim(x)[1],'\n\n')

	



    # END OF: Normalization
    #######################################


    #######################################
    # Calculate Absolute Calls
    #
	cat('Calculating absolute call values now ....\n\n')
	
	All.AbsCall = mas5calls(All.ReadCell)

    #######################################
    # Creating appropriate variables
    #
	Avgdata = exprs(All.estReadCell)
	Absdata = exprs(All.AbsCall)
	Absdata = t(apply(Absdata, 1, tzu.CharToNum))
	Absdata = t(apply(Absdata, 1, as.numeric))
	Gnames = rownames(Avgdata)
	Snames = colnames(Avgdata)

    #######################################
    # Output tab delimited file
    #

	if(normalize.method == 'mas5'){
		Detection = exprs(All.AbsCall)

		output.csv = c()
		output.rowname = rownames(Avgdata)
		output.colname = colnames(Avgdata)
		output.colname = rep(output.colname, each = 2)

		for(i in 1:dim(Avgdata)[2]){
			output.csv = cbind(output.csv, Avgdata[,i], Detection[,i])
		}

		ForOutput = cbind(output.rowname, output.csv)
		colnames(ForOutput)=c("ProbeSetID",output.colname)

		write.table(ForOutput, file = OutputCSVFile, quote = F, sep = ',', row.names = FALSE)

	}
	else{
		output.rowname = rownames(Avgdata)
		ForOutput = cbind(output.rowname, Avgdata)
		colnames(ForOutput )[1]="ProbeSetID"

		write.table(ForOutput , file = OutputCSVFile, quote = F, sep = ',',row.names=FALSE)

	}
    # END OF: Output Experiment file
    #######################################

    #######################################
    # Save Rdata sets and initiate procedure variable
    #
	Procedure = c()
	save(Absdata, Avgdata, Gnames, Snames, grouping, groups, Procedure, file = OutputFile, compress = T)

} ## END OF: function block
