summary.var<-function(Avgdata,groups){
	GroupVar <- cbind(var(Avgdata[groups[[1]]],na.rm=TRUE),var(Avgdata[groups[[2]]],na.rm=TRUE),var(Avgdata[groups[[3]]],na.rm=TRUE),var(Avgdata[groups[[4]]],na.rm=TRUE))
	return(GroupVar)
}

summary.n<-function(Avgdata,groups){
	GroupN <- cbind(sum(!is.na(Avgdata[groups[[1]]])),
                          sum(!is.na(Avgdata[groups[[2]]])),
                          sum(!is.na(Avgdata[groups[[3]]])),
                          sum(!is.na(Avgdata[groups[[4]]])))
	return(GroupN)
}

pooled.var.func <- function(data){
	pooled.var1<-( max(data["Line1Exp1-LocalVar"],data["Line1Exp1-Var"])*2 +  min(data["Line1Exp1-LocalVar"],data["Line1Exp1-Var"]) ) / 3   
	pooled.var2<-( max(data["Line2Exp1-LocalVar"],data["Line2Exp1-Var"])*2 +  min(data["Line2Exp1-LocalVar"],data["Line2Exp1-Var"]) ) / 3   
	pooled.var3<-( max(data["Line1Exp2-LocalVar"],data["Line1Exp2-Var"])*2 +  min(data["Line1Exp2-LocalVar"],data["Line1Exp2-Var"]) ) / 3   
	pooled.var4<-( max(data["Line2Exp2-LocalVar"],data["Line2Exp2-Var"])*2 +  min(data["Line2Exp2-LocalVar"],data["Line2Exp2-Var"]) ) / 3   
	pooled.var <- cbind(pooled.var1,pooled.var2,pooled.var3,pooled.var4)
	return(pooled.var)
}

modified.t<-function(data){
	t.stats1 <- (data["Line1Exp1-Mean"] - data["Line2Exp1-Mean"]) / (data["Line1Exp1-PooledVar"]/data["Line1Exp1-N"] + data["Line2Exp1-PooledVar"]/data["Line2Exp1-N"])^0.5 
	t.stats2 <- (data["Line1Exp2-Mean"] - data["Line2Exp2-Mean"]) / (data["Line1Exp2-PooledVar"]/data["Line1Exp2-N"] + data["Line2Exp2-PooledVar"]/data["Line2Exp2-N"])^0.5 
	t.stat<-cbind(t.stats1,t.stats2)
	return(t.stat)
}
