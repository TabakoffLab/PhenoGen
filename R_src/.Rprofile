.First <- function() {
   #
   # Change the following two lines to customize for your environment
   #
   G_SrcDir <<- '/usr/share/tomcat/webapps/PhenoGen/R_src/'
   G_WriteLogFile <<- '/usr/share/tomcat/logs/WriteLogs.txt'

   # Global variables and setup for writeLog use
   # for new programs, create a new G_WriteLogXXX variable below
   # see writeLog.R for additional documentation
   G_WriteLogDefault <<- TRUE
   G_WriteLogAffyExport <<- TRUE
   G_WriteLogAffyFilter <<- TRUE
   G_WriteLogAffyGeneList <<- TRUE
   G_WriteLogAffyImport <<- TRUE
   G_WriteLogAffyMultTest <<- TRUE
   G_WriteLogAffyNorm <<- TRUE
   G_WriteLogAffyStats <<- TRUE
   G_WriteLogAnova <<- TRUE
   G_WriteLogCDNAExport <<- TRUE
   G_WriteLogCDNAFilter <<- TRUE
   G_WriteLogCDNAGeneList <<- TRUE
   G_WriteLogCDNAImport <<- TRUE
   G_WriteLogCDNAMultTest <<- TRUE
   G_WriteLogCDNANorm <<- TRUE
   G_WriteLogCDNAStats <<- TRUE
	
   G_WriteUserMsgFile <<- "UserMsgs.txt"      # File to check for user msgs to display on web
                                              #   (will be written to the working directory)


   G_WriteLogID <<- paste("PID",Sys.getpid(),sep="")
   source(paste(G_SrcDir,"/writelog.R",sep=""))
   source(paste(G_SrcDir,"fileLoader.R",sep=""))


}
