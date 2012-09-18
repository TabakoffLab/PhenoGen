
tzu.CharToNum <- function(vector) {

	for(i in 1:length(vector)){

		if(vector[i] == 'A'){
			vector[i] = -1
		}
		else if(vector[i] == 'M'){
			vector[i] = 0
		}
		else {
			vector[i] = 1
		}

	}

	return(vector)


}