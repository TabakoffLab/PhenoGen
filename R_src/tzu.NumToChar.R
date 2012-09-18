
tzu.NumToChar <- function(vector) {

	for(i in 1:length(vector)){

		if(vector[i] == -1){
			vector[i] = 'A'
		}
		else if(vector[i] == 0){
			vector[i] = 'M'
		}
		else {
			vector[i] = 'P'
		}

	}

	return(vector)


}