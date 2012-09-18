<%
				log.debug("in rWarning.jsp");
				additionalInfo = "<BR>" + rExceptionErrorMsg + "<BR>";
				if (!rExceptionErrorMsg.equals("")) {
					rErrorMsg = new String[1];
					rErrorMsg[0] = rExceptionErrorMsg;
				}
                                //Warning - "Warning in R function"
                                session.setAttribute("rErrorMsg", rErrorMsg);
                                session.setAttribute("additionalInfo", additionalInfo);
                                session.setAttribute("successMsg", "R-003");
                                response.sendRedirect(commonDir + "successMsg.jsp");

%>
