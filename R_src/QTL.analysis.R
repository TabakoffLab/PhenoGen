########################## QTL.analysis.R ################
#
# This function execute an QTL analysis from user phenotype data
#	and our marker data for either BXD/Inbred mice/HXB/BXH 
#
# Parms:
#	InputFile	= name of input Rdata file created by QTL.data.prep.R with both genotype and phenotype information
#	method 		= type of QTL method to execute (to be implemented later)
#					"em" -> EM algorithm
#					"imp" -> Imputation
#					"hk" -> Haley-Knott regression
#					"mr" -> marker regression
#	weight		= weight analysis based on variance (T/F)
#	n.perm		= number of permutation to use for calculating p-value (0 to 1000000; 0 indicates that empirical pvalues are not calculated)
#   OutputFile	= name of output Rdata file containing LOD info for each marker
#   OutputTXTFile	= name of output txt file containing LOD info for each marker
#   GraphicFile = name of LOD plot
#
# Returns:
#    nothing
#
# Writes out:
#	rdata file (OutputFile) containing 
#	text file (OutputTXTFile) containing
#	png file (GraphicFile) containing
#
# Sample Call:
#
#
#  Function History
#	11/9/09		Laura Saba	Created
#
####################################################

QTL.analysis <- function(InputFile,method="mr",weight,n.perm,OutputFile,OutputTXTFile,GraphicFile){
	
	####################
	##  Housekeeping  ##
	####################
	
	## libraries needed
	library(qtl)
	
	## load data
	load(InputFile)
	
	## local functions
	effect.size <- function(x,phenotype){
		genotype <- factor(x, levels = c(1,3))
		y = summary(lm(phenotype ~ genotype,weights = weights))$coefficients[2,3] * sqrt((1/table(genotype)[1]) + (1/		table(genotype)[2]))
		return(y)
		}
		
	############################################
	##  Calculate LOD scores and effect sizes ##
	############################################
	
	if(!weight) weights = NULL 
	
	## calculate LOD scores
	results <- scanone(orig.cross,method = method,weights = weights)
	resultsChr <- scanone(reducedChr.cross,method = method,weights = weights)
	
	## calculate effect sizes
	pheno <- as.numeric(unlist(orig.cross$pheno))
	effects <- c()
	for(i in 1:nchr(orig.cross)){
		genotype <- unlist(orig.cross$geno[[i]]$data)
		out <- apply(genotype,2,effect.size,phenotype=pheno)
		effects <- c(effects,out)
		}

	
	###################################
	##  Calculate empirical p-value  ##
	###################################
	
	perms=NULL
	if(n.perm>0) {
		perms <- scanone(reduced.cross,method = method,n.perm = n.perm,verbose=FALSE,weights = weights)
		p001 = quantile(perms,0.999)
		p05 = quantile(perms,0.95)
		p63 = quantile(perms,0.37)
		}
		
	#######################
	##  Create LOD plot  ##
	#######################
	
	##  calculate upper bound for LOD plot
	maxLOD = max(results)$lod	
	if(n.perm>0) upper.bound = max(maxLOD,p001) + 1
	else upper.bound = maxLOD + 1
	
	##  calculate plot positions for the end of each chromosome
	chr.pos <- c(0)
	for(i in 1:nchr(orig.cross)){
		end.pos <- max(orig.cross$geno[[i]]$map) - min(orig.cross$geno[[i]]$map) + 12.5 + chr.pos[i]
		chr.pos <- c(chr.pos,end.pos)
		}
		
	## export graphic to jpeg file
	jpeg(filename = GraphicFile, width=1500, height=480)
		plot(results,ylim=c(0,upper.bound))
		#Lines to delimit chromosomes
		abline(v=chr.pos,col="grey")
		
		if(n.perm>0){
			#Line for p=0.001
			abline(h=p001,col="red")
			text(0,p001,"p = 0.001 (highly significant)",adj=c(-0.05,-0.05),cex=0.80,col="red")
			#Line for p=0.05
			abline(h=p05,col="green")
			text(0,p05,"p = 0.05 (significant)",adj=c(-0.05,-0.05),cex=0.80,col="green")
			#Line for p=0.10
			abline(h=p63,col="blue")
			text(0,p63,"p = 0.63 (suggestive)",adj=c(-0.05,-0.05),cex=0.80,col="blue")
		}
	dev.off()	
	
	########################################
	##  Create TXT file with all results  ##
	########################################
	
	if(n.perm>0) p.values <- round(sapply(results$lod,function(x) sum(x<round(perms,8))/n.perm),3)
	else p.values <- rep("undetermined",nrow(results))
	
	output <- cbind(marker.name = rownames(results),as.data.frame(results)[,1:2],LOD = round(results$lod,2),LRS = round(results$lod*2*log(10),2),p.value = p.values,effect.size = round(effects,3))
	
	write.table(output,file = OutputTXTFile,sep="\t",quote = FALSE,row.names=FALSE)
	
	save(orig.cross, reduced.cross, reducedChr.cross, weights, method, by.SDP, results, resultsChr, perms, output,file = OutputFile)
	
	
	}	