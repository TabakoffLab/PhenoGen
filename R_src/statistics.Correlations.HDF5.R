########################## statistics.Correlations.R ################
#
# This function computes correlations on the filtered genes in the input data and the user input for phenotype
#
# Parms:
#    InputFile  = name of HDF5 input file containing Absdata, Avgdata, Gnames, grouping, groups, Snames, Procedure
#                     (OutputFile from Normalization with Filter Data added after filtering)
#	 VersionPath = Version/Date/Time of dataset to use since .h5 files will have multiple versions per file and multiple filter/statistics results per version.
#	 SampleFile= File with Sample Names so that they can be read in--Unfortunately h5r has problems reading strings in.
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
#    .h5 file (OutputFile) containing Absdata, Avgdata, 
#                     Gnames, grouping, groups, Snames, p, Procedure
#    text file (GeneNumberFile) containing gene count
#
# Sample Call:
#    statistics.Correlations.HDF5(InputFile = 'Affy.NormVer.h5', Version='v1', PhenoFile="", CorrType = "pearson", GeneNumberFile = 'HapLap.GeneNumberCount.txt')
#
#
#  Function History
#	7/5/06	Laura Saba	Created
#	12/4/06	Laura Saba	Modified:  consolidated Affymetrix and CodeLink programs
#	3/12/07	Laura Saba	Modified:  report all strain means in stat file
#	8/24/07	Laura Saba	Modified:  updated to fit with new correlation format
#	12/22/08	Laura Saba	Modified: added code to handle groups when no samples are assigned to a group
#   3/1/12 Spencer Mahaffey Modified: Changed to Read/Write to HDF5 file.
# 3/13/15   Spencer Mahaffey Modified: Changed HDF5 methods to rHDF5 methods from h5r due to dropped support of h5r
#
#
####################################################


statistics.Correlations.HDF5 <- function(InputFile,VersionPath, SampleFile, PhenoFile, CorrType, GeneNumberFile) {

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
	
  #load(InputFile)
	vPath<-strsplit(x=VersionPath,split='/',fixed=TRUE)
	Version<-vPath[[1]][1]
	Day<-vPath[[1]][2]
	exactTime<-vPath[[1]][3]
	#load(InputFile)
	
  require(rhdf5)
  h5 <- H5Fopen (InputFile,flags = h5default("H5F_ACC"))
  gVersion<-H5Gopen(h5, Version)
  gFVer<-H5Gopen(h5, VersionPath)
  did <- H5Dopen(gFVer,  "fData")
  sid <- H5Dget_space(did)
  ds <- H5Dread(did)
  H5Dclose(did)
  H5Sclose(sid)
  # transpose matrix as rhdf5 reads in datasets in the opposite orientation from h5r.  This prevents needing 
  # to change the rest of the code to use columns as probesets and rows as samples.  But this should be fixed
  # in the future as it wastes CPU time and Memory
  ds=t(ds)
  Avgdata<-array(dim=c(dim(ds)[1],dim(ds)[2]))
  Avgdata[,]<-ds[1:dim(ds)[1],1:dim(ds)[2]]
  
  did <- H5Dopen(gFVer,  "fProbeset")
  sid <- H5Dget_space(did)
  ps <- H5Dread(did)
  H5Dclose(did)
  H5Sclose(sid)
  Gnames<-ps[]
  
  ins <- scan(SampleFile, list(""))
  Snames<-ins[[1]]
  
  rownames(Avgdata)<-Gnames
  colnames(Avgdata)<-Snames
  
  did <- H5Dopen(gVersion,  "Grouping")
  sid <- H5Dget_space(did)
  gs <- H5Dread(did)
  H5Dclose(did)
  H5Sclose(sid)
  grouping<-gs[1:dim(gs)[1]]  
  groups <- list()
  for(i in 1:max(grouping)) groups[[i]]<-which(grouping==i)

  H5Gclose(gVersion)
  H5Gclose(gFVer)
  H5Fclose(h5)

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

#	stats<-matrix(data=0, nr=sum(!is.na(phenotype$phenotype))+2, nc=NumProbes)
	stats<-array(dim=c(sum(!is.na(phenotype$phenotype))+2,NumProbes))
#	p<-matrix(data=0, nr=NumProbes, nc=1)
	p<-array(dim=c(length(Gnames)))
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

	Procedure <- paste('Function=statistics.Correlations.R',';','Stat.method = Correlation',';','Corr.Type = ',CorrType,sep = '')
  #save(Absdata, Avgdata, Gnames, grouping, groups, Snames, stats, p, Procedure,  file = OutputFile, compress = T)
  
  if(H5Aexists (gFVer, "statMethod")){
    H5Adelete (gFVer, "statMethod")
  }
  gSM <- h5createAttribute (gFVer, "statMethod")
  H5Awrite(gSM,Procedure)
  H5Aclose(gSM)
	#createH5Attribute(gFVer, "statMethod", Procedure, overwrite = TRUE)
	
  RowNames<-""
	for( tmp in rownames(stats)){
		RowNames<-paste(RowNames,tmp,sep=",")
	}
  if(H5Aexists (gFVer, "statRowNames")){
    H5Adelete (gFVer, "statRowNames")
  }
  gSM <- h5createAttribute (gFVer, "statRowNames")
  H5Awrite(gSM,RowNames)
  H5Aclose(gSM)
  #createH5Attribute(gFVer, "statRowNames",RowNames, overwrite = TRUE)

  stats=t(stats)
  sid <- H5Screate_simple (dim(stats)[1],dim(stats)[2] )
  did <- H5Dcreate (gFVer,"Statistics", "H5T_IEEE_F64LE", sid)
  H5Dwrite(did,stats)
  H5Dclose(did)
  H5Sclose(sid)
	
  #createH5Dataset(gFVer,"Statistics",stats,dType="double",chunkSizes=c(dim(stats)[1],dim(stats)[2]),overwrite=T)
  sid <- H5Screate_simple (length(p))
  did <- H5Dcreate (gFVer,"Pval", "H5T_IEEE_F64LE", sid)
  H5Dwrite(did,p)
  H5Dclose(did)
  H5Sclose(sid) 

  H5Gclose(gVersion)
  H5Gclose(gFVer)
  H5Fclose(h5)
  #tmpp<-p[1:length(Gnames)]
	#createH5Dataset(gFVer,"Pval",p,dType="double",overwrite=T)
	
}  #### END 
