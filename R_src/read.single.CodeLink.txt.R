
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
# Usage: read.CodeLink.txt(filePath = '/Users/tzu/Documents/INIA/Modules/Statistical Analysis/BorisCodeLinkRat/', filename = 'T00274762_2005-6-1_ILAS2-2{1}.txt')



read.single.CodeLink.txt<-function(filePath, filename, skip = 6) {
	
	current.wd = getwd()

	setwd(filePath)


	Chip.name = geneid = ncbi.id = type.flag = exp.value = norm.exp.value = gs.flag = codelink.flag = spot.col = spot.row = bg.mean = c()
		
		temp = c()

		temp = read.delim(filename, header = T, skip = skip, sep = '\t',colClasses = 'character')

		geneid = temp[,1]
		ncbi.id = temp[,2]
		type.flag = temp[,3]
		exp.value = temp[,5]
		norm.exp.value = temp[,6]
		gs.flag = temp[,7]
		codelink.flag = temp[,8]
		spot.col = temp[,9]
		spot.row = temp[,10]
		bg.mean = temp[,13]


	setwd(current.wd)

	return(list(geneid=geneid,ncbi.id=ncbi.id,type.flag=type.flag,exp.value=exp.value,norm.exp.value=norm.exp.value,gs.flag=gs.flag,codelink.flag=codelink.flag,spot.col=spot.col,spot.row=spot.row,bg.mean=bg.mean))

} ## END OF:read.CodeLink.txt