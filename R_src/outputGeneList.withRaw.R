########################## outputGeneList.WithRaw.R ################
#
# This function outputs to a file the raw data associated with the probe
#   sets in the current gene list
#
# Parms:
#    OutputRawData  = name of output file for raw data
#    InputFile      = name of input file containing Absdata, Avgdata, 
#                         Gnames, grouping, groups, Snames, p, Procedure, 
#                         GenebankID, kw.p, ttest.p, adjp
#                         (OutputFile from Affy.multipleTest)
#
# Returns:
#    nothing
#
# Writes out:
#    text file   (OutputRawData) containing expression data for data in gene list
#
# Sample Call:
#    outputGeneList.withRaw(InputFile = 'AffyMAS5.multipleTest.output.Rdata',OutputGeneList = 'HapLap.genetext.output.withRaw.txt', Run.At.Home = F)
#
#  Function History
#	6/9/06	Laura Saba	Created
#	12/4/06	Laura Saba	Modified: consolidated separate CodeLink and Affymetrix programs
#
####################################################


 outputGeneList.withRaw <- function(InputFile, OutputGeneList, Run.At.Home = F){


  ###################################################
  ###################################################
  ###				          ###################
  ### 	START OF PROGRAM	    ###################
  ###				          ###################
  ###################################################
  ###################################################


  #################################################
  ## process data
  #################################################

	load(InputFile)

	if(length(Gnames)>1){

            header.row<-c("ProbeID",as.character(Snames))
		for.text<-rbind(header.row,cbind(Gnames,format(Avgdata,nsmall=3,digits=4)))
		write.table(for.text, file = OutputGeneList, append = FALSE, sep = '\t',row.names = FALSE,quote=FALSE,col.names=FALSE)	

		
	}

	else if(length(Gnames)==1){

            header.row<-c("ProbeID",as.character(Snames))
		for.text<-rbind(header.row,cbind(Gnames,t(format(Avgdata,nsmall=3,digits=4))))
		write.table(for.text, file = OutputGeneList, append = FALSE, sep = '\t',row.names = FALSE,quote=FALSE,col.names=FALSE)	
		
	}

	################################
	# else: length of Gnames == 0

	else{
		
		stats = 'No statistically significant gene was selected'
			
		
		cat(stats, file = OutputGeneList, append = FALSE, sep = '\n')	
		
	}


	
} ## END       
	
