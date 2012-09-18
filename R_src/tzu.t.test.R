
tzu.t.test<-function(data, agroup, bgroup, na.rm = TRUE) {

	##########################
	# If missing value exist
	# and na.rm is FALSE
	# halt the function

	nans = is.na(data)
	if(any(nans) && na.rm == FALSE){
		print('data has missing values, and na.rm = FALSE.')
		return(1)
	}

	#########################
	# If all values are missing
	# halt the function


	if(any(nans)){
		#print('Some values are missing.')
		return(1)
	}
	

	#########################
	# Transfer the non-missing 
	# values to a new variable
	
	data = data[!nans]

	mean.group1 = mean(data[agroup])
      mean.group2 = mean(data[bgroup])

	if (var(data[agroup])==0) data[agroup][1]<-data[agroup][1]+0.000001
	if (var(data[bgroup])==0) data[bgroup][1]<-data[bgroup][1]+0.000001
		
	p = t.test(data[agroup], data[bgroup], var.equal = T)[[3]]

	return(c(mean.group1,mean.group2,p))

}
