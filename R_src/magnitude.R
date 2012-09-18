# magnitude(d) returns magnitude. d is a vector
magnitude<-function(d) {
  sqrt(sum(d*d,na.rm=T))
}
