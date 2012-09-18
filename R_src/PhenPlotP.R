##################  PhenPlotP.R ###############################
#
#
### A slightly modified version of plotP function in SPIA.
### 
### Prints pathway name in plot rather than pathway id number
### for those pathways found to be significant.
#
#  8/9/10  Steve Flink 
#  8/26/10 Steve Flink  Handles empty 
###############################################################

PhenPlotP<-function(x,threshold=0.05){

if(class(x)!="data.frame" | dim(x)[1]<1 | 
sum(names(x)%in%c("Name","ID","pSize","NDE","tA","pNDE","pPERT","pG","pGFdr","pGFWER","Status"))<11){
 plot(x=0, y=0, pch=19, cex=1.5, xlim = c(0,7), ylim=c(0,7),main="SPIA two-way evidence plot",
  xlab="-log(P NDE)",ylab="-log(P PERT)")
 abline(v= 7,lwd=1,col="red",lty=2)
 abline(h= 7,lwd=1,col="red",lty=2)
 abline(v= 6,lwd=1,col="blue",lty=2)
 abline(h= 6,lwd=1,col="blue",lty=2)
 points(c(0,10),c(10,0),col="red",lwd=2,cex=0.7,type="l")
 points(c(0,3),c(3,0),col="blue",lwd=2,cex=0.7,type="l")
 legend("center", "", title="No pathways were found for your gene list.")
}

####  
# if(threshold<x[1,"pGFdr"]){
# msg<-paste("The threshold value should be",x[1,"pGFdr"],"or higher!!!");
#  stop(msg);
# }

 pb<-x[,"pPERT"]
 ph<-x[,"pNDE"]
 okx<-(ph<1e-6)
 oky<-(pb<1e-6)

 ph[ph<1e-6]<-1e-6
 pb[pb<1e-6]<-1e-6

 plot(-log(ph),-log(pb),xlim=c(0,max(c(-log(ph),-log(pb))+1,na.rm=TRUE)),
  ylim=c(0,max(c(-log(ph),-log(pb)+1),na.rm=TRUE)),pch=19,main="SPIA two-way evidence plot",cex=1.5,
  xlab="-log(P NDE)",ylab="-log(P PERT)")
 tr<-threshold/dim(na.omit(x))[1]
 abline(v=-log(tr),lwd=1,col="red",lty=2)
 abline(h=-log(tr),lwd=1,col="red",lty=2)
 points(c(0,-log(PhenGetP2(tr))),c(-log(PhenGetP2(tr)),0),col="red",lwd=2,cex=0.7,type="l")
 oks<-x[,"pGFWER"]<=threshold
 
tr<-.9*min(x[,"pG"][x[,"pGFdr"]>threshold],na.rm=TRUE)
 if (sum(x[,"pGFdr"]<=threshold) > 0){
    tr<-mean(c(max(x[,"pG"][x[,"pGFdr"]<=threshold],na.rm=TRUE),min(x[,"pG"][x[,"pGFdr"]>threshold],na.rm=TRUE)))
 }
points(c(0,-log(PhenGetP2(tr))),c(-log(PhenGetP2(tr)),0),col="blue",lwd=2,cex=0.7,type="l")

 abline(v=-log(tr),lwd=1,col="blue",lty=2)
 abline(h=-log(tr),lwd=1,col="blue",lty=2)
 oks2<-x[,"pGFdr"]<=threshold
if (sum(oks2)>0){
   points(-log(ph)[oks2],-log(pb)[oks2],pch=19,col="blue",cex=1.5)
}
 if(sum(okx)>0){
  points(-log(ph)[okx]-0.12,-log(pb)[okx],pch="|",col="black",cex=1.5)
 }
 if(sum(oky)>0){
  points(-log(ph)[oky],-log(pb)[oky]-0.12,pch="_",col="black",cex=1.5)
 }
 if (sum(oks)>0){
   text(-log(ph)[oks],-log(pb)[oks]+0.5,labels=as.vector(x$Name)[oks])
   points(-log(ph)[oks],-log(pb)[oks],pch=19,col="red",cex=1.5)
 }
}


