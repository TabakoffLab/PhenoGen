##############  check.TwoWayAnova.Parameterization.R  ################
#
#  This function is used to determine if 2-way ANOVA is overparameterized  
#
#  Parms:
#    	FactorFile 	= name in file with factors for two-way ANOVA	
#    	pvalue	= which pvalue is of interest 
#             		"Model" -> overall model p-value (model with both main effects and an interaction effect)
#             		"Factor1" -> significance of Factor1 (model without an interaction effect)
#		  		"Factor2" -> significance of Factor2 (model without an interaction effect)
#		  		"Interaction" -> significance of interaction effect (model with both main effects and an interaction effect)
#	OutFile 	= name of txt file to output result
#
# Writes out:
#	text file (OutFile) containing "Warning: Overparameterized Model" or "Satisfactory Model"
#
# Sample Call:
#    check.TwoWayAnova.Parameterization(FactorFile = 'TwoWayFactorFile.txt', pvalue = "Model", OutFile="CheckFile.txt")
#
#  Function History
#	1/2/07	Laura Saba	Created
#	7/31/07	Laura Saba	Updated code on how to handle numeric phenotypes with only two values
#
######################################################################

check.TwoWayAnova.Parameterization <- function(FactorFile,pvalue,OutFile){

	### Activate Library
	library(corpcor)

	### Initiate Text
	text <- "Satisfactory Model"

	###  Read in Factor File
	pheno <- read.table(file=FactorFile,sep="\t",header=TRUE,row.names=1)
	x1 <- pheno[,1]
	x2 <- pheno[,2]


	########################################################################
	#  Reformatting categorical factors so that it is a 0/1 indicator      #
	#    that is ordered like the original factor.  If there is more than  #
	#    two categories, the matrix will have multiple columns             #
	########################################################################

	if (is.numeric(x1)!=TRUE){
		unique1<-unique(x1)   #ordered unique levels to factor 1
		new1<-matrix(0,nc=length(unique1)-1,nr=length(x1))
		for(j in 1:(length(unique1)-1)){
			for(i in 1:length(x1)){
				if(x1[i]==unique1[j]) new1[i,j]<-1
			}
		}
	}

	if (is.numeric(x2)!=TRUE){
		unique2<-unique(x2)   #ordered unique levels to factor 1
		new2<-matrix(0,nc=length(unique2)-1,nr=length(x2))
		for(j in 1:(length(unique2)-1)){
			for(i in 1:length(x2)){
				if(x2[i]==unique2[j]) new2[i,j]<-1
			}
		}
	}

	##############################################################
	#  Reformatting numeric factors into a matrix and adjusting  #
        #    values to 0 and 1 when only two levels are present      #
	##############################################################

	if (is.numeric(x1)){
		if(length(unique(x1))==2) new1<-as.matrix((x1-unique(x1)[2])/(unique(x1)[1]-unique(x1)[2]))
		if(length(unique(x1))!=2) new1<-as.matrix(x1)}
	if (is.numeric(x2)){
		if(length(unique(x2))==2) new2<-as.matrix((x2-unique(x2)[2])/(unique(x2)[1]-unique(x2)[2]))
		if(length(unique(x2))!=2) new2<-as.matrix(x2)}

	##########################################################################
	#  Creating interaction variables.  If multiple columns in either x1 or  #
	#    x2 then the interaction matrix (new3) will have multiple columns    #
	##########################################################################

	new3<-matrix(0,nr=nrow(new1),nc=(ncol(new1)*ncol(new2)))

	for (i in 1:ncol(new1)){
		for (j in 1:ncol(new2)){
			new3[,((i-1)*ncol(new2)+j)]<-new1[,i]*new2[,j]
		}
	}

	#################################################################################
	#  When the pvalue of interest is Factor1 or Factor2 then if the rank of the    #
	#    matrix with both factors is less than the number of columns (less than     #
	#    full rank) the model is overparameterized                                  #
	#################################################################################


	if(pvalue=="Factor1" || pvalue=="Factor2"){
		new.matrix<-cbind(rep(1,nrow(new1)),new1,new2)
		if (rank.condition(new.matrix)$rank<ncol(new.matrix)) text<-"Warning: Overparameterized Model"
	}

	#################################################################################
	#  When the pvalue of interest is 'Model' or 'Interaction' then if the rank of  #
	#    the matrix with both factors and the interactions is less than the number  #
        #    of columns (less than full rank) the model is overparameterized            #                      
	#################################################################################

	if(pvalue=="Model" || pvalue=="Interaction"){
		new.matrix<-cbind(rep(1,nrow(new1)),new1,new2,new3)
		if (rank.condition(new.matrix)$rank<ncol(new.matrix)) text<-"Warning: Overparameterized Model"
	}

	write.table(text,file=OutFile,quote=FALSE,row.names=FALSE,col.names=FALSE)

}   ####  END

