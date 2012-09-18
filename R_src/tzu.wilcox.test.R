
tzu.wilcox.test<-function(data, grouping, na.rm = TRUE) {

	
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


	if(all(nans)){
		print('All values are missing.')
		return(1)
	}
	

	#########################
	# Transfer the non-missing 
	# values to a new variable
	
	data = data[!nans]

	testData<-data.frame(
	  y = data[grouping!=0],
	  x = factor(grouping[grouping!=0]))

	if (max(data[grouping!=0])-min(data[grouping!=0])==0) p=1
	  else p = pvalue(wilcox_test(y ~ x, data = testData, distribution="exact"))
	mean.group1 = mean(data[grouping==1])
      mean.group2 = mean(data[grouping==2])

	return(c(mean.group1,mean.group2,p))

}
