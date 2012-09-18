


plotExonQC<-function(qc.checks,dabg.checks,fc.line.col="black",sf.ok.region="light blue",chip.label.col="black",sf.thresh = 6,present.thresh=10,bg.thresh=20,label=NULL,
main="QC Stats",usemid=F,spread=c(-8,8),cex=1,...) {
  old.par <- par()
  par(mai=c(0,0,0,0))
  
  ##  Get QC Measurements from qc.checks and dabg.checks  ##
  
  sfs <- 	qc.checks[,"pm_mean"] / mean(qc.checks[,"pm_mean"])
  n <- 		length(sfs)

  meansf <- mean(sfs)

  dpv <- dabg.checks[,"all_probeset_percent_called"]
  dpv <- (round(100*dpv,2))

  abg <- qc.checks[,"bgrd_mean"]
  abg <- (round(100*abg))/100
	
  if(is.null(label)) { label <- qc.checks[,"cel_files"] }
  
  auc <- qc.checks[,"pos_vs_neg_auc"]
  dabg.auc <- dabg.checks[,"pos_vs_neg_auc"]

  d1 <- 0.0;
  d2 <- 0.0;
  d3 <- 0.0;
  for(i in 1:n) {
    for(j in 1:n) { 
      d1 <- max(abs(sfs[i] - sfs[j]),d1);
      d2 <- max(abs(dpv[i] - dpv[j]),d2);
      d3 <- max(abs(abg[i] - abg[j]),d3);
    }
  }

  # set up plotting area - a column for array names next to a column for the QC

  m <- matrix(c(4,2,1,3) ,nrow=2,ncol=2)
  layout(m,c(1,2),c(0.1,1))
  # the title
  if(is.null(main)) { main="" }
  plot(0,0,xlim=range(0,1),ylim=range(0,1),type="n",yaxs="i",xaxt="n",yaxt="n",bty="n")
  text(0.35,0.5,labels=main,adj=0,cex=cex*2)

  # write out the array names

  plot(0,0,xlim=range(0,1),ylim=range(-1,n),type="n",yaxs="i",xaxt="n",yaxt="n",bty="n")
  text(1,(1:n)-0.5,labels=label,adj=1,cex=cex)
  plot(0,0,xlim=spread,ylim=c(-1,n),type="n",xaxs="i",yaxs="i",xaxt="n",yaxt="n",bty="n")

  x1 <- (1.3 - 1) * 10
  y1 <- 0
  x2 <- (0.7 - 1) * 10
  y2 <- n

  polygon(c(x1,x2,x2,x1),c(y1,y1,y2,y2),col=sf.ok.region,border=sf.ok.region);
  lines(c(0,0),c(0,n),lty=1,col=fc.line.col)
  lines(c(-1,-1),c(0,n),lty=2,col="grey")
  lines(c(-2,-2),c(0,n),lty=2,col="grey")
  lines(c(-3,-3),c(0,n),lty=2,col=fc.line.col)
  lines(c(1,1),c(0,n),lty=2,col="grey")
  lines(c(2,2),c(0,n),lty=2,col="grey")
  lines(c(3,3),c(0,n),lty=2,col=fc.line.col)
  text(3,-1,"1.3",pos=3,col=fc.line.col,cex=cex)
  text(2,-1,"1.2",pos=3,col=fc.line.col,cex=cex)
  text(1,-1,"1.1",pos=3,col=fc.line.col,cex=cex)
  text(-3,-1,"0.7",pos=3,col=fc.line.col,cex=cex)
  text(-2,-1,"0.8",pos=3,col=fc.line.col,cex=cex)
  text(-1,-1,"0.9",pos=3,col=fc.line.col,cex=cex)
  text(0,-1,"1",pos=3,col=fc.line.col,cex=cex)

  for(i in 1:n) {
    x1<-spread[1]
    x2<-spread[2]
    y1<-i-1;
    y2<-i-1;
    lines(c(x1,x2),c(y1,y2),lty=2,col="light grey")
    if(d1 > sf.thresh) { col = "red" } else {col="blue"}
     x1 <- (sfs[i] - 1)*10
     y1 <- i-0.25
     lines(c(0,x1),c(y1,y1),col=col);

    points(x1,y1,col=col,pch=20);
    x2 <- (auc[i]-1)*10
    y2 <- i-0.5;
    if(x2 < (-2)) { col = "red" } else {col="blue"}	
    points(x2,y2,pch=1,col=col);

     x2 <- (dabg.auc[i]-1)*10;
     y2 <- i-0.75;
     if(x2 < (-3)) { col = "red" } else {col="blue"}	
     points(x2,y2,pch=2,col=col);

     if(d2 > present.thresh) { col = "red" } else {col="blue"}
     x2 <- spread[1]
     y2 <- i-0.25
     dpvs<-paste(dpv[i],"%",sep="")
     text(x2,y2,label=dpvs,col=col,pos=4,cex=cex);
     
     if(d3 > bg.thresh) { col = "red" } else {col="blue"}
     x2 <- spread[1]
     y2 <- i-0.75
     text(x2,y2,label=abg[i],col=col,pos=4,cex=cex);
  }
     
 	#plot(0,0,xlim=range(-8,8),ylim=range(0,1),type="n",yaxs="i",xaxt="n",yaxt="n",bty="n")
  plot(0,0,xlim=range(0,2),ylim=range(0,1),type="n",yaxs="i",xaxt="n",yaxt="n",bty="n")
   points(0.25,0.5,pch=1)
   text(0.3,0.5,"AUC Pos vs Neg",pos=4,cex=cex)
   points(0.25,0.25,pch=2)
   text(0.3,0.25,"AUC Pos vs Neg - DABG",pos=4,cex=cex)
  

}


