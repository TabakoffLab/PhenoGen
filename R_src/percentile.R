# Returns the value in the percentile-th percentile of the sorted data

percentile <- function(x, percentile, na.rm = TRUE) 
{
    if (mode(x) != "numeric") 
        stop("need numeric data")
    if (na.rm) 
        x <- x[!is.na(x)]
    else if (any(is.na(x))) 
        return(NA)
    n <- length(x)
    if (n == 0) 
        return(NA)
    if(percentile == 100) return(max(x))
    if(percentile == 0) return(min(x))
    half <- floor((n + 1)*percentile/100)
    if ((n%%2 == 1)||(percentile != 50)) {
        sort(x, partial = half)[half]
    }
    else {
        sum(sort(x, partial = c(half, half + 1))[c(half, half + 
            1)])/2
    }
}
