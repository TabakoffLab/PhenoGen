########################## fileLoader ################
# This function is automatically sourced at the beginning of each R session.
# It is an indirect way of sourcing functions, so that calling functions
# do not need to know what directory is used for R function.
# Instead, the directory is set in a global variable that is set up
# at the same time as the fileLoader code is sourced, when R is started.
# (This happens in .First function in Rprofile.site or .Rprofile file)
#
#  Function History
#     ?????????   Tzu Phang      Created 
#     3/24/2005   Diane Birks    Modified to use G_SrcDir var set in Rprofile,
#                                instead of hardcoding the directory
#
######################################################

fileLoader<-function(sourcefiles) {

   pathdirectory <- G_SrcDir
   sourcefiles <- paste(pathdirectory,sourcefiles,sep="")

   for(i in 1:length(sourcefiles)) {
      source(sourcefiles[i])
   }

}
