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


function WGCNABrowser(id,disptype,viewtype){
	that={};
	that.singleID=id;
	that.dispType=disptype;
	that.viewType=viewtype;
	that.moduleList=[];
	that.modules={};

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
				data: {modFileType:that.viewtype,id:that.singleID,organism:organism,},
				dataType: 'json',
	    		success: function(data2){
	    				that.moduleList=data2; 
	        			for(){
	        				that.requestModule();
	        			}
	    		},
	    		error: function(xhr, status, error) {
	        		
	    		}
		});
	};
	that.requestModule=function(file){
		$.ajax({
				url:  modulePrefix +file,
	   			type: 'GET',
	   			async: true,
				data: {},
				dataType: 'json',
	    		success: function(data2){
	        			modules[data2.ID]=data2;
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