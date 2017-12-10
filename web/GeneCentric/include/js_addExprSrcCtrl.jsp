PhenogenExpr=function(params){
	var that={};

	that.parseParams=function (params){
		if(params.div){
			that.ctrlDiv=params.div;
		}
		if(params.genomeBrowser){
			console.log("genome:");
			console.log(params.genomeBrowser);
			that.gb=params.genomeBrowser;
		}
	};

	that.setup=function(){
		that.ctrl=d3.select("div#"+that.ctrlDiv+"srcCtrl");
		that.ctrl.append("text").text("Display Feature Type:");
		that.sel=that.ctrl.append("select").attr("id","srcCtrl"+that.ctrlDiv)
				.attr("name","srcCtrl"+that.ctrlDiv)
				.on("change", function(){
					//change titles
					val=that.sel.node().value;
					that.rbChart.setTitle(val+" RNA Gene/Transcript Expression");
					that.rlChart.setTitle(val+" RNA Gene/Transcript Expression");
					d3.select("span#"+that.ctrlDiv+"Titleb").html("Whole Brain "+val+" RNA-Seq Expression");
					d3.select("span#"+that.ctrlDiv+"Titlel").html("Liver "+val+" RNA-Seq Expression");
					//change datasources
					that.brainURL="tmpData/browserCache/"+genomeVer+"/regionData/"+that.gb.folderName+"/Brainexpr.json";
					that.liverURL="tmpData/browserCache/"+genomeVer+"/regionData/"+that.gb.folderName+"/Liverexpr.json";
					if(val==="Small"){
						that.brainURL="tmpData/browserCache/"+genomeVer+"/regionData/"+that.gb.folderName+"/Brain_sm_expr.json";
						that.liverURL="tmpData/browserCache/"+genomeVer+"/regionData/"+that.gb.folderName+"/Liver_sm_expr.json";
						that.rbChart.setDisplayHerit(false);
						that.rlChart.setDisplayHerit(false);
					}else{
						that.rbChart.setDisplayHerit(true);
						that.rlChart.setDisplayHerit(true);
					}
					that.rbChart.setDataURL(that.brainURL);
					that.rlChart.setDataURL(that.liverURL);
				}); 
		that.sel.append("option").attr("value","Long").text("long RNAs (>200bp)");
		that.sel.append("option").attr("value","Small").text("small RNAs (<=200bp)");
		d3.select("span#"+that.ctrlDiv+"Titleb").html("Whole Brain Long RNA-Seq Expression");
		d3.select("span#"+that.ctrlDiv+"Titlel").html("Liver Long RNA-Seq Expression");
       	that.setupCharts();
	};

	that.setupCharts=function(){
		 //setup charts
        that.rbChart=chart({"data":"tmpData/browserCache/"+genomeVer+"/regionData/"+that.gb.folderName+"/Brainexpr.json",
            "selector":"#chartRegionBrain","allowResize":true,"type":"heatmap","width":"45%","height":"70%","displayHerit":true,
        "title":"Long RNA Gene/Transcript Expression","titlePrefix":"Whole Brain"});
        that.rlChart=chart({"data":"tmpData/browserCache/"+genomeVer+"/regionData/"+that.gb.folderName+"/Liverexpr.json",
            "selector":"#chartRegionLiver","allowResize":true,"type":"heatmap","width":"45%","height":"70%","displayHerit":true,
        "title":"Long RNA Gene/Transcript Expression","titlePrefix":"Liver"});
        if($(window).width()<1500){
            that.rbChart.setWidth("98%");
            that.rlChart.setWidth("98%");
        }
	};

	that.parseParams(params);
	that.setup();
	return that;
};
            






