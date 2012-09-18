# WYSTEPDOWN Multiple comparison correction Westfall and Young Step down
#
# wystepdownsml <- function(data,classlabels,nonpara,numperms)
#
# data        nxm data matrix, has each item to be tested as ROWS
# classlabels length m vector of class identities (eg [1 1 2 2..])
#             for each column.  Must be integers greater than zero, should
#             be given in order.
# nonpara  boolean. 'parametric' or 'nonparametric' (default T)
#          for numgroups > 2, uses anova1 or kruskalwallis
#          for numgroups ==2, uses ttest2 or ranksum
# numperms number of permutations to use to estimate null distribution
#          (default 50)
#
# 
# Returns adjusted p-values using Westfall Young 
# setpdown procedure for multiple comparison correction (strong
# control of FWE).
# Idea is to use permutations to estimate null distribution,
# and correct p-values slightly for each successive hypothesis
# test by readjusting the percentile. Works if correlations
# among data for items tested.
#
# The procedure assumes that the p-values are monotone.
# 
# Graphs unadjusted vs adjusted p-values across the items
#
# Implemented as in "Statistical Methods for identifying differentially
#      expressed genes in replicated cDNA microarray experiments"
# by Dudoit et al, Stanford tech report#578 August 2000, page 14

# Transferred by Ben Elias, summer 03, corrected by Sonia Leach 9/03.

wystepdownsml <- function(data,classlabels,nonpara=T,numperms=50) {

if(is.vector(data)) 
  data<-matrix(data,ncol=length(data))

n<- dim(data)[1]
m<-dim(data)[2]


if (length(classlabels) != m) {
  print("Classlabels and data have incorrect dimensions.")
  return(NA)
}

if (numperms < 1) {
  print('Must specify non-zero number of perms')
  return(NA)
}

grps = max(classlabels)
if (grps < 2) {
  print('Must specify more than one group in 2nd argument')
  return(NA)
}

# Initialize storage
stat.b   <- matrix(rep(0,n*(numperms+1)),nrow=n)

unadj    <- rep(0,n)

# To be more space efficient, we make the outerloop 
# iterate over permutations, and the inner loop 
# iterate over items to be tested where the first
# column of stat.b is the REAL statistic

# 9/30/03 SML note: using p-values because
# R1 statistic is positive whereas t-stat
# is symmetric around zero so "as extreme"
# uses both +/- NUM to have same p-value 
# whereas R1 is centered around some positive 
# number so different values give same p-value.
# This section is the code from grpcompandperms.m
# in the matlab equivalent
print('permutation')
for(j in 1:(numperms+1)) {
  print(j)
  if (j==1) perm <- 1:m   # i.e. don't permute
  else perm <- sample(1:m,m)
#	print(perm)
  for(i in 1:n) {
   if (grps >  2) {
   	if (nonpara)
            p <- kruskal.test(data[i,],classlabels[perm])[[3]]
   	else 
            p <- anova1(data[i,], grouping)

   } else {
	Agroup <- which(classlabels[perm]==1)
	Bgroup <- which(classlabels[perm]==2)
	if (nonpara)
            p <- wilcox.test(data[i,Agroup],data[i,Bgroup])[[3]]
	else
            p<- t.test(data[i,Agroup],data[i,Bgroup],var.equal=T)[[3]]
   }
   stat.b[i,j] <- p
   if (j==1)
	unadj[i] <- p
  }   
}

# SML: Take off first column of stat.b==statReal
# since now is equal to unadj
permstats = stat.b
stat.b = stat.b[,2:(numperms+1)]

# Reorder the stats object based on order of real Stats
y = sort(abs(unadj))
order = order(abs(unadj))
order = rev(order) # SML make in descending order!!!!
stat.b = abs(stat.b[order,])

stat.b <- matrix(stat.b,nrow=n) # in case n==1,avoids errors.

# Rewrite stat.b(j,:) using step down procedure
# (starts from bottom (smallest statvalue)
# and overwrites the stat.b data structure)
if(n>1)
for (j in (n-1):1) {
  for(i in 1:numperms) {
    stat.b[j,i] = max(c(stat.b[j+1,i], stat.b[j,i]))
  }
}

# Get adjusted p-values as average number of times
# permuted statistic >= real statistic
# (actually, where permuted p-value < real p-value)

where<-matrix(rep(0,n*numperms),nrow=n)

for (i in 1:numperms) 
  where[,i] <- (stat.b[,i] < unadj[order])

# equiv to 
adj <- apply(where, 1, sum)/numperms
#adj <- rowSums(where)/numperms

if(n>1)
for (j in 2:n)
  adj[j]= max(c(adj[j], adj[j-1]))

# Have to undo sorting so p-values correspond to correct items
foo <- adj
for(i in 1:n)
  adj[order[i]] = foo[i]

return(adj,unadj,permstats)

}


#clf
#u = plot(sort(unadj), 'r.-')
#hold on
#a = plot(sort(adj), 'b.-')
#hold off
#ylabel('P-value')
#xlabel('Index of item, sorted by p-value')
#title('Comparison of Adjusted and Unadjusted P-values')
#legend([u a], str2mat('Unadjusted', 'Adjusted'))


 
	

