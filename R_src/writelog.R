########################## writelog ################
#
# Use this function rather than cat for debugging code and/or
#    sending msgs back to the user on the website.
#
# Writelog lines can be left in the code, but the 
#   output can be turned on or off, and directed to the console
#   or a file.
# To send a msg to the user, add the parm user=TRUE.
#   Use the default lvl (4) for warnings or informational msgs,
#   use a level > 4 (e.g. 8) to indicate that program execution
#   was unsuccessful.
#
# The G_... values are set through use of global variables 
#   which are set by  a .First function in an .Rprofile file
#   in the R startup directory or your home directory
#   (or Rprofile.site in the $R_HOME/etc/ folder)  as follows: 
#     .First <- function() {
#        G_WriteLogDefault <<- FALSE            # TRUE to turn on output
#        G_WriteLogXXX <<-  FALSE               # TRUE to turn on output for this program
#        G_WriteLogFile <<- "MyDebugLog.txt"    # direct to a file
#        #G_WriteLogFile <<- ""                 # or direct to console                  
#        source("your/path/here/writelog.R")
#     }
# The global variables can also be changed dynamically from the
#    R command line, as desired.
#
# To use writelog in your program always include flag=G_WriteLogXXX on each call, 
# where XXX is the global variable set for this program (e.g. G_WriteLogAffyNorm).  
# This allows logging to be turned on/off for individual programs in the event 
# that we need to track problems in production.  Please include a begin and end
# writelog statement in each program (that includes the name of the program), 
# as follows:
#
# myfunction <- function(......) {
#    logflag=G_WriteLogXXX
#    write function name and parm values to log
#    writelog(flag=logflag,'BEGIN',deparse(sys.call(0)))
#    .......  (function code here)
#    writelog(flag=logflag,'END')
# }
#
# For new programs, have the web admin add G_WriteLogXXX to the .Rprofile .First function
#
# To force a message (eg for a warning or error msg), use flag=TRUE. In this case
#    the message will be written to the G_WriteLogFile regardless of the value of G_WriteLogXXX. 
# 
# Note:  you do not need to add "\n" to the end of your log strings, as it will be added 
#        automatically. If you need to override this, add nl="" to the function call.
#
# 
#  Function History
#     3/21/2005   Diane Birks    Created
#
####################################################

writelog<-function(..., flag=G_WriteLogDefault,user=FALSE,lvl=4,nl='\n'){

   if (flag || user ) {    # flag TRUE indicates to write output to log file
                           # user TRUE indicates to write msg to a file that the java web code 
                           #    will check; any text in the file will be displayed to the user;
                           #    in this case we always write to log file also
      userlvl = ''

      if (user) {
         cat(lvl,"|",... , nl,file=G_WriteUserMsgFile,append=TRUE)
         userlvl = paste(' Usermsg, lvl=',lvl,":")          # set up info for log msg
      }

      cat(format(Sys.time(),"%Y/%m/%d | %H:%M:%S |"), G_WriteLogID, "|",userlvl, ... , nl,file=G_WriteLogFile,append=TRUE)
	
   }

}
