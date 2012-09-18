##### PhenGetP2.R
### unmodified from getP2.R in SPIA package

PhenGetP2<-function(t){
f<-function(x){
   x-x*log(x)
}
zz<-seq(0,t,by=t/1000)
r<-na.omit(f(zz))
zz[r>t][1]
}
