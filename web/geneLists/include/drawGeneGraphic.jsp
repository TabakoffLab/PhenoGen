<%
/* Request Parameters
   >> note: left as request.getaParameters so it could be open to ajax calls, with minor modification
   -------------------*/
    // Physical Location options
    String showPhysicalLocation = request.getParameter( "showPhysLoc" );
    String physicalLocationOf = request.getParameter( "geneLocs" );

    // Transcription Control options
    String showTranscriptionLocation = request.getParameter( "showTransLoc " );
    String transcriptinControlIn = request.getParameter( "transLocs" );

    //Advanced Settings
    String regionListId = request.getParameter( "qtlListID" );
    String regionListContents = request.getParameter( "regionList" );

    String regionOfInterestRestriction = request.getParameter( "regOpt" );

    // Gene List ID
    String geneListId = request.getParameter( "geneList" );

/*  -------------------*/

/*
    ArrayList geneList = new ArrayList();       // get collection from session or requery the database for the list.
    ArrayList regionList = new ArrayList();     // get collection from session, request attribute or query the database

*/
    /* filter/append data to geneList/regionList by Physical Location options
       filter/append data to geneList/regionList by Transcription Control options
       filter/append data to geneList/regionList by the radio buttons that relate to "configure graphic by region of interest"
    /*/
    /* * *
     *  Parameters to send to drawing utility:
     *      define characters: [] = optional data
     *                          - = creates a range
     *                          ~ = draw marker on left side of chromosome
     *                          | = delimits chromosome from its basepairs
     *                          : = delimits chromosomes
     *
     *      opt : means a default is set if not specifically defined
     *
     *      parameter           values/format
     *      ---------           --------------
     *      data                chromosomeNumber|basePair[-basePair][:chromosomeNumber|basePair[-basePair]]
                                    EXAMPLE: 1|20000000:2|1000000-2000000:2|3000000:2|~12850100...
     *      chrom               chromosome number (selects chromosome to view horizontally or vertically)
     *      horizontal (opt)    if parameter is present, chromosome will be displayed horizontal, if absent drawn vertically
     *      wide (opt)          if parameter is present, chromosomes will be displayed in 1 row, if absent 2 rows
     *      bp                  basePairStart-basePairEnd (must be range)    EXAMPLE:  2500100-3900200
     *      h (opt)             height (in px)  EXAMPLE: 100
     *      w (opt)             width (in px)   EXAMPLE: 200
     *      imageMap            draws the html map or not [0,1] default=1  (1: do not create img map, 0: create img map)
     *
     *      note: height and width pertain to the graphic itself, the individual chromosomes contained would be adjusted in proportion to the graphic
     *      !note: if you use imageMap, you will also need to set the image src parameters without the imageMap parameter

     *      graphic         parameters needed                                                    image
     *      -------         --------------------------                                           ----------------
     *      initial         data, imageMap, [h,w]                                                    data [h,w]
     *      expanded        1) data, imageMap, wide [h,w]              (top row of chromosomes)      data, wide [h,w]
     *                      2) data, chrom, horizontal, bp, [h,w]  (bottom horizontal chromosome)
     *      vertical        data, chrom, bp, [h,w]
    /*/

//<--start DUMMY DATA
/*
    LinkedHashSet genesToDisplay = new LinkedHashSet();
    genesToDisplay.add("Gnb1(145087_at) -- 4|||154865479");
    genesToDisplay.add("Tada1l(1439806_at) -- 1|||168309431");
    session.setAttribute("genesToDisplay", genesToDisplay);

    LinkedHashSet transToDisplay = new LinkedHashSet();
    transToDisplay.add("Cml5(1430966_at) -- 6|||85780382");
    transToDisplay.add("Mgst3(1448300_at) -- 1|||169302515");
    session.setAttribute("transToDisplay", transToDisplay);

    LinkedHashSet regionsToDisplay = new LinkedHashSet();
    regionsToDisplay.add("1|||8.5E7-1.02E8");
    regionsToDisplay.add("12|||2000000.0-2.0E7");
    regionsToDisplay.add("17|||4.9E7-6.5E7");
    session.setAttribute("regionsToDisplay", regionsToDisplay);
*/
//-->end DUMMY DATA

    String height = request.getParameter( "ht" ) == null ? "" : request.getParameter( "ht" );
    String width = request.getParameter( "wd" ) == null ? "" : request.getParameter( "wd" );
    String imageMap = "&imageMap=0";

    String graphicMode = request.getParameter( "mode" ) == null ? "initial" : request.getParameter( "mode" );

    String chrom = request.getParameter( "chromosome" ) != null ? request.getParameter( "chromosome" ) : "";

    String displayChromosome = (chrom.equals("") ? "" : myChromosomes[Integer.parseInt(chrom) - 1].getName());
    //String displayChromosome = chrom;

    //long bpMin   = 3000001;
    //long bpMax   = 197195432;
    //long bpStart = 3000001;     // set from real data/object
    //long bpEnd   = 197195432;   // set from real data/object
    long bpMin = 1;
    long bpMax   = (chrom.equals("") ? myChromosomes[0].getLength() : myChromosomes[Integer.parseInt(chrom) - 1].getLength());
	// Fix this to depend on the scale of the graph -- depends on the organism
	int marginLeft = new Double((chrom.equals("") ? 0: myChromosomes[Integer.parseInt(chrom) - 1].getLength())*.0000022).intValue();
	int marginRight = (chrom.equals("") ? 0 : myChromosomes[0].getLength() - myChromosomes[Integer.parseInt(chrom) - 1].getLength())/225000;

    if ( !graphicMode.equals( "initial" ) ) {
        if ( chrom != null && chrom.length() > 0 ) {
            chrom = "chrom=" + chrom;
	}
    }

    String frameSrcParams = "?";
    String mainImgSrcParams = frameSrcParams;
    String hImgSrcParams = frameSrcParams;

    boolean setHorizontal = false;

    List modes = Arrays.asList( new String[] {"initial","expanded","vertical"} );

    String heightAndWidth = ( height.length() > 0 ? "&height=" + height : "" ) + ( width.length() > 0 ? "&width=" + width : "" );

    switch ( modes.indexOf( graphicMode ) ) {
        case 0: //  initial
            frameSrcParams += imageMap + heightAndWidth;
            mainImgSrcParams += heightAndWidth;
            break;
        case 1: //  expanded
            String wide = "wide=1";
            String horizontal = "&horizontal=1";

            frameSrcParams += wide + imageMap + heightAndWidth;
            mainImgSrcParams += wide + heightAndWidth;
            hImgSrcParams += chrom + horizontal + heightAndWidth;

            setHorizontal = chrom.length() > 0;
            break;
        case 2: //  vertical
            // no display mode for this (modal vs .jsp)
            break;
        default:
            frameSrcParams = "";
            break;
    }

    String servletSrc = request.getContextPath() + "/Chromosomes";

    DecimalFormat df = new DecimalFormat( "#,###" );
%>
    <div class="mainImageMap"></div>
    <div class="mainImage <%=mode%>">
        <img class="expanded" src="<%= servletSrc %><%= mainImgSrcParams %>" usemap="#chrom_map" />
    </div>

    <script type = "text/javascript" >
        var hImageParams = { srcUrl   : "<%=servletSrc%>",
                             imgClass : imageClass.horizontal
                           };
        $.extend( hImageParams, makeJson( "<%= hImgSrcParams %>" ), makeJson( "<%=mainImgSrcParams%>" ) );
    </script>
<%
    if ( setHorizontal ) {
        String locatorParams = "?" + "&locator=" + displayChromosome + "|" + bpMin + "-" + bpMax + "&" + chrom + "&horizontal=1&height=35&width=300";
%>
    <div class="hControls">
        <div class="zoom out"></div>
        <div class="zoom in"></div>
        <div class="zoom factor info" title="Zoom Control - Zoom in by 1/x times or out x times.">
            Zoom <input name="factor" type="textbox" value="3" size="1" maxlength="2" /> X</div>

        <div style="width: 2px; margin: 2px 2px 2px 0; background: #99e; height: 28px; float:left;"></div>

        <div class="locationIndicator">
            <div class="label info" title="Location - Shows the range that is currently being displayed. Click to zoom in to a location on the chromosome (one time).">
                Zoom location
            </div>
            <img class="locator" src="<%= servletSrc %><%= locatorParams %>"/>
        </div>
    </div>

    <script type = "text/javascript" >
        // horizontal graphic control parameters and settings
        var controlSettings = { bpMax   : <%=bpMax%>,
                                bpMin   : <%=bpMin%>,
                                bpStart : <%=bpMin%>,
                                bpEnd   : <%=bpMax%>,
                                factor  : 0,
                                minBps  : 100000,       // minimum number of basepairs to show
                                minAdj  : 100000,       // minimum adjustment amount
                                scroll  : 0
                              };

        $(document).ready(function(){
            var tooltipSettings = { showBody : " - ",
                                    track : false,
                                    delay: 1000,
                                    showURL: false
                                  };

            $("div.info").tooltip( tooltipSettings );

            setupHorizontalGraphicControl();

            setHorizontalImageMap();
        });

        var locatorParams = { srcUrl    : "<%=servletSrc%>",
                              imgClass  : imageClass.locator
                            };

        $.extend( locatorParams, makeJson( "<%= locatorParams %>" ) );
    </script>

    <div id="horizontalImgMap" style="display: none;"></div>

    <div class="horizontalImgPrintArea"><img class="horizontal" src="<%= servletSrc %><%= hImgSrcParams %>" usemap="#chrom_map_horizontal" /></div>

    <div class="bpRightInfo grInfo"><%= df.format( bpMax ) %></div>
    <!-- <div class="bpRightInfo grInfo" style="margin-right:<%=marginRight%>px"><%= df.format( bpMax ) %></div> -->
    <div class="bpLeftInfo grInfo"><%= df.format( bpMin ) %></div>
    <div class="bpCenterInfo grInfo">Chromosome: <%=displayChromosome%></div>
    <!-- <div class="bpCenterInfo grInfo" style="margin-left:<%=marginLeft%>px">Chromosome: <%=displayChromosome%></div> -->

    <div class="hControls bottom">
        <div class="scroll left"></div>
        <div class="scroll basepairs info" title="Scroll Control - The number of basepairs to 'jump' left or right.<br> Scrolling function will be enabled when fewer basepairs are displayed than the chromosome actually has.">
            Basepairs: <input name="bpDist" type="textbox" value="<%=df.format(5000000)%>" size="8" maxlength="11" /></div>
        <div class="scroll right"></div>

        <div style="width: 2px; margin: 2px 2px 2px 10px; background: #99e; height: 26px; float:left;"></div>

        <div class="setBp leftIn">Proximal end: <input   name="bpLeft"  type="textbox" value="<%=df.format( bpMin )%>" size="12" maxlength="16" /></div>
        <div class="setBp rightIn">Distal end: <input name="bpRight" type="textbox" value="<%=df.format( bpMax )%>" size="12" maxlength="16" /></div>
        <div class="setBp apply button info" title="Basepair Control - Manually set left and right basepair."><b><b><b>Set</b></b></b></div>
    </div>
<%
    }
%>
