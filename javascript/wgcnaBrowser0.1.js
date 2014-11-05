/*
*	D3js based WGCNA Data Browser
*
* 	Author: Spencer Mahaffey
*	for http://phenogen.ucdenver.edu
*	Tabakoff Lab
* 	University of Colorado Denver AMC
* 	Department of Pharmaceutical Sciences Skaggs School of Pharmacy & Pharmaceutical Sciences
*
*	Builds an interactive view of WGCNA Modules.
*/


function WGCNABrowser(id,disptype,viewtype,tissue){
	that={};
	that.singleID=id;
	that.dispType=disptype;
	that.viewType=viewtype;
	that.moduleList=[];
	that.modules={};
	that.tissue=tissue;
	that.panel="";


	that.setup=function(){
		//request Module List
		that.requestModuleList();
		//create Image Controls
		that.createImageControls();
		//create View Controls
		that.createViewControls();
		//create Data Controls
		that.createDataControls();
	};

	that.requestModuleList=function (){
		$.ajax({
				url:  pathPrefix +"getWGCNAModules.jsp",
	   			type: 'GET',
	   			async: true,
				data: {modFileType:that.viewtype,id:that.singleID,organism:organism,panel:that.panel,tissue:that.tissue},
				dataType: 'json',
	    		success: function(data2){
	        		for(var i=0;i<data2.length;i++){
	        				that.moduleList.push(data2[i].ModuleID); 
	        				that.requestModule(data2[i].ModuleID);
	        		}
	        		console.log(that.moduleList);
	    		},
	    		error: function(xhr, status, error) {
	        		
	    		}
		});
	};
	that.requestModule=function(file){
		$.ajax({
				url:  "../../tmpData/modules/ds1/" +file+".json",
	   			type: 'GET',
	   			async: true,
				data: {},
				dataType: 'json',
	    		success: function(data2){
	        			that.modules[file]=data2;
	    		},
	    		error: function(xhr, status, error) {
	        		
	    		}
		});

	};
	that.createImageControls=function(){

	};

	that.createViewControls=function(){

	};

	that.createDataControls=function(){

	};

	//public method to create any type of WGCNA Image
	that.createMultiWGCNAImage=function(){

	};

	//common prototype to create generic view
	that.multiWGCNAImage=function(){

	};

	//internal methods to setup each specific type
	that.multiWGCNAImageGeneView=function(){

	};

	that.multiWGCNAImageGoView=function(){

	};
	that.multiWGCNAImageMultiMiRView=function(){

	};

	that.multiWGCNAImageEQTLView=function(){

	};

	//public method to create any type of WGCNA Image
	that.createSingleWGCNAImage=function(){

	};
	
	//common prototype to create generic view
	that.singleWGCNAImage=function(){

	};
	//internal methods to setup each specific type
	that.singleWGCNAImageGeneView=function(){

	};
	that.singleWGCNAImageGoView=function(){

	};
	that.singleWGCNAImageMultiMiRView=function(){

	};
	that.singleWGCNAImageEQTLView=function(){

	};

	return that;
}