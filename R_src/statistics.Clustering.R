########################## statistics.Clustering.R ################
#
# This function computes a clustering analysis on the filtered genes
#
# Parms:
#    InputFile  = name of input file containing Absdata, Avgdata, Gnames, grouping, groups, Snames, Procedure
#                     (OutputFile from Affy.filter.genes)
#    ClusterType = type of clustering use
#             	"hierarch" -> Hierarchical clustering
#             	"kmeans" -> k-means partitioning
#    ClusterObject = variable to cluster
#			"samples"
#			"genes"
#			"both" (only available for hierarchical clustering)
#    RunGroups = TRUE/FALSE indicator for whether rungroup means should be used, if FALSE samples will be used
#    GroupLabels = txt file with grp.number and grp.name
#    Distance = distance measure
#			"one.minus.corr" -> 1 - pearson correlation coefficient
#			"euclidean" -> Euclidean distance (square root of the sum of squared differences)
#    parameter1
#		For Hierarchical Clustering = between-cluster dissimilarity measure	
#			"single" -> minimum difference between points in different clusters
#			"complete" -> maximum difference between points in different clusters
#			"average" -> average of all distances between points in different clusters
#			"centroid" -> difference between cluster centroids
#		For K-Means Clustering = # of cluster
#    parameter2
#		For Hierarchical Clustering = # of clusters to be reported in Cluster Output Files
#		For K-Means Clustering = NOT NEEDED (default -99)
#    error.file = txt file generated if zero variance occurs in any cluster object
#
# Returns:
#    nothing
#
# Writes out:
#    png file (ImageFile) containing dendrogram or heatmap for hierarchical clustering
#    text file (ClusterMembershipFile) containing a row for each level of clustered variable with number
#		identifier of cluster that they belong to
#
# Sample Call:
#    statistics.Clustering(InputFile = 'filter.genes.output.Rdata',ClusterType="hierarch",ClusterObject="genes",Distance="euclidean",RunGroups=TRUE,GroupLabels = "GroupLabels.txt",parameter1="complete",parameter2=6)
#
#  Function History
#	9/20/07	Laura Saba	Created
#	9/26/07	Laura Saba	Modified:  transposed output text files
#	1/10/07	Laura Saba	Modified:  created text files associated with each graph
#	3/17/09	Laura Saba	Modified:	removed title and footer from dendrogram
#	8/12/09	Laura Saba	Modified:	added code to eliminate cluster objects with zero variance and to generate an error file
#   3/27/13 Laura Saba  Modified:	updated coding of kmeans graphic to handle situation when more than 1024 genes/samples are in one cluster (limitation due to color palette)
#
####################################################


statistics.Clustering <- function(InputFile, ClusterType, ClusterObject, RunGroups = FALSE, GroupLabels, Distance, parameter1, parameter2=-99, error.file){

  ###################################################
  ###################################################
  ###				  ###################
  ### 	START OF PROGRAM	  ###################
  ###				  ###################
  ###################################################
  ###################################################

  ####  Increase expressions value
  options(expressions=500000)

  ####  Call appropriate libraries
  library(stats)
  library(gplots)

  #### Import new heatmap function
  fileLoader('heatmap.new.R')

  ####  Import filtered data					
  load(InputFile)

  ####  Update Procedure variable
  Procedure <- paste(Procedure, "Function=statistics.Clustering.R",';','Clustering.method=',ClusterType,';','Cluster.object=',ClusterObject,'|',sep = '')

  ####  Import group labels
  unique.groups <- sort(unique(grouping))
  if(unique.groups[1]==0) unique.groups<-unique.groups[-1]
  group.labels <- read.table(file=GroupLabels,sep="\t",header=TRUE)
  group.labels <- group.labels[group.labels$grp.number %in% unique.groups,]
  group.labels <- group.labels[order(group.labels$grp.number),]

  ####  Needed Functions
  group.var <- function(Avgdata,groups,unique.groups){
	GroupVar<-c()
	for(i in 1:length(unique.groups)) GroupVar<-cbind(GroupVar,var(Avgdata[groups[[unique.groups[i]]]],na.rm=TRUE))
	return(GroupVar)
  }

  ####  Creating unique gene identifiers
  duplicates <- duplicated(row.names(Avgdata))
  both.genenames<-cbind(row.names(Avgdata),row.names(Avgdata))
  for (i in 1:nrow(Avgdata)){
	if(duplicates[i]) both.genenames[i,2]<-paste(row.names(Avgdata)[i],"_",i,sep="")
  }
  row.names(Avgdata)<-both.genenames[,2]

  ####  Calculate distance matrix based on mean values for RunGroups
  if (RunGroups) {

	####  Calculate Group Means and Group Standard Deviations
	GroupMeans<-c()
	for (i in 1:length(unique.groups)) GroupMeans <- cbind(GroupMeans,rowMeans(Avgdata[,groups[[unique.groups[i]]]]))
	colnames(GroupMeans) <- paste(group.labels$grp.name,"Mean",sep=".")
	GroupVars <- sqrt(t(apply(Avgdata,groups = groups, unique.groups=unique.groups,1,group.var)))
	colnames(GroupVars) <- paste(group.labels$grp.name,"StdDev",sep=".")

	####  Band-Aid - Cluster objects that do not vary within object
	if (ClusterObject=="samples" && Distance=="one.minus.corr") {
		bad.corrs <- (colSums(apply(GroupMeans,2,duplicated)) == (nrow(GroupMeans) - 1))
		bad.probes <- paste(labels(bad.corrs)[bad.corrs],collapse=",")
		
		if (sum(!bad.corrs) > 2){
			GroupMeans <- GroupMeans[,!bad.corrs]
			GroupVars <- GroupVars[,!bad.corrs]

			if(sum(bad.corrs)>0) {
				if (ClusterType == "hierarch" && parameter2>=ncol(GroupMeans)) {
					parameter2 = (ncol(GroupMeans) - 1)
					write(paste("Warning:",sum(bad.corrs),"of your Run Groups had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis causing the number of clusters requested to be equal to or more then the reduced number of Run Groups.  The number of clusters shown represent the maximum number possible.  The Euclidean distance measure allows for zero variance within a cluster object.",sep=" "),file=error.file)
				}
				else if (ClusterType == "kmeans" && parameter1>=ncol(GroupMeans)) {
					parameter1 = (ncol(GroupMeans) - 1)
					write(paste("Warning:",sum(bad.corrs),"of your Run Groups had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis causing the number of clusters requested to be equal to or more then the reduced number of Run Groups.  The number of clusters shown represent the maximum number possible.  The Euclidean distance measure allows for zero variance within a cluster object.",sep=" "),file=error.file)
				}
				else write(paste("Warning:",sum(bad.corrs),"of your Run Groups had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis.  The Euclidean distance measure allows for zero variance within a cluster object.",sep=" "),file=error.file)
			}
  		}
		else {
			write(paste("Error:",sum(bad.corrs),"of your Run Groups had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis.  Less than three Run Groups remain and therefore the clustering algorithm is not valid.  The Euclidean distance measure allows for zero variance within a cluster object.",sep=" "),file=error.file)
			stop("See txt output")
		}
	}

	if (ClusterObject=="genes" && Distance=="one.minus.corr") {
		bad.corrs <- (colSums(apply(GroupMeans,1,duplicated)) == (ncol(GroupMeans) - 1))
		bad.probes <- paste(labels(bad.corrs)[bad.corrs],collapse=",")

		if (sum(!bad.corrs) > 2){
			GroupMeans <- GroupMeans[!bad.corrs,]
			GroupVars <- GroupVars[!bad.corrs,]

			if(sum(bad.corrs)>0) {
				if (ClusterType == "hierarch" && parameter2>=nrow(GroupMeans)) {
					parameter2 = (nrow(GroupMeans) - 1)
					write(paste("Warning:",sum(bad.corrs),"of your genes had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis causing the number of clusters requested to be equal to or more then the reduced number of genes.  The number of clusters shown represent the maximum number possible.  The Euclidean distance measure allows for zero variance within a cluster object.",sep=" "),file=error.file)
				}
				else if (ClusterType == "kmeans" && parameter1>=nrow(GroupMeans)) {
					parameter1 = (nrow(GroupMeans) - 1)
					write(paste("Warning:",sum(bad.corrs),"of your genes had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis causing the number of clusters requested to be equal to or more then the reduced number of genes.  The number of clusters shown represent the maximum number possible.  The Euclidean distance measure allows for zero variance within a cluster object.",sep=" "),file=error.file)
				}
				else write(paste("Warning:",sum(bad.corrs),"of your genes had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis.  The Euclidean distance measure allows for zero variance within a cluster object.",sep=" "),file=error.file)
			} 
 		}
		else {
			write(paste("Error:",sum(bad.corrs),"of your genes had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis.  Less than three genes remain and therefore the clustering algorithm is not valid.  The Euclidean distance measure allows for zero variance within a cluster object.",sep=" "),file=error.file)
			stop("See txt output")
		}
	}

	####  Calculate distance matrix based on mean values for RunGroups
  	if (ClusterObject=="samples" && Distance=="one.minus.corr") distance <- as.dist(1-cor(GroupMeans))
	if (ClusterObject=="genes" && Distance=="one.minus.corr") distance <- as.dist(1-cor(t(GroupMeans)))
	if (ClusterObject=="samples" && Distance=="euclidean") distance <- dist(t(GroupMeans))
	if (ClusterObject=="genes" && Distance=="euclidean") distance <- dist(GroupMeans)

	####  Create cluster output file that has group means and standard deviations
	cluster.output <- c()
	labels <- c()
	for (j in 1:ncol(GroupMeans)){ 
		cluster.output<-cbind(cluster.output,GroupMeans[,j],GroupVars[,j])
		labels <-c(labels,colnames(GroupMeans)[j],colnames(GroupVars)[j])
	}
	labels <- c("gene.name","cluster.number",labels)
	ForGraphs <- GroupMeans
	colnames(ForGraphs) <- sub(".Mean","",colnames(GroupMeans))
  }


  if (!RunGroups){

  	####  Band-Aid - Cluster objects that do not vary within object
	if (ClusterObject=="samples" && Distance=="one.minus.corr") {
		bad.corrs <- (colSums(apply(Avgdata,2,duplicated)) == (nrow(Avgdata) - 1))
		bad.probes <- paste(labels(bad.corrs)[bad.corrs],collapse=",")

		
		if (sum(!bad.corrs) > 2){
			Avgdata<- Avgdata[,!bad.corrs]
			if(sum(bad.corrs)>0) {
				if (ClusterType == "hierarch" && parameter2>=ncol(Avgdata)) {
					parameter2 = (ncol(Avgdata) - 1)
					write(paste("Warning:",sum(bad.corrs),"of your samples had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis causing the number of clusters requested to be equal to or more the reduced number of samples.  The number of clusters shown represent the maximum number possible.  The Euclidean distance measure allows for zero variance with a cluster object.",sep=" "),file=error.file)
				}
				else if (ClusterType == "kmeans" && parameter1>=ncol(Avgdata)) {
					parameter1 = (ncol(Avgdata) - 1)
					write(paste("Warning:",sum(bad.corrs),"of your samples had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis causing the number of clusters requested to be equal to or more the reduced number of samples.  The number of clusters shown represent the maximum number possible.  The Euclidean distance measure allows for zero variance with a cluster object.",sep=" "),file=error.file)
				}
				else write(paste("Warning:",sum(bad.corrs),"of your samples had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis.  The Euclidean distance measure allows for zero variance with a cluster object.",sep=" "),file=error.file)
			}
  		}
		else {
			write(paste("Error:",sum(bad.corrs),"of your samples had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis.  Less than three samples remain and therefore the clustering algorithm is not valid.  The Euclidean distance measure allows for zero variance with a cluster object.",sep=" "),file=error.file)
			stop("See txt output")
		}
	}

	if (ClusterObject=="genes" && Distance=="one.minus.corr") {
		bad.corrs <- (colSums(apply(Avgdata,1,duplicated)) == (ncol(Avgdata) - 1))
		bad.probes <- paste(labels(bad.corrs)[bad.corrs],collapse=",")

		if (sum(!bad.corrs) > 2){
			Avgdata <- Avgdata[!bad.corrs,]
			if(sum(bad.corrs)>0) {
				if (ClusterType == "hierarch" && parameter2>=nrow(Avgdata)) {
					parameter2 = (nrow(Avgdata) - 1)
					write(paste("Warning:",sum(bad.corrs),"of your genes had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis causing the number of clusters requested to be equal to or more the reduced number of genes.  The number of clusters shown represent the maximum number possible.  The Euclidean distance measure allows for zero variance with a cluster object.",sep=" "),file=error.file)
				}
				else if (ClusterType == "kmeans" && parameter1>=nrow(Avgdata)) {
					parameter1 = (nrow(Avgdata) - 1)
					write(paste("Warning:",sum(bad.corrs),"of your genes had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis causing the number of clusters requested to be equal to or more the reduced number of genes.  The number of clusters shown represent the maximum number possible.  The Euclidean distance measure allows for zero variance with a cluster object.",sep=" "),file=error.file)
				}
				else write(paste("Warning:",sum(bad.corrs),"of your genes had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis.  The Euclidean distance measure allows for zero variance with a cluster object.",sep=" "),file=error.file)
			}
  		}
		else {
			write(paste("Error:",sum(bad.corrs),"of your genes had a zero variance","(",bad.probes,")","and therefore was/were deleted from the cluster analysis.  Less than three genes remain and therefore the clustering algorithm is not valid.  The Euclidean distance measure allows for zero variance with a cluster object.",sep=" "),file=error.file)
			stop("See txt output")
		}
	}

	####  Calculate distance matrix based on individual arrays
  	if (ClusterObject=="samples" && Distance=="one.minus.corr") distance <- as.dist(1-cor(Avgdata))
  	if (ClusterObject=="genes" && Distance=="one.minus.corr") distance <- as.dist(1-cor(t(Avgdata)))
  	if (ClusterObject=="samples" && Distance=="euclidean") distance <- dist(t(Avgdata))
  	if (ClusterObject=="genes" && Distance=="euclidean") distance <- dist(Avgdata)

	####  Create cluster output file
 	if (ClusterObject=="genes") {
		cluster.output <- round(Avgdata,digits=3)
		labels <- c("gene.name","cluster.number",colnames(cluster.output))
		ForGraphs <- Avgdata
	}
	if (ClusterObject=="samples") {
		cluster.output <- t(round(Avgdata,digits=3))
		labels <- c("sample.name","cluster.number",colnames(cluster.output))
		ForGraphs <- t(Avgdata)
 	}
  }
	

  ###############  Hierarchical Clustering  ###############

  if (ClusterType=="hierarch") {
	if (ClusterObject=="samples"||ClusterObject=="genes"){
		clust.cor <- hclust(distance, method = parameter1)

		bitmap(file = "Dendogram.png", type = 'png16m', width = 3.333, height = 3.333, res = 300)
			if (ClusterObject=="samples"){
			  if (length(clust.cor$labels)>70) plot(clust.cor,hang=-1,labels=FALSE,main="",sub="",xlab="")
			    else if (max(nchar(clust.cor$labels))>30||length(clust.cor$labels)>50) plot(clust.cor,hang=-1,cex=0.6,main="",sub="",xlab="")
			    else if (max(nchar(clust.cor$labels))>20||length(clust.cor$labels)>40) plot(clust.cor,hang=-1,cex=0.8,main="",sub="",xlab="")
			    else plot(clust.cor,hang=-1,main="",sub="",xlab="")
			  write.table(clust.cor$labels[clust.cor$order],file="SampleTable.txt",col.names=FALSE,quote=FALSE)
                  }
			if (ClusterObject=="genes"){
			  if (length(clust.cor$labels)<=40) plot(clust.cor,hang=-1,main="",sub="",xlab="")
			    else if (length(clust.cor$labels)<=50) plot(clust.cor,hang=-1,cex=0.8,main="",sub="",xlab="")
			    else if (length(clust.cor$labels)<=70) plot(clust.cor,hang=-1,cex=0.6,main="",sub="",xlab="")
			    else plot(clust.cor,hang=-1,labels=FALSE,main="",sub="",xlab="")
			  write.table(Gnames[clust.cor$order],file="GeneTable.txt",col.names=FALSE,quote=FALSE)
                  }

			cluster.class<-rect.hclust(clust.cor, k=parameter2, border="red")  #cut into clusters
		dev.off()

		cluster.groups<-c()
		for(i in 1:parameter2){
			tmp<-cbind(rep(i,length(cluster.class[[i]])),labels(cluster.class[[i]]))
			cluster.groups<-rbind(cluster.groups,tmp)
		}
		rownames(cluster.groups)<-cluster.groups[,2]
		cluster.groups <- cluster.groups[,1]


		###  Add Cluster Assignment to Cluster Output file
		if(ClusterObject=="genes") {
			cluster.output <- merge(cluster.groups,round(cluster.output,digits=3),by="row.names")
			colnames(cluster.output) <- labels
		}
		if(ClusterObject=="samples"){
			if (RunGroups) {
                  	cluster.number<-c()
				for(i in 1:length(cluster.groups)){
					cluster.number <- c(cluster.number,rep(cluster.groups[colnames(GroupMeans)][i],2))
				}
				cluster.output<-rbind(cluster.number,round(cluster.output,digits=3))
				colnames(cluster.output) <- labels[-1][-1]
			}
			if (!RunGroups) {
				cluster.output <-  merge(cluster.groups,round(cluster.output,digits=3),by="row.names")
				rownames(cluster.output)<-cluster.output[,1]
				cluster.output <- cluster.output[,-1]
				colnames(cluster.output)[1]<-"cluster.number"
			}
		}

		###  Output By Cluster Details By Sample
		cluster.detail <-c()
		for (k in 1:parameter2){
			
			if (ClusterObject == "genes") {
				stats <- cluster.output[cluster.output$cluster.number==k,]
				gene.ids <- stats$gene.name
				NumInGroup <- length(gene.ids)
				stats <- merge(both.genenames,stats,by.x=2,by.y="gene.name")
				stats <- t(stats[,-1])
				row.names(stats)[1]<-"gene.name"
				write.table(t(stats), file = paste("Cluster",k,".txt",sep=""),sep="\t",quote=FALSE,row.names=FALSE,col.names=TRUE)
				if (NumInGroup>1) c.summary<-colMeans(ForGraphs[gene.ids,])
				if (NumInGroup==1) c.summary<-ForGraphs[gene.ids,]
				c.summary<-c(paste(k),paste(NumInGroup),round(c.summary,digits=3))
				cluster.detail <- rbind(cluster.detail,c.summary)

				save(Absdata,Avgdata,Gnames,grouping,groups,Procedure,Snames,stats,file=paste("Cluster",k,".Rdata",sep=""))
			}

			if (ClusterObject == "samples") {
				if (RunGroups) {
					tmp<-which(cluster.number==k)
					tmp2<-which(cluster.groups[colnames(GroupMeans)]==k)
					NumInGroup <- length(tmp)/2
					if (NumInGroup>1) c.summary<-rowMeans(ForGraphs[,tmp2])
					if (NumInGroup==1) c.summary<-ForGraphs[,tmp2]
					for.output <- cluster.output[,tmp]
					rownames(for.output)[-1] <- both.genenames[,1]
					write.table(for.output, file = paste("Cluster",k,".txt",sep=""),sep="\t",quote=FALSE,row.names=TRUE,col.names=NA)
				}
				if (!RunGroups) {
					tmp<-which(cluster.output$cluster.number==k)
					NumInGroup <- length(tmp)
					if (NumInGroup>1) c.summary<-colMeans(ForGraphs[tmp,])
					if (NumInGroup==1) c.summary<-ForGraphs[tmp,]
					for.output <- t(cluster.output[tmp,])
					rownames(for.output)[-1] <- both.genenames[,1]
					write.table(for.output, file = paste("Cluster",k,".txt",sep=""),sep="\t",quote=FALSE,row.names=TRUE,col.names=NA)
				}

				c.summary<-c(paste(k),paste(NumInGroup),round(c.summary,digits=3))
				cluster.detail <- rbind(cluster.detail,c.summary)
			}

		}

		if (ClusterObject == "samples") colnames(cluster.detail)[3:ncol(cluster.detail)]<-both.genenames[,1]
		colnames(cluster.detail)[1:2]<-c("Cluster.Number","Number.In.Cluster")
		write.table(t(cluster.detail), file = "ClusterSummary.txt",sep="\t",quote=FALSE,row.names=TRUE,col.names=FALSE)
		if (ClusterObject == "samples"){
			if (RunGroups){
				lower<-cluster.output[2:nrow(cluster.output),]
				lower<-merge(both.genenames,lower,by.x=2,by.y=0)
				lower<-lower[,-1]
				stats<-t(lower)
				tmp.num<-c()
				for (l in 1:length(cluster.groups[colnames(GroupMeans)])) tmp.num <- c(tmp.num,rep(cluster.groups[colnames(GroupMeans)][l],2))
				tmp.labels<-paste(rownames(stats)[-1],".Cluster",tmp.num,sep="")
				rownames(stats)<-c("Probe.ID",tmp.labels)
				save(Absdata,Avgdata,Gnames,grouping,groups,Procedure,Snames,stats,file="ClusterSummary.Rdata")
			}
			if (!RunGroups){
				lower<-t(cluster.output[,2:ncol(cluster.output),])
				lower<-merge(both.genenames,lower,by.x=2,by.y=0)
				lower<-lower[,-1]
				stats<-t(lower)
				tmp.labels<-paste(rownames(stats)[-1],".Cluster",cluster.output$cluster.number,sep="")
				rownames(stats)<-c("Probe.ID",tmp.labels)
				save(Absdata,Avgdata,Gnames,grouping,groups,Procedure,Snames,stats,file="ClusterSummary.Rdata")
			}
		}
	}

	else if(ClusterObject=="both"){
		bitmap(file = "Heatmap.png", type = 'png16m', width = 3.333, height = 3.333, res = 300)
		if (!RunGroups & Distance=="one.minus.corr") clust.cor<-heatmap.new(Avgdata,margins=c(8,8),col=redgreen(75),hclustfun = function(a) hclust(a,method=parameter1),distfun = function(a) as.dist(1-cor(t(a))),trace="none",keysize=1.25,density.info="none",scale="row",cexCol=0.8)
		if (!RunGroups & Distance=="euclidean") clust.cor<-heatmap.new(Avgdata,margins=c(8,8),col=redgreen(75),hclustfun = function(a) hclust(a,method=parameter1),trace="none",keysize=1.25,density.info="none",scale="row",cexCol=0.8)
		if (RunGroups & Distance=="one.minus.corr")  clust.cor<-heatmap.new(GroupMeans,margins=c(8,8),col=redgreen(75),hclustfun = function(a) hclust(a,method=parameter1),distfun = function(a) as.dist(1-cor(t(a))),trace="none",keysize=1.25,density.info="none",scale="row",cexCol=0.8)
		if (RunGroups & Distance=="euclidean")  clust.cor<-heatmap.new(GroupMeans,margins=c(8,8),col=redgreen(75),hclustfun = function(a) hclust(a,method=parameter1),trace="none",keysize=1.25,density.info="none",scale="row",cexCol=0.8)
		dev.off()
	}
  }

  ###############  K-Means Clustering  ###############

  else if(ClusterType=="kmeans"){

	clust.cor <- kmeans(distance,parameter1)

	###  Add Cluster Assignment to Cluster Output file
	if(ClusterObject=="genes") {
		cluster.output <- merge(clust.cor$cluster,round(cluster.output,digits=3),by="row.names")
		colnames(cluster.output) <- labels
	}

	if(ClusterObject=="samples"){
		if (RunGroups) {
 			cluster.number<-c()
			for(i in 1:length(clust.cor$cluster)){
				cluster.number <- c(cluster.number,rep(clust.cor$cluster[colnames(GroupMeans)][i],2))
			}
			cluster.output<-rbind(as.character(cluster.number),round(cluster.output,digits=3))
			row.names(cluster.output)[1]<-"cluster.number"
			colnames(cluster.output) <- labels[-1][-1]
		}
		if (!RunGroups) {
			cluster.output <-  merge(clust.cor$cluster,round(cluster.output,digits=3),by="row.names")
			rownames(cluster.output)<-cluster.output[,1]
			cluster.output <- cluster.output[,-1]
			colnames(cluster.output)[1]<-"cluster.number"
			both.genenames <-rbind(rep("cluster.number",2),both.genenames)
		}
            
	}

	cluster.detail <- c()

	for (k in 1:parameter1){

		if (ClusterObject=="genes"){
			tmp<-cluster.output[cluster.output$cluster.number == k,"gene.name"]
			NumInGroup <- length(tmp)
			bitmap(file = paste("Cluster",k,".png",sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
				plot(ForGraphs[tmp[1],],type="l",ylim=c(min(ForGraphs)-0.5,max(ForGraphs)+0.5),ann=FALSE,xaxt="n")
				if (NumInGroup>1){
					if(NumInGroup<1025) palette(rainbow(NumInGroup))
					if(NumInGroup>1024) palette(rainbow(1024))
					for (i in 2:NumInGroup){
						lines(ForGraphs[tmp[i],],type="l",col=(i %% 1024))
					}
				}
				title(main=paste("Cluster",k,sep=" "),ylab="Gene Expression")
				axis(1,1:ncol(ForGraphs),lab=F)
				if (max(nchar(colnames(ForGraphs)))<16 && ncol(ForGraphs)<51) {
                          text(1:ncol(ForGraphs), par("usr")[3] - 0.4, srt=45, adj=1, labels=colnames(ForGraphs),xpd=T,cex=0.6)
				  write.table(colnames(ForGraphs),quote=FALSE,col.names=FALSE,file="SampleTable.txt",sep="\t")
                        }
				else if (ncol(ForGraphs)<51){
                          text(1:ncol(ForGraphs), par("usr")[3] - 0.5, srt=45, adj=1, labels=paste("Sample",1:ncol(ForGraphs),sep="."),xpd=T,cex=0.8)
				  write.table(colnames(ForGraphs),quote=FALSE,col.names=FALSE,file="SampleTable.txt",sep="\t")
				}
				else {
                          write.table(colnames(ForGraphs),quote=FALSE,col.names=FALSE,file="SampleTable.txt",sep="\t")
				}
			dev.off()

			stats <- cluster.output[cluster.output$cluster.number==k,]
			stats <- merge(both.genenames,stats,by.x=2,by.y="gene.name")
			stats <- stats[,-1]
			colnames(stats)[1]<-"gene.name"
			stats <- t(stats)
			write.table(t(stats), file = paste("Cluster",k,".txt",sep=""),sep="\t",quote=FALSE,row.names=FALSE,col.names=TRUE)
			save(Absdata,Avgdata,Gnames,grouping,groups,Procedure,Snames,stats,file=paste("Cluster",k,".Rdata",sep=""))
			if (NumInGroup>1) c.summary<-colMeans(ForGraphs[tmp,])
			if (NumInGroup==1) c.summary<-ForGraphs[tmp,]
			c.summary<-c(paste(k),paste(NumInGroup),round(c.summary,digits=3))
			cluster.detail <- rbind(cluster.detail,c.summary)
		}

		if (ClusterObject=="samples"){
			if(RunGroups) {
				tmp<-which(cluster.number == k)
				tmp2<-which(clust.cor$cluster[colnames(GroupMeans)]==k)
				NumInGroup <- length(tmp2)
				bitmap(file = paste("Cluster",k,".png",sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
					plot(ForGraphs[,tmp2[1]],type="l",ylim=c(min(ForGraphs)-0.5,max(ForGraphs)+0.5),ann=FALSE,xaxt="n")
					if (NumInGroup>1){
						palette(rainbow(NumInGroup))
						for (i in 2:NumInGroup){
							lines(ForGraphs[,tmp2[i]],type="l",col=i)
						}
					}
					title(main=paste("Cluster",k,sep=" "),ylab="Gene Expression")
					axis(1,1:nrow(ForGraphs),lab=F)
					if (nrow(ForGraphs)<36) text(1:nrow(ForGraphs), par("usr")[3] - 0.5, srt=45, adj=1, labels=rownames(ForGraphs),xpd=T,cex=0.8)
					  else if (nrow(ForGraphs)<51) text(1:nrow(ForGraphs), par("usr")[3] - 0.5, srt=45, adj=1, labels=rownames(ForGraphs),xpd=T,cex=0.5)
					write.table(rownames(ForGraphs),sep="/t",file="GeneTable.txt",quote=FALSE,col.names=FALSE)
				dev.off()

				stats <- cluster.output[,tmp]
				stats <- cbind(rownames(stats),stats)
				colnames(stats)[1]<-"V1"
				upper <- stats[1,]
				lower <- stats[2:nrow(stats),]
				lower <- merge(both.genenames,lower,by.x=2,by.y=1)
				lower <- lower[,-1]
				stats.t <- rbind(t(as.matrix(upper)),as.matrix(lower))
				colnames(stats.t)[1] <- ""
				stats <- t(stats.t)
				write.table(stats.t, file = paste("Cluster",k,".txt",sep=""),sep="\t",quote=FALSE,row.names=FALSE,col.names=TRUE)
				if (NumInGroup>1) c.summary<-rowMeans(ForGraphs[,tmp2])
				if (NumInGroup==1) c.summary<-ForGraphs[,tmp2]
				c.summary<-c(paste(k),paste(NumInGroup),round(c.summary,digits=3))
				cluster.detail <- rbind(cluster.detail,c.summary)
			}
			if(!RunGroups) {
				tmp<-rownames(cluster.output[cluster.output$cluster.number == k,])
				NumInGroup <- length(tmp)
				bitmap(file = paste("Cluster",k,".png",sep=""), type = 'png16m', width = 3.333, height = 3.333, res = 300)
					plot(ForGraphs[tmp[1],],type="l",ylim=c(min(ForGraphs)-0.5,max(ForGraphs)+0.5),ann=FALSE,xaxt="n")
					if (NumInGroup>1){
						palette(rainbow(NumInGroup))
						for (i in 2:NumInGroup){
							lines(ForGraphs[tmp[i],],type="l",col=i)
						}
					}
					title(main=paste("Cluster",k,sep=" "),ylab="Gene Expression")
					axis(1,1:ncol(ForGraphs),lab=F)
					if (ncol(ForGraphs)<36) text(1:ncol(ForGraphs), par("usr")[3] - 0.5, srt=45, adj=1, labels=colnames(ForGraphs),xpd=T,cex=0.8)
                                else if (ncol(ForGraphs)<51) text(1:ncol(ForGraphs), par("usr")[3] - 0.5, srt=45, adj=1, labels=colnames(ForGraphs),xpd=T,cex=0.5)
					write.table(colnames(ForGraphs),sep="\t",file="GeneTable.txt",col.names=FALSE,quote=FALSE)
				dev.off()

				stats <- t(cluster.output[tmp,])
				stats <- merge(both.genenames,stats,by.x=2,by.y=0)
				stats <- stats[,-1]
				colnames(stats)[1] <- ""
				stats <- t(stats)
				write.table(t(stats), file = paste("Cluster",k,".txt",sep=""),sep="\t",quote=FALSE,row.names=FALSE,col.names=TRUE)
				if (NumInGroup>1) c.summary<-colMeans(ForGraphs[tmp,])
				if (NumInGroup==1) c.summary<-ForGraphs[tmp,]
				c.summary<-c(paste(k),paste(NumInGroup),round(c.summary,digits=3))
				cluster.detail <- rbind(cluster.detail,c.summary)
			}
		}	
	}

	###  Output Cluster Summary	
	colnames(cluster.detail)[1:2]<-c("Cluster.Number","Number.In.Cluster")
	cluster.detail <- t(cluster.detail)

	if (ClusterObject == "genes") write.table(cluster.detail, file = "ClusterSummary.txt",sep="\t",quote=FALSE,row.names=TRUE,col.names=FALSE)

	if (ClusterObject == "samples"){
		upper <- cluster.detail[1:2,]
		upper <- cbind(rownames(upper),upper)
		colnames(upper) <- paste("V", 1:ncol(upper), sep="")
		lower <- cluster.detail[3:nrow(cluster.detail),]
		lower <- merge(both.genenames,lower,by.x=2,by.y=0)
		lower <- lower[,-1]
		colnames(lower) <- paste("V", 1:ncol(lower), sep="")
		cluster.detail <- rbind(upper,lower)
		write.table(cluster.detail, file = "ClusterSummary.txt",sep="\t",quote=FALSE,row.names=FALSE,col.names=FALSE)
		if (RunGroups) {
			tmp.cluster.out <- merge(both.genenames,cluster.output,by.x=2,by.y=0)
			stats<-t(tmp.cluster.out[,-1])	
			tmp.num<-c()
			for (l in 1:length(clust.cor$cluster[colnames(GroupMeans)])) tmp.num <- c(tmp.num,rep(clust.cor$cluster[colnames(GroupMeans)][l],2))
			tmp.labels<-paste(rownames(stats)[-1],".Cluster",tmp.num,sep="")
			rownames(stats)<-c("Probe.ID",tmp.labels)
			save(Absdata,Avgdata,Gnames,grouping,groups,Procedure,Snames,stats,file="ClusterSummary.Rdata")
		}
		if (!RunGroups) {
			tmp.cluster.out <- merge(both.genenames,t(cluster.output),by.x=2,by.y=0)
			stats<-t(tmp.cluster.out[,-1])	
			tmp.labels<-paste(rownames(stats)[-1],".Cluster",round(as.numeric(stats[-1,1])),sep="")
			stats <- stats[,-1]
			rownames(stats)<-c("Probe.ID",tmp.labels)
			save(Absdata,Avgdata,Gnames,grouping,groups,Procedure,Snames,stats,file="ClusterSummary.Rdata")
		}
	}

  }

}  #### END 
