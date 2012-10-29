<%
        String gene="";
        String heat="";
        String ident="";
        String rDataFile="'"+session.getAttribute("userFilesRoot");
        String dbName="";
        String version="";
        String firstEnsemblID="";
        iDecoderAnswer = (Set) session.getAttribute("iDecoderAnswer");
        ExonDataTools edt=new ExonDataTools();
        edt.setSession(session);
        List myIdentifierList=null;
        ArrayList<String> myEnsemblIDs=new ArrayList<String>();
        if(iDecoderAnswer!=null){
                myIdentifierList = Arrays.asList(iDecoderAnswer.toArray((Identifier[]) new Identifier[iDecoderAnswer.size()]));
        }/*else{
                log.debug("iDecoder Answer is NULL");
        }*/
        if(myOrganism!=null){
                if(myOrganism.equals("Mm")){
                        rDataFile=rDataFile+"public/Datasets/PublicILSXISSRIMice_Master/Affy.NormVer.h5'";
                        dbName="Public ILSXISS RI Mice";
                        version="v3";
                        //version="v6";  //need to use v6 while LXS49 strain is uncertain
                }else if(myOrganism.equals("Rn")){
                        if(myTissue.equals("Brain")){
                                rDataFile=rDataFile+"public/Datasets/PublicHXB_BXHRIRats(Brain,ExonArrays)_Master/Affy.NormVer.h5'";
                                dbName="Public HXB/BXH RI Rats (Brain, Exon Arrays)";
                                version="v3";
                        }else if(myTissue.equals("Heart")){
                                rDataFile=rDataFile+"public/Datasets/PublicHXB_BXHRIRats(Heart,ExonArrays)_Master/Affy.NormVer.h5'";
                                dbName="Public HXB/BXH RI Rats (Heart, Exon Arrays)";
                                version="v3";
                        }else if(myTissue.equals("Liver")){
                                rDataFile=rDataFile+"public/Datasets/PublicHXB_BXHRIRats(Liver,ExonArrays)_Master/Affy.NormVer.h5'";
                                dbName="Public HXB/BXH RI Rats (Liver, Exon Arrays)";
                                version="v3";
                        }else if(myTissue.equals("BAT")){
                                rDataFile=rDataFile+"public/Datasets/PublicHXB_BXHRIRats(BrownAdipose,ExonArrays)_Master/Affy.NormVer.h5'";
                                dbName="Public HXB/BXH RI Rats (Brown Adipose, Exon Arrays)";
                                version="v3";
                        }
                }
        }
	
        if(iDecoderAnswer!=null){
            //log.debug("iDecoderAnswer not null, length:"+myIdentifierList.size());
            if(myIdentifierList!=null&&myIdentifierList.size()>0){
                Identifier thisIdentifier = (Identifier)myIdentifierList.get(0);
                HashMap linksHash = thisIdentifier.getTargetHashMap();
                Set homologSet = myIDecoderClient.getIdentifiersForTargetForOneID(linksHash, new String[] {"Ensembl ID"});
                List homologList = myObjectHandler.getAsList(homologSet);

                for (int i=0; i< homologList.size(); i++) {
                    Identifier homologIdentifier = (Identifier) homologList.get(i);
                    if(homologIdentifier.getIdentifier().indexOf("T0")!=6){
                        myEnsemblIDs.add(homologIdentifier.getIdentifier());
                        if(ident.equals("")){
                            ident=homologIdentifier.getIdentifier();
                                                    firstEnsemblID=ident;
                        }else{
                            ident=ident+","+homologIdentifier.getIdentifier();
                        }

                    }
                }
                if(!ident.equals("")){
                    edt.getExonHeatMapData(ident,rDataFile,version,myOrganism,dbName);
                    gene =(String)session.getAttribute("exonCorGeneFile");//"http://stan.ucdenver.pvt/PhenoGen/web/exons/Test1XML.xml";
                    heat =(String)session.getAttribute("exonCorHeatFile");//"http://stan.ucdenver.pvt/PhenoGen/web/exons/HeatMap2.txt";
                                            //log.debug("Gene:"+gene+"\nHeat:"+heat);
                }else{
                        gene="No Ensembl ID";
                        heat="No Ensembl ID";
                }

            }
        %>



<%if (gene.equals("failed")){
        //log.debug("Gene=FAILED");
%>

        <div class="error">
            <p>An error occurred while generating the heatmap.  The administrator has been notified.  Please try again later.</p>
        </div>
        <div class="brClear"></div>
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />

<% }else if (gene.equals("No Ensembl ID")){%>
        <div class="error">
            <p>The identifier entered could not be translated to an Ensembl ID.  Please try a different identifier for your gene of interest and/or report the identifier so we can improve the method used to translate identifiers to Ensembl IDs.</p>
        </div>
        <div class="brClear"></div>
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />
        <BR />

<%}else if (gene.equals("External Site Unavailable")){%>
    <div class="error">
        <p>One of the external data sources(UCSC Genome Browser or Ensembl) is temporarily inaccessible.  
            Please wait a few minutes and try again.  The administrator has been notified.  Occassionally this happens, 
            but if you continue to experience problems the administrator will look into the problem.</p>
    </div>
    <div class="brClear"></div>
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />
    <BR />

<%}else{
                //log.debug("gene <> FAILED");
                if(ident.equals("")){
                                //log.debug("Ident is empty.");
%>
                        <div class="error">
                            <p>No ensembl gene identifier was found.</p>
                        </div>
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <BR />
                        <script type="text/javascript">
                            document.getElementById("wait1").style.display = 'none';
                        </script>
    <% }else{ %>
                        <BR />
                        <BR />
                        <script>
                            var gene="<%=gene%>";
                            var heat="<%=heat%>";
                            var ensembl="<%=firstEnsemblID%>";
                        </script>
                        <script src="http://java.com/js/deployJava.js"></script>
                        <script>
                            var attributes = {
                                code:       "edu.ucdenver.ccp.phenogen.applets.ExonCorrelationView",
                                archive:    "ExonCorrelationViewer2.jar, lib/swing-layout-1.0.4.jar",
                                width:      960,
                                height:     1200
                            };
                            var parameters = {jnlp_href:"/web/exons/launch.jnlp",
                                gene_data:gene,
                                heatmap_data:heat,
                                main_ensembl_id:ensembl
                            }; 
                            var version = "1.5"; 
                            deployJava.runApplet(attributes, parameters, version);
                        </script>

    <% } %>
<% } %>
<% 
} else {
%>
            <div id="exonDirections">
            <BR />
            <%if(myGeneArray!=null){%>
            <ol type="1" style="padding-left:40px; color:#000000; list-style: outside decimal;">

                <li>Choose a Gene, Species, and Tissue.</li>
                <li>Get the Exon Correlations.</li>
            </ol>
            <% } else { %>
            <ol type="1" style="padding-left:40px; color:#000000; list-style: outside decimal;">
                <li>Enter a Gene Symbol, Probeset ID, Ensembl ID, etc. in the Gene field.</li>
                <li>Choose a Species and Tissue.</li>
                <li>Get the Exon Correlations.</li>
            </ol>

            <% } %>

            You can view the exon-exon correlation heat map for any transcripts associated with the corresponding Ensembl ID provided by iDecoder.<BR />
            <b>Note: </b>You may be prompted to choose an Ensembl ID if more than one Ensembl ID corresponds to the gene entered.
            <BR />
            <BR />
            <BR />
            <script>
                if(!navigator.javaEnabled()){
                    document.write("<B>Error:</B>This feature requires the Java Plug-in which is either disabled or not installed.  Recent operating system and browser changes can disable java automatically.");
                    document.write("  This was done because the old versions are vulnerable to an attack which could take over your computer without your knowledge and access files or steal critical information like banking credentials.<BR><BR>Please first update or install Java from <a href=\"http://www.Java.com\">Java.com</a><BR><BR>To enable Java in your browser or operating system, see:<BR><BR> Firefox: <a href=\"http://support.mozilla.org/en-US/kb/unblocking-java-plugin\">http://support.mozilla.org/en-US/kb/unblocking-java-plugin</a><BR><BR>Internet Explorer: <a href=\"http://java.com/en/download/help/enable_browser.xml\">http://java.com/en/download/help/enable_browser.xml</a><BR><BR>Safari: <a href=\"http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html\">http://docs.info.apple.com/article.html?path=Safari/5.0/en/9279.html</a><BR><BR>Chrome: <a href=\"http://java.com/en/download/faq/chrome.xml\">http://java.com/en/download/faq/chrome.xml</a><BR>");
                }
            </script>
            </div>
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />
            <BR />

<% 
} %> 