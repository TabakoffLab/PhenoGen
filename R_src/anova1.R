#ANOVA1 One-way analysis of variance (ANOVA).
#   ANOVA1 performs a one-way ANOVA for comparing the means of two or more
#   groups of data. It returns the p-value for the null hypothesis that the
#   means of the groups are equal.
#
#   P = ANOVA1(X,GROUP)
#   X is a vector, GROUP must be a vector of the same length.
#   X values corresponding to the same value of
#   GROUP are placed in the same group.
#
#   Group numbers should be integers greater than zero.
#
#   If na.rm = FALSE, then any NA values in X will result in an error, returning
#   NA.  If na.rm = TRUE (default), then any NA values will simply be ignored.
#
#   NA values in GROUP (after entries where X is NA are removed) are not allowed.
#

anova1 <- function(x,group,na.rm=TRUE) {


if(length(x) != length(group)) {
  print('X and GROUP must have the same length.')
  return(NA)
}


nans <- is.na(x)
if (any(nans) && na.rm == FALSE) {
  print('X has missing values, and na.rm = FALSE.')
  return(NA)
}

x <- x[!nans]
group <- group[!nans]

if (any(is.na(group))) {
  print('GROUP has missing values!')
  return(NA)
}

lx <- length(x)

# if (classic)
mu <- mean(x)
x <- x - mu                # center to improve accuracy
xr <- x

#   else
#      [xr,tieadj] <- tiedrank(x)
#   end
  
maxi <- max(group)
countx <- rep(0,maxi)
xm <- rep(NA,maxi)

for(j in 1:maxi) {
    # Get group sizes and means
    k <- which(group == j)
    lk <- length(k)
    countx[j] <- lk
    xm[j] <- mean(xr[k])       # column means
}


gm <- mean(xr)                         # grand mean
df1 <- length(xm) - 1                  # Column degrees of freedom
df2 <- lx - df1 - 1                    # Error degrees of freedom
RSS <- sum(countx * (xm - gm)*(xm-gm)) # Regression Sum of Squares

TSS <- sum((xr - gm)*(xr - gm))        # Total Sum of Squares
SSE <- TSS - RSS                       # Error Sum of Squares

if (df2 > 0)
   mse <- SSE/df2
else
   mse <- NaN
end

#if (classical)
if (SSE!=0) {
   F <- (RSS/df1) / mse
   p <- 1 - pf(F,df1,df2)     # Probability of F given equal means.
} else if (RSS==0) {                  # Constant Matrix case.
   F <- 0
   p <- 1
} else {                              # Perfect fit case.
   F <- Inf
   p <- 0
}
#else
#   F <- (12 * RSS) / (lx * (lx+1))
#   if (tieadj > 0)
#      F <- F / (1 - 2 * tieadj/(lx^3-lx))
#   end
#   p <- 1 - chi2cdf(F, df1)
#end

return(p)

#Table<-zeros(3,5)               #Formatting for ANOVA Table printout
#Table(:,1)<-[ RSS SSE TSS]'
#Table(:,2)<-[df1 df2 df1+df2]'
#Table(:,3)<-[ RSS/df1 mse Inf ]'
#Table(:,4)<-[ F Inf Inf ]'
#Table(:,5)<-[ p Inf Inf ]'
#
#colheads <- ['Source       ''         SS  ''          df '...
#            '       MS    ''          F  ''     Prob>F  ']
#if (~classical)
#   colheads(5,:) <- '     Chi-sq  '
#   colheads(6,:) <- '  Prob>Chi-sq'
#end
#rowheads <- ['Columns    ''Error      ''Total      ']
#if (grouped)
#   rowheads(1,:) <- 'Groups     '
#end


}
