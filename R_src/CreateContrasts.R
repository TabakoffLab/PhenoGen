design.pairs <- function(levels) {
n <- length(levels)
design <- matrix(0,n,choose(n,2))
rownames(design) <- levels
colnames(design) <- 1:choose(n,2)
k <- 0
for (i in 1:(n-1))
for (j in (i+1):n) {
k <- k+1
design[i,k] <- 1
design[j,k] <- -1
colnames(design)[k] <- paste(levels[i],"-",levels[j],sep="")
}
design
}
