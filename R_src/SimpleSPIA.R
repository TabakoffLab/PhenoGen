######################## SimpleSPIA.R #########################
#
# This function reads a list of differentially expressed (DE) genes as probe set ids and
# their fold changes. The function carries out an analysis of the
# intersection between the DE gene set and the genes in known pathways. The SPIA algorithm
# uses not only the number of DE genes in a pathway but also the position of the DE genes 
# within the pathway to arrive at a score indicating how strongly a pathway is affected.
#
# Parameters:
#     DEList           =    Path to the text file containing the list of probe sets of the
#                           differentially expressed genes to be tested, together with 
#                           their fold changes. Must have first column: probe set ids, 
#                           second column: fold changes.
#
#     ReferenceTable   =    Path to the table of reference genes.
#                           Must be a text file with first column: probe set ids, second
#                           column: EntrezGene ids, third column: gene symbols. 
#
#     organism         =    3-letter KEGG abreviation for organism. 
#                           Must be one of 'hsa', 'mmu', 'rno', 'dme'. 
#                           Default is 'hsa'.
#
#     method           =    Method for combining fold-changes for multiple probe sets
#                           corresponding to the same gene. Must be one of 'average' or
#                           'maximum'. Default is 'average'.
#
#     MainTableName    =    File name of the main table.
#
#     AuxTableName     =    File name of the auxiliary table.
#
#     plotName         =    File name of the NDE-Pertubation plot. 
#
#     
#
# Returns:   
#     nothing
#
# Writes out:     
#     SPIAResultsTable =  Tab delimited file containing result of the analysis. 
#
#     SPIAPPlot        =  A .jpg file of an NDE-Pertubation plot.
# 
#     SPIAGeneTable    = Tab delimited file containing information about each
#                        DE gene in each pathway. 
#
# Sample Call:  
#            SimpleSPIA(DEList="SPIATestSetG13.txt",  ReferenceTable="HapLapRefTable.txt", 
#                       organism="mmu", method="average", MainTableName="NewSPIAOutTable.txt",
#                       AuxTableName = "NewSPIAGeneTable.txt", plotName="NewSPIAPlot.jpg")
#
# Function History:
#            8/9/10 Steve Flink       created
#            9/1/10 Steve Flink       provision made for SPIA returning an empty table
###########################################################################################

SimpleSPIA <- function(DEList, ReferenceTable, organism = "hsa", method = "average",
                       MainTableName = "SPIAOutputTable.txt", AuxTableName = "SPIAGeneTable", 
                       plotName = "SPIATwoWayPlot.jpg"){

###################### load packages
library(SPIA)

fileLoader("PhenMultipleValueConcat.R")
fileLoader("PhenPlotP.R")
fileLoader("PhenGetP2.R")
fileLoader("PhenSPIA.R")
fileLoader("PhenCombfunc.R")
#################################
data<-read.table(DEList, header=F)
Reference<-read.table(ReferenceTable, header=F, sep="\t")

RefNames<-colnames(Reference)
tempEntrezID<-Reference[,2]
tempEntrezID<-as.character(tempEntrezID)
Reference<-cbind(as.character(Reference[,1]), tempEntrezID, as.character(Reference[,3]))
colnames(Reference)<-RefNames

newProbeID<-c()
newEntrezID<-c()
newGeneSymbol<-c()
newFoldChange<-c()
for (i in 1:nrow(data)){
   id<-as.character(data[i,1])
   RefLabels<-which(Reference[,1]==id)
   for (j in RefLabels){
      newProbeID<-c(newProbeID, id)
      newEntrezID<-c(newEntrezID, as.character(Reference[j,2]))
      newGeneSymbol<-c(newGeneSymbol, as.character(Reference[j,3]))
      newFoldChange<-c(newFoldChange, as.numeric(data[i,2]))  
   }
}
newData<-data.frame(newProbeID, newEntrezID, newGeneSymbol, newFoldChange)
names(newData)<-c("ProbeID", "EntrezID", "GeneSymbol", "FoldChange")
newData<-na.omit(newData)
Data<-PhenMultipleValueConcat(newData, method)
# names(Data)
SPIAData<-matrix(as.numeric(Data[,4]),nrow=nrow(Data), ncol=1)      ## fold change
names(SPIAData)<-Data[,2]         ## Entrez id

#####################################################################
Results<-PhenSPIA(de=SPIAData,
                  all=as.character(Reference[,2]), organism = organism,
                  nB=2500, plots=F, verbose=F, beta=NULL)
####################################################################################
#
#    Create a vector of gene names for the de genes that come up in each pathway
#
####################################################################################
if (nrow(Results)>0){
   EDIDs<-strsplit(Results$EDIDs, " ")
   SPIAGeneNames<-NULL
   tempGeneName<-NULL
   for (i in 1:length(EDIDs)){
      tempGeneLabels<-which(Reference[ ,2]==EDIDs[[i]][1])
      tempGeneNames<-unique(Reference[tempGeneLabels,3])[1]
      if (length(unique(Reference[tempGeneLabels,3]))>1){
         for (j in 2:length(unique(Reference[tempGeneLabels,3]))){
            tempGeneName<-paste(tempGeneName, Reference[,3][tempGeneLabels[j]], sep="//")
         }
      }
      if (length(EDIDs[[i]])>1){
         for (eg in 2:length(EDIDs[[i]])){
            tempGeneLabels<-which(Reference[,2]==EDIDs[[i]][eg])
            tempGeneName<-unique(Reference[tempGeneLabels,3])[1]
            if (length(unique(Reference[tempGeneLabels,3]))>1){
               for (j in 2:length(unique(Reference[tempGeneLabels,3]))){
                  tempGeneName<-paste(tempGeneName, Reference[,3][tempGeneLabels[j]], sep="//")
               }
            }
         tempGeneNames<-paste(tempGeneNames, tempGeneName, sep=", ")
         } 
      }
      SPIAGeneNames<-c(SPIAGeneNames, tempGeneNames)
   }
}
############################################################################################
#
#    Create an auxiliary table, one line per DE gene-pathway intersection
#    with all gene identifiers, pathway id, and fold change used for analysis
#
###########################################################################################
if (nrow(Results)>0){
   AuxTable<-c()
   for (i in 1:length(SPIAGeneNames)){
      PathGeneNames<-strsplit(SPIAGeneNames[[i]], split = ", ")
      for (j in 1:length(PathGeneNames[[1]])){
         EID<-EDIDs[[i]][j]
         AuxPathID<-Results$ID[i] 
         ProbeIDLabels<-which(Reference[,2]==EID)
         ProbeIDList<-intersect(Reference[ProbeIDLabels,1], data[,1])
         AuxProbeID<-ProbeIDList[1]
         if (length(ProbeIDList) > 1){
            for (k in 2:length(ProbeIDList)){
               AuxProbeID<-paste(AuxProbeID, ProbeIDList[k], sep=", ")
            }
         }
         AuxFoldChange<-Data$FoldChange[Data$EntrezID==EID]
         AuxGeneName<-PathGeneNames[[1]][j]
         AuxRow<-c(EID, AuxPathID, AuxGeneName, AuxProbeID, AuxFoldChange)
         AuxTable<-rbind(AuxTable, AuxRow)
      }  
   }
   AuxFoldChanges<-as.numeric(AuxTable[,5])
   AuxiliaryTable<-data.frame(AuxTable[,1:4], AuxFoldChanges, row.names=c(1:nrow(AuxTable)))
   names(AuxiliaryTable)<-c("EntrezID", "PathID", "GeneSymbol", "ProbeSetIDs", "FoldChangeUsed")
}else{
   AuxiliaryTable<-data.frame("No Pathways Found", 0,0,0,0)
   names(AuxiliaryTable)<-c("EntrezID", "PathID", "GeneSymbol", "ProbeSetIDs", "FoldChangeUsed")
}
###################################
#
#   OUPTUT AUXILIARY TABLE
#
##################################   

write.table(AuxiliaryTable, AuxTableName, row.names=F, sep="\t")
   
###############################
##  OUTPUT PLOT
###############################      
if (nrow(Results)>0){    
  jpeg(filename = plotName, width = 480, height = 480,
       units = "px", pointsize = 16, quality = 100, bg = "white",
       res = NA)
       #res = NA, restoreConsole = TRUE)
  PhenPlotP(Results, threshold=.05)
  dev.off()
}else{
  jpeg(filename = plotName, width = 480, height = 480,
       units = "px", pointsize = 16, quality = 100, bg = "white",
       res = NA)
      plot(x=0, y=0, pch=19, cex=1.5, xlim = c(0,7), ylim=c(0,7),
           main="SPIA two-way evidence plot",
           xlab="-log(P NDE)",ylab="-log(P PERT)")
      abline(v= 7,lwd=1,col="red",lty=2)
      abline(h= 7,lwd=1,col="red",lty=2)
      abline(v= 6,lwd=1,col="blue",lty=2)
      abline(h= 6,lwd=1,col="blue",lty=2)
      points(c(0,10),c(10,0),col="red",lwd=2,cex=0.7,type="l")
      points(c(0,3),c(3,0),col="blue",lwd=2,cex=0.7,type="l")
      legend("center", "", title="No pathways were found for this gene list.")
   dev.off()
}

######################################
# CREATE AND OUTPUT MAIN TABLE
######################################
if (nrow(Results)>0){
   OutResults<-data.frame(Results[,1:4], SPIAGeneNames, signif(Results[,6:11],4), Results[,12:13])
   names(OutResults)<-c("PathName", "PathID", "PathSize","NumDEGenes", 
                        "DEGenes","tA", "pNDE", "pPert", "pG", "pGFdr",
                        "pGFWER", "Status", "KEGGLink")
}else{
   OutResults<-data.frame("No Pathways Found", 0,0,0,0,0,0,0,0,0,0,0,0)
      names(OutResults)<-c("PathName", "PathID", "PathSize","NumDEGenes", 
                        "DEGenes","tA", "pNDE", "pPert", "pG", "pGFdr",
                        "pGFWER", "Status", "KEGGLink")
}
write.table(OutResults, MainTableName, row.names=F, sep="\t")
## OutResults
}


