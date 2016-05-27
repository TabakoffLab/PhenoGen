
<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 


<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>
<jsp:useBean id="myPromoter" class="edu.ucdenver.ccp.PhenoGen.data.Promoter"> </jsp:useBean>
<jsp:useBean id="anonU" class="edu.ucdenver.ccp.PhenoGen.data.AnonUser" scope="session" />


<%
        String type="";
        String id="";
        String result="";
        String genomeVer="";


	if(request.getParameter("type")!=null){
		type=request.getParameter("type");
	}
	if(request.getParameter("geneListID")!=null){
		id=request.getParameter("geneListID");
	}
        if(request.getParameter("genomeVer")!=null){
                genomeVer=request.getParameter("genomeVer");
        }
	
	log.debug("\n genomeVer="+genomeVer);
	String now = myObjectHandler.getNowAsMMddyyyy_HHmmss();
	java.sql.Timestamp timeNow = myObjectHandler.getNowAsTimestamp();
	
        int parameter_group_id = myParameterValue.createParameterGroup(pool);

        mySessionHandler.createGeneListActivity("Ran promoter analysis:"+type+" on Gene List", pool);
	
        if(type.equals("Upstream")){
                String upstreamLengthPassedIn = (String) request.getParameter("upstreamLength");
                String upstreamStart= (String) request.getParameter("upstreamSelect");
                String upstart="gene start";
                if(upstreamStart.equals("trx")){
                    upstart="transcript start";
                }else if(upstreamStart.equals("trxcds")){
                    upstart="transcript cds start";
                }
                //
                // upstreamLengthPassedIn will be 0.5, 1, or 2, so multiply it by 1000 to get kb
                //
                Float upstreamLength1 = new Float((Float.valueOf(upstreamLengthPassedIn).floatValue()) *
                                                        (new Float("1000").floatValue()));
                int upstreamLength = (int) upstreamLength1.intValue();


                String geneListAnalysisDir = selectedGeneList.getGeneListAnalysisDir(userLoggedIn.getUserMainDir());
                String upstreamDir = selectedGeneList.getUpstreamDir(geneListAnalysisDir);
                if(userLoggedIn.getUser_name().equals("anon")){
                    /*Date start = new Date();
                    GregorianCalendar gc = new GregorianCalendar();
                    gc.setTime(start);
                    String datePart=Integer.toString(gc.get(gc.MONTH)+1)+
                                        Integer.toString(gc.get(gc.DAY_OF_MONTH))+
                                        Integer.toString(gc.get(gc.YEAR))+"_"+
                                        Integer.toString(gc.get(gc.HOUR_OF_DAY))+
                                        Integer.toString(gc.get(gc.MINUTE))+
                                        Integer.toString(gc.get(gc.SECOND));*/
                    upstreamDir=userLoggedIn.getUserGeneListsDir() +"/" + anonU.getUUID()+"/"+selectedGeneList.getGene_list_id()+"/UpstreamExtraction/";//+datePart+"/";
                }
                String upstreamFileName = selectedGeneList.getUpstreamFileName(upstreamDir, upstreamLength, now);

                if (!myFileHandler.createDir(geneListAnalysisDir) || 
                        !myFileHandler.createDir(upstreamDir)) {
                        log.debug("error creating geneListAnalysisDir or upstreamDir directory in upstream.jsp"); 
					
                        mySessionHandler.createGeneListActivity(
                                "got error creating geneListAnalysisDir or upstreamDir directory in upstream.jsp for " +
                                selectedGeneList.getGene_list_name(),
                                pool);
                        result="Error setting up extraction.";
                        //response.sendRedirect(commonDir + "errorMsg.jsp");
                } else {
                        log.debug("no problems creating geneListAnalysisDir or upstreamDir directory in upstream.jsp"); 

                        myGeneListAnalysis.setGene_list_id(selectedGeneList.getGene_list_id());
                        if(userLoggedIn.getUser_name().equals("anon")){
                            myGeneListAnalysis.setUser_id(-20);
                        }else{
                            myGeneListAnalysis.setUser_id(userLoggedIn.getUser_id());
                        }
                        myGeneListAnalysis.setCreate_date(timeNow);
                        myGeneListAnalysis.setAnalysis_type("Upstream");
                        myGeneListAnalysis.setDescription(selectedGeneList.getGene_list_name() + 
                                                        "_" + upstreamLength +" bp Upstream Sequence Extraction from "+upstart);
                        GeneList gl=null;
                        if(userLoggedIn.getUser_name().equals("anon")){
                            gl=(new AnonGeneList()).getGeneList(selectedGeneList.getGene_list_id(), pool);
                        }else{
                            gl=myGeneList.getGeneList(selectedGeneList.getGene_list_id(), pool);
                        }
                        myGeneListAnalysis.setAnalysisGeneList(gl);
                        myGeneListAnalysis.setParameter_group_id(parameter_group_id);
                        myGeneListAnalysis.setStatus("Running");
                        myGeneListAnalysis.setVisible(1);
		

			ParameterValue[] myParameterValues = new ParameterValue[3];
                        for (int i=0; i<myParameterValues.length; i++) {
                            myParameterValues[i] = new ParameterValue();
                            myParameterValues[i].setCreate_date();
                            myParameterValues[i].setParameter_group_id(parameter_group_id);
                            myParameterValues[i].setCategory("Upstream Extraction");
                        }
                        myParameterValues[0].setParameter("Sequence Length");
                        myParameterValues[0].setValue(Integer.toString(upstreamLength));
                        myParameterValues[1].setParameter("Sequence Start");
                        myParameterValues[1].setValue(upstart);

                        myParameterValues[2].setParameter("Genome Version");
                        myParameterValues[2].setValue(genomeVer);
			myGeneListAnalysis.setParameterValues(myParameterValues);

                        myGeneListAnalysis.createGeneListAnalysis(pool);
                        mySessionHandler.createGeneListActivity("Ran Upstream Sequence Extraction on Gene List", pool);
	
                        Thread thread = new Thread(new AsyncPromoterExtraction(
                                                session,
                                                upstreamFileName,
                                                upstreamStart,
                                                genomeVer,
						false,
                                		myGeneListAnalysis));

                        log.debug("Starting first thread "+ thread.getName());
                        thread.start();
                        result="Running...Upstream Extraction";
                }
        }else if(type.equals("MEME")){
                log.debug("start MEME");
                String upstreamLengthPassedIn = (String) request.getParameter("upstreamLength");
                String minWidth = (String) request.getParameter("minWidth");
                String maxWidth = (String) request.getParameter("maxWidth");
                String distribution = (String) request.getParameter("distribution");
                String maxMotifs = (String) request.getParameter("maxMotifs");
                String description = (String) request.getParameter("description");
                String upstreamStart= (String) request.getParameter("upstreamSelect");

                //
                // upstreamLengthPassedIn will be 0.5, 1, or 2, so multiply it by 1000 to get kb
                //
                Float upstreamLength1 = new Float((Float.valueOf(upstreamLengthPassedIn).floatValue()) *
                                                        (new Float("1000").floatValue()));
                int upstreamLength = (int) upstreamLength1.intValue();

                log.debug("numberOfGenes = "+ selectedGeneList.getNumber_of_genes());
                int totalLength = upstreamLength * selectedGeneList.getNumber_of_genes(); 
                log.debug("totalLength = "+ totalLength);
                if (totalLength > 300000) {
                                NumberFormat nf = NumberFormat.getInstance();
                                //Error - "Over 200,000 characters"
                                //session.setAttribute("errorMsg", "PRM-004");
                                //session.setAttribute("additionalInfo", );
                                result="Over the 300Kbp limit.  Your request contains "+selectedGeneList.getNumber_of_genes() + 
                                                " genes times "+upstreamLength + " characters for each gene, which equals "+
                                                        nf.format(totalLength) + " total characters.";
                } else {
                    String geneListAnalysisDir = selectedGeneList.getGeneListAnalysisDir(userLoggedIn.getUserMainDir());
                    
                    String memeDir = selectedGeneList.getMemeDir(geneListAnalysisDir,now);
                    if(userLoggedIn.getUser_name().equals("anon")){
                        memeDir=userLoggedIn.getUserGeneListsDir() +"/" + anonU.getUUID()+"/"+selectedGeneList.getGene_list_id()+"/MEME/"+now+"/";
                    }
                    //String sequenceFileName = selectedGeneList.getUpstreamFileName(memeDir, upstreamLength, now);
                    String sequenceFileName = memeDir+"upstream_"+ upstreamLength + "bp.fasta.txt";

                    if (!myFileHandler.createDir(geneListAnalysisDir) || 
                                    !myFileHandler.createDir(memeDir)) {
                            log.debug("error creating geneListAnalysisDir or memeDir directory in meme.jsp"); 

                            mySessionHandler.createGeneListActivity(
                                    "got error creating geneListAnalysisDir or memeDir directory in meme.jsp for " +
                                    selectedGeneList.getGene_list_name(),
                                    pool);
                            result="Error setting up to run MEME.";
                    } else {
                            log.debug("no problems creating geneListAnalysisDir or memeDir directory in meme.jsp"); 

                            myGeneListAnalysis.setGene_list_id(selectedGeneList.getGene_list_id());
                            if(userLoggedIn.getUser_name().equals("anon")){
                                myGeneListAnalysis.setUser_id(-20);
                            }else{
                                myGeneListAnalysis.setUser_id(userLoggedIn.getUser_id());
                            }
                            myGeneListAnalysis.setCreate_date(timeNow);
                            myGeneListAnalysis.setAnalysis_type("MEME");
                            myGeneListAnalysis.setDescription(description);
                            GeneList gl=null;
                            if(userLoggedIn.getUser_name().equals("anon")){
                                gl=(new AnonGeneList()).getGeneList(selectedGeneList.getGene_list_id(), pool);
                            }else{
                                gl=myGeneList.getGeneList(selectedGeneList.getGene_list_id(), pool);
                            }
                            myGeneListAnalysis.setAnalysisGeneList(gl);
                            myGeneListAnalysis.setParameter_group_id(parameter_group_id);
                            myGeneListAnalysis.setStatus("Running");
                            myGeneListAnalysis.setVisible(1);

                            log.debug("now = "+now);
                                    //String memeFileName = selectedGeneList.getMemeFileName(memeDir, now);
                            String memeFileName = memeDir;

                            ParameterValue[] myParameterValues = new ParameterValue[8];
                            for (int i=0; i<myParameterValues.length; i++) {
                                    myParameterValues[i] = new ParameterValue();
                                    myParameterValues[i].setCreate_date();
                                    myParameterValues[i].setParameter_group_id(parameter_group_id);
                                    myParameterValues[i].setCategory("MEME");
                            }
                            myParameterValues[0].setParameter("Sequence Length");
                            myParameterValues[0].setValue(Integer.toString(upstreamLength));
                            myParameterValues[1].setParameter("Distribution of Motifs");
                            myParameterValues[1].setValue(distribution);
                            myParameterValues[2].setParameter("Maximum Number of Motifs");
                            myParameterValues[2].setValue(maxMotifs);
                            myParameterValues[3].setParameter("Minimum Motif Width");
                            myParameterValues[3].setValue(minWidth);
                            myParameterValues[4].setParameter("Maximum Motif Width");
                            myParameterValues[4].setValue(maxWidth);
                            myParameterValues[5].setParameter("MEME Dir");
                            myParameterValues[5].setValue(memeDir);
                            myParameterValues[6].setParameter("Sequence Start");
                            String upstart="gene start";
                            if(upstreamStart.equals("trx")){
                                upstart="transcript start";
                            }else if(upstreamStart.equals("trxcds")){
                                upstart="transcript cds start";
                            }
                            myParameterValues[6].setValue(upstart);
                            myParameterValues[7].setParameter("Genome Version");
                            myParameterValues[7].setValue(genomeVer);

                            myGeneListAnalysis.setParameterValues(myParameterValues);
                            myGeneListAnalysis.createGeneListAnalysis(pool);

                            mySessionHandler.createGeneListActivity("Ran MEME on Gene List", pool);

                            Thread thread = new Thread(new AsyncPromoterExtraction(
                                            session,
                                            sequenceFileName,
                                            upstreamStart,
                                            genomeVer,
                                            true,
                                            myGeneListAnalysis));

                            log.debug("Starting first thread to run PromoterExtraction: "+ thread.getName());

                                            thread.start();

                            Thread thread2 = new Thread(new AsyncMeme(
                                            session,
                                            memeFileName,
                                            sequenceFileName,
                                            distribution,
                                            maxMotifs,
                                            minWidth,
                                            maxWidth,
                                            myGeneListAnalysis,
                                            thread));

                            log.debug("Starting second thread to run Meme "+ thread2.getName());

                                            thread2.start();

                            //Success - "MEME started"
                            //session.setAttribute("successMsg", "GLT-012");
                            //response.sendRedirect(commonDir + "successMsg.jsp");
                            result="Running...MEME";
                    }
                }
        }else if(type.equals("oPOSSUM")){
            String conservationLevel = (String) request.getParameter("conservationLevel");
                String thresholdLevel = (String) request.getParameter("thresholdLevel");
                String searchRegionLevel = (String) request.getParameter("searchRegionLevel");
                String description = (String) request.getParameter("description");

                mySessionHandler.createGeneListActivity("Ran oPOSSUM Process ", pool);
	
                HashMap ids = new HashMap();

                //String targets[] = {"RefSeq RNA ID"};
                String targets[] = {"Entrez Gene ID"};
                //String targets[] = {"Ensembl ID"};
                thisIDecoderClient.setNum_iterations(1);
                //Set refseqSet = thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersForTarget(iDecoderSet, targets));
                Set refseqSet = thisIDecoderClient.getIdentifiersByInputIDAndTarget(selectedGeneList.getGene_list_id(), targets,pool);
                //Set refseqSet = thisIDecoderClient.getValues(thisIDecoderClient.getIdentifiersByInputIDAndTarget(selectedGeneList.getGene_list_id(), targets,dbConn));
                //thisIDecoderClient.setNum_iterations(1);
                String genesToFile = "";
                if (refseqSet == null) {
                        //Error - "No RefSeqIDs from Promoter"
                        /*session.setAttribute("errorMsg", "GL-008");
                        response.sendRedirect(commonDir + "errorMsg.jsp");*/
                        result="No RefSeqIDs from Promoter";
                } else { 
                        log.debug("refseqSet from iDecoder = "); myDebugger.print(refseqSet);
                        //log.debug("iDecoderResult from iDecoder = "); myDebugger.print(iDecoderResult);

                        //
                        // Convert refseqSet identifer list to a string separated
                        // by carriage return and line feeds
                        //
                        //OLD VERSION
                        //genesToFile = myObjectHandler.getAsSeparatedString(refseqSet, "\n");
				
                        //NEW VERSION
				
                        Iterator it = refseqSet.iterator();
                        while (it.hasNext()) {
                            Identifier tmp=(Identifier)it.next();
                            Set relID=tmp.getRelatedIdentifiers();
                            Iterator it2=relID.iterator();
                            while(it2.hasNext()){
                                    String id2=((Identifier)it2.next()).getIdentifier();

                                            if(genesToFile.equals("")){
                                                    genesToFile=id2;
                                            }else{
                                                    genesToFile=genesToFile+"\n"+id2;
                                            }

                            }
                        }


	
                        log.debug("now = " + now + ", timeNow = "+ timeNow);

                        String geneListAnalysisDir = selectedGeneList.getGeneListAnalysisDir(userLoggedIn.getUserMainDir());
                        String promoterDir = selectedGeneList.getOPOSSUMDir(geneListAnalysisDir);
                        if(userLoggedIn.getUser_name().equals("anon")){
                            promoterDir=userLoggedIn.getUserGeneListsDir() +"/" + anonU.getUUID()+"/"+selectedGeneList.getGene_list_id()+"/oPOSSUM/";
                        }

                        if (!myFileHandler.createDir(geneListAnalysisDir) || 
                                !myFileHandler.createDir(promoterDir)) {
                                log.debug("error creating promoterDir directory in promoter.jsp"); 
					
                                mySessionHandler.createGeneListActivity("got error creating promoterDir directory in promoter.jsp for " +
                                        selectedGeneList.getGene_list_name(),
                                        pool);
                                /*session.setAttribute("errorMsg", "SYS-001");
                                response.sendRedirect(commonDir + "errorMsg.jsp");*/
                                result="Error setting up to run oPOSSUM";
                        } else {
                                log.debug("no problems creating promoterDir directory in promoter.jsp"); 

                                String filePrefix = promoterDir + now + "_";

                                myFileHandler.writeFile(genesToFile, filePrefix + "promoterGenes.txt");

                                log.debug("conservationLevel = "+conservationLevel);
                                log.debug("thresholdLevel = "+thresholdLevel);
                                log.debug("searchRegionLevel = "+searchRegionLevel);

                                myPromoter.setGene_list_id(selectedGeneList.getGene_list_id());
                                if(userLoggedIn.getUser_name().equals("anon")){
                                     myPromoter.setUser_id(-20);
                                }else{
                                     myPromoter.setUser_id(userLoggedIn.getUser_id());
                                }
                               
                                myPromoter.setCreate_date(timeNow);

                                Iterator itr = iDecoderSet.iterator();
                                while (itr.hasNext()) {
                                        Identifier thisIdentifier = (Identifier) itr.next();
                                        Set identifierValuesSet = thisIDecoderClient.getValues((Set) thisIdentifier.getRelatedIdentifiers());
                                        String[] identifierValues = (String[]) identifierValuesSet.toArray(new String[identifierValuesSet.size()]); 
                                        ids.put(thisIdentifier.getIdentifier(), identifierValues);
                                }

//	        		log.debug("ids = "); myDebugger.print(ids);

                                myPromoter.setIds(ids);

                                String searchRegionLevelText = "";
                                String conservationLevelText = "";
                                String thresholdLevelText = "";

                                if (searchRegionLevel.equals("1")) {
                                        searchRegionLevelText = "-10000 bp to +10000 bp";		
                                } else if (searchRegionLevel.equals("2")) {
                                        searchRegionLevelText = "-10000 bp to +5000 bp";
                                } else if (searchRegionLevel.equals("3")) {
                                        searchRegionLevelText = "-5000 bp to +5000 bp";		
                                } else if (searchRegionLevel.equals("4")) {
                                        searchRegionLevelText = "-5000 bp to +2000 bp";
                                } else if (searchRegionLevel.equals("5")) {
                                        searchRegionLevelText = "-2000 bp to +2000 bp";
                                } else {
                                        searchRegionLevelText = "-2000 bp to +0 bp";
                                }	

                                if (conservationLevel.equals("1")) {
                                        conservationLevelText = "Top 30% of conserved regions (min. conservation 60%)";
                                } else if (conservationLevel.equals("2")) {
                                        conservationLevelText = "Top 20% of conserved regions (min. conservation 65%)";
                                } else {
                                        conservationLevelText = "Top 10% of conserved regions (min. conservation 70%)";	
                                }

                                if (thresholdLevel.equals("1")) {
                                        thresholdLevelText = "75% of maximum possible PWM score for the TFBS";
                                } else if (thresholdLevel.equals("2")) {
                                        thresholdLevelText = "80% of maximum possible PWM score for the TFBS";
                                } else {
                                        thresholdLevelText = "85% of maximum possible PWM score for the TFBS";
                                }

                                myPromoter.setSearchRegionLevel(searchRegionLevelText);
                                myPromoter.setConservationLevel(conservationLevelText);
                                myPromoter.setThresholdLevel(thresholdLevelText);
                                myPromoter.setDescription(description);
	

                                int promoter_id = myPromoter.createPromoterResult(pool);
                                GeneListAnalysis thisGeneListAnalysis = new GeneListAnalysis(promoter_id);

                                log.debug("just set create date from promoter.jsp to "+timeNow);

                                log.debug("userEmail = " +userLoggedIn.getEmail());
                                Thread thread = new Thread(new AsyncPromoter(
                                        session,
                                        conservationLevel,
                                        thresholdLevel,
                                        searchRegionLevel,
                                        myPromoter,
                                        thisGeneListAnalysis,
                                        filePrefix,
                                        "Entrez Gene"));

                                log.debug("Starting first thread "+ thread.getName());

                                thread.start();

                                //Success - "oPOSSUM started"
                                /*session.setAttribute("successMsg", "GLT-009");
                                response.sendRedirect(commonDir + "successMsg.jsp");*/
                                result="Running...oPOSSUM";

                        }
                }
        }
%>


<%=result%>