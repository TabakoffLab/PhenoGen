

multiMiR.getGenesTargetedByMir <- function(mirID,organism,outputDir,outputPrefix,tbl='all',cutoffType='p',cutoff=20) {
  
  ###########################################
  #   Load Packages & Setup Working Space   #
  ###########################################
  
  library(multiMiR)
  
  output=get.multimir(org=organism,mirna=mirID, table=tbl,predicted.cutoff.type=cutoffType,predicted.cutoff=cutoff,summary=TRUE)
  
  outputPred=paste(outputDir,outputPrefix,".pred.txt",sep="")
  outputVal=paste(outputDir,outputPrefix,".val.txt",sep="")
  outputSum=paste(outputDir,outputPrefix,".summary.txt",sep="")
  
  write.table(output$predicted,file=outputPred,sep="\t",row.names=FALSE,quote=FALSE)
  write.table(output$validated,file=outputVal,sep="\t",row.names=FALSE,quote=FALSE)
  write.table(output$summary,file=outputSum,sep="\t",row.names=FALSE,quote=FALSE)
}