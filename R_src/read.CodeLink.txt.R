
# read.CodeLink.txt will read in a series of filename.txt files 
# and extract the intensities and flags values
#
# Input: filename.txt
# output:
#	geneid		= CodeLink custom gene id
#	ncbi.id		= gene id from NCBI
#	type.flag	= flag
#	exp.value	= signal intensities values
#	norm.exp.value	= median normalized signal
#	gs.flag		= GeneSpring flag
#	codelink.flag	= CodeLink flag
#
# Usage: read.CodeLink.txt(filePath = '/Users/tzu/Documents/INIA/Modules/Statistical Analysis/BorisCodeLinkRat/', fileListFile = 'CodeLink.PhenoData.txt')



read.CodeLink.txt<-function(import.path, export.path, fileListFile, skip = 6) {
	
	current.wd = getwd()

	setwd(export.path)

	filenames = read.table(file = fileListFile,header=FALSE)

	setwd(import.path)

	print(filenames)

	numfiles <- nrow(filenames)
	print('number of file is')
	print(numfiles)

	Chip.name = geneid = ncbi.id = type.flag = exp.value = norm.exp.value = gs.flag = codelink.flag = spot.col = spot.row = bg.mean = c()


	for(i in 1:numfiles) {
		
		temp = c()

		print('filename is')
		print(filenames$V1[i])
		temp = read.delim(as.character(filenames$V1[i]), header = T, skip = skip, sep = '\t',colClasses = 'character')
		temp<-temp[do.call(order,temp[,9:10]),]

		Chip.name = c(Chip.name, filenames$V2[i])

		geneid = temp[,1]
		ncbi.id = temp[,2]
		type.flag = cbind(type.flag, temp[,3])
		exp.value = cbind(exp.value, temp[,5])
		norm.exp.value = cbind(norm.exp.value, temp[,6])
		gs.flag = cbind(gs.flag, temp[,7])
		codelink.flag = cbind(codelink.flag, temp[,8])
		spot.col = cbind(spot.col, temp[,9])
		spot.row = cbind(spot.row, temp[,10])
		bg.mean = cbind(bg.mean, temp[,13])

		print(c('Data', i, 'Loaded\n'))
		
	}


	setwd(current.wd)

	out <- list(geneid = geneid,ncbi.id = ncbi.id,type.flag = type.flag,exp.value=exp.value,norm.exp.value=norm.exp.value,gs.flag=gs.flag,codelink.flag=codelink.flag,bg.mean=bg.mean)
    return(out)



} ## END OF:read.CodeLink.txt