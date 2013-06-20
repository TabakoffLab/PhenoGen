##### PhenGetP2.R
### unmodified from getP2.R in SPIA package
### Updated 6/12/13 Spencer Mahaffey  still unmodified except name of function

PhenGetP2<-function(pG,combine="fisher"){
#given a pG returns two equal p-values such as   combfunc(p1,p2)=pG
 if(combine=="fisher"){
ch=qchisq(pG,4,lower.tail = FALSE)
return(sqrt(exp(-ch/2)))
}

 if(combine=="norminv"){
  return(pnorm(qnorm(pG)*sqrt(2)/2))
 }
}
