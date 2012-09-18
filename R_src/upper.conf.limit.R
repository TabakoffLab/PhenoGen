upper.conf.limit <- function(data){
	Limit = 2*sd(data)+mean(data)
	return(Limit)
}