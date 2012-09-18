# NORMALIZEMAG1(DATA, DIM) normalizes across DIM to have mean 0, magnitude 1
#    default dimension to normalize is rows (1), not columns (i.e. 2)

normalizeMag1<-function(data, dim=1) {

#load required functions
fileLoader(c('magnitude.R'))

if (dim==1)
	d = t(data)         # flip so all col. funcs are actually using rows of DATA
else
	d = data

n = dim(d)[2]

# when getting magnitude, you want to use the data AFTER it is scaled
# by the means
for(i in 1:n) {
  d[,i] = d[,i] - mean(d[,i],na.rm=T)
  mags  = magnitude(d[,i])
  mags[mags==0] = 1   # have to watch where magnitude is 0
  d[,i] = d[,i]/mags
}

if (dim==1)
	d = t(d) # flip it back

return(d)
}
