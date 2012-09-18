# FDR - False Discovery Rate - Multiple comparison correction
#
# [H, CRITLEVEL,CUTOFF] = FDR(PVALUES, FDRF, METHOD)
# 
# Controls the false discovery rate FDRF, the expected 
# fraction of null hypotheses rejected mistakenly:
#
#           number of mistaken H0 rejections
#     FDRF = ----------------------------------
#             total number of rejections
#
# If all hypotheses are true than FDRF==ALPHAF.
# CRITLEVEL returns the critical significance level, i.e.
# CRITLEVEL_i = critical level if i number of tests to go
# H==1 if reject the null hypothesis
# CUTOFF = the first of PVALUES where PVALUE <= CRITLEVEL
#
# METHOD can be 'stepup' or 'dependent' (default)
#
# Reference: Am J Physiol Regulatory Integrative Comp Physiol
#            279:R1-R8, 2000
#            "Multiple comparisons: philosophies and 
#                 illustrations"
#               Douglas Curran-everett 
#            
#  based on Benjamini and Hochberg(1995) J Roy Stat Soc B 57:289:300 [stepup]
#       and Benjamini and Yekutieli(2001) Annals of Statistics
#
# See also MULTITEST

# Written by Sonia Leach 05/24/01, 3/26/03
# Edited by Laura Saba 09/02/10


fdr <- function(pvalues, fdrf, method='dependent') {

k <- length(pvalues)         # number of comparisons

if (method == 'dependent') fdrf <- fdrf/sum(1/(1:k))
else if (method != 'stepup') return(NA)

sortedpvalues <- rev(sort(pvalues))
spi<- rev(order(pvalues))

critlevel <- (fdrf*seq(k,1,-1))/k

cutoff <- which(sortedpvalues <= critlevel)

if (length(cutoff) > 0) {
	cutoff <- sortedpvalues[cutoff[1]]
} else {
#	print('Sorry, no true significant changes\n')
	cutoff <- 0
}

##HH = logical(zeros(k,1));
#####HH(spi(cutoff(1):end)) = logical(1);
##orderedcritlevel(spi) = critlevel;      

H <- (pvalues <= cutoff)

return(H)
}
