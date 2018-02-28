PhenogenExpr=function(params){
	var that={};
	that.featureType="Long";
	that.displayHerit=true;
	that.dataPrefix="";
	that.displayCtrl=true;

	that.parseParams=function (params){
		if(params.div){
			that.ctrlDiv=params.div;
		}
		if(params.genomeBrowser){
			console.log("genome:");
			console.log(params.genomeBrowser);
			that.gb=params.genomeBrowser;
		}
        if(params.type){
            that.type=params.type;
        }
        if(params.featureType){
        	that.featureType=params.featureType;
        }
        if(params.dataPrefix){
        	that.dataPrefix=params.dataPrefix;
        }
        if(typeof params.displayCtrl!=='undefined'){
        	that.displayCtrl=params.displayCtrl;
        }
        that.displayHerit=true;
	};

	that.setup=function(){
		if(that.displayCtrl){
			that.ctrl=d3.select("div#"+that.ctrlDiv+"srcCtrl");
			that.ctrl.append("text").text("Display Feature Type:");
			that.sel=that.ctrl.append("select").attr("id","srcCtrl"+that.ctrlDiv)
					.attr("name","srcCtrl"+that.ctrlDiv)
					.on("change", function(){
						//change titles
						val=that.sel.node().value;
						that.featureType=val;
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
		}
		d3.select("span#"+that.ctrlDiv+"Titleb").html("Whole Brain Long RNA-Seq Expression");
		d3.select("span#"+that.ctrlDiv+"Titlel").html("Liver Long RNA-Seq Expression");
       	that.setupCharts();
	};

	that.setupCharts=function(){
		//setup charts
		var curPrefix="tmpData/browserCache/"+genomeVer+"/regionData/"+that.gb.folderName;
		if(that.dataPrefix!==""){
			curPrefix=that.dataPrefix;
		}
		that.brainURL=curPrefix+"/Brainexpr.json";
		that.liverURL=curPrefix+"/Liverexpr.json";
		if(that.featureType==="Small"){
			that.brainURL=curPrefix+"/Brain_sm_expr.json";
			that.liverURL=curPrefix+"/Liver_sm_expr.json";
			that.displayHerit=false;
		}
        that.rbChart=chart({"data":that.brainURL,"selector":"#chartBrain"+that.ctrlDiv,"allowResize":true,
        	"type":that.type,"width":"45%","height":"70%","displayHerit":that.displayHerit,
        "title":that.featureType+" RNA Gene/Transcript Expression","titlePrefix":"Whole Brain"});
        that.rlChart=chart({"data":that.liverURL,"selector":"#chartLiver"+that.ctrlDiv,"allowResize":true,
        	"type":that.type,"width":"45%","height":"70%","displayHerit":that.displayHerit,
        "title":that.featureType+" RNA Gene/Transcript Expression","titlePrefix":"Liver"});
        if($(window).width()<1500){
            that.rbChart.setWidth("98%");
            that.rlChart.setWidth("98%");
        }
	};

	that.parseParams(params);
	that.setup();
	return that;
};
            






