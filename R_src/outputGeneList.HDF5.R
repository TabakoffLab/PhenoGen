########################## outputGeneList.R ################
#
# This function runs the specified test on the data
#
# Parms:
#    
#    InputFile      = name of HDF5 input file containing Absdata, Avgdata, 
#                         Gnames, grouping, groups, Snames, p, Procedure, 
#                         GenebankID, kw.p, ttest.p, adjp
#                         (OutputFile from Affy.multipleTest)
#    VersionPath = Version/Date/Time of dataset to use since .h5 files will have multiple versions per file and multiple filter/statistics results per version.
#    OutputGeneList = name of output file for gene count
#	 SampleFile = name of file containing a list of samples(1/line)
#
# Returns:
#    nothing
#
# Writes out:
#    text file   (GeneNumberFile) containing gene count
#    .html file  (OutputHTML)     web page containing gene list
#    .png file   (OutputHeatMap)  graphics file containing heat map
#    .rdata file (OutputRawData)  containing Avgdata
#
# Sample Call:
#    outputGeneList(InputFile = 'Affy.NormVer.h5', Version='v1', SampleListFile='/', InputChipInfoFile = 'ChipInfo.Rdata',OutputGeneList = 'HapLap.genetext.output.txt', Run.At.Home = F)
#
#
#  Function History
#     ?????????   Tzu Phang    Created      
#     3/21/2005   Diane Birks  Modified: Chip.version was hardcoded to 'mgu74av2',
#                                changed to use attr(ChipInfo,'annotation') instead
#                                (from InputChipInfoFile), added MaxHeatMapGenes, added logging via writelog
#	5/1/06	Laura Saba	Modified: added group means and pvalues (both raw and adjusted to output)
#	12/4/06	Laura Saba	Modified: added condition that if two-way ANOVA was used, export column headers
#						    and eliminated separate programs for affymetrix and codelink
#	3/13/07	Laura Saba	Modified: added condition that if Eaves test or correlation was used, export column headers
#	9/25/07	Laura Saba	Modified: added input of group names and export column headers with all data, regardless of statisics used
#	11/20/07	Laura Saba	Modified: corrected coding for situations when there is only one gene in the gene list
#	3/1/12	Spencer Mahaffey Modified: Read/Write HDF5 files.
#	3/8/12		Spencer Mahaffey Modified: Support multiple filters/stats per version.
#	7/18/12		Spencer Mahaffey Modified: Now gets MultiTest param with gene count if <=0 skips rest of script to avoid errors.
# 3/13/15   Spencer Mahaffey Modified: Changed HDF5 methods to rHDF5 methods from h5r due to dropped support of h5r
#
####################################################


outputGeneList.HDF5 <- function(InputFile, VersionPath, SampleFile, GroupNames, OutputGeneList, Run.At.Home = F){


  ###################################################
  ###################################################
  ###				          ###################
  ### 	START OF PROGRAM	    ###################
  ###				          ###################
  ###################################################
  ###################################################


  #################################################
  ## process data
  ##	

	##  Load Rdata file with stats					
	##load(InputFile)
	vPath<-strsplit(x=VersionPath,split='/',fixed=TRUE)
	Version<-vPath[[1]][1]
	Day<-vPath[[1]][2]
	exactTime<-vPath[[1]][3]
  
  require(rhdf5)
  h5 <- H5Fopen (InputFile)
  gVersion<-H5Gopen(h5, Version)
  gFilter<-H5Gopen(gVersion,"Filters")
  gDay<-H5Gopen(gFilter,Day)
  gFVer<-H5Gopen(gDay, exactTime)
  gMulti<-H5Gopen(gFVer, "Multi")
  aCount<-H5Aopen(gMulti,"count")
  count<-H5Aread(aCount)
  H5Aclose(aCount)
  
	# if count=0 don't need to output anything.
	if(count[1]>0){
		ins <- scan(SampleFile, list(""))
		Snames<-ins[[1]]
		
		did <- H5Dopen(gMulti,  "mProbeset")
		#sid <- H5Dget_space(did)
		ps <- H5Dread(did)
		H5Dclose(did)
		#H5Sclose(sid)
		Gnames<-ps[]
		
		#did <- H5Dopen(gMulti,  "mData")
		#sid <- H5Dget_space(did)
		#ds <- H5Dread(did)
		#H5Dclose(did)
		#H5Sclose(sid)
		# transpose matrix as rhdf5 reads in datasets in the opposite orientation from h5r.  This prevents needing 
		# to change the rest of the code to use columns as probesets and rows as samples.  But this should be fixed
		# in the future as it wastes CPU time and Memory
		#ds=t(ds)
		#Avgdata<-array(dim=c(dim(ds)[1],dim(ds)[2]))
		#Avgdata[,]<-ds[1:dim(ds)[1],1:dim(ds)[2]]
		#rownames(Avgdata)<-Gnames
		#colnames(Avgdata)<-Snames
	
	
		did <- H5Dopen(gVersion,  "Grouping")
		#sid <- H5Dget_space(did)
		gs <- H5Dread(did)
		H5Dclose(did)
		#H5Sclose(sid)
		grouping<-gs[1:dim(gs)[1]]  
		groups <- list()
		for(i in 1:max(grouping)) groups[[i]]<-which(grouping==i)
		
		did <- H5Dopen(gMulti,  "mPval")
		#sid <- H5Dget_space(did)
		pvs <- H5Dread(did)
		H5Dclose(did)
		#H5Sclose(sid)
		p<-pvs[]
		
		did <- H5Dopen(gMulti,  "mStatistics")
		#sid <- H5Dget_space(did)
		ss <- H5Dread(did)
		H5Dclose(did)
		#H5Sclose(sid)
		# transpose matrix as rhdf5 reads in datasets in the opposite orientation from h5r.  This prevents needing 
		# to change the rest of the code to use columns as probesets and rows as samples.  But this should be fixed
		# in the future as it wastes CPU time and Memory\
		ss=t(ss)
		stats<-array(dim=c(dim(ss)[1],dim(ss)[2]))
		stats[,]<-ss[1:dim(ss)[1],1:dim(ss)[2]]
		
		statRowName<-H5Aopen(gFVer,"statRowNames")
		srn<-H5Aread(statRowName)
		H5Aclose(statRowName)
		namelist=strsplit(x=srn[1],split=',',fixed=TRUE)
		adjnamelist<-namelist[[1]]
		rownames(stats)<-adjnamelist[2:length(adjnamelist)]
		colnames(stats)<-Gnames	
		
		did <- H5Dopen(gMulti,  "adjp")
		#sid <- H5Dget_space(did)
		adjpvs <- H5Dread(did)
		H5Dclose(did)
		#H5Sclose(sid)
		adjp<-adjpvs[]
		
		
		##*************************NEED TO REPLACE WITH STORING GROUP NAMES IN HDF5 file
		##  Read in group names
		group.names <- read.table(file=GroupNames,sep="\t",header=TRUE)
		##  Finding statistics method
		
		#tmp<-getH5Attribute(gFVer,"statMethod")
		aSMethod<-H5Aopen(gFVer,"statMethod")
		tmp<-H5Aread(aSMethod)
		H5Aclose(aSMethod)
	
		
	  		if (substr(tmp[1],1,32)=="Function=statistics.Clustering.R") method = "cluster"
	  		if (substr(tmp[1],1,34)=="Function=statistics.Correlations.R") method = "correlation"
	  		if (substr(tmp[1],1,31)=="Function=statistics.EavesTest.R") method = "eaves"
	  		if (substr(tmp[1],1,21)=="Function=statistics.R") method = "twogroup"
	  		if (substr(tmp[1],1,34)=="Function=statistics.TwoWay.ANOVA.R") method = "twowayanova"
	  		if (substr(tmp[1],1,34)=="Function=statistics.OneWay.ANOVA.R") method = "onewayanova"
	
		##  Adjustments to labels - Two Group Analyses
	
		if (method == "twogroup"){
			if (length(Gnames)>1){
				row.names<-rownames(stats)
				for (i in 1:length(row.names)){
	  				if (substr(row.names[i],1,5)=="Group"){ 
	    					tmp.num = substr(unlist(strsplit(row.names[i],"\\."))[1],6,1000)
	    					row.names[i]<-paste(group.names$grp.name[group.names$grp.number==tmp.num],".Mean",sep="")
	  				}
				}
				rownames(stats) <- row.names
			}
			else if (length(Gnames==1)){
				row.names<-names(stats)
				for (i in 1:length(row.names)){
	  				if (substr(row.names[i],1,5)=="Group"){ 
	    					tmp.num = substr(unlist(strsplit(row.names[i],"\\."))[1],6,1000)
	    					row.names[i]<-paste(group.names$grp.name[group.names$grp.number==tmp.num],".Mean",sep="")
	  				}
				}
				names(stats) <- row.names
			}	
		}
	
		##  Adjustments to labels - Eaves Test
	
		if (method == "eaves" && length(Gnames)>0){
			row.names<-rownames(stats)
			for (i in 1:length(row.names)){
				if (row.names[i]=="Line1Exp1-Mean") row.names[i]<-paste(group.names$grp.name[group.names$grp.number==1],".Mean",sep="")
				if (row.names[i]=="Line2Exp1-Mean") row.names[i]<-paste(group.names$grp.name[group.names$grp.number==2],".Mean",sep="")
				if (row.names[i]=="Line1Exp2-Mean") row.names[i]<-paste(group.names$grp.name[group.names$grp.number==3],".Mean",sep="")
				if (row.names[i]=="Line2Exp2-Mean") row.names[i]<-paste(group.names$grp.name[group.names$grp.number==4],".Mean",sep="")
			}
			stats <- rbind(round(as.numeric(stats[1,]),digits=3),round(as.numeric(stats[2,]),digits=3),round(as.numeric(stats[3,]),digits=3),round(as.numeric(stats[4,]),digits=3),round(as.numeric(stats[5,]),digits=2),round(as.numeric(stats[6,]),digits=2),stats[7,])
			rownames(stats) <- row.names
		}
		
		##  Adjustments to labels - Two Way ANOVA
	
		if (method == "twowayanova"){
			if (length(Gnames)==1) names(stats) <- gsub("()","",names(stats),fixed=TRUE)
			  else rownames(stats) <- gsub("()","",rownames(stats),fixed=TRUE)
		}
	
		##  Adjustments to labels - One Way ANOVA
	
		if (method == "onewayanova"){
			if (length(Gnames)>1){
				row.names<-rownames(stats)
				for (i in 1:length(row.names)){
					if (substr(row.names[i],1,5)=="Group") row.names[i] <- as.character(group.names$grp.name[group.names$grp.number==unlist(strsplit(row.names[i],".",fixed=TRUE))[2]])
				}
				rownames(stats) <- row.names
			}
			else if (length(Gnames)==1){
				row.names<-names(stats)
				for (i in 1:length(row.names)){
					if (substr(row.names[i],1,5)=="Group") row.names[i] <- as.character(group.names$grp.name[group.names$grp.number==unlist(strsplit(row.names[i],".",fixed=TRUE))[2]])
				}
				names(stats) <- row.names
			}
		}
	
		##  Output Gene List
	
		if (method=="cluster") {
			for.text<-t(stats)
			colnames(for.text)[1]<-"Probe.ID"
			write.table(for.text, file = OutputGeneList, append = FALSE, sep = '\t',row.names = FALSE,col.names=TRUE,quote=FALSE)	
		}
	
		if (method == "eaves"){
			for.text<-cbind(Gnames,t(format(stats,nsmall=3,digits=4)))
			colnames(for.text)[1]<-"Probe.ID"
			write.table(for.text, file = OutputGeneList, append = FALSE, sep = '\t',row.names = FALSE,col.names=TRUE,quote=FALSE)	
		}
		if (method != "cluster" && method != "eaves"){
			for.text<-cbind(Gnames,t(format(stats,nsmall=3,digits=4)),format(adjp,nsmall=3,digits=4,scientific=TRUE))
			colnames(for.text)[ncol(for.text)]<-"adjusted.p.value"
			colnames(for.text)[1]<-"Probe.ID"
			write.table(for.text, file = OutputGeneList, append = FALSE, sep = '\t',row.names = FALSE,col.names=TRUE,quote=FALSE)	
		}
	
	
	
		################################
		# else: length of Gnames == 0
	
		if (length(Gnames)<1){
			
			stats = 'No statistically significant gene was selected'
				
			
			cat(stats, file = OutputGeneList, append = FALSE, sep = '\n')	
			
		}
	
	}# END if(count>0)
  
  H5Gclose(gMulti)
  H5Gclose(gFVer)
  H5Gclose(gDay)
  H5Gclose(gFilter)
  H5Gclose(gVersion)  
  H5Fclose(h5)
	
} ## END       
	
