
############ Phenotype.ImportTxt.R ####################
# [Description]:
#
# This function imports a .txt file with phenotype information 
#
# [Usage]:
#
# Phenotype.ImportTxt(InputDataFile, Path, OutputDataFile, SummaryFile, GraphicFile, StrainNumberFile)
#
# [Arguments]:
#
# InputDataFile:	name of txt file with phenotype data
# Path:				location of original phenotype file
# OutputDataFile: 	name of Rdata file output by program
# SummaryFileExprs:	name of the txt file with summary data for the upload phenotype that match with expression data
# GraphicFileExprs:	name of the barchart displaying strain means and variance for strains that match with expression data
# StrainNumberExprs:name of txt file to which the number of strains that match with expression data
# SummaryFileQTL:	name of the txt file with summary data for the upload phenotype that match with QTL data
# GraphicFileQTL:	name of the barchart displaying strain means and variance for strains that match with QTL data
# StrainNumberQTL:	name of txt file to which the number of strains that match with QTL data
# Public:			true/false indicator for whether the data came from a public data set
#
# [Details]:
#
# [Value]:
# 
# DataObject: A simple class to store phenotype data
#
# [Author]:
#
# Laura Saba 
#
# [Date]:
#
# created: 06-30-06
# modified: 10-05-06  Changed strain abbreviations to official names
# modified: 08-06-07  Changed program to allow for experiments other than the preset strains
# modified: 08-21-07  Changed program to uniform input regardless of experiment
# modified:	08-19-09  Add summary and graphic code
# modified: 03-31-10  For public data sets, we now export summary information for strains with expression
#						data and strains with marker data
# modified: 04-25-11  Added group names for new LXS panel and HXB/BXH panel
#
# [Reference]:
#
#
# [Example]:
# 

Phenotype.ImportTxt <- function(InputDataFile, Path, OutputDataFile, SummaryFileExprs, GraphicFileExprs, StrainNumberExprs, SummaryFileQTL, GraphicFileQTL, StrainNumberQTL, Public){

	library(gplots)
	
	#############################
	# Changing directories
	#

	current.wd = getwd()
	setwd(Path)

	#############################
	# Importing phenotype data
	#

	phenotype<-read.table(file=InputDataFile,header=TRUE,sep="\t")
	phenotype<-phenotype[order(phenotype$grp.number),]

	setwd(current.wd)
	
	#############################
	# Calculating summary data for non-public data sets
	#
	
	if(!Public){
		numGroups <- sum(!is.na(phenotype$phenotype))
		cat(file = StrainNumberExprs,numGroups)
		cat(file = StrainNumberQTL,0)

		summary.data <- rbind(
		c("Number of Strains With Phenotype Data = ",numGroups),
		c("Mean = ", signif(mean(phenotype$phenotype,na.rm=TRUE),digits=3)),
		c("Median = ", median(phenotype$phenotype,na.rm=TRUE)),
		c("Standard Deviation of Strain Means = ",signif(sd(phenotype$phenotype,na.rm=TRUE),digits=3)),
		c("Standard Error of Strain Means = ",signif(sd(phenotype$phenotype,na.rm=TRUE)/sqrt(numGroups),digits=3)),
		c("Minimum = ", min(phenotype$phenotype,na.rm=TRUE)),
		c("Maximum = ", max(phenotype$phenotype,na.rm=TRUE)))
	
		write.table(summary.data,file=SummaryFileExprs,quote=FALSE,sep="\t",row.names=FALSE,col.names=FALSE)
	
		bitmap(file = GraphicFileExprs, type = 'png16m')
			par(las = 2)
			barplot(phenotype$phenotype[order(phenotype$phenotype)],names.arg=phenotype$grp.name[order(phenotype$phenotype)])
		dev.off()
	}
	
	############################
	#  Identify strains in expression data
	#
	
	inExprs <- c('08_BXH','1_HXB','10_BXH','10_HXB','11_BXH','12_BXH','13_BXH','13_HXB','15_HXB','17_HXB','18_HXB','2_HXB','20_HXB','23_HXB','25_HXB','26_HXB','27_HXB','29_HXB','3_HXB','31_HXB','4_HXB','5_BXH','6_BXH','7_HXB','8_BXH','9_BXH','BN-Lx','SHR-Lx','SHR/Ola','BXD1','BXD11','BXD12','BXD13','BXD14','BXD15','BXD16','BXD18','BXD19','BXD2','BXD21','BXD22','BXD23','BXD24','BXD27','BXD28','BXD29','BXD31','BXD32','BXD33','BXD34','BXD36','BXD38','BXD39','BXD40','BXD42','BXD5','BXD6','BXD8','BXD9','C57BL/6J','DBA/2J','129/svlmJ','129P3/J','A/J','AKR/J','Balb/cByJ','Balb/cJ','BTBR T+tf/J','C3H/HeJ','C57/BL6J','C58/J','CAST/EiJ','CBA/J','DBA/2J','FVB/NJ','KK/H1J','Molf/EiJ','NOD/LtJ','NZW/LacJ','PWD/PhJ','SJL/J',
	             'ILS','ILSXISS100','ILSXISS101','ILSXISS102','ILSXISS103','ILSXISS107','ILSXISS110','ILSXISS112','ILSXISS114','ILSXISS115','ILSXISS122','ILSXISS123','ILSXISS13','ILSXISS14','ILSXISS16','ILSXISS19','ILSXISS22',
	             'ILSXISS23','ILSXISS24','ILSXISS25','ILSXISS26','ILSXISS28','ILSXISS3','ILSXISS32','ILSXISS34','ILSXISS36','ILSXISS39','ILSXISS41','ILSXISS42','ILSXISS43','ILSXISS46','ILSXISS48','ILSXISS49','ILSXISS5','ILSXISS50',
	             'ILSXISS52','ILSXISS60','ILSXISS64','ILSXISS66','ILSXISS7','ILSXISS70','ILSXISS72','ILSXISS73','ILSXISS75','ILSXISS76','ILSXISS78','ILSXISS8','ILSXISS80','ILSXISS84','ILSXISS86','ILSXISS87','ILSXISS89','ILSXISS9',
	             'ILSXISS90','ILSXISS92','ILSXISS93','ILSXISS94','ILSXISS96','ILSXISS97','ILSXISS98','ILSXISS99','ISS',
	             'BN-Lx/CubPrin','BXH10/CubPrin','BXH11/CubPrin','BXH13/CubPrin','BXH6/CubPrin','BXH08/CubPrin','HXB1/IpcvPrin','HXB10/IpcvPrin','HXB13/IpcvPrin','HXB15/IpcvPrin','HXB17/IpcvPrin','HXB18/IpcvPrin','HXB2/IpcvPrin',
	             'HXB23/IpcvPrin','HXB25/IpcvPrin','HXB26/IpcvPrin','HXB27/IpcvPrin','HXB29/IpcvPrin','HXB3/IpcvPrin','HXB31/IpcvPrin','HXB4/IpcvPrin','HXB7/IpcvPrin','PD/CubPrin','SHR/OlaPrin','SHR/NCrlPrin','SHR-Lx/CubPrin','WKY/NCrlPrin')
	
	inQTL <- c('1_HXB','10_BXH','10_HXB','11_BXH','12_BXH','13_BXH','13_HXB','15_HXB','17_HXB','18_HXB','2_HXB','20_HXB','23_HXB','25_HXB','27_HXB','29_HXB','3_HXB','31_HXB','4_HXB','5_BXH','6_BXH','7_HXB','8_BXH','9_BXH','BN-Lx','SHR/Ola','12a_BXH','14_HXB','2_BXH','21_HXB','22_HXB','24_HXB','3_BXH','5_HXB','BXD1','BXD11','BXD12','BXD13','BXD14','BXD15','BXD16','BXD18','BXD19','BXD2','BXD21','BXD22','BXD23','BXD24','BXD27','BXD28','BXD29','BXD31','BXD32','BXD33','BXD34','BXD36','BXD38','BXD39','BXD40','BXD42','BXD5','BXD6','BXD8','BXD9','C57BL/6J','DBA/2J','BXD100','BXD20','BXD25','BXD30','BXD35','BXD37','BXD41','BXD43','BXD44','BXD45','BXD48','BXD49','BXD50','BXD51','BXD52','BXD53','BXD54','BXD55','BXD56','BXD59','BXD60','BXD61','BXD62','BXD63','BXD64','BXD65','BXD66','BXD67','BXD68','BXD69','BXD70','BXD71','BXD72','BXD73','BXD74','BXD75','BXD76','BXD77','BXD78','BXD79','BXD80','BXD81','BXD83','BXD84','BXD85','BXD86','BXD87','BXD88','BXD89','BXD90','BXD91','BXD92','BXD93','BXD94','BXD95','BXD96','BXD97','BXD98','BXD99', 
	           'ILS','ILSXISS100','ILSXISS101','ILSXISS102','ILSXISS103','ILSXISS107','ILSXISS110','ILSXISS112','ILSXISS114','ILSXISS115','ILSXISS122','ILSXISS123','ILSXISS13','ILSXISS14','ILSXISS16','ILSXISS19','ILSXISS22',
	           'ILSXISS23','ILSXISS24','ILSXISS25','ILSXISS26','ILSXISS28','ILSXISS3','ILSXISS32','ILSXISS34','ILSXISS36','ILSXISS39','ILSXISS41','ILSXISS42','ILSXISS43','ILSXISS46','ILSXISS48','ILSXISS49','ILSXISS5','ILSXISS50',
	           'ILSXISS52','ILSXISS60','ILSXISS64','ILSXISS66','ILSXISS7','ILSXISS70','ILSXISS72','ILSXISS73','ILSXISS75','ILSXISS76','ILSXISS78','ILSXISS8','ILSXISS80','ILSXISS84','ILSXISS86','ILSXISS87','ILSXISS89','ILSXISS9',
	           'ILSXISS90','ILSXISS92','ILSXISS93','ILSXISS94','ILSXISS96','ILSXISS97','ILSXISS98','ILSXISS99','ISS','ILSXISS10','ILSXISS35','ILSXISS51','ILSXISS56','ILSXISS62','ILSXISS68',
			   'BN-Lx/Cub','BN/HanKini','BN/Mav','BN/NHsdMcwi','BN/SsNHsd','BN/SsNSlc','BN/Ztm','BXH10/Cub','BXH11/Cub','BXH12/Cub','BXH12a/Cub','BXH13/Cub','BXH2/Cub','BXH3/Cub','BXH5/Cub','BXH6/Cub','BXH8/Cub','BXH9/Cub','HXB1/Ipcv',
	           'HXB10/Ipcv','HXB13/Ipcv','HXB14/Ipcv','HXB15/Ipcv','HXB17/Ipcv','HXB18/Ipcv','HXB2/Ipcv','HXB20/Ipcv','HXB21/Ipcv','HXB22/Ipcv','HXB23/Ipcv','HXB24/Ipcv','HXB25/Ipcv','HXB27/Ipcv','HXB29/Ipcv','HXB3/Ipcv','HXB31/Ipcv',
	           'HXB4/Ipcv','HXB5/Ipcv','HXB7/Ipcv','SHR-Lx/Cub','SHR/Izm','SHR/Kyo','SHR/molBbb','SHR/Ncruk','SHR/NCrl','SHR/NHsd','SHR/Npy','SHR/OlaIpcv','WKY/Bbb','WKY/Gcrc','WKY/Izm','WKY/Ncruk','WKY/NMna','WKY/Ztm')
	
	
	#############################
	# Calculating summary data for public data sets
	#
	
	if(Public){
		
		###  With Expression Data  ###
		exprs.phenotype <- phenotype[phenotype$grp.name %in% inExprs,]
		
		numGroups <- sum(!is.na(exprs.phenotype$phenotype))
		cat(file = StrainNumberExprs,numGroups)
		
		if (numGroups!=0){
			summary.data <- rbind(
			c("Number of Strains With Phenotype Data = ",numGroups),
			c("Mean = ", signif(mean(exprs.phenotype$phenotype,na.rm=TRUE),digits=3)),
			c("Median = ", median(exprs.phenotype$phenotype,na.rm=TRUE)),
			c("Standard Deviation of Strain Means = ",signif(sd(exprs.phenotype$phenotype,na.rm=TRUE),digits=3)),
			c("Standard Error of Strain Means = ",signif(sd(exprs.phenotype$phenotype,na.rm=TRUE)/sqrt(numGroups),digits=3)),
			c("Minimum = ", min(exprs.phenotype$phenotype,na.rm=TRUE)),
			c("Maximum = ", max(exprs.phenotype$phenotype,na.rm=TRUE)))
	
			write.table(summary.data,file=SummaryFileExprs,quote=FALSE,sep="\t",row.names=FALSE,col.names=FALSE)
	
			bitmap(file = GraphicFileExprs, type = 'png16m')
				par(las = 2)
				barplot(exprs.phenotype$phenotype[order(exprs.phenotype$phenotype)],names.arg=exprs.phenotype$grp.name[order(exprs.phenotype$phenotype)])
			dev.off()
			rm(summary.data)
		}
		###  With Marker Data  ###
		rm(numGroups)
		
		qtl.phenotype <- phenotype[phenotype$grp.name %in% inQTL,]
		
		numGroups <- sum(!is.na(qtl.phenotype$phenotype))
		cat(file = StrainNumberQTL,numGroups)
		
		if(numGroups!=0){
			summary.data <- rbind(
			c("Number of Strains With Phenotype Data = ",numGroups),
			c("Mean = ", signif(mean(qtl.phenotype$phenotype,na.rm=TRUE),digits=3)),
			c("Median = ", median(qtl.phenotype$phenotype,na.rm=TRUE)),
			c("Standard Deviation of Strain Means = ",signif(sd(qtl.phenotype$phenotype,na.rm=TRUE),digits=3)),
			c("Standard Error of Strain Means = ",signif(sd(qtl.phenotype$phenotype,na.rm=TRUE)/sqrt(numGroups),digits=3)),
			c("Minimum = ", min(qtl.phenotype$phenotype,na.rm=TRUE)),
			c("Maximum = ", max(qtl.phenotype$phenotype,na.rm=TRUE)))
	
			write.table(summary.data,file=SummaryFileQTL,quote=FALSE,sep="\t",row.names=FALSE,col.names=FALSE)
		
			bitmap(file = GraphicFileQTL, type = 'png16m')
				par(las = 2)
				barplot(qtl.phenotype$phenotype[order(qtl.phenotype$phenotype)],names.arg=qtl.phenotype$grp.name[order(qtl.phenotype$phenotype)])
			dev.off()
		}
	}
		
	
	save(phenotype, file = OutputDataFile, compress = T)



}  ## END OF: Phenotype.ImportTxt 