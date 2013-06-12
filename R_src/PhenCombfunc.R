################## PhenCombfunc.R ###################
#
# unmodified version of combfunc.R from SPIA package
#
#
#	6/12/13 Spencer Mahaffey updated but still unmodified from SPIA except function name.
#####################################################
PhenCombfunc<-function(p1=NULL,p2=NULL,combine="fisher"){
 tm=na.omit(c(p1,p2))
 if(!all(tm>=0 & tm<=1)){
 stop("values of p1 and p2 have to be >=0 and <=1 or NAs")
 }
 
if(combine=="fisher"){
 k=p1*p2
 comb=k-k*log(k)
 comb[is.na(p1)]<-p2[is.na(p1)]
 comb[is.na(p2)]<-p1[is.na(p2)]
 return(comb)
 }
 
 if(combine=="norminv"){
 
 comb=pnorm( (qnorm(p1)+qnorm(p2))/sqrt(2))
 comb[is.na(p1)]<-p2[is.na(p1)]
 comb[is.na(p2)]<-p1[is.na(p2)]
 
  return(comb)
 }
 
 
}
