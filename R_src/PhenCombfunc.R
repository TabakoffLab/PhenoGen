################## PhenCombfunc.R ###################
#
# unmodified version of combfunc.R from SPIA package
#
#####################################################
PhenCombfunc<-function(p1,p2){
 k=p1*p2
 k-k*log(k)
}
