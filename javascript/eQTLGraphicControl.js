// TREAT AS FINAL   these should match css and java, as needed
var graphicModes = { initial    : "initial",
                     expanded   : "expanded",
                     horizontal : "horizontal",
                     vertical   : "vertical",
                     locate     : "locate"
                   };

// TREAT AS FINAL   known classes on the jsp page that control height and width of graphic display area.
var imageClass = { horizontal : "horizontal",
                   vertical   : "verticalImage",
                   locator    : "locator"
                 };

function select_chrom( i )
{
    if ( i >= 0 )
    {
        $("input[name='chromosome']").attr({value: i+1});
        if ( getMode() == graphicModes.initial ) setMode( graphicModes.expanded )
    }

    $("form#graphicSettingsForm").submit();
}

function getMode()
{
    var thisMode = $("input[name='mode']").attr("value");

    // this is here to prevent invalid states maintained in firefox when the back button is used !! IMPORTANT
    thisMode = thisMode == ctrlMode ? thisMode : ctrlMode;

    return thisMode;
}

function setMode( thisMode )
{
    $("input[name='mode']").attr({value : thisMode});
}

/* * *
 *  Builds all image source parameters
 *      getMainGraphic is the large 2 row or 1 row representation of all the chromosomes
/*/
function getSrcParams( mode, getMainGraphic, getImageMap )
{
    var getBasepairs = function () {
            if ( hImageParams.bp != undefined && hImageParams.bp.length > 0 )
                return "&bp=" + hImageParams.bp;

            return "";
        }

    var srcParams = getImageMap ? "" : hImageParams.srcUrl + "?";

    if ( mode == graphicModes.initial )
    {
        srcParams += getImageMap ? "imageMap=Y" : "";
    }
    else if ( mode == graphicModes.expanded )
    {
        if ( getMainGraphic )
            srcParams += "wide=1" + ( getImageMap ? "&imageMap=Y" : "");
        else
            srcParams += "chrom=" + hImageParams.chrom + "&horizontal=" + hImageParams.horizontal + getBasepairs();
    }
    else if ( mode == graphicModes.vertical )
    {
        srcParams += "chrom=" + hImageParams.chrom + getBasepairs();
    }
    else if ( mode == graphicModes.locate )
    {
        var bp = getBasepairs();
        var bpParam = {};

        if ( bp ) bpParam = makeJson( bp )
        else bpParam.bp = controlSettings.bpStart + "-" + controlSettings.bpEnd;

        srcParams += "locator=" + locatorParams.chrom + "|" + bpParam.bp + "&chrom=" + locatorParams.chrom;
        srcParams += "&horizontal=" + locatorParams.horizontal + "&height=" + locatorParams.h + "&width=" + locatorParams.w;
    }
    else if ( mode == graphicModes.horizontal )
    {
        srcParams = "chrom=" + hImageParams.chrom + "&horizontal=" + hImageParams.horizontal;
        if ( getImageMap ) srcParams += "&imageMap=Y";
        srcParams += getBasepairs();
    }

    //alert('srcParams = '+srcParams);

    return srcParams;
}

var iExpandedMap = 0;
function setMainImageMap( mode ) {

    var imgParams = getSrcParams( mode, true, true );
    //alert("imgParams = "+ imgParams);
    //alert("srcUrl = "+ hImageParams.srcUrl);
    iExpandedMap++;

    $.ajax({
        type: "GET",
        dataType: "html",
        async: false,
        data: imgParams,
        url:  hImageParams.srcUrl,
        success: function(mapHtml){
            var mapDiv = $("div.mainImageMap");
            mapDiv.find("map").remove();

            $("div.mainImage").find("img").attr({usemap : "#chrom_map_" + iExpandedMap});

            mapDiv.html(mapHtml);

            mapDiv.find("map").attr({name: "chrom_map_" + iExpandedMap });

            mapDiv.find("area.pointer").tooltip({showURL: false});
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            alert( "could not get map for horizontal chromosome: " + textStatus + " " + errorThrown );
        }
    });
}

/* * *
 *  sets horizontal image and vertical image sources (any img with class)
/*/
var setImgSource = function( settings ){
        var url = settings.fullPath;
        //alert(url)
        $("img." + settings.imgClass ).attr({src : url});
    }

/* * *
 *  sets the location of the current view on the small locator chromosome --> shows the user where they have zoomed to, in relation to the whole chromosome
/*/
var setLocator = function( parameters ){
        parameters.fullPath = getSrcParams( graphicModes.locate );

        setImgSource( parameters );
    }

/* * *
 *  sets up the controls for the graphic, found within the graphic region
/*/
function setupGraphicControls() {
    setMainImageMap( getMode() );

    /* --- Graphic Shrink button --- */
    $("div.graphicShrink").click( function() {
        setMode( graphicModes.initial )
        select_chrom( -1 );
    });

    /* --- Graphic Enlarge button --- */
    $("div.graphicEnlarge").click(function(){
        setMode( graphicModes.expanded )
        select_chrom( -1 );
    });

    /* --- Rotate Chromosome to Vertical button --- */
    var verticalGraphic;
    $(".rotateChromoVertical").click(function(){
        if ( verticalGraphic == undefined )
            verticalGraphic = createDialog("div.verticalGraphic", { width: 200, height: 700, title: "Vertical Chromosome"})

        if ( hImageParams.chrom < 0 || hImageParams.chrom == undefined )
        {
            alert("please select a chromosome");
            return;
        }

        hImageParams.imgClass = imageClass.vertical;
        hImageParams.fullPath = getSrcParams( graphicModes.vertical );

        setImgSource( hImageParams );

        verticalGraphic.show().dialog("open");
    });

    /* --- Print Graphic button --- */
    $(".graphicPrint").click(function(){
        var specificArea = $(this).attr("data-specifiedPrintArea");

        if( specificArea != null ) $(specificArea).printArea();
        else $("#graphic").printArea();
    });

    /* --- Download Graphic button --- */
    $("div.graphicDownload").click(function(){
        var locHref = "";

        if ( !$("div.verticalGraphic").is(":hidden") )
        {
            locHref += getSrcParams( graphicModes.vertical );
        }
        else if ( getMode() == graphicModes.initial )
        {
            locHref += getSrcParams( graphicModes.initial, true );
        }
        else if ( getMode() == graphicModes.expanded )
        {
            if( hImageParams.chrom < 0 )
            {
                alert("please select a chromosome");
                return;
            }

            locHref += getSrcParams( graphicModes.expanded );
        }
        locHref += "&sendOctet=true";

        location.href = locHref.replace("?&", "?");
    });
}

/* * *
 *  var iHorizontalImageMap increments in order to change the map name.  !! IMPORTANT
 *  function will set a new horizontal image map, with the above iterator in its name to tell the browser that we will be using a "new" image map.
 *      without the name change, the browser does not update the map even though the <area>'s have changed.   !! IMPORTANT
 *  without this unconventional "name change" the new area map will not work.
/*/
var iHorizontalImageMap = 0;
function setHorizontalImageMap() {
    var imgParams = getSrcParams( graphicModes.horizontal, false, true );
    //alert(imgParams)
    iHorizontalImageMap++;

    $.ajax({
        type: "GET",
        dataType: "html",
        async: false,
        data: imgParams,
        url:  hImageParams.srcUrl,
        success: function(mapHtml){
            var mapDiv = $("div#horizontalImgMap");
            mapDiv.find("map").remove();

            $("div.horizontalImgPrintArea").find("img").attr({usemap : "#chrom_map_horizontal_" + iHorizontalImageMap});

            mapDiv.html(mapHtml);

            mapDiv.find("map").attr({name: "chrom_map_horizontal_" + iHorizontalImageMap });

            mapDiv.find("area.pointer").tooltip({showURL: false});
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
            //alert( "could not get map for horizontal chromosome: " + textStatus + " " + errorThrown );
        }
    });
}

/* * *
 *  calculates zoom
/*/
function calcZoom()
{
    var factor = controlSettings.factor;
    var b0 = parseInt( controlSettings.bpStart );
    var b1 = parseInt( controlSettings.bpEnd );
    var max = controlSettings.bpMax;
    var min = controlSettings.bpMin;

    var gLen = b1 - b0;

    var center = Math.round( (b0 + b1) / 2 );

    var newWidth = Math.abs( Math.round( gLen * ( factor < 0 ? 1/factor : factor ) ) );

    if ( newWidth > (max - min) )
    {
        b0 = min;
        b1 = max;
        return;
    }

    var adjustment = Math.round( newWidth / 2 );

    b0 = center - adjustment;
    b1 = center + adjustment;

    //alert( "center: " + center + " b0 = " + b0 + " b1 = " + b1 + " width: " + (b1-b0) + " ?= newWidth: " + newWidth )
    if ( b0 < min )
    {
        b0 = min;
        b1 = b0 + newWidth;
    }

    if ( b1 > max )
    {
        b1 = max;
        b0 = b1 - newWidth;
    }

    if ( newWidth < controlSettings.minBps )
    {
        b0 = center - ( Math.round( controlSettings.minBps / 2 ) )
        b1 = center + ( Math.round( controlSettings.minBps / 2 ) )
    }

    if ( (b0 < b1) && (b1 - b0) >= controlSettings.minBps )
    {
        controlSettings.bpStart = b0;
        controlSettings.bpEnd = b1;
    }
}

/* * *
 *  calculates scroll
/*/
function calcScroll() {
    var b0 = parseInt( controlSettings.bpStart );
    var b1 = parseInt( controlSettings.bpEnd );
    var scrollBps = parseInt( controlSettings.scroll );

    var gLen = b1 - b0;

    b0 += scrollBps;
    b1 += scrollBps;

    if ( b0 < controlSettings.bpMin )
    {
        b0 = controlSettings.bpMin;
        b1 = controlSettings.bpMin + gLen;
    }

    if ( b1 > controlSettings.bpMax )
    {
        b1 = controlSettings.bpMax;
        b0 = controlSettings.bpMax - gLen;
    }

    controlSettings.bpStart = b0;
    controlSettings.bpEnd   = b1;
}

/* * *
 *  calculates specified basepairs
/*/
function calcSetBp() {
    var b0 = $("div.hControls").find("input[name='bpLeft']").val();
    var b1 = $("div.hControls").find("input[name='bpRight']").val();

    b0 = parseInt( removeFormat( b0 ) );
    b1 = parseInt( removeFormat( b1 ) );

    if ( b0 == undefined || b0.length == 0 ) b0 = controlSettings.bpMin;
    if ( b1 == undefined || b1.length == 0 ) b1 = controlSettings.bpMax;

    if ( ( b1 - b0 ) <= controlSettings.minBps )
    {
        alert( "Display minimum number of basepairs threshold exceded. Must show at least " + controlSettings.minBps + " basepairs." );
        return;
    }

    controlSettings.bpStart = b0 < controlSettings.bpMin ? controlSettings.bpMin : b0;
    controlSettings.bpEnd   = b1 > controlSettings.bpMax ? controlSettings.bpMax : b1;
}

/* * *
 *  prepares the parameters that will be used to set the new souce of the HORIZONTAL CHROMOSOME IMAGE
/*/
var prepareImgSource = function( zoomIntent, scrollDirection ) {
        controlSettings.factor = zoomIntent * $("div.hControls").find("input[name='factor']").val();
        controlSettings.scroll = scrollDirection * parseInt( removeFormat( $("div.hControls").find("input[name='bpDist']").val() ) );

        if ( zoomIntent != 0 ) calcZoom();
        else if ( scrollDirection != undefined && scrollDirection != 0 ) calcScroll();
        else if ( scrollDirection == 0 ) calcSetBp();

        hImageParams.imgClass = imageClass.horizontal;
        hImageParams.bp = controlSettings.bpStart + "-" + controlSettings.bpEnd;

        if ( controlSettings.bpStart == controlSettings.bpMin && controlSettings.bpEnd == controlSettings.bpMax )
            hImageParams.bp = "";

        hImageParams.fullPath = getSrcParams( graphicModes.expanded );

        setImgSource( hImageParams );

        setLocator( locatorParams );

        setHorizontalImageMap();

        var bpStart = format( controlSettings.bpStart );
        var bpEnd   = format( controlSettings.bpEnd );

        var bpScroll = format( $("div.hControls").find("input[name='bpDist']").val() );

        $("div.hControls").find("input[name='bpDist']").val( bpScroll );

        $("div.hControls").find("input[name='bpLeft']").val( bpStart );
        $("div.hControls").find("input[name='bpRight']").val( bpEnd );

        $("div.bpLeftInfo").text(bpStart);
        $("div.bpRightInfo").text(bpEnd);
    }

/* * *
 *  sets up the horizontal graphic control and click events, and locator
/*/
function setupHorizontalGraphicControl() {
    var setBpButton = $(".hControls .setBp.apply.button");

    $(".hControls .zoom").not(".factor")
        .click(function(){
            var intent = -1; // zoom in

            if ( $(this).hasClass("out") ) intent = 1;

            prepareImgSource( intent );
        })

    $(".hControls .scroll").not(".basepairs")
        .click(function(){
            var sDir = -1 // scroll left

            if ( $(this).hasClass("right") ) sDir = 1;

            prepareImgSource( 0, sDir );
        });

    setBpButton
        .click(function(){
            prepareImgSource( 0,0 );
        });

    var zoomCount = 0;
    $("img.locator").click(function( e ){
        if ( zoomCount == 0 )
        {
            zoomCount++;
            $( ".hControls .zoom.in" ).click();
        }
        var pxWide = 260;
        var imgPadL = 18;
        var stablizer = 2;// unknown why this sets the center of the range more accurately

        var imgOffset = $(this).offset();

        var clickXpx = e.pageX - ( imgOffset.left + imgPadL ) +stablizer;

        var bpPerPx = Math.round( (controlSettings.bpMax - controlSettings.bpMin) / pxWide );

        var bpCenter = clickXpx * bpPerPx;

        var bpWide = controlSettings.bpEnd - controlSettings.bpStart;

        var adjustment = Math.round( bpWide / 2 );

        var bpL = bpCenter - adjustment;
        var bpR = bpCenter + adjustment;

        if ( bpL < controlSettings.bpMin )
        {
            bpL = controlSettings.bpMin;
            bpR = bpL + bpWide;
        }

        if ( bpR > controlSettings.bpMax )
        {
            bpR = controlSettings.bpMax;
            bpL = bpR - bpWide;
        }

        if ( bpL != controlSettings.bpStart ) $("div.hControls").find("input[name='bpLeft']").val( bpL );
        if ( bpR != controlSettings.bpEnd )   $("div.hControls").find("input[name='bpRight']").val( bpR );

        setBpButton.click();
    });
}

/* * *
 *  click handler for gene pointer clicks
/*/
function showData(geneId,organismToDisplay) {
	if(organismToDisplay == 'Mm'){
    	var gotoUrl = "http://www.ensembl.org/Mus_musculus/geneview?db=core;gene=" + geneId;
    }
    else{
    	var gotoUrl = "http://www.ensembl.org/Rattus_norvegicus/geneview?db=core;gene=" + geneId;
    }
    openPopup(gotoUrl, {asTab: true, winName: "_blank"});
}



/* * *
 *  click handler for trans pointer clicks
/*/
function showTransData(transId,organismToDisplay) {

	if(organismToDisplay == 'Mm'){	
    	var gotoUrl = "http://www.ensembl.org/Mus_musculus/Search/Results?species=Mus_musculus;idx=;q=" + transId;
    }
    else{
    	var gotoUrl = "http://www.ensembl.org/Rattus_norvegicus/Search/Results?species=Rattus_norvegicus;idx=;q=" + transId;
    }
    openPopup(gotoUrl, {asTab: true, winName: "_blank"});
}

/* * *
 *  removes all non digits
/*/
function removeFormat( str ) {
    var retString = new String(str);
    retString = retString.replace(/\D*/g, "");

    return retString;
}

/* * *
 *  groups hundreds, thousands, millions...etc (comma delim)
/*/
function format( str ) {
    str = removeFormat(str)

    var newStr = "";
    var i = 0;

    while ( str.length > 2 && i < 5 )
    {
        i++;
        str = str.replace(/(\d{3})$/g , function( m, group ){
            newStr = ( str.length == 3 ? "" : "," ) + group + newStr;
            return "";
        });
    }

    if ( str.length > 0 ) newStr = str + newStr;

    return newStr;
}

/* * *
 *  takes url parameters (?p1=v1&p2=v2&..pn=vn) and creates a json object { p1 : v1, p2 : v2, .. pn : vn}
 *      !! WARNING:  parameters with same name (example: p1=v1&p1=v2 ) get converted to { p1 : v1,v2 }
/*/
var makeJson = function(parms) {
        var q = {};
        parms.replace( /([^?=&]+)=([^&]+)/g, function( m, key, value ){
                q[key] = ( q[key] ? q[key] + "," : "" ) + value;
            });
        return q;
    }
