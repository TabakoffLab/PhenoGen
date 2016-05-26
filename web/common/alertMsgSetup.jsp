<%
	String additionalInfo = (session.getAttribute("additionalInfo") != null ? 
				(String) session.getAttribute("additionalInfo") : "");
	String msgID = (alertMsgExists ? (session.getAttribute("errorMsg") != null ? 
				(String) session.getAttribute("errorMsg") :
					(session.getAttribute("successMsg") != null ? 
						(String) session.getAttribute("successMsg") : "")) : "-99");

	
	/*log.debug("msgID = XXX" + msgID + "XXX"); 
	log.debug("successMsg = "+(String) session.getAttribute("successMsg"));
	log.debug("errorMsg = "+(String) session.getAttribute("errorMsg"));
	log.debug("additionalInfo = "+(String) session.getAttribute("additionalInfo"));
	*/
	
	alertMsg = (alertMsgExists && !msgID.equals("-99") ? myMessage.getMessage(msgID, pool) : "") +
		(!additionalInfo.equals("") ? "  " + additionalInfo : "");
	log.debug("msgID = " + msgID + ", alertMsg = xxx"+alertMsg + "xxx");
	if (loggedIn && !alertMsg.equals("")) {
		mySessionHandler.createSessionActivity(session.getId(), 
				(selectedExperiment != null ? selectedExperiment.getExp_id() : -99), 
				(selectedDataset != null ? selectedDataset.getDataset_id() : -99), 
				(selectedDatasetVersion != null ? selectedDatasetVersion.getVersion() : -99), 
				(selectedGeneList != null ? selectedGeneList.getGene_list_id() : -99), 
				"Got this error/success msg:  " + alertMsg.substring(0,Math.min(alertMsg.length(),1980)),
				pool);
	}
	//session.removeAttribute("successMsg");
	//session.removeAttribute("additionalInfo");
	//session.removeAttribute("errorMsg");
%>
