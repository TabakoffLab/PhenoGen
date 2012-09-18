tzu.CV <- function(data){
	
	CV = sd(data)/mean(data)
	
	return(CV)
}