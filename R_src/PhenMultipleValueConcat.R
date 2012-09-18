############################# PhenMultipleValueConcat.R #####################
### A script to modify data for input to SPIA.
### As input, SPIA requires a vector of fold change data, labeled
### with EntrezGene IDs, and a list of all available genes,
### also as EntrezGene IDs. SPIA wants at most one value for each distinct gene.
###
### This script takes as input a vector of values with (possibly duplicate) names
### and returns the vector with the duplicates either (based on method):
### a) removed and replaced by a single entry (with the duplicated name)
### with the mean of those duplicates, or
### b) removed and replaced by a single entry, the maximum of the duplicates
### method = "maximum" or "average"
### MVC =  multiple value concatenation
# 
#  column names of Data are "ProbeID", "EntrezID", "GeneSymbol", "FoldChange"
#  we are interested in the EntrezID and FoldChange
#############################################################################
PhenMultipleValueConcat<-function(Data, method="maximum"){
   NoName<-Data[,2]==""
   Data<-Data[!NoName,]
   Dupes<-duplicated(Data[!NoName,2])
   DistinctData<-Data[!Dupes,]
   for (i in 1:nrow(DistinctData)){
      ind<-which(Data[,2]==DistinctData[i,2])
      if (method == "maximum"){
         DistinctData[i,4]<-max(Data[ind,4])
      }
      if (method == "average"){
         DistinctData[i,4] = mean(Data[ind,4])
      }
   }
colnames(DistinctData)<-colnames(Data)
return(DistinctData)
}
   




