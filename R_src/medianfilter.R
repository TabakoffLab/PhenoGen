# MEDIANFILTER applies median filter to data
# 
#     p = MEDIANFILTER(DATA,SIGVAL, TITLE) 
# 
# Here, rows are experiments, COLS are genes, MISSING values
# are not allowed.
# 
# SIGVAL is optional, default is 0.05.
# TITLE  is optional and displays above the histograms
#
# Assume that most genes don't change expression level
# across experiments, i.e. the expression level is just noise.
# Assume a normal distribution for the noise.
# 
# If DATA = N x M matrix of expression values then,
# for each column of data (i.e. each gene), 
# let s2 be the column-variance.
# Let M be the median of the M column-variances.
# Let W = (N-1)*s2/M, which is approximately chi-squared with
# N-1 degrees of freedom.
# 
# p is the length M vector of CHI2 percentile values

# Written by Sonia Leach 05/22/01, 07/03/01
# Edited by Laura Saba 09/02/10
# function p = medianfilter(data, sigval, tit)

medianfilter <- function(data,percent=50,sigval=0.05,tit="Data:") {

#load required functions
fileLoader(c('percentile.R'))

if (length(which(is.na(data)))>0) {
	print('Error: data must not have missing values!\n')
	return(NA)
}	

N<-dim(data)[1]
M<-dim(data)[2]

s2<-rep(0,M)

for(i in 1:M)
  s2[i]<-var(data[,i])
MedianVariance<-percentile(s2,percent,na.rm = T)
W<-(N-1)*s2/MedianVariance

p = pchisq(W, N-1)

return(p)
}
