########################## Affymetrix.Import.R ################
#
# This function reads Affymetrix CEL files into an AffyBatch object named All.ReadCell.
# and saves this object to an Rdata file.
#
# Parms:
#    import.path = location of CEL files needed
#    export.path = location were the RawDataFile should be stored (FileListing is also located here)
#    FileListing = txt file with a list of CEL files to be imported
#    RawDataFile = output file name for data set
#
# Returns:
#    nothing
#
# Writes Out:
#    .rdata file for all CEL files, containing all.ReadCell (AffyBatch object)
#
# Sample Call:
#	Affymetrix.Import(import.path="C:\\My CEL Files", export.path="C:\\Export Data", FileListing = 'C57andFVB.Cross.CEL.files.txt', RawDataFile = 'Affymetrix.Import.output.Rdata')
#
#
#  Function History
#     	?????????   	Tzu Phang   	Created      
#     	3/21/2005   	Diane Birks  	Modified: changed to use AffyBatch attributes to
#                                        	get cdf and annotation info, added 
#                                        	ChipInfo output to rdata file,
#                                        	species abbr output to text file
#                                        	(text file used to be written by Normalization pgm),
#                                        	and added logging via writelog
#	11/15/2007	Laura Saba	Modified: changed name of function and program;replaced filenames with sample names on
#						main matrices
#	11/20/2007	Laura Saba	Modified: eliminated ChipInfo output
#
####################################################


Affymetrix.Import <- function(import.path, export.path, FileListing, RawDataFile) {

	################# Housekeeping ############################
	# set up libraries and R functions needed
	library(affy)

 	################## Read and Write Files #####################

	FileListing = paste(export.path, '/', FileListing, sep = '')

	filenames<-read.AnnotatedDataFrame(FileListing,header=FALSE,as.is=TRUE,row.names=NULL)
	numfiles<-length(filenames$V1)
	All.ReadCell<-ReadAffy(filenames=filenames$V1,sampleNames=filenames$V2,celfile.path=import.path)

 	################## Save Raw Data and Chip Info #####################

	save(All.ReadCell, file = paste(export.path, '/', RawDataFile,'.','Rdata',sep = ''), compress = T)

}
	


