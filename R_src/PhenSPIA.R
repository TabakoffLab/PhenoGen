############################ PhenSPIA.R ###################################
#
#
#   modified version of spia.R, a bioconductor package
#   http://www.bioconductor.org/packages/release/bioc/html/SPIA.html
#   modified for use on phenogen
#
#
#   8/9/10  Steve Flink   created/modified\
#	6/12/13	Spencer Mahaffey	Merged with updated SPIA package from Bioconductor 2.12 allows use of updated pathway rdata files created by downloading all kgml docs for each model organism using perl script updateSPIAPathways.pl
#								Major change from the regular SPIA package is EDIDs  possibly they were added by Steve so I kept that in this version since SimpleSPIA.R needs those IDs.
###########################################################################

PhenSPIA<-function(de=NULL,all=NULL,organism="hsa",data.dir=NULL,pathids=NULL,
                   nB=2000,plots=FALSE,verbose=TRUE,beta=NULL,combine="fisher"){

if(is.null(de)|is.null(all)){stop("de and all arguments can not be NULL!")}

  rel<-c("activation","compound","binding/association","expression","inhibition",
"activation_phosphorylation","phosphorylation","inhibition_phosphorylation",
"inhibition_dephosphorylation","dissociation","dephosphorylation",
"activation_dephosphorylation","state change","activation_indirect effect",
"inhibition_ubiquination","ubiquination", "expression_indirect effect",
"inhibition_indirect effect","repression","dissociation_phosphorylation",
"indirect effect_phosphorylation","activation_binding/association",
"indirect effect","activation_compound","activation_ubiquination")
if(is.null(beta)){
beta=c(1,0,0,1,-1,1,0,-1,-1,0,0,1,0,1,-1,0,1,-1,-1,0,0,1,0,1,1)
names(beta)<-rel
}else{

if(!all(names(beta) %in% rel) | length(names(beta))!=length(rel)){
 stop(paste("beta must be a numeric vector of length",length(rel), "with the following names:", "\n", paste(rel,collapse=",")))
 }
}


  .myDataEnv <- new.env(parent=emptyenv()) # not exported

 datload<-paste(organism, "SPIA", sep = "")

 if(is.null(data.dir)){
 if(! paste(datload,".RData",sep="") %in% dir(system.file("extdata",package="SPIA"))){
  cat("The KEGG pathway data for your organism is not present in the extdata folder of the SPIA package!!!")
cat("\n");
  cat("Please generate one first using makeSPIAdata and specify its location using data.dir argument or copy it in the extdata folder of the SPIA package!")
 } else{
  load(file=paste(system.file("extdata",package="SPIA"),paste("/",organism, "SPIA", sep = ""),".RData",sep=""), envir=.myDataEnv)
  }
 }
 if(!is.null(data.dir)){
 if (! paste(datload,".RData",sep="") %in% dir(data.dir)) {
   cat(paste(data.dir, " does not contin a file called ",paste(datload,".RData",sep="")))
    
 }else{
 load(file=paste(data.dir,paste(datload,".RData",sep=""),sep=""), envir=.myDataEnv)
  }
 }
  
  datpT=.myDataEnv[["path.info"]]
  
  if (!is.null(pathids)){
   if( all(pathids%in%names(datpT))){
   datpT=datpT[pathids]
   }else{
   stop( paste("pathids must be a subset of these pathway ids: ",paste(names(datpT),collapse=" "),sep=" "))
  }
  }
  
  datp<-list();


  path.names<-NULL
  hasR<-NULL
  
  for (jj in 1:length(datpT)){
  sizem<-dim(datpT[[jj]]$activation)[1]
  s<-0;
  con<-0;

  for(bb in 1:length(rel)){
  con=con+datpT[[jj]][[rel[bb]]]*abs(sign(beta[rel[bb]]))
  s=s+datpT[[jj]][[rel[bb]]]*beta[rel[bb]]
  }
  z=matrix(rep(apply(con,2,sum),dim(con)[1]),dim(con)[1],dim(con)[1],byrow=TRUE); 
  z[z==0]<-1;
    
datp[[jj]]<- s/z
path.names<-c(path.names,datpT[[jj]]$title)
hasR<-c(hasR,datpT[[jj]]$NumberOfReactions>=1) 
  } 

names(datp)<-names(datpT)
names(path.names)<-names(datpT)
tor<-lapply(datp,function(d){sum(abs(d))})==0 | hasR | is.na(path.names)
datp<-datp[!tor]
path.names<-path.names[!tor]

if(is.null(de)|is.null(all)){
   stop("de and all arguments can not be NULL!")
}

 IDsNotP<-names(de)[!names(de)%in%all]
if(length(IDsNotP)/length(de)>0.01){
   stop("More than 1% of your de genes have IDs are not present in the reference array!. Are you sure you use the right reference array?")
}
 
if(!length(IDsNotP)==0){
   cat("The following IDs are missing from all vector...:\n") 
   cat(paste(IDsNotP,collapse=","))
   cat("\nThey were added to your universe...")
   all<-c(all,IDsNotP)
} 
if(length(intersect(names(de),all))!=length(de)){
   stop("de must be a vector of log2 fold changes. The names of de should be included in the refference array!")
}
ph<-pb<-pcomb<-nGP<-pSize<-smPFS<-tA<-tAraw<-KEGGLINK<-NULL;
 set.seed(1)
 if(plots){ 
  pdf("SPIAPerturbationPlots.pdf")
 }
EDIDs<-NULL
 for(i in 1:length(names(datp))){
  path<-names(datp)[i]
  M<-datp[[path]]
  diag(M)<-diag(M)-1;
  X<-de[rownames(M)]
  noMy<-sum(!is.na(X))
  nGP[i]<-noMy
  okg<-intersect(rownames(M),all)
  ok<-rownames(M)%in%all
  pSize[i]<-length(okg)
   EDIDsInM<-intersect(rownames(M), names(de))
   LengthEDIDsInM<-length(EDIDsInM)
   if (LengthEDIDsInM > 0){
      pathEDIDs<-NULL
      for (ed in EDIDsInM){
         pathEDIDs<-paste(pathEDIDs,ed, sep=" ")
      }
      pathEDIDs<-sub(" ", "", pathEDIDs)
   }
   else{
      pathEDIDs<-""
   }
   EDIDs<-c(EDIDs, pathEDIDs)   
  if((noMy)>0&(abs(det(M))>1e-7)){
   gnns<-paste(names(X)[!is.na(X)],collapse="+")
   KEGGLINK[i]<-paste("http://www.genome.jp/dbget-bin/show_pathway?",organism,names(datp)[i],"+",gnns,sep="")
   X[is.na(X)]<-0.0
   pfs<-solve(M,-X)
   smPFS[i]<-sum(pfs-X)
   tAraw[i]<-smPFS[i]


   if(plots){
    #if(interactive()){x11();par(mfrow=c(1,2))}
    par(mfrow=c(1,2))
    plot(X,pfs-X,main=paste("pathway ID=",names(datp)[i],sep=""),
     xlab="Log2 FC",ylab="Perturbation accumulation (Acc)",cex.main=0.8,cex.lab=1.2);abline(h=0,lwd=2,col="darkgrey");
    abline(v=0,lwd=2,col="darkgrey");#abline(0,1,lwd=2,col="darkgrey");
    points(X[abs(X)>0 & X==pfs],pfs[abs(X)>0 & X==pfs]-X[abs(X)>0 & X==pfs],col="blue",pch=19,cex=1.4)
    points(X[abs(X)>0 & X!=pfs],pfs[abs(X)>0 & X!=pfs]-X[abs(X)>0 & X!=pfs],col="red",pch=19,cex=1.4)
    points(X[abs(X)==0 & X==pfs],pfs[abs(X)==0 & X==pfs]-X[abs(X)==0 & X==pfs],col="black",pch=19,cex=1.4)
    points(X[abs(X)==0 & X!=pfs],pfs[abs(X)==0 & X!=pfs]-X[abs(X)==0 & X!=pfs],col="green",pch=19,cex=1.4)
   }
   ph[i]<-phyper(q=noMy-1,m=pSize[i],n=length(all)-pSize[i],k=length(de),lower.tail=FALSE)
   pfstmp<-NULL
   for (k in 1:nB){
         x<-rep(0,length(X));
         names(x)<-rownames(M);
    x[ok][sample(1:sum(ok),noMy)]<-as.vector(sample(de,noMy))
    tt<-solve(M,-x)
    pfstmp<-c(pfstmp,sum(tt-x))#
   }           
    mnn<-median(pfstmp)
    pfstmp<-pfstmp-mnn
    ob<-smPFS[i]-mnn
    tA[i]<-ob
    if(ob>0){
       pb[i]<-sum(pfstmp>=ob)/length(pfstmp)*2
       if(pb[i]<=0){pb[i]<-1/nB/100} 
       if(pb[i]>1){pb[i]<-1} 
    }
    if(ob<0){
       pb[i]<-sum(pfstmp<=ob)/length(pfstmp)*2
      if(pb[i]<=0){pb[i]<-1/nB/100} 
      if(pb[i]>1){pb[i]<-1} 
    }
    
    if(ob==0){
     if(all(pfstmp==0)){    #there is nothing to learn from perturbations
        pb[i]<-NA
     }else{
      pb[i]<-1
     }
     }
     if(plots){
         plot(density(pfstmp,bw=sd(pfstmp)/4),cex.lab=1.2,col="black",lwd=2,main=paste("pathway ID=",names(datp)[i],"  P PERT=",round(pb[i],5),sep=""),
              xlim=c(min(c(tA[i]-0.5,pfstmp)),max(c(tA[i]+0.5,pfstmp))),cex.main=0.8,xlab="Total Perturbation Accumulation (TA)")
         abline(v=0,col="grey",lwd=2)
         abline(v=tA[i],col="red",lwd=3)
      }
      pcomb[i]<-PhenCombfunc(pb[i],ph[i],combine)
   }else{
      pb[i]<-ph[i]<-smPFS[i]<-pcomb[i]<-tAraw[i]<-tA[i]<-KEGGLINK[i]<-NA}
   if(verbose){
      cat("\n");
      cat(paste("Done pathway ",i," : ",substr(path.names[names(datp)[i]],1,30),"..",sep=""))
   }
}#end for each pathway
if(plots){ 
   par(mfrow=c(1,1))
   dev.off()
}
pcombFDR=p.adjust(pcomb,"fdr");
phFdr=p.adjust(ph,"fdr")
pcombfwer=p.adjust(pcomb,"bonferroni") 
Name=substr(path.names[names(datp)],1,30)
Status=ifelse(tA>0,"Activated","Inhibited")
res<-data.frame(Name,ID=names(datp),pSize,NDE=nGP,EDIDs,tA,pNDE=ph,pPERT=pb,pG=pcomb,pGFdr=pcombFDR,pGFWER=pcombfwer,Status,KEGGLINK,stringsAsFactors=FALSE)
res<-res[!is.na(res$pNDE),]
 res<-res[order(res$pG),]
 rownames(res)<-NULL;
res
} 

