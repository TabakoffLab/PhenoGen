<%
				log.debug("in rError.jsp");
                                additionalInfo = "The following message may provide further information:<BR>";
				if (!rExceptionErrorMsg.equals("")) {
                                        additionalInfo = additionalInfo + rExceptionErrorMsg + "<BR>";
					rErrorMsg = new String[1];
					rErrorMsg[0] = rExceptionErrorMsg;
				} else {
                                	for (int k=0; k<rErrorMsg.length; k++) {
                                        	additionalInfo = additionalInfo + rErrorMsg[k] + "<BR>";
                                        	log.debug("rErrorMsg = " + rErrorMsg[k]);
                                	}
				}
                                //Error - "Error in R function"
                                session.setAttribute("rErrorMsg", rErrorMsg);
                                session.setAttribute("additionalInfo", additionalInfo);
                                session.setAttribute("errorMsg", "R-001");
                                response.sendRedirect(commonDir + "errorMsg.jsp");

%>

