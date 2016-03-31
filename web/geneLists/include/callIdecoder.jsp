<%--
 *  Author: Cheryl Hornbaker
 *  Created: Nov, 2008
 *  Description:  This file calls iDecoder for a list of targets.
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%
	log.info("in callIdecoder.jsp. user = " + user);
	noIDecoderList = new ArrayList();
	String[] targets = null;

	if (selectedGeneList.getNumber_of_genes() > 200) {
		log.debug("trying to do annotation on list with more than 200 genes");
		//Error - "Cannot do annotation on list with more than 200 genes"
		mySessionHandler.createGeneListActivity("Running tools with a gene list containing more than 200 genes", pool);
		//session.setAttribute("successMsg", "GLT-014");
			
		targets = new String[] {
			"Gene Symbol", 
			// for Location tool
			"Location", 
			// for oPOSSUM tool
        		"RefSeq RNA ID"
		};
		myIDecoderClient.setNum_iterations(0);
	} else {
		if (selectedGeneList.getGenes().length == 0) {
			//Error - "No genes"
			session.setAttribute("errorMsg", "GL-004");
                	response.sendRedirect(commonDir + "errorMsg.jsp");
        	} else {
			targets = new String[] {
				"Affymetrix ID", 
				"CodeLink ID", 
				"Entrez Gene ID", 
				"Ensembl ID",
				"FlyBase ID", 
				"Gene Symbol", 
				// This is not included because it returns identifiers
				// from other species -- so this is done separately in homologs.jsp 
				//"Homologene ID",
				"Location", 
				"MGI ID",
				"RefSeq RNA ID", 
				"RefSeq Protein ID", 
				"RGD ID", 
				"SwissProt ID", 
				"SwissProt Name", 
			};
		}
	}

	try {
		log.debug("calling iDecoderClient");
		iDecoderSet = myIDecoderClient.getIdentifiersByInputIDAndTarget(selectedGeneList.getGene_list_id(), targets, pool);
		//log.debug("iDecoderSet = "); myDebugger.print(iDecoderSet);
		if(iDecoderSet.size()>0){
			Iterator itr = iDecoderSet.iterator();
			ArrayList<Identifier> altDecoderList=new ArrayList<Identifier>();
			while (itr.hasNext()) {
				Identifier thisIdentifier = (Identifier) itr.next();
				if (thisIdentifier.getRelatedIdentifiers().size() == 0) {
					Set tmp=myIDecoderClient.getIdentifiersByInputID(thisIdentifier.getIdentifier(),selectedGeneList.getOrganism(),targets, pool);
					Iterator tmpItr=tmp.iterator();
					while (tmpItr.hasNext()){
						Identifier thisId = (Identifier) tmpItr.next();
						if (thisId.getRelatedIdentifiers().size() != 0) {
							//thisId.setLowerCaseIdentifier();
							altDecoderList.add(thisId);
						}
					}
					noIDecoderList.add(thisIdentifier.getIdentifier());
				}
			}
			for (int i=0; i<noIDecoderList.size(); i++) {
				iDecoderSet.remove(new Identifier((String) noIDecoderList.get(i)));
			}
			for (int i=0; i<altDecoderList.size(); i++) {
				iDecoderSet.add(altDecoderList.get(i));
			}
		}else{
			iDecoderSet = myIDecoderClient.getIdentifiersByInputIDAndTargetCaseInsensitive(selectedGeneList.getGene_list_id(), targets, pool);
			//log.debug("iDecoderSet = "); myDebugger.print(iDecoderSet);
			if(iDecoderSet.size()>0){
				Iterator itr = iDecoderSet.iterator();
				while (itr.hasNext()) {
					Identifier thisIdentifier = (Identifier) itr.next();
					//thisIdentifier.setLowerCaseIdentifier();
					//log.debug("******ID"+thisIdentifier.getIdentifier());
					if (thisIdentifier.getRelatedIdentifiers().size() == 0) {
						log.debug("remove id:"+thisIdentifier.getIdentifier());
						noIDecoderList.add(thisIdentifier.getIdentifier());
					}
				}
				for (int i=0; i<noIDecoderList.size(); i++) {
					iDecoderSet.remove(new Identifier((String) noIDecoderList.get(i)));
				}
			}
		}
		log.debug("finished calling iDecoderClient");
		session.setAttribute("iDecoderSet", iDecoderSet);
		session.setAttribute("noIDecoderList", noIDecoderList);
	} catch (Exception e) {
		log.error("iDecoder timed out when calling it for gene list home" , e);
		//Error - "No iDecoder");
		session.setAttribute("errorMsg", "GLT-001");
		response.sendRedirect(commonDir + "errorMsg.jsp");
	}
	myIDecoderClient.setNum_iterations(1);
%>
