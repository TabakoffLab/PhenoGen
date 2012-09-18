########################## QTL.data.prep.R ################
#
# This function imports genotype and phenotype information to
#	create an csv file for import using read.cross 
#
# Parms:
#	InputGenoFile	= name and location of genotype Rdata file
#	InputPhenoFile	= name and location of phenotype Rdata file
#   OutputFile	= name of output Rdata file containing LOD info for each marker
#
# Returns:
#    nothing
#
# Writes out:
#	csv file (OutputFile) containing genotype and phenotype data
#		in the CSV format for read.cross
#
# Sample Call:
#
# Function History
#	11/9/09		Laura Saba	Created
#	12/9/10		Laura Saba	Corrected error in code for identifying unique SDP when the first strain is missing
#
####################################################


QTL.data.prep <- function(InputGenoFile, InputPhenoFile, OutputFile){
	
	#################
	##  FUNCTIONS  ##
	#################
	
	sw2numeric <- function(x) {
		pattern <- "^[\t]*-*[0-9]*[.]*[0-9]*[\t]*$"
		n <- sum(!is.na(x))
		if(length(grep(pattern,as.character(x[!is.na(x)])))==n) return(as.numeric(as.character(x)))
		else return(x)
		}
		
	library(qtl)
		
	load(InputPhenoFile)
	load(InputGenoFile)
	
	################################################################
	##  Reducing genotype data to only those with phenotype data  ##
	################################################################
	
	##  cleaning strain names
	pheno.strains <- as.character(phenotype$grp.name)
	
	##  matching strains in genotype and phenotype data
	matched.strains <- pheno.strains[pheno.strains %in% colnames(just.geno)]
	
	cat(paste(length(matched.strains),"strains from phenotype data were also in genotype file"))
	
	##  reduce genotype file
	genotype <- just.geno[,matched.strains]
	
	##  stop program if all of the strains in the phenotype file are not in the genotype data
	#if(length(pheno.strains)!=ncol(genotype)) stop("Not all strains in phenotype file have genotype data")
	
	##  eliminate SNPs with more than 5% missing information
	genotype2 <- genotype[(rowSums(genotype == 9)/ncol(genotype) < 0.05),]
	positions <- positions[(rowSums(genotype == 9)/ncol(genotype) < 0.05),]
	
	##  eliminate SNPs with no variation
	genotype3 <- genotype2[(rowSums(genotype2 == 1)!=0),]
	positions <- positions[(rowSums(genotype2 == 1)!=0),]
	
	genotype4 <- genotype3[(rowSums(genotype3 == 3)!=0),]
	positions <- positions[(rowSums(genotype3 == 3)!=0),]
	

	############################################################
	##  Creating an object of class 'cross' with all markers  ##
	############################################################

	## phenotype data
	
	pheno <- as.matrix(phenotype[phenotype$grp.name %in% matched.strains,"phenotype"])
	colnames(pheno) <- "phenotype"
	pheno <- data.frame(lapply(as.data.frame(pheno),sw2numeric))
	
	##  genotype data
	
	allgeno <- as.matrix(t(genotype4))
	chr <- as.vector(positions$chr)
	mnames <- as.vector(rownames(positions))
	map <- as.table(positions$bp_pos)
	rownames(map) <- mnames
	map.included <- TRUE
	
	uchr <- unique(chr)
	n.chr <- length(uchr)
	geno <- vector("list",n.chr)
	names(geno) <- uchr
	min.mar <-1
	
	# create map
	for(i in 1:n.chr){
		temp.map <- map[chr==uchr[i]]
		names(temp.map) <- mnames[chr==uchr[i]]
		
		data <- allgeno[,min.mar:(length(temp.map) + min.mar-1),drop=FALSE]
		min.mar <- min.mar + length(temp.map)
		colnames(data) <- names(temp.map)
		
		geno[[i]] <- list(data=data, map=temp.map)
		if(uchr[i] == "X") class(geno[[i]]) <- "A"
		else class(geno[[i]]) <- "A"
		}
	
	
	##  create cross
	
	orig.cross <- list(geno = geno,pheno = pheno)
	class(orig.cross) <- c("f2", "cross")
	orig.cross$pheno <- as.data.frame(orig.cross$pheno)
	
	###########################################################
	##  Creating an object of class 'cross' with unique SDP  ##
	###########################################################

	## reduce original genotype information to only unique SDP
	
	## need to create an "anchor" strain, so that the SDP 111333 is equivalent to 333111
	
	baseCall <- genotype4[,1]
	i=1
	while(sum(baseCall==9)>0){
		i = i+1
		print(sum(baseCall==9))
		baseCall[baseCall==9] = genotype4[baseCall==9,i]
		}
		
	recodeGeno = genotype4
	recodeGeno[genotype4==baseCall] <- 1 
	recodeGeno[genotype4==abs(baseCall-4)] <- 3
	
	duplicates <- duplicated(recodeGeno) 
	reduced.genotype <- recodeGeno[!duplicates,]
	reduced.positions <- positions[!duplicates,]
		
	##  genotype data
	
	r.allgeno <- as.matrix(t(reduced.genotype))
	r.chr <- as.vector(reduced.positions$chr)
	r.mnames <- as.vector(rownames(reduced.positions))
	r.map <- as.table(reduced.positions$bp_pos)
	rownames(r.map) <- r.mnames
	map.included <- TRUE
	
	r.uchr <- unique(r.chr)
	r.n.chr <- length(r.uchr)
	r.geno <- vector("list",r.n.chr)
	names(r.geno) <- r.uchr
	min.mar <-1
	
	# create map
	for(i in 1:r.n.chr){
		temp.map <- r.map[r.chr==r.uchr[i]]
		names(temp.map) <- r.mnames[r.chr==r.uchr[i]]
		
		data <- r.allgeno[,min.mar:(length(temp.map) + min.mar-1),drop=FALSE]
		min.mar <- min.mar + length(temp.map)
		colnames(data) <- names(temp.map)
		
		r.geno[[i]] <- list(data=data, map=temp.map)
		if(r.uchr[i] == "X") class(r.geno[[i]]) <- "A"
		else class(r.geno[[i]]) <- "A"
		}
	
	##  create cross
	reduced.cross <- list(geno = r.geno,pheno = pheno)
	class(reduced.cross) <- c("f2", "cross")
	reduced.cross$pheno <- as.data.frame(reduced.cross$pheno)
	
	###############################################################################
	##  Creating an object of class 'cross' with unique SDP for each chromosome  ##
	###############################################################################

	## reduce original genotype information to only unique SDP
	
	ordered.u.chr <- positions$chr[!duplicated(positions$chr)]
	for(i in 1:n.chr){
		if(i==1) byChr.duplicates <- duplicated(recodeGeno[positions$chr==ordered.u.chr[i],])
		else byChr.duplicates <- c(byChr.duplicates,duplicated(recodeGeno[positions$chr==ordered.u.chr[i],]))
		}
		
	reducedChr.genotype <- recodeGeno[!byChr.duplicates,]
	reducedChr.positions <- positions[!byChr.duplicates,]
		
	##  genotype data
	
	rChr.allgeno <- as.matrix(t(reducedChr.genotype))
	rChr.chr <- as.vector(reducedChr.positions$chr)
	rChr.mnames <- as.vector(rownames(reducedChr.positions))
	rChr.map <- as.table(reducedChr.positions$bp_pos)
	rownames(rChr.map) <- rChr.mnames
	map.included <- TRUE
	
	rChr.uchr <- unique(rChr.chr)
	rChr.n.chr <- length(rChr.uchr)
	rChr.geno <- vector("list",rChr.n.chr)
	names(rChr.geno) <- rChr.uchr
	min.mar <-1
	
	# create map
	for(i in 1:rChr.n.chr){
		temp.map <- rChr.map[rChr.chr==rChr.uchr[i]]
		names(temp.map) <- rChr.mnames[rChr.chr==rChr.uchr[i]]
		
		data <- rChr.allgeno[,min.mar:(length(temp.map) + min.mar-1),drop=FALSE]
		min.mar <- min.mar + length(temp.map)
		colnames(data) <- names(temp.map)
		
		rChr.geno[[i]] <- list(data=data, map=temp.map)
		if(rChr.uchr[i] == "X") class(rChr.geno[[i]]) <- "A"
		else class(rChr.geno[[i]]) <- "A"
		}
	
	##  create cross
	reducedChr.cross <- list(geno = rChr.geno,pheno = pheno)
	class(reducedChr.cross) <- c("f2", "cross")
	reducedChr.cross$pheno <- as.data.frame(reducedChr.cross$pheno)

	###############################
	##  Create weighting vector  ##
	###############################

	weights <- c()
	if(!is.null(phenotype$stddev)) weights = 1 / (phenotype$stddev*phenotype$stddev)
	
	###################################################################
	##  Creating a genotype file with starting and stopping markers  ##
	###################################################################

	withChr <- cbind(SNP=rownames(recodeGeno),chr=as.character(positions$chr), recodeGeno)
		
	SDP <- withChr[!duplicated(withChr[,c(colnames(withChr)[-1])]),]
	SDP <- cbind(SDP = c(1:nrow(SDP)),SDP)
	
	with.SDP <- merge(SDP,withChr,by=colnames(withChr)[-1])
	rownames(with.SDP) <- with.SDP$SNP.y
	with.SDP <- merge(with.SDP,positions,by=0)
	rownames(with.SDP) <- with.SDP$Row.names
	with.SDP <- with.SDP[rownames(positions),]
	with.SDP <- with.SDP[,c("SNP.y","chr.x","SDP","bp_pos","num.chr")]
	colnames(with.SDP) <- c("SNP","chr","SDP","bp_pos","num.chr")

	min.loc <- aggregate(data.frame(with.SDP$bp_pos),by=list(with.SDP$SDP),min)
	max.loc <- aggregate(data.frame(with.SDP$bp_pos),by=list(with.SDP$SDP),max)
	
	colnames(min.loc) <- c("SDP","min.bp")
	colnames(max.loc) <- c("SDP","max.bp")
	
	with.SDP2 <- merge(min.loc,with.SDP,by.y=c("SDP","bp_pos"),by.x=c("SDP","min.bp"))
	with.SDP3 <- merge(max.loc,with.SDP,by.y=c("SDP","bp_pos"),by.x=c("SDP","max.bp"))
		
	by.SDP <- merge(with.SDP2,with.SDP3,by="SDP")
	colnames(by.SDP)[colnames(by.SDP)=="SNP.x"] = "min.SNP"
	colnames(by.SDP)[colnames(by.SDP)=="SNP.y"] = "max.SNP"
	colnames(by.SDP)[colnames(by.SDP)=="chr.x"] = "chr"
	colnames(by.SDP)[colnames(by.SDP)=="num.chr.x"] = "num.chr"
	
	by.SDP <- by.SDP[order(by.SDP$num.chr,by.SDP$min.bp),c("SDP","min.SNP","max.SNP","chr","num.chr","min.bp","max.bp")]
	
	##########################
	##  Save to Rdata file  ##
	##########################
	save(orig.cross,reduced.cross,reducedChr.cross,weights,by.SDP,file = OutputFile)

	
	}