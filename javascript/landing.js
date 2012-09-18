
/* * * *
 *  sets up the click function for the "tools" tabs and the click on the <a> tags in various page sections
/*/
function setupLanding()
{
    var tabs = $("ul.tabs").find("li");

    tabs.each(function(i){
            $(this).css("left", $(this).css("left").match(/\d*/) * -i);
        });

    tabs.click(function(){
            $("ul.tabs li").removeClass("selected");
            $("div.tabContent").hide();
            //$("div.didYouKnowContent").hide();
            //$("div.howDoIContent").hide();

            var thisClass = $(this).attr("class");

            $(this).addClass("selected");

            $("div.tabContent." + thisClass).show();
            //$("div.didYouKnowContent." + thisClass).show();
            //$("div.howDoIContent." + thisClass).show();
        });

}
